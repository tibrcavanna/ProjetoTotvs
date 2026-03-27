#include "totvs.ch"

//------------------------------------------------------------------------------------------------------------- 
/*/{Protheus.doc} PEPCP03 
Função para ao realizar alteração da estrutura do produto acabado da OP, alterar os empenhos 
caso a OP seja aberta e prevista e informar ao usuário sobre as solicitações de compras ou pedidos referentes ao item modificado.
@type Function 
@author Israel Machado 
@since 27/08/2025 
@param a_Recnos, array, Array com lista dos recno alterados (recebido do ponto de entrada P200GRAV). 
@return variant, Nil 
/*/ 
//------------------------------------------------------------------------------------------------------------- 

User Function PEPCP03(a_Recnos)

    Local n_Ind1 := 0
    Local a_EPAlt := {}

    // Monta uma listas de todas as EP que foram alteradas. 
    For n_Ind1 := 1 to len(a_Recnos)
        SG1->(dbgoto( a_Recnos[n_Ind1][2] ))
                // Codigo do Produto, Componente, ID da Operação (3 ? Inclusão;4 ? Alteração; 5 ? Exclusão),Quantidade
        aAdd(a_EPAlt, { SG1->G1_COD,SG1->G1_COMP,a_Recnos[n_Ind1][1],SG1->G1_QUANT }) 
    Next 

    IF Len(a_EPAlt) > 0
        ProcAltEP(a_EPAlt)
    ENDIF
    
Return(Nil) 

/**
 * ProcAltEP
 * ============================================================================
 * Processa alterações de componentes em empenhos de produção.
 *
 * @param a_AltEP, array, Array contendo as alterações de componentes na EP.
 *                Cada elemento deve conter:
 *                  [1] Produto Acabado
 *                  [2] Componente
 *                  [3] Tipo de Operação (Ex: 3 = Inclusão)
 *                  [4] Quantidade
 *
 * O procedimento busca os empenhos relacionados ao componente alterado e executa
 * operações automáticas de empenho conforme o tipo de alteração (inclusão, alteração, etc).
 *
 * Retorna: .T. (True) ao final do processamento.
 *
 * Variáveis privadas utilizadas:
 *   - lMsErroAuto: Flag de erro automático.
 *   - aValidSC, aValidComp: Arrays de validação.
 *
 * Funções auxiliares:
 *   - SearchEmp(): Busca empenhos relacionados ao componente.
 *   - EXAutoSD4(): Executa a operação automática de empenho.
 *
 * ============================================================================
 */
Static Function ProcAltEP(a_AltEP)

    Local cComp     := ""
    Local nI        := 0
    Local nJ        := 0
    Local nQtd      := 0
    Local aEmpenhos := {}
    Local lNewComp := .F.

    Private lMsErroAuto := .F.
    Private aValidSC := {}
    Private aValidComp := {}

    For nI := 1 To Len(a_AltEP)

        cComp := a_AltEP[nI][2]
        nQtd  := a_AltEP[nI][4]
        // Buscar empenhos D4 que referenciem esse componente
        IF a_AltEP[nI][3] == 3 // Inclusão
            lNewComp := .T.
            aEmpenhos := SearchEmp(a_AltEP[nI][1], lNewComp)
        ELSE
            lNewComp := .F.
            aEmpenhos := SearchEmp(cComp,lNewComp)
        ENDIF

        If Len(aEmpenhos) == 0
            // nada a fazer com empenhos já existentes
            Loop
        EndIf

        // Para cada empenho encontrado
        For nJ := 1 To Len(aEmpenhos)

            // Executa a operação automática de empenho conforme o tipo da operação que o componente sofreu na EP
            IF lNewComp
                // Componente, Quantidade do componente, Tipo de Operação,Quantidade da OP, OP (C2_NUM+C2_ITEM+C2_SEQUEN)
                // Componente, Produto Acabado, OP (D4_OP), Recno do empenho, Tipo de operação,Quantidade da OP,Quantidade do Componente,OP (C2_NUM+C2_ITEM+C2_SEQUEN), lNovo componente
                EXAutoSD4(cComp,a_AltEP[nI][1],/*cOP*/,/*nRecno*/,a_AltEP[nI][3],aEmpenhos[nJ][1],nQtd,aEmpenhos[nJ][2],lNewComp)
            ELSE
                    // Componente, Produto Acabado, OP (D4_OP), Recno do empenho, Tipo de operação,Quantidade da OP,Quantidade do Componente,lNovo componente
                EXAutoSD4(cComp,a_AltEP[nI][1],aEmpenhos[nJ][2],aEmpenhos[nJ][3],a_AltEP[nI][3],aEmpenhos[nJ][4],nQtd,lNewComp)
            ENDIF

        Next
    Next // a_AltEP

Return .T.



/**
 * SearchEmp
 * 
 * Função responsável por realizar a busca de informações de empenho de acordo com o código do componente informado.
 * 
 * @param cComp, character, Código do componente/produto a ser pesquisado.
 * @param lNewComp, logical , Indica se a busca será feita pelo novo componente (lNewComp = .T.) ou pelo componente antigo (lNewComp = .F.).
 * 
 * @return Array, Array contendo os resultados da consulta SQL conforme os parâmetros informados.
 *
 * A função monta uma query SQL dinâmica para buscar dados nas tabelas SD4 e SC2, considerando diferentes campos e condições
 * dependendo do valor do parâmetro lNewComp. Utiliza a função QryArray para retornar os resultados em formato de array.
 */
Static Function SearchEmp(cComp,lNewComp)

    Local aRet := {}
    Local cQuery := ""
    
    cQuery := " "
    IF lNewComp
        cQuery += " SELECT DISTINCT C2_QUANT,C2_NUM+C2_ITEM+C2_SEQUEN AS OP "
    ELSE
        cQuery += " SELECT DISTINCT D4_COD, D4_OP, SD4.R_E_C_N_O_ AS RECNO_SD4,C2_QUANT "
    ENDIF
    cQuery += " FROM "+RetSqlName("SD4")+" SD4  " 
    cQuery += " INNER JOIN "+RetSqlName("SC2")+" SC2 ON   " 
    cQuery += " D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN   " 
    cQuery += " AND C2_QUJE = '0' AND C2_TPOP = 'P'   " 
    cQuery += " AND SC2.D_E_L_E_T_ = ' '   "
    IF lNewComp
        cQuery += " AND C2_PRODUTO = '" + cComp + "'  "
    ENDIF 
    cQuery += " WHERE SD4.D_E_L_E_T_ = ' ' AND D4_QUANT = D4_QTDEORI  " 
    IF !lNewComp
        cQuery += " AND D4_COD = '" + cComp + "'  "
    ENDIF

    aRet := QryArray(cQuery)

Return aRet


/**
 * EXAutoSD4
 * ============================================================================
 * Função responsável por alterar, excluir ou incluir empenhos na tabela SD4,
 * conforme operação informada. Utilizada para manipulação automática dos empenhos
 * de componentes em Ordens de Produção (OP) no Protheus.
 *
 * Parâmetros:
 *   @param cComp    , character , Código do componente a ser manipulado.
 *   @param cPACod   , character , Código da PAC (Plano de Atividades de Compra).
 *   @param cOP      , character , Número da OP (Ordem de Produção) original.
 *   @param nRecno   , numeric , Número do registro (Recno) da OP.
 *   @param nOper    , numeric , Tipo de operação (3=Incluir, 4=Alterar, 5=Excluir).
 *   @param nOpQtd   , numeric , Quantidade de OP.
 *   @param nQtd     , numeric , Quantidade do componente.
 *   @param cC2Op    , character , Número da OP principal (para inclusão de novo componente).
 *   @param lNewComp , logical , Indica se é novo componente (.T.) ou alteração/exclusão (.F.).
 *
 * Retorno:
 *   @return logical, lRet, .T. se operação realizada com sucesso, .F. caso contrário.
 *
 * Observações:
 *   - Realiza validações de saldo em estoque antes de incluir novo empenho.
 *   - Para produtos rastreados por lote, busca o lote correspondente.
 *   - Utiliza o MATA381 para efetuar as alterações na SD4.
 *   - Em caso de erro, exibe mensagem ao usuário.
 */
Static Function EXAutoSD4(cComp,cPACod,cOP,nRecno,nOper,nOpQtd,nQtd,cC2Op,lNewComp)

    Local lRet := .F.
    Local nX         := 0
    Local nPos       := 0
    Local aCab       := {}
    Local aLine      := {}
    Local aItens     := {}
    Local lLote      := .F.
    Local _cLote     := ""
    Local cMainOP    := ""
 
    PRIVATE lMsErroAuto := .F.
    
    IF lNewComp
        cMainOP := cC2Op
    ELSE
        cMainOP := cOP
    ENDIF
    //Monta o cabeçalho com o número da OP que será alterada.
    //Necessário utilizar o índice 2 para efetuar a alteração.
    aCab := {{"D4_OP",cMainOP,NIL},;
            {"INDEX",2,Nil}}

    //Busca os empenhos da SD4 para alterar/excluir.
    SD4->(dbSetOrder(2))
    IF SD4->(MsSeek(xFilial("SD4")+PadR(cMainOP,Len(SD4->D4_OP))))

        IF nOper <> 3
            While SD4->(!Eof()) .And. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+PadR(cOP,Len(SD4->D4_OP))
                //Adiciona as informações do empenho, conforme estão na tabela SD4.
                aLine := {}
                nX := 1
                For nX := 1 To SD4->(FCount())
                    aAdd(aLine,{SD4->(Field(nX)),SD4->(FieldGet(nX)),Nil})
                Next nX

                //Adiciona o identificador LINPOS para identificar que o registro já existe na SD4
                aAdd(aLine,{"LINPOS","D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
                                    SD4->D4_COD,;
                                    SD4->D4_TRT,;
                                    SD4->D4_LOTECTL,;
                                    SD4->D4_NUMLOTE,;
                                    SD4->D4_LOCAL,;
                                    SD4->D4_OPORIG,;
                                    SD4->D4_SEQ})
                
                // Se o produto foi excluído da estrutura, marca o empenho do produto como Excluído.
                If AllTrim(SD4->D4_COD) == AllTrim(cComp) .AND. nOper == 5

                    aAdd(aLine,{"AUTDELETA","S",Nil})

                    ValidaSC(Alltrim(cPACod), cMainOP, cComp)

                ElseIf AllTrim(SD4->D4_COD) == AllTrim(cComp) .AND. nOper == 4
                    //Altera a quantidade do empenho do produto
                    //Busca a informação da quantidade (D4_QTDEORI) no array aLine.
                    nPos := aScan(aLine,{|x| x[1] == "D4_QTDEORI"})
                    If nPos > 0
                        //Encontrou o valor da quantidade. Faz a alteração do valor.
                        aLine[nPos][2] := nQtd * nOpQtd
                    EndIf
                    
                    //Altera também o saldo do empenho
                    nPos := aScan(aLine,{|x| x[1] == "D4_QUANT"})
                    If nPos > 0
                        //Encontrou o valor da quantidade. Faz a alteração do valor.
                        aLine[nPos][2] := nQtd * nOpQtd
                    EndIf

                EndIf

                //Adiciona as informações do empenho no array de itens.
                aAdd(aItens,aLine)

                //Próximo registro da SD4.
                SD4->(dbSkip())
            End
        ELSE

            //Adiciona um novo empenho 
            
            // ?? Valida saldo em estoque
            If !ValidaSaldo(cComp,nQtd * nOpQtd)
                If aScan(aValidSC, {|x| x == AllTrim(cComp)}) == 0
                    aadd(aValidSC,AllTrim(cComp))
                    FWAlertWarning("Item "+AllTrim(cComp)+" incluído na estrutura não possui saldo em estoque."+ CHR(13)+CHR(10) + ;
                    "Será necessário criar a Solicitação de Compra manualmente.","Atenção!")
                EndIf
            EndIf
            
            DbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            If SB1->(MsSeek(xFilial("SB1")+PadR(cComp,Len(SB1->B1_COD))))
                IF SB1->B1_RASTRO == 'L'
                    lLote := .T.
                ENDIF
            ENDIF

            aLine := {}
            aAdd(aLine,{"D4_OP"     ,cMainOP           ,NIL})
            aAdd(aLine,{"D4_COD"    ,cComp             ,NIL})
            aAdd(aLine,{"D4_LOCAL"  ,SD4->D4_LOCAL     ,NIL})
            aAdd(aLine,{"D4_DATA"   ,SD4->D4_DATA      ,NIL})
            aAdd(aLine,{"D4_QTDEORI",nQtd * nOpQtd     ,NIL})
            aAdd(aLine,{"D4_QUANT"  ,nQtd * nOpQtd     ,NIL})
            IF lLote
                //Busca o lote do componente
                u_LOTESB8(cComp,@_cLote)
                aAdd(aLine,{"D4_LOTECTL",_cLote        ,NIL})
            ENDIF
            aAdd(aLine,{"D4_TRT"    ,SD4->D4_TRT       ,NIL})
            aAdd(aLine,{"D4_ROTEIRO",SD4->D4_ROTEIRO   ,NIL})
            aAdd(aItens,aLine)
        ENDIF

        //Executa o MATA381, com a operação de Alteração.
        MSExecAuto({|x,y,z| mata381(x,y,z)},aCab,aItens,4)

        If lMsErroAuto
            //Se ocorrer erro.
            MostraErro()
            lRet := .F.
        Else
            lRet := .T.
        EndIf
    ENDIF

Return lRet

/**
 * ValidaSC
 *
 * Função estática responsável por validar se um determinado componente (produto) possui solicitações de compras (SC),
 * pedidos de compras (PC) ou ordens de produção (OP) gerados a partir de sua estrutura, informando ao usuário sobre
 * a necessidade de comunicação ao setor de compras caso o item seja excluído.
 *
 * Parâmetros:
 *   @param cComp   , character, Código do PA (produto acabado) a ser validado.
 *   @param cMainOP , character, Código da OP principal relacionada ao componente.
 *   @param cProdDel, character, Código do componente que foi excluído da estrutura.
 *
 * Retorno:
 *   Não retorna valor. Exibe alertas informativos ao usuário sobre SCs, PCs e OPs relacionadas ao componente.
 *
 * Observações:
 *   - Utiliza consultas SQL para buscar as relações entre componente, SC, PC e OP.
 *   - Exibe mensagens de alerta caso existam SCs ou PCs gerados pelo componente.
 *   - Recomenda informar ao setor de compras sobre a exclusão do item e suas implicações.
 */
Static Function ValidaSC(cComp, cMainOP, cProdDel)

    Local cQuery := ""
    Local cTemp  := ""
    Local cSCMsg := ""
    Local cPCMsg := ""
    Local cOPMsg := ""
    Local aRes   := {}
    Local aResult := {}
    Local aSC := {}
    Local aPC := {}
    Local aOP := {}
    Local nX     := 0
    Local nY     := 0
    Local nTemp  := 1

    // ?? 1. Busca SC criada pelo item

    cQuery := " "
    cQuery += " SELECT DISTINCT SD4.D4_OP,SC1.C1_NUM,SC1.C1_ITEM,SC1.C1_PRODUTO,SC7.C7_NUM   " 
    cQuery += " FROM   " + RetSqlName("SVR") + " VR   " 
    cQuery += " INNER JOIN " + RetSqlName("SC1") + " SC1 ON SC1.C1_SEQMRP = VR.VR_NRMRP AND SC1.C1_PRODUTO = '"+AllTrim(cProdDel)+"'   " 
    cQuery += "        AND SC1.D_E_L_E_T_ = ' '   " 
    cQuery += " INNER JOIN "  + RetSqlName("SD4") + " SD4 ON SD4.D4_PRODUTO = VR.VR_PROD  " 
    cQuery += "       AND SD4.D_E_L_E_T_ = ' '  " 
    cQuery += " LEFT JOIN "  + RetSqlName("SC7") + " SC7 ON SC7.C7_NUMSC = SC1.C1_NUM   " 
    cQuery += "        AND SC7.D_E_L_E_T_ = ' '   " 
    cQuery += "        AND SC7.C7_ITEMSC = SC1.C1_ITEM   " 
    cQuery += "        AND SC7.C7_PRODUTO = SC1.C1_PRODUTO   " 
    cQuery += " WHERE  VR.VR_PROD = '" + cComp + "'   " 
    cQuery += "        AND VR.VR_TIPO = '1'   " 
    cQuery += "        AND VR.D_E_L_E_T_ = ' '  " 
    cQuery += " ORDER BY C1_PRODUTO,D4_OP   " 

    aRes := QryArray(cQuery)
    
    For nX := 1 To Len(aRes)

        IF nX == 1
            aAdd(aResult,{})
        ENDIF

        aAdd(aResult[nTemp],{aRes[nX][1],aRes[nX][2],aRes[nX][3],aRes[nX][4],aRes[nX][5]})
        
        cTemp := aRes[nX][4]
        IF AllTrim(cTemp) != AllTrim(aRes[IF(nX + 1 <= Len(aRes),nX+1,nX)][4])
            nTemp++
            aAdd(aResult,{})
        ENDIF

    Next

    If Len(aRes) > 0 .AND. Len(aResult) > 0

        nX := 1
        For nX := 1 To Len(aResult)
            aSC := {}
            aPC := {}
            aOP := {}

            nY := 1
            For nY := 1 To Len(aResult[nX])

                // Adiciona a OP ao array aOP apenas se ainda não existir
                If aScan(aOP, {|x| x[1] == aResult[nX][nY][1]}) == 0
                    aadd(aOP,{aResult[nX][nY][1]})
                EndIf

                aadd(aSC,{aResult[nX][nY][2]})

                IF !Empty(aResult[nX][nY][5])
                    If aScan(aPC, {|x| x[1] == aResult[nX][nY][5]}) == 0
                        aadd(aPC,{aResult[nX][nY][5]})
                    ENDIF
                ENDIF
            Next

            IF aScan(aValidComp, {|x| x == aResult[nX][1][4]}) == 0
                aadd(aValidComp, aResult[nX][1][4])

                // OPs
                nY := 1
                cOPMsg := "Informe ao setor de compras que não será mais necessário a compra para a(s) OP(s): " + CHR(13)+CHR(10)
                For nY := 1 To Len(aOP)
                    cOPMsg += AllTrim(aOP[nY][1])
                    If nY < Len(aOP)
                        cOPMsg += CHR(13)+CHR(10)
                    EndIf
                Next

                // SC
                cSCMsg := "Item "+AllTrim(aResult[nX][1][4])+" excluído da estrutura, ele gerou a(s) necessidade(s) (SC) de número(s): " + CHR(13)+CHR(10)
                nY := 1
                For nY := 1 To Len(aSC)
                    cSCMsg += AllTrim(aSC[nY][1])
                    If nY < Len(aSC)
                        cSCMsg += CHR(13)+CHR(10)
                    EndIf
                Next

                cSCMsg += CHR(13)+CHR(10) + CHR(13)+CHR(10) + cOPMsg
                
                // PC
                cPCMsg := "Item "+AllTrim(aResult[nX][1][4])+" excluído da estrutura, ele gerou o(s) pedidos(s) de compra (PC) de número(s): " + CHR(13)+CHR(10)
                nY := 1
                For nY := 1 To Len(aPC)
                    cPCMsg += AllTrim(aPC[nY][1])
                    If nY < Len(aPC)
                        cPCMsg += CHR(13)+CHR(10)
                    EndIf
                Next

                cPCMsg += CHR(13)+CHR(10) + CHR(13)+CHR(10) + cOPMsg

                If Len(aPC) > 0
                    FWAlertWarning(cPCMsg,"Atenção!")
                Endif
                If Len(aSC) > 0
                    FWAlertWarning(cSCMsg,"Atenção!")
                Endif
            ENDIF
        Next
    EndIf

Return

/**
 * ValidaSaldo
 * 
 * Função estática responsável por validar se o saldo de um determinado componente (produto)
 * é suficiente para atender a uma quantidade informada.
 * 
 * Parâmetros:
 *   @param cComp ,Character, Código do componente/produto a ser validado.
 *   @param nValor , Numeric, Quantidade desejada para validação do saldo.
 * 
 * Retorno:
 *   @return variant, Logical, .T. se o saldo for suficiente, .F. caso contrário ou se o produto não existir.
 * 
 * Observações:
 *   - Utiliza a tabela SB2 para buscar o saldo do produto.
 *   - Utiliza a rotina padrão CalcEst para calcular o saldo disponível.
 *   - Considera o saldo do produto no armazém e na data informada.
 */
Static Function ValidaSaldo(cComp,nValor)

    Local nSaldo := 0
    Local aSaldo := {}
    Local lRet   := .T.

    // Seleciona a SB2
    DbSelectArea("SB2")
    SB2->(DbSetOrder(1)) // B2_FILIAL+B2_COD
    If SB2->(MsSeek(xFilial("SB2")+PadR(cComp,Len(SB2->B2_COD))))
        
        // ?? Usa a rotina padrão CalcEst 
        // Parâmetros: produto, armazém, data
        aSaldo := CalcEst(cComp, SB2->B2_LOCAL, dDatabase + 1)
        nSaldo := aSaldo[1]

        If nSaldo < nValor
            lRet := .F.
        EndIf
    Else
        // Produto nem existe na SB2
        lRet := .F.
    EndIf

Return lRet
