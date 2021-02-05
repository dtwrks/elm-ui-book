module Main exposing (main)

import Html exposing (Html)
import UIBook exposing (UIBook, UIBookMsg, book, withChapters)
import Widgets exposing (buttonsChapter, inputChapter)


main : UIBook (Html UIBookMsg)
main =
    book "HTML"
        |> withChapters
            [ buttonsChapter
            , inputChapter
            ]
