module UIBook.Widgets.Docs.Wrapper exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import UIBook exposing (chapter, withSections)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.Widgets.Docs.Helpers exposing (mockBlock, mockList)
import UIBook.Widgets.Wrapper exposing (view)


docs : UIChapter x
docs =
    let
        props =
            { color = "#006fab"
            , isMenuOpen = False
            , header = mockBlock False
            , menuHeader = mockBlock False
            , menu = mockList "#5ab9ed"
            , menuFooter = mockBlock False
            , mainHeader = mockBlock True
            , main = mockList "#2c9fde"
            , mainFooter = mockBlock False
            , modal = Nothing
            , onCloseModal = UIBook.logAction "onCloseModal"
            }

        wrapper child =
            div [ css [ Css.height (px 400), fontFamily sansSerif ] ] [ child ]
    in
    chapter "Wrapper"
        |> withSections
            [ ( "Default"
              , wrapper (view props)
              )
            , ( "Opened Menu (Mobile)"
              , wrapper (view { props | isMenuOpen = True })
              )
            , ( "With Modal"
              , wrapper (view { props | modal = Just mockModalContent })
              )
            ]


mockModalContent : Html msg
mockModalContent =
    div
        [ css
            [ Css.width (px 400)
            ]
        ]
        [ mockList "#006fab" ]
