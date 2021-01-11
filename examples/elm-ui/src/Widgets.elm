module Widgets exposing (..)

import Element exposing (Element, alpha, text)
import Element.Input as Input
import UIDocs exposing (Docs(..), Msg, logAction, logActionWithString)


buttonDocs : Docs (Element Msg)
buttonDocs =
    DocsWithVariants "Button"
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


inputDocs : Docs (Element Msg)
inputDocs =
    Docs "Input" <|
        Input.text []
            { onChange = logActionWithString "Input"
            , text = ""
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Type something…"
            }
