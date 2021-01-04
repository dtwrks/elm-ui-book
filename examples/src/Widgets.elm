module Widgets exposing (..)

import Html.Styled exposing (Html)
import UIDocs exposing (Docs(..), Msg(..))
import UIDocs.Widgets exposing (buttonLink, button_)


buttonDocs : Docs (Html Msg)
buttonDocs =
    DocsWithVariants "Button"
        [ ( "Default"
          , button_
                { label = "Click me"
                , disabled = False
                , onClick = Action "onClick"
                }
          )
        , ( "Disabled"
          , button_
                { label = "Click me"
                , disabled = True
                , onClick = Action "onClick"
                }
          )
        , ( "As Link"
          , buttonLink
                { label = "Click me"
                , disabled = False
                , href = "#"
                }
          )
        ]
