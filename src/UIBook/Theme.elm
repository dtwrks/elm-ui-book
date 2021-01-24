module UIBook.Theme exposing (Theme, defaultTheme)

import Html exposing (Html)


type alias Theme msg =
    { urlPreffix : String
    , title : String
    , subtitle : String
    , customHeader : Maybe (Html msg)
    , color : String
    }


defaultTheme : String -> Theme msg
defaultTheme title =
    { urlPreffix = "ui-docs"
    , title = title
    , subtitle = "UI Docs"
    , customHeader = Nothing
    , color = "#1293D8"
    }
