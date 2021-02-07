module UIBook.ElmUI exposing (UIBook, UIChapter, book)

{-| When using [elm-ui](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/), use these as replacements for the same types and functions found on `UIBook`. Everything else should work just the same.

@docs UIBook, UIChapter, book

-}

import Element exposing (Element, layout)
import UIBook


type alias UIBookHtml state =
    Element (UIBook.UIBookMsg state)


{-| -}
type alias UIChapter state =
    UIBook.UIChapterCustom state (UIBookHtml state)


{-| -}
type alias UIBook state =
    UIBook.UIBookCustom state (UIBookHtml state)


{-| -}
book : String -> state -> UIBook.UIBookBuilder state (UIBookHtml state)
book title state =
    UIBook.customBook
        { title = title
        , state = state
        , toHtml = layout []
        }
