module UIBook.UI.Docs.Intro.Overview exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook exposing (chapter, withSection)
import UIBook.ElmCSS exposing (UIChapter)


docs : UIChapter x
docs =
    chapter "Overview"
        |> withSection (text "Work in progress…")
