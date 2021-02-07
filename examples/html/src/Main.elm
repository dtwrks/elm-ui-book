module Main exposing (main)

import Helpers exposing (UIBookCustom)
import UIBook exposing (statefulBook, withChapters)
import Widgets exposing (inputChapter)


type alias UIBookState =
    { input : Widgets.Model
    , other : ()
    }


initialState : UIBookState
initialState =
    { input = Widgets.init
    , other = ()
    }


main : UIBookCustom UIBookState
main =
    statefulBook "HTML" initialState
        |> withChapters
            [ inputChapter
            ]
