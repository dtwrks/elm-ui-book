module UIBook.UI.Docs.Footer exposing (..)

import UIBook exposing (chapter, withBackgroundColor, withSection)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Docs.Helpers exposing (mockTheme)
import UIBook.UI.Footer exposing (view)


docs : UIChapter x
docs =
    chapter "Footer"
        |> withBackgroundColor mockTheme
        |> withSection view
