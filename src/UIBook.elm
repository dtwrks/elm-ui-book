module UIBook exposing
    ( chapter, withSection, withSections, UIChapter
    , book, withChapters, UIBook, UIBookMsg
    , withColor, withSubtitle, withHeader
    , withRenderer
    , logAction, logActionWithString, logActionWithInt, logActionWithFloat, logActionMap
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
import Browser.Dom exposing (getViewport)
import Browser.Events exposing (onKeyDown, onKeyUp, onResize)
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Styled exposing (fromUnstyled, text, toUnstyled)
import Json.Decode as Decode
import List
import Task
import UIBook.Theme exposing (Theme, defaultTheme)
import UIBook.Widgets exposing (..)
import UIBook.Widgets.Footer
import UIBook.Widgets.Header
import UIBook.Widgets.Wrapper
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), map, oneOf, parse, s, string)


{-| Defines an UI Docs application.
-}
type alias UIBook =
    Program () Model UIBookMsg


type UIBookConfig html
    = UIBookConfig
        { theme : Theme UIBookMsg
        , toHtml : html -> Html UIBookMsg
        }


{-| Kickoff the creation of an UIBook application.
-}
book : String -> UIBookConfig (Html UIBookMsg)
book title =
    UIBookConfig
        { theme = defaultTheme title
        , toHtml = identity
        }


{-| When using a custom HTML library like elm-css or elm-ui, use this to easily turn all your chapters into plain HTML.
-}
withRenderer : (html -> Html UIBookMsg) -> UIBookConfig other -> UIBookConfig html
withRenderer toHtml (UIBookConfig config) =
    UIBookConfig
        { theme = config.theme
        , toHtml = toHtml
        }


{-| Customize your docs to fit your app's theme.
-}
withColor : String -> UIBookConfig html -> UIBookConfig html
withColor color (UIBookConfig config) =
    UIBookConfig
        { theme =
            { urlPreffix = config.theme.urlPreffix
            , title = config.theme.title
            , subtitle = config.theme.subtitle
            , customHeader = config.theme.customHeader
            , color = color
            }
        , toHtml = config.toHtml
        }


{-| Replace the default "UI Docs" subtitle with a custom one.
-}
withSubtitle : String -> UIBookConfig html -> UIBookConfig html
withSubtitle subtitle (UIBookConfig config) =
    UIBookConfig
        { theme =
            { urlPreffix = config.theme.urlPreffix
            , title = config.theme.title
            , subtitle = subtitle
            , customHeader = config.theme.customHeader
            , color = config.theme.color
            }
        , toHtml = config.toHtml
        }


{-| Replace the entire header with a custom one.

    book "MyApp"
        |> withHeader (h1 [ style "color" "crimson" ] [ text "My App" ])
        |> withChapters []

-}
withHeader : Html UIBookMsg -> UIBookConfig html -> UIBookConfig html
withHeader customHeader (UIBookConfig config) =
    UIBookConfig
        { theme =
            { urlPreffix = config.theme.urlPreffix
            , title = config.theme.title
            , subtitle = config.theme.subtitle
            , customHeader = Just customHeader
            , color = config.theme.color
            }
        , toHtml = config.toHtml
        }


{-| List the chapters that should be displayed on your book.

**Should be used as the final step on your setup.**

-}
withChapters : List (UIChapter html) -> UIBookConfig html -> UIBook
withChapters chapters (UIBookConfig config) =
    Browser.application
        { init =
            init
                { chapters = List.map (toValidChapter config.toHtml) chapters
                , theme = config.theme
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
                    , onResize (\w _ -> OnWindowResize w)
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


toValidChapter : (html -> Html UIBookMsg) -> UIChapter html -> UIChapterConfig (Html UIBookMsg)
toValidChapter toHtml (UIChapter config) =
    { title = config.title
    , slug = config.slug
    , sections = List.map (Tuple.mapSecond toHtml) config.sections
    }


chapterWithSlug : String -> Array (UIChapterConfig (Html UIBookMsg)) -> Maybe (UIChapterConfig (Html UIBookMsg))
chapterWithSlug targetSlug chapters =
    chapters
        |> Array.filter (\{ slug } -> slug == targetSlug)
        |> Array.get 0


searchChapters : String -> Array (UIChapterConfig (Html UIBookMsg)) -> Array (UIChapterConfig (Html UIBookMsg))
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


type alias Model =
    { navKey : Nav.Key
    , theme : Theme UIBookMsg
    , chapters : Array (UIChapterConfig (Html UIBookMsg))
    , chaptersSearched : Array (UIChapterConfig (Html UIBookMsg))
    , chapterActive : Maybe (UIChapterConfig (Html UIBookMsg))
    , chapterPreSelected : Int
    , search : String
    , isSearching : Bool
    , isShiftPressed : Bool
    , isMetaPressed : Bool
    , actionLog : List String
    , actionLogModal : Bool
    , isMobile : Maybe Bool
    , isMenuOpen : Bool
    }


init :
    { chapters : List (UIChapterConfig (Html UIBookMsg))
    , theme : Theme UIBookMsg
    }
    -> ()
    -> Url
    -> Nav.Key
    -> ( Model, Cmd UIBookMsg )
init props _ url navKey =
    let
        chapters =
            Array.fromList props.chapters

        activeChapter =
            parseActiveChapterFromUrl props.theme.urlPreffix chapters url
    in
    ( { navKey = navKey
      , theme = props.theme
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
      , isMobile = Nothing
      , isMenuOpen = False
      }
    , Cmd.batch
        [ maybeRedirect navKey activeChapter
        , Task.perform (\{ scene } -> OnWindowResize <| floor scene.width) getViewport
        ]
    )



-- Routing


type Route
    = Route String


parseActiveChapterFromUrl : String -> Array (UIChapterConfig (Html UIBookMsg)) -> Url -> Maybe (UIChapterConfig (Html UIBookMsg))
parseActiveChapterFromUrl preffix docsList url =
    parse (oneOf [ map Route (s preffix </> string) ]) url
        |> Maybe.andThen (\(Route slug) -> chapterWithSlug slug docsList)


maybeRedirect : Nav.Key -> Maybe a -> Cmd UIBookMsg
maybeRedirect navKey m =
    case m of
        Just _ ->
            Cmd.none

        Nothing ->
            Nav.pushUrl navKey "/"



-- Update


{-| The internal messages used by UIBook.
-}
type UIBookMsg
    = DoNothing
    | OnUrlRequest UrlRequest
    | OnUrlChange Url
    | Action String
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
    | OnWindowResize Int


update : UIBookMsg -> Model -> ( Model, Cmd UIBookMsg )
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
                    if url.path == "/" || String.startsWith ("/" ++ model.theme.urlPreffix ++ "/") url.path then
                        ( model, Nav.pushUrl model.navKey (Url.toString url) )

                    else
                        logAction_ ("Navigate to: " ++ url.path)

        OnUrlChange url ->
            if url.path == "/" then
                ( { model | chapterActive = Nothing }, Cmd.none )

            else
                let
                    activeChapter =
                        parseActiveChapterFromUrl model.theme.urlPreffix model.chapters url
                in
                ( { model
                    | chapterActive = activeChapter
                    , isMenuOpen = False
                  }
                , maybeRedirect model.navKey activeChapter
                )

        Action action ->
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
                        , Nav.pushUrl model.navKey <| Url.Builder.absolute [ model.theme.urlPreffix, slug ] []
                        )

                    Nothing ->
                        ( model, Cmd.none )

            else
                ( model, Cmd.none )

        OnWindowResize width ->
            ( { model
                | isMobile = Just <| width < 768
              }
            , Cmd.none
            )

        DoNothing ->
            ( model, Cmd.none )



-- Public Actions


{-| Logs an action that takes no inputs. e.g. onClick
-}
logAction : String -> UIBookMsg
logAction action =
    Action action


{-| Logs an action that takes one string input. e.g. onInput
-}
logActionWithString : String -> String -> UIBookMsg
logActionWithString action value =
    Action <| (action ++ ": " ++ value)


{-| Logs an action that takes one Int input.
-}
logActionWithInt : String -> String -> UIBookMsg
logActionWithInt action value =
    Action <| (action ++ ": " ++ value)


{-| Logs an action that takes one Float input.
-}
logActionWithFloat : String -> String -> UIBookMsg
logActionWithFloat action value =
    Action <| (action ++ ": " ++ value)


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
    Action <| (action ++ ": " ++ toString value)



-- View


view : Model -> Browser.Document UIBookMsg
view model =
    let
        activeChapter =
            case model.chapterActive of
                Just config ->
                    if List.length config.sections == 1 then
                        config.sections
                            |> List.head
                            |> Maybe.map Tuple.second
                            |> Maybe.map UIBook.Widgets.docs
                            |> Maybe.withDefault UIBook.Widgets.docsEmpty

                    else
                        UIBook.Widgets.docsWithVariants config.sections

                Nothing ->
                    UIBook.Widgets.docsEmpty
    in
    { title =
        let
            mainTitle =
                model.theme.title ++ " | " ++ model.theme.subtitle
        in
        case model.chapterActive of
            Just { title } ->
                title ++ " - " ++ mainTitle

            Nothing ->
                mainTitle
    , body =
        case model.isMobile of
            Nothing ->
                []

            Just isMobile ->
                [ UIBook.Widgets.Wrapper.view
                    { color = model.theme.color
                    , isMobile = isMobile
                    , isMenuOpen = model.isMenuOpen
                    , header =
                        UIBook.Widgets.Header.view
                            { color = model.theme.color
                            , title = model.theme.title
                            , subtitle = model.theme.subtitle
                            , custom =
                                model.theme.customHeader
                                    |> Maybe.map fromUnstyled
                            , isMenuOpen = model.isMenuOpen
                            , isMenuButtonVisible = isMobile
                            , onClickMenuButton = ToggleMenu
                            }
                    , menuHeader =
                        searchInput
                            { theme = model.theme
                            , value = model.search
                            , onInput = Search
                            , onFocus = SearchFocus
                            , onBlur = SearchBlur
                            }
                    , menu =
                        navList
                            { theme = model.theme
                            , preffix = model.theme.urlPreffix
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
                                        { theme = model.theme
                                        , numberOfActions = List.length model.actionLog - 1
                                        , lastAction = lastAction
                                        , onClick = ActionLogShow
                                        }
                                )
                            |> Maybe.withDefault (text "")
                    , modal =
                        if model.actionLogModal then
                            Just <| actionLogModal model.theme model.actionLog

                        else
                            Nothing
                    , onCloseModal = ActionLogHide
                    }
                    |> toUnstyled
                ]
    }



-- Keyboard Events


keyDownDecoder : Decode.Decoder UIBookMsg
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


keyUpDecoder : Decode.Decoder UIBookMsg
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
