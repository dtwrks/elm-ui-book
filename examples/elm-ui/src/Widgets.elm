module Widgets exposing (..)

import Element exposing (Element, alpha, text)
import Element.Input as Input
import UIDocs exposing (Docs(..), Msg(..))


buttonDocs : Docs (Element Msg)
buttonDocs =
    DocsWithVariants "Button"
        [ ( "Default"
          , Input.button []
                { label = text "Button"
                , onPress = Just <| Action "Button / onClick"
                }
          )
        , ( "Disabled"
          , Input.button [ alpha 0.5 ]
                { label = text "Button"
                , onPress = Just <| Action "Button / disabledClick"
                }
          )
        ]


inputDocs : Docs (Element Msg)
inputDocs =
    Docs "Input" <|
        Input.text []
            { onChange = ActionWithString "Input"
            , text = ""
            , placeholder = Nothing
            , label = Input.labelAbove [] <| text "Type something…"
            }
