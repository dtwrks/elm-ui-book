module UIBook.UI.Docs.Nav exposing (..)

import UIBook exposing (chapter, themeBackground, withBackgroundColor, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Nav exposing (view)


docs : UIChapter x
docs =
    let
        itemGroup index =
            ( ""
            , [ ( String.fromInt index ++ "-first-slug", "First" )
              , ( String.fromInt index ++ "-second-slug", "Second" )
              ]
            )

        props =
            { preffix = "x"
            , active = Nothing
            , preSelected = Nothing
            , itemGroups = List.singleton (itemGroup 0)
            }

        activeProps =
            { props | active = Just "0-first-slug" }
    in
    chapter "Nav"
        |> withBackgroundColor themeBackground
        |> withSections
            [ ( "Default", view props )
            , ( "Selected", view activeProps )
            , ( "Selected + Pre-selected", view { activeProps | preSelected = Just "0-second-slug" } )
            , ( "With groups"
              , view
                    { activeProps
                        | itemGroups =
                            List.range 0 3
                                |> List.map itemGroup
                                |> List.map (Tuple.mapFirst (\_ -> "Group Name"))
                    }
              )
            , ( "With unnamed groups"
              , view
                    { activeProps
                        | itemGroups =
                            List.range 0 3
                                |> List.map itemGroup
                                |> List.indexedMap
                                    (\index ( _, xs ) ->
                                        ( if index == 0 then
                                            ""

                                          else
                                            "Group Name"
                                        , xs
                                        )
                                    )
                    }
              )
            ]
