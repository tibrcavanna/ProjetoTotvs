#include "TOPCONN.CH"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
//
// Programa		VERB1NCM.PRW
// Autor		Carlos N. Puerta
// Data			07/01/2019
// Descricao	Programa para VERIFICAR o campo B1_POSIPI e tabela SYD
// Uso			Especifico CAVANA
//
User Function VERB1NCM()

Private _cCadastro := "Verifica B1_POSIPI x SYD"

@ 000,000 TO 140,460 DIALOG oDlg2 TITLE _cCadastro
@ 012,012 SAY " Verifica B1_POSIPI x SYD"
@ 024,012 SAY " "
@ 036,012 SAY " "
@ 026,200 BMPBUTTON TYPE 1 ACTION _VerificaSB1()
@ 040,200 BMPBUTTON TYPE 2 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2 CENTERED
Return

Static Function _VerificaSB1()
Processa( {|| OkProc() } , "Processando atualização..." )
Close(oDlg2)
Return

Static Function OkProc()
Private _cProduto := Space(15)
Private _cPosIPI  := Space(10)
Private _aTexto   := {}
Private _cTexto   := " "
Private _cLinha   := " "
Private _nCont    := 0

_cTexto := "Produto"+";"+"Descricao"+";"+"B1POSIPI"+";"+"B1.POS.IPI"+";"+"NOVO"
IncTexto(_cTexto)

OpenDTC("NCMSATI")

dbSelectArea("TNCM")
dbGoTop()

dbSelectArea("SB1")
dbSetOrder(1)
dbGoTop()
ProcRegua(Reccount())    // Numero de registros a processar

Do While !Eof()
    If _nCont > 5000
        Exit
    EndIf

    _cProduto := SB1->B1_COD
    _cPosIPI  := SB1->B1_POSIPI
    _cPosIPI1 := Substr(SB1->B1_POSIPI,1,4)+"."+Substr(SB1->B1_POSIPI,5,2)+"."+Substr(SB1->B1_POSIPI,7,2)

    IncProc("Aguarde Processando... Produto: "+SB1->B1_COD)
    
    If Empty(SB1->B1_POSIPI)
        dbSkip()
        Loop
    EndIf

    dbSelectArea("SYD")
    dbSetOrder(1)             // YD_FILIAL+YD_TEC+YD_EX_NCM+YD_EX_NBM+YD_DESTAQU
    If !(dbSeek(xFilial("SYD")+_cPosIPI))
        _nCont++
        dbSelectArea("TNCM")
        If !(dbSeek(_cPosIPI1))
            _cTexto := "'"+SB1->B1_COD+";"+SB1->B1_DESC+";"+SB1->B1_POSIPI+";"+Substr(SB1->B1_POSIPI,1,4)+"."+Substr(SB1->B1_POSIPI,5,2)+"."+Substr(SB1->B1_POSIPI,7,2)+";"+"EOF"
            IncTexto(_cTexto)
        Else
            _cTexto := "'"+SB1->B1_COD+";"+SB1->B1_DESC+";"+SB1->B1_POSIPI+";"+Substr(SB1->B1_POSIPI,1,4)+"."+Substr(SB1->B1_POSIPI,5,2)+"."+Substr(SB1->B1_POSIPI,7,2)+";"+"NOVO"
            IncTexto(_cTexto)
        EndIf
    EndIf

    dbSelectArea("SB1")
    dbSkip()
EndDo
GeraTXT()
dbSelectArea("TNCM")
dbCloseArea()
MsGBox("Cadastro Verificado com sucesso! Contador: "+Str(_nCont),"Fim","INFO")
Return

Static Function IncTexto(_cTexto)
aAdd(_aTexto,_cTexto)
Return

Static Function GeraTXT()
Private _cTexto  := Space(01)
Private _cArqLog := ""
Private _nI

For _nI := 1  To  Len(_aTexto)
	_cTexto += _aTexto[_nI] + CHR(13) + CHR(10)
Next

_cNome1  := Dtoc(dDataBase)
_cNome2  := Time()
_cArqLog := "C:\RELATO\SB1_SEM_SYD.CSV"
MEMOWRIT(_cArqLog,_cTexto)
Return _cArqLog
//
//
Static Function OpenDTC(_cNomArq)
Local _cArqInd := CriaTrab(NIL,.f.)
dbusearea(.T.,,"\TMP_CNP\"+_cNomArq,"TNCM",.T.,.F.)
dbcreateindex( _cArqInd , "NCM", {|| NCM } )
Return