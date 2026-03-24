#include "totvs.ch"
#include "fileio.ch"
#INCLUDE 'FWMVCDEF.CH'


static oCellAligH := FwXlsxCellAlignment():Horizontal()
static oCellAligV := FwXlsxCellAlignment():Vertical()

static oCellHorAlign  := FwXlsxCellAlignment():Horizontal()
static oCellVertAlign := FwXlsxCellAlignment():Vertical()


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  FSPCPR02
  Função para gerar excel de relatório de Faltas
  informações para apoiar nas decisões do planejamento
  @type function
  @author Silvio Nogueira Silva
  @since 17/10/25025
/*/
//-------------------------------------------------------------------------------------------------------------

User Function FSPCPR02()
    Local a_Area     := FWGetArea()
    Local l_Ret      := Nil
    Local a_Pergs    := {}
    Local c_OPDe   := Space( TamSX3( "H6_OP")[01] )
    Local c_OPAte  := Replicate("Z", TamSX3( "H6_OP")[01] )
    Local c_ProjDe   := Space( TamSX3( "C2_ITEMCTA")[01] )
    Local c_ProjAte  := Replicate("Z", TamSX3( "C2_ITEMCTA")[01] )
    Local c_PVDe   := Space( TamSX3( "C6_NUM")[01] )
    Local c_PVAte  := Replicate("Z", TamSX3( "C6_NUM")[01] )

    Local c_GetFile

    Private c_Temp     := GetNextAlias()
    Private c_Alias    := GetNextAlias()

    aAdd( a_Pergs, {1, "OP De "   		, c_OPDe   , ""            , ""           , "SC2"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "OP Ate "  		, c_OPAte  , ""            , ""           , "SC2"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Projeto De "   	, c_ProjDe   , ""            , ""           , "CTD"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Projeto Ate "  	, c_ProjAte  , ""            , ""           , "CTD"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Ped Venda De " 	, c_PVDe   , ""            , ""           , "SC5"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Ped Venda Ate "	, c_PVAte  , ""            , ""           , "SC5"  , "",   0, .F. } )

    If ParamBox( a_Pergs, "Gera Excel - Relatório da Faltas",,,,,,,,, .F. )
        c_OPDe  	:=  M->MV_PAR01
        c_OPAte 	:=  M->MV_PAR02
        c_ProjDe  	:=  M->MV_PAR03
        c_ProjAte 	:=  M->MV_PAR04
        c_PVDe  	:=  M->MV_PAR05
        c_PVAte 	:=  M->MV_PAR06
        c_GetFile := tFileDialog( "" , "Seleção de Arquivos",,GetTempPath(),.T.)

        If ! Empty(c_GetFile)
            If FWAlertYesNo("Confirma a geração dos arquivos ?", "Continuar?" )
                Processa( {|| GeraExcel( c_GetFile, c_OPDe, c_OPAte, c_ProjDe, c_ProjAte, c_PVDe, c_PVAte ) },,, .T.)
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
         c_OPDe,      char,   OP de
         c_OPAte,     char,   OP ate
         c_ProjDe,      char,   projeto de
         c_ProjAte,     char,   projeto ate
  @return l_Ret, 	bollean, True se gerado com sucesso.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function GeraExcel( c_GetFile,  c_OPDe, c_OPAte, c_ProjDe, c_ProjAte, c_PVDe, c_PVAte )
    Local l_Ret      := .T.
    Local c_NomeArq  := "FALTAS" + FwTimeStamp()
    Local c_ArqTemp  := "\spool\" + c_NomeArq + ".rel"
    Local n_LinXLS   := 1
    Local c_PathDest := c_GetFile
    Local c_Query
    Local c_Msg      := ""
    Local a_Estoque
    Local n_Estoque
    Local c_ProjAtu
    Local c_OPAtu
    Local n_TotDisp
    Local c_TemSC
    Local l_Estoque

    Private oPrtXlsx := NIL
    Private c_Item

    ProcRegua(1)
    IncProc("Obtendo dados para gerar o excel...")
    ProcessMessage()

    c_Query := MontaQry( c_OPDe, c_OPAte, c_ProjDe, c_ProjAte, c_PVDe, c_PVAte )

    c_Temp 	:= MPSysOpenQuery( c_Query )

    CriaTabTemp() // Cria tabela temporária utilizando c_alias

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
        l_Ret    := oPrtXlsx:AddSheet( "Rel de Faltas" )
        l_Ret    := oPrtXlsx:ApplyAutoFilter(1, 1, (c_Alias)->(LASTREC())+1, 17)
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
        l_Ret    := oPrtXlsx:ApplyFormat(1, 11)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 12)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 13)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 14)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 15)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 16)
        l_Ret    := oPrtXlsx:ApplyFormat(1, 17)
        n_LinXLS := 1

        // Calcula saldos estoque , falta Compras e Disponibidade
        (c_Alias)->(dbGotop())
        Do While l_Ret .and. (c_Alias)->(! eof())

            n_Estoque := 0
            //Obtem o saldo em estoque do componentes em um local da OP (C2_LOCAL).
            a_Estoque 	:= CalcEst( (c_Alias)->CODITEM, (c_Alias)->LOCOP, date()+1 )
            n_Estoque 	+= a_Estoque[1]

               RecLock(c_Alias,.F.)			
            (c_Alias)->ESTOQUE	:= n_Estoque
            MsUnlock()

            (c_Alias)->(dbSkip())

        EndDo

        // Atualiza Status da OP
        (c_Alias)->(dbGotop())
        Do While l_Ret .and. (c_Alias)->(! eof())

            c_ProjAtu	:= (c_Alias)->PROJETO
            c_OPAtu		:= (c_Alias)->OP
            n_RecAnt	:= (c_Alias)->(Recno())

            c_TemSC	:= 'N'
            n_TotDisp	:= 0

            l_Estoque := .F.	

            Do While (c_Alias)->(! eof()) .And. c_OPAtu == (c_Alias)->OP .And. c_ProjAtu == (c_Alias)->PROJETO

                l_Estoque	:= If((c_Alias)->ESTOQUE >= (c_Alias)->EMPENHO,.T., .F.)

                (c_Alias)->(dbSkip())

            Enddo
            
            
            // Procedimento para gravar o Status nos registros referentes a OP
            (c_Alias)->(dbGoto(n_RecAnt))

            Do While (c_Alias)->(! eof()) .And. c_OPAtu == (c_Alias)->OP .And. c_ProjAtu == (c_Alias)->PROJETO

                   RecLock(c_Alias,.F.)			
                (c_Alias)->TIPO := If(l_Estoque,'ESTOQUE',If(!Empty((c_Alias)->ORDCOM),'PC',If((c_Alias)->TEMSC == 'S','SC','OP')))
                (c_Alias)->(dbSkip())
                MsUnlock()

            Enddo

        EndDo

        l_Ret := MontaCab( n_LinXLS )

        (c_Alias)->(dbGotop())

        Do While l_Ret .and. (c_Alias)->(! eof())
            IncProc("Gerando excel no servidor...")
            ProcessMessage()

            If (c_Alias)->ESTOQUE < (c_Alias)->EMPENHO

                n_LinXLS++

                l_Ret := MontaLin( n_LinXLS )

            Endif

            c_Item	:= (c_Alias)->OP

            (c_Alias)->(dbSkip())

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
  @param c_ProjDe,      char,   projeto de
         c_ProjAte,     char,   projeto ate
         c_DescDe,      char,   OP de 
         c_DescAte      char,   OP ate
  @return c_Query, 	char, Script SQL.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MontaQry( c_OPDe, c_OPAte, c_ProjDe, c_ProjAte, c_PVDe, c_PVAte )
    Local o_Query
    Local c_Query := ""

    c_Query := "SELECT SC2.C2_ITEMCTA [PROJETO], SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN [OP], SC2.C2_DATPRI [DATAOP], G1_COMP [CODITEM], SB1.B1_DESC [DESCR], SC2.C2_PRODUTO [PRDORD],"
    c_Query += "	SB1B.B1_DESC [DESCPRD], SC2.C2_QUANT [QTDOP], 0 [ESTOQUE], EMPENHO [EMPENHO], 0 [DISPONIB], SPACE(10) [TIPO], ISNULL(C7_NUM,SPACE(6)) [ORDCOM],"
    c_Query += "	ISNULL(C7_ITEM,SPACE(3)) [ITEORD], ISNULL(C7_FORNECE,SPACE(6)) [FORNEC], ISNULL(C7_LOJA,SPACE(2)) [LOJA],"
    c_Query += "	ISNULL(C7_DATPRF,SPACE(8)) [PRZENT],CASE WHEN ISNULL(SC1.REGSC1,0) > 0 THEN 'S' ELSE 'N' END [TEMSC], SC2B.C2_NUM+SC2B.C2_ITEM+SC2B.C2_SEQUEN  [OPPAI], SC2.C2_LOCAL [LOCOP], ISNULL(SC2C.C2_NUM+SC2C.C2_ITEM+SC2C.C2_SEQUEN,SPACE(13)) [OPFILHA]"
    c_Query += "	FROM ? SC2 "
    c_Query += "	INNER JOIN ? SB1B ON SB1B.B1_FILIAL = '?' AND SC2.C2_PRODUTO = SB1B.B1_COD AND SB1B.D_E_L_E_T_ = '' "
    c_Query += "	LEFT OUTER JOIN ? SG1  ON G1_FILIAL = '?' AND SG1.G1_COD = SC2.C2_PRODUTO AND SG1.D_E_L_E_T_ = '' "
    c_Query += "	LEFT OUTER JOIN ? SB1  ON SB1.B1_FILIAL = '?' AND SG1.G1_COMP = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
    c_Query += "	LEFT OUTER JOIN (SELECT D4_OP,D4_COD,SUM(D4_QUANT) EMPENHO FROM ? "
    c_Query += "						WHERE D4_FILIAL = '?' AND D_E_L_E_T_ = '' "
    c_Query += "						GROUP BY D4_OP,D4_COD "
    c_Query += "						) SD4 "
    c_Query += "		ON D4_OP = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AND D4_COD = G1_COMP "
    c_Query += "	LEFT OUTER JOIN (SELECT C1_PRODUTO,C1_OP,COUNT(*) REGSC1 FROM ? "
    c_Query += "				WHERE C1_FILIAL = '?' AND D_E_L_E_T_ = '' "
    c_Query += "				GROUP BY C1_PRODUTO,C1_OP) SC1 "
    c_Query += "				ON SC1.C1_PRODUTO = SG1.G1_COMP AND SC1.C1_OP = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN "
    c_Query += "	LEFT OUTER JOIN ? SC7 ON SC7.C7_FILIAL = '?' AND SC7.C7_PRODUTO = SG1.G1_COMP AND SC7.C7_OP = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AND SC7.D_E_L_E_T_ = '' "
    c_Query += "	LEFT OUTER JOIN ? SC2B  ON SC2B.C2_FILIAL = '?' AND SC2.C2_NUM+SC2.C2_ITEM = SC2B.C2_NUM+SC2B.C2_ITEM AND SC2.C2_SEQPAI = SC2B.C2_SEQUEN AND SC2B.D_E_L_E_T_ = ''
    c_Query += "	LEFT OUTER JOIN ? SC2C  ON SC2C.C2_FILIAL = '?' AND SD4.D4_COD = SC2C.C2_PRODUTO AND SC2C.D_E_L_E_T_ = '' AND SC2C.C2_DATRF = ''"
    c_Query += "    WHERE SC2.D_E_L_E_T_ = '' AND SC2.C2_FILIAL = '?' AND SC2.C2_DATRF = '' "
    c_Query += "		AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN >= '?' AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN <= '?' AND SC2.C2_ITEMCTA >= '?'  AND SC2.C2_ITEMCTA <= '?' "
    //c_Query += "    ORDER BY SC2.C2_XPROJET,SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN "

    c_Query += "UNION ALL

    c_Query += "SELECT SC5.C5_XPROJET [PROJETO], SC6.C6_NUM [OP], SC6.C6_EMISSAO [DATAOP], SC6.C6_PRODUTO [CODITEM], SB1.B1_DESC [DESCR], SC6.C6_NUM [PRDORD], "
    c_Query += "	SA1.A1_NOME [DESCPRD], SC6.C6_QTDVEN [QTDOP], 0 [ESTOQUE], SC6.C6_QTDVEN [EMPENHO], 0 [DISPONIB], SPACE(10) [TIPO], ISNULL(C7_NUM,SPACE(6)) [ORDCOM], "
    c_Query += "	ISNULL(C7_ITEM,SPACE(3)) [ITEORD], ISNULL(C7_FORNECE,SPACE(6)) [FORNEC], ISNULL(C7_LOJA,SPACE(2)) [LOJA], "
    c_Query += "	ISNULL(C7_DATPRF,SPACE(8)) [PRZENT],CASE WHEN ISNULL(SC1.REGSC1,0) > 0 THEN 'S' ELSE 'N' END [TEMSC], ''  [OPPAI], SC6.C6_LOCAL [LOCOP], ISNULL(SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN,SPACE(13)) [OPFILHA] "
    c_Query += "	FROM ? SC6 "
    c_Query += "	INNER JOIN ? SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
    c_Query += "	INNER JOIN ? SA1 ON SA1.A1_FILIAL = '?' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
    c_Query += "	INNER JOIN ? SB1 ON SB1.B1_FILIAL = '?' AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
    c_Query += "	LEFT OUTER JOIN ? SC2  ON SC2.C2_FILIAL = SC6.C6_FILIAL AND SC2.C2_ITEMCTA = SC5.C5_XPROJET AND SC2.C2_PRODUTO = SC6.C6_PRODUTO AND SC2.D_E_L_E_T_ = '' AND SC2.C2_DATRF = ''"
    c_Query += "	LEFT OUTER JOIN (SELECT C1_PRODUTO,C1_ITEMCTA,COUNT(*) REGSC1 FROM ? "
    c_Query += "				WHERE C1_FILIAL = '?' AND D_E_L_E_T_ = '' "
    c_Query += "				GROUP BY C1_PRODUTO,C1_ITEMCTA) SC1 "
    c_Query += "				ON SC1.C1_PRODUTO = SC6.C6_PRODUTO AND SC1.C1_ITEMCTA = SC5.C5_XPROJET"
    c_Query += "	LEFT OUTER JOIN ? SC7 ON SC7.C7_FILIAL = '?' AND SC7.C7_PRODUTO = SC6.C6_PRODUTO AND SC7.C7_ITEMCTA = SC5.C5_XPROJET AND SC7.D_E_L_E_T_ = '' "
    c_Query += "    WHERE SC6.D_E_L_E_T_ = '' AND SC6.C6_FILIAL = '?' AND SC6.C6_NOTA = '' AND SC6.C6_NUM <> ''"
    c_Query += "		AND SC6.C6_NUM >= '?' AND SC6.C6_NUM <= '?' AND SC5.C5_XPROJET >= '?'  AND SC5.C5_XPROJET <= '?' "
    c_Query += "    ORDER BY PROJETO,OP "

    c_Query := ChangeQuery(c_Query)
    o_Query := FWPreparedStatement():New(c_Query)

    o_Query:SetUnsafe(1, RetSqlName( "SC2" ))
    o_Query:SetUnsafe(2, RetSqlName( "SB1" ))
    o_Query:SetUnsafe(3, xFilial( "SB1" ))
    o_Query:SetUnsafe(4, RetSqlName( "SG1" ))
    o_Query:SetUnsafe(5, xFilial( "SG1" ))
    o_Query:SetUnsafe(6, RetSqlName( "SB1" ))
    o_Query:SetUnsafe(7, xFilial( "SB1" ))
    o_Query:SetUnsafe(8, RetSqlName( "SD4" ))
    o_Query:SetUnsafe(9, xFilial( "SD4" ))
    o_Query:SetUnsafe(10, RetSqlName( "SC1" ))
    o_Query:SetUnsafe(11, xFilial( "SC1" ))
    o_Query:SetUnsafe(12, RetSqlName( "SC7" ))
    o_Query:SetUnsafe(13, xFilial( "SC7" ))
    o_Query:SetUnsafe(14, RetSqlName( "SC2" ))
    o_Query:SetUnsafe(15, xFilial( "SC2" ))
    o_Query:SetUnsafe(16, RetSqlName( "SC2" ))
    o_Query:SetUnsafe(17, xFilial( "SC2" ))
    o_Query:SetUnsafe(18, xFilial( "SC2" ))
    o_Query:SetUnsafe(19, c_OPDe)
    o_Query:SetUnsafe(20, c_OPAte)
    o_Query:SetUnsafe(21, c_ProjDe)
    o_Query:SetUnsafe(22, c_ProjAte)

    o_Query:SetUnsafe(23, RetSqlName( "SC6" ))
    o_Query:SetUnsafe(24, RetSqlName( "SC5" ))
    o_Query:SetUnsafe(25, RetSqlName( "SA1" ))
    o_Query:SetUnsafe(26, xFilial( "SA1" ))
    o_Query:SetUnsafe(27, RetSqlName( "SB1" ))
    o_Query:SetUnsafe(28, xFilial( "SB1" ))
    o_Query:SetUnsafe(29, RetSqlName( "SC2" ))
    o_Query:SetUnsafe(30, RetSqlName( "SC1" ))
    o_Query:SetUnsafe(31, xFilial( "SC1" ))
    o_Query:SetUnsafe(32, RetSqlName( "SC7" ))
    o_Query:SetUnsafe(33, xFilial( "SC7" ))
    o_Query:SetUnsafe(34, xFilial( "SC6" ))
    o_Query:SetUnsafe(35, c_PVDe)
    o_Query:SetUnsafe(36, c_PVAte)
    o_Query:SetUnsafe(37, c_ProjDe)
    o_Query:SetUnsafe(38, c_ProjAte)

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
    l_Ret := oPrtXlsx:SetColumnsWidth( 2,  2, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 3,  3, 19    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 4,  4, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 5,  5, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 6,  6, 50    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 7,  7, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 8,  8, 50    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 9,  9, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 10, 10, 18    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 11, 11, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 12, 12, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 13, 13, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 14, 14, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 15, 15, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 16, 16, 16    )

    // Seta a formatação de celula a ser usada
    l_Ret := oPrtXlsx:SetCellsFormat( c_HorAlig, c_VerAlig, l_WrapText, n_Rotation, "000000", "FFFFFF", c_Custom )

    // Seta a fonte a ser usada
    l_Ret := oPrtXlsx:SetFont( c_Font, n_Size, l_Italic, l_Bold, l_Under )

    // Preenche o cabeçalho
    l_Ret := oPrtXlsx:SetText(n_Linha,   1, "Projeto"			)
    l_Ret := oPrtXlsx:SetText(n_Linha,   2, "OP/PV"         	)
    l_Ret := oPrtXlsx:SetText(n_Linha,   3, "OP Pai" 			)
    l_Ret := oPrtXlsx:SetText(n_Linha,   4, "Data da OP/PV"		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   5, "Código do Item"	)
    l_Ret := oPrtXlsx:SetText(n_Linha,   6,	"Descrição do Item"	)
    l_Ret := oPrtXlsx:SetText(n_Linha,   7, "Produto da OP/PV"  )
    l_Ret := oPrtXlsx:SetText(n_Linha,   8, "Descr Prod OP/PV" 	)
    l_Ret := oPrtXlsx:SetText(n_Linha,   9, "Quant da OP/PV"	)
    l_Ret := oPrtXlsx:SetText(n_Linha,   10, "Estoque"    		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   11, "Empenho"  		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   12, "Tipo"  			)
    l_Ret := oPrtXlsx:SetText(n_Linha,   13, "Documento"        )
    l_Ret := oPrtXlsx:SetText(n_Linha,   14, "Fornecedor"  		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   15, "Loja"		  		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   16, "Prazo de Entrega" )

Return(l_Ret)


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaLin
  Preenche a linha do excel, conforme dataset posicionado
  @type function
  @author Silvio Nogueira
  @since 16/10/2025
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
    l_Ret := oPrtXlsx:SetText(	n_Linha,  1, 	(c_Alias)->PROJETO 	)
    l_Ret := oPrtXlsx:SetText(	n_Linha,  2, 	(c_Alias)->OP   	)
    l_Ret := oPrtXlsx:SetText(	n_Linha,  3, 	(c_Alias)->OPPAI	)


    SetDateCell((c_Alias)->DATAOP,  n_Linha,4)

    l_Ret := oPrtXlsx:SetText(	n_Linha,  5, 	(c_Alias)->CODITEM 	)
    l_Ret := oPrtXlsx:SetText( 	n_Linha,  6, 	(c_Alias)->DESCR  	)
    l_Ret := oPrtXlsx:SetText(	n_Linha,  7, 	(c_Alias)->PRDORD 	)
    l_Ret := oPrtXlsx:SetText( 	n_Linha,  8, 	(c_Alias)->DESCPRD 	)
    l_Ret := oPrtXlsx:SetNumber(n_Linha,  9, 	(c_Alias)->QTDOP	)
    l_Ret := oPrtXlsx:SetNumber(n_Linha, 10, 	(c_Alias)->ESTOQUE	)
    l_Ret := oPrtXlsx:SetNumber(n_Linha, 11, 	(c_Alias)->EMPENHO	)
    l_Ret := oPrtXlsx:SetText(	n_Linha, 12, 	(c_Alias)->TIPO		)
    l_Ret := oPrtXlsx:SetText(	n_Linha, 13, 	If(!Empty((c_Alias)->ORDCOM),(c_Alias)->ORDCOM+(c_Alias)->ITEORD,If(!Empty((c_Alias)->OPFILHA),(c_Alias)->OPFILHA,'')))
    //l_Ret := oPrtXlsx:SetText(	n_Linha, 14, 	(c_Alias)->ITEORD 	)
    l_Ret := oPrtXlsx:SetText(	n_Linha, 14, 	(c_Alias)->FORNEC 	)
    l_Ret := oPrtXlsx:SetText(	n_Linha, 15, 	(c_Alias)->LOJA 	)

    SetDateCell((c_Alias)->PRZENT,  n_Linha,16)

Return(l_Ret)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp
  Cria tabela temporária para ativar modo gravação
  @type function
  @author Silvio Nogueira
  @since 16/10/2025
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function CriaTabTemp()

    Local n_Campo
    Local a_Struct
    Local o_TempTable
    Local a_Campos := {}

    a_Struct	:= (c_Temp)->(dbStruct())

    For n_Campo := 1 To Len( a_Struct )

        Aadd(a_Campos, {a_Struct[n_Campo][1],;
                       a_Struct[n_Campo][2],;
                       a_Struct[n_Campo][3],;
                       a_Struct[n_Campo][4];
                      })

    Next n_Campo

    o_TempTable:= FWTemporaryTable():New(c_Alias)
    o_TempTable:SetFields( a_Campos )
    o_TempTable:AddIndex( "01", {'PROJETO','OP'} )
    o_TempTable:Create()

    (c_Temp)->(dbGotop())

    If !(c_Temp)->(Eof())

        While !(c_Temp)->(Eof())

            RecLock(c_Alias,.T.)
            (c_Alias)->PROJETO		:= (c_Temp)->PROJETO
            (c_Alias)->OP			:= (c_Temp)->OP 
            (c_Alias)->OPPAI		:= (c_Temp)->OPPAI
            (c_Alias)->DATAOP		:= (c_Temp)->DATAOP
            (c_Alias)->CODITEM		:= (c_Temp)->CODITEM
            (c_Alias)->DESCR		:= (c_Temp)->DESCR
            (c_Alias)->PRDORD		:= (c_Temp)->PRDORD
            (c_Alias)->DESCPRD		:= (c_Temp)->DESCPRD
            (c_Alias)->QTDOP		:= (c_Temp)->QTDOP
            (c_Alias)->ESTOQUE		:= (c_Temp)->ESTOQUE
            (c_Alias)->EMPENHO		:= (c_Temp)->EMPENHO
            (c_Alias)->TIPO			:= (c_Temp)->TIPO
            (c_Alias)->ORDCOM		:= (c_Temp)->ORDCOM
            (c_Alias)->ITEORD		:= (c_Temp)->ITEORD
            (c_Alias)->FORNEC		:= (c_Temp)->FORNEC
            (c_Alias)->LOJA			:= (c_Temp)->LOJA
            (c_Alias)->PRZENT		:= (c_Temp)->PRZENT
            (c_Alias)->TEMSC		:= (c_Temp)->TEMSC
            (c_Alias)->DISPONIB		:= (c_Temp)->DISPONIB
            (c_Alias)->LOCOP		:= (c_Temp)->LOCOP
            
            (c_Temp)->(dbSkip())

        End

    Endif

    (c_Temp)->(dbCloseArea())

Return

//Static Function SetDateCell(xValue,cCabec,nR,nC)
Static Function SetDateCell(xValue,nR,nC)
    Local dValue := IF (Valtype(xValue) == 'D', xValue, StoD(xValue))


    cHorAlignment := oCellHorAlign:Center()
    cVertAlignment := oCellVertAlign:Center()
    lWrapText := .F.
    nRotation := 0
    cCustomFormat := "dd/mm/yyyy"
    // Comando 'Formato de Célula' com cor de texto e fundo personalizadas
    lRet := oPrtXlsx:SetCellsFormat(cHorAlignment, cVertAlignment, lWrapText, nRotation, "383838", "FBFBFB", cCustomFormat )

    nRow := nR
    nCol := nC
    // Texto na Célula
    lRet := oPrtXlsx:SetDate(nRow, nCol, dValue)

    lRet := oPrtXlsx:ResetCellsFormat()
Return
