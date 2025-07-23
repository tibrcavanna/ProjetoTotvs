#Include 'Protheus.ch'
#include 'topconn.ch'
#include 'totvs.ch'

#Define ENTER  Chr(10) + Chr (13) // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)

User Function COMXPROC()

    Local _aArea    := GetArea()
    Local _cQry     := ""
    Local cArquivo  := "E:\TOTVS12\protheus_data\SQL\"
    Local _lRet     := .T.
    Local cFornec   := SDS->DS_FORNEC
    Local cDoc      := SDS->DS_DOC
    Local cVerPreNF := SuperGetMV("MV_XVERNFL",,.F.)

    If cVerPreNF
        _cQry += " SELECT " + ENTER
        _cQry += " Data_Inserimento_Ordine, " + ENTER
        _cQry += " Nr_Ordine, " + ENTER
        _cQry += " Riga_Ordine, " + ENTER
        _cQry += " Articolo, " + ENTER
        _cQry += " Desc_Articolo, " + ENTER
        _cQry += " BP, " + ENTER
        _cQry += " BusinessPartner, " + ENTER
        _cQry += " Nr_Ricevimento, " + ENTER
        _cQry += " Nr_DocTrasposto" + ENTER
        _cQry += " FROM " + ENTER
        //_cQry += " erpdb.dbo.Analisi_ODA_CPM_104 " + ENTER
        _cQry += " Analisi_ODA_CPM_104 " + ENTER
        _cQry += " WHERE SUBSTRING(BP,3,6) = '" + cFornec           + "'" + ENTER
        _cQry += "   AND Nr_DocTrasposto = '" + CVALTOCHAR(VAL(cDoc))+ "'" + ENTER

        MemoWrite(cArquivo + "COMXPROC.sql", _cQry)

        If Select("WORK") > 0
            WORK->(dbCloseArea())
        EndIf 

        DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, _cQry) , "WORK" , .T. , .T. )
        
        If Empty(WORK->Nr_DocTrasposto) .OR. Empty(WORK->Nr_Ricevimento)
            _lRet := .F.
        EndIf
    
    EndIf
    
    RestArea(_aArea)

RETURN _lRet
