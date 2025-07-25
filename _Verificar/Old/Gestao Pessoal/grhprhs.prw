#INCLUDE "RWMAKE.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#include "topconn.ch"
/**
* Gera RHP e RHS
**/
//**************************************************
User Function grhprhs()
	Private cPerg	:= "grhprhs"

	//criaSX1(cPerg)
	//If Pergunte(cPerg,.T.)		
		pGrhPrhs()
	//EndIf
Return
Static Function pGrhPrhs()

Local cQuery	:= ""
Local cErroLog	:= ""
Local dxtpag    := ctod("  /  /    ")
private lMsHelpAuto := .F.
private lMsErroAuto := .F.

//DbselectArea("RHP")
//RHP->( DbSetOrder( 1 ) )
//DbSeek(xFilial("RHP")+cEmpAnt+SPACE(06)) //space devido o campo ter 8 caracteres e s� � preenhido com 2

//FECHA A AREA TA TABELA TEMPORARIA DE CABECALHO
If SELECT("TBFAB")>0
	dbSelectArea("TBFAB")
	TBFAB->(dbCloseArea())
EndIf
//SELECIONA OS PEDIDOS QUE AINDA NAO FORAM PROCESSADOS
dbSelectarea("SRD")
SRD->(DbSetOrder(1))
cQuery := " "
cQuery += " SELECT RD_FILIAL,RD_MAT,RD_PD,RD_DATARQ,RD_DATPGT,RD_MES,RD_VALOR"
cQuery += "  FROM "
cQuery += RetSqlName("SRD")
cQuery += "   WHERE "
cQuery += "   RD_PD IN ('446','484','485') " 
cQuery += "   AND RD_DATARQ >= '201801' "
cQuery += "   AND RD_DATARQ <= '201812' " 
cQuery += "   AND D_E_L_E_T_ <> '*' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), "TBFAB", .F., .T. )

While TBFAB->(!Eof())

msgrun("Gerando Informa��es para DIRF, Aguarde !!!")
/*
DbselectArea("RHP")
RHP->( DbSetOrder( 1 ) )
DbSeek(xFilial("RHP")+TBFAB->RD_MAT)

Reclock("RHP",.T.)
RHP_FILIAL := TBFAB->RD_FILIAL
RHP_MAT := TBFAB->RD_MAT
RHP_DTOCOR := STOD(TBFAB->RD_DATPGT)
RHP_ORIGEM := '1'
RHP_CODIGO := ""
RHP_TPLAN := ''
RHP_TPFORN := '1'
RHP_CODFOR := '02'
RHP_TPPLAN := ''
RHP_PD := TBFAB->RD_PD
RHP_VLRFUN := TBFAB->RD_VALOR
RHP_VLREMP := 0
RHP_COMPPG := TBFAB->RD_DATARQ
RHP_DATPGT := STOD(TBFAB->RD_DATPGT)
RHP_DTHRGR := ""
MsUnlock()  
*/
DbselectArea("RHS")
RHS->( DbSetOrder( 1 ) )
DbSeek(xFilial("RHS")+TBFAB->RD_MAT)

Reclock("RHS",.T.)
RHS_FILIAL := TBFAB->RD_FILIAL
RHS_MAT := TBFAB->RD_MAT
RHS_DATA := STOD(TBFAB->RD_DATPGT)
RHS_ORIGEM := '1'
RHS_CODIGO := ""
RHS_TPLAN := '1'
RHS_TPFORN := '1'
RHS_CODFOR := '02'
RHS_TPPLAN := '1'
RHS_PLANO := "E1"
RHS_PD := TBFAB->RD_PD
RHS_VLRFUN := TBFAB->RD_VALOR
RHS_VLREMP := 0
RHS_COMPPG := TBFAB->RD_DATARQ
RHS_DATPGT := STOD(TBFAB->RD_DATPGT)
RHS_DTHRGR := ""
RHS_TIPO := ""
MsUnlock()  
	TBFAB->(dbSkip())
End
alert("Finalizado com Sucesso !!!")
Return
//Static Function criaSX1(cPerg)
//	putSx1(cPerg, '01', 'Da Data:' 		, '', '', 'mv_ch1' , 'C', 					    6, 0, 0, 'G', '',       '', '', '', 'mv_par01')
//	putSx1(cPerg, '02', 'At� Data:' 	, '', '', 'mv_ch2' , 'C', 					    6, 0, 0, 'G', '',       '', '', '', 'mv_par02')
//Return
