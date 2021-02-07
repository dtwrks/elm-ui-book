module UIBook.Test exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import UIBook exposing (UIBook, UIChapter, book, chapter, updateState, updateState1, withChapters, withStatefulSection)


type alias MyState =
    { input : String, counter : Int }


initialState : MyState
initialState =
    { input = "", counter = 0 }


main : UIBook MyState
main =
    book "MyStatefulApp" initialState
        |> withChapters
            [ inputChapter
            , counterChapter
            ]


counterChapter : UIChapter { x | counter : Int }
counterChapter =
    let
        update state =
            { state | counter = state.counter + 1 }
    in
    chapter "Input"
        |> withStatefulSection
            (\state ->
                button
                    [ onClick (updateState update) ]
                    [ text <| String.fromInt state.counter ]
            )


inputChapter : UIChapter { x | input : String }
inputChapter =
    let
        updateInput value state =
            { state | input = value }
    in
    chapter "Input"
        |> withStatefulSection
            (\state ->
                input
                    [ value state.input
                    , onInput (updateState1 updateInput)
                    ]
                    []
            )
