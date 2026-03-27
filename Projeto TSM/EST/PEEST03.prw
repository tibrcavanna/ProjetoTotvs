#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PEEST02
@description: Ponto de Entrada na rotina de recalculo do custo médio de estoque.
Rotina para agrupar os movimentos da tabela de apontamento Z01 e gera movimento na tabela SC2/SD3
@type user function
@version 1.0
@author Silvio Nogueira Silva
@since 22/12/2025
@return lRet - parâmetro indicando que a rotina foi processada corretamente e que pode seguir o fluxo normal
do processamento de recalculo do custo médio
/*/
User Function PEEST03(c_OPCAllegre)

    Local l_Ret := .T.
    Local c_AnoMes  := Left(DtoS(d_DtFech),6)
    Local c_LocPad  := SuperGetMv("FS_LOCPAD",.F.,"01")
    Local c_CAllegre    := If(c_OPCAllegre <> Nil,GetAdvFVal('SC2', 'C2_PRODUTO', xFilial('SC2') + c_OPCAllegre, 1, ''),'')

    Local o_QryC
    Local c_Qry
    Local c_QryCond
    Local c_Alias

    Local o_QryA
    Local c_AliasA
    Local c_QryA

    Local c_CodMO
    Local a_Campos  := {}
    Local c_ProjImp := SuperGetMv("FS_PROJIMP",.F.,"BHI")
    Local c_GrpMO   := SuperGetMv("FS_GRPMO",.F.,"2999")
    Local c_TipMO   := SuperGetMv("FS_TIPMO",.F.,"GN")

    Local c_Item		:= "01"
    Local c_Sequen   := "001"

    Local c_Docto
    Local c_TipMvR  := SuperGetMv("FS_TPMOVS",.F.,"630")

    Local n_Opc     := 3
    Local c_CodCC
    Local c_CodMOD
    Local c_DescRec

    Local n_QtdMO

    Local a_CabSD3  := {}
    Local a_DtItens := {}
    Local a_Itens   := {}

    Local c_NumFull

    Local c_Process	:= ProcName(1)    

    Local a_Area    := GetArea()

    // Mês em fechamento

    // Agrupamento dos registros da tabela Z01 pelos campos Z01_PROJ+Z01_CODPI + Z01_COPER 

    ProcLogAtu( "INICIO",  "Agrupamento dos registros da tabela Z01 pelos campos Z01_PROJ+Z01_CODPI + Z01_COPER" ,,c_Process,.T. )

    c_QryCond := " WHERE LEFT(Z01_DTINI,6) = ? AND Z01.D_E_L_E_T_ = '' AND Z01_OP = '' AND LEFT(Z01_PROJ,3) <> ? AND Z01_OPMO = '' "

    If c_OPCAllegre <> Nil

        c_QryCond   += " AND Z01_CODPI = ?"

    Endif

    If o_QryC == Nil

        c_Qry := "SELECT Z01_PROJ,Z01_CODPI,H1_CCUSTO,H1_DESCRI,SUM(Z01_TOTAL) TOTHOR FROM ? Z01 "
        c_Qry += " INNER JOIN ? SB1 ON B1_FILIAL = ? AND B1_COD = Z01_CODPI AND SB1.D_E_L_E_T_ = '' "
        c_Qry += " INNER JOIN ? SG2 ON G2_FILIAL = ? AND G2_PRODUTO = Z01_CODPI AND G2_CODIGO = SB1.B1_OPERPAD AND G2_OPERAC = Z01_COPER AND SG2.D_E_L_E_T_ = ''"
        c_Qry += " INNER JOIN ? SH1 ON H1_FILIAL = ? AND H1_CODIGO = G2_RECURSO AND SH1.D_E_L_E_T_ = ''"
        c_Qry += c_QryCond
        c_Qry += " GROUP BY Z01_PROJ,Z01_CODPI,H1_CCUSTO,H1_DESCRI "
        c_Qry += " ORDER BY Z01_PROJ,Z01_CODPI,H1_CCUSTO,H1_DESCRI "

        c_Qry := ChangeQuery(c_Qry)
        o_QryC := FWPreparedStatement():New(c_Qry)

    EndIf

    o_QryC:SetUnsafe(1, RetSqlName( "Z01" ))
    o_QryC:SetUnsafe(2, RetSqlName( "SB1" ))
    o_QryC:SetUnsafe(3, xFilial( "SB1" ))
    o_QryC:SetUnsafe(4, RetSqlName( "SG2" ))
    o_QryC:SetUnsafe(5, xFilial( "SG2" ))
    o_QryC:SetUnsafe(6, RetSqlName( "SH1" ))
    o_QryC:SetUnsafe(7, xFilial( "SH1" ))
    o_QryC:SetString(8, c_AnoMes)
    o_QryC:SetString(9, c_ProjImp)

    If c_OPCAllegre <> Nil

        o_QryC:SetString(10, c_CAllegre)

    Endif

    c_Qry   := o_QryC:GetFixQuery()
    c_Alias := MPSysOpenQuery( c_Qry )

    (c_Alias)->(dbGotop())

    While (c_Alias)->(!Eof())

        c_CodMO := Alltrim((c_Alias)->Z01_CODPI)+'MO'

        // Criação do cadastro do produto CodeAllegre+"MO" caso não exista, via execauto na MATA010

        SB1->(dbSetOrder(1))
        If SB1->(!MsSeek(FWxFilial("SB1") + c_CodMO ))

            ProcLogAtu( "MENSAGEM",  "Criação do cadastro do produto CodeAllegre+'MO' caso não exista, via execauto na MATA010" ,,c_Process,.T. )

	    	a_Campos    := {}

            c_DescPI    := GetAdvFVal('SB1', 'B1_DESC', xFIlial('SB1') + (c_Alias)->Z01_CODPI, 1, '')
    
	    	aAdd(a_Campos,{"B1_FILIAL"		, xFilial("SB1")   	,NIL})
	    	aAdd(a_Campos,{"B1_COD"			, c_CodMO  	,".T."})
	    	aAdd(a_Campos,{"B1_GRUPO"		, c_GrpMO   	,NIL})
	    	aAdd(a_Campos,{"B1_DESC"		, Alltrim(c_DescPI) + " - Mão de Obra"  	,NIL})
	    	aAdd(a_Campos,{"B1_TIPO"		, c_TipMO   	,NIL})
	    	aAdd(a_Campos,{"B1_UM"			, "UN"   		,NIL})
	    	aAdd(a_Campos,{"B1_LOCPAD"		, c_LocPad    ,NIL})
	    	aAdd(a_Campos,{"B1_LOCALIZ"		, "N"   ,NIL})
	    	aAdd(a_Campos,{"B1_MRP"		, "N"    ,NIL})

	    	a_CampoCab := aClone(a_Campos)
    
	    	lMsErroAuto := .F.
	    	lMsHelpAuto := .F.
    
	    	Begin Transaction
    
	    			MsExecAuto({|x,y| MATA010(x,y)}, a_CampoCab, 3,.T.)

	    			If lMsErroAuto

	    				_cNomeLog := NomeAutoLog()

	    				MostraErro()

                        ProcLogAtu( "ERRO",  "Erro na inclusão do produto " + c_CodMO ,,c_Process,.T. )

                        l_Ret := .F.

                        DisarmTransaction()

	    			EndIf

	    	End Transaction

        Endif

        // Inclusão da OP do produto CodeAllegre+"MO" caso não exista, via execauto na MATA650
        If l_Ret .And. c_OPCAllegre == Nil

            ProcLogAtu( "MENSAGEM",  "Inclusão da OP do produto CodeAllegre+'MO' caso não exista, via execauto na MATA650" ,,c_Process,.T. )

	    	lMsErroAuto := .F.
	    	lMsHelpAuto := .F.

            SC2->(dbSetOrder(2))
            If SC2->(!MsSeek(FWxFilial("SC2") + c_CodMO ))

                c_NumOP := GetSxeNum("SC2","C2_NUM")
                ConfirmSX8()
                c_NumFull := c_NumOP+c_Item+c_Sequen

                aMATA650 := { 	{'C2_FILIAL' 		,cFilAnt 				,NIL},;
 	    			            {'C2_NUM' 			,c_NumOP 				,NIL},; 
 	    			            {'C2_ITEM' 			,c_Item 				,NIL},; 
 	    			            {'C2_SEQUEN' 		,c_Sequen				,NIL},;
 	    			            {'C2_PRODUTO' 		,c_CodMO 				,NIL},;
 	    			            {'C2_LOCAL' 		,c_LocPad 				,NIL},;
 	    			            {'C2_QUANT' 		,1      				,NIL},;
 	    			            {'C2_EMISSAO' 		,d_DtFech 				,NIL},;
 	    			            {'C2_DATPRI' 		,d_DtFech 				,NIL},;
 	    			            {'C2_DATPRF' 		,DDATABASE 				,NIL},;
 	    			            {'AUTEXPLODE' 		,"N" 					,NIL}}
	        	Begin Transaction

                    msExecAuto({|x,Y| Mata650(x,Y)},aMata650,n_Opc)
    
	                If lMsErroAuto

                        MostraErro()

                        ProcLogAtu( "ERRO",  "Erro na inclusão da OP " + c_NumFull ,,c_Process,.T. )

                        l_Ret   := .F.

	                EndIf

        		End Transaction

            Else 

                c_NumFull := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN

            Endif

        Endif

        If l_Ret

            // Criação da MOD no cadastro de produtos
            ProcLogAtu( "MENSAGEM",  "Criação da MOD no cadastro de produtos" ,,c_Process,.T. )

            //c_CodOper   := (c_Alias)->Z01_COPER
            //c_Recurso   := Posicione('SG2', 1, FWxFilial('SG2') + (c_Alias)->Z01_CODPI + "01" +  c_CodOper, 'G2_RECURSO')
            c_CodCC     := (c_Alias)->H1_CCUSTO
            c_DescRec   := (c_Alias)->H1_DESCRI
            c_CodMOD    := 'MOD'+c_CodCC

            SB1->(dbSetOrder(1))
            If SB1->(!MsSeek(FWxFilial("SB1") + c_CodMOD ))

	        	a_Campos    := {}

	        	aAdd(a_Campos,{"B1_FILIAL"		, xFilial("SB1")   	,NIL})
	        	aAdd(a_Campos,{"B1_COD"			, c_CodMOD   	,".T."})
	        	aAdd(a_Campos,{"B1_GRUPO"		, c_GrpMO   	,NIL})
	        	aAdd(a_Campos,{"B1_DESC"		, "MOD"+c_DescRec  	,NIL})
	        	aAdd(a_Campos,{"B1_TIPO"		, "MO"   	,NIL})
	        	aAdd(a_Campos,{"B1_UM"			, "HR"   		,NIL})
	        	aAdd(a_Campos,{"B1_LOCPAD"		, c_LocPad   ,NIL})
	        	aAdd(a_Campos,{"B1_CC"  		, c_CodCC   ,NIL})

	        	a_CampoCab := aClone(a_Campos)

	        	lMsErroAuto := .F.
	        	lMsHelpAuto := .F.

	        	Begin Transaction

	        			MsExecAuto({|x,y| MATA010(x,y)}, a_CampoCab, 3,.T.)

	        			If lMsErroAuto

	        				_cNomeLog := NomeAutoLog()

	        				MostraErro()

                            ProcLogAtu( "ERRO",  "Erro na inclusão do produto " + c_CodMOD ,,c_Process,.T. )

                            l_Ret := .F.

                            DisarmTransaction()

	        			EndIf

	        	End Transaction

            Endif

        EndIf

        // Gravação via execauto das movimentações das MODs na tabela SD3 e 
        // gravar na tabela Z01 as informações de Z01_CODMO e Z01_OPMO respectivamente aos registros processados

        If l_Ret

            ProcLogAtu( "MENSAGEM",  "Gravação via execauto das movimentações das MODs na tabela SD3" ,,c_Process,.T. )

            If o_QryA == Nil

                c_QryA := "SELECT Z01_PROJ,Z01_CODPI,Z01_COPER,H1_CCUSTO,Z01.R_E_C_N_O_ REG FROM ? Z01 "
                c_QryA += " INNER JOIN ? SG2 ON G2_FILIAL = ? AND G2_PRODUTO = Z01_CODPI AND G2_CODIGO = '01' AND G2_OPERAC = Z01_COPER AND SG2.D_E_L_E_T_ = ''"
                c_QryA += " INNER JOIN ? SH1 ON H1_FILIAL = ? AND H1_CODIGO = G2_RECURSO AND H1_CCUSTO = ? AND SH1.D_E_L_E_T_ = ''"
                c_QryA += c_QryCond
                c_QryA += " AND Z01_CODPI = ?"

                c_QryA := ChangeQuery(c_QryA)
                o_QryA := FWPreparedStatement():New(c_QryA)

            EndIf

            o_QryA:SetUnsafe(1, RetSqlName( "Z01" ))
            o_QryA:SetUnsafe(2, RetSqlName( "SG2" ))
            o_QryA:SetUnsafe(3, xFilial( "SG2" ))
            o_QryA:SetUnsafe(4, RetSqlName( "SH1" ))
            o_QryA:SetUnsafe(5, xFilial( "SH1" ))
            o_QryA:SetString(6, (c_Alias)->(H1_CCUSTO))
            o_QryA:SetString(7, c_AnoMes)
            o_QryA:SetString(8, c_ProjImp)
            o_QryA:SetString(9, (c_Alias)->(Z01_CODPI))

            If c_OPCAllegre <> Nil

                o_QryA:SetString(10, c_CAllegre)

            Endif

            c_CodCC     := (c_Alias)->H1_CCUSTO
            c_CodMOD    := 'MOD'+c_CodCC

            c_QryA 	:= o_QryA:GetFixQuery()
            c_AliasA 	:= MPSysOpenQuery( c_QryA )

            n_QtdMO := (c_Alias)->TOTHOR

            SB1->(dbSetOrder(1))
            SB1->(MsSeek(FWxFilial("SB1") + c_CodMOD ))

            dbSelectArea("SD3")    	
            c_Docto := CriaVar("D3_DOC")

            If EMPTY(Alltrim(c_Docto))
               c_Docto := NextNumero("SD3",2,"D3_DOC",.T.)
            Endif

            If c_OPCAllegre <> Nil

                c_NumFull   := c_OPCAllegre                 

            Endif

	    	a_CabSD3    := {}
	    	a_DtItens   := {}
	    	a_Itens     := {}

            AADD( a_CabSD3, {"D3_DOC"		, c_Docto    , NIL})
            AADD( a_CabSD3, {"D3_TM"       	, c_TipMvR   , NIL})
	    	AADD( a_CabSD3, {"D3_CC"	    , SB1->B1_CC , NIL})
            AADD( a_CabSD3, {"D3_EMISSAO"	, d_DtFech	, NIL} )

	    	AADD( a_DtItens, {"D3_COD"		, c_CodMOD          , NIL})
	    	AADD( a_DtItens, {"D3_QUANT"  	, n_QtdMO           , NIL})
	    	AADD( a_DtItens, {"D3_LOCAL"	, c_LocPad          , NIL})
	    	AADD( a_DtItens, {"D3_OP"	    , c_NumFull         , NIL})
	    	AADD( a_DtItens, {"D3_CC"	    , SB1->B1_CC        , NIL})
	    	AADD( a_DtItens, {"D3_CONTA"    , SB1->B1_CONTA     , NIL})
	    	AADD( a_DtItens, {"D3_UM"       , SB1->B1_UM        , NIL})

	    	AADD( a_Itens, AClone(a_DtItens))

            Begin Transaction

        	    If Len( a_Itens ) > 0
	            	MSExecAuto({|x, y, z| MatA241(x, y, z)}, a_CabSD3, a_Itens, 3)

                    If lMsErroAuto

                        MostraErro()

                        ProcLogAtu( "ERRO",  "Erro na inclusão do movimento na SD3 " + c_Docto + " / " + c_CodMOD ,,c_Process,.T. )

                        l_Ret := .F.

                        DisarmTransaction()

                    Endif

                Endif


                If l_Ret

                    ProcLogAtu( "MENSAGEM",  "Gravando na tabela Z01 as informações de Z01_CODMO e Z01_OPMO respectivamente aos registros processados" ,,c_Process,.T. )

                    l_Ret   := .F.

                    (c_AliasA)->(dbGotop())

                    While (c_AliasA)->(!Eof())

                        Z01->(dbGoto((c_AliasA)->REG))

                        Reclock("Z01",.F.)
                        Z01->Z01_CODMO  := c_CodMO
                        Z01->Z01_OPMO   := c_NumFull

                        l_Ret   := .T.

                        Z01->(MsUnlock())

                        (c_AliasA)->(dbSkip())

                    Enddo

                    If !l_Ret

                        DisarmTransaction()

                    Endif

                Endif

            End Transaction

            (c_AliasA)->(DbCloseArea())

        Endif

        (c_Alias)->(dbSkip())

    Enddo

    (c_Alias)->(DbCloseArea())

    RestArea(a_Area)

    If l_Ret

        ProcLogAtu( "FIM",  "Processamento 1 Finalizado com Sucesso." ,,c_Process,.T. )

    Else

        FwAlertError("Ocorreu erro durante o processamento das horas apontadas de Engenharia. Processamento será abortado.","Erro no Processamento")

        ProcLogAtu( "ERRO",  "Ocorreu Erro no Processamento." ,,c_Process,.F. )

    Endif

Return l_Ret
