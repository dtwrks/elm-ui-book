module UIBook.UI.Docs.Search exposing (..)

import UIBook exposing (chapter, logAction, logActionWithString, withSection)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Docs.Helpers exposing (mockTheme)
import UIBook.UI.Search exposing (view)


docs : UIChapter x
docs =
    chapter "Search"
        |> withSection
            (view
                { theme = mockTheme
                , value = ""
                , onInput = logActionWithString "onInput"
                , onFocus = logAction "onFocus"
                , onBlur = logAction "onBlur"
                }
            )
