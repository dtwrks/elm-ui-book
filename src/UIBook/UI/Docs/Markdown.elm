module UIBook.UI.Docs.Markdown exposing (..)

import UIBook exposing (chapter, withDescription, withSections, withTwoColumns)
import UIBook.ElmCSS exposing (UIChapter)
import UIBook.UI.Markdown


docs : UIChapter x
docs =
    chapter "Markdown"
        |> withTwoColumns
        |> withSections
            [ ( "Headings + Body"
              , UIBook.UI.Markdown.view """
# Heading 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

## Heading 2

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

### Heading 3

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

---

#### Heading 4

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

##### Heading 5

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

###### Heading 6

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                """
              )
            , ( "Images, Quotes and CodeBlocks"
              , UIBook.UI.Markdown.view """
# Heading 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

![image](https://source.unsplash.com/WLUHO9A_xik/1600x900)

Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

> Lorem ipsum dolor sit amet, consectetur adipiscing elit, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Lorem ipsum dolor sit amet, `consectetur adipiscing elit`, [sed do eiusmod](http://xxx.xxx) tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

    view : String -> Html msg
    view content =
        UIBook.UI.Markdown.view content
"""
              )
            , ( "Lists and Tables"
              , UIBook.UI.Markdown.view """
# Heading 1

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

* Lorem ipsum dolor sit amet, consectetur adipiscing elit.
* Lorem ipsum dolor sit amet, consectetur adipiscing elit.
* Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.

1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
1. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

| Característica da contratação e aquisição                 | Divulgação                                     | Método de seleção                                                                                   |
| --------------------------------------------------------- | ---------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Consultoria (serviços de baixa complexidade)              | Trabalhe Conosco (site do Idec) e de parceiros | Contratação simplificada de consultoria pessoa jurídica ou contratação de consultor individual (PF) |
| Consultoria (equipe multidisciplinar, serviços complexos) | Trabalhe Conosco (site do Idec) e de parceiros | Contratação de pessoa jurídica – Qualidade e preço                                                  |
| Bens de produção contínua                                 | Carta convite, pesquisa em sites               | Compra direta                                                                                       |
|                                                           | Carta convite, pesquisa em sites               | Comparação de preços e qualidade de pelo menos 3 fornecedores qualificados                          |
| Bens sob encomenda                                        | Carta convite, pesquisa em sites               | Compra direta                                                                                       |
|                                                           | Carta convite, pesquisa em sites               | Comparação de preços e qualidade de pelo menos 3 fornecedores qualificados                          |
| Serviços de natureza continuada                           | Carta convite, pesquisa em sites               | Contratação direta                                                                                  |
|                                                           | Carta convite, pesquisa em sites               | Comparação de preços e qualidade de pelo menos 3 fornecedores qualificados                          |

"""
              )
            ]
