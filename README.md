# UI Docs

Visualize and interact with all your UI components in a beautiful environment.

**Features**

- Plain Elm (no custom setup)
- Custom branding
- Single and multi-variant components
- Action logging
- Comes with custom dev server (not required)

**Guide**

- [Quickstart](#getting-started)
- [Logging actions](#logging-actions)
- [Using it with elm-css, elm-ui and others](#using-it-with-elm-css-elm-ui-and-others)

### Getting started

Create docs for your UI components like this

```elm
module Button exposing (buttonDocs)

import Html exposing (Html, button)
import Html.Attributes exposing (disabled)
import UIDocs exposing (Docs(..), Msg)

buttonDocs : Docs (Html Msg)
buttonDocs =
  Docs "Button" [
    ( "Default", button [] [] )
  , ( "Disabled", button [ disabled True ] [] )
  ]
```

Then in your main file

```elm
module Docs exposing (main)

import Button exposing (buttonDocs)
import Menu exposing (menuDocs)
import Sidebar exposing (sidebarDocs)
import UIDocs exposing (UIDocs, generate)

main : UIDocs
main =
  generate "My App Name"
    [ buttonDocs
    , sidebarDocs
    , menuDocs
    ]
```
