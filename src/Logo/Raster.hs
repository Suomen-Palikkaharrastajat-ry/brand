module Logo.Raster (exportPng, exportPngSquare, exportPngSquareTrimmed, exportWebp) where

import Control.Exception (bracket)
import System.Directory (doesDirectoryExist, listDirectory, makeAbsolute, removeFile)
import System.Environment (getEnvironment)
import System.FilePath ((</>))
import System.IO (hClose, hPutStr, openTempFile)
import System.Process (callProcess, createProcess, env, proc, readProcess, waitForProcess)

-- | Export SVG to PNG at given width using rsvg-convert.
-- Sets up a fontconfig config so Pango can find the Outfit font by name.
exportPng :: FilePath -> FilePath -> Int -> IO ()
exportPng svgIn pngOut widthPx = do
    putStrLn $ "  raster " ++ svgIn ++ " -> " ++ pngOut
    callRsvg ["-w", show widthPx] svgIn pngOut

-- | Export SVG to a square PNG of exactly sizePx × sizePx.
-- The SVG is scaled to fit within the square while preserving its aspect
-- ratio (--keep-aspect-ratio), and the output canvas is forced to the
-- requested square dimensions via --page-width/--page-height.  Any
-- letterbox/pillarbox area is transparent.
exportPngSquare :: FilePath -> FilePath -> Int -> IO ()
exportPngSquare svgIn pngOut sizePx = do
    putStrLn $ "  raster (square) " ++ svgIn ++ " -> " ++ pngOut
    let sz = show sizePx
    callRsvg ["-w", sz, "-h", sz, "--keep-aspect-ratio",
              "--page-width", sz, "--page-height", sz] svgIn pngOut

-- | Export SVG to a square PNG, trimming transparent padding first so the
-- actual brick content fills as much of the target square as possible.
-- Steps:
--   1. Render at 8× the target size for accurate trim detection.
--   2. Use ImageMagick to trim transparent edges, pad back to square,
--      and scale to the target size.
-- Only the content bounding box is used; transparent letterbox/pillarbox
-- from pad-left/pad-right/pad-top/pad-bottom in the source layout is removed.
exportPngSquareTrimmed :: FilePath -> FilePath -> Int -> IO ()
exportPngSquareTrimmed svgIn pngOut sizePx = do
    putStrLn $ "  raster (square, trimmed) " ++ svgIn ++ " -> " ++ pngOut
    let sz      = show sizePx
        renderSz = show (max 512 (sizePx * 8))
        tmpRaw  = pngOut ++ ".raw.tmp.png"
    callRsvg ["-w", renderSz, "-h", renderSz, "--keep-aspect-ratio",
              "--page-width", renderSz, "--page-height", renderSz] svgIn tmpRaw
    -- Step 1: trim transparent edges into a second temp file.
    let tmpTrim = pngOut ++ ".trim.tmp.png"
    callProcess "magick" [tmpRaw, "-trim", "+repage", tmpTrim]
    removeFile tmpRaw
    -- Step 2: read back the trimmed dimensions so we can pad to a square
    -- with a concrete geometry string.  Using %w/%h avoids FX expressions
    -- that are not supported by ImageMagick 6's -extent argument.
    dimStr <- readProcess "identify" ["-format", "%w %h", tmpTrim] ""
    let [w, h] = map (read :: String -> Int) (words dimStr)
        dim    = show (max w h)
    -- Step 3: pad to square and scale to final size.
    callProcess "magick"
        [ tmpTrim
        , "-gravity", "center"
        , "-background", "transparent"
        , "-extent", dim ++ "x" ++ dim
        , "-resize", sz ++ "x" ++ sz
        , pngOut
        ]
    removeFile tmpTrim

-- | Export SVG to WebP at given width (via intermediate PNG and cwebp).
exportWebp :: FilePath -> FilePath -> Int -> IO ()
exportWebp svgIn webpOut widthPx = do
    putStrLn $ "  raster " ++ svgIn ++ " -> " ++ webpOut
    let tmpPng = webpOut ++ ".tmp.png"
    callRsvg ["-w", show widthPx] svgIn tmpPng
    callProcess "cwebp" ["-q", "90", tmpPng, "-o", webpOut]
    removeFile tmpPng

-- | Run rsvg-convert with FONTCONFIG_FILE set to a temporary config that
-- lists fonts/ plus every Nix-store share/fonts directory.
-- This ensures Pango finds "Outfit" (and any fallback system fonts).
callRsvg :: [String] -> FilePath -> FilePath -> IO ()
callRsvg sizeArgs svgIn pngOut =
    withFontConfigEnv $ \e -> do
        (_, _, _, ph) <-
            createProcess
                (proc "rsvg-convert" (sizeArgs ++ ["-f", "png", "-o", pngOut, svgIn]))
                    { env = Just e }
        _ <- waitForProcess ph
        return ()

-- | Run an action with FONTCONFIG_FILE pointing to a temporary config that
-- lists our fonts/ dir plus every Nix-store share/fonts dir.
withFontConfigEnv :: ([(String, String)] -> IO a) -> IO a
withFontConfigEnv action =
    bracket acquire removeFile $ \fcPath -> do
        base <- getEnvironment
        let e = ("FONTCONFIG_FILE", fcPath)
                : filter (\(k, _) -> k /= "FONTCONFIG_FILE") base
        action e
  where
    acquire = do
        fontsDir  <- makeAbsolute "fonts"
        nixDirs   <- nixStoreFontDirs
        (path, h) <- openTempFile "/tmp" "logo_fc_.conf"
        hPutStr h (buildFcConf (fontsDir : nixDirs))
        hClose h
        return path

-- | Collect every @\/nix\/store\/<entry>\/share\/fonts@ directory that exists.
-- Returns an empty list on non-Nix systems where @\/nix\/store@ is absent.
nixStoreFontDirs :: IO [FilePath]
nixStoreFontDirs = do
    storeExists <- doesDirectoryExist "/nix/store"
    if not storeExists
        then return []
        else do
            entries <- listDirectory "/nix/store"
            let candidates = ["/nix/store" </> e </> "share" </> "fonts" | e <- entries]
            flags <- mapM doesDirectoryExist candidates
            return [d | (d, ok) <- zip candidates flags, ok]

-- | Build a fontconfig XML config listing the given directories.
-- A writable @cachedir@ under @\/tmp@ avoids read-only Nix-store cache failures.
buildFcConf :: [FilePath] -> String
buildFcConf dirs =
    "<?xml version=\"1.0\"?>\n\
    \<fontconfig>\n\
    \  <cachedir>/tmp/logo-fontconfig-cache</cachedir>\n"
    ++ concatMap (\d -> "  <dir>" ++ d ++ "</dir>\n") dirs
    ++ "</fontconfig>\n"
