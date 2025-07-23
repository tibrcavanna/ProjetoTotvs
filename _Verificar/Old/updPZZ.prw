#INCLUDE 'PROTHEUS.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � UPDPZZ   � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de update dos dicion�rios para compatibilizacao     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � UPDPZZ   - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function UPDPZZ()

Local   aSay     := {}
Local   aButton  := {}
Local   aMarcadas:= {}
Local   cTitulo  := 'ATUALIZA��O DE DICION�RIOS E TABELAS'
Local   cDesc1   := 'Esta rotina tem como fun��o fazer a atualiza��o dos dicion�rios do Sistema ( SX?/SIX ) '
Local   cDesc2   := 'Este processo deve ser executado em modo EXCLUSIVO, ou seja n�o podem haver outros '
Local   cDesc3   := 'usu�rios  ou  jobs utilizando  o sistema.  � extremamente recomendav�l  que  se  fa�a um '
Local   cDesc4   := 'BACKUP  dos DICION�RIOS  e da  BASE DE DADOS antes desta atualiza��o,  para que '
Local   cDesc5   := 'caso ocorra eventuais falhas, esse backup seja ser restautado '
Local   cDesc6   := ''
Local   cDesc7   := ''
Local   lOk      := .F.

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch()  } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch()  } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk
	aMarcadas := EscEmpresa()

	If !Empty( aMarcadas )
		If  ApMsgNoYes( 'Confirma a atualiza��o dos dicion�rios ?', cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, 'Atualizando', 'Aguarde , atualizando ...', .F. )
			oProcess:Activate()

			If lOk
				Final( 'Atualiza��o Conclu�da' )
			Else
				Final( 'Atualiza��o n�o Realizada' )
			EndIf

		Else
			Final( 'Atualiza��o n�o Realizada' )

		EndIf

	Else
		Final( 'Atualiza��o n�o Realizada' )

	EndIf

EndIf

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSTProc  � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao dos arquivos           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSTProc  - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   cTexto    := ''
Local   cFile     := ''
Local   cAux      := ''
Local   cMask     := 'Arquivos Texto (*.TXT) |*.txt|'
Local   nRecno    := 0
Local   nI        := 0
Local   nX        := 0
Local   nPos      := 0
Local   aRecnoSM0 := {}
Local   aInfo     := {}
Local   lOpen     := .F.
Local   lRet      := .T.

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0Ex() )

	dbSelectArea( 'SM0' )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		  .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 2 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.

			cTexto += Replicate( '-', 128 ) + CRLF
			cTexto += 'Empresa : ' + SM0->M0_CODIGO + '/' + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 7 )

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX2         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de arquivos - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...'  )
			cTexto += FSAtuSX2()

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX3         �
			//������������������������������������
			cTexto += FSAtuSX3()

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SIX         �
			//������������������������������������
			oProcess:IncRegua1( 'Dicion�rio de indices - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			cTexto += FSAtuSIX()

			oProcess:IncRegua1( 'Dicion�rio de dados - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			oProcess:IncRegua2( 'Atualizando campos/indices')


			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			For nX := 1 To Len( aArqUpd )

				If Select( aArqUpd[nx] ) > 0
					dbSelectArea( aArqUpd[nx] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nx] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					Aviso( 'ATEN��O', 'Ocorreu um erro desconhecido durante a atualizacao da tabela : ' + aArqUpd[nx] + '. Verifique a integridade do dicion�rio e da tabela.', { 'Continuar' }, 2 )
					cTexto += 'Ocorreu um erro desconhecido durante a atualizacao da estrutura da tabela : ' + aArqUpd[nx] + CRLF
				EndIf

			Next nX

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX6         �
			//������������������������������������
			//oProcess:IncRegua1( 'Dicion�rio de par�metros - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...'  )
			//cTexto += FSAtuSX6()

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX7         �
			//������������������������������������
			//oProcess:IncRegua1( 'Dicion�rio de gatilhos ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...'  )
			//cTexto += FSAtuSX7()

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SXA         �
			//������������������������������������
			//oProcess:IncRegua1( 'Dicion�rio de pastas ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...'  )
			//cTexto += FSAtuSXA()

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SXB         �
			//������������������������������������
			//oProcess:IncRegua1( 'Dicion�rio de consultas padr�o - ' + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...'  )
			//cTexto += FSAtuSXB()

			//����������������������������������Ŀ
			//�Atualiza o dicion�rio SX5         �
			//������������������������������������
			//oProcess:IncRegua1( 'Dicion�rio de tabelas sistema - '  + SM0->M0_CODIGO + ' ' + SM0->M0_NOME + ' ...' )
			//cTexto += FSAtuSX5()

			RpcClearEnv()

			If !( lOpen := MyOpenSm0Ex() )
				Exit
			EndIf

		Next nI

		If lOpen

			cAux += Replicate( '-', 128 ) + CRLF
			cAux += Replicate( ' ', 128 ) + CRLF
			cAux += 'LOG DA ATUALIZACAO DOS Dicion�rioS' + CRLF
			cAux += Replicate( ' ', 128 ) + CRLF
			cAux += Replicate( '-', 128 )  + CRLF
			cAux += CRLF
			cAux += ' Dados Ambiente'        + CRLF
			cAux += ' --------------------'  + CRLF
			cAux += ' Empresa / Filial...: ' + cEmpAnt + '/' + cFilAnt  + CRLF
			cAux += ' Nome Empresa.......: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_NOMECOM', cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
			cAux += ' Nome Filial........: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
			cAux += ' DataBase...........: ' + DtoC( dDataBase )  + CRLF
			cAux += ' Data / Hora........: ' + DtoC( Date() ) + ' / ' + Time()  + CRLF
			cAux += ' Environment........: ' + GetEnvServer()  + CRLF
			cAux += ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' )  + CRLF
			cAux += ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' )  + CRLF
			cAux += ' Versao.............: ' + GetVersao(.T.)  + CRLF
			cAux += ' Modulo.............: ' + GetModuleFileName()  + CRLF
			cAux += ' Usuario Microsiga..: ' + __cUserId + ' ' +  cUserName + CRLF
			cAux += ' Computer Name......: ' + GetComputerName()  + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += ' '  + CRLF
				cAux += ' Dados Thread'  + CRLF
				cAux += ' --------------------'  + CRLF
				cAux += ' Usuario da Rede....: ' + aInfo[nPos][1] + CRLF
				cAux += ' Estacao............: ' + aInfo[nPos][2] + CRLF
				cAux += ' Programa Inicial...: ' + aInfo[nPos][5] + CRLF
				cAux += ' Environment........: ' + aInfo[nPos][6] + CRLF
				cAux += ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) )  + CRLF
			EndIf
			cAux += Replicate( '-', 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto

			__cFileLog := MemoWrite( CriaTrab( , .F. ) + '.LOG', cTexto )

			Define Font oFont Name 'Mono AS' Size 5, 12

			Define MsDialog oDlg Title 'Atualizacao concluida.' From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, '' ), If( cFile == '', .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel // Salva e Apaga //'Salvar Como...'

			Activate MsDialog oDlg Center

		EndIf

	EndIf
Else

	lRet := .F.

EndIf

Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX2 � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX2 - Arquivos      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX2 - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX2()
Local aSX2     := {}
Local aEstrut  := {}
Local nI       := 0
Local nJ       := 0
Local cAlias   := ''
Local cTexto   := 'Inicio da Atualizacao do SX2' + CRLF + CRLF
Local cPath    := ''
Local cNome    := ''
Local cModo    := ''

aEstrut := { 'X2_CHAVE', 'X2_PATH', 'X2_ARQUIVO', 'X2_NOME'  , 'X2_NOMESPA', 'X2_NOMEENG', ;
             'X2_DELET', 'X2_MODO', 'X2_TTS'    , 'X2_ROTINA', 'X2_PYME' }

dbSelectArea('SX2')
SX2->(DbSetOrder(1))
MsSeek('SA1') //Seleciona a tabela que eh padrao do sistema para pegar algumas informacoes
cPath := SX2->X2_PATH
cNome := Substr(SX2->X2_ARQUIVO,4,5)
cModo := SX2->X2_MODO

//
// Tabela PZZ
//
aAdd( aSX2, { ;
	'PZZ'																	, ; // Chave
	cPath																	, ; // Path
	'PZZ'+cNome																, ; // Arquivo
	'CHAMADOS MICROSIGA'													, ; // Nome
	'CHAMADOS MICROSIGA'													, ; // Nome SPA
	'CHAMADOS MICROSIGA'													, ; // Nome ENG
	0																		, ; // Delet
	'E'																		, ; // Modo
	''																		, ; // TTS
	''																		, ; // Rotina
	''																		} ) // Pyme

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( 'SX2' )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + '/'
			cTexto += 'Foi inclu�da a tabela ' + aSX2[nI][1] + CRLF
		EndIf

		RecLock( 'SX2', .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == 'X2_ARQUIVO'
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  '0' )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		oProcess:IncRegua2( 'Atualizando Arquivos (SX2)...')

	EndIf

Next nI

cTexto += CRLF + CRLF + 'Final da Atualizacao do SX2' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX3 � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX3 - Campos        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX3 - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX3()
Local aSX3     := {}
Local aEstrut  := {}
Local nI       := 0
Local nJ       := 0
Local nTamSeek := Len( SX3->X3_CAMPO )
Local cAlias   := ''
Local cTexto   := 'Inicio da Atualizacao do SX3' + CRLF + CRLF

aEstrut := { 'X3_ARQUIVO', 'X3_ORDEM'  , 'X3_CAMPO'  , 'X3_TIPO'   , 'X3_TAMANHO', 'X3_DECIMAL', ;
             'X3_TITULO' , 'X3_TITSPA' , 'X3_TITENG' , 'X3_DESCRIC', 'X3_DESCSPA', 'X3_DESCENG', ;
             'X3_PICTURE', 'X3_VALID'  , 'X3_USADO'  , 'X3_RELACAO', 'X3_F3'     , 'X3_NIVEL'  , ;
             'X3_RESERV' , 'X3_CHECK'  , 'X3_TRIGGER', 'X3_PROPRI' , 'X3_BROWSE' , 'X3_VISUAL' , ;
             'X3_CONTEXT', 'X3_OBRIGAT', 'X3_VLDUSER', 'X3_CBOX'   , 'X3_CBOXSPA', 'X3_CBOXENG', ;
             'X3_PICTVAR', 'X3_WHEN'   , 'X3_INIBRW' , 'X3_GRPSXG' , 'X3_FOLDER' , 'X3_PYME'   }


//
// Tabela SZB
//
aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'01'																	, ; // Ordem
	'ZZ_FILIAL'																, ; // Campo
	'C'																		, ; // Tipo
	2																		, ; // Tamanho
	0																		, ; // Decimal
	'Filial'																, ; // Titulo
	'Sucursal'																, ; // Titulo SPA
	'Branch'																, ; // Titulo ENG
	'Filial do Sistema'														, ; // Descricao
	'Sucursal'																, ; // Descricao SPA
	'Branch of the System'													, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	1																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'N'																		, ; // Browse
	''																		, ; // Visual
	''																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'02'																	, ; // Ordem
	'ZZ_CHAMADO'															, ; // Campo
	'C'																		, ; // Tipo
	6																		, ; // Tamanho
	0																		, ; // Decimal
	'No.Chamado'															, ; // Titulo
	'No.Chamado'															, ; // Titulo SPA
	'No.Chamado'															, ; // Titulo ENG
	'Numero do Chamado'														, ; // Descricao
	'Numero do Chamado'														, ; // Descricao SPA
	'Numero do Chamado'														, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'GETSXENUM("PZZ","ZZ_CHAMADO")'											, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	'Existchav("PZZ")'														, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'03'																	, ; // Ordem
	'ZZ_TITULO'																, ; // Campo
	'C'																		, ; // Tipo
	50																		, ; // Tamanho
	0																		, ; // Decimal
	'Titulo'																, ; // Titulo
	'Titulo'																, ; // Titulo SPA
	'Titulo'																, ; // Titulo ENG
	'Titulo'																, ; // Descricao
	'Titulo'																, ; // Descricao SPA
	'Titulo'																, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'04'																	, ; // Ordem
	'ZZ_NOME'																, ; // Campo
	'C'																		, ; // Tipo
	20																		, ; // Tamanho
	0																		, ; // Decimal
	'Usuario'																, ; // Titulo
	'Usuario'																, ; // Titulo SPA
	'Usuario'																, ; // Titulo ENG
	'Usuario'																, ; // Descricao
	'Usuario'																, ; // Descricao SPA
	'Usuario'																, ; // Descricao ENG
	'@R'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'USRRETNAME(RETCODUSR())'												, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'05'																	, ; // Ordem
	'ZZ_NNOME'																, ; // Campo
	'C'																		, ; // Tipo
	50																		, ; // Tamanho
	0																		, ; // Decimal
	'Nome'																	, ; // Titulo
	'Nome'																	, ; // Titulo SPA
	'Nome'																	, ; // Titulo ENG
	'Nome'																	, ; // Descricao
	'Nome'																	, ; // Descricao SPA
	'Nome'																	, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'U_RETNAME()'															, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'06'																	, ; // Ordem
	'ZZ_TEL'																, ; // Campo
	'C'																		, ; // Tipo
	20																		, ; // Tamanho
	0																		, ; // Decimal
	'Telefone'																, ; // Titulo
	'Telefone'																, ; // Titulo SPA
	'Telefone'																, ; // Titulo ENG
	'Telefone'																, ; // Descricao
	'Telefone'																, ; // Descricao SPA
	'Telefone'																, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'07'																	, ; // Ordem
	'ZZ_EMAIL'																, ; // Campo
	'C'																		, ; // Tipo
	50																		, ; // Tamanho
	0																		, ; // Decimal
	'E-mail'																, ; // Titulo
	'E-mail'																, ; // Titulo SPA
	'E-mail'																, ; // Titulo ENG
	'E-mail'																, ; // Descricao
	'E-mail'																, ; // Descricao SPA
	'E-mail'																, ; // Descricao ENG
	'@R'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'U_RETMAIL()'															, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'08'																	, ; // Ordem
	'ZZ_DEPTO'																, ; // Campo
	'C'																		, ; // Tipo
	30																		, ; // Tamanho
	0																		, ; // Decimal
	'Departamento'															, ; // Titulo
	'Departamento'															, ; // Titulo SPA
	'Departamento'															, ; // Titulo ENG
	'Departamento'															, ; // Descricao
	'Departamento'															, ; // Descricao SPA
	'Departamento'															, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'U_RETDEPTO()'															, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'N'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'09'																	, ; // Ordem
	'ZZ_DTCHAM'																, ; // Campo
	'D'																		, ; // Tipo
	8																		, ; // Tamanho
	0																		, ; // Decimal
	'Dt.Abertura'															, ; // Titulo
	'Dt.Abertura'															, ; // Titulo SPA
	'Dt.Abertura'															, ; // Titulo ENG
	'Data Abertura Chamado'													, ; // Descricao
	'Data Abertura Chamado'													, ; // Descricao SPA
	'Data Abertura Chamado'													, ; // Descricao ENG
	'dd/mm/yyyy'															, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'Date()'																, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'10'																	, ; // Ordem
	'ZZ_HRCHAM'																, ; // Campo
	'C'																		, ; // Tipo
	8																		, ; // Tamanho
	0																		, ; // Decimal
	'Hr.Chamado'															, ; // Titulo
	'Hr.Chamado'															, ; // Titulo SPA
	'Hr.Chamado'															, ; // Titulo ENG
	'Hora Abertura Chamado'													, ; // Descricao
	'Hora Abertura Chamado'													, ; // Descricao SPA
	'Hora Abertura Chamado'													, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'Time()'																, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'12'																	, ; // Ordem
	'ZZ_PROBLEM'															, ; // Campo
	'C'																		, ; // Tipo
	6																		, ; // Tamanho
	0																		, ; // Decimal
	'Problema'																, ; // Titulo
	'Problema'																, ; // Titulo SPA
	'Problema'																, ; // Titulo ENG
	'Tipo de Problema'														, ; // Descricao
	'Tipo de Problema'														, ; // Descricao SPA
	'Tipo de Problema'														, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	'ZG'																	, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'13'																	, ; // Ordem
	'ZZ_DESCRI'																, ; // Campo
	'M'																		, ; // Tipo
	10																		, ; // Tamanho
	0																		, ; // Decimal
	'Descricao'																, ; // Titulo
	'Descricao'																, ; // Titulo SPA
	'Descricao'																, ; // Titulo ENG
	'Descricao do Chamado'													, ; // Descricao
	'Descricao do Chamado'													, ; // Descricao SPA
	'Descricao do Chamado'													, ; // Descricao ENG
	''																		, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	'INCLUI'																, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'14'																	, ; // Ordem
	'ZZ_PRIORID'															, ; // Campo
	'C'																		, ; // Tipo
	1																		, ; // Tamanho
	0																		, ; // Decimal
	'Prioridade'															, ; // Titulo
	'Prioridade'															, ; // Titulo SPA
	'Prioridade'															, ; // Titulo ENG
	'Prioridade'															, ; // Descricao
	'Prioridade'															, ; // Descricao SPA
	'Prioridade'															, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'A'																		, ; // Visual
	'R'																		, ; // Context
	'�'																		, ; // Obrigat
	'PERTENCE("123")'														, ; // Vlduser
	'1=Alta;2=Media;3=Baixa'												, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'15'																	, ; // Ordem
	'ZZ_ANALIST'															, ; // Campo
	'C'																		, ; // Tipo
	15																		, ; // Tamanho
	0																		, ; // Decimal
	'Analista'																, ; // Titulo
	'Analista'																, ; // Titulo SPA
	'Analista'																, ; // Titulo ENG
	'Analista Responsavel'													, ; // Descricao
	'Analista Responsavel'													, ; // Descricao SPA
	'Analista Responsavel'													, ; // Descricao ENG
	'@R'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'16'																	, ; // Ordem
	'ZZ_CLASSIF'															, ; // Campo
	'C'																		, ; // Tipo
	20																		, ; // Tamanho
	0																		, ; // Decimal
	'Classificaca'															, ; // Titulo
	'Classificaca'															, ; // Titulo SPA
	'Classificaca'															, ; // Titulo ENG
	'Classificacao do Chamado'												, ; // Descricao
	'Classificacao do Chamado'												, ; // Descricao SPA
	'Classificacao do Chamado'												, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'17'																	, ; // Ordem
	'ZZ_HISTOR'																, ; // Campo
	'M'																		, ; // Tipo
	10																		, ; // Tamanho
	0																		, ; // Decimal
	'Historico'																, ; // Titulo
	'Historico'																, ; // Titulo SPA
	'Historico'																, ; // Titulo ENG
	'Historico'																, ; // Descricao
	'Historico'																, ; // Descricao SPA
	'Historico'																, ; // Descricao ENG
	''																		, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'N'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'18'																	, ; // Ordem
	'ZZ_DTENCER'															, ; // Campo
	'D'																		, ; // Tipo
	8																		, ; // Tamanho
	0																		, ; // Decimal
	'Data Encerra'															, ; // Titulo
	'Data Encerra'															, ; // Titulo SPA
	'Data Encerra'															, ; // Titulo ENG
	'Data de Encerramento'													, ; // Descricao
	'Data de Encerramento'													, ; // Descricao SPA
	'Data de Encerramento'													, ; // Descricao ENG
	'dd/mm/yyyy'															, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'19'																	, ; // Ordem
	'ZZ_HRENCER'															, ; // Campo
	'C'																		, ; // Tipo
	8																		, ; // Tamanho
	0																		, ; // Decimal
	'Hora Encerra'															, ; // Titulo
	'Hora Encerra'															, ; // Titulo SPA
	'Hora Encerra'															, ; // Titulo ENG
	'Hora de Encerramento'													, ; // Descricao
	'Hora de Encerramento'													, ; // Descricao SPA
	'Hora de Encerramento'													, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	''																		, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'20'																	, ; // Ordem
	'ZZ_STATUS'																, ; // Campo
	'C'																		, ; // Tipo
	1																		, ; // Tamanho
	0																		, ; // Decimal
	'Status Cham.'															, ; // Titulo
	'Status Cham.'															, ; // Titulo SPA
	'Status Cham.'															, ; // Titulo ENG
	'Status do Chamado'														, ; // Descricao
	'Status do Chamado'														, ; // Descricao SPA
	'Status do Chamado'														, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'"A"'																	, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'S'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	'A=ABERTO;B=EM ANDAMENTO;C=CANCELADO;D=ENCERRADO;E=EM APROVACAO'		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

aAdd( aSX3, { ;
	'PZZ'																	, ; // Arquivo
	'21'																	, ; // Ordem
	'ZZ_IDUSER'																, ; // Campo
	'C'																		, ; // Tipo
	6																		, ; // Tamanho
	0																		, ; // Decimal
	'Id.do Usuari'															, ; // Titulo
	'Id.do Usuari'															, ; // Titulo SPA
	'Id.do Usuari'															, ; // Titulo ENG
	'Id.Usuario'															, ; // Descricao
	'Id.Usuario'															, ; // Descricao SPA
	'Id.Usuario'															, ; // Descricao ENG
	'@!'																	, ; // Picture
	''																		, ; // Valid
	'���������������'														, ; // Usado
	'RETCODUSR()'															, ; // Relacao
	''																		, ; // F3
	0																		, ; // Nivel
	'��'																	, ; // Reserv
	''																		, ; // Check
	''																		, ; // Trigger
	'U'																		, ; // Propri
	'N'																		, ; // Browse
	'V'																		, ; // Visual
	'R'																		, ; // Context
	''																		, ; // Obrigat
	''																		, ; // Vlduser
	''																		, ; // Cbox
	''																		, ; // Cbox SPA
	''																		, ; // Cbox ENG
	''																		, ; // Pictvar
	''																		, ; // When
	''																		, ; // Inibrw
	''																		, ; // SXG
	''																		, ; // Folder
	''																		} ) // Pyme

//
// Atualizando dicion�rio
//
aSort( aSX3,,, { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( 'SX3' )
dbSetOrder( 2 )
cAliasAtu := ''

For nI := 1 To Len( aSX3 )

	SX3->( dbSetOrder( 2 ) )

		If !SX3->( dbSeek( PadR( aSX3[nI][3], nTamSeek ) ) )

			If !( aSX3[nI][1] $ cAlias )
				cAlias += aSX3[nI][1] + '/'
				aAdd( aArqUpd, aSX3[nI][1] )
			EndIf

			//
			// Busca ultima ocorrencia do alias
			//
			If ( aSX3[nI][1] <> cAliasAtu )
				cSeqAtu   := '00'
				cAliasAtu := aSX3[nI][1]

				dbSetOrder( 1 )
				SX3->( dbSeek( cAliasAtu + 'ZZ', .T. ) )
				dbSkip( -1 )

				If ( SX3->X3_ARQUIVO == cAliasAtu )
					cSeqAtu := X3_ORDEM
				EndIf
			EndIf

			cSeqAtu := Soma1( cSeqAtu )

			RecLock( 'SX3', .T. )
			For nJ := 1 To Len( aSX3[nI] )
				If     nJ == 2    // Ordem
					FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

				ElseIf FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

				EndIf
			Next nJ
		dbCommit()
		MsUnLock()

		cTexto += 'Criado o campo ' + aSX3[nI][3] + CRLF

	Else

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) )   .AND. ;
				StrTran( AllToChar( SX3->( FieldGet( nJ ) )  ), ' ', '' ) <> ;
				StrTran( AllToChar( aSX3[nI][nJ]             ), ' ', '' ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> 'X3_ORDEM'

				If ApMsgNoYes( 'O campo ' + aSX3[nI][3] + ' est� com o ' + SX3->( FieldName( nJ ) ) + ;
					' com o conte�do' + CRLF + ;
					'[' + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + ']' + CRLF + ;
					', que ser� substituido pelo NOVO conte�do' + CRLF + ;
					'[' + RTrim( AllToChar( aSX3[nI][nJ] ) ) + ']' + CRLF + ;
					'Deseja substituir ? ', 'Confirmar substitui��o de conte�do' )

					RecLock( 'SX3', .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()

					If !( aSX3[nI][1] $ cAlias )
						cAlias += aSX3[nI][1] + '/'
						aAdd( aArqUpd, aSX3[nI][1] )
					EndIf

					cTexto += 'Alterado o campo ' + aSX3[nI][3] + CRLF

				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2(  'Atualizando Campos de Tabelas (SX3)...' )

Next nI

cTexto += CRLF + CRLF + 'Final da Atualizacao do SX3' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSIX � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SIX - Indices       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSIX - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSIX()
Local cTexto   := 'Inicio da Atualizacao do SIX' + CRLF + CRLF
Local cAlias   := ''
Local lDelInd  := .F.
Local aSIX     := {}
Local aEstrut  := {}
Local nI       := 0
Local nJ       := 0

aEstrut := { 'INDICE', 'ORDEM', 'CHAVE', 'DESCRICAO', 'DESCSPA', 'DESCENG', 'PROPRI', 'F3', 'NICKNAME', 'SHOWPESQ' }


//
// Tabela PZZ
//
aAdd( aSIX, { ;
	'PZZ'																	, ; // Indice
	'1'																		, ; // Ordem
	'ZZ_FILIAL+ZZ_STATUS+ZZ_CHAMADO'										, ; // Chave
	'Status Cham.+No.Chamado'												, ; // Descricao
	'Id.do Usuari+Status Cham.+No.Chamado'									, ; // Descricao SPA
	'Id.do Usuari+Status Cham.+No.Chamado'									, ; // Descricao ENG
	'U'																		, ; // Proprietario
	''																		, ; // F3
	''																		, ; // Nickname
	''																		} ) // Showpesq

aAdd( aSIX, { ;
	'PZZ'																	, ; // Indice
	'2'																		, ; // Ordem
	'ZZ_FILIAL+ZZ_CHAMADO'													, ; // Chave
	'No.Chamado'															, ; // Descricao
	'No.Chamado'															, ; // Descricao SPA
	'No.Chamado'															, ; // Descricao ENG
	'U'																		, ; // Proprietario
	''																		, ; // F3
	''																		, ; // Nickname
	''																		} ) // Showpesq

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( 'SIX' )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( 'SIX', .T. )
		lDelInd := .F.
		cTexto += '�ndice criado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
	Else
		RecLock( 'SIX', .F. )
		lDelInd := .T.  // Se for alteracao precisa apagar o indice do banco
		cTexto += '�ndice alterado ' + aSIX[nI][1] + '/' + aSIX[nI][2] + ' - ' + aSIX[nI][3] + CRLF
	EndIf

	If StrTran( Upper( AllTrim( CHAVE )       ), ' ', '') <> ;
	   StrTran( Upper( AllTrim( aSIX[nI][3] ) ), ' ', '' )
		aAdd( aArqUpd, aSIX[nI][1] )

		If !( aSIX[nI][1] $ cAlias )
			cAlias += aSIX[nI][1] + '/'
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + '|' + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	oProcess:IncRegua2( 'Atualizando �ndices...' )

Next nI

cTexto += CRLF + CRLF + 'Final da Atualizacao do SIX' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX6 � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX6 - Par�metros    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX6 - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX6()
Local aSX6    := {}
Local aEstrut := {}
Local nI      := 0
Local nJ      := 0
Local cAlias  := ''
Local cTexto  := 'Inicio da Atualizacao do SX6' + CRLF + CRLF
Local lReclock  := .T.
Local lContinua := .T.

aEstrut := { 'X6_FIL'    , 'X6_VAR'  , 'X6_TIPO'   , 'X6_DESCRIC', 'X6_DSCSPA' , 'X6_DSCENG' , 'X6_DESC1'  , 'X6_DSCSPA1',;
             'X6_DSCENG1', 'X6_DESC2', 'X6_DSCSPA2', 'X6_DSCENG2', 'X6_CONTEUD', 'X6_CONTSPA', 'X6_CONTENG', 'X6_PROPRI' }

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( 'SX6' )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .T.
	lReclock  := .T.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], 2 ) + PadR( aSX6[nI][2], Len( SX6->X6_VAR) ) ) )
		lReclock  := .F.

		If StrTran( SX6->X6_CONTEUD, ' ', '' ) <> StrTran( aSX6[nI][13], ' ', '' )
			lContinua :=  ApMsgNoYes( 'O parametro ' + aSX6[nI][2] + ' est� com o conte�do' + CRLF + ;
			'[' + RTrim( StrTran( SX6->X6_CONTEUD, ' ', '' ) ) + ']' + CRLF + ;
			', que � ser� substituido pelo NOVO conte�do ' + CRLF + ;
			'[' + RTrim( StrTran( aSX6[nI][13]  , ' ', ''  ) ) + ']' + CRLF + ;
			'Deseja substituir ? ', 'Confirmar substitui��o de conte�do' )
		Else
			lContinua := .F.
		EndIf

	EndIf

	If lContinua

		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + '/'
		EndIf

		RecLock( 'SX6', .T. )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		cTexto += 'Foi inclu�do o par�metro ' + aSX6[nI][1] + aSX6[nI][2] + ' Conte�do [' + aSX6[nI][13]+ ']'+ CRLF

		oProcess:IncRegua2( 'Atualizando Arquivos (SX6)...')

	EndIf

Next nI

cTexto += CRLF + CRLF + 'Final da Atualizacao do SX6' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX7 � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX7 - Gatilhos      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX7 - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX7()
Local aSX7     := {}
Local aEstrut  := {}
Local nI       := 0
Local nJ       := 0
Local nTamSeek := Len( SX7->X7_CAMPO )
Local cAlias   := ''
Local cTexto   := 'Inicio da Atualizacao do SX7' + CRLF + CRLF

aEstrut := { 'X7_CAMPO', 'X7_SEQUENC', 'X7_REGRA', 'X7_CDOMIN', 'X7_TIPO', 'X7_SEEK', ;
             'X7_ALIAS', 'X7_ORDEM'  , 'X7_CHAVE', 'X7_PROPRI', 'X7_CONDIC' }

cTexto += CRLF + CRLF + 'Final da Atualizacao do SX7' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSXA � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SXA - Pastas        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSXA - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSXA()
Local aSXA     := {}
Local aEstrut  := {}
Local nI       := 0
Local nJ       := 0
Local cAlias   := ''
Local cTexto   := 'Inicio da Atualizacao do SXA' + CRLF + CRLF

aEstrut := { 'XA_ALIAS', 'XA_ORDEM', 'XA_DESCRIC', 'XA_DESCSPA', 'XA_DESCENG', 'XA_PROPRI' }

cTexto += CRLF + CRLF + 'Final da Atualizacao do SXA' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSXB � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SXB - Consultas Pad ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSXB - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSXB()
Local aSXB     := {}
Local aEstrut  := {}
Local nI       := 0
Local nJ       := 0
Local cAlias   := 'Inicio da Atualizacao do SXB' + CRLF + CRLF
Local cTexto   := ''

aEstrut := { 'XB_ALIAS', 'XB_TIPO', 'XB_SEQ', 'XB_COLUNA', 'XB_DESCRI', 'XB_DESCSPA', 'XB_DESCENG', 'XB_CONTEM' }


//
// Consulta PA1
//
aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'1'																		, ; // Tipo
	'01'																	, ; // Sequencia
	'DB'																	, ; // Coluna
	'Cadastro de Veiculos'													, ; // Descricao
	'Cadastro de Veiculos'													, ; // Descricao SPA
	'Cadastro de Veiculos'													, ; // Descricao ENG
	'PA1'																	} ) // Contem

aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'2'																		, ; // Tipo
	'01'																	, ; // Sequencia
	'01'																	, ; // Coluna
	'Placa'																	, ; // Descricao
	'Placa'																	, ; // Descricao SPA
	'Placa'																	, ; // Descricao ENG
	''																		} ) // Contem

aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'3'																		, ; // Tipo
	'01'																	, ; // Sequencia
	'01'																	, ; // Coluna
	'Cadastra Novo'															, ; // Descricao
	'Incluye Nuevo'															, ; // Descricao SPA
	'Add New'																, ; // Descricao ENG
	'01'																	} ) // Contem

aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'4'																		, ; // Tipo
	'01'																	, ; // Sequencia
	'01'																	, ; // Coluna
	'Placa'																	, ; // Descricao
	'Placa'																	, ; // Descricao SPA
	'Placa'																	, ; // Descricao ENG
	'PA1_PLACA'																} ) // Contem

aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'4'																		, ; // Tipo
	'01'																	, ; // Sequencia
	'02'																	, ; // Coluna
	'Tipo'																	, ; // Descricao
	'Tipo'																	, ; // Descricao SPA
	'Tipo'																	, ; // Descricao ENG
	'PA1_TIPO'																} ) // Contem

aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'5'																		, ; // Tipo
	'01'																	, ; // Sequencia
	''																		, ; // Coluna
	''																		, ; // Descricao
	''																		, ; // Descricao SPA
	''																		, ; // Descricao ENG
	'PA1->PA1_PLACA'														} ) // Contem

aAdd( aSXB, { ;
	'PA1'																	, ; // Alias
	'5'																		, ; // Tipo
	'02'																	, ; // Sequencia
	''																		, ; // Coluna
	''																		, ; // Descricao
	''																		, ; // Descricao SPA
	''																		, ; // Descricao ENG
	'PA1->PA1_TIPO'															} ) // Contem

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( 'SXB' )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + '/'
				cTexto += 'Foi inclu�da a consulta padrao ' + aSXB[nI][1] + CRLF
			EndIf

			RecLock( 'SXB', .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					StrTran( AllToChar( SXB->( FieldGet( nJ ) )  ), ' ', '' ) <> ;
					StrTran( AllToChar( aSXB[nI][nJ]             ), ' ', '' )

					If ApMsgNoyes( 'A consulta padrao ' + aSXB[nI][1] + ' est� com o ' + SXB->( FieldName( nJ ) ) + ;
					' com o conte�do' + CRLF + ;
					'[' + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + ']' + CRLF + ;
					', e este � diferente do conte�do' + CRLF + ;
					'[' + RTrim( AllToChar( aSXB[nI][nJ] ) ) + ']' + CRLF +;
					'Deseja substituir ? ', 'Confirma substitui��o de conte�do' )

						RecLock( 'SXB', .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + '/'
							cTexto += 'Foi Alterada a consulta padrao ' + aSXB[nI][1] + CRLF
						EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( 'Atualizando Consultas Padroes (SXB)...' )

Next nI

cTexto += CRLF + CRLF + 'Final da Atualizacao do SXB' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � FSAtuSX5 � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento da gravacao do SX5 - Indices       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � FSAtuSX5 - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FSAtuSX5()
Local cTexto    := 'Inicio Atualizacao SX5' + CRLF + CRLF
Local cAlias    := ''
Local aSX5      := {}
Local aEstrut   := {}
Local nI        := 0
Local nJ        := 0

aEstrut := { 'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE', 'X5_DESCRI', 'X5_DESCSPA', 'X5_DESCENG' }

//
// Atualizando dicion�rio
//
oProcess:SetRegua2( Len( aSX5 ) )

dbSelectArea( 'SX5' )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )

	If !SX5->( MsSeek( aSX5[nI][1] + aSX5[nI][2] + aSX5[nI][3]) )
		RecLock( 'SX5', .T. )
		cTexto += 'Tabela criada tabela ' + aSX5[nI][1] + aSX5[nI][2] + CRLF
	Else
		RecLock( 'SX5', .F. )
		cTexto += 'Tabela alterada tabela ' + aSX5[nI][1] + aSX5[nI][2] + CRLF
	EndIf

	If Upper( AllTrim( CHAVE ) ) <> Upper( AllTrim( aSX5[nI][3] ) )
		aAdd( aArqUpd, aSX5[nI][1] )

		If !( aSX5[nI][1] $ cAlias )
			cAlias += aSX5[nI][1] + '/'
		EndIf

		For nJ := 1 To Len( aSX5[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

	EndIf

	oProcess:IncRegua2( 'Atualizando tabelas...' )

Next nI

cTexto += CRLF + CRLF + 'Final da Atualizacao do SX5' + CRLF + Replicate( '-', 128 ) + CRLF + CRLF

Return cTexto


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �ESCEMPRESA�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Generica para escolha de Empresa, montado pelo SM0_ ���
���          � Retorna vetor contendo as selecoes feitas.                 ���
���          � Se nao For marcada nenhuma o vetor volta vazio.            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EscEmpresa()
//��������������������������������������������Ŀ
//� Parametro  nTipo                           �
//� 1  - Monta com Todas Empresas/Filiais      �
//� 2  - Monta so com Empresas                 �
//� 3  - Monta so com Filiais de uma Empresa   �
//�                                            �
//� Parametro  aMarcadas                       �
//� Vetor com Empresas/Filiais pre marcadas    �
//�                                            �
//� Parametro  cEmpSel                         �
//� Empresa que sera usada para montar selecao �
//����������������������������������������������
Local   aSalvAmb := GetArea()
Local   aSalvSM0_:= {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), 'LBOK' )
Local   oNo      := LoadBitmap( GetResources(), 'LBNO' )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ''
Local   cNomEmp  := ''
Local   cMascEmp := '??'
Local   cMascFil := '??'

Local   aMarcadas  := {}


If !MyOpenSm0Ex()
	ApMsgStop( 'Nao foi possivel abrir SM0 exclusivo' )
	Return aRet
EndIf


dbSelectArea( 'SM0' )
aSalvSM0_:= SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !EOF()

    If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
        aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} )>0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
    EndIf

    dbSkip()
End
RestArea(  aSalvSM0_ )

Define MSDialog  oDlg Title '' From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := 'Tela para M�ltiplas Sele��es de Empresas/Filiais'

oDlg:cTitle := 'Selecione a(s) Empresa(s) para Atualiza��o'

@ 10, 10 Listbox  oLbx Var  cVar Fields Header ' ', ' ', 'Empresa' Size 178, 095 Of  oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
// oLbx:BlDblClick := {||  aVetor[oLbx:nAt, 1] := ! aVetor[oLbx:nAt, 1], IIf( aVetor[oLbx:nAt, 1], .T., lChk := .F. ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:BlDblClick := {||  aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @ lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. //NoScroll

@ 112, 10 CheckBox  oChkMar Var  lChk Prompt 'Todos'   Message 'Marca / Desmarca Todos' Size 40, 007 Pixel Of  oDlg;
on Click MarcaTodos( lChk, @ aVetor, oLbx )

@ 123, 10 Button  oButInv  Prompt '&Inverter'  Size 32, 12 Pixel Action ( InvSelecao( @ aVetor, oLbx, @ lChk, oChkMar ), VerTodos( aVetor, @ lChk, oChkMar ) ) ;
Message 'Inverter Sele��o' Of  oDlg

// Marca/Desmarca por mascara
@ 112, 51 Say  oSay Prompt 'Empresa' Size  40, 08 Of  oDlg Pixel
@ 112, 80 MSGet   oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture '@!'  Valid (  cMascEmp := StrTran( cMascEmp, ' ', '?' ), cMascFil := StrTran( cMascFil, ' ', '?' ), oMascEmp:Refresh(), .T. ) ;
Message 'M�scara Empresa ( ?? )'  Of  oDlg
@ 123, 50 Button  oButMarc Prompt '&Marcar'    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @ lChk, oChkMar ) ) ;
Message 'Marcar usando m�scara ( ?? )'    Of  oDlg
@ 123, 80 Button  oButDMar Prompt '&Desmarcar' Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @ lChk, oChkMar ) ) ;
Message 'Desmarcar usando m�scara ( ?? )' Of  oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @ aRet, aVetor ), oDlg:End() ) OnStop 'Confirma a Sele��o'  Enable Of  oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop 'Abandona a Sele��o' Enable Of  oDlg
Activate MSDialog  oDlg Center

RestArea(  aSalvAmb )
dbSelectArea( 'SM0' )
dbCloseArea()

Return  aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �MARCATODOS�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Auxiliar para marcar/desmarcar todos os itens do    ���
���          � ListBox ativo                                              ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For  nI := 1 To Len( aVetor )
    aVetor[nI][1] :=  lMarca
Next  nI

oLbx:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �INVSELECAO�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Auxiliar para inverter selecao do ListBox Ativo     ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For  nI := 1 To Len( aVetor )
    aVetor[nI][1] := !aVetor[nI][1]
Next  nI

oLbx:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �RETSELECAO�Autor  � Ernani Forastieri  � Data �  27/09/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao Auxiliar que monta o retorno com as selecoes        ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For  nI := 1 To Len( aVetor )
    If  aVetor[nI][1]
        aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
    EndIf
Next nI

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � MARCAMAS �Autor  � Ernani Forastieri  � Data �  20/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para marcar/desmarcar usando mascaras               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For  nZ := 1 To Len( aVetor )
    If  cPos1 == '?' .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
        If cPos2 == '?' .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
             aVetor[nZ][1] :=  lMarDes
        EndIf
    EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    � VERTODOS �Autor  � Ernani Forastieri  � Data �  20/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao auxiliar para verificar se estao todos marcardos    ���
���          � ou nao                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue  := .T.
Local nI      := 0

For nI := 1 To Len( aVetor )
    lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next  nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
��� Programa � MyOpenSM � Autor � Microsiga          � Data �  05/05/09   ���
�������������������������������������������������������������������������͹��
��� Descricao� Funcao de processamento abertura do SM0 modo exclusivo     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
��� Uso      � MyOpenSM - V.2.5                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MyOpenSM0Ex()

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , 'SIGAMAT.EMP', 'SM0', .F., .F. )

	If !Empty( Select( 'SM0' ) )
		lOpen := .T.
		dbSetIndex( 'SIGAMAT.IND' )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	Aviso( 'ATEN��O', 'Nao foi possivel a abertura da tabela ' + ;
		'de empresas de forma exclusiva.', { 'Sair' }, 2 )
EndIf

Return lOpen


/////////////////////////////////////////////////////////////////////////////
