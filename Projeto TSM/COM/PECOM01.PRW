#Include "Protheus.ch"
#Include "FwMvcDef.ch"
/*/{Protheus.doc}
(TELA DE PEDIDO DE COMPRA, OPÇÃO SCs)
@type  function
@author Silvio Nogueira
@since 01/10/2025
@version 01
@description Ponto de Entrada na tela de Inclusão de PC
@           que abre uma tela markbrowse para seleção de SCs
/*/
User Function PECOM01()

    Local oQryC
    Local cAlias
    Local nCampo
    Local aStruct := {}
	Local bOk		:= {|| nOpca := 1, AtuDadosPC(oMrkBrw:data()), oDlgLS:End()}
	Local bCancel	:= {|| oMrkBrw:Deactivate(), oDlgLS:End()}
	Local aColumns	:= {}
    Local aArea     := GetArea()
    Local cPerg     := 'XTSMSC'
    Local aTamanho  := {}
    Local nPosTam
    Local aCpsFilt  := {}

    Private cCodigo
    Private ctmpTela := "TST_" + RetCodUsr()
    Private aCampos := {}
    Private lMsErroAuto
    Private lMostraMsg := .T.
    
    // Grupo de Perguntas XTSMSC para permitir filtro por fornecedor/produto/sc
    Pergunte(cPerg,.T.)

	If oQryC == Nil

        cAlias := GetNextAlias()
    	_cMarca := Space(2)

        cQry := ""
        cQry += "SELECT C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_UM,C1_QUANT,C1_QUJE,C1_CONDPAG,'  ' AS C1_OK,CASE WHEN C1_FORNECE <> '' THEN C1_FORNECE ELSE B1_PROC END [C1_FORNECE] ,CASE WHEN C1_FORNECE <> '' THEN C1_LOJA ELSE B1_LOJPROC END [C1_LOJA] ,C1_SEGUM,C1_XPRECO,C1_TOTAL,C1_QTSEGUM,C1_XPRECO,C1_TOTAL,C1_QTSEGUM,C1_DATPRF,C1_OP FROM ?  SC1"
        cQry += "	INNER JOIN ? SB1 ON SB1.B1_FILIAL = '?' AND SC1.C1_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
        cQry += "WHERE C1_FILIAL= '?' AND "
        //cQry += "C1_PRODUTO='" + cVar             + "' AND "
        cQry += "C1_ACCPROC <> '1' AND "
        cQry += "C1_TPSC <> '2' AND "
        cQry += "C1_QUJE<C1_QUANT AND "
        cQry += "C1_TPOP<>'P' AND "
        cQry += "C1_APROV IN(' ','L') AND "
	    cQry += "C1_FLAGGCT <> '1' AND " //-- Integracao com o Modulo de Gestao de Contratos
	    cQry += "C1_RESIDUO=' ' AND "
	    cQry += "C1_PEDIDO='' AND "
	    cQry += "SC1.D_E_L_E_T_ = ' ' "

        cQry += "AND C1_PRODUTO = ? AND C1_FORNECE = ? AND C1_LOJA = ? AND C1_NUM = ? "

	    cQry += "ORDER BY ?"
	    //cQry += "ORDER BY "+SqlOrder(SC1->(IndexKey()))

		cQry := ChangeQuery(cQry)
		oQryC := FWPreparedStatement():New(cQry)

	EndIf

	oQryC:SetUnsafe(1, RetSqlName( "SC1" ))
	oQryC:SetUnsafe(2, RetSqlName( "SB1" ))
	oQryC:SetUnsafe(3, xFilial( "SB1" ))
	oQryC:SetUnsafe(4, xFilial( "SC1" ))
    oQryC:SetUnsafe(5, If(!Empty(MV_PAR01),"'"+MV_PAR01+"'",'C1_PRODUTO'))
    oQryC:SetUnsafe(6, If(!Empty(MV_PAR02),"'"+MV_PAR02+"'",'C1_FORNECE'))
    oQryC:SetUnsafe(7, If(!Empty(MV_PAR03),"'"+MV_PAR03+"'",'C1_LOJA'))
    oQryC:SetUnsafe(8, If(!Empty(MV_PAR04),"'"+MV_PAR04+"'",'C1_NUM'))
    oQryC:SetUnsafe(9, SqlOrder(SC1->(IndexKey())))

	cQry 	:= oQryC:GetFixQuery()

    cAlias 	:= MPSysOpenQuery( cQry )

    //AAdd(aColumns, FWBrwColumn():New())
    aStruct	:= (cAlias)->(dbStruct())

    // Cria array para definir tamanho das colunas
    Aadd(aTamanho,{'C1_NUM', 80})
    Aadd(aTamanho,{'C1_ITEM', 80})
    Aadd(aTamanho,{'C1_PRODUTO', 100})
    Aadd(aTamanho,{'C1_DESCRI', 180})
    Aadd(aTamanho,{'C1_UM', 80})
    Aadd(aTamanho,{'C1_QUANT', 80})
    Aadd(aTamanho,{'C1_QUJE', 80})
    Aadd(aTamanho,{'C1_CONDPAG', 80})
    Aadd(aTamanho,{'C1_OK', 80})
    Aadd(aTamanho,{'C1_FORNECE', 80})
    Aadd(aTamanho,{'C1_LOJA', 80})
    Aadd(aTamanho,{'C1_SEGUM', 80})
//    Aadd(aTamanho,{'C1_VUNIT', 80})
    Aadd(aTamanho,{'C1_XPRECO', 80})
    Aadd(aTamanho,{'C1_TOTAL', 80})
    Aadd(aTamanho,{'C1_QTSEGUM', 80})
    Aadd(aTamanho,{'C1_DATPRF', 80})
    Aadd(aTamanho,{'C1_OP', 100})

		//MarkBrowse
	For nCampo := 1 To Len( aStruct )
		If	(AllTrim(aStruct[nCampo][1]) $ "C1_NUM,C1_ITEM,C1_PRODUTO,C1_DESCRI,C1_UM,C1_QUANT,C1_QUJE,C1_CONDPAG,C1_OK,C1_FORNECE,C1_LOJA,C1_SEGUM,C1_XPRECO,C1_TOTAL,C1_QTSEGUM,C1_XPRECO,C1_TOTAL,C1_QTSEGUM,C1_DATPRF,C1_OP")
            nPosTam := ascan(aTamanho, {|x| alltrim(x[1]) == AllTrim(aStruct[nCampo][1] )})
			AAdd(aColumns, FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCampo][1] + "}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nCampo][1]))
			//aColumns[Len(aColumns)]:SetSize(aStruct[nCampo][3]*2)
			aColumns[Len(aColumns)]:SetSize(If(nPosTam<>0,aTamanho[nPosTam][2], aStruct[nCampo][3]*2))
			aColumns[Len(aColumns)]:lAutoSize := .F.
			aColumns[Len(aColumns)]:nAlign := If(aStruct[nCampo][2]='N',2,3)
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nCampo][4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SC1", aStruct[nCampo][1]))
		EndIf
		If	(AllTrim(aStruct[nCampo][1]) $ "C1_DATPRF")

            aStruct[nCampo,2]   := "D"

        Endif
	Next nCampo

	For nCampo := 1 To Len( aStruct )

        //Aadd(aCampos, {Left(RetTitle(aStruct[nCampo][1]),10),;
        Aadd(aCampos, {aStruct[nCampo][1],;
                       aStruct[nCampo][2],;
                       aStruct[nCampo][3],;
                       aStruct[nCampo][4];
                      })

        Aadd(aCpsFilt,{aStruct[nCampo][1],;
                       RetTitle(aStruct[nCampo][1]),;
                       aStruct[nCampo][2],;
                       aStruct[nCampo][3],;
                       aStruct[nCampo][4],;
                       PesqPict("SC1", aStruct[nCampo][1]);
                      })

    Next nCampo

    oTempTable:= FWTemporaryTable():New(ctmpTela)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex( "01", {'C1_NUM','C1_ITEM','C1_PRODUTO'} )
    oTempTable:Create()

    If !(cAlias)->(Eof())

        While !(cAlias)->(Eof())

            RecLock(ctmpTela,.T.)
            (ctmpTela)->C1_NUM      := (cAlias)->C1_NUM 
            (ctmpTela)->C1_ITEM     := (cAlias)->C1_ITEM
            (ctmpTela)->C1_PRODUTO  := (cAlias)->C1_PRODUTO
            (ctmpTela)->C1_DESCRI   := (cAlias)->C1_DESCRI
            (ctmpTela)->C1_UM       := (cAlias)->C1_UM
            (ctmpTela)->C1_QUANT    := (cAlias)->C1_QUANT
            (ctmpTela)->C1_QUJE     := (cAlias)->C1_QUJE
            (ctmpTela)->C1_CONDPAG  := (cAlias)->C1_CONDPAG
            (ctmpTela)->C1_FORNECE  := (cAlias)->C1_FORNECE
            (ctmpTela)->C1_LOJA     := (cAlias)->C1_LOJA
            (ctmpTela)->C1_OK       := (cAlias)->C1_OK
            (ctmpTela)->C1_SEGUM    := (cAlias)->C1_SEGUM
            (ctmpTela)->C1_XPRECO    := (cAlias)->C1_XPRECO
            (ctmpTela)->C1_TOTAL    := (cAlias)->C1_TOTAL
            (ctmpTela)->C1_QTSEGUM  := (cAlias)->C1_QTSEGUM
            //(ctmpTela)->C1_VUNIT    := (cAlias)->C1_VUNIT
            (ctmpTela)->C1_DATPRF   := Stod((cAlias)->C1_DATPRF,8)
            (ctmpTela)->C1_OP       := (cAlias)->C1_OP

            (cAlias)->(dbSkip())

        End

    Endif

    (cAlias)->(dbCloseArea())

    //DbSelectArea(cAlias)
    //(cAlias)->(dbGotop())

    _cMarca := GetMark(,ctmpTela,"C1_OK")

	If !(ctmpTela)->(Eof())

		DEFINE MSDIALOG oDlgLS TITLE " Solicitações de Compra " From 300, 0 to 800,800 OF oMainWnd PIXEL 

		oMrkBrw := FWMarkBrowse():New()
		oMrkBrw:oBrowse:SetEditCell(.F.)
		oMrkBrw:SetFieldMark("C1_OK")

        //oMrkBrw:SetQuery(cQry)
        oMrkBrw:SetFields()

        oMrkBrw:SetFieldFilter(aCpsFilt)

		oMrkBrw:SetOwner(oDlgLS)
		oMrkBrw:SetAlias(ctmpTela)

		//oMrkBrw:SetSeek(.T., aPesq)
		oMrkBrw:SetMenuDef("")
		oMrkBrw:AddButton("Confirmar", bOk, NIL, 2) //Confirmar
		oMrkBrw:AddButton("Cancelar", bCancel, NIL, 2) //Cancelar
		//oMrkBrw:bMark	 := {|| VldMark()}
		//oMrkBrw:bAllMark := {||}
        oMrkBrw:SetValid({|| VldMark()})
		oMrkBrw:SetMark( _cMarca, ctmpTela, "C1_OK" )
        oMrkBrw:SetAllMark({|| FWAlertWarning("Serão marcados todos os registros com base nos registros já marcados ou no primeiro da lista.","Informação") , lMostraMsg := .F., oMrkBrw:AllMark(), lMostraMsg := .T. ,oMrkBrw:Refresh(.T.)})
		oMrkBrw:SetDescription("")
		oMrkBrw:SetColumns(aColumns)
		oMrkBrw:SetTemporary(.T.)
        oMrkBrw:SetIgnoreARotina(.T.)
        oMrkBrw:SetLocate({|| .T.})
        oMrkBrw:Refresh(.T.)
        oMrkBrw:GoTop(.T.)
       
		//oMrkBrw:AllMark()
		//oMrkBrw:SetAllMark( { || oMrkBrw:AllMark() } )
		oMrkBrw:Activate()
        (ctmpTela)->(dbGotop())
		ACTIVATE MSDIALOG oDlgLS CENTERED
	Else 
		FWAlertError("Não existem SCs para gerar PC", "Error")
	EndIf

    (ctmpTela)->(dbCloseArea())

    RestArea(aArea)

Return

/*/{Protheus.doc}
(TELA DE PEDIDO DE COMPRA, OPÇÃO "TSM SCs")
@type  function
@author Silvio Nogueira
@since 02/10/2025
@version 01
@description Função para validar se o fornecedor/loja/condição de pagamento do registro
@           selecionado diverge dos demais itens que já estão marcados
/*/
Static Function VldMark()

    Local lRet  := .T.
    Local aArea := GetArea()
    Local cForn
    Local cLoja
    Local cCond
    Local aFwArea       := FwGetArea()
    Local aSaveLines    := FWSaveRows()
    Local lJaMarca      := (ctmpTela)->C1_OK == _cMarca
    Local nPreco

    cForn   := (ctmpTela)->C1_FORNECE
    cLoja   := (ctmpTela)->C1_LOJA
    cCond   := (ctmpTela)->C1_CONDPAG
    nPreco  := (ctmpTela)->C1_XPRECO

    If Empty(cForn + cLoja)

        If lMostraMsg        
   		   FWAlertError("Fornecedor/Loja dessa SC não estão preenchidos,", "Fornecedor/Loja em branco")
        Endif

        lRet := .F.

    Endif

    /*
    If Empty(cCond)

        If lMostraMsg        
       		FWAlertError("Condição de Pagamento dessa SC não está preenchido,", "Cond.Pagamento em branco")
        Endif

        lRet := .F.

    Endif
    */

    If Empty(nPreco)

        If lMostraMsg        
       		FWAlertError("Valor Unitário não está preenchido,", "Vlr.Unit. em branco")
        Endif

        lRet := .F.

    Endif

    (ctmpTela)->(dbGotop())

    While !(ctmpTela)->(Eof()) .And. lRet

        If (ctmpTela)->C1_OK == _cMarca

            If (ctmpTela)->C1_FORNECE+(ctmpTela)->C1_LOJA <> cForn+cLoja

                If lMostraMsg        
        		    FWAlertError("Fornecedor/Loja dessa SC ("+cForn+"/"+cLoja+") diverge das demais SCs selecionadas ("+(ctmpTela)->C1_FORNECE+"/"+(ctmpTela)->C1_LOJA+").", "Divergência Fornecedor")
                Endif
                lRet := .F.

            Endif

            If (ctmpTela)->C1_CONDPAG <> cCond

                If lMostraMsg        
            		FWAlertError("Condição de Pagamento dessa SC ("+cCond+") diverge das demais SCs selecionadas ("+(ctmpTela)->C1_CONDPAG+").", "Divergência Condição de Pagamento")
                Endif
                lRet := .F.

            Endif

        Endif

        If !lRet

            Exit

        Endif

        (ctmpTela)->(dbSkip())


    End

    FWRestArea(aFwArea)

    FWRestRows( aSaveLines )

    RestArea(aArea)

    lRet := If(lJaMarca .And. !lMostraMsg,.F.,lRet)

    //lMostraMsg := .T.

Return lRet

/*/{Protheus.doc}
@type  function
@author Silvio Nogueira
@since 01/10/2025
@version 01
@description Função para efetuar o execauto no PC (MATA120) com base nas SCs selecionadas
/*/
Static Function AtuDadosPC(oDados)

    Local lRet      := .T.
    Local aSC7Header := {}
    Local cCurrentItem := '0000'
    Local aSC7Lines := {}
    Local aTempLine := {}
    Local aRegLines := {}
    Local cCondPag  := SuperGetMv('FS_CONDPG',.F.,'001')

    aSC7Header := {;
        {'C7_FILIAL'    ,cFilAnt                    ,Nil},;
        {'C7_FORNECE'   ,(ctmpTela)->C1_FORNECE     ,Nil},;
        {'C7_LOJA'      ,(ctmpTela)->C1_LOJA        ,Nil},;
        {'C7_COND'      ,If(Empty((ctmpTela)->C1_CONDPAG),cCondPag,(ctmpTela)->C1_CONDPAG)     ,Nil},;
        {'C7_EMISSAO'   ,dDataBase                  ,Nil},;
        {'C7_MOEDA'     ,1                          ,Nil},;
        {'C7_CONTATO'   ,""                         ,Nil},;
        {'C7_FILENT'    ,cFilAnt                    ,Nil},;
        {'C7_TIPO'      ,"1"                        ,Nil},;
        {'C7_TXMOEDA'   ,0                          ,Nil};
    }

    (ctmpTela)->(dbGotop())
    
    While !(ctmpTela)->(Eof())

        If (ctmpTela)->C1_OK == _cMarca

            cCurrentItem := Soma1(cCurrentItem)

            aTempLine := {}
            Aadd(aTempLine,{"C7_ITEM",cCurrentItem,Nil})
            Aadd(aTempLine,{"C7_PRODUTO",(ctmpTela)->C1_PRODUTO,Nil})
            Aadd(aTempLine,{"C7_DESCRI",(ctmpTela)->C1_DESCRI,Nil})
            Aadd(aTempLine,{"C7_QUANT",(ctmpTela)->C1_QUANT,Nil})
            Aadd(aTempLine,{"C7_UM",(ctmpTela)->C1_UM,Nil})
            //Aadd(aTempLine,{"C7_QTSEGUM",(ctmpTela)->C1_QTSEGUM,Nil})
            //Aadd(aTempLine,{"C7_SEGUM",(ctmpTela)->C1_SEGUM,Nil})
            Aadd(aTempLine,{"C7_PRECO",(ctmpTela)->C1_XPRECO,Nil})
            Aadd(aTempLine,{"C7_TOTAL",(ctmpTela)->C1_QUANT*(ctmpTela)->C1_XPRECO,Nil})
            Aadd(aTempLine,{"C7_NUMSC",(ctmpTela)->C1_NUM,Nil})
            Aadd(aTempLine,{"C7_ITEMSC",(ctmpTela)->C1_ITEM,Nil})
            Aadd(aTempLine,{"C7_QTDSOL",(ctmpTela)->C1_QUANT,Nil})
            

            Aadd(aRegLines,aTempLine)

        Endif

        (ctmpTela)->(dbSkip())

    End

    //aSC7Lines := Aclone({aTempLine})
    aSC7Lines := Aclone(aRegLines)

    //Begin Transaction

    If len(aSC7Lines) > 0

        MsExecAuto(;
            {|v,x,y,z,w| MATA120(v,x,y,z,w)},;
            1,;            // 1-Pedido de Compra    2-Autorização de Entrega
            aSC7Header,;
            aSC7Lines,;
            3,;             //3-Inclusão   4-Alteração   5-Exclusão
            .T.;            //.T.-abre a tela de PC        .F.- não apresenta tela
            )

        // Verifica se houve falha
        If lMsErroAuto

            MostraErro()
            DisarmTransaction()
            lRet := .F.

        Endif    

    Else

	    FWAlertError("Nenhum registro foi marcado.", "Registros não Marcados")
        lRet := .f.

    Endif
    //End

Return lRet

