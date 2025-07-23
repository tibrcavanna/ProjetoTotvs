#Include 'Protheus.ch'



/*/{Protheus.doc} CACOM001
//TODO Integração dos pedidos de compra via tabela fronteira SZ6 - ATIVADO VIA SCHEDULE
@author ricardo.cavalini
@since 30/08/2016
@version undefined

@type function
/*/
User Function CACOM001()
	
	Local _cEmpresa := "99"		//modificar na base da cavanna
	Local _cFilial := "01"
	Local aOpenTable      := {"SZ6","SC7"}
	Local _calias := GetNextAlias()
		
	Private _nPosRecno := 0 
	RPCSetType(3)
	RPCSetEnv(_cEmpresa,_cFilial,"","","","",aOpenTable) // Abre todas as tabelas.


	BeginSql Alias _cAlias
	
	column Z6_EMISSAO as date
	
	%NoParser%

		SELECT *, R_E_C_N_O_ AS RECNOSZ6
		FROM %Table:SZ6%
		WHERE Z6_FILIAL = %xfilial:SZ6%
		AND Z6_SITUAC = 'N'
		AND %Notdel%
		ORDER BY Z6_FILIAL, Z6_ITEM, Z6_PRODUTO, Z6_STATUS DESC

	EndSql
	
	_nPosRecno := RECNOSZ6

	(_cAlias)->(dbGotop())
	if (_cAlias)->(eof())
		conout("Não foram encontrados registros aptos para importação."+"  -  "+dtoc(date())+"  -  "+time() )
	Endif

	While ! (_cAlias)->(eof())
	
		GrvSC7(_cAlias)
	
		(_cAlias)->(dbSkip())
	
	End

	RpcClearEnv() // Limpa o environment

Return

//____________________________________________
//
//
//____________________________________________

Static Function GrvSC7(_cAlias)

	Local _aMsgErro 	:= array(15)
	Local _nOperacao	:= iif((_cAlias)->(Z6_STATUS)=="N",3,4)
	Local SC7_Cab 		:= {}
	Local SC7_Itens		:= {}
	Local _nErro 		:= 0
	Local _cNum			:= GetSxeNum("SC7","C7_NUM")
	Local aCab 			:= {}
	Local aItens		:= {} 
	Local _cFornece 	:= (_cAlias)->Z6_FORNECE
	Local _cStatus		:= (_cAlias)->Z6_STATUS
//VALIDAÇÕES
//___________________________________________________________________________

	_lRet := .t.
	if empty((_cAlias)->(Z6_LNPED)) 					// CODIGO DO PEDIDO LN
		AADD(_aMsgErro ,"Z6_LNPED não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_ITEM)) 						// ITEM
		AADD(_aMsgErro ,"Z6_ITEM não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_PRODUTO)) 					// PRODUTO
		AADD(_aMsgErro ,"Z6_PRODUTO não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_QUANT)) 					// QUANTIDADE
		AADD(_aMsgErro ,"Z6_QUANT não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_PRECO)) 					// PRECO
		AADD(_aMsgErro ,"Z6_PRECO não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_TOTAL)) 					// TOTAL
		AADD(_aMsgErro ,"Z6_TOTAL não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_FORNECE)) 					// FORNECEDOR
		AADD(_aMsgErro ,"Z6_FORNECE não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_CC))	 					// CENTRO DE CUSTO
		AADD(_aMsgErro ,"Z6_CC não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_EMISSAO)) 					// EMISSAO
		AADD(_aMsgErro ,"Z6_EMISSAO não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_COND)) 						// CONDICAO DE PAGAMENTO
		AADD(_aMsgErro ,"Z6_COND não preenchido ")
	endif
	

	_lRet := .t.
	if empty((_cAlias)->(Z6_MOEDA)) 					// MOEDA
		AADD(_aMsgErro ,"Z6_MOEDA não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_STATUS)) 					// STATUS NOVO/MODIFICADO/DELETADO
		AADD(_aMsgErro ,"Z6_STATUS não preenchido ")
	endif

	_lRet := .t.
	if empty((_cAlias)->(Z6_SITUAC)) 					// SITUACAO IMPORTADO OU NÃO PELO PROTHEUS
		AADD(_aMsgErro ,"Z6_SITUAC não preenchido ")
	endif


//_____________________________________________________________________________________________


	dbSelectArea("SC7")
	dbOrderNickName("CA_LN_PED")
	if dbSeek(xfilial("SZ6")+ ALLTRIM((_cAlias)->(Z6_LNPED)))
		if (_cAlias)->(Z6_STATUS) == "N"
			AADD(_aMsgErro , "Pedido de Compra "+(_cAlias)->(Z6_COD)+" já existente na tabela SC7")
		
			dbSelectArea("SZ6")
			SZ6->(dbGoTo(_nPosRecno))
			Reclock("SZ6",.F.)
			SZ6->Z6_SITUAC := "Y"
			SZ6->(MsUnlock())
		
		elseif (_cAlias)->(Z6_STATUS) == "M"
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
		                                       
	dbSelectArea("SZ6")
	SZ6->(dbGoTo(_nPosRecno))

	if _nErro == 0
	///////////////////////////////////////
	
		conout("Importando dados da tabela SZ6")
	
		conout((_cAlias)->(Z6_LNPED		))
		conout((_cAlias)->(Z6_ITEM		))
		conout((_cAlias)->(Z6_PRODUTO	))
		conout((_cAlias)->(Z6_QUANT		))
		conout((_cAlias)->(Z6_PRECO		))
		conout((_cAlias)->(Z6_TOTAL		))
		conout((_cAlias)->(Z6_FORNECE	))
		conout((_cAlias)->(Z6_CC		))
		conout((_cAlias)->(Z6_EMISSAO	))
		conout((_cAlias)->(Z6_NUM		))
		conout((_cAlias)->(Z6_MOEDA		))
		
		//Cabeçalho do PC (SC7_Cab)
		//_______________________________________________________________________________________________
		
				
		aadd(SC7_Cab, {"C7_LOJA"				,'01'						,nil})
		aadd(SC7_Cab, {"C7_FORNECE"				,(_cAlias)->Z6_FORNECE		,nil})
		aadd(SC7_Cab, {"C7_CONTATO"				,(_cAlias)->Z6_CONTATO		,nil})
		aadd(SC7_Cab, {"C7_COND"				,(_cAlias)->Z6_COND			,nil})
		aadd(SC7_Cab, {"C7_FILENT"				,(_cAlias)->Z6_FILENT		,nil})
		aadd(SC7_Cab, {"C7_CC"					,(_cAlias)->Z6_CC 			,nil})
		aadd(SC7_Cab, {"C7_EMISSAO"				,(_cAlias)->Z6_EMISSAO		,nil})
		aadd(SC7_Cab, {"C7_NUM"					,_cNum						,nil})
		aadd(SC7_Cab, {"C7_XLNPED"				,(_cAlias)->Z6_LNPED		,nil})
			
	//	aadd(aCab,SC7_Cab)
	
	//	_aTmp1 := SLVetSx3(SC7_Cab,"SC7")
	//	SC7_Cab := {}
	//	SC7_Cab := _aTmp1
	
	//Itens do PC (SC7_Itens)
		//_______________________________________________________________________________________________
		
	_cLNPED := ALLTRIM((_cAlias)->Z6_LNPED)
		
		While !(_cAlias)->(Eof()) .and. ALLTRIM((_cAlias)->Z6_LNPED) == _cLNPED
			SC7_Itens := {}
			
			aadd(SC7_Itens, {"C7_ITEM"				,(_cAlias)->Z6_ITEM			,nil})
			aadd(SC7_Itens, {"C7_PRODUTO"			,(_cAlias)->Z6_PRODUTO		,nil})
			aadd(SC7_Itens, {"C7_QUANT"				,(_cAlias)->Z6_QUANT		,nil})
			aadd(SC7_Itens, {"C7_PRECO"				,(_cAlias)->Z6_PRECO		,nil})
			aadd(SC7_Itens, {"C7_TOTAL"				,(_cAlias)->Z6_TOTAL		,nil})
			aadd(SC7_Itens, {"C7_MOEDA"				,(_cAlias)->Z6_MOEDA		,nil})
			aadd(SC7_Itens, {"C7_TXMOEDA"			,(_cAlias)->Z6_TXMOEDA		,nil})
			
			aadd(aItens, SC7_Itens)
			(_cAlias)-> (dbSkip())
		End
	
	
	//_______________________________________________________________________________________________	
		
		
	
		_aTmp2 := SLVetSx3(SC7_Itens,"SC7")
		SC7_Itens := {}
		SC7_Itens := _aTmp2
	
		Begin Transaction
	
			ConOut( Repl( "-", 80 ) )
			ConOut( PadC( "Importacao para a tabela Pedido de Compras (SC7) ", 80 ) )
			ConOut( "Inicio: " + Time() )
	
			lMsErroAuto:= .f.
	
			MSExecAuto({|x,y,z,w| MATA120(x,y,z,w)},1,SC7_Cab,aItens,_nOperacao)
	
			If lMsErroAuto
				ConOut(MostraErro())

			Else
		
				dbSelectArea("SZ6")
				SZ6->(dbGoTo(_nPosRecno))
				Reclock("SZ6",.F.)
				SZ6->Z6_SITUAC := "Y"
				SZ6->Z6_NUM	:= SC7->C7_NUM
				SZ6->(MsUnlock())
		
		
				conout("Fornecedor "+_cFornece+" Status "+_cStatus+" processado com sucesso"+"  -  "+dtoc(date())+"  -  "+time() )
			
			
			Endif
	
			ConfirmSx8()
	
		End Transaction
		
	Endif
		
Return


//_____________________________________
Static Function SLVetSX3(_aVetor,__cAlias)
	Local _aTmpExec := {}
	Local _nPos := {}
	
//ORDENA VETOR QUE SERA UTILIZADO POR MSEXECAUTO
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(__cAlias)
	While !Eof().And.(x3_arquivo==__cAlias)

		_nPos := aScan(_aVetor,{|x| alltrim(x[1]) == alltrim(X3_CAMPO)})

		If _nPos > 0
			
			AADD(_aTmpExec,{_aVetor[_nPos][1], _aVetor[_nPos][2],_aVetor[_nPos][3]   })
		
		Endif

		SX3->(dbSkip())

	End

	_aVetor := {}
	_aVetor := _aTmpExec
       
Return(_aVetor)