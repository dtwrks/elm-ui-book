module Widgets exposing (..)

import Element exposing (Element, alpha, text)
import Element.Input as Input
import UIDocs exposing (UIDocsChapter, UIDocsMsg, logAction, logActionWithString, uiDocsChapter, withSection, withSectionList)


buttonDocs : UIDocsChapter (Element UIDocsMsg)
buttonDocs =
    uiDocsChapter "Button"
        |> withSectionList
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


inputDocs : UIDocsChapter (Element UIDocsMsg)
inputDocs =
    uiDocsChapter "Input"
        |> withSection
            (Input.text []
                { onChange = logActionWithString "Input"
                , text = ""
                , placeholder = Nothing
                , label = Input.labelAbove [] <| text "Type something…"
                }
            )
