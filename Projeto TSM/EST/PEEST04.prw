#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PEEST04
@description: Ponto de Entrada na rotina de recalculo do custo médio de estoque.
Rotina para filtrar todas as OPs abertas de mão de obra de code allegre - Grupo=2999, 
verificar se existe a OP principal do CodeAllegre, caso exista encerrar a OP de Mão de Obra e requisitar para a OP principal
@type user function
@version 1.0
@author Silvio Nogueira Silva
@since 23/12/2025
@return lRet - parâmetro indicando que a rotina foi processada corretamente e que pode seguir o fluxo normal
do processamento de recalculo do custo médio
/*/
User Function PEEST04(c_OPCAllegre)

    Local c_Process	:= ProcName(1)    
    Local l_Ret := .T.
    Local o_QryC
    Local c_LocPad  := SuperGetMv("FS_LOCPAD",.F.,"01")
    Local c_GrpMO   := SuperGetMv("FS_GRPMO",.F.,"2999")
    Local c_Alias
    Local c_Qry

    Local c_TipMov  := SuperGetMv("FS_TPMOVE",.F.,"130")
    Local c_TipMvR  := SuperGetMv("FS_TPMVS2",.F.,"631")  

    Local c_CodMO
    Local n_Qtd
    Local c_Docto
    Local c_OPAtu
    Local a_CabSD3  := {}
    Local a_DtItens := {}
    Local a_Itens   := {}

    Local n_Opc

    Local a_Vetor

    Local a_Area    := GetArea()

    // Filtro das OPs de Mão de Obra do CodeAllegre - Grupo = 2999 

    ProcLogAtu( "INICIO",  "Filtro das OPs de Mão de Obra do CodeAllegre - Grupo = 2999" ,,c_Process,.T. )

    If o_QryC == Nil

        c_Qry := "SELECT SC2.C2_FILIAL,SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN OPMO,SC2.C2_PRODUTO PRODOPMO,SC2.C2_QUANT,SC2B.OPORIG,SC2B.C2_PRODUTO PRODOP,Z01_CODMO FROM ? SC2 "
        c_Qry += " INNER JOIN ? SB1 ON C2_PRODUTO = B1_COD AND B1_GRUPO = ? AND SB1.D_E_L_E_T_ = '' "
        c_Qry += " INNER JOIN (SELECT Z01_CODPI,Z01_CODMO FROM ? "
        c_Qry += " 		WHERE  D_E_L_E_T_ = ' ' "
        c_Qry += " 		GROUP BY Z01_CODPI,Z01_CODMO "
        c_Qry += " )  Z01 ON SC2.C2_PRODUTO = Z01_CODMO "
        c_Qry += " INNER JOIN (SELECT C2_FILIAL,C2_NUM+C2_ITEM+C2_SEQUEN OPORIG,C2_PRODUTO FROM ? "
        c_Qry += "		WHERE  D_E_L_E_T_ = ' ' AND C2_DATRF = ' '  AND C2_EMISSAO <= ? "
        c_Qry += " )  SC2B ON SC2.C2_FILIAL = SC2B.C2_FILIAL AND Z01.Z01_CODPI = SC2B.C2_PRODUTO "
        c_Qry += " WHERE  SC2.D_E_L_E_T_ = ' ' AND SC2.C2_DATRF = ' '" 

        If c_OPCAllegre <> Nil

            c_Qry   += " AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN = ?"

        Endif

        c_Qry += " ORDER BY  SC2.C2_FILIAL,SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN,SC2B.OPORIG "

        c_Qry := ChangeQuery(c_Qry)
        o_QryC := FWPreparedStatement():New(c_Qry)

    EndIf

    o_QryC:SetUnsafe(1, RetSqlName( "SC2" ))
    o_QryC:SetUnsafe(2, RetSqlName( "SB1" ))
    o_QryC:SetString(3, c_GrpMO)
    o_QryC:SetUnsafe(4, RetSqlName( "Z01" ))
    o_QryC:SetUnsafe(5, RetSqlName( "SC2" ))
    o_QryC:SetString(6, Dtos(d_DtFech))

    If c_OPCAllegre <> Nil

        o_QryC:SetString(7, c_OPCAllegre)

    Endif

    c_Qry 	:= o_QryC:GetFixQuery()
    c_Alias 	:= MPSysOpenQuery( c_Qry )

    dbSelectArea("SD3")

    RestArea(a_Area)

    // Para cada registro da tabela temporário deverá encerrar a OP de MO (OPMO) e requisitar para a montagem final do Code Allegre (OPORIG)
    (c_Alias)->(dbGotop())

    If (c_Alias)->(!Eof())

        c_OPAtu := ""

        While (c_Alias)->(!Eof())

            ProcLogAtu( "MENSAGEM",  "Encerrar a OP de MO (OPMO) e requisitar para a montagem final do Code Allegre (OPORIG)" ,,c_Process,.T. )

            a_CabSD3    := {}
            a_DtItens   := {}
            a_Itens     := {}

            lMsErroAuto := .F.
	        lMsHelpAuto := .F.

            If (c_Alias)->OPMO <> c_OPAtu

                c_OPAtu := (c_Alias)->OPMO            

                // Encerrar a OP de MO (OPMO)
                c_OPMO  := (c_Alias)->OPMO

                dData:=dDataBase                

                dbSelectArea("SD3")    	
                c_Docto := CriaVar("D3_DOC")

                If EMPTY(Alltrim(c_Docto))
                   c_Docto := NextNumero("SD3",2,"D3_DOC",.T.)
                Endif

                SC2->(dbSetOrder(1))
                SC2->(MsSeek(FWxFilial("SC2") + c_OPMO ))

                SB1->(dbSetOrder(1))
                SB1->(MsSeek(FWxFilial("SB1") + (c_Alias)->PRODOPMO ))

                n_Opc   := 3  // Opção de encerramento

                a_Vetor := {{"D3_OP"        ,c_OPMO             ,NIL},;
                            {"D3_TM"        ,c_TipMov           ,NIL},;
                            {"D3_DOC"       ,c_Docto            ,NIL},;
                            {"D3_EMISSAO"   ,d_DtFech           ,NIL},;
                            {"D3_COD"       ,(c_Alias)->PRODOPMO,NIL},;
                            {"D3_UM"        ,SB1->B1_UM         ,NIL},;
                            {"D3_CONTA"     ,SB1->B1_CONTA      ,NIL},;
                            {"D3_LOCAL"     ,c_LocPad           ,NIL},;
                            {"D3_QUANT"     ,(c_Alias)->C2_QUANT,NIL},;
                            {"D3_PARCTOT"   , "T"               ,NIL}}


                Begin Transaction

                    MSExecAuto({|x, y| mata250(x, y)},a_Vetor, n_Opc )

                    If lMsErroAuto

                        l_Ret := .F.

                        MostraErro()

                        ProcLogAtu( "ERRO",  "Erro no encerramento da OP de MO do Code Allegre " + c_OPMO + " / " + (c_Alias)->PRODOPMO ,,c_Process,.T. )

                        DisarmTransaction()

                    Endif    

                    // Requisição do Produto Code Allegre MO para OP de Montagem do Code Allegre
                    If l_Ret

                        ProcLogAtu( "MENSAGEM",  "Requisição do Produto Code Allegre MO para OP de Montagem do Code Allegre" ,,c_Process,.T. )

                        c_CodMO := (c_Alias)->PRODOPMO
                        n_Qtd   := (c_Alias)->C2_QUANT
                        c_OP    := (c_Alias)->OPORIG

                        SB1->(dbSetOrder(1))
                        SB1->(MsSeek(FWxFilial("SB1") + c_CodMO ))
    
                        dbSelectArea("SD3")    	
                        c_Docto := CriaVar("D3_DOC")
    
                        If EMPTY(Alltrim(c_Docto))
                           c_Docto := NextNumero("SD3",2,"D3_DOC",.T.)
                        Endif
    
                        AADD( a_CabSD3, {"D3_DOC"		, c_Docto    , NIL})
                        AADD( a_CabSD3, {"D3_TM"       	, c_TipMvR   , NIL})
	            	    AADD( a_CabSD3, {"D3_CC"	    , SB1->B1_CC , NIL})
                        AADD( a_CabSD3, {"D3_EMISSAO"	, d_DtFech	, NIL} )
    
	            	    a_DtItens := {}
	            	    AADD( a_DtItens, {"D3_COD"		, c_CodMO           , NIL})
	            	    AADD( a_DtItens, {"D3_QUANT"  	, n_Qtd             , NIL})
	            	    AADD( a_DtItens, {"D3_LOCAL"	, c_LocPad          , NIL})
	            	    AADD( a_DtItens, {"D3_OP"	    , c_OP              , NIL})
	            	    AADD( a_DtItens, {"D3_CC"	    , SB1->B1_CC        , NIL})
	            	    AADD( a_DtItens, {"D3_CONTA"    , SB1->B1_CONTA     , NIL})
	            	    AADD( a_DtItens, {"D3_UM"       , SB1->B1_UM        , NIL})
    
	            	    AADD( a_Itens, AClone(a_DtItens))
    
                	    If Len( a_Itens ) > 0
	                    	MSExecAuto({|x, y, z| MatA241(x, y, z)}, a_CabSD3, a_Itens, 3)
    
                            If lMsErroAuto
    
                                l_Ret := .F.
    
                                MostraErro()
    
                                ProcLogAtu( "ERRO",  "Erro na inclusão do movimento na SD3 " + c_Docto + " / " + c_CodMO ,,c_Process,.T. )
    
                                DisarmTransaction()
    
                            Endif
    
                        Endif
    
                    Endif

        	    End Transaction

            Endif

            (c_Alias)->(dbSkip())

        Enddo

    Endif

    (c_Alias)->(DbCloseArea())

    RestArea(a_Area)

    If l_Ret

        ProcLogAtu( "FIM",  "Processamento 2 Finalizado com Sucesso." ,,c_Process,.T. )

    Else

        FwAlertError("Ocorreu erro durante o processamento das horas apontadas de Engenharia. Processamento será abortado.","Erro no Processamento")

        ProcLogAtu( "ERRO",  "Ocorreu Erro no Processamento." ,,c_Process,.F. )

    Endif

Return l_Ret
