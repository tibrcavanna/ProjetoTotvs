#include "tbiconn.ch"
#include "protheus.ch"

// Por : Luis Henrique - Leste System
// Em  : 15 / 08 / 2015
// Objetivo :  	Importar dados da tabela SZ8 ( intermediaria )  para a tabela SA2 ( Fornecedores )
//             	Os dados da tabela SZ8 são gerados pelo sistema LN e atualizados pelo Protheus 
//				na gravação do campo Z8_SITUAC = Y

User Function CAFOR001()
	Local _cEmpresa  := "99"		//modificar na base da cavanna
	Local _cFilial   := "01"
	Local aOpenTable := {"SZ8","SA2"}
	Local _calias    := GetNextAlias()

	Default aParams := {"01","01"}
	cCodEmp         := aParams[1]
	cCodFil         := aParams[2]
	ConOut("Montando Ambiente: Empresa " + cCodEmp + " Filial: " + cCodFil)

	RPCSetType(3)
//	RPCSetEnv(_cEmpresa,_cFilial,"","","","",aOpenTable) // Abre todas as tabelas.

	PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial

	BeginSql Alias _cAlias

		SELECT *, R_E_C_N_O_ AS RECNOSZ8
		FROM %Table:SZ8%
		WHERE Z8_FILIAL = %xfilial:SZ8%
		AND Z8_SITUAC = 'N'
		AND %Notdel%
		ORDER BY Z8_FILIAL, Z8_COD, Z8_STATUS DESC

	EndSql

	(_cAlias)->(dbGotop())
	if (_cAlias)->(eof())
		conout("Não foram encontrados registros aptos para importação."+"  -  "+dtoc(date())+"  -  "+time() )
	Endif

	While ! (_cAlias)->(eof())
	
		GrvSA2(_cAlias)
	
		(_cAlias)->(dbSkip())
	
	End

	RESET ENVIRONMENT
//	RpcClearEnv() // Limpa o environment

Return

//____________________________________________
//
//
//____________________________________________
Static Function GrvSA2(_cAlias)
	Local _aMsgErro := array(15)
	Local _nOperacao := iif((_cAlias)->(Z8_STATUS)=="N",3,4)
	Local TAB_SA2 := {}
	Local _nErro := 0
//VALIDAÇÕES

	_lRet := .t.
	if empty((_cAlias)->(Z8_CGC)) 				// CNPJ
		AADD(_aMsgErro ,"Z8_CGC não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_NOME))				// NOME
		AADD(_aMsgErro , "Z8_NOME não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_NREDUZ)) 			//NOME REDUZIDO
		AADD(_aMsgErro , "Z8_NREDUZ não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_END)) 				//ENDEREÇO
		AADD(_aMsgErro , "Z8_END não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_NR_END)) 			//NR° END
		AADD(_aMsgErro ,"Z8_NR_END não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_COMPLEM))			//COMPLEMENTO
		AADD(_aMsgErro , "Z8_COMPLEM não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_BAIRRO))			//BAIRRO
		AADD(_aMsgErro , "Z8_BAIRRO não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_EST))				//ESTADO INICIAIS
		AADD(_aMsgErro ,"Z8_EST não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_COD_MUN))			//CODIGO DO MUNICIPIO
		AADD(_aMsgErro , "Z8_COD_MUN não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_MUN))				//MUNICIPIO
		AADD(_aMsgErro , "Z8_MUN não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_CEP))				//CEP
		AADD(_aMsgErro ,"Z8_CEP não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_TEL))				//TELEFONE
		AADD(_aMsgErro ,"Z8_TEL não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_INSCR))				//INSCRIÇÃO ESTADUAL
		AADD(_aMsgErro , "Z8_INSCR não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_NATUREZ))			//NATUREZA
		AADD(_aMsgErro ,"Z8_NATUREZ não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_STATUS)) 				// STATUS NOVO/MODIFICADO/DELETADO
		AADD(_aMsgErro ,"Z8_STATUS não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z8_SITUAC)) 				// SITUACAO IMPORTADO OU NÃO PELO PROTHEUS
		AADD(_aMsgErro ,"Z8_SITUAC não preenchido ")
	endif


//_____________________________________________________________________________________________

	dbSelectArea("SA2")
	dbSetOrder(3)
	if dbSeek(xfilial("SA2")+(_cAlias)->(Z8_CGC))
		if (_cAlias)->(Z8_STATUS) == "N"
			AADD(_aMsgErro , "Fornecedor "+(_cAlias)->(Z8_COD)+" já existente na tabela SA2")
		
			dbSelectArea("SZ8")
			SZ8->(dbGoTo((_cAlias)->RECNOSZ8))
			Reclock("SZ8",.F.)
			SZ8->Z8_SITUAC := "Y"
			SZ8->(MsUnlock())
		
		elseif (_cAlias)->(Z8_STATUS) == "M"
			_nOperacao := 4
		Endif

	Endif

//_____________________________


	for _nx := 1 to len(_aMsgErro)
		if _aMsgErro[_nx] ==  Nil
			_aMsgErro[_nx] := ""
		Else
			conout(_aMsgErro[_nx]+"  -  "+dtoc(date())+"  -  "+time() )
			_nErro ++
		Endif
	Next
		                                       
	dbSelectArea("SZ8")
	SZ8->(dbGoTo((_cAlias)->RECNOSZ8))
//	Reclock("SZ8",.F.)
//	SZ8->Z8_ERRO := _aMsgErro 		
//	SZ8->(MsUnlock())

	if _nErro == 0
	///////////////////////////////////////
	
		conout("Importando dados da tabela SZ8")
	
		conout((_cAlias)->(Z8_LOJA		))
		conout((_cAlias)->(Z8_NOME		))
		conout((_cAlias)->(Z8_NREDUZ	))
		conout((_cAlias)->(Z8_END		))
		conout((_cAlias)->(Z8_NR_END	))
		conout((_cAlias)->(Z8_BAIRRO	))
		conout((_cAlias)->(Z8_EST		))
		conout((_cAlias)->(Z8_COD_MUN	))
		conout((_cAlias)->(Z8_MUN		))
		conout((_cAlias)->(Z8_CEP		))
		conout((_cAlias)->(Z8_CGC		))
		conout((_cAlias)->(Z8_TEL		))
		conout((_cAlias)->(Z8_INSCR		))
		conout((_cAlias)->(Z8_NATUREZ	))
		conout((_cAlias)->(Z8_TIPO		))
	
			
		aadd(TAB_SA2, {"A2_LOJA"				,"01"					,nil})
		aadd(TAB_SA2, {"A2_NOME"				,(_cAlias)->Z8_NOME		,nil})
		aadd(TAB_SA2, {"A2_NREDUZ"				,(_cAlias)->Z8_NREDUZ	,nil})
		aadd(TAB_SA2, {"A2_END"					,(_cAlias)->Z8_END		,nil})
		aadd(TAB_SA2, {"A2_NR_END"				,(_cAlias)->Z8_NR_END	,nil})
		aadd(TAB_SA2, {"A2_BAIRRO"				,(_cAlias)->Z8_BAIRRO	,nil})
		aadd(TAB_SA2, {"A2_EST"					,(_cAlias)->Z8_EST		,nil})
		aadd(TAB_SA2, {"A2_COD_MUN"				,(_cAlias)->Z8_COD_MUN	,nil})
		aadd(TAB_SA2, {"A2_MUN"					,(_cAlias)->Z8_MUN		,nil})
		aadd(TAB_SA2, {"A2_CEP"					,(_cAlias)->Z8_CEP		,nil})
		aadd(TAB_SA2, {"A2_CGC"					,(_cAlias)->Z8_CGC		,nil})
		aadd(TAB_SA2, {"A2_TEL"					,(_cAlias)->Z8_TEL		,nil})
		aadd(TAB_SA2, {"A2_INSCR"				,(_cAlias)->Z8_INSCR	,nil})
		aadd(TAB_SA2, {"A2_NATUREZ"				,(_cAlias)->Z8_NATUREZ	,nil})
		aadd(TAB_SA2, {"A2_TIPO"				,(_cAlias)->Z8_TIPO		,nil})
		
		_aTmp := U_SLVetSx3(TAB_SA2,"SA2")
		TAB_SA2 := {}
		TAB_SA2 := _aTmp
	
		Begin Transaction
	
			ConOut( Repl( "-", 80 ) )
			ConOut( PadC( "Importacao para a tabela Produtos (SA2) ", 80 ) )
			ConOut( "Inicio: " + Time() )
	
			lMsErroAuto:= .f.
	
			MSExecAuto({|x,y| MATA020(x,y)},TAB_SA2,_nOperacao)
	
			If lMsErroAuto
				ConOut(MostraErro())

			Else
	
		
	
				dbSelectArea("SZ8")
				SZ8->(dbGoTo((_cAlias)->RECNOSZ8))
				Reclock("SZ8",.F.)
				SZ8->Z8_SITUAC := "Y"
				SZ8->Z8_COD	:= SA2->A2_COD
				SZ8->(MsUnlock())
		
		
				conout("Fornecedor "+SZ8->Z8_COD+" Status "+(_cAlias)->(Z8_STATUS)+" processado com sucesso"+"  -  "+dtoc(date())+"  -  "+time() )
			
			Endif
	
		End Transaction
		
	Endif

Return()
