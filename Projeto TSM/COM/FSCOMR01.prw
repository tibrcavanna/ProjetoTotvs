#include "totvs.ch"
#include "fileio.ch"
#INCLUDE 'FWMVCDEF.CH'


static oCellAligH := FwXlsxCellAlignment():Horizontal()
static oCellAligV := FwXlsxCellAlignment():Vertical()

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  FSCOMR01
  Função para gerar excel de Demanda X Fornecimento, listando todos os produtos onde
  a soma das aquisições (SCs) sejam maiores que a demanda (empenhos)
  @type function
  @author Silvio Nogueira Silva
  @since 15/10/25025
/*/
//-------------------------------------------------------------------------------------------------------------

User Function FSCOMR01()
    Local a_Area     := FWGetArea()
    Local l_Ret      := Nil
    Local a_Pergs    := {}
    Local c_ProdDe   := Space( TamSX3( "B2_COD")[01] )
    Local c_ProdAte  := Replicate("Z", TamSX3( "B2_COD")[01] )
    Local c_DescDe   := Space( TamSX3( "B1_DESC")[01] )
    Local c_DescAte  := Replicate("Z", TamSX3( "B1_DESC")[01] )

    Local c_GetFile
    Private c_Alias     := GetNextAlias()

    aAdd( a_Pergs, {1, "Produto De "   , c_ProdDe   , ""            , ""           , "SB1"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Produto Ate "  , c_ProdAte  , ""            , ""           , "SB1"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Descrição De " , c_DescDe   , "@S20"        , ""           , ""     , "",   120, .F. } )
    aAdd( a_Pergs, {1, "Descrição Ate ", c_DescAte  , "@S20"        , ""           , ""     , "",   120, .F. } )

    If ParamBox( a_Pergs, "Gera Excel - Demanda X Fornecimento",,,,,,,,, .F. )
        c_ProdDe  :=  M->MV_PAR01
        c_ProdAte :=  M->MV_PAR02
        c_DescDe  :=  M->MV_PAR03
        c_DescAte :=  M->MV_PAR04
        c_GetFile := tFileDialog( "" , "Seleção de Arquivos",,GetTempPath(),.T.)

        If ! Empty(c_GetFile)
            If FWAlertYesNo("Confirma a geração dos arquivos ?", "Continuar?" )
                Processa( {|| GeraExcel( c_GetFile,  c_ProdDe, c_ProdAte, c_DescDe, c_DescAte ) },,, .T.)
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
  @author Silvio Nogueira
  @since 15/10/20025
  @param c_GetFile, 	char, 	caminho para salvar o arquivo gerado
         c_ProdDe,      char,   produto de
         c_ProdAte,     char,   produto ate
         c_DescDe,      char,   Descrição de 
         c_DescAte      char,   Descrição ate
  @return l_Ret, 	bollean, True se gerado com sucesso.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function GeraExcel( c_GetFile,  c_ProdDe, c_ProdAte, c_DescDe, c_DescAte )
    Local l_Ret      := .T.
    Local c_NomeArq  := "DEMXFOR" + FwTimeStamp()
    Local c_ArqTemp  := "\spool\" + c_NomeArq + ".rel"
    Local n_LinXLS   := 1
    Local c_PathDest := c_GetFile
    Local c_Query
    Local c_Msg      := ""

    Private oPrtXlsx := NIL
    Private c_Item

    ProcRegua(1)
    IncProc("Obtendo dados para gerar o excel...")
    ProcessMessage()


    c_Query := MontaQry( c_ProdDe, c_ProdAte, c_DescDe, c_DescAte )

    c_Alias 	:= MPSysOpenQuery( c_Query )

    (c_Alias)->(dbGotop())
    If (c_Alias)->(Eof())

        l_Ret := .F.
        c_Msg := "Nenhum dado encontrado para os parâmetros informados !"

    EndIf

    If l_Ret
        ProcRegua( (c_Alias)->(LASTREC()) )
        ProcessMessage()

        oFileW   := FwFileWriter():New(c_ArqTemp)
        oPrtXlsx := FwPrinterXlsx():New()

        l_Ret    := oPrtXlsx:Activate( c_ArqTemp, oFileW )
        l_Ret    := oPrtXlsx:AddSheet( "Rel Demanda X Fornecimento" )
        l_Ret    := oPrtXlsx:ApplyFormat(1, 1)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 2)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 3)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 4)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 5)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 6)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 7)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 8)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 9)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 10)
        n_LinXLS := 1

        l_Ret := MontaCab( n_LinXLS )

        Do While l_Ret .and. (c_Alias)->(! eof())
            IncProc("Gerando excel no servidor...")
            ProcessMessage()

            n_LinXLS++

            l_Ret := MontaLin( n_LinXLS )

            c_Item	:= (c_Alias)->ITEM

            (c_Alias)->(dbSkip())

        EndDo

        l_Ret    := oPrtXlsx:ApplyAutoFilter(1, 1, n_LinXLS, 10)

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

    (c_Alias)->(dbCloseArea())

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
  @author Silvio Nogueira
  @since  15/10/2025
  @param c_ProdDe,      char,   projeto de
         c_ProdAte,     char,   projeto ate
         c_DescDe,      char,   OP de 
         c_DescAte      char,   OP ate
  @return c_Query, 	char, Script SQL.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MontaQry( c_ProdDe, c_ProdAte, c_DescDe, c_DescAte )
    Local o_Query
    Local c_Query := ""

    c_Query := "SELECT B2_COD [ITEM], B1_DESC [DESCR], '###' [TPDEM], Isnull(B2_QEMP+B2_QEMPPRE,0) [DEMTOT], Isnull(B2_QATU,0) [SLDEST],"
    c_Query += "Isnull(FORN,0) [FORN],  Isnull(TPDOC+C7_NUM,'') [NUMDOC],Isnull(C7_ITEM,'') [POSICAO], IsNull(C7_QUANT,0) [QTDPC], Isnull(SA2.A2_NOME,'') [FORNECE],"
    c_Query += "CASE WHEN ISNULL(SC1.REGSC1,0) > 0 THEN 'S' ELSE 'N' END [TEMSC], 
    
    c_Query += "	CASE	WHEN ISNULL(SC1.REGSC1,0) = 0 AND FORN = 0 THEN 'OP' "
    c_Query += "			WHEN FORN <> 0 THEN 'PC' "
    c_Query += "			WHEN ISNULL(SC1.REGSC1,0) <> 0 AND FORN = 0 THEN 'SC' "
    c_Query += "	END [TPFOR] "
    
    c_Query += "	FROM ? SB1 " 

    c_Query += "INNER JOIN ( SELECT B2_FILIAL,B2_COD,SUM(B2_QATU) B2_QATU,SUM(B2_QEMP) B2_QEMP,SUM(B2_QEMPPRE) B2_QEMPPRE  FROM ? "
    c_Query += "				WHERE D_E_L_E_T_ = '' AND B2_FILIAL = '?' "
    c_Query += "GROUP BY B2_FILIAL,B2_COD ) SB2 ON B1_COD = B2_COD "

    c_Query += "LEFT OUTER JOIN (SELECT 'PC' [TPDOC],C7_FILIAL,C7_NUM,C7_ITEM,C7_PRODUTO,C7_FORNECE,C7_LOJA,C7_QUANT FROM ? WHERE C7_FILIAL = '?' AND C7_QUANT > C7_QUJE AND C7_RESIDUO = '' AND D_E_L_E_T_ = ''	) SC7 ON B1_COD = SC7.C7_PRODUTO "
    c_Query += "LEFT OUTER JOIN (SELECT C7_FILIAL,C7_PRODUTO,SUM(C7_QUANT-C7_QUJE) FORN FROM ? WHERE C7_FILIAL = '?' AND C7_QUANT > C7_QUJE AND C7_RESIDUO = '' AND D_E_L_E_T_ = ''	GROUP BY C7_FILIAL,C7_PRODUTO) SC7B ON B1_COD = SC7B.C7_PRODUTO "
    c_Query += "LEFT OUTER JOIN ? SA2 ON A2_FILIAL = '?' AND C7_FORNECE = SA2.A2_COD AND C7_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = '' "
    c_Query += "LEFT JOIN (SELECT C1_PRODUTO,COUNT(*) REGSC1 FROM ? "
    c_Query += "			WHERE C1_FILIAL = ? AND D_E_L_E_T_ = '' "
    c_Query += "				GROUP BY C1_PRODUTO) SC1 "
    c_Query += "				ON SC1.C1_PRODUTO = B1_COD "
    c_Query += "WHERE B1_FILIAL = '?' AND B1_COD >= '?' AND B1_COD <= '?' AND B1_DESC >= '?' AND B1_DESC <= '?' AND SB1.D_E_L_E_T_ = '' "
    c_Query += "AND FORN > B2_QEMP "
    c_Query += "ORDER BY B1_COD,TPDOC,C7_NUM,C7_ITEM,A2_COD,A2_LOJA"

    c_Query := ChangeQuery(c_Query)
    o_Query := FWPreparedStatement():New(c_Query)

    o_Query:SetUnsafe(1, RetSqlName( "SB1" ))
    o_Query:SetUnsafe(2, RetSqlName( "SB2" ))
    o_Query:SetUnsafe(3, xFilial( "SB2" ))
    o_Query:SetUnsafe(4, RetSqlName( "SC7" ))
    o_Query:SetUnsafe(5, xFilial( "SC7" ))
    o_Query:SetUnsafe(6, RetSqlName( "SC7" ))
    o_Query:SetUnsafe(7, xFilial( "SC7" ))
    o_Query:SetUnsafe(8, RetSqlName( "SA2" ))
    o_Query:SetUnsafe(9, xFilial( "SA2" ))
    o_Query:SetUnsafe(10, RetSqlName( "SC1" ))
    o_Query:SetUnsafe(11, xFilial( "SC1" ))
    o_Query:SetUnsafe(12, xFilial( "SB1" ))
    o_Query:SetUnsafe(13, c_ProdDe)
    o_Query:SetUnsafe(14, c_ProdAte)
    o_Query:SetUnsafe(15, c_DescDe)
    o_Query:SetUnsafe(16, c_DescAte)

    c_Query 	:= o_Query:GetFixQuery()

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
    l_Ret := oPrtXlsx:SetColumnsWidth( 2,  2, 50    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 3,  3, 19    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 4,  4, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 5,  5, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 6,  6, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 7,  7, 18    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 8,  8, 10    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 9,  9, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth(10, 10, 33    )

    // Seta a formatação de celula a ser usada
    l_Ret := oPrtXlsx:SetCellsFormat( c_HorAlig, c_VerAlig, l_WrapText, n_Rotation, "000000", "FFFFFF", c_Custom )

    // Seta a fonte a ser usada
    l_Ret := oPrtXlsx:SetFont( c_Font, n_Size, l_Italic, l_Bold, l_Under )

    // Preenche o cabeçalho
    l_Ret := oPrtXlsx:SetText(n_Linha,   1, "Item"             )
    l_Ret := oPrtXlsx:SetText(n_Linha,   2, "Descrição"        )
    l_Ret := oPrtXlsx:SetText(n_Linha,   3, "Tp Fornecimento"  )
    l_Ret := oPrtXlsx:SetText(n_Linha,   4, "Demanda Total"    )
    l_Ret := oPrtXlsx:SetText(n_Linha,   5, "Estoque"          )
    l_Ret := oPrtXlsx:SetText(n_Linha,   6, "Fornecimento"     )
    l_Ret := oPrtXlsx:SetText(n_Linha,   7, "No.Documento"     )
    l_Ret := oPrtXlsx:SetText(n_Linha,   8, "Posição"          )
    l_Ret := oPrtXlsx:SetText(n_Linha,   9, "Qtd PC"          )
    l_Ret := oPrtXlsx:SetText(n_Linha,   10, "Fornecedor"       )

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

    // Seta a formatação de celula a ser usada
    l_Ret := oPrtXlsx:ResetCellsFormat()

    // Seta a fonte a ser usada
    l_Ret := oPrtXlsx:SetFont( c_Font, n_Size, l_Italic, l_Bold, l_Under )

    // Preenche as linhas
    l_Ret := oPrtXlsx:SetText(   n_Linha,  1, (c_Alias)->ITEM   )
    l_Ret := oPrtXlsx:SetText(   n_Linha,  2, (c_Alias)->DESCR  )
    l_Ret := oPrtXlsx:SetText(   n_Linha,  3, (c_Alias)->TPFOR  )
    l_Ret := oPrtXlsx:SetNumber( n_Linha,  4, (c_Alias)->DEMTOT )
    l_Ret := oPrtXlsx:SetNumber( n_Linha,  5, (c_Alias)->SLDEST )
    l_Ret := oPrtXlsx:SetNumber( n_Linha,  6, (c_Alias)->FORN   )
    l_Ret := oPrtXlsx:SetText( n_Linha,    7, (c_Alias)->NUMDOC   )
    l_Ret := oPrtXlsx:SetText( n_Linha,    8, (c_Alias)->POSICAO  )
    l_Ret := oPrtXlsx:SetNumber( n_Linha,    9, (c_Alias)->QTDPC  )
    l_Ret := oPrtXlsx:SetText( n_Linha,   10, (c_Alias)->FORNECE  )

Return(l_Ret)
