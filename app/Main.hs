{-# LANGUAGE TypeApplications #-}

module Main where

import Data.List (intercalate)
import Data.Maybe (listToMaybe)
import System.Environment (getArgs)

data FactorTree = Prime Integer | Composite Integer FactorTree FactorTree
  deriving (Show)

isqrt :: Integer -> Integer
isqrt = floor @Double . sqrt . fromIntegral

find2 :: Integer -> Maybe (Integer, Integer)
find2 n =
  let test = listToMaybe $ take 1 $ filter (\x -> n `mod` x == 0) [2 .. isqrt n]
   in case test of
        Nothing -> Nothing
        Just x -> Just (x, n `div` x)

factor :: Integer -> FactorTree
factor n = case find2 n of
  Nothing -> Prime n
  Just (fac1, fac2) -> Composite n (factor fac1) (factor fac2)

getPrimes :: FactorTree -> [Integer]
getPrimes (Prime n) = [n]
getPrimes (Composite _ t1 t2) = getPrimes t1 ++ getPrimes t2

primeMult :: [Integer] -> [(Integer, Integer)]
primeMult [] = []
primeMult (x : xs) = (x, toInteger $ length (filter (== x) xs) + 1) : primeMult (filter (/= x) xs)

pprint :: (Integer, Integer) -> String
pprint (n, m)
  | m == 1 = show n
  | otherwise = show n ++ "^" ++ show m

pprint2 :: [(Integer, Integer)] -> String
pprint2 xs = intercalate " * " (fmap pprint xs)

printPrimes :: Integer -> String
printPrimes = pprint2 . primeMult . getPrimes . factor

main :: IO ()
main = do
  num <- fmap (read . head) getArgs
  putStrLn $ printPrimes num
