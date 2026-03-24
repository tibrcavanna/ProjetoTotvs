#INCLUDE 'Totvs.ch'

/*/{Protheus.doc} PECOM05
description
@type function
@version  
@author gabal
@since 2/9/2026
@return variant, return_description
/*/
User Function PECOM05()
    Local aAreaE2 := SE2->(FwGetArea())

    dbselectarea("SE2")
    SE2->( dbsetorder(6) )
    SE2->( DbGoTop() )
    SE2->( DbSeek( SD1->D1_FILIAL + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_SERIE + SD1->D1_DOC ) )

    Begin Transaction
    while !SE2->( Eof() ) .AND. (SE2->E2_NUM==SD1->D1_DOC .AND. SE2->E2_PREFIXO==SD1->D1_SERIE .AND. SE2->E2_FORNECE==SD1->D1_FORNECE .AND. SE2->E2_LOJA==SD1->D1_LOJA)
        IF RecLock("SE2", .F.)
            SE2->E2_CLVL := 'F' + SD1->D1_FORNECE + SD1->D1_LOJA  // F+CodFornecedor+Loja
            SE2->(MsUnlock())
        ENDIF
        SE2->(DBSKIP())
    End
    End Transaction

    FwRestArea(aAreaE2)
Return
