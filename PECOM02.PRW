#INCLUDE "TOTVS.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PECOM02
  Ponto de entrada, apos execauto de gravaÁ„o do SF1, na rotina de ImportaÁ„o do XML.
  TDN :  https://tdn.totvs.com/pages/releaseview.action?pageId=233760407

  Neste fonte, o PE È utilizado para preencher o campos customizado D1_XNCMF (NCM na NF fiscal), usado posteriormente 
  para comparar com o NCM do cadastro de produto e notificar o usaurio em caso de divergencias. 
 
  @type function
  @author Silvio Mota
  @since 11/08/2025
  @history	28/09/2025, Silvio Mota, Inclus„o do tatrativa do campo Lote. Parte do principio que o Lote do XML n„o È confiavel.
  @param 
  @return Nil, undefined, Esta funcao nao tem retorno
  @modified Silvio Nogueira Silva, 08/10/2025, modificar tratativa de comparaÁ„o para n„o utilizar campo na tabela SD1 pelo motivo da SD1 ter atingido o limite de campos na Cavanna
/*/
//-------------------------------------------------------------------------------------------------------------

User Function PECOM02()
	Local cQuery     := ""
	Local _aFields   := {}
	Local cAliasTMP  := GetNextAlias()
	Local _nX        := 0
	Local nI         := 0
	Local cXML       := ""
	Local oXML
	Local cTpDocNCM  := SuperGetMV("FS_TPDOCXM",.F.,"109")
	Local aTpDocNCM  := StrTokArr( cTpDocNCM, "/" )
	Local cTpDocIn   := ""
	Local a_ItensNFE := {}
	Local l_Lote     := .F.
	Local c_LoteCTL  := ""
	Local d_DtValid  := date()

	//PRIVATE _aProdutos := {}

	conout("[COLSTTS] - Inicio ")

	For nI := 1 to Len( aTpDocNCM )
		if valtype(aTpDocNCM[nI]) == "C"
			cTpDocIn += ( iif(nI > 1,"','","") + aTpDocNCM[nI] )
		endif
	Next nI

	aadd(_aFields,{'CKO_RECNO' ,"N",10,0})


	// Cria objeto
	oTempTable := FWTemporaryTable():New( cAliasTMP )

	//Monta os campos da tabela
	oTemptable:SetFields( _aFields )

	//Cria√ß√£o da tabela
	oTempTable:Create()


	// Recuperar o XML gravado na tabela CKO, para obter o NCM do XML
	cQuery := ""
	cQuery += " SELECT  CKO.R_E_C_N_O_ AS CKO_RECNO "
	cQuery += " FROM    "+RetSqlName("SF1")+" SF1 "
	cQuery += "         INNER JOIN " + RetSqlName("SDS") + " SDS ON DS_CHAVENF = F1_CHVNFE "
	cQuery += "         INNER JOIN " + RetSqlName("CKO") + " CKO ON CKO_CHVDOC = F1_CHVNFE "
	cQuery += " WHERE   F1_CHVNFE          = '" + SF1->F1_CHVNFE + "'    "
	cQuery += "         AND SF1.D_E_L_E_T_ = ' ' "
	cQuery += "         AND SDS.D_E_L_E_T_ = ' ' "
	cQuery += "         AND CKO.D_E_L_E_T_ = ' ' "
	If Empty(cTpDocIn)
		cQuery += " AND CKO.CKO_CODEDI = '109'"
	Else
		cQuery += " AND CKO.CKO_CODEDI IN ('"+cTpDocIn+"')"
	EndIf

	cQuery := ChangeQuery(cQuery)
	Processa({||SqlToTrb(cQuery, _aFields, cAliasTMP)})	// Cria arquivo temporario

	If ! (cAliasTMP)->(Eof())
		DbSelectArea("CKO")
		CKO->(DbGoto((cAliasTMP)->CKO_RECNO))
		oXML := TXMLManager():New()
		cXML := CKO->CKO_XMLRET

		// Vai exibir "No errors on Parse!"
		If !oXML:Parse( cXML )
			conout( "[COLSTTS] - Errors on Parse!" )
		Else
			conout( "[COLSTTS] - No errors on Parse!" )
		Endif

		//Registra o NameSpace
		aNS := oXML:XPathGetRootNsList()
		oXML:XPathRegisterNs('ns',aNS[1,2])

		//oXML:XPathGetNodeValue( "/ns:nfeProc/ns:NFe/ns:infNFe/ns:dest/ns:CNPJ" )
		BuildResult(oXml,_aProdutos)

		// Verificar os produtos que j√° possuem amarracao Produtos X Fornecedores
		For _nX := 1 to Len(_aProdutos)

			DbSelectArea("SA5")
			DbSetOrder(14)
			If DbSeek(xFilial("SA5")+SF1->F1_FORNECE+SF1->F1_LOJA+AllTrim(_aProdutos[_nX][1][2])) .and. !Empty(SA5->A5_PRODUTO)

				aAdd(_aProdutos[_nX],{'cProProtheus',SA5->A5_PRODUTO})

				DbSelectArea("SD1")
				DbSetOrder(1)  //  D1_FILIAL + D1_DOC + D1_SERIE +D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
				DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+SA5->A5_PRODUTO)
				Do While !Eof()  .and. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+SA5->A5_PRODUTO == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD)

					If SD1->(FieldPos("D1_XNCMF")) > 0
						SD1->(RecLock("SD1", .F. ))
						SD1->D1_XNCMF := _aProdutos[_nX][2][2]
						SD1->(MsUnLock())
					Else
						If Z06->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+SA5->A5_PRODUTO))
							Z06->(RecLock("Z06", .F. ))
							Z06->Z06_NCMF := _aProdutos[_nX][2][2]
							Z06->(MsUnLock())
						Else
							Z06->(RecLock("Z06", .T. ))
							Z06->Z06_FILIAL	:= SD1->D1_FILIAL
							Z06->Z06_DOC	:= SD1->D1_DOC
							Z06->Z06_SERIE	:= SD1->D1_SERIE
							Z06->Z06_FORNEC	:= SD1->D1_FORNECE
							Z06->Z06_LOJA	:= SD1->D1_LOJA
							Z06->Z06_COD	:= SD1->D1_COD
							Z06->Z06_ITEM	:= SD1->D1_ITEM
							Z06->Z06_NCMF	:= _aProdutos[_nX][2][2]
							Z06->(MsUnLock())
						Endif
					EndIf

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek( xFilial('SB1') + SD1->D1_COD )) .and. SB1->B1_RASTRO $ 'S.L'  //S=SubLote;L=Lote;N=Nao utiliza
						l_Lote    := .T.
						c_LoteCTL := Formula( SB1->B1_FORMLOT )
						d_DtValid := Date() + SB1->B1_PRVALID
					Else
						l_Lote    := .F.
						c_LoteCTL := space(len(SD1->D1_LOTECTL))
						d_DtValid := Date()
					EndIf

					If l_Lote
						SD1->(RecLock("SD1", .F. ))
						SD1->D1_LOTECTL := c_LoteCTL
						SD1->D1_DTVALID := d_DtValid
						SD1->(MsUnLock())
					EndIf

					aAdd( a_ItensNFE , { SD1->D1_ITEM, SD1->D1_COD, Z06->Z06_NCMF } )

					SD1->(DbSkip())
				EndDo
			endif
		Next _nX

		// Compara NCM da NF com o NCM no cadastro do produto
		c_Msg := U_CompNCM( a_ItensNFE )
		If ! empty(c_Msg)
			c_Msg :=  "A NF/Serie " + Alltrim(SF1->F1_DOC) +  "/" + AllTrim(SF1->F1_SERIE) + " do fornecedor " + SF1->F1_FORNECE + "/" + SF1->F1_LOJA  + " (" + Alltrim(Posicione( 'SA2', 1, FWxFilial('SA2') + SF1->F1_FORNECE + SF1->F1_LOJA , 'A2_NOME' )) + "), possui divergencias de NCM em relaÁ„o ao cadastro de produto : <BR>"  + c_Msg

			EventInsert( FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, "508", FW_EV_LEVEL_INFO, "" , "Divergencia NCM NF Entrada", c_Msg, .T. )
		EndIf
	EndIf

	//Exclui a tabela
	oTempTable:Delete()

Return( Nil )



// Monta os dados para um ListBox com os resultados obtidos 
Static Function BuildResult( oXml, _aProdutos, aResult, nStack )
	Local   cRow
	Local   nI
	DEFAULT aResult := {}
	DEFAULT nStack := 1

	Do While .T.
		// Se o n√≥ atual tem um dado, armazena
		If ! XMLempty( oXML:cText )
			cRow := 'Path ['+oXML:cPath+'] Value ['+oXML:cText+']'
			aAdd(aResult,cRow)

			If AllTrim(oXML:cName) == 'prod'
				aAdd(_aProdutos,{})
			Elseif AllTrim(oXML:cName) $ "###cProd##NCM##"
				aAdd(_aProdutos[len(_aProdutos)],{AllTrim(oXML:cName),AllTrim(oXML:cText)})
			EndIf
		Endif

		IF oXml:DOMHASATT()
			// Se o n√≥ atual tem atrubitos, l√™ todos
			aAtt := oXml:DOMGETATTARRAY()
			For nI := 1 to len(aAtt)
				cRow := 'Path ['+oXML:cPath+'] Att ['+aAtt[nI][1]+'] Value ['+aAtt[nI][2]+']'
				aadd(aResult,cRow)
			Next
		Endif

		If oXml:DOMHasChildNode()
			// Se o n√≥ atual tem um filho, entra nele para avaliar o conteudo
			oxml:DOMChildNode()
			BuildResult(oXml,_aProdutos,aResult,nStack+1)
			oxml:DOMParentNode()
		Endif

		IF oXml:DOMHasNextNode()
			// Se existe um pr√≥ximo n√≥ neste nivel,
			// vai pra ele e continua analizando
			oxml:DOMNextNode()
			LOOP
		Endif

		// Este n√≥ j√° foi analizado inteiro, sai do loop
		EXIT
	Enddo
Return



// Remove caracteres irrelevantes do valor de um node 
// para ver se ele √© realmente vazio
Static Function XMLempty( cNodeValue )

	cNodeValue := strtran(cNodeValue,chr(13),'')
	cNodeValue := strtran(cNodeValue,chr(10),'')
	cNodeValue := strtran(cNodeValue,chr(9),'')
	cNodeValue := strtran(cNodeValue,' ','')

Return empty(cNodeValue)

