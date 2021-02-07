module UIBook.Widgets.Docs.Header exposing (..)

import UIBook exposing (chapter, logAction, withSection)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.Widgets.Docs.Helpers exposing (mockTheme)
import UIBook.Widgets.Header exposing (view)


docs : UIChapter x
docs =
    chapter "Header"
        |> withSection
            (view
                { color = mockTheme
                , title = "Title"
                , subtitle = "Subtitle"
                , custom = Nothing
                , isMenuOpen = False
                , onClickMenuButton = logAction "onClickMenuButton"
                }
            )
