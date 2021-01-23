module UIDocs exposing
    ( Chapter, chapter, withSection, withSections
    , UIDocs, uiDocs, withChapters
    , withColor, withSubtitle, withHeader
    , withRenderer
    , logAction, logActionWithString, logActionWithInt, logActionWithFloat, logActionMap
    , UIDocsMsg
    )

{-| UI documentation tool for Elm applications.


# Start with a chapter

You can create one chapter for each one of your components and split it in sections, to showcase all of their possible variants.

    buttonsChapter : Chapter (Html UIDocsMsg)
    buttonsChapter =
        chapter "Buttons"
            |> withSections
                [ ( "Default", button [] [] )
                , ( "Disabled", button [ disabled True ] [] )
                ]

Don't be limited by this pattern though. A chapter and its sections may be used however you want. For instance, it's useful to have a catalog of possible colors or branding guidelines in your documentation. Why not dedicate a chapter to it?

@docs Chapter, chapter, withSection, withSections


# Then create your book

Your UI documentation is a collection of chapters.

    book : UIDocs
    book =
        uiDocs "MyApp"
            |> withChapters
                [ colorsChapter
                , buttonsChapter
                , inputsChapter
                , chartsChapter
                ]

This returns a standard `Browser.application`. You can choose to use it just as you would any Elm application – however, this package can also be added as a NPM dependency to be used as zero-config dev server to get things started.

If you want to use our zero-config dev server, just install `elm-ui-docs` as a devDependency then run `npx elm-ui-docs {MyBookModule}.elm` and you should see your brand new documentation running on your browser.

@docs UIDocs, uiDocs, withChapters


# Customize the book's theme

@docs withColor, withSubtitle, withHeader


# Integration with elm-css, elm-ui and others

@docs withRenderer


# Logging Actions

@docs logAction, logActionWithString, logActionWithInt, logActionWithFloat, logActionMap


# Exposed Types

You shouldn't really have to worry about these. This package focuses on opaque types so you don't have to worry about how things are set up underneath.

@docs UIDocsMsg

-}

import Array exposing (Array)
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events exposing (onKeyDown, onKeyUp)
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Styled exposing (fromUnstyled, toUnstyled)
import Json.Decode as Decode
import List
import Task
import UIDocs.Theme exposing (Theme, defaultTheme)
import UIDocs.Widgets exposing (..)
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), map, oneOf, parse, s, string)


{-| Defines an UI Docs application.
-}
type alias UIDocs =
    Program () Model UIDocsMsg


type UIDocsConfig html
    = UIDocsConfig
        { theme : Theme UIDocsMsg
        , toHtml : html -> Html UIDocsMsg
        }


{-| Kickoff the creation of an UIDocs application.
-}
uiDocs : String -> UIDocsConfig (Html UIDocsMsg)
uiDocs title =
    UIDocsConfig
        { theme = defaultTheme title
        , toHtml = identity
        }


{-| When using a custom HTML library like elm-css or elm-ui, use this to easily turn all your chapters into plain HTML.
-}
withRenderer : (html -> Html UIDocsMsg) -> UIDocsConfig other -> UIDocsConfig html
withRenderer toHtml (UIDocsConfig config) =
    UIDocsConfig
        { theme = config.theme
        , toHtml = toHtml
        }


{-| Customize your docs to fit your app's theme.
-}
withColor : String -> UIDocsConfig html -> UIDocsConfig html
withColor color (UIDocsConfig config) =
    UIDocsConfig
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
withSubtitle : String -> UIDocsConfig html -> UIDocsConfig html
withSubtitle subtitle (UIDocsConfig config) =
    UIDocsConfig
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
-}
withHeader : Html UIDocsMsg -> UIDocsConfig html -> UIDocsConfig html
withHeader customHeader (UIDocsConfig config) =
    UIDocsConfig
        { theme =
            { urlPreffix = config.theme.urlPreffix
            , title = config.theme.title
            , subtitle = config.theme.subtitle
            , customHeader = Just customHeader
            , color = config.theme.color
            }
        , toHtml = config.toHtml
        }


{-| List the chapters that should be displayed on your documentation.

**Should be used as the final step on your UIDocs setup.**

-}
withChapters : List (Chapter html) -> UIDocsConfig html -> UIDocs
withChapters chapters (UIDocsConfig config) =
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
                    ]
        }



-- Chapters


type alias ChapterConfig html =
    { title : String
    , slug : String
    , sections : List ( String, html )
    }


{-| Each chapter needs to define their "type" of Html. So for plain-html applications this would look like:

    Chapter (Html UIDocsMsg)

But if you're using something like `elm-ui` this would be:

    Chapter (Element UIDocsMsg)

**Just be sure to use the same type throughout your book.**

-}
type Chapter html
    = Chapter (ChapterConfig html)


{-| Creates a chapter with some title.
-}
chapter : String -> ChapterConfig html
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
withSection : html -> ChapterConfig html -> Chapter html
withSection html config =
    Chapter
        { title = config.title
        , slug = config.slug
        , sections = [ ( "", html ) ]
        }


{-| Used for chapters with multiple sections.
-}
withSections : List ( String, html ) -> ChapterConfig html -> Chapter html
withSections sections config =
    Chapter
        { title = config.title
        , slug = config.slug
        , sections = sections
        }



-- App


toValidChapter : (html -> Html UIDocsMsg) -> Chapter html -> ChapterConfig (Html UIDocsMsg)
toValidChapter toHtml (Chapter config) =
    { title = config.title
    , slug = config.slug
    , sections = List.map (Tuple.mapSecond toHtml) config.sections
    }


chapterWithSlug : String -> Array (ChapterConfig (Html UIDocsMsg)) -> Maybe (ChapterConfig (Html UIDocsMsg))
chapterWithSlug targetSlug chapters =
    chapters
        |> Array.filter (\{ slug } -> slug == targetSlug)
        |> Array.get 0


searchChapters : String -> Array (ChapterConfig (Html UIDocsMsg)) -> Array (ChapterConfig (Html UIDocsMsg))
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
    , theme : Theme UIDocsMsg
    , chapters : Array (ChapterConfig (Html UIDocsMsg))
    , chaptersSearched : Array (ChapterConfig (Html UIDocsMsg))
    , chapterActive : Maybe (ChapterConfig (Html UIDocsMsg))
    , chapterPreSelected : Int
    , search : String
    , isSearching : Bool
    , isShiftPressed : Bool
    , isMetaPressed : Bool
    , actionLog : List String
    , actionLogModal : Bool
    }


init :
    { chapters : List (ChapterConfig (Html UIDocsMsg))
    , theme : Theme UIDocsMsg
    }
    -> ()
    -> Url
    -> Nav.Key
    -> ( Model, Cmd UIDocsMsg )
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
      }
    , maybeRedirect navKey activeChapter
    )



-- Routing


type Route
    = Route String


parseActiveChapterFromUrl : String -> Array (ChapterConfig (Html UIDocsMsg)) -> Url -> Maybe (ChapterConfig (Html UIDocsMsg))
parseActiveChapterFromUrl preffix docsList url =
    parse (oneOf [ map Route (s preffix </> string) ]) url
        |> Maybe.andThen (\(Route slug) -> chapterWithSlug slug docsList)


maybeRedirect : Nav.Key -> Maybe a -> Cmd UIDocsMsg
maybeRedirect navKey m =
    case m of
        Just _ ->
            Cmd.none

        Nothing ->
            Nav.pushUrl navKey "/"



-- Update


{-| -}
type UIDocsMsg
    = OnUrlRequest UrlRequest
    | OnUrlChange Url
    | Action String
    | ActionLogShow
    | ActionLogHide
    | SearchFocus
    | SearchBlur
    | Search String
    | DoNothing
    | KeyArrowDown
    | KeyArrowUp
    | KeyShiftOn
    | KeyShiftOff
    | KeyMetaOn
    | KeyMetaOff
    | KeyEnter
    | KeyK
    | KeyIgnore


update : UIDocsMsg -> Model -> ( Model, Cmd UIDocsMsg )
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
                ( { model | chapterActive = activeChapter }, maybeRedirect model.navKey activeChapter )

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
                ( model, Task.attempt (\_ -> DoNothing) (Browser.Dom.focus "ui-docs-search") )

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

        KeyIgnore ->
            ( model, Cmd.none )

        DoNothing ->
            ( model, Cmd.none )



-- Public Actions


{-| -}
logAction : String -> UIDocsMsg
logAction action =
    Action action


{-| -}
logActionWithString : String -> String -> UIDocsMsg
logActionWithString action value =
    Action <| (action ++ ": " ++ value)


{-| -}
logActionWithInt : String -> String -> UIDocsMsg
logActionWithInt action value =
    Action <| (action ++ ": " ++ value)


{-| -}
logActionWithFloat : String -> String -> UIDocsMsg
logActionWithFloat action value =
    Action <| (action ++ ": " ++ value)


{-| -}
logActionMap : String -> (value -> String) -> value -> UIDocsMsg
logActionMap action toString value =
    Action <| (action ++ ": " ++ toString value)



-- View


view : Model -> Browser.Document UIDocsMsg
view model =
    let
        activeChapter =
            case model.chapterActive of
                Just config ->
                    if List.length config.sections == 1 then
                        config.sections
                            |> List.head
                            |> Maybe.map Tuple.second
                            |> Maybe.map (UIDocs.Widgets.docs model.theme config.title)
                            |> Maybe.withDefault (UIDocs.Widgets.docsEmpty model.theme)

                    else
                        UIDocs.Widgets.docsWithVariants model.theme config.title config.sections

                Nothing ->
                    UIDocs.Widgets.docsEmpty model.theme
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
        [ wrapper
            { theme = model.theme
            , sidebar =
                sidebar
                    { title =
                        model.theme.customHeader
                            |> Maybe.map fromUnstyled
                            |> Maybe.withDefault
                                (title
                                    { theme = model.theme
                                    , title = model.theme.title
                                    , subtitle = model.theme.subtitle
                                    }
                                )
                    , search =
                        searchInput
                            { theme = model.theme
                            , value = model.search
                            , onInput = Search
                            , onFocus = SearchFocus
                            , onBlur = SearchBlur
                            }
                    , navList =
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
                    }
            , main_ = [ activeChapter ]
            , bottom =
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


keyDownDecoder : Decode.Decoder UIDocsMsg
keyDownDecoder =
    Decode.map
        (\string ->
            case string of
                "ArrowDown" ->
                    KeyArrowDown

                "ArrowUp" ->
                    KeyArrowUp

                "Shift" ->
                    KeyShiftOn

                "Meta" ->
                    KeyMetaOn

                "Enter" ->
                    KeyEnter

                "k" ->
                    KeyK

                "K" ->
                    KeyK

                _ ->
                    KeyIgnore
        )
        (Decode.field "key" Decode.string)


keyUpDecoder : Decode.Decoder UIDocsMsg
keyUpDecoder =
    Decode.map
        (\string ->
            case string of
                "Shift" ->
                    KeyShiftOff

                "Meta" ->
                    KeyMetaOff

                _ ->
                    KeyIgnore
        )
        (Decode.field "key" Decode.string)
