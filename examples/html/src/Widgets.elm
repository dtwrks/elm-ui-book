module Widgets exposing (..)

import Html exposing (Html, button, input, text)
import Html.Attributes exposing (disabled, placeholder)
import Html.Events exposing (onClick, onInput)
import UIBook exposing (UIBookMsg, UIChapter, chapter, logAction, logActionWithString, withSection, withSections)


buttonDocs : UIChapter (Html UIBookMsg)
buttonDocs =
    chapter "Button"
        |> withSections
            [ ( "Default", button [ onClick <| logAction "Button / onClick" ] [ text "Button" ] )
            , ( "Disabled", button [ disabled True ] [ text "Button" ] )
            ]


inputDocs : UIChapter (Html UIBookMsg)
inputDocs =
    chapter "Input"
        |> withSection
            (input
                [ placeholder "Type something"
                , onInput <| logActionWithString "Input"
                ]
                []
            )
