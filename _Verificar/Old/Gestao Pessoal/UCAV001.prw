#include "rwmake.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UCAV001  ºAutor  ³ Josinei L Sobreira º Data ³  11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ajustes no cadastro de verbas                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uso especifico CAVANNNA                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UCAV001()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg
Local cCadastro := "UCAV001 - Atualizações Cadastro de Verbas"
Local aSays     :={}, aButtons:={}
Local nOpca     := 0
Local aCA       :={"Confirma","Abandona"}

Private  nOpc    := 3
Private aGetArea := Getarea()
Private aLog     := {}

Public _cTxt := ''

AADD(aSays,"Este Programa tem por objetivo atualizar cadastro" )
AADD(aSays,"de verbas.                                       " )
AADD(aSays," " )
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, If(cA23Ok(), o:oWnd:End(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( cCadastro, aSays, aButtons )
If nOpca == 1
	Processa( { |lEnd| _ProcSRV() } )
EndIf

RestArea(aGetArea)

MsgInfo("Processo concluido com sucesso...")

Return(.T.)

////////////////////////	
Static Function cA23Ok()
////////////////////////
Return (MsgYesNo("Confirma Processamento?"))
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ _ProcSRV  ºAutor  ³ Josinei L Sobreira º Data ³ 11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa rotina para atualização do Cadastro de Verbas     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Uso especifico CAVANNA                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function _ProcSRV()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _cCodDEB1 := Criavar("RV_DEB1")
Local _cCodDEB2 := Criavar("RV_DEB2") 
Local _cCodDEB3 := Criavar("RV_DEB3")
Local _cCodDEB4 := Criavar("RV_DEB4")

Local _cCodCRD1 := Criavar("RV_CRED1")
Local _cCodCRD2 := Criavar("RV_CRED2")
Local _cCodCRD3 := Criavar("RV_CRED3")
Local _cCodCRD4 := Criavar("RV_CRED4")

dbUseArea(.t.,,"SRV010M.DBF","SRVTRB",.t.,.t.)
cIndex := CriaTrab(Nil, .F.)
IndRegua("SRVTRB", cIndex, "RV_FILIAL + RV_COD", , , "Selecionando Registros...")
cIndex := CriaTrab(Nil, .F.)
DbGoTop()

DbSelectArea("SRVTRB")
DbGoTop()
ProcRegua(SRVTRB->(RecCount()))

While SRVTRB->(!Eof())
	IncProc('Processando...')
	_cCODVERBA := SRVTRB->RV_COD

	_cCodDEB1 := SRVTRB->RV_DEB1
	_cCodDEB2 := SRVTRB->RV_DEB2
	_cCodDEB3 := SRVTRB->RV_DEB3
	_cCodDEB4 := SRVTRB->RV_DEB4
	
	_cCodCRD1 := SRVTRB->RV_CRED1
	_cCodCRD2 := SRVTRB->RV_CRED2
	_cCodCRD3 := SRVTRB->RV_CRED3
	_cCodCRD4 := SRVTRB->RV_CRED4

	_cAlias := Alias()
	_nOrder := IndexOrd()
	_nRecno := Recno()

	DbSelectArea("SRV")
	DbSetOrder(1)
	DbGoTop()
	
	If SRV->(DbSeek(xFilial() + _cCODVERBA))
		RecLock("SRV",.F.)
		SRV->RV_DEB1 := _cCodDEB1
		SRV->RV_DEB2 := _cCodDEB2
		SRV->RV_DEB3 := _cCodDEB3
		SRV->RV_DEB4 := _cCodDEB4

		SRV->RV_CRED1 := 	_cCodCRD1
		SRV->RV_CRED2 := 	_cCodCRD2
		SRV->RV_CRED3 := 	_cCodCRD3
		SRV->RV_CRED4 := 	_cCodCRD4

		SRV->(MsUnLock())
		SRV->(DbCommit())	
	EndIf

	DbSelectArea(_cAlias)
	DbSetOrder(_nOrder)
	DbGoTo(_nRecno)

	SRVTRB->(DbSkip())

EndDo
Return()