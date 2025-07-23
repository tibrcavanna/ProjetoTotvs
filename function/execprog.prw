#INCLUDE "TOTVS.CH"


//-----------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecProg
Função para execução de programas
@type function
@version 12.1.33
@author Leandro Cesar (Unica TI)
@since 11/22/2023
/*/
User Function ExecProg()

	Local oMdl := Nil
	Local oDlg := Nil
	Local nAlt := 100
	Local nLar := 300

	Local oFnt01 := TFont():New( "Arial",, 16,, .F.,,,,, .F. )

	Local cCmb := ""
	Local cAux := ""
	Local cRun := Space(300)
	Local aHis := LerHis()

	Private lErr := .F.

	oMdl := FWDialogModal():New()
	oMdl:SetTitle( "Executar" )
	oMdl:SetSize( nAlt, nLar )
	oMdl:SetBackground( .T. )
	oMdl:SetEscClose( .T. )
	oMdl:CreateDialog()

	oDlg := oMdl:getPanelMain()
	nAlt := ( oDlg:nHeight / 2 )
	nLar := ( oDlg:nWidth / 2 )

	oSay01 := tSay():New( 010, 010, {|| "Digite uma linha de código ou uma função que deseja executar." }, oDlg,, oFnt01,,,, .T.,,, 300, 020 )

	oBmp02 := TBitmap():New( 027, 010, 15, 15, "PARAMETROS",,, oDlg,,,,,,,,, .T. )

	oCmb01 := tComboBox():New( 025, 030, bSetGet( cCmb ), aHis, nLar-40, 015, oDlg,, {|| cRun := PadR( cCmb, 300 ) },,,, .T. )
	oCmb01:SetHeight( 34 )

	@025,030 MSGET cRun SIZE nLar-51,015 FONT oFnt01 OF oDlg PIXEL

	oFormBar := FWFormBar():New( oMdl:oFormBar:oOwner )
	oFormBar:AddClose( {|| oMdl:oOwner:End() }, "Cancelar", "" )
	oFormBar:AddOK( {|| cAux := cRun, AddHis( @aHis, cRun ), GrvHis( aHis, 30 ), Execute( cRun ), oCmb01:SetItems( aHis ), oCmb01:Select( 1 ), cRun := cAux }, "Executar", "" )
	oMdl:oFormBar := oFormBar

	oMdl:Activate()

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function Execute( cRun, aHis )

	Local xReturn := ""
	Local oError  := ErrorBlock( {|e| Error( e ) })

	Default cRun := ""

	lErr := .F.

	BEGIN SEQUENCE

		Processa( {|| xReturn := &( cRun ) }, "Executando", "Executando linha de comando, aguarde...", .F. )

	END SEQUENCE

	//oBlk:= ErrorBlock( oError )

Return ( xReturn )

//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function Error( oError )

	MsgAlert( "Mensagem de Erro: " + chr(10) + oError:Description )
	lErr := .T.

Return Nil

//---------------------------------------------------------------------------------------------------------------------------------------------
Static Function AddHis( aHis, cRun )

	Local nX   := 0
	Local aNew := {}

	cRun := AllTrim( cRun )
	aAdd( aNew, "" )
	aAdd( aNew, cRun )

	For nX := 1 To Len( aHis )
		If ( !Empty( aHis[nX] ) .And. !( aHis[nX] == cRun ) )
			aAdd( aNew, aHis[nX] )
		EndIf
	Next nX

	aHis := aNew

Return ( aHis )

//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GetHisArq()

	Local cArq := ""

	cArq := GetTempPath()
	cArq += "MCFG001"

Return ( cArq )

//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function GrvHis( aHis, nQnt )

	Local nX   := 0
	Local nHnd := 0
	Local cArq := GetHisArq()

	If File( cArq )
		FErase( cArq )
	EndIf

	nHnd := FCreate( cArq )
	If ( nHnd < 0 )
		MsgAlert( "Erro ao criar arquivo: " + Str( FError() ) )
		Return Nil
	EndIf

	If ( Len( aHis ) < nQnt )
		nQnt := Len( aHis )
	EndIf

	For nX := 1 To nQnt
		FWrite( nHnd, aHis[nX] + CRLF )
	Next nX

	FClose( nHnd )

Return Nil

//-----------------------------------------------------------------------------------------------------------------------------------------------
Static Function LerHis()

	Local aHis := {}
	Local cArq := GetHisArq()

	If File( cArq )

		FT_FUse( cArq )
		FT_FGoTop()

		While !FT_FEOF()
			aAdd( aHis, FT_FReadLn() )
			FT_FSkip()
		EndDo

		FT_FUse()

	EndIf

	If Len( aHis ) == 0
		aAdd( aHis, "" )
	EndIf

Return ( aHis )
