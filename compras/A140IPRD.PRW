#Include 'Protheus.ch'
#include 'topconn.ch'
#include 'totvs.ch'
#INCLUDE "XMLXFUN.CH"

#Define ENTER  Chr (13) + Chr(10) // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)

User Function A140IPRD() 

    Local cFornec   := PARAMIXB[1]
    Local cLoja     := PARAMIXB[2]
    Local cNewPRD   := PARAMIXB[3]
    Local oDetItem  := PARAMIXB[4] 
    Local _aArea    := GetArea()
    Local _cPedCom  := ""
    Local _nitemPed := ""
    Local _cNcm     := ""
    Local _cQry     := ""
    Local cArquivo  := "E:\TOTVS12\protheus_data\SQL\"
    Local cError    := ""
    Local cWarning  := ""
    Local oXml      := NIL

    //Gera o Objeto XML
    If !Empty(CKO->CKO_XMLRET)
        oXml := XmlParser( CKO->CKO_XMLRET, "_", @cError, @cWarning )
        If (oXml == NIL )
            ConOut("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
        Endif
    Endif
        
    If AttIsMemberOf(oDetItem:_PROD,"_XPED") 
        _cPedCom  := oDetItem:_PROD:_XPED:TEXT
        _cPedCom  := Replace(_cPedCom,"'","")
    EndIf

    If AttIsMemberOf(oDetItem:_PROD,"_nItemped") 
        _nitemPed := oDetItem:_PROD:_nItemped:TEXT
    EndIf

    If AttIsMemberOf(oDetItem:_PROD,"_NCM") 
        _cNcm := alltrim(oDetItem:_PROD:_NCM:TEXT)
    EndIf

    If ! Empty(_cPedCom)
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
        _cQry += " WHERE SUBSTRING(BP,3,6) = '" + cFornec   + "'" + ENTER
        _cQry += "   AND Nr_Ordine LIKE '%"   + _cPedCom  + "%'" + ENTER
        If !Empty(_nitemPed)
            _cQry += " AND Riga_Ordine = '" +_nitemPed + "'" + ENTER
        EndIf

        MemoWrite(cArquivo + "A140IPRD.sql", _cQry)

        If Select("PEDCOM") > 0
            PEDCOM->(DbCloseArea())
        EndIf

        DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, _cQry) , "PEDCOM" , .T. , .T. )
            
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
        if SB1->(dbSeek(xfilial("SB1") + alltrim(PEDCOM->Articolo)))

            If AttIsMemberOf(oDetItem:_PROD,"_NCM")
                If Empty(SB1->B1_POSIPI) .Or. AllTrim(SB1->B1_POSIPI) <> AllTrim(_cNcm)
                    Reclock("SB1",.F.)
                        SB1->B1_POSIPI := _cNcm // Alimento o NCM do Produto.
                    SB1->(MsUnlock())
                EndIf
            EndIf

            If AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS00")
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS00:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS10")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS10:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf 
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS20")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS20:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf 
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS30")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS30:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf 
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS40")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS40:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf 
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS41")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS41:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf 
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS50")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS50:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf  
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS51")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS51:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf    
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS60")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS60:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf     
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS70")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS70:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf  
            ElseIf AttIsMemberOf(oDetItem:_IMPOSTO:_ICMS,"_ICMS90")   
                If Empty(SB1->B1_ORIGEM)	
                    Reclock("SB1",.F.)
                        SB1->B1_ORIGEM := alltrim(oDetItem:_IMPOSTO:_ICMS:_ICMS90:_ORIG:TEXT) // Alimento a origem do Produto.
                    SB1->(MsUnlock())
                EndIf           
            EndIf
    
        Endif
        If !Empty(alltrim(PEDCOM->Articolo))
            U_COMA01(cFornec,cLoja,alltrim(PEDCOM->Articolo),cNewPRD,_cNcm)   // Realizo amarração Produto x Fornecedor. 
        Else
            ConOut("Não encontrou o produto na tabela ODA, verificar...")    
        EndIf
        DbCloseArea()
    Else
        ConOut("Não executou o PE A140PRD...")
    EndIf

    RestArea(_aArea)

Return 
