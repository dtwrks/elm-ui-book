module UIBook.Widgets.Docs.Nav exposing (..)

import UIBook exposing (chapter, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.Widgets.Docs.Helpers exposing (mockTheme)
import UIBook.Widgets.Nav exposing (view)


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
        |> withSections
            [ ( "Default", view props )
            , ( "Selected", view activeProps )
            , ( "Selected + Pre-selected", view { activeProps | preSelected = Just "second-slug" } )
            ]
