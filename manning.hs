-- manning.hs
import Data.List (isSuffixOf)
import Text.Pandoc
import Text.PrettyPrint.HughesPJ hiding ( Str )

--
-- Start: Text.Pandoc.UTF8
-- Copyright John Mac Farlane
--

import qualified Data.ByteString as B
import Codec.Binary.UTF8.String (encodeString)
import Data.ByteString.UTF8 (toString, fromString)
import Prelude hiding (readFile, writeFile, getContents, putStr, putStrLn)
import System.IO (Handle)
import Control.Monad (liftM)

bom :: B.ByteString
bom = B.pack [0xEF, 0xBB, 0xBF]

stripBOM :: B.ByteString -> B.ByteString
stripBOM s | bom `B.isPrefixOf` s = B.drop 3 s
stripBOM s = s

readFile :: FilePath -> IO String
readFile = liftM (toString . stripBOM) . B.readFile . encodeString

writeFile :: FilePath -> String -> IO ()
writeFile f = B.writeFile (encodeString f) . fromString

getContents :: IO String
getContents = liftM (toString . stripBOM) B.getContents

putStr :: String -> IO ()
putStr = B.putStr . fromString

putStrLn :: String -> IO ()
putStrLn = B.putStrLn . fromString

hPutStr :: Handle -> String -> IO ()
hPutStr h = B.hPutStr h . fromString

hPutStrLn :: Handle -> String -> IO ()
hPutStrLn h s = hPutStr h (s ++ "\n")

--
-- End: Text.Pandoc.UTF8
--

--
-- Start: Text.Pandoc.XML
-- Copyright John Mac Farlane
--

stripTags :: String -> String
stripTags ('<':xs) =
  let (_,rest) = break (=='>') xs
  in  if null rest
         then ""
         else stripTags (tail rest) -- leave off >
stripTags (x:xs) = x : stripTags xs
stripTags [] = []

-- | Escape one character as needed for XML.
escapeCharForXML :: Char -> String
escapeCharForXML x = case x of
                       '&'    -> "&amp;"
                       '<'    -> "&lt;"
                       '>'    -> "&gt;"
                       '"'    -> "&quot;"
                       c      -> [c]

-- | True if the character needs to be escaped.
needsEscaping :: Char -> Bool
needsEscaping c = c `elem` "&<>\""

-- | Escape string as needed for XML.  Entity references are not preserved.
escapeStringForXML :: String -> String
escapeStringForXML ""  = ""
escapeStringForXML str =
  case break needsEscaping str of
    (okay, "")     -> okay
    (okay, (c:cs)) -> okay ++ escapeCharForXML c ++ escapeStringForXML cs

-- | Return a text object with a string of formatted XML attributes.
attributeList :: [(String, String)] -> Doc
attributeList = text .  concatMap
  (\(a, b) -> " " ++ escapeStringForXML a ++ "=\"" ++
  escapeStringForXML b ++ "\"")

-- | Put the supplied contents between start and end tags of tagType,
--   with specified attributes and (if specified) indentation.
inTags:: Bool -> String -> [(String, String)] -> Doc -> Doc
inTags isIndented tagType attribs contents =
  let openTag = char '<' <> text tagType <> attributeList attribs <>
                char '>'
      closeTag  = text "</" <> text tagType <> char '>'
  in  if isIndented
         then openTag $$ nest 0 contents $$ closeTag
         else openTag <> contents <> closeTag

-- | Return a self-closing tag of tagType with specified attributes
selfClosingTag :: String -> [(String, String)] -> Doc
selfClosingTag tagType attribs =
  char '<' <> text tagType <> attributeList attribs <> text " />"

-- | Put the supplied contents between start and end tags of tagType.
inTagsSimple :: String -> Doc -> Doc
inTagsSimple tagType = inTags False tagType []

-- | Put the supplied contents in indented block btw start and end tags.
inTagsIndented :: String -> Doc -> Doc
inTagsIndented tagType = inTags True tagType []
--

--
-- End: Text.Pandoc.XML
--

--
-- Manning Callout converter
-- Copyright Alvaro Videla & Jason J. W. Williams
--
-- (Code, Callout, Id)
getCalloutId :: String -> (String, String)
getCalloutId co =
    helper co []
  where
    helper :: String -> String -> (String, String)
    helper ('(':rest) acc = helper rest acc
    helper (x:rest) acc =
        if(x /= ')')
          then
            helper rest (acc ++ [x])
          else
            (rest, acc)

-- Handles Erlang, Java and C# comments characters
removeCommentsMarks :: String -> String
removeCommentsMarks codeLine
  | isSuffixOf "%%" codeLine = dropSuffix codeLine
  | isSuffixOf "//" codeLine = dropSuffix codeLine
  | otherwise                = codeLine
  where
    dropSuffix xs = take ((length xs) -2) xs

-- (Code, Callout, CalloutId)
splitAtCallout :: String -> (String, (String, String))
splitAtCallout codeLine =
  helper codeLine []
  where
    helper :: String -> String -> (String, (String, String))
    helper []         codeStrAcc = (codeStrAcc, ([], []))
    helper [x]        codeStrAcc = (codeStrAcc ++ [x], ([], []))
    helper (x:y:rest) codeStrAcc =
        if (x == '#') && (y == '/')
          then
            ((removeCommentsMarks codeStrAcc), (getCalloutId rest))
          else
            helper (y:rest) (codeStrAcc ++ [x])

convertCodeLine :: (String, (String, String)) -> String
convertCodeLine (code, ([], _))      =
  (escapeStringForXML code)
convertCodeLine (code, (_callout, calloutId)) =
  (escapeStringForXML code) ++ "<co id='" ++ calloutId ++ "'/>"

addCoToLines :: [String] -> [String]
addCoToLines codeLines =
  map convertCodeLine (map splitAtCallout codeLines)

programListing :: String -> Doc
programListing str =
    inTags True "programlisting" [("xml:space", "preserve")] (text str')
  where
    str' = unlines $ addCoToLines $ lines str

generateCallouts :: [String] -> [Doc]
generateCallouts codeLines =
    helper (map splitAtCallout codeLines) []
  where
    helper [] result = result
    helper ((_, ([], _)):rest) result =
        helper rest result
    helper ((_, (callout, calloutId)):rest) result =
        helper rest (result ++ [inTags True "callout" [("arearefs", calloutId)] $
                                  inTagsSimple "para" (text (escapeStringForXML callout))])

callouts :: String -> Doc
callouts str =
    case generateCallouts (lines str) of
        [] ->
          text ""
        co ->
          inTags True "calloutlist" [] (vcat co)

blockToManning :: Block -> IO Block
blockToManning (CodeBlock (_,_,namevals) str) =
      case lookup "title" namevals of
          Just title ->
            return (RawBlock "html" (render (inTags True "example" [] $
              inTagsSimple "title" (text (escapeStringForXML title)) $$
              programListing str $$
              callouts str)))
          Nothing ->
            return (RawBlock "html" (render (inTags True "informalexample" [] $
              programListing str $$
              callouts str)))
blockToManning x =  return x

readDoc :: String -> Pandoc
readDoc = readMarkdown defaultParserState

writeDoc :: String -> Pandoc -> String
writeDoc template pandocText = writeDocbook defaultWriterOptions {writerStandalone = True, writerTemplate = template} pandocText

main :: IO ()
main = do
  origText <- getContents
  docbookText <- bottomUpM blockToManning $ readDoc origText
  template <- readFile "../manning.template"
  putStrLn $ writeDoc template docbookText