module UIDocs.Theme exposing (Theme, defaultTheme)


type alias Theme =
    { preffix : String
    , docsLabelBackground : String
    , docsLabelText : String
    , docsVariantBackground : String
    , docsVariantText : String
    , docsPadding : Float
    }


defaultTheme : Theme
defaultTheme =
    { preffix = "ui-docs"
    , docsLabelBackground = "#222"
    , docsLabelText = "#eaeaea"
    , docsVariantBackground = "#f5f5f5"
    , docsVariantText = "#999"
    , docsPadding = 12
    }
