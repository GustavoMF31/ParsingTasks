module Example exposing (expandingTests, parsingTests)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (Task(..))
import Parser
import Test exposing (..)


taskBlock =
    """{
    . Test
    - Call
    . Test Again
}
"""


taskDeclaration =
    """Important thing to do {
    - Super
    . Important thing
}
"""


ast =
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


parsingTests : Test
parsingTests =
    describe "Parses"
        [ describe "a task"
            [ test "that is simple" <|
                \_ ->
                    Parser.run Main.parseTask ". Dance Class"
                        |> Expect.equal (Ok (SimpleTask "Dance Class"))
            , test "that is a task call" <|
                \_ ->
                    Parser.run Main.parseTask "- Awesome stuff"
                        |> Expect.equal (Ok (TaskCall "Awesome stuff"))
            ]
        , describe "a task block"
            [ test "made of simple tasks and task calls" <|
                \_ ->
                    Parser.run Main.parseTaskBlock taskBlock
                        |> Expect.equal
                            (Ok
                                [ SimpleTask "Test"
                                , TaskCall "Call"
                                , SimpleTask "Test Again"
                                ]
                            )
            ]
        , describe "a task declaration"
            [ test "made of simple tasks and task calls" <|
                \_ ->
                    Parser.run Main.parseTaskDeclaration taskDeclaration
                        |> Expect.equal
                            (Ok
                                { name = "Important thing to do"
                                , tasks = [ TaskCall "Super", SimpleTask "Important thing" ]
                                }
                            )
            ]
        , describe "a full AST"
            [ test "made of simple tasks and task calls" <|
                \_ ->
                    Parser.run Main.parseAst ast
                        |> Expect.equal
                            (Ok
                                [ { name = "Arrumar a mochila", tasks = [ SimpleTask "Caderno de Matemática", SimpleTask "Caderno de Ciências", SimpleTask "Caderno de Biologia" ] }
                                , { name = "Tomar café", tasks = [ SimpleTask "Colocar a mesa", SimpleTask "Escovar os dentes", SimpleTask "Escovar o aparelho" ] }
                                , { name = "Rotina matinal", tasks = [ TaskCall "Arrumar a mochila", TaskCall "Tomar café" ] }
                                ]
                            )
            ]
        ]


expandingTests : Test
expandingTests =
    describe "Expansions"
        [ describe "Getting a task"
            [ test "that's simple" <|
                \_ ->
                    Main.getTaskWithName "Do the dishes" [ { name = "Do the dishes", tasks = [] } ]
                        |> Expect.equal (Just { name = "Do the dishes", tasks = [] })

            -- , test "returns Nothing when names clash": Implement this behavior
            ]
        , describe "Expanding a task"
            [ test "that's simple" <|
                \_ ->
                    Main.expandTask [] (SimpleTask "George")
                        |> Expect.equal (Just [ "George" ])
            , test "that's a call" <|
                \_ ->
                    Main.expandTask [ { name = "Andrew", tasks = [ SimpleTask "A", SimpleTask "B" ] } ] (TaskCall "Andrew")
                        |> Expect.equal (Just [ "A", "B" ])
            ]
        ]
