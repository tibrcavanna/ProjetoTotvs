#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#include 'FWMVCDEF.CH'

#define MVC_VIEWDEF_NAME "VIEWDEF.FSESTX01"

/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} FSESTX01
 Rotina de Custo Estimado para os produtos. O objetivo desta rotina é permitir preencher uma tabela customizada
 contendo os custos estimados por período para determinados produtos.
  
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param	Nil, nil, Esta funcao nao possui parametros.
 @return Nil, undefined, Esta funcao nao tem retorno
-------------------------------------------------------------------------------------------------------------*/
User Function FSESTX01()
	Local a_Area    := FwGetArea()
	Local a_Campos  := {}
	Local n_RetView
	Local a_Pergs    := {}

	Private c_AnoMesI		:= Strzero(Year(dDatabase),4)+Strzero(Month(dDatabase),2)
	Private c_AnoMesF		:= Strzero(Year(dDatabase),4)+Strzero(Month(dDatabase),2)

	Private c_AliasTmp	:= GetNextAlias()
	Private c_Alias1	:= GetNextAlias()
	Private c_Alias2	:= GetNextAlias()

	aAdd( a_Pergs, {1, "Ano/Mes Inicial ?"  , c_AnoMesI   , "@R 9999/99"            , "U_VldPerI()"           , ""  , "",   0, .F. } )
	aAdd( a_Pergs, {1, "Ano/Mes Final ?"  , c_AnoMesF   , "@R 9999/99"            , "U_VldPerF()"           , ""  , "",   0, .F. } )

	If ParamBox( a_Pergs, "Tabela de Valores Estimados",,,,,,,,, .F. )

		c_AnoMesI  :=  M->MV_PAR01
		c_AnoMesF :=  M->MV_PAR02

		aAdd(a_Campos, {"TMP_CODIGO" , "C",  15 , 0})
		aAdd(a_Campos, {"TMP_DESCRI" , "C", 50 , 0})
		aAdd(a_Campos, {"TMP_ANOMES" , "C", 6 , 0})
		aAdd(a_Campos, {"TMP_VALOR"  , "N", 12 , 2})
		aAdd(a_Campos, {"TMP_PERINI" , "C", 6 , 0})
		aAdd(a_Campos, {"TMP_PERFIM" , "C", 6 , 0})

		// Tenho duvida se precisa da tabela temporaria... Avalir se pode retirar...
		oTempTable := FWTemporaryTable():New(c_AliasTmp)
		oTempTable:SetFields(a_Campos)
		oTempTable:AddIndex("1", { "TMP_CODIGO", "TMP_DESCRI", "TMP_ANOMES" } )
		oTempTable:Create()

		aButtons := GetButtons()

    	LoadInfo() // Carrega informações da tabela para grid

		dbSelectArea(c_AliasTmp)
		dbGotop()

		///                    ( cTitulo , cPrograma        , nOperation             , oDlg , bCloseOnOk , bOk        , nPercReducao   , aEnableButtons, bCancel )
		n_RetView := FWExecView('Valor Estimado'  , MVC_VIEWDEF_NAME , MODEL_OPERATION_INSERT ,      , { || .T. } , { || SalvaInfo() } ,                , aButtons      ,         )

		oTempTable:Delete()

	Endif

	FWRestArea(a_Area)

Return(Nil)


/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} GetButtons()
 Função para montar array para habilitar/dessabilitar buttons na tela View do MVC
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	undefined, Esta funcao nao possui parametros.
 @return a_Ret, Array, 		Array com as definições dos botões.
-------------------------------------------------------------------------------------------------------------*/
Static Function GetButtons()
	Local a_Ret := {}

	// Preencher com .T. ou .F. para Habilitar/Desabilitar cada botão
	aAdd( a_Ret, {.F.,Nil} )   //  1 - Copiar
	aAdd( a_Ret, {.F.,Nil} )   //  2 - Recortar
	aAdd( a_Ret, {.F.,Nil} )   //  3 - Colar
	aAdd( a_Ret, {.F.,Nil} )   //  4 - Calculadora
	aAdd( a_Ret, {.F.,Nil} )   //  5 - Spool
	aAdd( a_Ret, {.F.,Nil} )   //  6 - Imprimir
	aAdd( a_Ret, {.T.,Nil} )   //  7 - Confirmar  - Nesta posição é possivel informar {.F., "MEU TEXTO 1" }, apra altera o texto do bottao
	aAdd( a_Ret, {.T.,Nil})    //  8 - Cancelar   - Nesta posição é possivel informar {.F., "MEU TEXTO 2" }, apra altera o texto do bottao
	aAdd( a_Ret, {.F.,Nil} )   //  9 - WalkTrhough
	aAdd( a_Ret, {.F.,Nil} )   // 10 - Ambiente
	aAdd( a_Ret, {.F.,Nil} )   // 11 - Mashup
	aAdd( a_Ret, {.F.,Nil} )   // 12 - Help
	aAdd( a_Ret, {.F.,Nil} )   // 13 - Formulário HTML
	aAdd( a_Ret, {.F.,Nil} )   // 14 - ECM

Return(a_Ret)


/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} ModelDef
 Função para definição do Modelo MVC
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	 undefined, Esta funcao nao possui parametros.
 @return oModel, Object, Objeto MVC definido. 
-------------------------------------------------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel    As object
	Local oStrField := GetModStr1()
	Local oStrGrid  := GetModStr2()

	oModel := MPFormModel():New("MIDMESTX01", /*bVldPre*/, /*bVldPos*/ /*{||fConfirm()},, {||lConfirm := .F.,.t.}*/)

	oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/ )
	oModel:addGrid("GRIDID", "CABID", oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

	oModel:GetModel("GRIDID"):SetOptional(.T.)
	oModel:SetDescription("Valores Estimados")

	// Desabilita deleção de linha no grid
	oModel:GetModel('GRIDID'):SetNoDeleteLine( .T. )

	// É necessário que haja alguma alteração na estrutura Field
	oModel:SetActivate( { |oModel| onActivate(oModel)} )

Return( oModel )


/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} GetModStr1
 Monta o modelo de estrutura de dados do cabecalho
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	 undefined, Esta funcao nao possui parametros.
 @return oStruct, Object, modelo de estrutura de dados.
-------------------------------------------------------------------------------------------------------------*/
Static Function GetModStr1() 
	Local oStruct   := FWFormModelStruct():New()

	oStruct:addTable(c_AliasTmp, {"TMP_PERINI","TMP_PERFIM"}, "Período", {|| "" } )
	oStruct:AddField( "Ano/Mês Inicial", "Ano/Mês Inicial"  , "TMP_PERINI", "C" ,        6,        0, Nil , Nil  , {}     , .F.     , FwBuildFeature( STRUCT_FEATURE_INIPAD, "' '"                  ) , .F. , .F.   , .F. )
	oStruct:AddField( "Ano/Mês Final"  , "Ano/Mês Final"  , "TMP_PERFIM", "C" ,       6,        0, Nil   , Nil  , {}     , .F.     , FwBuildFeature( STRUCT_FEATURE_INIPAD, "' '"                     ) , .F. , .F.   , .F. )

Return( oStruct )

/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} GetModStr2
 Monta o modelo de estrutura de dados do Grid
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	 undefined, Esta funcao nao possui parametros.
 @return oStruct, Object, modelo de estrutura de dados do grid.
-------------------------------------------------------------------------------------------------------------*/
Static Function GetModStr2()
	Local oStruct   := FWFormModelStruct():New()

	oStruct:AddTable(c_AliasTmp, {'TMP_CODIGO','TMP_DESCRI','TMP_ANOMES','TMP_VALOR'}, "Valores" )

	// Adiciona os campo a Estrutura
	//      AddField( cTitulo         , cTooltip        , cIdField    , cTipo, nTamanho, nDecimal, bValid                                          , bWhen, aValues, lObrigat, bInit                                                            , lKey, lNoUpd, lVirtual, cValid )
	oStruct:AddField( "Código"   , "Código"   		,"TMP_CODIGO"   , "C"  ,  15      , 0       , Nil                                             , Nil, {}, .T., FwBuildFeature( STRUCT_FEATURE_INIPAD, c_AliasTmp+"->TMP_CODIGO"   ) , .F., .F., .F. )
	oStruct:AddField( "Descrição"  , "Descrição"	,"TMP_DESCRI"  , "C"  , 50      , 0       , Nil                                             , Nil, {}, .T., FwBuildFeature( STRUCT_FEATURE_INIPAD, c_AliasTmp+"->TMP_DESCRI"  ) , .F., .F., .F. )
	oStruct:AddField( "Ano/Mês"  , "Ano/Mês"		, "TMP_ANOMES"  , "C"  , 6      , 0       , Nil                                             , Nil, {}, .T., FwBuildFeature( STRUCT_FEATURE_INIPAD, c_AliasTmp+"->TMP_ANOMES"  ) , .F., .F., .F. )
    oStruct:AddField( "Valor Estimado" ,"Valor Estimado" 	,"TMP_VALOR", "N"  , 12      , 2       , Nil                                             , Nil, {}, .F., FwBuildFeature( STRUCT_FEATURE_INIPAD, c_AliasTmp+"->TMP_VALOR") , .F., .F., .F. )

Return( oStruct )

/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} ViewDef
 Função para definição do View MVC
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	 undefined, Esta funcao nao possui parametros.
 @return oModel, Object, Objeto View MVC definido. 
-------------------------------------------------------------------------------------------------------------*/
Static Function ViewDef()
	Local oView
	Local oStrCab  := Get1ViewStr()
	Local oStrGrid := Get2ViewStr()

	// Carrega o modelo definido no arquivos fontes FESTX01 (que é esse fonte mesmo)
 	oModel := FWLoadModel("FSESTX01")
	oView  := FwFormView():New()

	oView:setModel(oModel)
	oView:addField("CAB", oStrCab, "CABID")
	oView:addGrid("GRID", oStrGrid, "GRIDID")

	oView:createHorizontalBox("TOCAB", 20 ) //30 )
	oView:createHorizontalBox("TOGRID", 80 )

	oView:setOwnerView("CAB", "TOCAB" )
	oView:setOwnerView("GRID", "TOGRID")

	oView:setDescription( "Valores Estimados" )

Return( oView )



/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} Get1ViewStr
 Monta a estrutura para o objetivo View, ou seja, a definição dos campos 
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	 undefined, Esta funcao nao possui parametros.
 @return oStruct, Object, modelo de estrutura para o objetivo View.
-------------------------------------------------------------------------------------------------------------*/
Static Function Get1ViewStr()
	Local oStruct := FWFormViewStruct():New()	

	//      AddField( cIdField      , cOrdem, cTitulo                , cDescric             , aHelp, cType, cPicture            , bPictVar, cLookUp, lCanChange , cFolder, cGroup, aComboValues, nMaxLenCombo, cIniBrow, lVirtual, cPictVar, lInsertLine )
	oStruct:AddField( "TMP_PERINI"  , "01"  , "Ano/Mês Inicial", "Ano/Mês Inicial"        , Nil  , "C"  , "@R 9999/99"                , Nil     , ""     , .F.        , Nil    , Nil   , Nil     , Nil           , Nil     , Nil     , Nil     , Nil  )
	oStruct:AddField( "TMP_PERFIM"   , "02"  , "Ano/Mês Final" , "Ano/Mês Final"         , Nil  , "C"  , "@R 9999/99" , Nil     , ""     , .F.        , Nil    , Nil   , Nil         , Nil         , Nil     , Nil     , Nil     , Nil  )

Return( oStruct )


/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} Get2ViewStr
 Monta a estrutura para o grid do objetivo View (definição dos campos)
 
 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  Nil, 	 undefined, Esta funcao nao possui parametros.
 @return oStruct, Object, modelo de estrutura para o grid do objetivo View.
-------------------------------------------------------------------------------------------------------------*/
Static Function Get2ViewStr()
	Local oStruct := FWFormViewStruct():New()

	oStruct:AddField( "TMP_CODIGO"  , "01"  , "Código"      , "Código"  , Nil  , "C"  , "@!"                    , Nil     , ""     , .F.        , Nil    , Nil   , Nil         , Nil, Nil, Nil, Nil, Nil )
	oStruct:AddField( "TMP_DESCRI"  , "02"  , "Descrição"   , "Descrição"  , Nil  , "C"  , "@!"                    , Nil     , ""     , .F.        , Nil    , Nil   , Nil         , Nil, Nil, Nil, Nil, Nil )
	oStruct:AddField( "TMP_ANOMES"  , "03"  , "Ano/Mês"     , "Ano/Mês"  , Nil  , "C"  , "@R XXXX/XX"                    , Nil     , ""     , .F.        , Nil    , Nil   , Nil         , Nil, Nil, Nil, Nil, Nil )
	oStruct:AddField( "TMP_VALOR"   , "04"  , "Valor"       , "Valor"     , Nil  , "N"  , "@E 999.99"             , Nil     , ""     , .T.        , Nil    , Nil   , Nil         , Nil, Nil, Nil, Nil, Nil )

Return( oStruct )



/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} OnActivate
 Função de ativação do modelo. Aqui utilizada para carregar o tempo total no campo TMP_TEMPO

 @type function
 @author Silvio Mota
 @since 18/11/2025
 @history	18/11/2025, Silvio Mota, Versão Inicial
 @param  oModel, Object,  Objeto
 @return Nil,  Nulo, Nulo
-------------------------------------------------------------------------------------------------------------*/
Static Function OnActivate(oModel)

	oModel:GetModel("CABID"):SetValue(  'TMP_PERINI' ,  c_AnoMesI )
	oModel:GetModel("CABID"):SetValue(  'TMP_PERFIM',   c_AnoMesF )

	(c_AliasTmp)->(dBGoTop())
	Do While (c_AliasTmp)->(! EOF()) //.And. l_Ret
		(c_AliasTmp)->(dbSkip())
		If (c_AliasTmp)->(! EOF())
			oModel:GetModel("GRIDID"):AddLine()
		Endif
	EndDo

	oModel:GetModel("GRIDID"):SetNoInsertLine( .T. )
	oModel:GetModel("GRIDID"):SetNoDeleteLine( .T. )

Return(Nil)



/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} LoadInfo
 Função de carregar os Centros de Trabalho no Grid

 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  oModel, Object,  Objeto
 @return Nil,  Nulo, Nulo
-------------------------------------------------------------------------------------------------------------
*/
//Static Function LoadInfo(oModel)
Static Function LoadInfo()
	Local o_QryC
	Local c_Query   := ""
    Local c_Alias	:= GetNextAlias()
	Local c_PerIni	:= c_AnoMesI
	Local c_PerFim	:= c_AnoMesF
	Local l_Ret	:= .T.
	Local d_DataIni	:= Ctod('01/'+Substring(c_PerIni,5,2)+'/'+Left(c_PerIni,4))
	Local d_DataFim	:= Ctod('01/'+Substring(c_PerFim,5,2)+'/'+Left(c_PerFim,4))
	Local a_AnoMes	:= {}
	Local c_MesAtu
	Local d_DtAtu

	If Empty(d_DataFim)

		FWAlertInfo( "Ano/Mês Final Inválido" ,  "Informação Inválida" )

		l_Ret := .F.

	Endif

	If l_Ret .And. d_DataFim < d_DataIni

		FWAlertInfo( "Período Digitado Inválido" ,  "Período Inválido" )

		l_Ret := .F.
	
	Endif

	If l_Ret


		d_DtAtu := d_DataIni
		c_QryPer	:= ""
		While d_DtAtu <= d_DataFim

			Aadd(a_AnoMes,Strzero(Year(d_DtAtu),4)+Strzero(Month(d_DtAtu),2))
			c_QryPer += "SELECT '"+Strzero(Year(d_DtAtu),4)+Strzero(Month(d_DtAtu),2)+"' ANOMES "

			c_MesAtu	:= If(Month(d_DtAtu)+1 = 13,'01',Month(d_DtAtu)+1)
			d_DtAtu	:= Ctod(Strzero(day(d_DtAtu),2)+"/"+Strzero(c_MesAtu,2)+"/"+Strzero(Year(d_DtAtu),4))

			If d_DtAtu <= d_DataFim			
				c_QryPer += " UNION ALL "
			Endif

		Enddo

    	If o_QryC == Nil

			c_Query := "SELECT B1_COD,B1_DESC,ANOMES,Z07_VALOR VALOR FROM ? SB1"
			c_Query += "  INNER JOIN ( ? ) X ON ANOMES = ANOMES "
			c_Query += "  LEFT OUTER JOIN ? Z07 ON Z07_FILIAL = B1_FILIAL AND Z07_CODIGO = B1_COD AND Z07_ANOMES = ANOMES AND Z07.D_E_L_E_T_ = ''"
			c_Query += "  WHERE LEFT(B1_COD,3) = 'MOD' AND SB1.D_E_L_E_T_ = ''"

			c_Qry := ChangeQuery(c_Query)
			o_QryC := FWPreparedStatement():New(c_Query)

		Endif

		o_QryC:SetUnsafe(1, RetSqlName( "SB1" ))
		o_QryC:SetUnsafe(2, c_QryPer)
		o_QryC:SetUnsafe(3, RetSqlName( "Z07" ))

		c_Qry	:= o_QryC:GetFixQuery()
	
    	c_Alias	:= MPSysOpenQuery( c_Qry )

		(c_Alias)->(dBGoTop())
		Do While (c_Alias)->(! EOF())

			(c_AliasTmp)->(RecLock(c_AliasTmp,.t.))
			(c_AliasTmp)->TMP_CODIGO	:= (c_Alias)->B1_COD
			(c_AliasTmp)->TMP_DESCRI	:= (c_Alias)->B1_DESC
			(c_AliasTmp)->TMP_ANOMES	:= (c_Alias)->ANOMES
			(c_AliasTmp)->TMP_VALOR		:= (c_Alias)->VALOR

			(c_Alias)->(dbSkip())

		Enddo
		

		If (c_Alias)->(RecCount()) > 990

			FWAlertError( "A geração das informações atingiu limite de registros. Favor diminuir o período à analisar" , "Limite de Registros")
			l_Ret	:= .F.

		Endif

		(c_Alias)->(dbCloseArea())

	Endif

Return(l_Ret)


/*-------------------------------------------------------------------------------------------------------------
 {Protheus.doc} SalvaInfo
 Função para salvar os valores digitados

 @type function
 @author Silvio Nogueira
 @since 26/02/2026
 @history	26/02/2026, Silvio Nogueira, Versão Inicial
 @param  oModel, Object,  Objeto
 @return l_Ret,  Bollean, Sempre verdadeiro.
-------------------------------------------------------------------------------------------------------------
*/
Static Function SalvaInfo( oModel )
	Local a_Area	:= FwGetArea()
	Local l_Ret      := .T.
	Local l_Erro     := .F.
	Local c_MsgErro  := ""
	Local oModelMVC  := FWModelActive()  /// pega o modelo ativo
	Local n_Line

	If FWAlertYesNo("Deseja salvar os valores digitados ?", "Salva Valores" )

		Begin Transaction
			For n_Line := 1 to oModelMVC:GetModel("GRIDID"):Length()

				oModelMVC:GetModel("GRIDID"):GoLine( n_Line )
				c_Codigo	:= oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODIGO"   )
				c_AnoMes	:= oModelMVC:GetModel("GRIDID"):GetValue("TMP_ANOMES"  )
				n_Valor		:= oModelMVC:GetModel("GRIDID"):GetValue("TMP_VALOR")

				Z07->(dbSetOrder(1))
				If !Z07->(dbSeek(xFilial('Z07') + c_Codigo + c_AnoMes )) 
					If !Empty(n_Valor)
						If Z07->(RecLock( "Z07" , .T. )) 
							Z07->Z07_FILIAL	:= xFilial("SC7")
							Z07->Z07_CODIGO	:= c_Codigo
							Z07->Z07_ANOMES	:= c_AnoMes
							Z07->Z07_VALOR	:= n_Valor
							Z07->(dbCommit())
							Z07->(MsUnLock())
						Else
							c_MsgErro := "Não foi possivel reservar o registro do Codigo " + c_CodMod + " para alteração. Os custos não foram gravados no MOD."
							l_Erro    := .T.
							Exit
						EndIf
					Endif
				Else
					If Z07->(RecLock( "Z07" , .F. ))
						Z07->Z07_VALOR	:= n_Valor
						Z07->(MsUnLock())
					Else
						c_MsgErro := "Não foi possivel reservar o registro do Codigo " + c_CodMod + " para alteração. Os custos não foram gravados no MOD."
						l_Erro    := .T.
						Exit
					EndIf
				EndIf
				If l_Erro
					Exit
				EndIf
			Next
			If l_Erro
				DisarmTransaction()
				break
			EndIf
		End Transaction
		If l_Erro
			FWAlertError( c_MsgErro , "Erro ao gravar Vvalores")
		Else
			FWAlertSuccess( "Os valores foram gravador com sucesso!", "Valores gravados" )
		EndIf
	EndIf

	FWRestArea(a_Area)

Return(l_Ret)


User Function VldPerI()

	Local l_Ret	:= .T.
	Local c_PerIni	:= M->MV_PAR01
	Local d_Data	:= '01/'+Substring(c_PerIni,5,2)+'/'+Left(c_PerIni,4)

	If Empty(CtoD(d_Data))

		FWAlertInfo( "Ano/Mês Inicial Inválido" ,  "Informação Inválida" )

		l_Ret := .F.

	Endif

Return l_Ret

User Function VldPerF()
	Local l_Ret	:= .T.
	Local c_PerFim	:= M->MV_PAR02
	Local d_Data	:= '01/'+Substring(c_PerFim,5,2)+'/'+Left(c_PerFim,4)

	If Empty(CtoD(d_Data))

		FWAlertInfo( "Ano/Mês Inicial Inválido" ,  "Informação Inválida" )

		l_Ret := .F.

	Endif

Return l_Ret
