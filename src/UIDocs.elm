module UIDocs exposing
    ( UIDocs
    , UIDocsChapter
    , UIDocsMsg
    , logAction
    , logActionMap
    , logActionWithFloat
    , logActionWithInt
    , logActionWithString
    , uiDocs
    , uiDocsChapter
    , withChapters
    , withColor
    , withHeader
    , withRenderer
    , withSection
    , withSectionList
    , withSubtitle
    )

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



-- UIDocs


{-| -}
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
withChapters : List (UIDocsChapter html) -> UIDocsConfig html -> UIDocs
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


type alias UIDocsChapterConfig html =
    { title : String
    , slug : String
    , sections : List ( String, html )
    }


{-| -}
type UIDocsChapter html
    = UIDocsChapter (UIDocsChapterConfig html)


{-| Kicksoff the creation of an UIDocs chapter.
-}
uiDocsChapter : String -> UIDocsChapterConfig html
uiDocsChapter title =
    { title = title
    , slug = toSlug title
    , sections = []
    }


toSlug : String -> String
toSlug =
    String.toLower >> String.replace " " "-"


{-| Creates a chapter with a single section.
-}
withSection : html -> UIDocsChapterConfig html -> UIDocsChapter html
withSection html chapter =
    UIDocsChapter
        { title = chapter.title
        , slug = chapter.slug
        , sections = [ ( "", html ) ]
        }


{-| Creates a chapter with multiple sections.
-}
withSectionList : List ( String, html ) -> UIDocsChapterConfig html -> UIDocsChapter html
withSectionList sections chapter =
    UIDocsChapter
        { title = chapter.title
        , slug = chapter.slug
        , sections = sections
        }



-- App


toValidChapter : (html -> Html UIDocsMsg) -> UIDocsChapter html -> UIDocsChapterConfig (Html UIDocsMsg)
toValidChapter toHtml (UIDocsChapter chapter) =
    { title = chapter.title
    , slug = chapter.slug
    , sections = List.map (Tuple.mapSecond toHtml) chapter.sections
    }


chapterWithSlug : String -> Array (UIDocsChapterConfig (Html UIDocsMsg)) -> Maybe (UIDocsChapterConfig (Html UIDocsMsg))
chapterWithSlug targetSlug chapters =
    chapters
        |> Array.filter (\{ slug } -> slug == targetSlug)
        |> Array.get 0


searchChapters : String -> Array (UIDocsChapterConfig (Html UIDocsMsg)) -> Array (UIDocsChapterConfig (Html UIDocsMsg))
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
    , chapters : Array (UIDocsChapterConfig (Html UIDocsMsg))
    , chaptersSearched : Array (UIDocsChapterConfig (Html UIDocsMsg))
    , chapterActive : Maybe (UIDocsChapterConfig (Html UIDocsMsg))
    , chapterPreSelected : Int
    , search : String
    , isSearching : Bool
    , isShiftPressed : Bool
    , isMetaPressed : Bool
    , actionLog : List String
    , actionLogModal : Bool
    }


init :
    { chapters : List (UIDocsChapterConfig (Html UIDocsMsg))
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


parseActiveChapterFromUrl : String -> Array (UIDocsChapterConfig (Html UIDocsMsg)) -> Url -> Maybe (UIDocsChapterConfig (Html UIDocsMsg))
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


logAction : String -> UIDocsMsg
logAction action =
    Action action


logActionWithString : String -> String -> UIDocsMsg
logActionWithString action value =
    Action <| (action ++ ": " ++ value)


logActionWithInt : String -> String -> UIDocsMsg
logActionWithInt action value =
    Action <| (action ++ ": " ++ value)


logActionWithFloat : String -> String -> UIDocsMsg
logActionWithFloat action value =
    Action <| (action ++ ": " ++ value)


logActionMap : String -> (value -> String) -> value -> UIDocsMsg
logActionMap action toString value =
    Action <| (action ++ ": " ++ toString value)



-- View


view : Model -> Browser.Document UIDocsMsg
view model =
    let
        activeChapter =
            case model.chapterActive of
                Just chapter ->
                    if List.length chapter.sections == 1 then
                        chapter.sections
                            |> List.head
                            |> Maybe.map Tuple.second
                            |> Maybe.map (UIDocs.Widgets.docs model.theme chapter.title)
                            |> Maybe.withDefault (UIDocs.Widgets.docsEmpty model.theme)

                    else
                        UIDocs.Widgets.docsWithVariants model.theme chapter.title chapter.sections

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
