#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} M460FIM
Gera titulos financeiros para Z03 e compensa valores de acordo com adiantamento do pedido
@type function
@version 12.1.2410 
@author Gildeir Pereira - Refatorado
@since 14/10/2025
/*/
User Function M460FIM() 
    Local cNumPed     := ""
    Local cCliente    := ""
    Local cLoja       := ""
    Local aArea       := GetArea()
    Local aAreaSF2    := SF2->(GetArea())
    Local aAreaSD2    := SD2->(GetArea())
    Local aAreaSC5    := SC5->(GetArea())
    Local aAreaSE1    := SE1->(GetArea())  
    Local nVlrBaixa   := 0
    Local nRecnoRA    := 0
    Local nRecnoNF    := 0
    Local cPrefixo    := ""
    Local cNumTitulo  := ""
    
    // Variáveis da MaIntBxCR
    Local aRecRA      := {}
    Local aRecNF      := {}
    Local lContabiliza:= .F. // Ajuste conforme seus parâmetros
    Local lDigita     := .F.
    
    // 1. Identificar o Pedido através dos Itens da Nota
    DbSelectArea("SD2")
    SD2->(DbSetorder(3)) // FILIAL + DOC + SERIE + CLIE + LOJA
    If SD2->(DbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
        cNumPed := SD2->D2_PEDIDO
    Endif          

    If !Empty(cNumPed)
        
        // 2. Busca dados do Pedido de Venda
        DbSelectArea("SC5")
        SC5->(DbSetorder(1))
        If SC5->(DbSeek(xFilial('SC5')+cNumPed))
            cCliente := SC5->C5_CLIENTE
            cLoja    := SC5->C5_LOJACLI
            
            // 3. Busca o valor do Adiantamento (Sua lógica da tabela FIE)
            // Atenção: Verifique se a FIE realmente tem o vínculo correto
            DbSelectArea("FIE")
            FIE->(DbSetOrder(1)) 
            If FIE->(DbSeek(xFilial("FIE")+"R"+cNumPed)) // Assumindo chave FILIAL + TIPO + PEDIDO
                
                While !FIE->(EOF()) .And. FIE->FIE_FILIAL == xFilial("FIE") .And. FIE->FIE_PEDIDO == cNumPed
                    
                    // Se for registro do tipo Adiantamento e tiver valor
                    If FIE->FIE_CART == "R"
                        
                        // 4. Encontrar o Título de Adiantamento (RA) no Financeiro
                        DbSelectArea("SE1")
                        SE1->(DbSetOrder(1)) 
                        If SE1->(DbSeek(xFilial("SE1")+FIE->FIE_PREFIX+FIE->FIE_NUM+FIE->FIE_PARCEL+"RA"))
                            
                            nRecnoRA := SE1->(Recno())
                            
                            // Verifica se o RA realmente tem saldo no financeiro
                            If SE1->E1_SALDO > 0
                                nSaldoDoRA := SE1->E1_SALDO
                            EndIf
                                                        
                            // Primeiro, achamos a primeira parcela para pegar Prefixo e Numero
                            SE1->(DbSetOrder(1)) 
                            If SE1->(DbSeek(xFilial("SE1")+SF2->(F2_SERIE+F2_DOC)))
                                cPrefixo   := SE1->E1_PREFIXO
                                cNumTitulo := SE1->E1_NUM
                                                       
                                // Enquanto for a mesma nota e tivermos saldo no RA para gastar
                                While !SE1->(Eof()) .And. SE1->E1_PREFIXO == cPrefixo .And. SE1->E1_NUM == cNumTitulo .And. nSaldoDoRA > 0
                                    
                                    If SE1->E1_SALDO > 0 .And. Alltrim(SE1->E1_TIPO) == "NF"
                                        
                                        nRecnoNF := SE1->(Recno())
                                        
                                        // Baixa o menor valor: ou mata o título ou zera o RA
                                        If nSaldoDoRA >= SE1->E1_SALDO
                                            nVlrBaixa := SE1->E1_SALDO
                                        Else
                                            nVlrBaixa := nSaldoDoRA
                                        EndIf
                                        
                                        // Prepara Arrays para ExecAuto
                                        aRecRA := { nRecnoRA }
                                        aRecNF := { nRecnoNF }
                                        
                                        // Chama a rotina de Compensação
                                        If !MaIntBxCR(3, aRecNF, , aRecRA, ,{lContabiliza, .F., lDigita, .F., .F., .F.}, , , , , nVlrBaixa)
                                            // Help("M460FIM",1,"HELP","M460FIM","Erro na compensação automática.",1,0)
                                        Else
                                            // Se deu certo, deduzimos do saldo do RA que estamos controlando em memória
                                            nSaldoDoRA := nSaldoDoRA - nVlrBaixa
                                        Endif
                                        
                                        SE1->(DbGoTo(nRecnoNF))
                                    EndIf
                                    
                                    SE1->(DbSkip()) 
                                EndDo
                            EndIf
                        EndIf
                    EndIf
                    
                    FIE->(DbSkip())
                EndDo
            EndIf
        Endif
    Endif
    
    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aAreaSC5)
    RestArea(aAreaSE1)
    RestArea(aArea)
Return
