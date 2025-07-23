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

User Function CAEST002()
	Local aAreaUso  := GetArea() 
	Local nSaveSX8  := GetSX8Len()      
	Local cSeqLN    := ""
	Local aCampoSz3 := {}
	Local cCampoSz3 := "" 
	Local cCampoSd1 := ""
	Local _nSD1Rec  := SD1->(Recno())
	Local nX

	//________________________________________  GERA SEQUENCIAL EM D1_SEQLN                      
	/*While .t.

	_cSeqLN := getsxenum("SD1","D1_SEQLN")
	ConfirmSx8()
	alert(_cSeqLN)
	SD1->(dbOrderNickName("D1_SEQLN"))
	If ! SD1->(dbSeek(xfilial("SD1")+_cSeqLN)) 
	exit
	Endif		

	End                                
	_cSeqLN := getsxenum("SD1","D1_SEQLN")
	ConfirmSx8()
	*/
	cSeqLN := GetSx8Num('SD1','D1_SEQLN')
	If __lSX8 
		While (GetSX8Len() > nSaveSX8)
			ConfirmSX8()
		End
	Else
		RollBackSX8()
	EndIf

	SD1->(dbGoto(_nSD1Rec))
	SD1->D1_SEQLN := cSeqLN
	//________________________________________                       

	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek("SZ3")
		While ! SX3->(Eof()) .and. SX3->X3_ARQUIVO == "SZ3"
			aadd(aCampoSz3,{SX3->X3_CAMPO})
			dbSkip()
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
		MsUnLock()

	EndIf
   	RestArea(aAreaUso)
Return


