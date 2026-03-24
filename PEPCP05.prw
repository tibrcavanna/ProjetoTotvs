#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} pa145ger
description 
O ponto de entrada PA145GER È executado ao finalizar a geraÁ„o de todos os documentos do MRP (PCPA712, PCPA144 ou Resultados MRP).
LocalizaÁ„o:	
Classe ProcessaDocumentos, mÈtodo processar() - Respons·vel por realizar a geraÁ„o dos documentos
Eventos:	
Ao finalizar a geraÁ„o dos documentos È aberta uma nova thread exclusiva para a execuÁ„o do ponto de entrada.
Programa Fonte:	PCPA145.PRW
Sintaxe:
PA145GER( [ cTicket ] ) --> Nil
ObservaÁıes:	
N„o È permitida a utilizaÁ„o de qualquer componente de interface gr·fica nesse ponto de entrada, visto que a funÁ„o ser· executada em background.
A rotina principal n„o aguardar· o tÈrmino da execuÁ„o do ponto de entrada.

Ponto de Entrada ser· utilizado para gravar o Item Cont·bil / Projeto nas OPs e SCs geradas pelo MRP

Conte˙do campo HWC_TDCERP = 	1=Ordem de Produùùo;2=Solicitaùùo de Compras;3=Pedido de Compras;4=Ordem de Produùùo Firme;5=SC Firme;6=Pedido de Compras Firme

@type function
@version  1.0
@author Silvio Nogueira - TOTVSTSM
@since 20/01/2026
@return nil, return_description
/*/
User Function PEPCP05()
	
	Local c_Alias   := GetNextAlias()
    Local c_AliasOP := GetNextAlias()
    //Local c_AliasPRE:= GetNextAlias()
	Local c_Ticket  := PARAMIXB[1]
	Local a_Area    := GetArea()
    Local c_NumPV1
    Local c_NumPV
    Local c_ItemPV
    //Local n_RecAnt
    //Local a_DocPai  := {}
    Local c_ItemCta


	//Local _cQuery   := ""
	//Local _aFields  := {}
	//Local cAliasSC2 := GetNextAlias()
	//Local cChave    := "%C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN%"
	//PRIVATE lMsErroAuto := .F.
	//Private lMsHelpAuto	:= .T.
	//Private aMata650    := {}

    Local o_Query
    Local c_Query := ""

    /*
    c_Query := "SELECT HWC_FILIAL,HWC_TICKET,HWC_TPDCPA,HWC_DOCPAI,HWC_PRODUT,HWC_DOCFIL,HWC_SEQUEN,HWC_TDCERP,HWC_DOCERP FROM ? HWC "
    c_Query += "  WHERE HWC_FILIAL = ? AND D_E_L_E_T_ = '' AND HWC_TICKET = ? AND HWC_DOCERP <> ''"
    c_Query += "  ORDER BY HWC_TPDCPA,HWC_DOCPAI,HWC_SEQUEN "
    */

    // Processa os documentos gerados pelo PV
    c_TipoDoc   := '3'

    c_Query := "SELECT * FROM ? HWC "
    c_Query += "  WHERE HWC_FILIAL = ? AND D_E_L_E_T_ = '' AND HWC_TICKET = ? AND HWC_DOCERP <> '' AND LTRIM(RTRIM(HWC_TPDCPA)) = '?'"
    c_Query += "  ORDER BY HWC_TPDCPA,HWC_DOCPAI,HWC_SEQUEN "


    c_Query := ChangeQuery(c_Query)
    o_Query := FWPreparedStatement():New(c_Query)

    o_Query:SetUnsafe(1, RetSqlName( "HWC" ))
    o_Query:SetUnsafe(2, xFilial( "HWC" ))
    o_Query:SetUnsafe(3, c_Ticket)
    o_Query:SetUnsafe(4, c_TipoDoc)

    c_Query 	:= o_Query:GetFixQuery()

    c_Alias 	:= MPSysOpenQuery( c_Query )

    (c_Alias)->(dbGotop())
    While (c_Alias)->(!Eof())

        // Indice 2 da tabela SVR - VR_FILIAL+VR_CODIGO+VR_PROD+STR(VR_SEQUEN)
        c_NumPV1    := GETADVFVAL('SVR', 'VR_DOC', xFilial('SVR') + SUBSTRING((c_Alias)->HWC_DOCPAI,3,15) + Left((c_Alias)->HWC_PRODUT,15) + SUBSTRING((c_Alias)->HWC_DOCPAI,18,84), 2, '')
        c_NumPV     := Left(c_NumPV1,6)
        c_ItemPV    := Substring(c_NumPV1,7,2)

        SC6->(dbSetOrder(1))
        SC6->(MsSeek(xFilial("SC6") + Left(c_NumPV,6) + c_ItemPV))

        If (c_Alias)->HWC_TDCERP $ ('1/4') // Ordem de ProduÁ„o Prevista e Firme

            SC2->(dbSetOrder(1))
            If SC2->(MsSeek(xFilial("SC2") + (c_Alias)->HWC_DOCERP))
               RecLock("SC2",.F.)
               SC2->C2_ITEMCTA := SC6->C6_ITEMCTA
               SC2->C2_XPEDIDO  := c_NumPV
               SC2->C2_XITEMPV  := c_ItemPV
               SC2->(MsUnlock())
            Endif

        ElseIf (c_Alias)->HWC_TDCERP $ ('2/5') // SolicitaÁ„o de Compra Prevista e Firme

            SC1->(dbSetOrder(1))
            If SC1->(MsSeek(xFilial("SC1") + (c_Alias)->HWC_DOCERP))
               RecLock("SC1",.F.)
               SC1->C1_ITEMCTA := SC6->C6_ITEMCTA
               SC1->C1_XPEDIDO  := c_NumPV
               SC1->C1_XITEMPV  := c_ItemPV
               SC1->(MsUnlock())
            Endif

        Endif

        (c_Alias)->(dbSkip())

    Enddo

    (c_Alias)->(dbGotop())
    While (c_Alias)->(!Eof())

        //If Alltrim((c_Alias)->HWC_TPDCPA) == c_TipoDoc

        HWC->(dbSetOrder(2))
        HWC->(dbSeek(xFilial("HWC")+c_Ticket))
        While HWC->(!Eof()) .And. HWC->HWC_TICKET == c_Ticket

            If (c_Alias)->HWC_DOCFIL == Alltrim(HWC->HWC_DOCPAI)

                c_NumPV1    := GETADVFVAL('SVR', 'VR_DOC', xFilial('SVR') + SUBSTRING((c_Alias)->HWC_DOCPAI,3,15) + Left((c_Alias)->HWC_PRODUT,15) + SUBSTRING((c_Alias)->HWC_DOCPAI,18,84), 2, '')
                c_NumPV     := Left(c_NumPV1,6)
                c_ItemPV    := Substring(c_NumPV1,7,2)

                SC6->(dbSetOrder(1))
                SC6->(MsSeek(xFilial("SC6") + Left(c_NumPV,6) + c_ItemPV))

                If HWC->HWC_TDCERP $ ('1/4') // Ordem de ProduÁ„o Prevista e Firme

                    SC2->(dbSetOrder(1))
                    If SC2->(MsSeek(xFilial("SC2") + HWC->HWC_DOCERP))
                        RecLock("SC2",.F.)
                        SC2->C2_ITEMCTA := SC6->C6_ITEMCTA
                        SC2->C2_XPEDIDO  := c_NumPV
                        SC2->C2_XITEMPV  := c_ItemPV
                        SC2->(MsUnlock())
                    Endif

                ElseIf HWC->HWC_TDCERP $ ('2/5') // SolicitaÁ„o de Compra Prevista e Firme

                    SC1->(dbSetOrder(1))
                    If SC1->(MsSeek(xFilial("SC1") + HWC->HWC_DOCERP))
                        RecLock("SC1",.F.)
                        SC1->C1_ITEMCTA := SC6->C6_ITEMCTA
                        SC1->C1_XPEDIDO  := c_NumPV
                        SC1->C1_XITEMPV  := c_ItemPV                        
                        SC1->(MsUnlock())
                    Endif

                Endif

            Endif

            HWC->(dbSkip())

        Enddo

        (c_Alias)->(dbSkip())

    Enddo

    (c_Alias)->(dbCloseArea())


    // Processa as OPs->SCs geradas pelo MRP

    c_TipoDoc   := 'OP'

    /*
    c_Query := " SELECT HWC.HWC_DOCPAI, HWC.HWC_DOCFIL, HWCB.HWC_DOCPAI DOCPAI,HWCB.HWC_TPDCPA TPDCPA, HWCB.HWC_SEQUEN SEQUENPAI, HWC.HWC_FILIAL,HWC.HWC_TICKET,HWC.HWC_TPDCPA,HWC.HWC_PRODUT,HWC.HWC_SEQUEN,HWC.HWC_TDCERP,HWC.HWC_DOCERP, HWCB.HWC_PRODUT PRODPAI, HWC.R_E_C_N_O_ NUMREG FROM ? HWC "
    c_Query += "   INNER JOIN ? HWCB ON HWCB.HWC_FILIAL = HWC.HWC_FILIAL AND HWC.HWC_DOCPAI = HWCB.HWC_DOCFIL AND HWCB.D_E_L_E_T_ = '' AND HWCB.HWC_TICKET = HWC.HWC_TICKET " 
    c_Query += "  WHERE HWC.HWC_FILIAL = ? AND HWC.D_E_L_E_T_ = '' AND HWC.HWC_TICKET = ?  AND HWC.HWC_TPDCPA = '?' AND HWC.HWC_DOCERP <> ''"
    c_Query += " ORDER BY HWC.HWC_DOCPAI, HWC.HWC_DOCFIL, HWCB.HWC_DOCPAI "
    */

    c_Query := "SELECT * FROM ? HWC "
    c_Query += "  WHERE HWC_FILIAL = ? AND D_E_L_E_T_ = '' AND HWC_TICKET = ? AND HWC_DOCERP <> '' AND LTRIM(RTRIM(HWC_TPDCPA)) = '?' AND HWC_DOCFIL <> ''"
    c_Query += "  ORDER BY HWC_TPDCPA,HWC_DOCFIL,HWC_DOCPAI "

    c_Query := ChangeQuery(c_Query)
    o_Query := FWPreparedStatement():New(c_Query)

    o_Query:SetUnsafe(1, RetSqlName( "HWC" ))
    o_Query:SetUnsafe(2, xFilial( "HWC" ))
    o_Query:SetUnsafe(3, c_Ticket)
    o_Query:SetUnsafe(4, c_TipoDoc)

    c_Query 	:= o_Query:GetFixQuery()

    c_AliasOP 	:= MPSysOpenQuery( c_Query )
    

    (c_AliasOP)->(dbGotop())
    While (c_AliasOP)->(!Eof())

        SC2->(dbSetOrder(1))
        SC2->(MsSeek(xFilial("SC2") + (c_AliasOP)->HWC_DOCERP))
        c_ItemCta   := SC2->C2_ITEMCTA
        c_NumPV     := SC2->C2_XPEDIDO
        c_ItemPV    := SC2->C2_XITEMPV

        HWC->(dbSetOrder(2))
        HWC->(dbSeek(xFilial("HWC")+c_Ticket))
        While HWC->(!Eof()) .And. HWC->HWC_TICKET == c_Ticket

            If (c_AliasOP)->HWC_DOCFIL == Alltrim(HWC->HWC_DOCPAI)
 
                If HWC->HWC_TDCERP $ ('1/4') // Ordem de ProduÁ„o Prevista e Firme

                    SC2->(dbSetOrder(1))
                    If SC2->(MsSeek(xFilial("SC2") + HWC->HWC_DOCERP))
                        RecLock("SC2",.F.)
                        SC2->C2_ITEMCTA := c_ItemCta
                        SC2->C2_XPEDIDO  := c_NumPV
                        SC2->C2_XITEMPV  := c_ItemPV
                        SC2->(MsUnlock())
                    Endif

                ElseIf HWC->HWC_TDCERP $ ('2/5') // SolicitaÁ„o de Compra Prevista e Firme

                    SC1->(dbSetOrder(1))
                    If SC1->(MsSeek(xFilial("SC1") + HWC->HWC_DOCERP))
                        RecLock("SC1",.F.)
                        SC1->C1_ITEMCTA := c_ItemCta
                        SC1->C1_XPEDIDO  := c_NumPV
                        SC1->C1_XITEMPV  := c_ItemPV                        
                        SC1->(MsUnlock())
                    Endif

                Endif

            Endif

            HWC->(dbSkip())

        Enddo

        (c_AliasOP)->(dbSkip())

    Enddo

    (c_AliasOP)->(dbCloseArea())


    // Processa as OPs->SCs geradas pelo MRP atravÈs de OPs prÈ-existentes antes do processamento

    c_TipoDoc   := 'PR…-OP'

    /*
    c_Query := " SELECT HWC.HWC_FILIAL,HWC.HWC_TICKET,UPPER(HWC.HWC_TPDCPA) HWC_TPDCPA,HWC.HWC_DOCPAI,HWC.HWC_PRODUT,HWC.HWC_DOCFIL,HWC.HWC_SEQUEN,HWC.HWC_TDCERP,HWC.HWC_DOCERP FROM ? HWC "
    c_Query += "  WHERE HWC.HWC_FILIAL = ? AND HWC.D_E_L_E_T_ = '' AND HWC.HWC_TICKET = ?  AND UPPER(HWC.HWC_TPDCPA) = '?' AND HWC.HWC_DOCERP <> ''"
    c_Query += " ORDER BY HWC.HWC_TPDCPA,HWC.HWC_DOCPAI,HWC.HWC_SEQUEN "
    */

    c_Query := "SELECT * FROM ? HWC "
    c_Query += "  WHERE HWC_FILIAL = ? AND D_E_L_E_T_ = '' AND HWC_TICKET = ? AND HWC_DOCERP <> '' AND UPPER(LTRIM(RTRIM(HWC_TPDCPA))) = '?' AND HWC_DOCFIL <> ''"
    c_Query += "  ORDER BY HWC_TPDCPA,HWC_DOCFIL,HWC_DOCPAI "

    c_Query := ChangeQuery(c_Query)
    o_Query := FWPreparedStatement():New(c_Query)

    o_Query:SetUnsafe(1, RetSqlName( "HWC" ))
    o_Query:SetUnsafe(2, xFilial( "HWC" ))
    o_Query:SetUnsafe(3, c_Ticket)
    o_Query:SetUnsafe(4, c_TipoDoc)

    c_Query 	:= o_Query:GetFixQuery()

    c_AliasPRE 	:= MPSysOpenQuery( c_Query )

    (c_AliasPRE)->(dbGotop())
    While (c_AliasPRE)->(!Eof())

        a_DocPai  := StrTokArr( (c_AliasPRE)->HWC_DOCPAI, ";" )

        SC2->(dbSetOrder(1))
        SC2->(MsSeek(xFilial("SC2") + a_DocPai[4]))
        c_ItemCta   := SC2->C2_ITEMCTA
        c_NumPV     := SC2->C2_XPEDIDO
        c_ItemPV    := SC2->C2_XITEMPV

        If (c_AliasPRE)->HWC_TDCERP $ ('1/4') // Ordem de ProduÁ„o Prevista e Firme

            SC2->(dbSetOrder(1))
            If SC2->(MsSeek(xFilial("SC2") + (c_AliasPRE)->HWC_DOCERP))
                RecLock("SC2",.F.)
                SC2->C2_ITEMCTA  := c_ItemCta
                SC2->C2_XPEDIDO  := c_NumPV
                SC2->C2_XITEMPV  := c_ItemPV
                SC2->(MsUnlock())
            Endif

        ElseIf (c_AliasPRE)->HWC_TDCERP $ ('2/5') // SolicitaÁ„o de Compra Prevista e Firme

            SC1->(dbSetOrder(1))
            If SC1->(MsSeek(xFilial("SC1") + (c_AliasPRE)->HWC_DOCERP))
                RecLock("SC1",.F.)
                SC1->C1_ITEMCTA  := c_ItemCta
                SC1->C1_XPEDIDO  := c_NumPV
                SC1->C1_XITEMPV  := c_ItemPV
                SC1->(MsUnlock())
            Endif

        Endif

        (c_AliasPRE)->(dbSkip())

    Enddo

    (c_AliasPRE)->(dbGotop())
    While (c_AliasPRE)->(!Eof())

        SC2->(dbSetOrder(1))
        SC2->(MsSeek(xFilial("SC2") + (c_AliasPRE)->HWC_DOCERP))
        c_ItemCta   := SC2->C2_ITEMCTA
        c_NumPV     := SC2->C2_XPEDIDO
        c_ItemPV    := SC2->C2_XITEMPV

        HWC->(dbSetOrder(2))
        HWC->(dbSeek(xFilial("HWC")+c_Ticket))
        While HWC->(!Eof()) .And. HWC->HWC_TICKET == c_Ticket

            If (c_AliasPRE)->HWC_DOCFIL == Alltrim(HWC->HWC_DOCPAI)
 
                If HWC->HWC_TDCERP $ ('1/4') // Ordem de ProduÁ„o Prevista e Firme

                    SC2->(dbSetOrder(1))
                    If SC2->(MsSeek(xFilial("SC2") + HWC->HWC_DOCERP))
                        RecLock("SC2",.F.)
                        SC2->C2_ITEMCTA := c_ItemCta
                        SC2->C2_XPEDIDO  := c_NumPV
                        SC2->C2_XITEMPV  := c_ItemPV
                        SC2->(MsUnlock())
                    Endif

                ElseIf HWC->HWC_TDCERP $ ('2/5') // SolicitaÁ„o de Compra Prevista e Firme

                    SC1->(dbSetOrder(1))
                    If SC1->(MsSeek(xFilial("SC1") + HWC->HWC_DOCERP))
                        RecLock("SC1",.F.)
                        SC1->C1_ITEMCTA := c_ItemCta
                        SC1->C1_XPEDIDO  := c_NumPV
                        SC1->C1_XITEMPV  := c_ItemPV
                        SC1->(MsUnlock())
                    Endif

                Endif

            Endif

            HWC->(dbSkip())

        Enddo

        (c_AliasPRE)->(dbSkip())

    Enddo

    (c_AliasPRE)->(dbCloseArea())

    RestArea(a_Area)

Return
