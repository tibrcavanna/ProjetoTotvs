#Include 'Protheus.ch'

User Function COMCOLSD()

    Local ExpA1 := PARAMIXB[1]
    Local ExpA2 := PARAMIXB[2]

    
    //U_COMA001()
    
    // Validações do usuário 
    SDT->(dBSetOrder(1))
    /*
    If SDT->(MsSeek(xFilial("SDT")+SDS->DS_CNPJ+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE))
        While SDS->DS_CNPJ == SDT->DT_CNPJ .And. SDS->DS_FORNEC == SDT->DT_FORNEC .And. SDS->DS_LOJA == SDT->DT_LOJA .And. SDS->DS_DOC == SDT->DT_DOC
            If !Empty(SDT->DT_PEDIDO)
                RecLock("SDT",.F.)
                    SDT->DT_CFOP := 'N'
                MsUnLock()
            EndIF
            SDT-> (DbSkip())
        End
    EndIf
    */
Return
