{- | blay-animate: assemble pre-rendered PNG frames into animated GIF and/or WebP.

== Usage

@
blay-animate --input FRAME1.png [--input FRAME2.png ...]
             [--gif-out FILE]  [--webp-out FILE]
             [--anim-ms N]
@

Frames are assembled in the order --input flags appear.
No filenames or timings are hardcoded.
-}
module Main where

import Control.Monad (when)
import Logo.Animate (assembleGif, assembleWebp)
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStrLn, stderr)

data AnimArgs = AnimArgs
    { aaInputs :: [FilePath]
    , aaGifOut :: Maybe FilePath
    , aaWebpOut :: Maybe FilePath
    , aaAnimMs :: Int
    }

defaultAnimArgs :: AnimArgs
defaultAnimArgs =
    AnimArgs
        { aaInputs = []
        , aaGifOut = Nothing
        , aaWebpOut = Nothing
        , aaAnimMs = 10000
        }

main :: IO ()
main = do
    args <- getArgs
    case args of
        ("--help" : _) -> putStr usageText >> exitSuccess
        ("-h" : _) -> putStr usageText >> exitSuccess
        _ -> case parseArgs args defaultAnimArgs of
            Left err -> die err
            Right aa -> runAnimate aa

runAnimate :: AnimArgs -> IO ()
runAnimate aa = do
    let frames = aaInputs aa
    when (null frames) $ die "at least one --input PNG frame is required"
    when (noOutput (aaGifOut aa) (aaWebpOut aa)) $
        die "at least one of --gif-out or --webp-out is required"
    let ms = aaAnimMs aa
    case aaGifOut aa of
        Just p -> assembleGif frames p ms
        Nothing -> return ()
    case aaWebpOut aa of
        Just p -> assembleWebp frames p ms
        Nothing -> return ()
    putStrLn "blay-animate: done."

noOutput :: Maybe a -> Maybe a -> Bool
noOutput Nothing Nothing = True
noOutput _ _ = False

parseArgs :: [String] -> AnimArgs -> Either String AnimArgs
parseArgs [] aa = Right aa
parseArgs [f] _ = Left $ "missing value for flag: " ++ f
parseArgs (f : v : rest) aa = case f of
    "--input" -> parseArgs rest aa{aaInputs = aaInputs aa ++ [v]}
    "--gif-out" -> parseArgs rest aa{aaGifOut = Just v}
    "--webp-out" -> parseArgs rest aa{aaWebpOut = Just v}
    "--anim-ms" -> readInt f v >>= \n -> parseArgs rest aa{aaAnimMs = n}
    _ -> Left $ "unknown flag: " ++ f

readInt :: String -> String -> Either String Int
readInt flag s = case reads s of
    [(n, "")] -> Right n
    _ -> Left $ "expected integer for " ++ flag ++ ", got: " ++ s

die :: String -> IO a
die msg = hPutStrLn stderr ("blay-animate: " ++ msg) >> exitFailure

usageText :: String
usageText =
    unlines
        [ "Usage: blay-animate --input FRAME.png [--input ...] [OPTIONS]"
        , ""
        , "Assemble pre-rendered PNG frames into an animated GIF and/or WebP."
        , "Frames are assembled in the order the --input flags appear."
        , ""
        , "Options:"
        , "  --input FILE      PNG frame to include (repeatable, required)"
        , "  --gif-out FILE    Output animated GIF"
        , "  --webp-out FILE   Output animated WebP"
        , "  --anim-ms N       Frame duration in milliseconds  [default: 10000]"
        ]
