module Helpers exposing (UIBookCustom, UIChapterCustom)

import Html exposing (Html)
import UIBook exposing (UIBook, UIBookMsg, UIChapter)


type alias UIBookHtml state =
    Html (UIBookMsg state)


type alias UIChapterCustom state =
    UIChapter state (UIBookHtml state)


type alias UIBookCustom state =
    UIBook state (UIBookHtml state)
