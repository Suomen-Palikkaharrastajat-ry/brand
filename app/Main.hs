-- | blay-render: convert a single .blay file to SVG, PNG, WebP and optionally
-- compose a subtitle text element below the brick logo.
--
-- == Usage
--
-- @
-- blay-render --input FILE.blay
--             [--svg-out FILE]
--             [--png-out FILE]  [--webp-out FILE]  [--width N]
--             [--compose-pad-bottom N]
--             [--compose-font PATH  --compose-text TEXT  [--compose-text-size N]
--              [--compose-light-color RRGGBB]  [--compose-dark-color RRGGBB]
--              [--compose-svg-out FILE]      [--compose-dark-svg-out FILE]
--              [--compose-png-out FILE]      [--compose-dark-png-out FILE]
--              [--compose-webp-out FILE]     [--compose-dark-webp-out FILE]]
--             [--favicon-dir DIR]
-- @
--
-- Colour arguments are 6-digit hex without '#'.
-- No brand names, colours, or filenames are hardcoded here.
module Main where

import Control.Exception (finally)
import Control.Monad (forM_, when)
import Data.Maybe (isJust)
import qualified Data.Text as T
import Logo.BrickLayout (BrickLayout (..), layoutToSvg, readBrickLayout)
import Logo.Compose (PadXMode (..), composeLogoWith, loadFont)
import Logo.Favicons (generateFavicons)
import Logo.Raster (exportPng, exportWebp)
import System.Directory (createDirectoryIfMissing, removeFile)
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath (takeDirectory)
import System.IO (hPutStrLn, stderr)

-- CLI args

data RenderArgs = RenderArgs
    { raInput              :: FilePath
    , raSvgOut             :: Maybe FilePath
    , raPngOut             :: Maybe FilePath
    , raWebpOut            :: Maybe FilePath
    , raWidth              :: Int
    -- subtitle composition
    , raComposePadBottom   :: Maybe Int  -- override pad-bottom for compose SVG
    , raComposePadX        :: Int        -- extra horizontal padding each side (SVG px)
    , raComposeSquare      :: Bool       -- auto-pad horizontally so canvas is square
    , raComposeFont        :: Maybe FilePath
    , raComposeText        :: String
    , raComposeText2       :: String     -- optional second subtitle line (empty = none)
    , raComposeTextSize    :: Int
    , raComposeTextWeight  :: Int        -- font-weight value (e.g. 400, 700)
    , raComposeLightColor  :: String  -- 6-digit hex, no '#'
    , raComposeDarkColor   :: String  -- 6-digit hex, no '#'
    , raComposeSvgOut      :: Maybe FilePath
    , raComposeDarkSvgOut  :: Maybe FilePath
    , raComposePngOut      :: Maybe FilePath
    , raComposeDarkPngOut  :: Maybe FilePath
    , raComposeWebpOut     :: Maybe FilePath
    , raComposeDarkWebpOut :: Maybe FilePath
    -- favicons
    , raFaviconDir         :: Maybe FilePath
    }

defaultArgs :: RenderArgs
defaultArgs = RenderArgs
    { raInput              = ""
    , raSvgOut             = Nothing
    , raPngOut             = Nothing
    , raWebpOut            = Nothing
    , raWidth              = 800
    , raComposePadBottom   = Nothing
    , raComposePadX        = 0
    , raComposeSquare      = False
    , raComposeFont        = Nothing
    , raComposeText        = ""
    , raComposeText2       = ""
    , raComposeTextSize    = 57
    , raComposeTextWeight  = 400
    , raComposeLightColor  = "05131D"
    , raComposeDarkColor   = "FFFFFF"
    , raComposeSvgOut      = Nothing
    , raComposeDarkSvgOut  = Nothing
    , raComposePngOut      = Nothing
    , raComposeDarkPngOut  = Nothing
    , raComposeWebpOut     = Nothing
    , raComposeDarkWebpOut = Nothing
    , raFaviconDir         = Nothing
    }

-- Entry point

main :: IO ()
main = do
    args <- getArgs
    case args of
        ("--help" : _) -> putStr usageText >> exitSuccess
        ("-h"     : _) -> putStr usageText >> exitSuccess
        _ -> case parseArgs args defaultArgs of
                Left err -> die err
                Right ra ->
                    if null (raInput ra)
                        then die "--input is required"
                        else runRender ra

runRender :: RenderArgs -> IO ()
runRender ra = do
    putStrLn $ "==> blay-render: " ++ raInput ra
    bl <- readBrickLayout (raInput ra)
    let svgText = T.pack (layoutToSvg bl)
        -- For composition, optionally override pad-bottom (e.g. to 0 so the
        -- subtitle sits closer to the logo mark regardless of the layout's
        -- own pad-bottom value).
        blForCompose  = maybe bl (\n -> bl { blPadBottom = n }) (raComposePadBottom ra)
        svgTextForCompose = T.pack (layoutToSvg blForCompose)

    -- 1. Write raw brick SVG
    forM_ (raSvgOut ra) $ \p -> writeSvgText p svgText

    -- 2. Raw raster (needs SVG on disk)
    let rawNeeded = isJust (raPngOut ra) || isJust (raWebpOut ra)
                 || isJust (raFaviconDir ra)
    when rawNeeded $
        withSvgFile (raSvgOut ra) (raInput ra ++ ".raw.tmp.svg") svgText $
            \svgPath -> do
                forM_ (raPngOut ra)     $ \p -> exportPng  svgPath p (raWidth ra)
                forM_ (raWebpOut ra)    $ \p -> exportWebp svgPath p (raWidth ra)
                forM_ (raFaviconDir ra) $ \d -> generateFavicons svgPath d

    -- 3. Subtitle composition
    let lightNeeded = isJust (raComposeSvgOut ra)
                   || isJust (raComposePngOut ra)
                   || isJust (raComposeWebpOut ra)
        darkNeeded  = isJust (raComposeDarkSvgOut ra)
                   || isJust (raComposeDarkPngOut ra)
                   || isJust (raComposeDarkWebpOut ra)
    when (lightNeeded || darkNeeded) $ do
        font <- requireArg "--compose-font" (raComposeFont ra)
        fontDataUri <- loadFont font
        let subtitleText  = T.pack (raComposeText ra)
            mSubtitleText2 = let s = raComposeText2 ra
                              in if null s then Nothing else Just (T.pack s)
            textSize      = raComposeTextSize ra
            fontWeight    = raComposeTextWeight ra
            padXMode      = if raComposeSquare ra
                              then AutoSquare
                              else FixedPadX (raComposePadX ra)

        when lightNeeded $ do
            let col  = T.pack $ "#" ++ raComposeLightColor ra
                cSvg = composeLogoWith fontDataUri subtitleText mSubtitleText2 col svgTextForCompose textSize fontWeight padXMode
            renderComposeVariant ra cSvg
                (raComposeSvgOut ra) (raComposePngOut ra) (raComposeWebpOut ra)
                (raInput ra ++ ".light.tmp.svg")

        when darkNeeded $ do
            let col  = T.pack $ "#" ++ raComposeDarkColor ra
                cSvg = composeLogoWith fontDataUri subtitleText mSubtitleText2 col svgTextForCompose textSize fontWeight padXMode
            renderComposeVariant ra cSvg
                (raComposeDarkSvgOut ra) (raComposeDarkPngOut ra) (raComposeDarkWebpOut ra)
                (raInput ra ++ ".dark.tmp.svg")

    putStrLn "Done."

-- | Write composed SVG and raster it.  Uses the given explicit SVG output path
-- if available, otherwise a temp path that is deleted after rasterization.
renderComposeVariant
    :: RenderArgs
    -> T.Text        -- composed SVG text
    -> Maybe FilePath -- svg-out
    -> Maybe FilePath -- png-out
    -> Maybe FilePath -- webp-out
    -> FilePath       -- temp path (used if svg-out is Nothing)
    -> IO ()
renderComposeVariant ra cSvg mSvgOut mPngOut mWebpOut tmpPath = do
    let rasterNeeded = isJust mPngOut || isJust mWebpOut
    case mSvgOut of
        Just svgPath -> do
            writeSvgText svgPath cSvg
            forM_ mPngOut  $ \p -> exportPng  svgPath p (raWidth ra)
            forM_ mWebpOut $ \p -> exportWebp svgPath p (raWidth ra)
        Nothing ->
            when rasterNeeded $
                withSvgFile Nothing tmpPath cSvg $ \svgPath -> do
                    forM_ mPngOut  $ \p -> exportPng  svgPath p (raWidth ra)
                    forM_ mWebpOut $ \p -> exportWebp svgPath p (raWidth ra)

-- | Run an action with the SVG on disk.
-- If an explicit path is provided, the file is expected to already exist.
-- Otherwise the SVG text is written to tempPath, the action runs, and the temp
-- file is deleted afterwards.
withSvgFile
    :: Maybe FilePath -- explicit path (already written)
    -> FilePath       -- temp path to use if no explicit path
    -> T.Text         -- SVG text to write if explicit path absent
    -> (FilePath -> IO ())
    -> IO ()
withSvgFile (Just p) _    _       action = action p
withSvgFile Nothing  tmp  svgText action = do
    writeSvgText tmp svgText
    action tmp `finally` removeFile tmp

writeSvgText :: FilePath -> T.Text -> IO ()
writeSvgText p svgText = do
    createDirectoryIfMissing True (takeDirectory p)
    writeFile p (T.unpack svgText)
    putStrLn $ "  Wrote " ++ p

requireArg :: String -> Maybe a -> IO a
requireArg flag Nothing  = die $ flag ++ " is required for compose outputs"
requireArg _    (Just x) = return x

-- Arg parsing

parseArgs :: [String] -> RenderArgs -> Either String RenderArgs
parseArgs []                          ra = Right ra
parseArgs ("--compose-square" : rest) ra = parseArgs rest ra { raComposeSquare = True }
parseArgs [f]                         _  = Left $ "missing value for flag: " ++ f
parseArgs (f : v : rest)              ra = case f of
    "--input"                -> parseArgs rest ra { raInput              = v }
    "--svg-out"              -> parseArgs rest ra { raSvgOut             = Just v }
    "--png-out"              -> parseArgs rest ra { raPngOut             = Just v }
    "--webp-out"             -> parseArgs rest ra { raWebpOut            = Just v }
    "--width"                -> readInt f v >>= \n -> parseArgs rest ra { raWidth = n }
    "--compose-pad-bottom"   -> readInt f v >>= \n -> parseArgs rest ra { raComposePadBottom = Just n }
    "--compose-pad-x"        -> readInt f v >>= \n -> parseArgs rest ra { raComposePadX      = n }
    "--compose-font"         -> parseArgs rest ra { raComposeFont        = Just v }
    "--compose-text"         -> parseArgs rest ra { raComposeText        = v }
    "--compose-text2"        -> parseArgs rest ra { raComposeText2       = v }
    "--compose-text-size"    -> readInt f v >>= \n -> parseArgs rest ra { raComposeTextSize  = n }
    "--compose-text-weight"  -> readInt f v >>= \n -> parseArgs rest ra { raComposeTextWeight = n }
    "--compose-light-color"  -> parseArgs rest ra { raComposeLightColor  = v }
    "--compose-dark-color"   -> parseArgs rest ra { raComposeDarkColor   = v }
    "--compose-svg-out"      -> parseArgs rest ra { raComposeSvgOut      = Just v }
    "--compose-dark-svg-out" -> parseArgs rest ra { raComposeDarkSvgOut  = Just v }
    "--compose-png-out"      -> parseArgs rest ra { raComposePngOut      = Just v }
    "--compose-dark-png-out" -> parseArgs rest ra { raComposeDarkPngOut  = Just v }
    "--compose-webp-out"     -> parseArgs rest ra { raComposeWebpOut     = Just v }
    "--compose-dark-webp-out"-> parseArgs rest ra { raComposeDarkWebpOut = Just v }
    "--favicon-dir"          -> parseArgs rest ra { raFaviconDir         = Just v }
    _                        -> Left $ "unknown flag: " ++ f

readInt :: String -> String -> Either String Int
readInt flag s = case reads s of
    [(n, "")] -> Right n
    _         -> Left $ "expected integer for " ++ flag ++ ", got: " ++ s

die :: String -> IO a
die msg = hPutStrLn stderr ("blay-render: " ++ msg) >> exitFailure

usageText :: String
usageText = unlines
    [ "Usage: blay-render --input FILE.blay [OPTIONS]"
    , ""
    , "Render a .blay brick layout to SVG, PNG, and/or WebP."
    , "No brand names, colours, or filenames are hardcoded."
    , ""
    , "Core options:"
    , "  --input FILE            Input .blay file (required)"
    , "  --svg-out FILE          Write raw brick SVG"
    , "  --png-out FILE          Write PNG raster"
    , "  --webp-out FILE         Write WebP raster"
    , "  --width N               Raster width in pixels      [default: 800]"
    , ""
    , "Subtitle composition (all compose-* outputs require --compose-font and"
    , "--compose-text to be set):"
    , "  --compose-pad-bottom N      Override pad-bottom for the compose SVG (e.g. 0)"
    , "  --compose-pad-x N           Extra horizontal padding each side (SVG px) [default: 0]"
    , "  --compose-square            Auto-pad horizontally so canvasW == canvasH (square output)"
    , "  --compose-font PATH         Outfit variable font path"
    , "  --compose-text TEXT         Subtitle text line 1"
    , "  --compose-text2 TEXT        Subtitle text line 2 (omit for single-line)"
    , "  --compose-text-size N       Subtitle font size (SVG px) [default: 57]"
    , "  --compose-text-weight N     Subtitle font weight        [default: 400]"
    , "  --compose-light-color HEX   Light subtitle colour       [default: 05131D]"
    , "  --compose-dark-color HEX    Dark subtitle colour        [default: FFFFFF]"
    , "  --compose-svg-out FILE      Light composed SVG"
    , "  --compose-dark-svg-out FILE Dark composed SVG"
    , "  --compose-png-out FILE      Light composed PNG"
    , "  --compose-dark-png-out FILE Dark composed PNG"
    , "  --compose-webp-out FILE     Light composed WebP"
    , "  --compose-dark-webp-out FILE Dark composed WebP"
    , ""
    , "Favicons:"
    , "  --favicon-dir DIR       Generate favicons from brick SVG into DIR"
    ]
