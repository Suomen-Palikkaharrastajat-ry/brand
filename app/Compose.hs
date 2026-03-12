-- | blay-compose: generic .blay transformation tool.
--
-- Transforms one or more .blay files into a single output .blay by
-- optionally recolouring and/or tiling them side-by-side.
--
-- == Usage
--
-- @
-- blay-compose --input FILE[:RRGGBB:RRGGBB] [--input ...] --output FILE
--              [--tile] [--gap-studs N] [--pad-top N] [--pad-bottom N]
-- @
--
-- Each @--input@ may embed a per-file recolour rule as @FILE:FROM:TO@ where
-- FROM and TO are 6-digit hex colours without '#'.
--
-- @--tile@ composes inputs side-by-side (requires two or more inputs).
-- Without @--tile@ a single @--input@ is copied/recoloured to @--output@.
module Main where

import Control.Monad (when)
import Data.List (intercalate)
import qualified Data.Text as T
import Logo.BrickLayout
    ( BrickLayout (..)
    , RGB
    , composeLayouts
    , parseHex
    , recolorLayout
    , readBrickLayout
    , writeBrickLayout
    )
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStrLn, stderr)

-- One --input: a file path plus an optional FROM->TO recolour.
data InputSpec = InputSpec
    { isPath    :: FilePath
    , isRecolor :: Maybe (RGB, RGB)
    }

data ComposeArgs = ComposeArgs
    { caInputs    :: [InputSpec]
    , caOutput    :: Maybe FilePath
    , caTile      :: Bool
    , caGapStuds  :: Int
    , caPadTop    :: Maybe Int
    , caPadBottom :: Maybe Int
    }

defaultComposeArgs :: ComposeArgs
defaultComposeArgs = ComposeArgs
    { caInputs    = []
    , caOutput    = Nothing
    , caTile      = False
    , caGapStuds  = 2
    , caPadTop    = Nothing
    , caPadBottom = Nothing
    }

-- Entry point

main :: IO ()
main = do
    args <- getArgs
    case args of
        ("--help" : _) -> putStr usage >> exitSuccess
        ("-h"     : _) -> putStr usage >> exitSuccess
        _ -> case parseArgs args defaultComposeArgs of
                Left err -> die err
                Right ca -> case caOutput ca of
                    Nothing  -> die "--output is required"
                    Just out -> runCompose ca out

runCompose :: ComposeArgs -> FilePath -> IO ()
runCompose ca out = do
    when (null (caInputs ca)) $ die "at least one --input is required"
    bls <- mapM loadInput (caInputs ca)
    result <- assemble ca bls
    writeBrickLayout out result
    putStrLn "blay-compose: done."

assemble :: ComposeArgs -> [BrickLayout] -> IO BrickLayout
assemble ca bls = do
    tiled <- case bls of
        []   -> die "no inputs" >> return undefined
        [bl] -> do
            when (caTile ca) $
                hPutStrLn stderr "blay-compose: warning: --tile has no effect with a single input"
            return bl
        _    -> do
            when (not (caTile ca)) $ die "multiple --input files require --tile"
            return $ composeLayouts (caGapStuds ca) bls
    let withTop = maybe tiled  (\p -> tiled   { blPadTop    = p }) (caPadTop    ca)
        withBot = maybe withTop (\p -> withTop { blPadBottom = p }) (caPadBottom ca)
    return withBot

loadInput :: InputSpec -> IO BrickLayout
loadInput spec = do
    bl <- readBrickLayout (isPath spec)
    return $ case isRecolor spec of
        Nothing         -> bl
        Just (from, to) -> recolorLayout from to bl

-- Arg parsing

parseArgs :: [String] -> ComposeArgs -> Either String ComposeArgs
parseArgs []               ca = Right ca
parseArgs ["--tile"]       ca = Right ca { caTile = True }
parseArgs ("--tile" : rest) ca = parseArgs rest ca { caTile = True }
parseArgs [f]              _  = Left $ "missing value for flag: " ++ f
parseArgs (f : v : rest) ca = case f of
    "--input"      -> parseInputSpec v >>= \i ->
                          parseArgs rest ca { caInputs = caInputs ca ++ [i] }
    "--output"     -> parseArgs rest ca { caOutput    = Just v }
    "--gap-studs"  -> readInt f v >>= \n -> parseArgs rest ca { caGapStuds  = n }
    "--pad-top"    -> readInt f v >>= \n -> parseArgs rest ca { caPadTop    = Just n }
    "--pad-bottom" -> readInt f v >>= \n -> parseArgs rest ca { caPadBottom = Just n }
    _              -> Left $ "unknown flag: " ++ f

-- | Parse FILE or FILE:RRGGBB:RRGGBB.
-- Splits on the last two ':' so paths with colons work on Unix.
parseInputSpec :: String -> Either String InputSpec
parseInputSpec s =
    let parts = mySplitOn ':' s
    in case reverse parts of
        [path'] ->
            Right InputSpec { isPath = path', isRecolor = Nothing }
        (to : from : pathParts) ->
            case (parseHex (T.pack from), parseHex (T.pack to)) of
                (Just f, Just t) ->
                    Right InputSpec
                        { isPath    = intercalate ":" (reverse pathParts)
                        , isRecolor = Just (f, t)
                        }
                _ -> Left $ "bad --input (expected FILE or FILE:RRGGBB:RRGGBB): " ++ s
        _ -> Left $ "bad --input (expected FILE or FILE:RRGGBB:RRGGBB): " ++ s

mySplitOn :: Char -> String -> [String]
mySplitOn c str = case break (== c) str of
    (w, [])       -> [w]
    (w, _ : rest) -> w : mySplitOn c rest

readInt :: String -> String -> Either String Int
readInt flag s = case reads s of
    [(n, "")] -> Right n
    _         -> Left $ "expected integer for " ++ flag ++ ", got: " ++ s

die :: String -> IO a
die msg = hPutStrLn stderr ("blay-compose: " ++ msg) >> exitFailure

usage :: String
usage = unlines
    [ "Usage: blay-compose --input FILE[:FROM:TO] [--input ...] --output FILE"
    , "                    [--tile] [--gap-studs N] [--pad-top N] [--pad-bottom N]"
    , ""
    , "Transform one or more .blay files into a single output .blay."
    , "No project-specific colours or filenames are hardcoded."
    , ""
    , "Options:"
    , "  --input FILE[:RRGGBB:RRGGBB]  Input .blay, optionally recoloured."
    , "                                FROM/TO are 6-digit hex, no '#'."
    , "                                Flag may be repeated."
    , "  --output FILE                 Output .blay path (required)."
    , "  --tile                        Compose inputs side-by-side (needs >=2)."
    , "  --gap-studs N                 Stud-column gap between tiles [default: 2]"
    , "  --pad-top N                   Override pad-top on result (SVG px)"
    , "  --pad-bottom N                Override pad-bottom on result (SVG px)"
    ]
