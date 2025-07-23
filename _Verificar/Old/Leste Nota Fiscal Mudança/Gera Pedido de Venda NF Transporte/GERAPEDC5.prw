#INCLUDE "REPORT.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "RWMAKE.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "ParmType.ch"

/*/

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BOLEBRAD ³ Autor ³ xxxxxxxxxxxxx         ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER   BRADESCO COM CODIGO DE BARRAS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ xxxxxx                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function GERAPEDC5()
LOCAL   aCampos := {{"B2_COD","Produto","@!"},{"B2_DESC","Descrição","@!"},{"B2_QATU1","Quantidade","@9"},{"B2_VATU1","Vlr. Unitário","@E 9,999,999.99"}}
LOCAL   nOpc       := 0
LOCAL   aDesc      := {"","",""}
Local aSays     	:= {}, aButtons := {}, nOpca := 0

PRIVATE Exec       := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''
PRIVATE cMarca     := GetMark()

Private nomeprog 	:= "GERAPEDC5"

Private nLastKey 	:= 0
Private cPerg
Private oPrint

Public aMarked    := {}
Tamanho  := "M"
titulo   := " "
cDesc1   := " "
cDesc2   := ""
cDesc3   := ""
cString  := "ESTOQUE"
wnrel    := " "
lEnd     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPerg    :="TIRAFLAG"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


AjustaSX1()

If Pergunte(cPerg,.T. )           
dbSelectArea("ESTOQUE")

	cQuery := "B2_COD           >= '" + MV_PAR01 + "' .And. B2_COD <= '" + MV_PAR02 + "'"
	
	cArqTrab := CriaTrab("",.F.)
	IndRegua(cString,cArqTrab,"PA1_COD,PA1_ENDERE",,cQuery,"Selecionado Registros...")
	nIndD2 := RetIndex("ESTOQUE")
	If RDDNAME() != "TOPCONN"
		dbSetIndex(cArqTrab+ordBagExt())
	ENDIF
	dbSelectArea("ESTOQUE")
	SE1->(dbGoTop())
	If mv_par11 = 1
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Produtos"
		@ 001,001 TO 170,350 BROWSE "PA1" MARK "PA1_OK"
		@ 180,310 BMPBUTTON TYPE 01 ACTION (Exec := .T.,Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (Exec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED
	Else
		Exec       := .T.
	EndIf
	dbGoTop()
	Do While !Eof()
		If mv_par11 = 1
			If Marked("PA1_OK")
				AADD(aMarked,.T.)
			Else
				AADD(aMarked,.F.)
			EndIf
		Else
			AADD(aMarked,.T.)
		Endif
		dbSkip()
	EndDo
	dbGoTop()
	If Exec
		Processa({|lEnd|MontaTela(aMarked)})
	Endif
	RetIndex("PA1")
	fErase(cIndexName+OrdBagExt())
	fErase(cArqTrab+ordBagExt())
EndIf

Return Nil

******************************
Static Function MontaTela(aMarked)

LOCAL i         := 1
LOCAL nRec      := 0
Public n := 0

Processa({|lEnd| ApagaFlag()},Titulo)


Static Function ApagaFlag()


i:=1

nRec := 0
DbSelectArea("ESTOQUE")
dbGoTop()
Do While !EOF()
	nRec := nRec + 1
	dbSkip()
EndDo

dbGoTop()
ProcRegua(nRec)

Do While !EOF()
	If aMarked[i]
		If SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
			
			RecLock("SE1",.f.)
			SE1->E1_ENVSITE = ''
			MsUnlock()
			
		Endif      
		
		DbSelectArea("SF2")
		dbSetOrder(1)
		If SF2->(DbSeek(xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO))
		
			RecLock("SF2",.f.)
			SF2->F2_ENVFAT  := ''
		 	SF2->F2_ENV_ND  := ''
		   	SF2->F2_ENVSITE :=''
			MsUnlock()
			
		Endif
	
		n := n + 1
	EndIf
	DbSelectArea("SE1")
	dbSetOrder(1)
	dbSkip()
	IncProc("Processaondo Nota Fiscal "+SE1->E1_NUM)
	i := i + 1
EndDo

U_TLJOB01B()

Return nil

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³AjustaSX1 ³ Autor ³ Mary C. Hergert       ³ Data ³05/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria as perguntas necessarias a impressao do RPS            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local 	aAreaSX1 := SX1->(GetArea())

SX1->(dbSetOrder(1))

If SX1->(dbSeek("TIRAFLAG  01"))
	While ALLTRIM(SX1->X1_GRUPO) == "TIRAFLAG  "
		/*
		RecLock("SX1",.F.)
		SX1->X1_CNT01:= " "
		SX1->X1_CNT01:= " "
		SX1->X1_CNT01:= " "
		MsUnlock()
		*/
		SX1->(dbSkip())
	EndDo
	
Else
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o Produto Inicial")
	
	PutSX1("TIRAFLAG", "01","Do Produto ","","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par12", ;
	"","", "", "", "", "", "", "", "", "", "", "", "", "", "","",aHelpPor)
	aHelpPor := {}
	aAdd(aHelpPor,"Informe o Código do Produto Final ")
	PutSX1("TIRAFLAG", "02","Até o Produto ","","","mv_ch2","C",3,0,0,"G","","SB1","","","mv_par12", ;
	"","", "", "", "", "", "", "", "", "", "", "", "", "", "","",aHelpPor)
Endif
RestArea(aAreaSX1)
Return(.T.)


