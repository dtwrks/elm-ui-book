module Widgets exposing (..)

import Html.Styled exposing (Html, button, input, text)
import Html.Styled.Attributes exposing (disabled, placeholder)
import Html.Styled.Events exposing (onClick, onInput)
import UIDocs exposing (UIDocsChapter, UIDocsMsg, logAction, logActionWithString, uiDocsChapter, withSection, withSectionList)


buttonDocs : UIDocsChapter (Html UIDocsMsg)
buttonDocs =
    uiDocsChapter "Button"
        |> withSectionList
            [ ( "Default", button [ onClick <| logAction "Button / onClick" ] [ text "Button" ] )
            , ( "Disabled", button [ disabled True ] [ text "Button" ] )
            ]


inputDocs : UIDocsChapter (Html UIDocsMsg)
inputDocs =
    uiDocsChapter "Input"
        |> withSection
            (input
                [ placeholder "Type something"
                , onInput <| logActionWithString "Input"
                ]
                []
            )
