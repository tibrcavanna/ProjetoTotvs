/*/{Protheus.doc} MATA020
Ponto de entrada durante a criação do fornecedor, automatizando a criação de 
item contábil. Para cada fornecedor criado o fonte cria um item contábil com
o mesmo código. 
@type function
@version 1.0
@author Lucas
@since 24/09/2025
/*/
User Function MATA020()

	// local   aCTBA040    := {}
	local   aCTBA060	:= {}
	Local	aAreaCTH	:= CTH->(FwGetArea())

	PRIVATE lMsErroAuto := .F.

	IF INCLUI
		// DbSelectarea("CTD")
		// CTD->(DbSetOrder(1))

		// //Se nao conseguir posicionar, registro sera criado
		// If ! CTD->(DbSeek(FWxFilial("CTD") + 'F'+alltrim(A2_COD)+"-"+A2_LOJA))
		// 	aAdd( aCTBA040, { 'CTD_ITEM'    , 'F'+alltrim(A2_COD)+"-"+A2_LOJA, Nil } )
		// 	aAdd( aCTBA040, { 'CTD_CLASSE'  , '2'                   , Nil } )
		// 	aAdd( aCTBA040, { 'CTD_NORMAL'  , '2'                   , Nil } )
		// 	aAdd( aCTBA040, { 'CTD_DESC01'  , Alltrim(A2_NOME)      , Nil } )

		// 	MsExecAuto( {|ER,UD| CTBA040(ER,UD)}, aCTBA040, 3  )

		// 	If lMsErroAuto
		// 		MOSTRAERRO()
		// 		Alert("Erro ao criar item contábil, favor criar de forma manual.")
		// 		Return
		// 	EndIf
		// EndIf
		
		DbSelectarea("CTH")
		CTH->(DbSetOrder(1))

		//Se nao conseguir posicionar, registro sera criado
		If ! CTH->(DbSeek(FWxFilial("CTH") + 'F'+alltrim(A2_COD)+A2_LOJA))
			aAdd( aCTBA060, { 'CTH_CLVL'    , 'F'+alltrim(A2_COD)+A2_LOJA	, Nil } )
			aAdd( aCTBA060, { 'CTH_CLASSE'  , '2'							, Nil } )
			aAdd( aCTBA060, { 'CTH_NORMAL'  , '1'							, Nil } )
			aAdd( aCTBA060, { 'CTH_DESC01'  , Alltrim(A2_NOME)				, Nil } )

			MsExecAuto( {|ER,UD| CTBA060(ER,UD)}, aCTBA060, 3  )

			If lMsErroAuto .AND. !IsBlind()
				MOSTRAERRO()
				Alert("Erro ao criar classe de valor, favor criá-la de forma manual.")
				Return
			EndIf
		EndIf

		FwRestArea(aAreaCTH)
	ENDIF

Return
