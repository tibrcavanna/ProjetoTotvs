#include "protheus.ch"
// Por : Luis Henrique - Leste System
// Em  : 27 / 12 / 2013
// Objetivo :  Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. 
//             O registro no SD1 já se encontra travado (Lock). Será executado uma vez para cada item do Documento de Entrada 
//             que está sendo incluída.
//             
//             Ponto de entrada utilizado para replicar os dados da tabela SD1 na tabela SZ3 de mesma estrutura
// - Integrado com ponto de entrada SD1100I
// - Wederson Santana - 17/01/2020
// - Ajuste pesquisa próximo número, campo D1_SEQLN
// - Thiago (Rahro) - 23/01/2023 - Alteração para corrigir o sequencial do D1_SEQLN

User Function CAEST002()
	Local aAreaUso  := GetArea()
	Local cSeqLN    := GetNextNum()
	Local aCampoSz3 := {}
	Local cCampoSz3 := ""
	Local cCampoSd1 := ""
	Local nX

	dbSelectArea("SX3")
	SX3->(dbSetOrder(1))
	If SX3->(dbSeek("SZ3"))
		While ! SX3->(Eof()) .and. SX3->X3_ARQUIVO == "SZ3"
			aadd(aCampoSz3,{SX3->X3_CAMPO})
			SX3->(dbSkip())
		End

		dbSelectArea("SZ3")
		RecLock("SZ3",.T.)
		For nX:=1 To Len(aCampoSz3)
			If! Empty(aCampoSz3[nX][1])
				cCampoSd1 := "D1_"+Alltrim(SubStr(aCampoSz3[nX][1],4,7))
				cCampoSz3 := alltrim(aCampoSz3[nX][1])
				If SD1->( FieldPos(cCampoSd1) ) > 0
					If SZ3->( FieldPos(cCampoSz3) ) > 0
						If! Empty(SD1->(&cCampoSd1))
							SZ3->&cCampoSz3:=SD1->&cCampoSd1
						EndIf
					EndIf
				EndIf
			EndIf
		Next

		SZ3->Z3_SEQLN := cSeqLN
		SZ3->(MsUnLock())

	EndIf

	RecLock("SD1",.F.)
	SD1->D1_SEQLN := cSeqLN
	SD1->(MsUnLock())

	SD1->(ConfirmSX8())


	RestArea(aAreaUso)
Return

/*/==============================================================================
{Protheus.doc} GetNextNum
//TODO Retorna o próximo numero D1_SEQLN
@author thiago.reis
@since 23/01/2023
@version 1.0
@type function
==============================================================================/*/
Static Function GetNextNum()

	Local _aAreaSD1 := SD1->(GetArea())
	Local _cRet		:= ""

	//Variavel Public de Controle do GetSxeNum
	nSaveSX8			:= 0

	_cRet := GetSxeNum("SD1","D1_SEQLN")

	SD1->(dbOrderNickName("D1_SEQLN"))
	While SD1->(dbSeek(xFilial("SD1")+_cRet))

		if ( __lSx8 ) //Variavel Public de Controle do GetSxeNum
			SD1->(ConfirmSX8())
		endif

		_cRet := GetSxeNum("SD1","D1_SEQLN")

	end
	
	RestArea(_aAreaSD1)

Return (_cRet)
