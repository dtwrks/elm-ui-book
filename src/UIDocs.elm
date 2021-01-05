module UIDocs exposing (Docs(..), Msg(..), UIDocs, generate, generateCustom)

-- import Html.Attributes exposing (..)
-- import Html.Events exposing (..)
-- import Html.Keyed as Keyed

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Styled exposing (fromUnstyled, toUnstyled)
import List
import UIDocs.Theme exposing (Theme, defaultTheme)
import UIDocs.Widgets exposing (..)
import Url exposing (Url)
import Url.Parser exposing ((</>), map, oneOf, parse, string)


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


type alias Model =
    { navKey : Nav.Key
    , theme : Theme
    , docs : DocsList
    , docsSlugsAndLabels : List ( String, String )
    , activeDocs : Maybe DocsWithSlug
    , search : String
    , actionLog : List String
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
            parseActiveDocsFromUrl docs url
    in
    ( { navKey = navKey
      , theme = props.theme
      , docs = docs
      , docsSlugsAndLabels = docsSlugsAndLabels
      , activeDocs = activeDocs
      , search = ""
      , actionLog = []
      }
    , maybeRedirect navKey activeDocs
    )



-- Routing


type Route
    = Route String


parseActiveDocsFromUrl : DocsList -> Url -> Maybe DocsWithSlug
parseActiveDocsFromUrl docsList url =
    parse (oneOf [ map Route string ]) url
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
    | ActionWithString String String


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
                    logAction ("Navigate to: " ++ url.path)
                        |> Tuple.mapSecond (\_ -> Nav.pushUrl model.navKey (Url.toString url))

        OnUrlChange url ->
            if url.path == "/" then
                ( { model | activeDocs = Nothing }, Cmd.none )

            else
                let
                    activeDocs =
                        parseActiveDocsFromUrl model.docs url
                in
                ( { model | activeDocs = activeDocs }, maybeRedirect model.navKey activeDocs )

        Action action ->
            logAction action

        ActionWithString action value ->
            logAction (action ++ ": " ++ value)



-- View
-- viewList : DocsList Msg -> Html Msg
-- viewList docs_ =
--     let
--         cases : ( String, DocsCaseList Msg ) -> Html Msg
--         cases ( docId, cases_ ) =
--             li [ class "text-sm py-2" ]
--                 [ p [ class "font-bold text-primary-800" ] [ text docId ]
--                 , ul [] <|
--                     List.map
--                         (\( caseId, _ ) ->
--                             li []
--                                 [ a
--                                     [ class "cursor-pointer"
--                                     , onClick <| ShowDocsCase ( docId, caseId )
--                                     ]
--                                     [ text caseId ]
--                                 ]
--                         )
--                         cases_
--                 ]
--     in
--     ul [] (List.map cases docs_)
-- viewActiveCase : ActiveCase msg -> Html msg
-- viewActiveCase v =
--     case v of
--         Just ( doc, case_, html ) ->
--             Keyed.node "div" [] [ ( doc ++ case_, html ) ]
--         Nothing ->
--             text "Select a component on the left to get started."


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
                , navList
                    { active = Maybe.map Tuple.first model.activeDocs
                    , items = model.docsSlugsAndLabels
                    }
                ]
            , main_ = [ activeDocs ]
            , modal = Nothing
            , bottom =
                List.head model.actionLog
                    |> Maybe.map
                        (\lastAction ->
                            actionLog (List.length model.actionLog) lastAction
                        )
            }
            |> toUnstyled
        ]
    }



-- [ viewList model.docs
-- , viewActiveCase model.active
-- ]
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
