{- | brand-gen: generate project design-guide assets from design-guide.toml.

Reads design-guide.toml and generates:
  * design-guide.tokens.json (W3C Design Tokens 2025.10)
  * design-guide/*.jsonld (JSON-LD section files)
  * src/Guide/Tokens.elm (Elm constants)
  * optionally public/brand.css

No .blay files are read; this step is independent of the blay render pipeline.

== Usage

@
brand-gen [--elm-tokens-out FILE] [--css-out FILE]
@
-}
module Main where

import Data.ByteString qualified as BS
import Data.Text.Encoding qualified as TE
import Data.Text.IO qualified as TIO
import Guide.CssGen (generateBrandCss)
import Guide.ElmGen (generateBrandModule)
import Guide.Json (generateDesignGuide)
import Guide.JsonLd (generateJsonLd)
import Guide.Toml (parseDesignGuide)
import System.Directory (createDirectoryIfMissing)
import System.Environment (getArgs)
import System.Exit (exitSuccess)
import System.FilePath (takeDirectory)

data BrandArgs = BrandArgs
    { baElmTokensOut :: FilePath
    , baCssOut :: Maybe FilePath
    }

defaultBrandArgs :: BrandArgs
defaultBrandArgs =
    BrandArgs
        { baElmTokensOut = "src/Guide/Tokens.elm"
        , baCssOut = Nothing
        }

main :: IO ()
main = do
    args <- getArgs
    case args of
        ("--help" : _) -> putStr usageText >> exitSuccess
        ("-h" : _) -> putStr usageText >> exitSuccess
        _ -> case parseArgs args defaultBrandArgs of
            Left err -> putStrLn ("brand-gen: " ++ err)
            Right ba -> runBrandGen ba

runBrandGen :: BrandArgs -> IO ()
runBrandGen ba = do
    dg <- parseDesignGuide "design-guide.toml"
    putStrLn "==> design-guide.tokens.json"
    generateDesignGuide dg
    putStrLn "==> design-guide/*.jsonld"
    generateJsonLd dg
    let elmOut = baElmTokensOut ba
    putStrLn $ "==> " ++ elmOut
    createDirectoryIfMissing True (takeDirectory elmOut)
    TIO.writeFile elmOut (generateBrandModule dg)
    putStrLn $ "Wrote " ++ elmOut
    case baCssOut ba of
        Nothing -> return ()
        Just cssOut -> do
            putStrLn $ "==> " ++ cssOut
            createDirectoryIfMissing True (takeDirectory cssOut)
            BS.writeFile cssOut (TE.encodeUtf8 (generateBrandCss dg))
            putStrLn $ "Wrote " ++ cssOut
    putStrLn "brand-gen: done."

parseArgs :: [String] -> BrandArgs -> Either String BrandArgs
parseArgs [] ba = Right ba
parseArgs [f] _ = Left $ "missing value for flag: " ++ f
parseArgs (f : v : rest) ba = case f of
    "--elm-tokens-out" -> parseArgs rest ba{baElmTokensOut = v}
    "--css-out" -> parseArgs rest ba{baCssOut = Just v}
    _ -> Left $ "unknown flag: " ++ f

usageText :: String
usageText =
    unlines
        [ "Usage: brand-gen [--elm-tokens-out FILE] [--css-out FILE]"
        , ""
        , "Generate project design-guide assets from Guide.* modules."
        , ""
        , "Options:"
        , "  --elm-tokens-out FILE   Elm tokens output path [default: src/Guide/Tokens.elm]"
        , "  --css-out FILE          Brand CSS output path  [default: none]"
        ]
