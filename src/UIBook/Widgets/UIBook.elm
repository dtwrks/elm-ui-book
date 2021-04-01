module UIBook.Widgets.UIBook exposing (..)

import UIBook exposing (withChapters, withSubtitle)
import UIBook.ElmCSS exposing (UIBook, book)
import UIBook.Widgets.Docs.ActionLog
import UIBook.Widgets.Docs.Footer
import UIBook.Widgets.Docs.Header
import UIBook.Widgets.Docs.Icons
import UIBook.Widgets.Docs.Nav
import UIBook.Widgets.Docs.Placeholder
import UIBook.Widgets.Docs.Search
import UIBook.Widgets.Docs.Wrapper


main : UIBook ()
main =
    book "UIBook's" ()
        |> withSubtitle "Widget Library"
        |> withChapters
            [ UIBook.Widgets.Docs.Wrapper.docs
            , UIBook.Widgets.Docs.Footer.docs
            , UIBook.Widgets.Docs.Header.docs
            , UIBook.Widgets.Docs.Search.docs
            , UIBook.Widgets.Docs.Nav.docs
            , UIBook.Widgets.Docs.ActionLog.docs
            , UIBook.Widgets.Docs.Icons.docs
            , UIBook.Widgets.Docs.Placeholder.docs
            ]
