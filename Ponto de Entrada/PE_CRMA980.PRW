#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} CRMA980
    Incluir um Item Contábil após cadastrar algum Cliente/Fornecedor
    ALTERAR PARAMETRO MV_MVCSSA1->A1 PARA .T.
    @type  Function
    @author Felipe Venezuela
    @since 09/11/2023
    /*/
USER Function CRMA980()

	Local   aParam      := PARAMIXB
	Local   oObj        := ''
	Local   cIdPonto    := ''
	Local   cIdModel    := ''
	Local   nOper       := 0
	Local   aArea       := FWGetArea()
	Local   lRet        := .T.
	local   aCTBA060	:= {}

	PRIVATE lMsErroAuto := .F.

	If aParam <> NIL

		oObj        := aParam[1]
		cIdPonto    := aParam[2]
		cIdModel    := aParam[3]

		If cIdPonto == "MODELCOMMITNTTS"
			nOper := oObj:nOperation

			if nOper == 3
				// //Abre a tabela CTD
				// DbSelectArea("CTD")
				// CTD->(DbSetOrder(1))

				// //Se nao conseguir posicionar, registro sera criado
				// If ! CTD->(MsSeek(xFilial("CTD") + 'C' + SA1->A1_COD + "-" + SA1->A1_LOJA))
				//     //Se nao conseguir posicionar, registro sera criado
				//     aAdd( aCTBA040, { 'CTD_ITEM'    , 'C' + SA1->A1_COD + "-" + SA1->A1_LOJA    , Nil } )
				//     aAdd( aCTBA040, { 'CTD_CLASSE'  , '2'                   , Nil } )
				//     aAdd( aCTBA040, { 'CTD_NORMAL'  , '2'                   , Nil } )
				//     aAdd( aCTBA040, { 'CTD_DESC01'  , Alltrim(SA1->A1_NOME) , Nil } )

				//     MsExecAuto( {|ER,UD| CTBA040(ER,UD)}, aCTBA040, 3  )

				//     If lMsErroAuto
				//         MOSTRAERRO()
				//         Alert("Erro ao criar item contábil, favor criar de forma manual.")
				//         Return
				//     ENDIF
				// ENDIF

                DbSelectarea("CTH")
                CTH->(DbSetOrder(1))

				If ! CTH->(DbSeek(FWxFilial("CTH") + 'C' + SA1->A1_COD + "-" + SA1->A1_LOJA))
					aAdd( aCTBA060, { 'CTH_CLVL'    , 'C'+alltrim(SA1->A1_COD)+SA1->A1_LOJA	, Nil } )
					aAdd( aCTBA060, { 'CTH_CLASSE'  , '2'							, Nil } )
					aAdd( aCTBA060, { 'CTH_NORMAL'  , '2'							, Nil } )
					aAdd( aCTBA060, { 'CTH_DESC01'  , Alltrim(SA1->A1_NOME)			, Nil } )

					MsExecAuto( {|ER,UD| CTBA060(ER,UD)}, aCTBA060, 3  )

					If lMsErroAuto .AND. !IsBlind()
						MOSTRAERRO()
						Alert("Erro ao criar classe de valor, favor criá-la de forma manual.")
						Return
					EndIf
				EndIf
			Endif
		Endif
	Endif

	FWRestArea(aArea)

Return (lRet)
