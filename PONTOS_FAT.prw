#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'


/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Ponto de entrada chamado pós o encerramento das operações da rotina                 @@@
@ de orçamentos ( inclusão, alteração, exclusão )                                     @@@
@ Autor: Lucas Apolinario                                                             @@@
@ Since: 01/06/2025                                                                   @@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
User Function MA415END()
    Local nTipo     := PARAMIXB[1]      // 0 se nao confirmou a operação,  1 se confirmou a operação
    Local nOper     := PARAMIXB[2]      // 1 se é inclusão, 2 se é alteração, 3 se é exclusão
    Local cRevAtu   := SCJ->CJ_XREVISA  // revisão atual do orçamento


    if nTipo == 1 .and. nOper == 2 // chamada apenas quando for alteração e ja tiver sido confirmado a operação
        cRevAtu := Soma1(cRevAtu) // incrementa a revisão do orçamento
        RECLOCK('SCJ',.F.)
            SCJ->CJ_XREVISA := cRevAtu
        SCJ->(MsUnlock())

    endif


Return .t.



/*=============================================================================================+
|| @Descrição:Responsável pela adição de rotinas no menu da rotina "outras ações"             ||
|| da tela de orçamento                                                                 	  ||
|| @Parâmetros:                                                                               ||
||    nenhum																				  ||
|| @Return:                                                                                   ||
||    nil   														                          ||
|| @author Lucas Apolinario                                                                   ||
|| @since 16/07/2025                                                                          ||        
+=============================================================================================*/
User Function MA415MNU()
    Aadd(aRotina,{'Imprimir Orçamento',"U_PEFAT02()",0,1,0,NIL})
Return 

/*=============================================================================================+
|| @Descrição:Responsável pela adição de rotinas no botão Outras Ações do pedido venda        ||            
||                                                                                        	  ||
|| @Parâmetros:                                                                               ||
||    nenhum																				  ||
|| @Return:                                                                                   ||
||    aRetorno (Array com ações para o "Outras ações")                                        ||
|| @author  Anderson Rezende                                                                  ||
|| @since 12/11/2025                                                                          ||
+=============================================================================================*/
User function MA410MNU()
    Local aRetorno := {}
    Aadd(aRotina,{"Impressão P.V.","U_PEFAT03(SC5->C5_NUM)",0,3,0,NIL})
    Aadd(aRotina,{"Impressão Invoice","U_PEFAT04(SC5->C5_NUM)",0,3,0,NIL})
Return( aRetorno )

/*=============================================================================================+
|| @Descrição:Responsável pela validação da alteração/ ou inclusao do orçamento               ||
||                                                                                        	  ||
|| @Parâmetros:                                                                               ||
||    nenhum																				  ||
|| @Return:                                                                                   ||
||    nil   														                          ||
|| @author Lucas Apolinario                                                                   ||
|| @since 04/08/2025                                                                          ||
+=============================================================================================*/
User function A415TDOK() 
    Local aArea := FwGetArea()
    Local lRet  := .T. //Variável utilizada para controle e validação ao clicar no botão SALVAR do Orçamento de venda

    IF ALTERA
        DbSelectArea("ACB")
        ACB->(DbSetOrder(2))
        IF ACB->(!MsSeek(xFilial('ACB') + cFilAnt + M->CJ_NUM + M->CJ_XREVISA+ '.pdf'))
            lRet := .F.
            Help(, , "Help A415TDOK", , "Não é possivel alterar orçamentos que ainda não possuem PDF vinculado ao banco de conhecimento!", 1, 0, , , , , , {"Execute a rotina de imprimir orçamento (localizado em Outras Ações) e siga o passo a passo!"})
        ENDIF


        ACB->(DbCloseArea())

    ENDIF


    FwRestArea(aArea)
Return(lRet)

/*=============================================================================================+
|| @Descrição:Responsável pela adição de rotinas no botão Outras Ações do Doc. de Saída       ||
||                                                                                        	  ||
|| @Parâmetros:                                                                               ||
||    nenhum																				  ||
|| @Return:                                                                                   ||
||    aRetorno (Array com ações para o "Outras ações")  			                          ||
|| @author Israel Machado                                                                     ||
|| @since 04/08/2025                                                                          ||
+=============================================================================================*/
User function MA461ROT()
    Local aRetorno := {}
    AAdd( aRetorno, {'Packing List','U_PEFAT01()' , 0 , 2, 0, Nil}) 
Return( aRetorno )


/*=============================================================================================+
|| @Descrição:Ponto de entrada para carregar informações do orçamento para o pedido de venda  ||
||                                                                                        	  ||
|| @Parâmetros:                                                                               ||
||    nenhum																				  ||
|| @Return:                                                                                   ||
|| @author Lucas Gonçalves                                                                    ||
|| @since 22/01/2026                                                                          ||
+=============================================================================================*/
User Function MTA416PV()
    
    // Transfere o conteÃºdo do campo vendedor e observaÃ§Ã£o para o Pedido de Venda gerado.

    C5_FECENT     := CJ_VALIDA
    C5_SUGENT     := CJ_VALIDA
    C5_XTIPO      := AllTrim(CJ_XTIPPRJ)
    C5_XPROJET    := AllTrim(CJ_XPROJET)

Return



User Function MA415BUT()

    SetKey(VK_F6, { || U_FSAPTR02() })

Return
