# UI Docs

UI documentation tool for Elm applications.

**Features**

- Plain Elm (no custom setup)
- Customizable theme colors and header
- Organize your components into chapters and sections
- Log your actions
- Optional built-in development server

**Guide**

- [Getting Started](#getting-started)
- [Theme Customization](#customizing-the-theme)
- [Logging actions](#logging-actions)
- [Using it with elm-css, elm-ui and others](#using-it-with-elm-css-elm-ui-and-others)

## Getting Started

This is a fully functional UIDocs application:

```elm
module Docs exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import UIDocs exposing (..)

main : UIDocs
main =
    uiDocs "My App"
        |> withChapters
            [ buttonDocs
            , inputDocs
            ]


buttonDocs : UIDocsChapter (Html UIDocsMsg)
buttonDocs =
    uiDocsChapter "Button"
        |> withSections
            [ ( "Default", button [] [] )
            , ( "Disabled", button [ disabled True ] [] )
            ]

inputDocs : UIDocsChapter (Html UIDocsMsg)
inputDocs =
    uiDocsChapter "Input"
        |> withSection
            (input [ placeholder "Type something" ] [])

```

You can set it up just as you would any other Elm application or you can use our simple built-in development server like this:

```bash
npm install --save-dev elm-ui-docs
npx elm-ui-docs ./Docs.elm
```

## Logging Actions

You can use one of the provided helpers to log your actions on the in-app action log.

```elm
import UIDocs exposing (..)

-- Will log "Clicked!" after pressing the button
button
  [ onClick <| logAction "Clicked!" ] []

-- Will log "Input: x" after pressing the "x" key
input
  [ onInput <| logActionWithString "Input: " ] []

```

## Customizing the Theme

You can replace the default "UI Docs" subtitle or the entire header with your own custom element and specify a hex color to match your app's look and feel.

```elm
main : UIDocs
main =
    uiDocs "My App"
        |> withHeader (myCompanyLogo)
        |> withColor "#007"
        |> withChapters [ … ]
```

## Using it with `elm-css`, `elm-ui` and others

If you're using any custom Html library for your UI components, just pass in a custom renderer that will map each component to elm/html's Html. Same as you would to your main application's view function.

```elm
module Main exposing (main)

import Element exposing (layout)
import UIDocs exposing (..)


main : UIDocs
main =
    uiDocs "My App"
        |> withRenderer (layout [])
        |> withChapters [ … ]

```
