#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEPCP04
  Chamada para processamento do ponto de entrada MT381VLD em PONTOS_PCP

  @type function
  @author Silvio Mota
  @since 13/08/2025
/*/
//-------------------------------------------------------------------------------------------------------------


User Function PEPCP04()
	Local l_Ret    := .T.//Validações do cliente

	If l_Inclui .or. l_Altera
		// Troca produtos fantasmas pelos, seus componentes.
		If TrocaFant()
			If FWAlertYesNo( "O(s) produtos(s) fantasma foram substituidos pelos seus respectivos componentes, conforme revisão da Estrutura de Produto! Continuar?", "Produto fantasma substituido" )
				l_Ret := .T.
			Else
				l_Ret := .F.
			End
		EndIf
	EndIf

RETURN
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TrocaFant
  Função para, na rotina de empenho, multiplo, quando houver itens fantasma, subsituio mesmo pelos seus componentes.
  Função chamada no pronto de entrada MT381VLD.

  @type function
  @author Silvio Mota
  @since 14/08/2025
  @param 
  @return l_Ret, bollean,	retornar .T. se encontrou/trocou itens fantasmas pelos seus componentes.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function TrocaFant()
	Local a_OldArea := GetArea()
	Local l_Ret     := .F.
	Local n_Ind1
	Local n_Ind2
	Local n_Ind3
	Local c_Codigo
	Local n_Quant
	Local l_CtrlRev  := .T.  // Se .T. ativa controle de revisão. Para este fontes, so vai trazer os componente da revisao c_RevAtu.
	Local c_RevAtu
	Local a_CodFant  := {}
	Local a_Estrut   := {}   // { nEstru, cCodigo, cComponente, nQuantItem, cTrt, cGrOpc, cOpc, Recno() } )

	Private nEstru  := 0   // Variavel usada pela funcao Estrut(), chamada a baixo. Nao remover!!


	// Varre o aCols, em busca de codigo fantasma... se encontrar, deleta a linha do aCols e alimenta uma listas (array) de codigos fantasmas
	For n_Ind1 := 1 to len(aCols)

		// Só verificar, linhas não deletadas
		If ! aCols[ n_Ind1, Len(aHeader)+1 ]

			c_Codigo := aCols[ n_Ind1, nPosCod   ]
			n_Quant  := aCols[ n_Ind1, nPosQuant ]

			SB1->(dbSetOrder(1))
			If SB1->(dbSeek( xFilial('SB1') + c_Codigo )) .and. SB1->B1_FANTASM == 'S'
				aAdd( a_CodFant, { c_Codigo, n_Quant , SB1->B1_REVATU } )
				aCols[ n_Ind1 ][ Len(aHeader)+1]  := .T.
			EndIf
		EndIF
	Next


	// Varre a lista de Codigoa Fantasmas (a_CodFanta), obtem seus componentes e inclui no aCols do Empenho
	For n_Ind2 := 1 to len(a_CodFant)
		nEstru     := 0                      // Variavel usada pela funcao Estrut(), chamada a baixo. Nao remover!!
		c_Codigo   := a_CodFant[ n_Ind2, 1 ]
		n_Quant    := a_CodFant[ n_Ind2, 2 ]
		c_RevAtu   := a_CodFant[ n_Ind2, 3 ]
		l_OneLevel := .T.

		// Obtem array da EP de cada Codigo fantasma. No segunte formato, a_Estrut := { { nEstru, cCodigo, cComponente, nQuantItem, cTrt, cGrOpc, cOpc, Recno() } }
		a_Estrut := Estrut( c_Codigo, n_Quant, l_OneLevel, /*lPreEstru*/ , /*lPrdBlq*/ , l_CtrlRev , c_RevAtu )

		//  Varre a EP retornada, e incluir novas linhas no aCols, para cada componente da EP.
		For n_Ind3 := 1 to len(a_Estrut)

			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1") + a_Estrut[n_Ind3,3] ))

				// Adiciona nova linha vazia no aCols
				n_Linha := AddLinACols()

				// Preenche os campos da nova linha do acols com dados da estrutura
				GDFieldPut( "D4_COD"     , a_Estrut[n_Ind3,3]                                     , n_Linha )
				GDFieldPut( "D4_LOCAL"   , RetFldProd(SB1->B1_COD,"B1_LOCPAD")                    , n_Linha )
				GDFieldPut( "D4_QTDEORI" , a_Estrut[n_Ind3,4]                                     , n_Linha )
				GDFieldPut( "D4_QUANT"   , a_Estrut[n_Ind3,4]                                     , n_Linha )
				GDFieldPut( "D4_TRT"     , a_Estrut[n_Ind3,5]                                     , n_Linha )
				GDFieldPut( "D4_DATA"    , dDataBase                                              , n_Linha )
				GDFieldPut( "D4_QTSEGUM" , ConvUM( a_Estrut[n_Ind3,3], a_Estrut[n_Ind3,4], 0, 2 ) , n_Linha )

				// Executa gatilhos para os campos preenchidos
				If ExistTrigger("D4_COD")
					RunTrigger(2, n_Linha, ,"D4_COD"     )
				EndIf
				If ExistTrigger("D4_LOCAL")
					RunTrigger(2, n_Linha, ,"D4_LOCAL"   )
				EndIf
				If ExistTrigger("D4_QTDEORI")
					RunTrigger(2, n_Linha, ,"D4_QTDEORI" )
				EndIf
				If ExistTrigger("D4_QUANT")
					RunTrigger(2, n_Linha, ,"D4_QUANT"   )
				EndIf
				If ExistTrigger("D4_TRT")
					RunTrigger(2, n_Linha, ,"D4_TRT"     )
				EndIf

				l_Ret := .T.
			EndIf
		Next
	Next

	RestArea(a_OldArea)
Return( l_Ret )




// Adiciona nova linha vazia no aCols
Static Function AddLinACols()
	Local n_NewLinha
	Local n_Ind4
	Local c_Campo

	// Adiciona item no acols
	aAdd( aCols, Array(Len(aHeader)+1) )

	n_NewLinha := Len(aCols)

	//Preenche acols com valores iniciais, conforme aHeader
	For n_Ind4 := 1 to Len(aHeader)
		c_Campo := Alltrim(aHeader[ n_Ind4, 2 ])
		If IsHeadRec(c_Campo)
			aCols[ n_NewLinha, n_Ind4 ] := 0
		ElseIf IsHeadAlias(c_Campo)
			aCols[ n_NewLinha, n_Ind4 ] := "SD4"
		Else
			aCols[ n_NewLinha, n_Ind4 ] := CriaVar(c_Campo,.F.)
		EndIf
	Next

	// Mantem deletado, por enquanto....
	aCols[ n_NewLinha, Len(aHeader)+1 ] := .F.

Return( n_NewLinha )
