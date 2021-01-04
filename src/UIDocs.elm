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


componentDocsLabel : ValidDocs -> String
componentDocsLabel c =
    case c of
        Docs label _ ->
            label

        DocsWithVariants label _ ->
            label


type alias DocsMap =
    Dict String ValidDocs


docsMapFromDocs : List ValidDocs -> DocsMap
docsMapFromDocs list =
    List.map (\c -> ( componentDocsLabel c, c )) list
        |> Dict.fromList


type alias Model =
    { navKey : Nav.Key
    , docs : List ValidDocs
    , docsLabels : List String
    , docsMap : DocsMap
    , activeDocs : Maybe ValidDocs
    , search : String
    , actionLog : List String
    }


init : List ValidDocs -> () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init docs _ url navKey =
    let
        docsMap =
            docsMapFromDocs docs

        docsLabels =
            List.map componentDocsLabel docs

        activeDocs =
            parseActiveDocsFromUrl docsMap url
    in
    ( { navKey = navKey
      , docs = docs
      , docsLabels = docsLabels
      , docsMap = docsMap
      , activeDocs = activeDocs
      , search = ""
      , actionLog = []
      }
    , maybeRedirect navKey activeDocs
    )



-- Routing


type Route
    = Route String


parseActiveDocsFromUrl : DocsMap -> Url -> Maybe ValidDocs
parseActiveDocsFromUrl docsMap url =
    parse (oneOf [ map Route string ]) url
        |> Maybe.map (\(Route c) -> c)
        |> Maybe.andThen (\c -> Dict.get c docsMap)


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
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

        OnUrlChange url ->
            if url.path == "/" then
                ( { model | activeDocs = Nothing }, Cmd.none )

            else
                let
                    activeDocs =
                        parseActiveDocsFromUrl model.docsMap url
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
                        Docs label html ->
                            Html.div []
                                [ Html.p [] [ Html.text label ]
                                , Html.div [] [ html ]
                                ]

                        DocsWithVariants label variants ->
                            Html.ul [] <|
                                List.map
                                    (\( variantLabel, html ) ->
                                        Html.li []
                                            [ Html.p [] [ Html.text variantLabel ]
                                            , Html.div [] [ html ]
                                            ]
                                    )
                                    variants

                Nothing ->
                    Html.p [] [ Html.text "Welcome" ]
    in
    { title = "UI Docs"
    , body =
        [ wrapper
            { sidebar =
                [ title "UI Docs"
                , navList
                    { active = Maybe.map componentDocsLabel model.activeDocs
                    , items = model.docsLabels
                    }
                ]
            , main_ = [ fromUnstyled activeDocs ]
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
        , toHtml = identity
        }


generateCustom :
    { docs : List (Docs html)
    , toHtml : html -> Html Msg
    }
    -> Program () Model Msg
generateCustom props =
    Browser.application
        { init = init <| List.map (toValidDocs props.toHtml) props.docs
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = OnUrlChange
        , onUrlRequest = OnUrlRequest
        }
