module Application.Database.PostgreSQL.Compact where

import Prelude
import Control.Applicative
import Data.Pool
import Database.PostgreSQL.Simple
import Yesod.Default.Config
import Data.Aeson

type ConnPool = Pool Connection

mkConnPool :: Show e => e -> FilePath -> IO ConnPool
mkConnPool env file = do
    (conf, np) <- withYamlEnvironment file env parser
    createPool (connect conf) close 1 20 np
  where
    parser (Object o) = do
        c <- ConnectInfo 
             <$> o .: "host"
             <*> o .: "port"
             <*> o .: "user"
             <*> o .: "password"
             <*> o .: "database"
        p <- o .: "poolsize"
        pure (c,p)
    parser _ = empty
