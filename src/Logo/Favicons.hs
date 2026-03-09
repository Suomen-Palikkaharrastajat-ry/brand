module Logo.Favicons (generateFavicons) where

import Logo.Raster (exportPng)
import System.Directory (createDirectoryIfMissing)
import System.Process (callProcess)
import Control.Monad (forM_)

-- | Generate all favicon assets from the square logo SVG.
generateFavicons :: FilePath -> FilePath -> IO ()
generateFavicons squareSvgPath faviconDir = do
    createDirectoryIfMissing True faviconDir

    forM_ sizes $ \(sz, name) ->
        exportPng squareSvgPath (faviconDir ++ "/" ++ name ++ ".png") sz

    -- Bundle 16, 32, 48px PNGs into a multi-size favicon.ico
    callProcess
        "icotool"
        [ "--create"
        , "-o"
        , faviconDir ++ "/favicon.ico"
        , faviconDir ++ "/favicon-16.png"
        , faviconDir ++ "/favicon-32.png"
        , faviconDir ++ "/favicon-48.png"
        ]

    putStrLn $ "  Wrote " ++ faviconDir ++ "/favicon.ico"
  where
    sizes :: [(Int, String)]
    sizes =
        [ (16, "favicon-16")
        , (32, "favicon-32")
        , (48, "favicon-48")
        , (180, "apple-touch-icon")
        , (192, "icon-192")
        , (512, "icon-512")
        ]
