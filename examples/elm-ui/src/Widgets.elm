module Widgets exposing (..)

import Element exposing (Element, alpha, text)
import Element.Input as Input
import UIBook exposing (UIBookMsg, UIChapter, chapter, logAction, logActionWithString, withSection, withSections)


buttonDocs : UIChapter (Element UIBookMsg)
buttonDocs =
    chapter "Button"
        |> withSections
            [ ( "Default"
              , Input.button []
                    { label = text "Button"
                    , onPress = Just <| logAction "Button / onClick"
                    }
              )
            , ( "Disabled"
              , Input.button [ alpha 0.5 ]
                    { label = text "Button"
                    , onPress = Just <| logAction "Button / disabledClick"
                    }
              )
            ]


inputDocs : UIChapter (Element UIBookMsg)
inputDocs =
    chapter "Input"
        |> withSection
            (Input.text []
                { onChange = logActionWithString "Input"
                , text = ""
                , placeholder = Nothing
                , label = Input.labelAbove [] <| text "Type something…"
                }
            )
