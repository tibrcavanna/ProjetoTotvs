#Include "Totvs.ch"
/*/
{Protheus.doc} A410CONS
� chamada no momento de montar a enchoicebar do pedido de vendas, e serve para incluir mais bot�es com rotinas de usu�rio.
@type  Function
@author Rafael Mattiuzzo
@since 24/01/2023
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6784033
/*/
User Function A410CONS

	Local aButton := {}

	aAdd(aButton,{"S4WB005N",{|| U_ImpItmPv() },"Importacao de Itens","Importar"} )


Return( aButton )
