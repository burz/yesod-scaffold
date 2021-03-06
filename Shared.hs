{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}
module Shared where

import ClassyPrelude.Conduit
import Shelly (Sh, run, fromText)
import Text.ProjectTemplate (createTemplate)
import Filesystem (createTree)

branches :: [Text]
branches = ["postgres", "sqlite", "mysql", "mongo", "simple", "postgres-fay"]

master :: Text
master = "postgres"

-- | Works in the current Shelly directory. Confusingly, the @FilePath@
-- destination is relative to the original working directory.
createHsFiles :: FilePath -- ^ root
              -> Text -- ^ branch
              -> FilePath -- ^ destination
              -> Sh ()
createHsFiles root branch fp = do
    files <- run "git" ["ls-tree", "-r", branch, "--name-only"]
    liftIO $ createTree $ directory fp
    liftIO
        $ runResourceT
        $ mapM_ (yield . toPair . fromText) (lines files)
       $$ createTemplate
       =$ sinkFile fp
  where
    toPair fp' = (fp', readFile $ root </> fp')
