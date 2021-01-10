# UI Docs with Elm-CSS

Add elm-css's `Html.Styled.toUnstyled` to a custom `generateCustom.toHtml` and you should be good to go!

```elm
module Main exposing (main)

import Html.Styled exposing (toUnstyled)
import UIDocs exposing (UIDocs, generateCustom)

main : UIDocs
main =
    generateCustom
        { toHtml = toUnstyled
        , theme = defaultTheme "With Elm-CSS"
        , docs = ..
        }
```
