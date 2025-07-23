#include "protheus.ch"

// Por : Luis Henrique - Leste System
// Em  : 27 / 12 / 2013
// Objetivo :  Importar dados da tabela SZ2 ( intermediaria )  para a tabela SB1 ( Produtos )
//             Os dados da tabela SZ2 são gerados pelo sistema LN e atualizados pelo Protheus na gravação do campo Z2_SITUAC = Y

User Function CAEST001()
	Local _cAlias

	Local _cEmpresa := "01"
	Local _cFilial := "01"
	Local aOpenTable      := {"SZ2","SB1"}
	//Local _nx
	
	Private _aRecSZ2 := {}

	RPCSetType(3)
	RPCSetEnv(_cEmpresa,_cFilial,"","","","",aOpenTable) // Abre todas as tabelas.

	conout('========================================================================================')
	conout('INICIO DA ROTINA: CAEST001 ')

	dbSelectArea("SZ2")

	cQuery  := "SELECT *, SZ2.R_E_C_N_O_ AS RECNOSZ2 "
	cQuery  += " FROM " + RetSqlName("SZ2")+ " SZ2  "
	cQuery  += "WHERE Z2_FILIAL = '"+xfilial("SZ2")+ "' AND "
	cQuery  += " Z2_SITUAC = 'N'  AND "
	//cQuery  += " rtrim(Z2_ERRO) = '' AND "
	cQuery  += " SZ2.D_E_L_E_T_<>'*' "
	cQuery  += " ORDER BY Z2_FILIAL, Z2_COD, Z2_STATUS DESC  "

	_cAlias := CriaTrab(Nil,.F.)
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.T.)

	(_cAlias)->(dbGotop())
	if (_cAlias)->(eof())
		conout("Não foram encontrados registros aptos para importação."+"  -  "+dtoc(date())+"  -  "+time() )
	Endif

	While ! (_cAlias)->(eof())

		GrvSB1(_cAlias)

		(_cAlias)->(dbSkip())

	End
/*
	_cHtml := MontaHtm()
	if SendMail(_cHtml)

		//Atualiza data depois do e-mail enviado, para não reenviar
		For _nx := 1 To Len(_aRecSZ2)
			SZ2->(dbGoTo(_aRecSZ2[_nx]))
			RecLock('SZ2',.F.)
			SZ2->Z2_DTEMAIL := Date()
			SZ2->(MsUnlock())
		Next
	endif
*/
	conout('FIM DA ROTINA: CAEST001 ')
	conout('========================================================================================')

	RpcClearEnv() // Limpa o environment

Return

//____________________________________________
//
//
//____________________________________________
Static Function GrvSB1(_cAlias)
	Local _MsgErro := ""
	Local _nOperacao := iif((_cAlias)->(Z2_STATUS)=="N",3,4)
	Local _cUm := iif( alltrim(upper((_cAlias)->(Z2_UM))) $ "CP|CF","UN", alltrim(upper((_cAlias)->(Z2_UM))) )
	Local TAB_SB1 := {}
	Local _lInc := .T.
	Local _cConta := ""

	//VALIDAÇÕES
	//_____________________________ PRODUTO

	dbSelectArea("SB1")
	dbSetOrder(1)
	if dbSeek(xfilial("SB1")+(_cAlias)->(Z2_COD))
		if (_cAlias)->(Z2_STATUS) == "N"
			_MsgErro := "Produto "+(_cAlias)->(Z2_COD)+" já existente na tabela SB1"

			dbSelectArea("SZ2")
			SZ2->(dbGoTo((_cAlias)->RECNOSZ2))
			Reclock("SZ2",.F.)
			SZ2->Z2_SITUAC := "Y"
			SZ2->(MsUnlock())

		Endif
	Else
		if (_cAlias)->(Z2_STATUS) == "M"
			_MsgErro := "Produto "+(_cAlias)->(Z2_COD)+" não encontrado para modificação"
			_nOperacao := 3
			
		Endif
	Endif

	//______________________________ TIPO

	dbSelectArea("SX5")
	dbSetOrder(1)
	if ! dbSeek(xfilial("SX5")+"02"+ alltrim((_cAlias)->(Z2_TIPO)) )

		_MsgErro := "Tipo "+(_cAlias)->(Z2_TIPO)+ " não encontrado na tabela 02 em SX5"

	Endif

	//______________________________ UNIDADE DE MEDIDA

	dbSelectArea("SAH")
	dbSetOrder(1)
	
	if ! dbSeek(xfilial("SAH") + _cUm  )

		_MsgErro := "Unidade de Medida "+(_cAlias)->(Z2_UM)+ " não encontrado na tabela SAH"

	Endif

	If (_cAlias)->(Z2_TIPO) $ "MP/ME"
		_cConta := "1105010020" // Conta de materia Prima
	ElseIf (_cAlias)->(Z2_TIPO) == "MC"
		_cConta := "1105010010"
	// ElseIf (_cAlias)->(Z2_TIPO) == "ME"
	//	_cConta := "1105010041"	
	EndIf
	//_____________________________
	if !_lInc  //empty(_MsgErro)

		conout(_MsgErro+"  -  "+dtoc(date())+"  -  "+time() )

		if empty(SZ2->Z2_DTEMAIL)

			dbSelectArea("SZ2")
			SZ2->(dbGoTo((_cAlias)->RECNOSZ2))
			Reclock("SZ2",.F.)
			SZ2->Z2_MSGPROC := _MsgErro
			SZ2->(MsUnlock())

		Endif

	Else
		///////////////////////////////////////
		conout("Importando dados da tabela SZ2")
		conout((_cAlias)->(Z2_COD))
		conout((_cAlias)->(Z2_DESC))
		conout((_cAlias)->(Z2_TIPO))
		conout(_cUm)
		conout((_cAlias)->(Z2_LOCPAD))

		aadd(TAB_SB1,{ "B1_COD"    		, (_cAlias)->(Z2_COD)  		, })
		aadd(TAB_SB1,{ "B1_DESC"   		, IIF( EMPTY((_cAlias)->(Z2_DESC)) .OR. ALLTRIM((_cAlias)->(Z2_DESC))=="0" ,"PRODUTO:" + cvaltochar((_cAlias)->(Z2_COD)),(_cAlias)->(Z2_DESC)),})
		aadd(TAB_SB1,{ "B1_TIPO"  		, (_cAlias)->(Z2_TIPO)   	, })
		aadd(TAB_SB1,{ "B1_UM"  		,  _cUm   					, })
		aadd(TAB_SB1,{ "B1_LOCPAD"  	, (_cAlias)->(Z2_LOCPAD)   	, })
		aadd(TAB_SB1,{ "B1_CONTA"  	    , _cConta               	, })
		aadd(TAB_SB1,{ "B1_GARANT"  	, "2"   					, })

		_aTmp := U_SLVetSx3(TAB_SB1,"SB1")
		TAB_SB1 := {}
		TAB_SB1 := _aTmp

		Begin Transaction

			ConOut( Repl( "-", 80 ) )
			ConOut( PadC( "Importacao para a tabela Produtos (SB1) ", 80 ) )
			ConOut( "Inicio: " + Time() )

			lMsErroAuto:= .f.

			MSExecAuto({|x,y| MATA010(x,y)},TAB_SB1,_nOperacao)

			If lMsErroAuto
				_cMsgErro := "ERRO DE MSEXECAUTO"+chr(13)+chr(10)
				    If (!IsBlind()) // COM INTERFACE GRÁFICA
						MostraErro()
					Else // EM ESTADO DE JOB
						cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

						ConOut(PadC("Automatic routine ended with error", 80))
						ConOut("Error: "+ cError)
					EndIf
				// _cMsgErro := MostraErro()


				//ConOut(_cMsgErro)

				dbSelectArea("SZ2")
				SZ2->(dbGoTo((_cAlias)->RECNOSZ2))
				Reclock("SZ2",.F.)
				SZ2->Z2_MSGPROC := _cMsgErro
				SZ2->Z2_DTEMAIL := CTOD('')
				SZ2->(MsUnlock())

			Else

				dbSelectArea("SZ2")
				SZ2->(dbGoTo((_cAlias)->RECNOSZ2))
				Reclock("SZ2",.F.)
				SZ2->Z2_SITUAC := "Y"
				SZ2->Z2_MSGPROC := ''
				SZ2->Z2_DTEMAIL := CTOD('')
				SZ2->(MsUnlock())

				conout("Produto "+(_cAlias)->(Z2_COD)+" Status "+(_cAlias)->(Z2_STATUS)+" processado com sucesso"+"  -  "+dtoc(date())+"  -  "+time() )

			Endif

		End Transaction

	Endif

Return()

//_____________________________________
User Function SLVetSX3(_aVetor,__cAlias)
	Local _aTmpExec := {}

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

/*/{Protheus.doc} MontaHtm
//TODO Dispara email formato html com ocorrências de erro na importação da tabela SZ2
@author josinalvo.melo
@since 25/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MontaHtm()
	Local _cHtml := ''
	Local _cAlias := GetNextAlias()

	BeginSql Alias _cAlias

	SELECT R_E_C_N_O_ SZ2REC
	FROM %Table:SZ2%
	WHERE %NotDel%
	AND Z2_SITUAC = 'N'
	AND Z2_DTEMAIL = ''
	AND Z2_MSGPROC <> ''
	AND Z2_FILIAL = %Exp:xFilial("SZ2")%

	EndSql

	_cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">                                       '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<html>                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<head>                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += '  <meta content="text/html; charset=ISO-8859-1"                                                                 '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' http-equiv="content-type">                                                                                               '
	_cHtml += '                                                                                                                                       '
	_cHtml += '  <title></title>                                                                                                               '
	_cHtml += '                                                                                                                                       '
	_cHtml += '</head>                                                                                                                          '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<body>                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<br>                                                                                                                                '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<span style="font-family: Calibri;">Segue abaixo                                                                  '
	_cHtml += '                                                                                                                                       '
	_cHtml += 'rela&ccedil;&atilde;o de registros que apresentaram erro de                                                    '
	_cHtml += '                                                                                                                                       '
	_cHtml += 'processamento durante a importa&ccedil;&atilde;o da tabela                                                   '
	_cHtml += '                                                                                                                                       '
	_cHtml += 'SZ2&nbsp;</span><br style="font-family: Calibri;">                                                              '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<span style="font-family: Calibri;">&nbsp;para                                                                     '
	_cHtml += '                                                                                                                                       '
	_cHtml += 'cadastro de produtos do sistema Protheus</span>&nbsp; :<br>                                              '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<br>                                                                                                                                '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<table style="text-align: left; width: 100%;" border="1"                                                        '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' cellpadding="2" cellspacing="2">                                                                                        '
	_cHtml += '                                                                                                                                       '
	_cHtml += '  <tbody>                                                                                                                         '
	_cHtml += '                                                                                                                                       '
	_cHtml += '    <tr>                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += '      <td                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' style="text-align: center; width: 143px; font-family: Calibri;">C&oacute;digo</td>                   '
	_cHtml += '                                                                                                                                       '
	_cHtml += '      <td                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' style="text-align: center; width: 311px; font-family: Calibri;">Descri&ccedil;&atilde;o</td>       '
	_cHtml += '                                                                                                                                       '
	_cHtml += '      <td                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' style="width: 51px; text-align: center; font-family: Calibri;">TIPO</td>                                  '
	_cHtml += '                                                                                                                                       '
	_cHtml += '      <td                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' style="text-align: center; width: 55px; font-family: Calibri;">UM</td>                                    '
	_cHtml += '                                                                                                                                       '
	_cHtml += '      <td style="width: 57px; font-family: Calibri;">LOCAL</td>                                               '
	_cHtml += '                                                                                                                                       '
	_cHtml += '      <td                                                                                                                            '
	_cHtml += '                                                                                                                                       '
	_cHtml += ' style="width: 403px; text-align: center; font-family: Calibri;">OCORR&Ecirc;NCIA</td>             '
	_cHtml += '                                                                                                                                       '
	_cHtml += '    </tr>                                                                                                                           '
	_cHtml += '                                                                                                                                       '

	While ! (_cAlias)->(eof())

		SZ2->(dbGoTo((_cAlias)->SZ2REC))
		aAdd(_aRecSZ2,(_cAlias)->SZ2REC)

		_cHtml += '    <tr>                                                                                                                            '
		_cHtml += '                                                                                                                                       '
		_cHtml += '      <td style="width: 143px; font-family: Calibri;">'	+AllTrim(SZ2->Z2_COD)+'</td>                                           '
		_cHtml += '                                                                                                                                       '
		_cHtml += '      <td style="width: 311px; font-family: Calibri;">'	+AllTrim(SZ2->Z2_DESC)+'</td>                   '
		_cHtml += '                                                                                                                                       '
		_cHtml += '      <td style="width: 51px; font-family: Calibri;">'	+AllTrim(SZ2->Z2_TIPO)+'</td>                                                 '
		_cHtml += '                                                                                                                                       '
		_cHtml += '      <td style="width: 55px; font-family: Calibri;">'	+AllTrim(SZ2->Z2_UM)+'</td>                                                   '
		_cHtml += '                                                                                                                                       '
		_cHtml += '      <td style="width: 57px; font-family: Calibri;">'	+AllTrim(SZ2->Z2_LOCPAD)+'</td>                                               '
		_cHtml += '                                                                                                                                       '
		_cHtml += '      <td style="width: 403px; font-family: Calibri;">'	+AllTrim(SZ2->Z2_MSGPROC)+'</td>                            '
		_cHtml += '                                                                                                                                       '
		_cHtml += '    </tr>                                                                                                                           '

		(_cAlias)->(dbSkip())
	End

	_cHtml += '                                                                                                                                       '
	_cHtml += '  </tbody>                                                                                                                       '
	_cHtml += '                                                                                                                                       '
	_cHtml += '</table>                                                                                                                          '
	_cHtml += '                                                                                                                                       '
	_cHtml += '<br>                                                                                                                                '
	_cHtml += '                                                                                                                                       '
	_cHtml += '</body>                                                                                                                           '
	_cHtml += '                                                                                                                                       '
	_cHtml += '</html>                                                                                                                           '

	(_cAlias)->(dbCloseArea())

Return (_cHtml)

Static Function SendMail(_cHtml)

	Local aAnexo 	:= {}
	Local cEmailTo  := ""
	Local cEmailBcc := ""
	Local lResult   := .T.
	Local cError    := ""
	Local lRet	    := .F.
	
	Local _cEmail	:= AllTrim(GetNewPar("CV_MAILEST","henrique@rahro.com.br"))
	Local cServer	:= AllTrim(GetNewPar("MV_RELSERV","mail.rahro.com.br:587"))
	Local cConta	:= AllTrim(GetNewPar("MV_RELACNT","protheus@rahro.com.br"))
	Local xSenha 	:= AllTrim(GetNewPar("MV_RELPSW","!@pr0th3vs@!"))
	Local cFrom   	:= AllTrim(GetNewPar("MV_RELFROM","protheus@rahro.com.br"))
	Local lAuth	 	:= GetNewPar("MV_RELAUTH",.t.)
	

	cAssunto := 'LOG DE PROCESSAMENTO DE IMPORTAÇÃO DE PRODUTO - LN X PROTHEUS'

	cEmailTo := _cEmail
	cMensagem := _cHtml

	if Empty(cEmailTo)
		conout('Falha no envio de e-mail. O parâmetro CV_MAILES não está preenchido')
		lResult := .F.
	endif

	if Empty(cServer)
		conout('Falha no envio de e-mail. O parâmetro MV_RELSERV não está preenchido')
		lResult := .F.
	endif

	if Empty(cConta)
		conout('Falha no envio de e-mail. O parâmetro MV_RELACNT não está preenchido')
		lResult := .F.
	endif

	if Empty(xSenha)
		conout('Falha no envio de e-mail. O parâmetro MV_RELPSW não está preenchido')
		lResult := .F.
	endif

	if Empty(cFrom)
		conout('Falha no envio de e-mail. O parâmetro MV_RELFROM não está preenchido')
		lResult := .F.
	endif

	if lResult
		lResult := MailSmtpOn( cServer, cConta, xSenha, )
	endif

	// Se a conexao com o SMTP esta ok
	If lResult

		// Se existe autenticacao para envio valida pela funcao MAILAUTH
		If lauth
			lRet := Mailauth(cFrom,xSenha)
		Else
			lRet := .T.
		Endif

		If lRet

			lResult := MailSend( cFrom, { cEmailTo },{},{ cEmailBcc }, cAssunto, cMensagem,aAnexo , .F. )

			If !lResult
				//Erro no envio do email
				cError:=MailGetErr( )
				conout(" ",1,"ATENCAO",,cError+ " " + cEmailTo,4,5)
				Conout(" ")

			Endif

		Else
			cError:=MailGetErr( )
			conout(cError)
			conout("Erro de autenticação","Verifique a conta e a senha para envio")
			lResult := .F.
		Endif

		MailSmtpOff()  // Disconnect to Smtp Server

	Else
		//Erro na conexao com o SMTP Server
		cError:=MailGetErr( )
		conout(cError)
	Endif

	if lResult
		conout('E-mail enviado com sucesso para: ' + AllTrim(_cEmail))
	endif

Return(lResult)
