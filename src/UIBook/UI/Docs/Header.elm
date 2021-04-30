module UIBook.UI.Docs.Header exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import UIBook exposing (chapter, logAction, withDescription, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Docs.Helpers exposing (mockTheme)
import UIBook.UI.Header exposing (view)


docsDescription : String
docsDescription =
    """
You can create a custom header.    
"""


docs : UIChapter x
docs =
    let
        props =
            { href = "/x"
            , color = mockTheme
            , title = "Title"
            , subtitle = "Subtitle"
            , custom = Nothing
            , isMenuOpen = False
            , onClickMenuButton = logAction "onClickMenuButton"
            }

        customTitle =
            div
                [ css
                    [ fontSize (px 36)
                    , color (hex "#69a")
                    ]
                ]
                [ text "Custom" ]
    in
    chapter "Header"
        |> withDescription docsDescription
        |> withSections
            [ ( "Default"
              , view props
              )
            , ( "Custom"
              , view { props | custom = Just customTitle }
              )
            ]
