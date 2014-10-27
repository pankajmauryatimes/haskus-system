import Text.Printf
import Data.Foldable (traverse_)
--import Data.List (intersperse)
import Control.Concurrent.STM
import Control.Applicative ((<$>))

import ViperVM.Platform.Host
import ViperVM.Platform.PlatformInfo
import ViperVM.Platform.Loading
import ViperVM.Platform.Config
import ViperVM.Platform.Types(Memory(..))
import qualified ViperVM.STM.TSet as TSet

main :: IO ()
main = do
   putStrLn "Loading Platform..."
   pf <- loadPlatform defaultConfig {
            enableOpenCLCPUs = True
         }

   let 
      showInfo x = putStrLn $ "  - " ++ x

      memoriesStr x 
         | x <= 1    = printf "%d memory found" x
         | otherwise = printf "%d memories found" x
      procsStr x 
         | x <= 1    = printf "%d processor found" x
         | otherwise = printf "%d processors found" x
      netsStr x 
         | x <= 1    = printf "%d network found" x
         | otherwise = printf "%d networks found" x

      --linkTo m mis = putStrLn $ "  - " ++ show (memoryId m) ++ " -> " ++ concat (intersperse ", " (fmap (show . memoryId) mis))

      extractMem xs x = return (x:xs)

   mems <- reverse <$> atomically (breadthFirstMemories pf [] extractMem)

   putStrLn . memoriesStr . length $ mems
   traverse_ (showInfo . memoryInfo) mems

   procs <- atomically (TSet.toList =<< TSet.unions (map memoryProcs mems))

   putStrLn . procsStr $ length procs
   traverse_ (showInfo . procInfo) procs

   nets <- atomically (TSet.toList =<< TSet.unions (map memoryNetworks mems))

   putStrLn . netsStr $ length nets
   traverse_ (showInfo . networkInfo) nets

   --putStrLn "Links"
   --traverse_ (\m -> linkTo m =<< atomically (memoryNeighbors m)) (platformMemories pf)
