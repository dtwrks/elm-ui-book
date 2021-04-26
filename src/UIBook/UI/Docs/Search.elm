module UIBook.UI.Docs.Search exposing (..)

import UIBook exposing (chapter, logAction, logActionWithString, withBackgroundColor, withSection)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Docs.Helpers exposing (mockTheme)
import UIBook.UI.Search exposing (view)


docs : UIChapter x
docs =
    chapter "Search"
        |> withBackgroundColor mockTheme
        |> withSection
            (view
                { theme = mockTheme
                , value = ""
                , onInput = logActionWithString "onInput"
                , onFocus = logAction "onFocus"
                , onBlur = logAction "onBlur"
                }
            )
