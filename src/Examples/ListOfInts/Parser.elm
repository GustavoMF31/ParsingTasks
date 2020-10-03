module Examples.ListOfInts.Parser exposing (parseList)

import Parser exposing (..)


rawString =
    "[2, 4, 9, 1, 2, 100]"


parseList : Parser (List Int)
parseList =
    succeed (\firstInt rest -> firstInt :: rest)
        |. symbol "["
        |= int
        |= loop [] parseListIntHelp


parseListIntHelp ints =
    oneOf
        [ succeed (\nextInt -> Loop (ints ++ [ nextInt ]))
            |. symbol ","
            |. spaces
            |= int
        , succeed ()
            |. symbol "]"
            |. end
            |> Parser.map (\_ -> Done ints)
        ]
