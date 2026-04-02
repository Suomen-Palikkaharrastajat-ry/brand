module Logo.Animate (assembleGif, assembleWebp) where

import System.Process (callProcess)
import Text.Printf (printf)

{- | Assemble PNG frames into an animated GIF using gifski.
animMs is the milliseconds per frame.
-}
assembleGif :: [FilePath] -> FilePath -> Int -> IO ()
assembleGif framePaths outGif animMs = do
    putStrLn $ "  animate " ++ outGif ++ "  (" ++ show (length framePaths) ++ " frames)"
    -- gifski uses fps; convert ms-per-frame to fps
    let fps :: Double
        fps = 1000.0 / fromIntegral animMs
        fpsStr :: String
        fpsStr = printf "%.4f" fps
    callProcess "gifski" (["--fps", fpsStr, "-o", outGif] ++ framePaths)

{- | Assemble PNG frames into an animated WebP using img2webp.
animMs is the milliseconds per frame.
-}
assembleWebp :: [FilePath] -> FilePath -> Int -> IO ()
assembleWebp framePaths outWebp animMs = do
    putStrLn $ "  animate " ++ outWebp ++ "  (" ++ show (length framePaths) ++ " frames)"
    let delayArg = show animMs
        frameArgs = concatMap (\f -> ["-d", delayArg, f]) framePaths
    callProcess "img2webp" (frameArgs ++ ["-o", outWebp])
