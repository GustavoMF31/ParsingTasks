module Main exposing (Task(..), expandTask, getTaskWithName, main, parseAst, parseTask, parseTaskBlock, parseTaskDeclaration)

import Browser exposing (..)
import Html
import Maybe.Extra
import Parser exposing ((|.), (|=), Parser, Step(..), chompIf, chompWhile, end, getChompedString, loop, oneOf, run, succeed, symbol)


type alias Ast =
    List TaskDeclaration


type alias TaskDeclaration =
    { name : String
    , tasks : List Task
    }


type Task
    = SimpleTask String
    | TaskCall String


parseTask : Parser Task
parseTask =
    oneOf
        [ succeed TaskCall
            |. symbol "-"
            |. symbol " "
            |= oneOrMore (\c -> c /= '\n')
        , succeed SimpleTask
            |. symbol "."
            |. symbol " "
            |= oneOrMore (\c -> c /= '\n')
        ]


parseTaskBlock : Parser (List Task)
parseTaskBlock =
    succeed identity
        |. symbol "{"
        |. symbol "\n"
        |= loop [] parseTaskBlockHelper



{- In this case the accumulator is the same as the final value
   Inital val-> Parser (Loop with a List Task, or End with a List Task)
-}


parseTaskBlockHelper : List Task -> Parser (Step (List Task) (List Task))
parseTaskBlockHelper accumulator =
    oneOf
        [ succeed (\task -> Loop (task :: accumulator))
            |. symbol "    "
            |= parseTask
            |. symbol "\n"
        , succeed ()
            |. symbol "}"
            |. symbol "\n"
            -- TODO: Make trailing new line optional
            |> Parser.map (\_ -> Done (List.reverse accumulator))
        ]


parseTaskDeclaration : Parser TaskDeclaration
parseTaskDeclaration =
    succeed (\name content -> TaskDeclaration (String.slice 0 -1 name) content)
        |= oneOrMore (\c -> c /= '{')
        |= parseTaskBlock


parseAst : Parser Ast
parseAst =
    loop [] parseAstHelper


parseAstHelper : Ast -> Parser (Step Ast Ast)
parseAstHelper accumulator =
    oneOf
        [ succeed (\declaration -> Loop <| declaration :: accumulator)
            |. zeroOrMore (\c -> c == '\n')
            |= parseTaskDeclaration
        , end
            |> Parser.map (always <| Done <| List.reverse accumulator)
        ]


zeroOrMore : (Char -> Bool) -> Parser String
zeroOrMore f =
    succeed ()
        |. chompWhile f
        |> getChompedString


oneOrMore : (Char -> Bool) -> Parser String
oneOrMore f =
    succeed ()
        |. chompIf f
        |. chompWhile f
        |> getChompedString



-- TODO: Break on name collisions
-- TODO: Test the individual expanding functions


getTaskWithName : String -> Ast -> Maybe TaskDeclaration
getTaskWithName taskName ast =
    let
        filtered =
            List.filter (\task -> task.name == taskName) ast
    in
    List.head filtered



-- Maybe there should be a validation step for the Ast
-- Possible failures: Recursive definition, two tasks with the same name


expandTaskDeclaration : Ast -> TaskDeclaration -> Maybe (List String)
expandTaskDeclaration ast taskDeclaration =
    taskDeclaration.tasks
        |> List.map (expandTask ast)
        |> Maybe.Extra.combine
        |> Maybe.andThen (\list -> Just (List.foldr (++) [] list))


expandTask : Ast -> Task -> Maybe (List String)
expandTask ast task =
    case task of
        SimpleTask name ->
            Just [ name ]

        TaskCall name ->
            getTaskWithName name ast
                |> Maybe.andThen (expandTaskDeclaration ast)


main =
    Browser.sandbox { init = init, view = view, update = update }


init =
    ()


update _ _ =
    ()


rawAst =
    """Arrumar a mochila {
    . Caderno de Matemática
    . Caderno de Ciências
    . Caderno de Biologia
}

Tomar café {
    . Colocar a mesa
    . Escovar os dentes
    . Escovar o aparelho
}

Rotina matinal {
    - Arrumar a mochila
    - Tomar café
}
"""


view _ =
    Html.div []
        [ Html.div []
            [ let
                parsed =
                    Parser.run parseAst rawAst
              in
              case parsed of
                Ok ast ->
                    expandTask ast (TaskCall "Rotina matinal")
                        |> Debug.toString
                        |> Html.text

                Err errorMessage ->
                    errorMessage
                        |> Debug.toString
                        |> Html.text
            ]
        ]
