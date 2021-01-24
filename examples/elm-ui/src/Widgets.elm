module Widgets exposing (..)

import Element exposing (Element, alpha, text)
import Element.Input as Input
import UIBook exposing (UIBookMsg, UIChapter, chapter, logAction, logActionWithString, withSection, withSections)


buttonsChapter : UIChapter (Element UIBookMsg)
buttonsChapter =
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


inputChapter : UIChapter (Element UIBookMsg)
inputChapter =
    chapter "Input"
        |> withSection
            (Input.text []
                { onChange = logActionWithString "Input"
                , text = ""
                , placeholder = Nothing
                , label = Input.labelAbove [] <| text "Type something…"
                }
            )
