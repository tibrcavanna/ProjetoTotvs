#include "TOPCONN.CH"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
//
// Programa		ATUB1NCM.PRW
// Autor		Carlos N. Puerta
// Data			21/12/2018
// Descricao	Programa para atualizar o campo B1_POSIPI, B1_ALIQISS e B1_CODISS
// Uso			Especifico CAVANA
//
User Function ATUB1NCM()

Private _cCadastro := "Atualizar B1_POSIPI, B1_ALIQISS e B1_CODISS (SB1)"

@ 000,000 TO 140,460 DIALOG oDlg2 TITLE _cCadastro
@ 012,012 SAY " Atualiza B1_POSIPI e B1_CODISS(SB1)."
@ 024,012 SAY " "
@ 036,012 SAY " O arquivo deve ser obrigatoriamente B1POSIPI.DTC "
@ 026,200 BMPBUTTON TYPE 1 ACTION _AtualizaSB1()
@ 040,200 BMPBUTTON TYPE 2 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2 CENTERED
Return

Static Function _AtualizaSB1()
Processa( {|| OkProc() } , "Processando atualização..." )
Close(oDlg2)
Return

Static Function OkProc()

OpenDTC("B1POSIPI")

dbSelectArea("TSB1")
dbGoTop()

Do While !Eof()
    dbSelectArea("SB1")
    dbSetOrder(1)             // B1_FILIAL+B1_COD
    If dbSeek(xFilial("SB1")+TSB1->PRODUTO)
        RecLock("SB1",.F.)
        SB1->B1_POSIPI  := Substr(AllTrim(TSB1->NEWPOSIPI),1,08)   // Substr(TSB1->POSIPI_NCM,1,04)+Substr(TSB1->POSIPI_NCM,6,02)+Substr(TSB1->POSIPI_NCM,9,02)
//      If SB1->B1_IPI == 0
            SB1->B1_IPI := GETADVFVAL("SYD","YD_PER_II",XFILIAL("SYD")+Substr(AllTrim(TSB1->NEWPOSIPI),1,08),1,0.00)
//      EndIf
        SB1->B1_ALIQISS := TSB1->NEWALIQISS
        SB1->B1_CODISS  := AllTrim(TSB1->NEWCSERISS)
        MsUnLock()
    Else
        Alert("Produto "+TSB1->PRODUTO+" Nao encontrado no Protheus...")
    EndIf

    dbSelectArea("TSB1")
    dbSkip()
EndDo

dbSelectArea("TSB1")
dbCloseArea()
MsGBox("Cadastro Atualizado com sucesso!","Fim","INFO")
Return

Static Function OpenDTC(_cNomArq)
Local _cArqInd := CriaTrab(NIL,.f.)
dbusearea(.T.,,"\Importacoes\"+_cNomArq,"TSB1",.T.,.F.)
dbcreateindex( _cArqInd , "PRODUTO", {|| PRODUTO } )
Return