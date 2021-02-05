module UIBook exposing
    ( chapter, withSection, withSections, UIChapter
    , book, withChapters, UIBook, UIBookMsg
    , withColor, withSubtitle, withHeader
    , withRenderer
    , logAction, logActionWithString, logActionWithInt, logActionWithFloat, logActionMap
    , UIBookMsgStateful, bookStateful
    )

{-| A book that tells the story of the UI elements of your Elm application.


# Start with a chapter.

You can create one chapter for each one of your UI elements and split it in sections to showcase all of their possible variants.

    buttonsChapter : UIChapter (Html UIBookMsg)
    buttonsChapter =
        chapter "Buttons"
            |> withSections
                [ ( "Default", button [] [] )
                , ( "Disabled", button [ disabled True ] [] )
                ]

Don't be limited by this pattern though. A chapter and its sections may be used however you want. For instance, it's useful to have a catalog of possible colors or branding guidelines in your documentation. Why not dedicate a chapter to it?

@docs chapter, withSection, withSections, UIChapter


# Then, create your book.

Your UIBook is a collection of chapters.

    book : Book
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

@docs book, withChapters, UIBook, UIBookMsg


# Customize the book's style.

You can configure your book with a few extra settings to make it more personalized. Want to change the theme color so it's more fitting to your brand? Sure. Want to use your app's logo as the header? Go crazy.

    book "MyApp"
        |> withColor "#007"
        |> withSubtitle "Design System"
        |> withChapters []

**Important**: Please note that you always need to use the `withChapters` functions the final step of your setup.

@docs withColor, withSubtitle, withHeader


# Integrate it with elm-css, elm-ui and others.

If you're building your UI elements with something other than [elm/html](https://package.elm-lang.org/packages/elm/html/latest), no worries. Just specify a renderer function that will transform your custom elements to what Elm's runtime is expecting and everything is going to be just fine. For instance, if you're using `elm-ui`, you would do something like this:

    import Element exposing (layout)

    book "MyApp"
        |> withRenderer (layout [])
        |> withChapters []

**Important**: Please note that you always need to use the `withChapters` functions the final step of your setup.

@docs withRenderer


# Interact with it.

For now, you can't really create interactive elements inside your UIBook. However, you can showcase their different states and log actions that represent the intent to move between states. Something like this:

    -- Will log "Clicked!" after pressing the button
    button [ onClick <| logAction "Clicked!" ] []

    -- Will log "Input: x" after pressing the "x" key
    input [ onInput <| logActionWithString "Input: " ] []

@docs logAction, logActionWithString, logActionWithInt, logActionWithFloat, logActionMap

-}

import Array exposing (Array)
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events exposing (onKeyDown, onKeyUp)
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Styled exposing (fromUnstyled, text, toUnstyled)
import Json.Decode as Decode
import List
import Task
import UIBook.Widgets exposing (..)
import UIBook.Widgets.Footer
import UIBook.Widgets.Header
import UIBook.Widgets.Wrapper
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), map, oneOf, parse, s, string)


{-| Defines an UI Docs application.
-}
type alias UIBook html =
    UIBookStateful () html


type alias UIBookStateful state html =
    Program () (Model state html) (Msg state)


type UIBookBuilder state html
    = UIBookBuilder (UIBookConfig state html)


type alias UIBookConfig state html =
    { urlPreffix : String
    , title : String
    , subtitle : String
    , customHeader : Maybe (Html Never)
    , theme : String
    , state : state
    , toHtml : html -> Html (Msg state)
    }


{-| Kickoff the creation of an UIBook application.
-}
book : String -> UIBookBuilder () (Html (Msg ()))
book title =
    UIBookBuilder
        { urlPreffix = "chapter"
        , title = title
        , subtitle = "UI Book"
        , customHeader = Nothing
        , theme = "#1293D8"
        , state = ()
        , toHtml = identity
        }


bookStateful : String -> state -> UIBookBuilder state (Html (Msg state))
bookStateful title state =
    UIBookBuilder
        { urlPreffix = "chapter"
        , title = title
        , subtitle = "UI Book"
        , customHeader = Nothing
        , theme = "#1293D8"
        , state = state
        , toHtml = identity
        }


{-| When using a custom HTML library like elm-css or elm-ui, use this to easily turn all your chapters into plain HTML.
-}
withRenderer : (html -> Html (Msg state)) -> UIBookBuilder state x -> UIBookBuilder state html
withRenderer toHtml (UIBookBuilder config) =
    UIBookBuilder
        { urlPreffix = config.urlPreffix
        , title = config.title
        , subtitle = config.subtitle
        , customHeader = config.customHeader
        , theme = config.theme
        , state = config.state
        , toHtml = toHtml
        }


{-| Customize your docs to fit your app's theme.
-}
withColor : String -> UIBookBuilder state html -> UIBookBuilder state html
withColor theme (UIBookBuilder config) =
    UIBookBuilder
        { config | theme = theme }


{-| Replace the default "UI Docs" subtitle with a custom one.
-}
withSubtitle : String -> UIBookBuilder state html -> UIBookBuilder state html
withSubtitle subtitle (UIBookBuilder config) =
    UIBookBuilder
        { config | subtitle = subtitle }


{-| Replace the entire header with a custom one.

    book "MyApp"
        |> withHeader (h1 [ style "color" "crimson" ] [ text "My App" ])
        |> withChapters []

-}
withHeader : Html Never -> UIBookBuilder state html -> UIBookBuilder state html
withHeader customHeader (UIBookBuilder config) =
    UIBookBuilder
        { config | customHeader = Just customHeader }


{-| List the chapters that should be displayed on your book.

**Should be used as the final step on your setup.**

-}
withChapters : List (UIChapter html) -> UIBookBuilder state html -> UIBookStateful state html
withChapters chapters (UIBookBuilder config) =
    Browser.application
        { init =
            init
                { config = config
                , chapters = List.map (\(UIChapter c) -> c) chapters
                }
        , view = view
        , update = update
        , onUrlChange = OnUrlChange
        , onUrlRequest = OnUrlRequest
        , subscriptions =
            \_ ->
                Sub.batch
                    [ onKeyDown keyDownDecoder
                    , onKeyUp keyUpDecoder
                    ]
        }


{-| Each chapter needs to define their "type" of Html. So for plain-html applications this would look like:

    UIChapter (Html UIBookMsg)

But if you're using something like `elm-ui` this would be:

    UIChapter (Element UIBookMsg)

**Just be sure to use the same type throughout your book.**

-}
type UIChapter html
    = UIChapter (UIChapterConfig html)


{-| -}
type alias UIChapterConfig html =
    { title : String
    , slug : String
    , sections : List ( String, html )
    }


{-| Creates a chapter with some title.
-}
chapter : String -> UIChapterConfig html
chapter title =
    { title = title
    , slug = toSlug title
    , sections = []
    }


toSlug : String -> String
toSlug =
    String.toLower >> String.replace " " "-"


{-| Used for chapters with a single section.
-}
withSection : html -> UIChapterConfig html -> UIChapter html
withSection html config =
    UIChapter
        { title = config.title
        , slug = config.slug
        , sections = [ ( "", html ) ]
        }


{-| Used for chapters with multiple sections.
-}
withSections : List ( String, html ) -> UIChapterConfig html -> UIChapter html
withSections sections config =
    UIChapter
        { title = config.title
        , slug = config.slug
        , sections = sections
        }



-- App


chapterWithSlug : String -> Array (UIChapterConfig html) -> Maybe (UIChapterConfig html)
chapterWithSlug targetSlug chapters =
    chapters
        |> Array.filter (\{ slug } -> slug == targetSlug)
        |> Array.get 0


searchChapters : String -> Array (UIChapterConfig html) -> Array (UIChapterConfig html)
searchChapters search chapters =
    case search of
        "" ->
            chapters

        _ ->
            let
                searchLowerCase =
                    String.toLower search

                titleMatchesSearch { title } =
                    String.contains searchLowerCase (String.toLower title)
            in
            Array.filter titleMatchesSearch chapters


type alias Model state html =
    { navKey : Nav.Key
    , config : UIBookConfig state html
    , chapters : Array (UIChapterConfig html)
    , chaptersSearched : Array (UIChapterConfig html)
    , chapterActive : Maybe (UIChapterConfig html)
    , chapterPreSelected : Int
    , search : String
    , isSearching : Bool
    , isShiftPressed : Bool
    , isMetaPressed : Bool
    , actionLog : List String
    , actionLogModal : Bool
    , isMenuOpen : Bool
    }


init :
    { chapters : List (UIChapterConfig html)
    , config : UIBookConfig state html
    }
    -> ()
    -> Url
    -> Nav.Key
    -> ( Model state html, Cmd (Msg state) )
init props _ url navKey =
    let
        chapters =
            Array.fromList props.chapters

        activeChapter =
            parseActiveChapterFromUrl props.config.urlPreffix chapters url
    in
    ( { navKey = navKey
      , config = props.config
      , chapters = chapters
      , chaptersSearched = chapters
      , chapterActive = activeChapter
      , chapterPreSelected = 0
      , search = ""
      , isSearching = False
      , isShiftPressed = False
      , isMetaPressed = False
      , actionLog = []
      , actionLogModal = False
      , isMenuOpen = False
      }
    , maybeRedirect navKey activeChapter
    )



-- Routing


type Route
    = Route String


parseActiveChapterFromUrl : String -> Array (UIChapterConfig html) -> Url -> Maybe (UIChapterConfig html)
parseActiveChapterFromUrl preffix docsList url =
    parse (oneOf [ map Route (s preffix </> string) ]) url
        |> Maybe.andThen (\(Route slug) -> chapterWithSlug slug docsList)


maybeRedirect : Nav.Key -> Maybe a -> Cmd (Msg state)
maybeRedirect navKey m =
    case m of
        Just _ ->
            Cmd.none

        Nothing ->
            Nav.pushUrl navKey "/"



-- Update


{-| The internal messages used by UIBook.
-}
type alias UIBookMsg =
    Msg ()


type alias UIBookMsgStateful state =
    Msg state


type Msg state
    = DoNothing
    | OnUrlRequest UrlRequest
    | OnUrlChange Url
    | UpdateState state
    | LogAction String
    | ActionLogShow
    | ActionLogHide
    | SearchFocus
    | SearchBlur
    | Search String
    | ToggleMenu
    | KeyArrowDown
    | KeyArrowUp
    | KeyShiftOn
    | KeyShiftOff
    | KeyMetaOn
    | KeyMetaOff
    | KeyEnter
    | KeyK


update : Msg state -> Model state html -> ( Model state html, Cmd (Msg state) )
update msg model =
    let
        logAction_ action =
            ( { model | actionLog = action :: model.actionLog }
            , Cmd.none
            )
    in
    case msg of
        OnUrlRequest request ->
            case request of
                External url ->
                    logAction_ ("Navigate to: " ++ url)

                Internal url ->
                    if url.path == "/" || String.startsWith ("/" ++ model.config.urlPreffix ++ "/") url.path then
                        ( model, Nav.pushUrl model.navKey (Url.toString url) )

                    else
                        logAction_ ("Navigate to: " ++ url.path)

        OnUrlChange url ->
            if url.path == "/" then
                ( { model | chapterActive = Nothing }, Cmd.none )

            else
                let
                    activeChapter =
                        parseActiveChapterFromUrl model.config.urlPreffix model.chapters url
                in
                ( { model
                    | chapterActive = activeChapter
                    , isMenuOpen = False
                  }
                , maybeRedirect model.navKey activeChapter
                )

        UpdateState state ->
            let
                config =
                    model.config

                nextConfig =
                    { config | state = state }
            in
            ( { model | config = nextConfig }
            , Cmd.none
            )

        LogAction action ->
            logAction_ action

        ActionLogShow ->
            ( { model | actionLogModal = True }, Cmd.none )

        ActionLogHide ->
            ( { model | actionLogModal = False }, Cmd.none )

        SearchFocus ->
            ( { model | isSearching = True, chapterPreSelected = 0 }, Cmd.none )

        SearchBlur ->
            ( { model | isSearching = False }, Cmd.none )

        Search value ->
            ( { model
                | search = value
                , chaptersSearched = searchChapters value model.chapters
                , chapterPreSelected = 0
              }
            , Cmd.none
            )

        ToggleMenu ->
            ( { model | isMenuOpen = not model.isMenuOpen }
            , Cmd.none
            )

        KeyArrowDown ->
            ( { model
                | chapterPreSelected = modBy (Array.length model.chaptersSearched) (model.chapterPreSelected + 1)
              }
            , Cmd.none
            )

        KeyArrowUp ->
            ( { model
                | chapterPreSelected = modBy (Array.length model.chaptersSearched) (model.chapterPreSelected - 1)
              }
            , Cmd.none
            )

        KeyShiftOn ->
            ( { model | isShiftPressed = True }, Cmd.none )

        KeyShiftOff ->
            ( { model | isShiftPressed = False }, Cmd.none )

        KeyMetaOn ->
            ( { model | isMetaPressed = True }, Cmd.none )

        KeyMetaOff ->
            ( { model | isMetaPressed = False }, Cmd.none )

        KeyK ->
            if model.isMetaPressed then
                ( model, Task.attempt (\_ -> DoNothing) (Browser.Dom.focus "ui-book-search") )

            else
                ( model, Cmd.none )

        KeyEnter ->
            if model.isSearching then
                case Array.get model.chapterPreSelected model.chaptersSearched of
                    Just { slug } ->
                        ( model
                        , Nav.pushUrl model.navKey <| Url.Builder.absolute [ model.config.urlPreffix, slug ] []
                        )

                    Nothing ->
                        ( model, Cmd.none )

            else
                ( model, Cmd.none )

        DoNothing ->
            ( model, Cmd.none )



-- Public Actions


{-| Logs an action that takes no inputs. e.g. onClick
-}
logAction : String -> UIBookMsg
logAction action =
    LogAction action


{-| Logs an action that takes one string input. e.g. onInput
-}
logActionWithString : String -> String -> UIBookMsg
logActionWithString action value =
    LogAction <| (action ++ ": " ++ value)


{-| Logs an action that takes one Int input.
-}
logActionWithInt : String -> String -> UIBookMsg
logActionWithInt action value =
    LogAction <| (action ++ ": " ++ value)


{-| Logs an action that takes one Float input.
-}
logActionWithFloat : String -> String -> UIBookMsg
logActionWithFloat action value =
    LogAction <| (action ++ ": " ++ value)


{-| Logs an action that takes one generic input that can be transformed into a String.

    eventToString : Event -> String
    eventToString event =
        case event of
            Start ->
                "Start"

            Finish ->
                "Finish"

    myCustomElement {
        onEvent =
            logActionMap "My Custom Element: " eventToString
    }

-}
logActionMap : String -> (value -> String) -> value -> UIBookMsg
logActionMap action toString value =
    LogAction <| (action ++ ": " ++ toString value)



-- View


view : Model state html -> Browser.Document (Msg state)
view model =
    let
        activeChapter =
            case model.chapterActive of
                Just activeChapter_ ->
                    if List.length activeChapter_.sections == 1 then
                        activeChapter_.sections
                            |> List.head
                            |> Maybe.map Tuple.second
                            |> Maybe.map model.config.toHtml
                            |> Maybe.map UIBook.Widgets.docs
                            |> Maybe.withDefault UIBook.Widgets.docsEmpty

                    else
                        UIBook.Widgets.docsWithVariants <|
                            List.map (\( label, html ) -> ( label, model.config.toHtml html )) activeChapter_.sections

                Nothing ->
                    UIBook.Widgets.docsEmpty
    in
    { title =
        let
            mainTitle =
                model.config.title ++ " | " ++ model.config.subtitle
        in
        case model.chapterActive of
            Just { title } ->
                title ++ " - " ++ mainTitle

            Nothing ->
                mainTitle
    , body =
        [ UIBook.Widgets.Wrapper.view
            { color = model.config.theme
            , isMenuOpen = model.isMenuOpen
            , header =
                UIBook.Widgets.Header.view
                    { color = model.config.theme
                    , title = model.config.title
                    , subtitle = model.config.subtitle
                    , custom =
                        model.config.customHeader
                            |> Maybe.map (Html.map (\_ -> DoNothing))
                            |> Maybe.map fromUnstyled
                    , isMenuOpen = model.isMenuOpen
                    , onClickMenuButton = ToggleMenu
                    }
            , menuHeader =
                searchInput
                    { theme = model.config.theme
                    , value = model.search
                    , onInput = Search
                    , onFocus = SearchFocus
                    , onBlur = SearchBlur
                    }
            , menu =
                navList
                    { theme = model.config.theme
                    , preffix = model.config.urlPreffix
                    , active = Maybe.map .slug model.chapterActive
                    , preSelected =
                        if model.isSearching then
                            Array.get model.chapterPreSelected model.chaptersSearched
                                |> Maybe.map .slug

                        else
                            Nothing
                    , items =
                        Array.toList model.chaptersSearched
                            |> List.map (\{ slug, title } -> ( slug, title ))
                    }
            , menuFooter = UIBook.Widgets.Footer.view
            , mainHeader =
                model.chapterActive
                    |> Maybe.map .title
                    |> Maybe.withDefault ""
                    |> text
            , main = activeChapter
            , mainFooter =
                List.head model.actionLog
                    |> Maybe.map
                        (\lastAction ->
                            actionLog
                                { theme = model.config.theme
                                , numberOfActions = List.length model.actionLog - 1
                                , lastAction = lastAction
                                , onClick = ActionLogShow
                                }
                        )
                    |> Maybe.withDefault (text "")
            , modal =
                if model.actionLogModal then
                    Just <| actionLogModal model.config.theme model.actionLog

                else
                    Nothing
            , onCloseModal = ActionLogHide
            }
            |> toUnstyled
        ]
    }



-- Keyboard Events


keyDownDecoder : Decode.Decoder (Msg state)
keyDownDecoder =
    Decode.map
        (\string ->
            case String.toLower string of
                "arrowdown" ->
                    KeyArrowDown

                "arrowup" ->
                    KeyArrowUp

                "shift" ->
                    KeyShiftOn

                "meta" ->
                    KeyMetaOn

                "enter" ->
                    KeyEnter

                "k" ->
                    KeyK

                _ ->
                    DoNothing
        )
        (Decode.field "key" Decode.string)


keyUpDecoder : Decode.Decoder (Msg state)
keyUpDecoder =
    Decode.map
        (\string ->
            case String.toLower string of
                "shift" ->
                    KeyShiftOff

                "meta" ->
                    KeyMetaOff

                _ ->
                    DoNothing
        )
        (Decode.field "key" Decode.string)
