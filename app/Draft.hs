module Main where

import Logo.Blockify (blockifyToLayout)
import Logo.BrickLayout (writeBrickLayout)
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStrLn, stderr)

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["--help"] -> putStr draftUsage >> exitSuccess
        ["-h"] -> putStr draftUsage >> exitSuccess
        _ -> case parseDraftArgs args defaultDraftArgs of
            Left err -> hPutStrLn stderr ("blay-draft: " ++ err) >> exitFailure
            Right da -> runDraft da

data DraftArgs = DraftArgs
    { daSource :: FilePath
    , daOutput :: FilePath
    , daSqPx :: Int
    , daBlkW :: Int
    , daBlkH :: Int
    , daPad :: Int
    , daPadTop :: Int
    , daPadBot :: Int
    }

defaultDraftArgs :: DraftArgs
defaultDraftArgs =
    DraftArgs
        { daSource = "source.svg"
        , daOutput = "layout/first.blay"
        , daSqPx = 14
        , daBlkW = 24
        , daBlkH = 20
        , daPad = 1
        , daPadTop = 20
        , daPadBot = 20
        }

runDraft :: DraftArgs -> IO ()
runDraft da = do
    layout <-
        blockifyToLayout
            (daSource da)
            (daSqPx da)
            (daBlkW da)
            (daBlkH da)
            (daPad da)
            (daPadTop da)
            (daPadBot da)
    writeBrickLayout (daOutput da) layout
    putStrLn "Done."

parseDraftArgs :: [String] -> DraftArgs -> Either String DraftArgs
parseDraftArgs [] da = Right da
parseDraftArgs [f] _ = Left $ "missing value for flag: " ++ f
parseDraftArgs (f : v : rest) da = case f of
    "--source" -> parseDraftArgs rest da{daSource = v}
    "--output" -> parseDraftArgs rest da{daOutput = v}
    "--sq-px" -> readInt f v >>= \n -> parseDraftArgs rest da{daSqPx = n}
    "--blk-w" -> readInt f v >>= \n -> parseDraftArgs rest da{daBlkW = n}
    "--blk-h" -> readInt f v >>= \n -> parseDraftArgs rest da{daBlkH = n}
    "--pad" -> readInt f v >>= \n -> parseDraftArgs rest da{daPad = n}
    "--pad-top" -> readInt f v >>= \n -> parseDraftArgs rest da{daPadTop = n}
    "--pad-bot" -> readInt f v >>= \n -> parseDraftArgs rest da{daPadBot = n}
    _ -> Left $ "unknown flag: " ++ f

readInt :: String -> String -> Either String Int
readInt flag s = case reads s of
    [(n, "")] -> Right n
    _ -> Left $ "expected integer for " ++ flag ++ ", got: " ++ s

draftUsage :: String
draftUsage =
    unlines
        [ "Usage: blay-draft [OPTIONS]"
        , ""
        , "Rasterize a source SVG into a .blay brick-layout draft."
        , "Use this locally to generate a starting point, then hand-edit as needed."
        , ""
        , "Options:"
        , "  --source PATH   Input SVG file            [default: source.svg]"
        , "  --output PATH   Output .blay file         [default: layout/first.blay]"
        , "  --sq-px N       Target raster width (px)  [default: 14]"
        , "  --blk-w N       Brick SVG unit width       [default: 24]"
        , "  --blk-h N       Brick SVG unit height      [default: 20]"
        , "  --pad N         Column padding each side   [default: 1]"
        , "  --pad-top N     Top padding (SVG px)       [default: 20]"
        , "  --pad-bot N     Bottom padding (SVG px)    [default: 20]"
        ]
