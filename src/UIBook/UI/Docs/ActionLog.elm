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
                    { lastActionIndex = 0
                    , lastAction = ( "Context", "Action" )
                    , onClick = logAction "onClick"
                    }
              )
            , ( "List"
              , list
                    (List.range 1 10
                        |> List.map (\index -> ( "Context", "Action number " ++ String.fromInt index ))
                    )
              )
            ]
