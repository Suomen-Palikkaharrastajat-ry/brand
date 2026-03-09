-- | Build-time and runtime configuration for logo-gen.
--
-- All tunable constants live here as fields of 'Config'.  The Makefile
-- also declares them as Make variables (single documented source of truth)
-- and forwards them to the executable via CLI flags so that changing a
-- constant in the Makefile triggers regeneration without a Haskell rebuild.
module Logo.Config
    ( Config (..)
    , defaultConfig
    , parseConfig
    , usage
    ) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStr, hPutStrLn, stderr)

-- | All tunable constants for the logo pipeline.
data Config = Config
    { -- ── Inputs ────────────────────────────────────────────────────────────
      cfgSourceSvg  :: FilePath
      -- ^ Source minifig SVG (default: @source.svg@)
    , cfgFontPath   :: FilePath
      -- ^ Outfit variable font used in full logos
      --   (default: @fonts/Outfit-VariableFont_wght.ttf@)

    -- ── Rasterisation widths (pixels) ─────────────────────────────────────
    , cfgSqPx       :: Int
      -- ^ Target raster width for square blockify pass (default: 14)
    , cfgHzPx       :: Int
      -- ^ Target raster width for horizontal blockify pass (default: 62)

    -- ── Brick geometry ────────────────────────────────────────────────────
    , cfgBlkW       :: Int
      -- ^ Brick SVG unit width in SVG units (default: 24)
    , cfgBlkH       :: Int
      -- ^ Brick SVG unit height in SVG units (default: 20)
    , cfgPad        :: Int
      -- ^ Transparent column padding on each side of blockified image
      --   (default: 1)

    -- ── Logo layout ───────────────────────────────────────────────────────
    , cfgSqPadV     :: Int
      -- ^ Vertical padding added above and below square logos (default: 20)
    , cfgHzPadTop   :: Int
      -- ^ Top padding added above horizontal logos (default: 20)

    -- ── Subtitle text ─────────────────────────────────────────────────────
    , cfgTxtSize    :: Int
      -- ^ Subtitle font size in SVG units (default: 57)

    -- ── Animation ─────────────────────────────────────────────────────────
    , cfgAnimMs     :: Int
      -- ^ Animation frame duration in milliseconds (default: 10000)

    -- ── Export ────────────────────────────────────────────────────────────
    , cfgRasterW    :: Int
      -- ^ PNG/WebP export width in pixels (default: 800)

    -- ── Output directories ────────────────────────────────────────────────
    , cfgDesignDir  :: FilePath -- ^ Raw design SVGs          (default: @design@)
    , cfgSqSvgDir   :: FilePath -- ^ Square brick SVGs        (default: @logo/square/svg@)
    , cfgHzSvgDir   :: FilePath -- ^ Horizontal brick SVGs    (default: @logo/horizontal/svg@)
    , cfgSqPngDir   :: FilePath -- ^ Square raster outputs    (default: @logo/square/png@)
    , cfgHzPngDir   :: FilePath -- ^ Horizontal raster outputs(default: @logo/horizontal/png@)
    , cfgFaviconDir :: FilePath -- ^ Favicon outputs          (default: @favicon@)
    } deriving (Show)

-- | Default configuration matching the original hardcoded constants.
defaultConfig :: Config
defaultConfig = Config
    { cfgSourceSvg  = "source.svg"
    , cfgFontPath   = "fonts/Outfit-VariableFont_wght.ttf"
    , cfgSqPx       = 14
    , cfgHzPx       = 62
    , cfgBlkW       = 24
    , cfgBlkH       = 20
    , cfgPad        = 1
    , cfgSqPadV     = 20
    , cfgHzPadTop   = 20
    , cfgTxtSize    = 57
    , cfgAnimMs     = 10000
    , cfgRasterW    = 800
    , cfgDesignDir  = "design"
    , cfgSqSvgDir   = "logo/square/svg"
    , cfgHzSvgDir   = "logo/horizontal/svg"
    , cfgSqPngDir   = "logo/square/png"
    , cfgHzPngDir   = "logo/horizontal/png"
    , cfgFaviconDir = "favicon"
    }

-- | Parse CLI args and return a Config, or print usage and exit.
parseConfig :: IO Config
parseConfig = do
    args <- getArgs
    case args of
        ["--help"] -> putStr usage >> exitSuccess
        ["-h"]     -> putStr usage >> exitSuccess
        _          -> case applyAll args defaultConfig of
            Left err -> do
                hPutStrLn stderr $ "logo-gen: " ++ err
                hPutStr stderr usage
                exitFailure
            Right cfg -> return cfg

-- | Apply a list of @--flag value@ pairs to a Config.
applyAll :: [String] -> Config -> Either String Config
applyAll [] cfg = Right cfg
applyAll [flag] _ = Left $ "missing value for flag: " ++ flag
applyAll (flag : val : rest) cfg =
    applyOne flag val cfg >>= applyAll rest

applyOne :: String -> String -> Config -> Either String Config
applyOne flag val cfg = case flag of
    "--source"      -> Right cfg { cfgSourceSvg  = val }
    "--font-path"   -> Right cfg { cfgFontPath   = val }
    "--sq-px"       -> int $ \n -> cfg { cfgSqPx      = n }
    "--hz-px"       -> int $ \n -> cfg { cfgHzPx      = n }
    "--blk-w"       -> int $ \n -> cfg { cfgBlkW      = n }
    "--blk-h"       -> int $ \n -> cfg { cfgBlkH      = n }
    "--pad"         -> int $ \n -> cfg { cfgPad       = n }
    "--sq-pad-v"    -> int $ \n -> cfg { cfgSqPadV    = n }
    "--hz-pad-top"  -> int $ \n -> cfg { cfgHzPadTop  = n }
    "--txt-size"    -> int $ \n -> cfg { cfgTxtSize   = n }
    "--anim-ms"     -> int $ \n -> cfg { cfgAnimMs    = n }
    "--raster-w"    -> int $ \n -> cfg { cfgRasterW   = n }
    "--design-dir"  -> Right cfg { cfgDesignDir  = val }
    "--sq-svg-dir"  -> Right cfg { cfgSqSvgDir   = val }
    "--hz-svg-dir"  -> Right cfg { cfgHzSvgDir   = val }
    "--sq-png-dir"  -> Right cfg { cfgSqPngDir   = val }
    "--hz-png-dir"  -> Right cfg { cfgHzPngDir   = val }
    "--favicon-dir" -> Right cfg { cfgFaviconDir = val }
    _               -> Left $ "unknown flag: " ++ flag
  where
    int f = case reads val of
        [(n, "")] -> Right (f n)
        _         -> Left $ "expected integer for " ++ flag ++ ", got: " ++ val

-- | Help text printed on @--help@ or parse error.
usage :: String
usage = unlines
    [ "Usage: logo-gen [OPTIONS]"
    , ""
    , "Options (all have defaults; see defaultConfig):"
    , "  --source PATH       Source minifig SVG          [default: source.svg]"
    , "  --font-path PATH    Outfit variable font         [default: fonts/Outfit-VariableFont_wght.ttf]"
    , "  --sq-px N           Square blockify target px    [default: 14]"
    , "  --hz-px N           Horizontal blockify px       [default: 62]"
    , "  --blk-w N           Brick SVG unit width         [default: 24]"
    , "  --blk-h N           Brick SVG unit height        [default: 20]"
    , "  --pad N             Column padding each side     [default: 1]"
    , "  --sq-pad-v N        Square logo vertical pad     [default: 20]"
    , "  --hz-pad-top N      Horizontal logo top pad      [default: 20]"
    , "  --txt-size N        Subtitle font size (SVG px)  [default: 57]"
    , "  --anim-ms N         Animation frame duration ms  [default: 10000]"
    , "  --raster-w N        PNG/WebP export width px     [default: 800]"
    , "  --design-dir PATH   Raw design SVG output dir    [default: design]"
    , "  --sq-svg-dir PATH   Square SVG output dir        [default: logo/square/svg]"
    , "  --hz-svg-dir PATH   Horizontal SVG output dir    [default: logo/horizontal/svg]"
    , "  --sq-png-dir PATH   Square PNG/WebP output dir   [default: logo/square/png]"
    , "  --hz-png-dir PATH   Horizontal PNG/WebP dir      [default: logo/horizontal/png]"
    , "  --favicon-dir PATH  Favicon output dir           [default: favicon]"
    ]
