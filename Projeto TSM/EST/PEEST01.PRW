#include "PROTHEUS.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ESTM001
  @description: Carrega array do browse com as informações da OP informada no parâmetro
  @type function
  @author Silvio Nogueira Silva
  @since 12/09/2025
  @return nil
/*/
//-------------------------------------------------------------------------------------------------------------

User Function PEEST01()

    Private lOk         := .T.
    Private aEmpenhos  := {}
    Private aArea       := GetArea()
    Private cPerg       := "ESTM001"

    If Pergunte("ESTM001",.t.)

        // Acessa rotina para buscar os empenhos da OP
        Processa({|| ProcM001()},"Lendo registros dos empenhos....")

    Endif

Return


// Função para buscar os empenhos da OP e carregar no acols da tela de S.A.
Static Function ProcM001

    Local lExistSA
    Local cSAAber
    Local nQtdSA    := 0
    Local nItensH     := 0
    Local nItensEmp   := 0

    ProcRegua(1)

    // Faz a leitura dos empenhos para a OP digitada
    If !Empty(mv_par01) .And. lOk

        SD4->(dbSetOrder(2))
        SD4->(dbSeek(xFilial("SD4")+mv_par01,.T.))

        While !SD4->(Eof()) .And. SD4->D4_FILIAL == xFilial("SD4") .And. SD4->D4_OP = mv_par01

            lExistSA    := .F.
            cSAAber     := ''
            nQtdSA      := 0

            SC2->(dbSetOrder(1))
            SC2->(dbSeek(xFilial("SC2")+SD4->D4_OP))

            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))

            If !Empty(SD4->D4_QUANT)  .And. SC2->C2_TPOP = 'F' .And. Empty(SC2->C2_DATRF)

                AADD(aEmpenhos,;
                                {   NIL,;
                                    NIL,;
                                    SD4->D4_COD,;
                                    SD4->D4_QUANT,;
                                    SD4->D4_TRT,;
                                    SD4->D4_LOTECTL,;
                                    SD4->D4_NUMLOTE,;
                                    "",;
                                    "",;
                                    SD4->D4_LOCAL,;
                                    SD4->D4_OP,;
                                    SD4->D4_QTSEGUM;
                                };
                    )

            Endif

            SD4->(dbSkip())

            IncProc("Lendo itens empenhados nas OPs.... ")

        End

    EndIf

    // Faz a leitura dos itens de primeiro nivel
    If !Empty(aEmpenhos)

        cContaIt := aCols[len(aCols),aScan(aHeader,{|aX| AllTrim(aX[2]) == "CP_ITEM"})]
        
    Endif


    // Carrega no acols da tela os itens do array aEmpenhos
    ProcRegua(Len(aEmpenhos))

    For nItensEmp := 1 to Len(aEmpenhos)

        If cContaIt >= 'ZZ'

            MsgAlert("A numeração de itens na S.A. atingiu o limite máximo. Favor verificar e corrigir os parâmetros se for o caso.")
            Exit

        Endif

        IncProc("Carregando itens empenhados nas OPs.... ")

        nPosCod := aScan(aHeader,{|aX| AllTrim(aX[2]) == "CP_PRODUTO"})

        // Se a primeira linha esta em branco remove a mesma do acols
        If !Empty(Len(aCols)) .And. Empty(aCols[1,nPosCod])

            ADel(aCols,1)
            ASize(aCols,Len(aCols)-1)

        EndIf

        // Adiciona item no acols
        AADD(aCols,Array(Len(aHeader)+1))

        // Preenche conteudo do acols
        For nItensH :=1 to Len(aHeader)

            If IsHeadRec(aHeader[nItensH][2])

                aCols[Len(aCols)][nItensH] := 0

            ElseIf IsHeadAlias(aHeader[nItensH][2])

                aCols[Len(aCols)][nItensH] := "SCP"

            Else

                If aHeader[nItensH][10] != "V" 

                    cCampo:=Alltrim(aHeader[nItensH,2])
                    aCols[Len(aCols)][nItensH] := CriaVar(cCampo,.F.)

                    If cCampo == "CP_ITEM"

                        aCols[Len(aCols)][nItensH] := STRZERO(Len(aCols),LEN(SCP->CP_ITEM))

                    ElseIF cCampo == "CP_DATPRF"

                        aCols[Len(aCols)][nItensH] := dDataBase

                    EndIf

                Endif

            EndIf

        Next nItensH

        aCOLS[Len(aCols)][Len(aHeader)+1] := .F.

        GDFieldPut("CP_ITEM",cContaIt,Len(aCols))
        cContaIt := Soma1(cContaIt)
        GDFieldPut("CP_PRODUTO"     ,aEmpenhos[nItensEmp,3],Len(aCols))

        // Preenche campos especificos
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")+aEmpenhos[nItensEmp,3]))

        //l_AproInd := IIF(SB1->B1_APROPRI=='I',.T.,.F.)

        GDFieldPut("CP_DESCRI"      ,SB1->B1_DESC,Len(aCols))
        GDFieldPut("CP_UM"          ,SB1->B1_UM,Len(aCols))
        GDFieldPut("CP_SEGUM"       ,SB1->B1_SEGUM,Len(aCols))
        GDFieldPut("CP_AVITRT"      ,aEmpenhos[nItensEmp,5],Len(aCols))

        GDFieldPut("CP_CC"      ,SB1->B1_CC,Len(aCols))

        GDFieldPut("CP_LOCAL"       ,aEmpenhos[nItensEmp,10],Len(aCols))
        GDFieldPut("CP_QUANT"       ,aEmpenhos[nItensEmp,4],Len(aCols))
        GDFieldPut("CP_DATPRF"      ,mv_par02,Len(aCols))
        GDFieldPut("CP_OP"       ,aEmpenhos[nItensEmp,11],Len(aCols))
        GDFieldPut("CP_QTSEGUM"       ,aEmpenhos[nItensEmp,12],Len(aCols))

         If ExistTrigger("CP_PRODUTO")

            RunTrigger(2,Len(aCols),,,"CP_PRODUTO")

        EndIf

        If ExistTrigger("CP_LOCAL")

            RunTrigger(2,Len(aCols),,,"CP_LOCAL")

        EndIf

        If ExistTrigger("CP_QUANT")

            RunTrigger(2,Len(aCols),,,"CP_QUANT")

        Endif

        If ExistTrigger("CP_DATPRF")

            RunTrigger(2,Len(aCols),,,"CP_DATPRF")

        EndIf

        If ExistTrigger("CP_OP")

            RunTrigger(2,Len(aCols),,,"CP_OP")

        EndIf

    Next nItensEmp
    
    RestArea(aArea)

Return
