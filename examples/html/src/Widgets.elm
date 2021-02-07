module Widgets exposing (..)

import Helpers exposing (UIChapterCustom)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import UIBook exposing (chapter, updateStateWith, withStatefulSection)


type alias Model =
    { value : String
    , disabled : Bool
    }


init : Model
init =
    { value = ""
    , disabled = False
    }


type Msg
    = SetValue String
    | ToggleDisabled


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetValue value ->
            { model | value = value }

        ToggleDisabled ->
            { model | disabled = not model.disabled }


view : Model -> Html Msg
view model =
    div []
        [ input
            [ onInput SetValue
            , placeholder "Type something"
            , value model.value
            , disabled model.disabled
            ]
            []
        , button [ onClick ToggleDisabled ] [ text "toggle disabled" ]
        ]


inputChapter : UIChapterCustom { x | input : Model }
inputChapter =
    chapter "Button"
        |> withStatefulSection
            (\{ input } ->
                view input
                    |> Html.map
                        (updateStateWith
                            (\msg state ->
                                { state | input = update msg state.input }
                            )
                        )
            )
