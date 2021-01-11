module UIDocs exposing
    ( Docs(..)
    , Msg
    , UIDocs
    , logAction
    , logActionMap
    , logActionWithFloat
    , logActionWithInt
    , logActionWithString
    , uiDocs
    , withColor
    , withDocs
    , withHeader
    , withRenderer
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
import Task
import UIDocs.Theme exposing (Theme, defaultTheme)
import UIDocs.Widgets exposing (..)
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), map, oneOf, parse, s, string)


{-| Used to define use cases for you component.
-}
type Docs html
    = Docs String html
    | DocsWithVariants String (List ( String, html ))


toValidDocs : (html -> Html Msg) -> Docs html -> Docs (Html Msg)
toValidDocs toHtml docs =
    case docs of
        Docs label html ->
            Docs label (toHtml html)

        DocsWithVariants label variants ->
            DocsWithVariants label
                (List.map (\( variantLabel, html ) -> ( variantLabel, toHtml html ))
                    variants
                )


type alias ValidDocs =
    Docs (Html Msg)


type alias DocsWithSlug =
    ( String, ValidDocs )


type alias DocsList =
    List DocsWithSlug


toDocsList : List ValidDocs -> DocsList
toDocsList =
    List.map (\docs -> ( docsSlug docs, docs ))


toSlugsAndLabels : DocsList -> Array ( String, String )
toSlugsAndLabels docsList =
    List.map (\( slug, docs ) -> ( slug, docsLabel docs )) docsList
        |> Array.fromList


docsLabel : Docs html -> String
docsLabel docs =
    case docs of
        Docs label _ ->
            label

        DocsWithVariants label _ ->
            label


docsSlug : Docs html -> String
docsSlug =
    docsLabel >> String.toLower >> String.replace " " "-"


docsBySlug : String -> DocsList -> Maybe DocsWithSlug
docsBySlug slug docsList =
    case List.filter (\( s, _ ) -> s == slug) docsList of
        [] ->
            Nothing

        x :: _ ->
            Just x


filterBySearch : String -> Array ( String, String ) -> Array ( String, String )
filterBySearch search docsSlugsAndLabels =
    if String.isEmpty search then
        docsSlugsAndLabels

    else
        docsSlugsAndLabels
            |> Array.filter
                (\( _, label ) ->
                    String.contains (String.toLower search) (String.toLower label)
                )


type alias Model =
    { navKey : Nav.Key
    , theme : Theme Msg
    , docs : DocsList
    , docsSlugsAndLabels : Array ( String, String )
    , filteredSlugsAndLabels : Array ( String, String )
    , activeDocs : Maybe DocsWithSlug
    , search : String
    , isSearching : Bool
    , isShiftPressed : Bool
    , isMetaPressed : Bool
    , preSelectedDocs : Int
    , actionLog : List String
    , actionLogModal : Bool
    }


init :
    { docs : List ValidDocs
    , theme : Theme Msg
    }
    -> ()
    -> Url
    -> Nav.Key
    -> ( Model, Cmd Msg )
init props _ url navKey =
    let
        docs =
            toDocsList props.docs

        docsSlugsAndLabels =
            toSlugsAndLabels docs

        activeDocs =
            parseActiveDocsFromUrl props.theme.urlPreffix docs url
    in
    ( { navKey = navKey
      , theme = props.theme
      , docs = docs
      , docsSlugsAndLabels = docsSlugsAndLabels
      , filteredSlugsAndLabels = docsSlugsAndLabels
      , activeDocs = activeDocs
      , search = ""
      , isSearching = False
      , isShiftPressed = False
      , isMetaPressed = False
      , preSelectedDocs = 0
      , actionLog = []
      , actionLogModal = False
      }
    , maybeRedirect navKey activeDocs
    )



-- Routing


type Route
    = Route String


parseActiveDocsFromUrl : String -> DocsList -> Url -> Maybe DocsWithSlug
parseActiveDocsFromUrl preffix docsList url =
    parse (oneOf [ map Route (s preffix </> string) ]) url
        |> Maybe.andThen (\(Route slug) -> docsBySlug slug docsList)


maybeRedirect : Nav.Key -> Maybe a -> Cmd msg
maybeRedirect navKey m =
    case m of
        Just _ ->
            Cmd.none

        Nothing ->
            Nav.pushUrl navKey "/"



-- Update


type Msg
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


update : Msg -> Model -> ( Model, Cmd Msg )
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
                ( { model | activeDocs = Nothing }, Cmd.none )

            else
                let
                    activeDocs =
                        parseActiveDocsFromUrl model.theme.urlPreffix model.docs url
                in
                ( { model | activeDocs = activeDocs }, maybeRedirect model.navKey activeDocs )

        Action action ->
            logAction_ action

        ActionLogShow ->
            ( { model | actionLogModal = True }, Cmd.none )

        ActionLogHide ->
            ( { model | actionLogModal = False }, Cmd.none )

        SearchFocus ->
            ( { model | isSearching = True, preSelectedDocs = 0 }, Cmd.none )

        SearchBlur ->
            ( { model | isSearching = False }, Cmd.none )

        Search value ->
            if String.isEmpty value then
                ( { model
                    | search = value
                    , filteredSlugsAndLabels = model.docsSlugsAndLabels
                    , preSelectedDocs = 0
                  }
                , Cmd.none
                )

            else
                let
                    filteredSlugsAndLabels =
                        filterBySearch model.search model.docsSlugsAndLabels
                in
                ( { model
                    | search = value
                    , filteredSlugsAndLabels = filteredSlugsAndLabels
                    , preSelectedDocs = 0
                  }
                , Cmd.none
                )

        KeyArrowDown ->
            ( { model
                | preSelectedDocs = modBy (Array.length model.filteredSlugsAndLabels) (model.preSelectedDocs + 1)
              }
            , Cmd.none
            )

        KeyArrowUp ->
            ( { model
                | preSelectedDocs = modBy (Array.length model.filteredSlugsAndLabels) (model.preSelectedDocs - 1)
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
                case Array.get model.preSelectedDocs model.filteredSlugsAndLabels of
                    Just ( slug, _ ) ->
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


logAction : String -> Msg
logAction action =
    Action action


logActionWithString : String -> String -> Msg
logActionWithString action value =
    Action <| (action ++ ": " ++ value)


logActionWithInt : String -> String -> Msg
logActionWithInt action value =
    Action <| (action ++ ": " ++ value)


logActionWithFloat : String -> String -> Msg
logActionWithFloat action value =
    Action <| (action ++ ": " ++ value)


logActionMap : String -> (value -> String) -> value -> Msg
logActionMap action toString value =
    Action <| (action ++ ": " ++ toString value)



-- View


view : Model -> Browser.Document Msg
view model =
    let
        activeDocs =
            case model.activeDocs of
                Just docs ->
                    case docs of
                        ( _, Docs label html ) ->
                            UIDocs.Widgets.docs model.theme label html

                        ( _, DocsWithVariants label variants ) ->
                            UIDocs.Widgets.docsWithVariants model.theme label variants

                Nothing ->
                    UIDocs.Widgets.docsEmpty model.theme
    in
    { title =
        let
            mainTitle =
                model.theme.title ++ " | " ++ model.theme.subtitle
        in
        case model.activeDocs of
            Just ( _, docs ) ->
                mainTitle ++ " - " ++ docsLabel docs

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
                            , active = Maybe.map Tuple.first model.activeDocs
                            , preSelected =
                                if model.isSearching then
                                    Maybe.map Tuple.first <| Array.get model.preSelectedDocs model.filteredSlugsAndLabels

                                else
                                    Nothing
                            , items = Array.toList model.filteredSlugsAndLabels
                            }
                    }
            , main_ = [ activeDocs ]
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


keyDownDecoder : Decode.Decoder Msg
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


keyUpDecoder : Decode.Decoder Msg
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



-- Setup


type alias UIDocs =
    Program () Model Msg


type UIDocsConfig html
    = UIDocsConfig
        { theme : Theme Msg
        , toHtml : html -> Html Msg
        }


uiDocs : String -> UIDocsConfig (Html Msg)
uiDocs title =
    UIDocsConfig
        { theme = defaultTheme title
        , toHtml = identity
        }


withRenderer : (html -> Html Msg) -> UIDocsConfig other -> UIDocsConfig html
withRenderer toHtml (UIDocsConfig config) =
    UIDocsConfig
        { theme = config.theme
        , toHtml = toHtml
        }


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


withHeader : Html Msg -> UIDocsConfig html -> UIDocsConfig html
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


withDocs : List (Docs html) -> UIDocsConfig html -> UIDocs
withDocs docs (UIDocsConfig config) =
    Browser.application
        { init =
            init
                { docs = List.map (toValidDocs config.toHtml) docs
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
