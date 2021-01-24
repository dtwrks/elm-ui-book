module Main exposing (main)

import UIBook exposing (UIBook, book, withChapters)
import Widgets exposing (buttonDocs, inputDocs)


main : UIBook
main =
    book "HTML"
        |> withChapters
            [ buttonDocs
            , inputDocs
            ]
