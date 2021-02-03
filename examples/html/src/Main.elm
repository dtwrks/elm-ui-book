module Main exposing (main)

import Html exposing (Html, text)
import UIBook exposing (UIBook, UIBookMsg, UIChapter, book, chapter, withChapters, withSections)


chapterWithIndex : Int -> UIChapter (Html UIBookMsg)
chapterWithIndex index =
    let
        indexString =
            String.fromInt (index + 1)
    in
    chapter indexString
        |> withSections (List.repeat (index + 1) ( indexString, text ("Hello " ++ indexString) ))


main : UIBook
main =
    book "HTML"
        |> withChapters
            (List.map chapterWithIndex (List.range 0 19))
