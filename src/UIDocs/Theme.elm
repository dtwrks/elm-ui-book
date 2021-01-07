module UIDocs.Theme exposing (Theme, defaultTheme)

import Html exposing (Html)


type alias Theme =
    { urlPreffix : String
    , title : String
    , subtitle : String
    , customHeader : Maybe (Html Never)
    , docsLabelBackground : String
    , docsLabelText : String
    , docsVariantBackground : String
    , docsVariantText : String
    , docsPadding : Float
    }


defaultTheme : String -> Theme
defaultTheme title =
    { urlPreffix = "ui-docs"
    , title = title
    , subtitle = "UI Docs"
    , customHeader = Nothing
    , docsLabelBackground = "#222"
    , docsLabelText = "#eaeaea"
    , docsVariantBackground = "#f5f5f5"
    , docsVariantText = "#999"
    , docsPadding = 12
    }
