module UIBook.UI.Docs.ActionLog exposing (..)

import UIBook exposing (chapter, logAction, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.ActionLog exposing (list, preview)
import UIBook.UI.Docs.Helpers exposing (mockTheme)


docs : UIChapter x
docs =
    chapter "ActionLog"
        |> withSections
            [ ( "Preview"
              , preview
                    { theme = mockTheme
                    , lastActionIndex = 0
                    , lastActionLabel = "Action"
                    , onClick = logAction "onClick"
                    }
              )
            , ( "List"
              , list
                    { theme = mockTheme
                    , actions =
                        List.range 1 10
                            |> List.map (\index -> "Action number " ++ String.fromInt index)
                    }
              )
            ]
