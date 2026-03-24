#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#Include "FWMVCDef.CH"

/*/{Protheus.doc} MT410TOK 
Interface customizada para registro de eventos
e datas prévias que farão a geração dos títulos referentes ao pagamento do projeto. 
@type function 
@version 12.1.2410 
@author Gildeir Pereira - gildeir.pereira@totvs.com.br 
@since 03/10/2025 /*/ 

User Function MT410TOK()
	Local lRet := .T.
	Local aArea := GetArea()
	Local nOpc := PARAMIXB[1] //2-Visualização, 3-Inclusão, 4-Alteração
	Local cCondPag := GetMv("MV_XCNDPAG") // Condição de pagamento parametrizada
	Private cNPedZ03 := M->C5_NUM // Número do pedido
	Private cNameUser := UsrRetName(RetCodUsr())
	Private nParc := "0"
	Public __XaParcPed := {}

	If nOpc == 3 .or. nOpc == 4
		If M->C5_CONDPAG = cCondPag // Só executa se for a condição definida
			U_GCVNPARC()
		EndIf
	Endif
	
	RestArea(aArea)

Return lRet

