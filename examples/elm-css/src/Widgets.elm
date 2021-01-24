module Widgets exposing (..)

import Html.Styled exposing (Html, button, input, text)
import Html.Styled.Attributes exposing (disabled, placeholder)
import Html.Styled.Events exposing (onClick, onInput)
import UIBook exposing (UIBookMsg, UIChapter, chapter, logAction, logActionWithString, withSection, withSections)


buttonsChapter : UIChapter (Html UIBookMsg)
buttonsChapter =
    chapter "Button"
        |> withSections
            [ ( "Default", button [ onClick <| logAction "Button / onClick" ] [ text "Button" ] )
            , ( "Disabled", button [ disabled True ] [ text "Button" ] )
            ]


inputChapter : UIChapter (Html UIBookMsg)
inputChapter =
    chapter "Input"
        |> withSection
            (input
                [ placeholder "Type something"
                , onInput <| logActionWithString "Input"
                ]
                []
            )
