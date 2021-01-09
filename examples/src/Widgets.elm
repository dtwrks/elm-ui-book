module Widgets exposing (..)

import Html.Styled exposing (Html)
import UIDocs exposing (Docs(..), Msg(..))
import UIDocs.Theme exposing (defaultTheme)
import UIDocs.Widgets exposing (actionLog, buttonLink, button_)


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
                , href = "/some-url"
                }
          )
        ]


actionLogDocs : Docs (Html Msg)
actionLogDocs =
    Docs "Action Log" <|
        actionLog {
        theme = defaultTheme "Example"
        , numberOfActions = 5
        , lastAction = "Previous action"
        , onClick = Action "actionLog - onClick"
        }
