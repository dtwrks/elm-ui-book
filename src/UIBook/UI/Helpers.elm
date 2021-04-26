module UIBook.UI.Helpers exposing (..)

import Css exposing (..)
import Css.Media exposing (only, screen, withMedia)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)



-- Theme Color


themeVar : String
themeVar =
    "--ui-book-theme"


setThemeColor : String -> Attribute msg
setThemeColor color =
    attribute "style" (themeVar ++ ":" ++ color ++ ";")


themeColor : String
themeColor =
    "var(" ++ themeVar ++ ")"



-- Media Queries


mobile : List Style -> Style
mobile =
    withMedia [ only screen [ Css.Media.maxWidth (px 768) ] ]



-- Typography


fontDefault : Style
fontDefault =
    fontFamily sansSerif


fontLabel : Style
fontLabel =
    Css.batch
        [ fontDefault
        , textTransform uppercase
        , letterSpacing (px 0.5)
        ]



-- Shadows


shadows : Style
shadows =
    boxShadow4 (px 0) (px 0) (px 20) (rgba 0 0 0 0.05)


shadowsDark : Style
shadowsDark =
    boxShadow4 (px 0) (px 0) (px 20) (rgba 0 0 0 0.1)


shadowsLight : Style
shadowsLight =
    boxShadow4 (px 0) (px 1) (px 4) (rgba 0 0 0 0.15)


shadowsInset : Style
shadowsInset =
    boxShadow5 inset (px 0) (px 0) (px 20) (rgba 0 0 0 0.05)



-- Layout


insetZero : Style
insetZero =
    Css.batch
        [ position absolute
        , top zero
        , left zero
        , right zero
        , bottom zero
        ]
