module Helper where

-----------------------
-- IMPORT STATEMENTS -- 
-----------------------

-- Library Imports -- 
import System.Environment
import Control.Exception
import System.IO ( hPutStr, stdout, stderr, hPutStrLn )
import Data.List
import Data.Char (isSpace) 
import Data.List.Split

-- Local Imports -- 
import Tokens
import Grammar
import Types




-- ================================================================================ --
-- ================================================================================ --
-- ================================ HELPER METHODS ================================ --
-- ================================================================================ --
-- ================================================================================ --




-----------------------------
-- READING TABLE FROM FILE -- 
-----------------------------

-- myReadFile
        -- @brief:
        -- @params: 
        -- @return:
myReadFile :: String -> IO String
myReadFile file = do
                        strOrExc <- try $ readFile file :: IO (Either SomeException String)
                        case strOrExc of
                                Left except -> return "error"
                                Right contents -> return contents

-- getTableFromLines
        -- @brief:
        -- @params: 
        -- @return:
getTableFromLines :: [String] -> [Configuration] -> Table
getTableFromLines [] config         = []
getTableFromLines (row:rows) config = cells : (getTableFromLines rows config)
        where
                cells = splitOn delim row
                delim = if (hasInputDelim config) then
                                getInputDelim config
                            else 
                                ","

-- hasInputDelim
        -- @brief:
        -- @params: 
        -- @return:
hasInputDelim :: [Configuration] -> Bool
hasInputDelim []                        = False
hasInputDelim ((InputDelim del):cs) = True
hasInputDelim (c:cs)                    = hasInputDelim cs

-- getInputDelim
        -- @brief:
        -- @params: 
        -- @return:
getInputDelim :: [Configuration] -> String
getInputDelim []                        = error "No output delimiter configuration provided.@"
getInputDelim ((InputDelim ""):cs)  = error "The input delimiter cannot not be null.@"
getInputDelim ((InputDelim del):cs) = del
getInputDelim (c:cs)                    = getInputDelim cs

-- hasOutputDelim
        -- @brief:
        -- @params: 
        -- @return:
hasOutputDelim :: [Configuration] -> Bool
hasOutputDelim []                         = False
hasOutputDelim ((OutputDelim del):cs) = True
hasOutputDelim (c:cs)                     = hasOutputDelim cs

-- getOutputDelim
        -- @brief:
        -- @params: 
        -- @return:
getOutputDelim :: [Configuration] -> String
getOutputDelim []                         = error "No output delimiter configuration provided.@"
getOutputDelim ((OutputDelim ""):cs)  = error "The output delimiter cannot not be null.@"
getOutputDelim ((OutputDelim del):cs) = del
getOutputDelim (c:cs)                     = getOutputDelim cs

----------------------
-- FORMATTING TABLE --
---------------------- 

-- formatTable
        -- @brief:
        -- @params: 
        -- @return:
formatTable :: Table -> [Configuration] -> Table
formatTable [] config    = [[]]
formatTable table config = trimTable table

-- trimTable
        -- @brief:
        -- @params: 
        -- @return:
trimTable :: Table -> Table
trimTable [] = []
trimTable (row:rows) = (trimRow row) : (trimTable rows)

-- trimRow
        -- @brief:
        -- @params: 
        -- @return:
trimRow :: Row -> Row
trimRow [] = []
trimRow (cell:cells) = trimCell cell : trimRow cells

-- trim
        -- @brief:
        -- @params: 
        -- @return:
trimCell :: String -> String
trimCell = f . f
   where f = reverse . dropWhile isSpace

------------------------
-- UPDATING VARIABLES --
------------------------ 

-- updateVars
        -- @brief:
        -- @params: 
        -- @return:
updateVars :: Var -> Vars -> Vars
updateVars newVar [] = [newVar]
updateVars (name, table) ((varName,varTable):varsToGo) | name == varName = [(name, table)] ++ varsToGo
                                                       | otherwise = [(varName,varTable)] ++ (updateVars (name,table) varsToGo)

------------------
-- MISC METHODS -- 
------------------

-- getCellFromTable
        -- @brief:
        -- @params: 
        -- @return:
getCellFromTable :: Table -> Int -> Int -> Cell
getCellFromTable table row col = table!!row!!col

-- getTableWidth
        -- @brief:
        -- @params: 
        -- @return:
getTableWidth :: Table -> Int
getTableWidth []    = 0 -- for case when input file is empty
getTableWidth table = length (table!!0) -- CAUSES PROBLEMS IF TABLE IS NOT UNIFORM

-- getNullRow
        -- @brief:
        -- @params: 
        -- @return:
getNullRow :: Int -> Row
getNullRow 0 = []
getNullRow width = "" : (getNullRow (width-1))


-- interleave
        -- @brief:
        -- @params: 
        -- @return:
interleave :: [a] -> [a] -> [a]
interleave xs ys = concat (zipWith (\x y -> [x]++[y]) xs ys)


-- interleaveAll
        -- @brief:
        -- @params: 
        -- @return:
interleaveAll :: [a] -> [a] -> [a]
interleaveAll xs ys = (interleave xs ys) ++ extraElements
        where
                extraElements | length xs == length ys = []
                              | length xs > length ys = drop (length ys) xs
                              | length xs < length ys = drop (length xs) ys

-- contains
        -- @brief:
        -- @params: 
        -- @return:
contains :: Eq a => a -> [a] -> Bool
contains val [] = False
contains val (x:xs) | x == val  = True
                    | otherwise = contains val xs

-- stringEndsWith
        -- @brief:
        -- @params: 
        -- @return:
stringEndsWith :: String -> String -> Bool
stringEndsWith end string = stringStartsWith (reverse end) (reverse string)

-- stringStartsWith
        -- @brief:
        -- @params: 
        -- @return:
stringStartsWith :: String -> String -> Bool
stringStartsWith [] []         = True
stringStartsWith start []      = False
stringStartsWith [] string          = True
stringStartsWith (x:xs) (s:ss) | x == s    = stringStartsWith xs ss
                               | otherwise = False