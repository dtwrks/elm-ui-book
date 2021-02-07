module UIBook.Widgets.Docs.Footer exposing (..)

import UIBook exposing (chapter, withSection)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.Widgets.Footer exposing (view)


docs : UIChapter x
docs =
    chapter "Footer"
        |> withSection view
