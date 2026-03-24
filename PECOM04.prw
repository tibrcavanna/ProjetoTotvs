#Include 'Protheus.ch'

/*/{Protheus.doc} PECOM04
description
@type function
@version  
@author Gabriel Souza
@since 2/9/2026
@return variant, return_description
/*/
User Function PECOM04()
    Local aAreaD1 := SD1->(FwGetArea())

    dbselectarea("SD1")
    SD1->( dbsetorder(1) )
    SD1->( DbGoTop() )
    SD1->( DbSeek( CFILFIE + CNFISCAL + CSERIE + CA100FOR + CLOJA ) )

    Begin Transaction
    while !SD1->( Eof() ) .AND. (SD1->D1_DOC==CNFISCAL .AND. SD1->D1_SERIE==CSERIE .AND. SD1->D1_FORNECE==CA100FOR .AND. SD1->D1_LOJA==CLOJA)
        IF RecLock("SD1", .F.)
            SD1->D1_CLVL := 'F' + CA100FOR + CLOJA  // F+CodFornecedor+Loja
            SD1->(MsUnlock())
        ENDIF
        SD1->(DBSKIP())
    End
    End Transaction

    FwRestArea(aAreaD1)
Return
