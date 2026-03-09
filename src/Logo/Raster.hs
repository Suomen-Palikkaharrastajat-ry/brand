module Logo.Raster (exportPng, exportWebp) where

import Control.Exception (bracket)
import System.Directory (doesDirectoryExist, listDirectory, makeAbsolute, removeFile)
import System.Environment (getEnvironment)
import System.FilePath ((</>))
import System.IO (hClose, hPutStr, openTempFile)
import System.Process (callProcess, createProcess, env, proc, waitForProcess)

-- | Export SVG to PNG at given width using rsvg-convert.
-- Sets up a fontconfig config so Pango can find the Outfit font by name.
exportPng :: FilePath -> FilePath -> Int -> IO ()
exportPng svgIn pngOut widthPx = do
    putStrLn $ "  raster " ++ svgIn ++ " -> " ++ pngOut
    callRsvg svgIn pngOut widthPx

-- | Export SVG to WebP at given width (via intermediate PNG and cwebp).
exportWebp :: FilePath -> FilePath -> Int -> IO ()
exportWebp svgIn webpOut widthPx = do
    putStrLn $ "  raster " ++ svgIn ++ " -> " ++ webpOut
    let tmpPng = webpOut ++ ".tmp.png"
    callRsvg svgIn tmpPng widthPx
    callProcess "cwebp" ["-q", "90", tmpPng, "-o", webpOut]
    removeFile tmpPng

-- | Run rsvg-convert with FONTCONFIG_FILE set to a temporary config that
-- lists fonts/ plus every Nix-store share/fonts directory.
-- This ensures Pango finds "Outfit" (and any fallback system fonts).
callRsvg :: FilePath -> FilePath -> Int -> IO ()
callRsvg svgIn pngOut widthPx =
    withFontConfigEnv $ \e -> do
        (_, _, _, ph) <-
            createProcess
                (proc "rsvg-convert" ["-w", show widthPx, "-f", "png", "-o", pngOut, svgIn])
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
-- Mirrors what @scripts/svg_to_png.py@ did so fallback fonts also work.
nixStoreFontDirs :: IO [FilePath]
nixStoreFontDirs = do
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
