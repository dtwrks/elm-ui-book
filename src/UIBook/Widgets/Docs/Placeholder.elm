module UIBook.Widgets.Docs.Placeholder exposing (..)

import UIBook exposing (chapter, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.Widgets.Placeholder as Placeholder exposing (placeholder)


docs : UIChapter x
docs =
    chapter "Placeholder"
        |> withSections
            [ ( "Default", placeholder )
            , ( "With custom width"
              , Placeholder.custom
                    |> Placeholder.withWidth 500
                    |> Placeholder.view
              )
            , ( "With Custom Foreground Color"
              , Placeholder.custom
                    |> Placeholder.withForegroundColor "#FF0000"
                    |> Placeholder.view
              )
            , ( "With Custom Background and Foreground Colors"
              , Placeholder.custom
                    |> Placeholder.withForegroundColor "#FFF"
                    |> Placeholder.withBackgroundColor "#FF0000"
                    |> Placeholder.view
              )
            ]
