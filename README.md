# UI Book

A book that tells the story of the UI elements of your Elm application.

- Plain Elm (no custom setup)
- Customizable theme colors and header
- Organize your components into chapters and sections
- Log your actions
- Built-in development server (Optional)

## Start with a chapter.

You can create one chapter for each one of your UI elements and split it in sections to showcase all of their possible variants.

    buttonsChapter : UIChapter (Html UIBookMsg)
    buttonsChapter =
        chapter "Buttons"
            |> withSections
                [ ( "Default", button [] [] )
                , ( "Disabled", button [ disabled True ] [] )
                ]

Don't be limited by this pattern though. A chapter and its sections may be used however you want. For instance, it's useful to have a catalog of possible colors or branding guidelines in your documentation. Why not dedicate a chapter to it?

## Then, create your book.

Your UIBook is a collection of chapters.

    book : UIBook
    book =
        book "MyApp"
            |> withChapters
                [ colorsChapter
                , buttonsChapter
                , inputsChapter
                , chartsChapter
                ]

This returns a standard `Browser.application`. You can choose to use it just as you would any Elm application – however, this package can also be added as a NPM dependency to be used as zero-config dev server to get things started.

If you want to use our zero-config dev server, just install `elm-ui-book` as a devDependency then run `npx elm-ui-book {MyBookModule}.elm` and you should see your brand new Book running on your browser.

## Customize the book's style.

You can configure your book with a few extra settings to make it more personalized. Want to change the theme color so it's more fitting to your brand? Sure. Want to use your app's logo as the header? Go crazy.

    book "MyApp"
        |> withColor "#007"
        |> withSubtitle "Design System"
        |> withChapters [ ... ]

## Integrate it with elm-css, elm-ui and others.

If you're building your UI elements with something other than [elm/html](https://package.elm-lang.org/packages/elm/html/latest), no worries. Just specify a renderer function that will transform your custom elements to what Elm's runtime is expecting and everything is going to be just fine. For instance, if you're using `elm-ui`, you would do something like this:

    import Element exposing (layout)

    book "MyApp"
        |> withRenderer (layout [])
        |> withChapters [ ... ]

## Interact with it.

For now, you can't really create interactive elements inside your UIBook. However, you can showcase their different states and log actions that represent the intent to move between states. Something like this:

    -- Will log "Clicked!" after pressing the button
    button [ onClick <| logAction "Clicked!" ] []

    -- Will log "Input: x" after pressing the "x" key
    input [ onInput <| logActionWithString "Input: " ] []

## What's next?

This package is still being actively developed. This is what is in the roadmap for now:

- Make it work properly on mobile.
- Create some way of using interactive components without overly complicating the rest of the setup.
- More customization possibilities for chapters/sections.
