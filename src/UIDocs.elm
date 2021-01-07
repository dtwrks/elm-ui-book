module UIDocs exposing (Docs(..), Msg(..), UIDocs, generate, generateCustom)

-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
-- import Html.Keyed as Keyed

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Styled exposing (fromUnstyled, toUnstyled)
import List
import UIDocs.Theme exposing (Theme, defaultTheme)
import UIDocs.Widgets exposing (..)
import Url exposing (Url)
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


toSlugsAndLabels : DocsList -> List ( String, String )
toSlugsAndLabels =
    List.map (\( slug, docs ) -> ( slug, docsLabel docs ))


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


filterBySearch : String -> List ( String, String ) -> List ( String, String )
filterBySearch search docsSlugsAndLabels =
    if String.isEmpty search then
        docsSlugsAndLabels

    else
        docsSlugsAndLabels
            |> List.filter
                (\( _, label ) ->
                    String.contains (String.toLower search) (String.toLower label)
                )


type alias Model =
    { navKey : Nav.Key
    , theme : Theme
    , docs : DocsList
    , docsSlugsAndLabels : List ( String, String )
    , activeDocs : Maybe DocsWithSlug
    , search : String
    , actionLog : List String
    , actionLogModal : Bool
    }


init :
    { docs : List ValidDocs
    , theme : Theme
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
            parseActiveDocsFromUrl props.theme.preffix docs url
    in
    ( { navKey = navKey
      , theme = props.theme
      , docs = docs
      , docsSlugsAndLabels = docsSlugsAndLabels
      , activeDocs = activeDocs
      , search = ""
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
    | Search String
    | Action String
    | ActionWithString String String
    | ActionLogShow
    | ActionLogHide


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        logAction action =
            ( { model | actionLog = action :: model.actionLog }
            , Cmd.none
            )
    in
    case msg of
        OnUrlRequest request ->
            case request of
                External url ->
                    logAction ("Navigate to: " ++ url)

                Internal url ->
                    if String.startsWith "/ui-docs/" url.path then
                        ( model, Nav.pushUrl model.navKey (Url.toString url) )

                    else
                        logAction ("Navigate to: " ++ url.path)

        OnUrlChange url ->
            if url.path == "/" then
                ( { model | activeDocs = Nothing }, Cmd.none )

            else
                let
                    activeDocs =
                        parseActiveDocsFromUrl model.theme.preffix model.docs url
                in
                ( { model | activeDocs = activeDocs }, maybeRedirect model.navKey activeDocs )

        Search value ->
            ( { model | search = value }, Cmd.none )

        Action action ->
            logAction action

        ActionWithString action value ->
            logAction (action ++ ": " ++ value)

        ActionLogShow ->
            ( { model | actionLogModal = True }, Cmd.none )

        ActionLogHide ->
            ( { model | actionLogModal = False }, Cmd.none )



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
                    fromUnstyled <| Html.p [] [ Html.text "Welcome" ]
    in
    { title = "UI Docs"
    , body =
        [ wrapper
            { sidebar =
                [ title "UI Docs"
                , searchInput
                    { value = model.search
                    , onInput = Search
                    }
                , navList
                    { preffix = model.theme.preffix
                    , active = Maybe.map Tuple.first model.activeDocs
                    , items = filterBySearch model.search model.docsSlugsAndLabels
                    }
                ]
            , main_ = [ activeDocs ]
            , bottom =
                List.head model.actionLog
                    |> Maybe.map
                        (\lastAction ->
                            actionLog
                                { numberOfActions = List.length model.actionLog - 1
                                , lastAction = lastAction
                                , onClick = ActionLogShow
                                }
                        )
            , modal =
                if model.actionLogModal then
                    Just <| actionLogModal model.actionLog

                else
                    Nothing
            , onCloseModal = ActionLogHide
            }
            |> toUnstyled
        ]
    }



-- Setup


type alias UIDocs =
    Program () Model Msg


generate : List (Docs (Html Msg)) -> Program () Model Msg
generate docs =
    generateCustom
        { docs = docs
        , theme = defaultTheme
        , toHtml = identity
        }


generateCustom :
    { docs : List (Docs html)
    , theme : Theme
    , toHtml : html -> Html Msg
    }
    -> Program () Model Msg
generateCustom props =
    Browser.application
        { init =
            init
                { docs = List.map (toValidDocs props.toHtml) props.docs
                , theme = props.theme
                }
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = OnUrlChange
        , onUrlRequest = OnUrlRequest
        }
