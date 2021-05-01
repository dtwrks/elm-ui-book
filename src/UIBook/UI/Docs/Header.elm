module UIBook.UI.Docs.Header exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook exposing (chapter, logAction, withBackgroundColor, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Header exposing (view)
import UIBook.UI.Icons exposing (iconElm)
import UIBook.UI.Helpers exposing (themeBackground)


docs : UIChapter x
docs =
    let
        props =
            { href = "/x"
            , logo = Nothing
            , title = "Title"
            , subtitle = "Subtitle"
            , custom = Nothing
            , isMenuOpen = False
            , onClickMenuButton = logAction "onClickMenuButton"
            }

        customTitle =
            div
                [ css
                    [ fontSize (px 28)
                    , color (hex "#75c5f0")
                    ]
                ]
                [ text "Custom" ]
    in
    chapter "Header"
        |> withBackgroundColor themeBackground
        |> withSections
            [ ( "Default"
              , view props
              )
            , ( "Custom Logo"
              , view { props | logo = Just (iconElm { size = 28, color = "#75c5f0" }) }
              )
            , ( "Custom"
              , view { props | custom = Just customTitle }
              )
            ]
