ghc --make -O2 Snip.lhs
./Snip Snip.lhs

"snip" extracts snippets (typically from an .lhs file) and "snap"
includes them (converting a .snap file to an .lhs file).

> module Main
> where
> import Data.Char
> import Data.List ( intercalate )
> import System.Environment
> import System.Exit

<<main>>

> main = do
>   me <- getProgName
>   if me == "snap" then
>     mainSnap
>   else
>     mainSnip

-------------------------------------------------------------------------------

> data Class
>   = Blank
>   | Code String
>   | Snip String
>   | Include Int String  -- identation
>   | Comment String
>   | Begin String
>   | End String
>   deriving (Show, Eq)

-------------------------------------------------------------------------------

Extract program snippets from source file.

> mainSnip = do
>   args <- getArgs
>   case args of
>     [inFile] -> do
>       processSnip inFile
>       exitSuccess
>     _        -> do
>       mapM_ print args
>       putStrLn "synopsis: snip <<infile>>"
>       exitFailure

> processSnip :: FilePath -> IO ()
> processSnip inFile = do
>   putStrLn ("snipping " ++ inFile ++ "...")
>   contents <- readFile inFile
>   sequence_ [ do
>     let outFile = basename inFile ++ "-" ++ s ++ ".snip"
>     putStrLn ("  writing " ++ outFile)
>     writeFile outFile (unlines' code)
>     | (s, code) <- snip contents ]

> basename = reverse . rm . reverse
>   where rm = tail . dropWhile (/='.')  -- we assume that the filename contains a dot
> --  where rm ('s' : 'h' : 'l' : '.' : x) = x
> --        rm ('s' : 'h' : '.' : x) = x

-------------------------------------------------------------------------------

Insert program snippets into target file.

> mainSnap = do
>   args <- getArgs
>   case args of
>     [inFile, outFile] -> do
>       processSnap inFile (Just outFile)
>       exitSuccess
>     [inFile] -> do
>       processSnap inFile Nothing
>       exitSuccess
>     _        -> do
>       mapM_ print args
>       putStrLn "synopsis: snap <<infile>> [<<outfile>>]"
>       exitFailure

> processSnap :: FilePath -> Maybe FilePath -> IO ()
> processSnap inFile outFile = do
>   putStrLn ("snapping " ++ inFile ++ "...")
>   s <- include 2 0 inFile
>   case outFile of
>     Nothing   ->  putStr s
>     Just out  ->  writeFile out s

> include n k inFile = do
>   contents <- readFile inFile
>   weave <- sequence [ out n k cmd | cmd <- snap contents ]
>   return (unlines' weave)

> classify str
>   | isCode str       =  Code str
>   | isSnip str       =  command (closing (drop 2 str))   -- stuff after ">>" is ignored
>   | isSpec str       =  Code str
>   | all isSpace str  =  Blank
>   | isBeginCode str  =  Begin str
>   | isEndCode str    =  End str
>   | otherwise        =  Comment str

> out _n k (Blank)      =  return ""
> out _n k (Code s)     =  return (shift k s)
> out _n k (Snip s)     =  return ("<<" ++ s ++ ">>")
> out n k1 (Include k2 s) =  do
>   putStrLn (replicate n ' ' ++ "including " ++ s ++ " (indented by " ++ show k2 ++ " spaces) ...")
>   include (n + 2) (k1 + k2) s
> out _n k (Comment s)  =  return (shift k s)
> out _n k (Begin s)    =  return s -- "\\begin{code}"
> out _n k (End s)      =  return s -- "\\end{code}"

> closing ('>' : '>' : _)  =  ""
> closing (c : s)          =  c : closing s
> closing []               =  ""

-------------------------------------------------------------------------------

Helper functions.

> unlines' :: [String] -> String   --- in contrast to unlines, no trailing "\n"
> unlines' = intercalate "\n" 

NB. |lines "a\nb" = lines "a\nb\n"|.

> snip = conflate . fmap classify . lines

> snap = fmap classify . lines

> isCode ('>' : _) = True
> isCode _ = False

> isSnip ('<' : '<' : _) = True
> isSnip _               = False

> isSpec ('<' : _) = True
> isSpec _ = False

> isBeginCode ('\\' : 'b' : 'e' : 'g' : 'i' : 'n' : '{' : 'c' : 'o' : 'd' : 'e' :  '}' :  _) = True
> isBeginCode ('\\' : 'b' : 'e' : 'g' : 'i' : 'n' : '{' : 's' : 'p' : 'e' : 'c' :  '}' :  _) = True
> isBeginCode _ = False

> isEndCode ('\\' : 'e' : 'n' : 'd' : '{' : 'c' : 'o' : 'd' : 'e' :  '}' :  _) = True
> isEndCode ('\\' : 'e' : 'n' : 'd' : '{' : 's' : 'p' : 'e' : 'c' :  '}' :  _) = True
> isEndCode _ = False

> command ('i':'n':'c':'l':'u':'d':'e': c : s)
>   |  isSpace c
>   =  Include 0 (dropWhile isSpace s)
>   |  c == '+'
>   =  Include (read s1) (dropWhile isSpace s2)
>   |  c == '-'
>   =  Include (- read s1) (dropWhile isSpace s2)
>   where (s1, s2) = span isDigit s
> command ('s':'n':'i':'p': c : s)
>   |  isSpace c
>   =  Snip s
> command s  -- <<string>> is the same as <<snip string>>
>   =  Snip s

<<conflate-1>>

> conflate [] = []
> --conflate (Snip s : Begin : x) = (s, code) : conflate y
> --  where (code, y) = eat2 x
> conflate (Snip s : Begin s2 : x) = (s, s2 : code) : conflate y
>   where (code, y) = eat3 x
> conflate (Snip s : w) = (s, code) : conflate z
>   where x = dropWhile (== Blank) w
>         (code, y) = eat x
>         z = dropWhile (== Blank) y
> conflate (_ : w) = conflate w

<<snip conflate-2>>

> eat (Code s : x) = tack s (eat x)
> eat x            = ([], x)

Old eater: converts \begin{code}...\end{code} blocks into Bird tracks.

> eat2 (Blank : x)     = tack "> " (eat2 x)
> eat2 (Comment s : x) = tack ("> " ++ s) (eat2 x)
> eat2 (End s : x)     = ([s], x)
> eat2 x               = ([], x) -- eg begin within begin; what to do?
> -- eat2 (Code s : x)    = tack s (eat2 x)
> -- eat2 (Snip s : x)    = tack s (eat2 x)
> -- eat2 (Include s : x) = tack s (eat2 x)

New eater: preserves \begin{code}...\end{code} blocks.

> eat3 (Blank : x)     = tack "" (eat3 x)
> eat3 (Comment s : x) = tack s (eat3 x)
> eat3 (End s : x)     = ([s], x)
> eat3 x               = ([], x) -- eg begin within begin; what to do?

> tack :: a -> ([a], b) -> ([a], b)
> tack x (xs, y) = (x : xs, y)

> shift k s
>   | k == 0 = s
>   | k <  0 = dropSpace k s
>   | k >  0 = replicate k ' ' ++ s

> dropSpace :: Int -> String -> String  -- indentation, first argument, should be negative
> dropSpace 0 s = s
> dropSpace k (c : s)
>   | isSpace c = dropSpace (k + 1) s
> dropSpace k s = s
