module UIBook.UI.Docs.Footer exposing (..)

import UIBook exposing (chapter, withSection)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Footer exposing (view)


docs : UIChapter x
docs =
    chapter "Footer"
        |> withSection view
