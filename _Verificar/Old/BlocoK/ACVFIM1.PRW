#include "rwmake.ch"

User Function ACVFIM1()

SetPrvt("_cProduto, _cLocal, _nQtd, _nCusto")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ACQFIM   ³ Autor ³ Carlos Nemesio Puerta ³ Data ³ 21/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera movimentacoes no SD3 para nao deixar saldo negativo   ³±±
±±³          ³ no final do periodo (fechamento)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaEst - Especifico AutoLife                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

@ 96,042 TO 323,505 DIALOG oDlg5 TITLE "Gera movimentações de estoque"
@ 08,010 TO 084,222
@ 91,168 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 23,014 SAY "Gera movimentações de estoque - SD3"
@ 33,014 SAY " "
@ 43,014 SAY "Este programa tem o objetivo de gerar movimentacoes de estoque ( SD3 ), para "
@ 53,014 SAY "nao deixar saldo negativo no final do periodo com base em recalculo do custo "
@ 63,014 SAY "medio ja executado ( B2_VFIM1 )...."
ACTIVATE DIALOG oDlg5
return

Static Function OkProc()
Close(oDlg5)
Processa( {|| RunProc() } )
Return

Static Function RunProc()
_cProduto := Space(15)
_cLocal   := Space(02)
_nQtd     := 0.00
_nCusto   := 0.00
_nCustd   := 0.00
_dData    := dDataBase

dbSelectArea("SB2")
dbSetOrder(1)               //  Filial+Cod
dbSeek(xFilial("SB2"),.T.)
ProcRegua(LastRec())

Do While !Eof() .And. SB2->B2_FILIAL == xFilial("SB2")
	
	IncProc("SB2 - Produto "+_cProduto)

	If SB2->B2_VFIM1 >= 0.00
		dbSkip()
		Loop
	EndIf

    _nQtd     := 0.00
	_cProduto := SB2->B2_COD
	_cLocal   := SB2->B2_LOCAL
    _nCusto   := SB2->B2_VFIM1 * -1

	dbSelectArea("SB1")
	dbSetOrder(1)               //  Filial+Cod+Local+Dtos(Data)
	If !dbSeek(xFilial("SB1")+_cProduto,.T.)
	    Alert("Produto nao encontrado no cadastro do produto SB1...")
	    dbSelectArea("SB2")
	    dbSkip()
	    Loop
	EndIf

	dbSelectArea("SD3")
	RecLock("SD3",.T.)
	SD3->D3_FILIAL  := xFilial("SD3")
	SD3->D3_TM      := "007"
	SD3->D3_COD     := _cProduto
	SD3->D3_UM      := GetAdvFval("SB1","B1_UM",xFilial("SB1")+_cProduto,1," ")
	SD3->D3_QUANT   := _nQtd
	SD3->D3_LOCAL   := _cLocal
	SD3->D3_DOC     := "AE"+Substr(Dtoc(dDataBase),4,2)+Substr(Dtoc(dDataBase),7,2)
	SD3->D3_GRUPO   := GetAdvFval("SB1","B1_GRUPO",xFilial("SB1")+_cProduto,1," ")
	SD3->D3_EMISSAO := dDataBase
	SD3->D3_CUSTO1  := _nCusto
	SD3->D3_NUMSEQ  := ProxNum()
	SD3->D3_CF      := "DE6"
	SD3->D3_TIPO    := GetAdvFval("SB1","SB1->B1_TIPO",xFilial("SB1")+_cProduto,1," ")
	SD3->D3_USUARIO := AllTrim(SubStr(cUsuario,7,15))
	SD3->D3_CHAVE   := "E0"
	SD3->D3_STSERV  := "1"
	SD3->D3_GARANTI := "N"
	SD3->D3_OBS     := "AC.SALDO "+Dtoc(dDataBase)
	MsUnlock()

	dbSelectArea("SB2")
	dbSkip()
EndDo
Return