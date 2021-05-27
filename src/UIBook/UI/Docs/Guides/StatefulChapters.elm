module UIBook.UI.Docs.Guides.StatefulChapters exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook exposing (chapter, withSection)
import UIBook.ElmCSS exposing (UIChapter)


docs : UIChapter x
docs =
    chapter "Stateful Chapters"
        |> withSection (text "Work in progress…")
