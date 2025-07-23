#INCLUDE "PROTHEUS.CH"

User Function CAPCP001()

	Local TAB_SC2 := {}

	Local _lErro      := .F.
	Local _cDescErro:= ""
	Local _cLinha     := ""
	Local TAB_SC2    := {}

	Local _cProduto 
	Local _cLocal   
	Local _nQuant   
	Local _dDtIni   
	Local _dDtFim   
	Local _lConout := .t.
	Local aOpenTable      := {"SZ4","SC2","SB1"}
	Local _cAlias := GetNextAlias()                      
	Local _cFilial 
	Local _MsgErro := ""

	RpcClearEnv()
	//RPCSetType(3)
	RPCSetEnv("01","01",,,,,aOpenTable) // Abre todas as tabelas.

	_cFilial := xfilial("SZ4")                                 

	BeginSql Alias _cAlias

	%noparser%

	column Z4_QUANT as Numeric(12,2)     
	column Z4_DATPRI as Date
	column Z4_DATPRF as Date

	Select *, SZ4.R_E_C_N_O_ AS RECNOSZ4 
	From %Table:SZ4% SZ4
	Where %NotDel% AND
	Z4_FILIAL = %Exp:_cFilial% 
	AND Z4_SITUAC = 'N' 
	AND Z4_STSH = 'W'
	Order BY Z4_FILIAL, Z4_NUM, Z4_ITEM, Z4_SEQUEN

	EndSql

	conout("Inicio de importação de dados da tabela SZ4 - Ordens de Produção")


	(_cAlias)->(dbGotop())
	While ! (_cAlias)->(eof())

		//______________________________ UNIDADE DE MEDIDA

		dbSelectArea("SAH")
		dbSetOrder(1)
		if ! dbSeek(xfilial("SAH")+alltrim((_cAlias)->(Z4_UM))  )

			_MsgErro := "Unidade de Medida "+(_cAlias)->(Z4_UM)+ " não encontrado na tabela SAH"

		Endif

		//_____________________________
		if !empty(_MsgErro)

			conout(_MsgErro+"  -  "+dtoc(date())+"  -  "+time() )

			//	dbSelectArea("SZ4")
			//	SZ4->(dbGoTo((_cAlias)->RECNOSZ2))
			//	Reclock("SZ4",.F.)
			//	SZ4->Z4_ERRO := _MsgErro
			//	SZ4->(MsUnlock())

		Else

			if _lConout
				///////////////////////////////////////
				conout("Importando dados da tabela SZ4")

				conout("Produto " 	+ (_cAlias)->Z4_PRODUTO )
				conout("Local " 	+ "01" )
				conout("Quant " 	+ str( (_cAlias)->Z4_QUANT )  )
				conout("Data Ini " 	+ dtoc((_cAlias)->Z4_DATPRI)  )
				conout("Data Fim "	+ dtoc((_cAlias)->Z4_DATPRF)  )
			Endif

			Aadd( TAB_SC2, { "C2_PRODUTO"	,  (_cAlias)->Z4_PRODUTO, })
			Aadd( TAB_SC2, { "C2_LOCAL"     , "01"					, })
			Aadd( TAB_SC2, { "C2_QUANT"     , (_cAlias)->Z4_QUANT 	, })
			if !empty((_cAlias)->Z4_UM)
				Aadd( TAB_SC2, { "C2_UM"     	, (_cAlias)->Z4_UM 	, })
			Endif
			Aadd( TAB_SC2, { "C2_EMISSAO"   , (_cAlias)->Z4_DATPRI 	, })
			Aadd( TAB_SC2, { "C2_DATPRI"    , (_cAlias)->Z4_DATPRI 	, })
			Aadd( TAB_SC2, { "C2_DATPRF"    , (_cAlias)->Z4_DATPRF	, })

			Begin Transaction

				if _lConout
					ConOut( Repl( "-", 80 ) )
					ConOut( PadC( "Importacao para a tabela Ordem de Produção (SC2) ", 80 ) )
					ConOut( "Inicio: " + Time() )
				Endif

				lMsErroAuto:= .f.

				MSExecAuto({|x,y| MATA650(x,y)},TAB_SC2,3)

				If lMsErroAuto

					_cErro := ""
					_cErro := "Erro na inclusão da Ordem de Produção  via MSEXECAUTO "+MostraErro()

					if _lConout
						ConOut(_cErro)
					Endif


					dbSelectArea("SZ4")
					SZ4->(dbGoTo((_cAlias)->RECNOSZ4))
					Reclock("SZ4",.F.)
					SZ4->Z4_STSH	:= "E"
					(_cAlias)->(MsUnlock())


					//U_GRVWSERR(_cChave,_cCodigo+" - "+_cNome+" - "+_cNomeFant,_cErro)

				Else
					_cRet := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN

					dbSelectArea("SZ4")
					SZ4->(dbGoTo((_cAlias)->RECNOSZ4))
					Reclock("SZ4",.F.)
					SZ4->Z4_SITUAC 	:= "Y"
					SZ4->Z4_NUM		:= SC2->C2_NUM
					SZ4->Z4_ITEM	:= SC2->C2_ITEM
					SZ4->Z4_SEQUEN	:= SC2->C2_SEQUEN	
					SZ4->Z4_STSH	:= "S"
					(_cAlias)->(MsUnlock())

					if _lConout
						conout("Gerada a Ordem de Produção "+_cRet)
					Endif
				Endif

			End Transaction

			if _lConout
				ConOut("Date: " + Dtos(dDatabase) + " - Time: " + Time() + " - FIM INCLUSAO ORDEM DE PRODUÇÃO "+_cRet)
			Endif

		Endif

		(_cAlias)->(dbSkip())
	End
	conout("Fim de importação de dados da tabela SZ4")

	(_cAlias)->(dbCloseArea())
	RpcClearEnv() // Limpa o environment

Return .T.

