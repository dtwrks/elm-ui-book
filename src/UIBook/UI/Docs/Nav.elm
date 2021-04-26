module UIBook.UI.Docs.Nav exposing (..)

import UIBook exposing (chapter, withBackgroundColor, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Docs.Helpers exposing (mockTheme)
import UIBook.UI.Nav exposing (view)


docs : UIChapter x
docs =
    let
        props =
            { theme = mockTheme
            , preffix = "x"
            , active = Nothing
            , preSelected = Nothing
            , items =
                [ ( "first-slug", "First" )
                , ( "second-slug", "Second" )
                ]
            }

        activeProps =
            { props | active = Just "first-slug" }
    in
    chapter "Nav"
        |> withBackgroundColor mockTheme
        |> withSections
            [ ( "Default", view props )
            , ( "Selected", view activeProps )
            , ( "Selected + Pre-selected", view { activeProps | preSelected = Just "second-slug" } )
            ]
