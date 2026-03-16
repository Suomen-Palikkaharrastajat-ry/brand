module Logo.Favicons (generateFavicons) where

import Logo.Raster (exportPngSquareTrimmed)
import System.Directory (createDirectoryIfMissing)
import System.Process (callProcess)
import Control.Monad (forM_)

-- | Generate all favicon assets from the square logo SVG.
-- The source SVG may not be perfectly square; exportPngSquare fits it
-- into an exact N×N canvas (with transparent padding) so all outputs are
-- square, as required by browser and OS favicon specifications.
generateFavicons :: FilePath -> FilePath -> IO ()
generateFavicons squareSvgPath faviconDir = do
    createDirectoryIfMissing True faviconDir

    forM_ sizes $ \(sz, name) ->
        exportPngSquareTrimmed squareSvgPath (faviconDir ++ "/" ++ name ++ ".png") sz

    -- Bundle 16, 32, 48, 64px PNGs into a multi-size favicon.ico
    callProcess
        "icotool"
        [ "--create"
        , "-o"
        , faviconDir ++ "/favicon.ico"
        , faviconDir ++ "/favicon-16.png"
        , faviconDir ++ "/favicon-32.png"
        , faviconDir ++ "/favicon-48.png"
        , faviconDir ++ "/favicon-64.png"
        ]

    putStrLn $ "  Wrote " ++ faviconDir ++ "/favicon.ico"
  where
    sizes :: [(Int, String)]
    sizes =
        -- Browser favicons
        [ (16,  "favicon-16")
        , (32,  "favicon-32")
        , (48,  "favicon-48")
        , (64,  "favicon-64")
        -- Apple touch icons
        , (120, "apple-touch-icon-120")
        , (152, "apple-touch-icon-152")
        , (167, "apple-touch-icon-167")
        , (180, "apple-touch-icon")
        -- PWA icons
        , (192, "icon-192")
        , (512, "icon-512")
        ]
