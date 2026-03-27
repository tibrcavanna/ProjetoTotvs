#include "totvs.ch"
#include "fileio.ch"
#INCLUDE 'FWMVCDEF.CH'


static oCellAligH := FwXlsxCellAlignment():Horizontal()
static oCellAligV := FwXlsxCellAlignment():Vertical()


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  FSPCPR01
  Função para gera excel de Relação por OP, composto pelos projetos da empresa
  @type function
  @author Silvio Mota
  @since 05/08/25025
/*/
//-------------------------------------------------------------------------------------------------------------

User Function FSPCPR01()
	Local a_Area     := FWGetArea()
	Local l_Ret      := Nil
	Local a_Pergs    := {}
	Local c_ProjDe   := Space( TamSX3( "D4_OP")[01] )
	Local c_ProjAte  := Replicate("Z", TamSX3( "D4_OP")[01] )
	Local c_OPDe     := Space( TamSX3( "D4_OP")[01] )
	Local c_OPAte    := Replicate("Z", TamSX3( "D4_OP")[01] )

	Local c_GetFile

	aAdd( a_Pergs, {1, "Projeto De ?"  , c_ProjDe   , ""            , ""           , "SB1"  , "",   0, .F. } )
	aAdd( a_Pergs, {1, "Projeto Ate ?" , c_ProjAte  , ""            , ""           , "SB1"  , "",   0, .F. } )
	aAdd( a_Pergs, {1, "OP De ?"       , c_OPDe     , ""            , ""           , "SC2"  , "",   0, .F. } )
	aAdd( a_Pergs, {1, "OP Ate ?"      , c_OPAte    , ""            , ""           , "SC2"  , "",   0, .F. } )

	If ParamBox( a_Pergs, "Gera Excel - Relação por OP",,,,,,,,, .F. )
		c_ProjDe  :=  M->MV_PAR01
		c_ProjAte :=  M->MV_PAR02
		c_OPDe    :=  M->MV_PAR03
		c_OPAte   :=  M->MV_PAR04
		c_GetFile := cGetFile( "Arquivos (*.XLSX) |*.XLSX|" , 'Escolha uma pastas de Destino', 0, "C:\TEMP", .F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE )

		If ! Empty(c_GetFile)
			c_GetFile := AllTrim(c_GetFile)+"\"
			If FWAlertYesNo("Confirma a geração dos arquivos ?", "Continuar?" )
				Processa( {|| GeraExcel( c_GetFile,  c_ProjDe, c_ProjAte, c_OPDe, c_OPAte ) },,, .T.)
			EndIf
		Else
			FWAlertError("Você precisa escolher uma pasta para salvar o arquivo !", "Escolha uma pasta" )
		EndIf
	EndIf

	FwRestArea(a_Area)
Return(l_Ret)



//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GeraExecl
  Função pra geral o Excel.
  @type function
  @author Silvio Mota
  @since 05/08/20025
  @param c_GetFile, 	char, 	caminho para salvar o arquivo gerado
         c_ProjDe,      char,   projeto de
         c_ProjAte,     char,   projeto ate
         c_OPDe,        char,   OP de 
         c_OPAte        char,   OP ate
  @return l_Ret, 	bollean, True se gerado com sucesso.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function GeraExcel( c_GetFile,  c_ProjDe, c_ProjAte, c_OPDe, c_OPAte )
	Local l_Ret      := .T.
	Local c_NomeArq  := "RELOP" + FwTimeStamp()
	Local c_ArqTemp  := "\spool\" + c_NomeArq + ".rel"
	Local n_LinXLS   := 1
	Local c_PathDest := c_GetFile
	Local c_Query
	Local c_Msg      := ""

	Private oPrtXlsx := NIL


	ProcRegua(1)
	IncProc("Obtendo dados para gerar o excel...")
	ProcessMessage()


	c_Query := MontaQry( c_ProjDe, c_ProjAte, c_OPDe, c_OPAte )
	c_Query := ChangeQuery(c_Query)

	dbUseArea( .T., "TOPCONN", TCGenQry(,,c_Query), "QRY", .F., .T.)


	QRY->(dbGotop())
	If QRY->(EOF())
		l_Ret := .F.
		c_Msg := "Nenhuma dado encontrada para os parâmetros informados !"
	EndIf

	If l_Ret
		ProcRegua( QRY->(LASTREC()) )
		ProcessMessage()

		oFileW   := FwFileWriter():New(c_ArqTemp)
		oPrtXlsx := FwPrinterXlsx():New()

		l_Ret    := oPrtXlsx:Activate( c_ArqTemp, oFileW )
		l_Ret    := oPrtXlsx:AddSheet( "Rel por OP" )
		n_LinXLS := 1

		l_Ret := MontaCab( n_LinXLS )

		Do While l_Ret .and. QRY->(! eof())
			IncProc("Gerando excel no servidor...")
			ProcessMessage()

			n_LinXLS++

			l_Ret := MontaLin( n_LinXLS )

			QRY->(dbSkip())
		EndDo

		If ! l_Ret
			c_Msg := "Erro ao gerar Excel !"
		EndIf

		oPrtXlsx:toXlsx()

		c_ArqTemp := StrTran(c_ArqTemp, ".rel", ".xlsx")

		If File(c_ArqTemp)
			IncProc("Copiando arquivo excel para " + c_PathDest + "..." )
			ProcessMessage()


			If CpyS2T(c_ArqTemp, c_PathDest )
				oPrtXlsx:EraseBaseFile()
			Else
				FWAlertWarning("Nao copiou o arquivo gerado " + c_ArqTemp +  " para a pasta de destino: " + c_PathDest , "Arquivo Gerado" )
			EndIf
		Else
			FWAlertWarning("Nao achou o arquivo gerado " + c_ArqTemp + "! ", "Arquivo Gerado" )
		EndIf

		oPrtXlsx:DeActivate()

		ShellExecute("open", c_PathDest + c_NomeArq + ".xlsx", "", c_PathDest , 1)
	EndIf

	QRY->(dbCloseArea())

	If l_Ret
		FWAlertWarning("Concluído com sucesso", "Arquivos Gerado" )
	else
		FWAlertWarning( c_Msg , "Erro" )
	EndIf

Return(l_Ret)




//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaQry
  Monta o script sql para selecionar os dados principais, conforme o parametros.
  @type function
  @author Silvio Mota
  @since  05/08/2025
  @param c_ProjDe,      char,   projeto de
         c_ProjAte,     char,   projeto ate
         c_OPDe,        char,   OP de 
         c_OPAte        char,   OP ate
  @return c_Query, 	char, Script SQL.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MontaQry( c_ProjDe, c_ProjAte, c_OPDe, c_OPAte )
	Local c_Query := ""

	c_Query := "SELECT  '100001' AS C2_XPROJETO, C2_PRODUTO, C2_NUM+C2_ITEM+C2_SEQUEN AS OP, D4_COD, D4_QTDEORI, D4_QUANT, D4_LOCAL "
	c_Query += "FROM  " + RetSqlName("SD4") + " SD4                                      "
	c_Query += "        INNER JOIN                                                       "
	c_Query += "        " + RetSqlName("SC2") + " SC2                                                       "
	c_Query += "        ON SD4.D4_FILIAL  = SC2.C2_FILIAL                           AND  "
	c_Query += "           SD4.D4_OP      = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN    AND  "
	c_Query += "          (SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN BETWEEN '" + c_OPDe     + "' AND '" + c_OPAte   + "' ) AND  "
	c_Query += "          (SC2.C2_XPROJETO                      BETWEEN '" + c_ProjDe   + "' AND '" + c_ProjAte + "' ) AND  "
	c_Query += "           SC2.D_E_L_E_T_ = ''                         "
	c_Query += "           INNER JOIN                                  "
	c_Query += "          " + RetSqlName("SB1") + " SB1                         "
	c_Query += "           ON '" + xFilial('SB1') + "' =  SB1.B1_FILIAL   AND   "
	c_Query += "               SD4.D4_COD     =  SB1.B1_COD      AND   "
	c_Query += "               'S'            <> SB1.B1_FANTASM  AND   "
	c_Query += "               SB1.D_E_L_E_T_ =  ''                    "
	c_Query += "WHERE   SD4.D4_FILIAL  = '" + xFilial('SD4') + "' AND  "
	c_Query += "        SD4.D_E_L_E_T_ = ''                            "

Return(c_Query)



//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaCab
  Preenche o cabeçalho do Excel.
  @type function
  @author Silvio Mota
  @since 05/08/2025
  @param n_Linha, number, Linha do excel que será preenchida.
  @return l_Ret, bolean, True se preencher com sucesso.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MontaCab( n_Linha )
	Local l_Ret    := .T.
	Local c_Font   :=  FwPrinterFont():Calibri()
	Local n_Size   := 11
	Local l_Italic := .F.
	Local l_Bold   := .T.
	Local l_Under  := .F.

	Local c_HorAlig  := oCellAligH:Center()
	Local c_VerAlig  := oCellAligV:Center()
	Local l_WrapText := .T.
	Local n_Rotation := 0
	Local c_Custom   := ""


	// Ajusta a largura das colunas
	l_Ret := oPrtXlsx:SetColumnsWidth( 1,  1, 16    )
	l_Ret := oPrtXlsx:SetColumnsWidth( 2,  2, 16    )
	l_Ret := oPrtXlsx:SetColumnsWidth( 3,  3, 19    )
	l_Ret := oPrtXlsx:SetColumnsWidth( 4,  4, 16    )
	l_Ret := oPrtXlsx:SetColumnsWidth( 5,  5, 23    )
	l_Ret := oPrtXlsx:SetColumnsWidth( 6,  6, 23    )
	l_Ret := oPrtXlsx:SetColumnsWidth( 7,  7, 23    )


	// Ajusta a altura da linha do cabeçalho
	///l_Ret := oPrtXlsx:SetRowsHeight( n_Linha, n_Linha, 75 )


	// Seta a formatação de celula a ser usada
	l_Ret := oPrtXlsx:SetCellsFormat( c_HorAlig, c_VerAlig, l_WrapText, n_Rotation, "000000", "FFFFFF", c_Custom )


	// Seta a fonte a ser usada
	l_Ret := oPrtXlsx:SetFont( c_Font, n_Size, l_Italic, l_Bold, l_Under )


	// Preenche o cabeçalho
	l_Ret := oPrtXlsx:SetText(n_Linha,   1, "Projeto"                                 )
	l_Ret := oPrtXlsx:SetText(n_Linha,   2, "Produto"                                 )
	l_Ret := oPrtXlsx:SetText(n_Linha,   3, "Ordem de Produção"                       )
	l_Ret := oPrtXlsx:SetText(n_Linha,   4, "Componente"                              )
	l_Ret := oPrtXlsx:SetText(n_Linha,   5, "Quantidade Empenho"                      )
	l_Ret := oPrtXlsx:SetText(n_Linha,   6, "Saldo Empenho"                           )
	l_Ret := oPrtXlsx:SetText(n_Linha,   7, "Saldo Estoque"                           )

Return(l_Ret)




//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaLin
  Preenche a linha do excel, conforme dataset posicionado
  @type function
  @author Silvio Mota
  @since 05/08/2025
  @param  n_Linha,      Number, Numero da LInha do excel que será
  @return l_Ret, bolean, True se preencher com sucesso.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MontaLin( n_Linha )
	Local l_Ret := .T.
	Local c_Font   :=  FwPrinterFont():Calibri()
	Local n_Size   := 11
	Local l_Italic := .F.
	Local l_Bold   := .F.
	Local l_Under  := .F.
	Local a_Saldo
	Local n_Saldo

	// Obtem o saldo em estoque do componentes.
	a_Saldo := CalcEst( QRY->D4_COD, QRY->D4_LOCAL, date()+1 )
	n_Saldo := a_Saldo[1]


	// Seta a formatação de celula a ser usada
	l_Ret := oPrtXlsx:ResetCellsFormat()


	// Seta a fonte a ser usada
	l_Ret := oPrtXlsx:SetFont( c_Font, n_Size, l_Italic, l_Bold, l_Under )


	// Preenche as linhas
	l_Ret := oPrtXlsx:SetText(   n_Linha,  1, QRY->C2_XPROJETO )
	l_Ret := oPrtXlsx:SetText(   n_Linha,  2, QRY->C2_PRODUTO  )
	l_Ret := oPrtXlsx:SetText(   n_Linha,  3, QRY->OP          )
	l_Ret := oPrtXlsx:SetText(   n_Linha,  4, QRY->D4_COD      )
	l_Ret := oPrtXlsx:SetNumber( n_Linha,  5, QRY->D4_QTDEORI  )
	l_Ret := oPrtXlsx:SetNumber( n_Linha,  6, QRY->D4_QUANT    )
	l_Ret := oPrtXlsx:SetNumber( n_Linha,  7, n_Saldo          )

Return(l_Ret)

