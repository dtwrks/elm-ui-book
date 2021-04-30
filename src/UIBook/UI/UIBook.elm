module UIBook.UI.UIBook exposing (..)

import UIBook exposing (withChapters, withColor, withSubtitle)
import UIBook.ElmCSS exposing (UIBook, book)
import UIBook.UI.Docs.ActionLog
import UIBook.UI.Docs.Footer
import UIBook.UI.Docs.Header
import UIBook.UI.Docs.Icons
import UIBook.UI.Docs.Markdown
import UIBook.UI.Docs.Nav
import UIBook.UI.Docs.Placeholder
import UIBook.UI.Docs.Search
import UIBook.UI.Docs.Wrapper


main : UIBook ()
main =
    book "UIBook's" ()
        |> withSubtitle "Widget Library"
        |> withColor "#37605f"
        |> withChapters
            [ UIBook.UI.Docs.Wrapper.docs
            , UIBook.UI.Docs.Footer.docs
            , UIBook.UI.Docs.Header.docs
            , UIBook.UI.Docs.Search.docs
            , UIBook.UI.Docs.Nav.docs
            , UIBook.UI.Docs.ActionLog.docs
            , UIBook.UI.Docs.Icons.docs
            , UIBook.UI.Docs.Markdown.docs
            , UIBook.UI.Docs.Placeholder.docs
            ]
