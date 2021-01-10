module Widgets exposing (..)

import Html.Styled exposing (Html, button, input, text)
import Html.Styled.Attributes exposing (disabled, placeholder)
import Html.Styled.Events exposing (onClick, onInput)
import UIDocs exposing (Docs(..), Msg(..))


buttonDocs : Docs (Html Msg)
buttonDocs =
    DocsWithVariants "Button"
        [ ( "Default", button [ onClick <| Action "Button / onClick" ] [ text "Button" ] )
        , ( "Disabled", button [ disabled True ] [ text "Button" ] )
        ]


inputDocs : Docs (Html Msg)
inputDocs =
    Docs "Input" <|
        input [ placeholder "Type something", onInput <| ActionWithString "Input" ] []
