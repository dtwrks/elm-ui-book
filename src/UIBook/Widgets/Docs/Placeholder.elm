module UIBook.Widgets.Docs.Placeholder exposing (..)

import UIBook exposing (chapter, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.Widgets.Placeholder exposing (placeholder)


docs : UIChapter x
docs =
    chapter "Placeholders"
        |> withSections
            [ ( "Default", placeholder ) ]
