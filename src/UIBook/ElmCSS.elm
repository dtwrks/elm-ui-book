module UIBook.ElmCSS exposing (UIBook, UIChapter, book)

import Html.Styled exposing (Html, toUnstyled)
import UIBook


type alias UIBookHtml state =
    Html (UIBook.UIBookMsg state)


type alias UIChapter state =
    UIBook.UIChapterCustom state (UIBookHtml state)


type alias UIBook state =
    UIBook.UIBookCustom state (UIBookHtml state)


book : String -> model -> UIBook.UIBookBuilder model (UIBookHtml model)
book title model =
    UIBook.customBook
        { title = title
        , model = model
        , toHtml = toUnstyled
        }
