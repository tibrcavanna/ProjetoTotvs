#include "totvs.ch"
#include "fileio.ch"
#INCLUDE 'FWMVCDEF.CH'


static oCellAligH := FwXlsxCellAlignment():Horizontal()
static oCellAligV := FwXlsxCellAlignment():Vertical()

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}  FSPCPR03
  Função para gerar excel de relatório de Completamento, listando todos as OPs e respectivas
  informações para apoiar nas decisões do planejamento
  @type function
  @author Silvio Nogueira Silva
  @since 16/10/25025
/*/
//-------------------------------------------------------------------------------------------------------------

User Function FSPCPR03()
    Local a_Area    := FWGetArea()
    Local l_Ret     := Nil
    Local a_Pergs   := {}
    Local c_OPDe    := Space( TamSX3( "H6_OP")[01] )
    Local c_OPAte   := Replicate("Z", TamSX3( "H6_OP")[01] )
    Local c_ProdDe  := Space( TamSX3( "B2_COD")[01] )
    Local c_ProdAte := Replicate("Z", TamSX3( "B2_COD")[01] )
    Local c_PVDe    := Space( TamSX3( "C5_NUM")[01] )
    Local c_PVAte   := Replicate("Z", TamSX3( "C5_NUM")[01] )
    Local c_ProjDe  := Space( TamSX3( "C5_XPROJET")[01] )
    Local c_ProjAte := Replicate("Z", TamSX3( "C5_XPROJET")[01] )

    Local c_GetFile

    Private c_Temp     := GetNextAlias()
    Private c_Alias    := GetNextAlias()

    aAdd( a_Pergs, {1, "OP De "   		, c_OPDe   , ""            , ""           , "SC2"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "OP Ate "  		, c_OPAte  , ""            , ""           , "SC2"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Produto De "   	, c_ProdDe   , ""            , ""           , "SB1"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Produto Ate "  	, c_ProdAte  , ""            , ""           , "SB1"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Ped Venda De "  , c_PVDe   , ""            , ""           , "SC5"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Ped Venda Ate " , c_PVAte  , ""            , ""           , "SC5"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Projeto De "   	, c_ProjDe   , ""            , ""           , "CTD"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Projeto Ate "  	, c_ProjAte  , ""            , ""           , "CTD"  , "",   0, .F. } )

    If ParamBox( a_Pergs, "Gera Excel - Completamento",,,,,,,,, .F. )
        c_OPDe  	:=  M->MV_PAR01
        c_OPAte 	:=  M->MV_PAR02
        c_ProdDe  	:=  M->MV_PAR03
        c_ProdAte 	:=  M->MV_PAR04
        c_GetFile := tFileDialog( "" , "Seleção de Arquivos",,GetTempPath(),.T.)

        If ! Empty(c_GetFile)
            If FWAlertYesNo("Confirma a geração dos arquivos ?", "Continuar?" )
                Processa( {|| GeraExcel( c_GetFile, c_OPDe, c_OPAte, c_ProdDe, c_ProdAte, c_ProjDe, c_ProjAte, c_PVDe, c_PVAte ) },,, .T.)
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
         c_ProdDe,      char,   produto de
         c_ProdAte,     char,   produto ate
  @return l_Ret, 	bollean, True se gerado com sucesso.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function GeraExcel( c_GetFile,  c_OPDe, c_OPAte, c_ProdDe, c_ProdAte,c_ProjDe, c_ProjAte, c_PVDe, c_PVAte )
    Local l_Ret      := .T.
    Local c_NomeArq  := "COMPLET" + FwTimeStamp()
    Local c_ArqTemp  := "\spool\" + c_NomeArq + ".rel"
    Local n_LinXLS   := 1
    Local c_PathDest := c_GetFile
    Local c_Query
    Local c_Msg      := ""
    Local a_Estoque
    Local n_Estoque
    Local n_FaltaCom
    Local n_Disponib
    Local c_Status
    Local c_OPAtu
    Local n_ItOP
    Local n_TotDisp
    Local c_ProjAtu
    Local n_ItemEst
    Local c_CompAtu
    Local n_ItemFlt
    Local n_OPDisp
    Local c_TemCom

    Private oPrtXlsx := NIL
    Private c_Item


    ProcRegua(1)
    IncProc("Obtendo dados para gerar o excel...")
    ProcessMessage()


    c_Query := MontaQry( c_OPDe, c_OPAte, c_ProdDe, c_ProdAte,c_ProjDe, c_ProjAte, c_PVDe, c_PVAte )

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
        l_Ret    := oPrtXlsx:AddSheet( "Rel Completamento" )
        l_Ret    := oPrtXlsx:ApplyAutoFilter(1, 1, (c_Alias)->(LASTREC())+1, 11)
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
        n_LinXLS := 1

    
        // Calcula saldos estoque , falta Compras e Disponibidade
        (c_Alias)->(dbGotop())
        Do While l_Ret .and. (c_Alias)->(! eof())

            c_OPAtu := (c_Alias)->OP
            c_ProjAtu := (c_Alias)->PROJETO
            c_CompAtu := (c_Alias)->COMPONENTE
            n_ItemEst   := 0
            n_ItemFlt   := 0
            n_OPDisp    := 0

            n_Estoque := 0

            //Obtem o saldo em estoque do componentes em um local da OP (C2_LOCAL).
            a_Estoque 	:= CalcEst( (c_Alias)->COMPONENTE, (c_Alias)->LOCOP, date()+1 )
            n_Estoque 	:= a_Estoque[1]

            n_FaltaCom	:= (c_Alias)->QTDESTRUT - n_Estoque // Calcula Falta Compras = Soma do Total (Qtd Estrutura) – Soma do Estoque
            n_FaltaCom	:= If(n_FaltaCom < 0,0,n_FaltaCom)

            n_Disponib	:= Round(n_Estoque / (c_Alias)->QTDESTRUT,2)
            n_Disponib	:= If(n_Disponib>1,1,n_Disponib)*100 // Calcula percentual do estoque X quantidade total da estrutura
             
            If n_Disponib >= 1

                n_ItemEst++
                n_OPDisp += n_Disponib

            ElseIf n_FaltaCom > 0

                n_ItemFlt++

            Endif
                
            RecLock(c_Alias,.F.)			
            (c_Alias)->ESTOQUE	:= n_ItemEst
            (c_Alias)->FLT_COM	:= n_ItemFlt
            (c_Alias)->DISPONIB	:= n_Disponib
            MsUnlock()

            (c_Alias)->(dbSkip())

        EndDo


        // Atualiza Status da OP
        (c_Alias)->(dbGotop())
        Do While l_Ret .and. (c_Alias)->(! eof())

            c_OPAtu		:= (c_Alias)->OP
            n_RecAnt	:= (c_Alias)->(Recno())

            n_ItOP		:= 0

            n_ItemEst := 0
            n_ItemFlt := 0
            n_TotDisp	:= 0

            c_TemCom	:= 'N'

            Do While (c_Alias)->(!eof()) .And. c_OPAtu == (c_Alias)->OP

                n_ItOP++
                n_TotDisp += (c_Alias)->DISPONIB

                n_ItemEst += (c_Alias)->ESTOQUE
                n_ItemFlt += (c_Alias)->FLT_COM

                c_TemCom    := If(c_TemCom == "S",c_TemCom,If((c_Alias)->TEMCOMPRA == "S","S","N"))


                (c_Alias)->(dbSkip())

            Enddo
            
            (c_Alias)->(dbGoto(n_RecAnt))

            c_OPAtu		:= (c_Alias)->OP
            c_Status	:= If((c_Alias)->OPINICIADA == 'S','Montagem',If(n_TotDisp/n_ItOP == 100,'Estoque',If(c_TemCom == 'S','Compras',If((c_Alias)->TPDOC == 'OP','Ordem de Produção','Pedido de Venda'))))

            Do While (c_Alias)->(! eof()) .And. c_OPAtu == (c_Alias)->OP

                RecLock(c_Alias,.F.)
                (c_Alias)->DISPONIB := n_TotDisp/n_ItOP
                (c_Alias)->ESTOQUE  := n_ItemEst
                (c_Alias)->FLT_COM  := n_ItemFlt
                (c_Alias)->TOT_ITE  := n_ItOP
                
                (c_Alias)->STATUS   := c_Status

                (c_Alias)->(dbSkip())
                MsUnlock()

            Enddo

        EndDo

        l_Ret := MontaCab( n_LinXLS )

        c_OPAtu := ""
        c_ProjAtu := ""

        (c_Alias)->(dbGotop())

        Do While l_Ret .and. (c_Alias)->(! eof())
            IncProc("Gerando excel no servidor...")
            ProcessMessage()

            If c_OPAtu <> (c_Alias)->OP .Or. c_ProjAtu <> (c_Alias)->PROJETO

                n_LinXLS++

                l_Ret := MontaLin( n_LinXLS )

            Endif

            c_OPAtu := (c_Alias)->OP
            c_ProjAtu := (c_Alias)->PROJETO

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
  @param c_ProdDe,      char,   projeto de
         c_ProdAte,     char,   projeto ate
         c_DescDe,      char,   OP de 
         c_DescAte      char,   OP ate
  @return c_Query, 	char, Script SQL.
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MontaQry( c_OPDe, c_OPAte, c_ProdDe, c_ProdAte, c_ProjDe, c_ProjAte, c_PVDe, c_PVAte )
    Local o_Query
    Local c_Query := ""

    c_Query := "SELECT 'OP' TPDOC,C2_NUM+C2_ITEM+C2_SEQUEN [OP],C2_XPROJET [PROJETO], C2_PRODUTO [CODIGO],ISNULL(G1_COMP,'') [COMPONENTE],B1_DESC [DESCR],ISNULL(QTDESTRUT*SC2.C2_QUANT,0) [QTDESTRUT],0 [ESTOQUE],"
    c_Query += "	0 [FLT_COM],0 [DISPONIB], CASE WHEN ISNULL(SH6.REGS,0) > 0 THEN 'S' ELSE 'N' END [OPINICIADA],"
    c_Query += "	ISNULL(SG2.HRSMONT,0) [HRSMONT], SPACE(20) [STATUS],"
    c_Query += "	CASE WHEN ISNULL(SC7.REGSC7,0) > 0 THEN 'S' ELSE 'N' END [TEMCOMPRA], C2_LOCAL [LOCOP], 0 [QTD_EST], 0 [TOT_ITE] FROM ? SC2 "
    c_Query += "	INNER JOIN ? SB1 ON B1_FILIAL = '?' AND C2_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = '' "

    c_Query += "	LEFT OUTER JOIN ( "
    c_Query += "					SELECT G1_FILIAL,C2_NUM+C2_SEQUEN+C2_ITEM [OP2],G1_COMP,SUM(G1_QUANT) [QTDESTRUT] FROM ? SG1B "
    c_Query += "						INNER JOIN ? SC2B ON SC2B.C2_FILIAL = '?' AND SC2B.C2_PRODUTO = G1_COD AND SC2B.D_E_L_E_T_ = '' "
    c_Query += "						WHERE SG1B.D_E_L_E_T_ = '' AND G1_FILIAL = '?' AND SC2B.C2_REVI BETWEEN G1_REVINI AND G1_REVFIM "
    c_Query += "						GROUP BY G1_FILIAL,C2_NUM+C2_SEQUEN+C2_ITEM,G1_COMP "
    c_Query += "						) SG1 "
    c_Query += "		ON OP2 = C2_NUM+C2_SEQUEN+C2_ITEM "

    c_Query += "	LEFT OUTER JOIN (SELECT H6_OP,COUNT(H6_OP) REGS FROM ? "
    c_Query += "						WHERE H6_FILIAL = '?' AND D_E_L_E_T_ = '' "
    c_Query += "						GROUP BY H6_OP) SH6 ON H6_OP = C2_NUM+C2_ITEM+C2_SEQUEN "
    c_Query += "	LEFT OUTER JOIN (SELECT G2_PRODUTO,G2_CODIGO,SUM(G2_TEMPAD) HRSMONT FROM ? "
    c_Query += "						WHERE G2_FILIAL = '?' AND D_E_L_E_T_ = '' "
    c_Query += "						GROUP BY G2_PRODUTO,G2_CODIGO) SG2 ON G2_PRODUTO = B1_COD AND G2_CODIGO = B1_OPERPAD  "
    c_Query += "	LEFT OUTER JOIN (SELECT C7_PRODUTO,COUNT(*) REGSC7 FROM ? "
    c_Query += "						WHERE C7_FILIAL = '?' AND C7_QUANT > C7_QUJE AND C7_RESIDUO = '' AND D_E_L_E_T_ = '' "
    c_Query += "						GROUP BY C7_PRODUTO) "
    c_Query += "						SC7 ON C7_PRODUTO = G1_COMP "
    c_Query += "  WHERE SC2.C2_DATRF = '' AND SC2.D_E_L_E_T_ = '' AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN >= '?' AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN <= '?' AND "
    c_Query += "  SC2.C2_PRODUTO >= '?' AND SC2.C2_PRODUTO <= '?' AND SC2.C2_ITEMCTA >= '?'  AND SC2.C2_ITEMCTA <= '?' "

    c_Query += " UNION ALL "

    c_Query += "SELECT  'PV' TPDOC,SC6.C6_NUM [OP],C5_XPROJET [PROJETO], SC6.C6_PRODUTO [CODIGO],SC6.C6_PRODUTO [COMPONENTE],B1_DESC [DESCR],"
    c_Query += "	ISNULL(SC6.C6_QTDVEN,0) [QTDESTRUT],0 [ESTOQUE],"
    c_Query += "       	0 [FLT_COM],0 [DISPONIB], 'N' [OPINICIADA],"
    c_Query += "       	ISNULL(SG2.HRSMONT,0) [HRSMONT], SPACE(20) [STATUS],"
    c_Query += "       	CASE WHEN ISNULL(SC7.REGSC7,0) > 0 THEN 'S' ELSE 'N' END [TEMCOMPRA], C6_LOCAL [LOCOP], 0 [QTD_EST], 0 [TOT_ITE] FROM ? SC6 "
    c_Query += "	INNER JOIN ? SC5 ON SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM AND SC5.D_E_L_E_T_ = '' "
    c_Query += "    INNER JOIN ? SB1 ON B1_FILIAL = '?' AND C6_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = '' "
    c_Query += "    LEFT OUTER JOIN (SELECT G2_PRODUTO,G2_CODIGO,SUM(G2_TEMPAD) HRSMONT FROM ? "
    c_Query += "       				WHERE G2_FILIAL = '?' AND D_E_L_E_T_ = '' "
    c_Query += "       				GROUP BY G2_PRODUTO,G2_CODIGO) SG2 ON G2_PRODUTO = B1_COD AND G2_CODIGO = B1_OPERPAD  "
    c_Query += "    LEFT OUTER JOIN (SELECT C7_PRODUTO,COUNT(*) REGSC7 FROM ?"
    c_Query += "       				WHERE C7_FILIAL = '?' AND C7_QUANT > C7_QUJE AND C7_RESIDUO = '' AND D_E_L_E_T_ = '' "
    c_Query += "       				GROUP BY C7_PRODUTO) SC7 ON C7_PRODUTO = B1_COD"
    c_Query += "    WHERE SC6.C6_NOTA = '' AND SC6.D_E_L_E_T_ = '' AND SC6.C6_NUM >= '?' AND SC6.C6_NUM <= '?' "
    c_Query += "AND SC6.C6_PRODUTO >= '?' AND SC6.C6_PRODUTO <= '?' AND SC5.C5_XPROJET >= '?' AND SC5.C5_XPROJET <= '?' AND C6_NUM <> ''"
    c_Query += "ORDER BY OP,PROJETO"

    c_Query := ChangeQuery(c_Query)
    o_Query := FWPreparedStatement():New(c_Query)

    o_Query:SetUnsafe(1, RetSqlName( "SC2" ))
    o_Query:SetUnsafe(2, RetSqlName( "SB1" ))
    o_Query:SetUnsafe(3, xFilial( "SB1" ))
    o_Query:SetUnsafe(4, RetSqlName( "SG1" ))
    o_Query:SetUnsafe(5, RetSqlName( "SC2" ))
    o_Query:SetUnsafe(6, xFilial( "SC2" ))
    o_Query:SetUnsafe(7, xFilial( "SG1" ))
    o_Query:SetUnsafe(8, RetSqlName( "SH6" ))
    o_Query:SetUnsafe(9, xFilial( "SH6" ))
    o_Query:SetUnsafe(10, RetSqlName( "SG2" ))
    o_Query:SetUnsafe(11, xFilial( "SG2" ))
    o_Query:SetUnsafe(12, RetSqlName( "SC7" ))
    o_Query:SetUnsafe(13, xFilial( "SC7" ))
    o_Query:SetUnsafe(14, c_OPDe)
    o_Query:SetUnsafe(15, c_OPAte)
    o_Query:SetUnsafe(16, c_ProdDe)
    o_Query:SetUnsafe(17, c_ProdAte)
    o_Query:SetUnsafe(18, c_ProjDe)
    o_Query:SetUnsafe(19, c_ProjAte)
    o_Query:SetUnsafe(20, RetSqlName( "SC6" ))
    o_Query:SetUnsafe(21, RetSqlName( "SC5" ))
    o_Query:SetUnsafe(22, RetSqlName( "SB1" ))
    o_Query:SetUnsafe(23, xFilial( "SB1" ))
    o_Query:SetUnsafe(24, RetSqlName( "SG2" ))
    o_Query:SetUnsafe(25, xFilial( "SG2" ))
    o_Query:SetUnsafe(26, RetSqlName( "SC7" ))
    o_Query:SetUnsafe(27, xFilial( "SC7" ))
    o_Query:SetUnsafe(28, c_PVDe)
    o_Query:SetUnsafe(29, c_PVAte)
    o_Query:SetUnsafe(30, c_ProdDe)
    o_Query:SetUnsafe(31, c_ProdAte)
    o_Query:SetUnsafe(32, c_ProjDe)
    o_Query:SetUnsafe(33, c_ProjAte)

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
    Local n_Size   := 9
    Local l_Italic := .F.
    Local l_Bold   := .T.
    Local l_Under  := .F.

    Local c_HorAlig  := oCellAligH:Center()
    Local c_VerAlig  := oCellAligV:Center()
    Local l_WrapText := .T.
    Local n_Rotation := 0
    Local c_Custom   := ""


    // Ajusta a largura das colunas
    l_Ret := oPrtXlsx:SetColumnsWidth( 1,  1, 4    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 2,  2, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 3,  3, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 4,  4, 19    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 5,  5, 50    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 6,  6, 16    )
    //l_Ret := oPrtXlsx:SetColumnsWidth( 6,  6, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 7,  7, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 8,  8, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth( 9,  9, 16    )
    l_Ret := oPrtXlsx:SetColumnsWidth(10,10, 18    )
    l_Ret := oPrtXlsx:SetColumnsWidth(11,11, 16    )

    // Seta a formatação de celula a ser usada
    l_Ret := oPrtXlsx:SetCellsFormat( c_HorAlig, c_VerAlig, l_WrapText, n_Rotation, "000000", "FFFFFF", c_Custom )


    // Seta a fonte a ser usada
    l_Ret := oPrtXlsx:SetFont( c_Font, n_Size, l_Italic, l_Bold, l_Under )


    // Preenche o cabeçalho
    l_Ret := oPrtXlsx:SetText(n_Linha,   1, "Tp Doc"            )
    l_Ret := oPrtXlsx:SetText(n_Linha,   2, "OP / PV"           )
    l_Ret := oPrtXlsx:SetText(n_Linha,   3, "Projeto" 			)
    l_Ret := oPrtXlsx:SetText(n_Linha,   4, "Código"  			)
    l_Ret := oPrtXlsx:SetText(n_Linha,   5, "Descrição"    		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   6,	"Status"       		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   7, "Total"          	)
    l_Ret := oPrtXlsx:SetText(n_Linha,   8, "Estoque"     		)
    l_Ret := oPrtXlsx:SetText(n_Linha,   9, "Falta Compras"    	)
    l_Ret := oPrtXlsx:SetText(n_Linha,  10, "Disponibilidade"  )
    l_Ret := oPrtXlsx:SetText(n_Linha,  11, "Hrs Montagem"  	)

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
    l_Ret := oPrtXlsx:SetText(	n_Linha,  1, (c_Alias)->TPDOC  	)
    l_Ret := oPrtXlsx:SetText(	n_Linha,  2, (c_Alias)->OP   	)
    l_Ret := oPrtXlsx:SetText(	n_Linha,  3, (c_Alias)->PROJETO )
    l_Ret := oPrtXlsx:SetText(	n_Linha,  4, (c_Alias)->CODIGO  )
    l_Ret := oPrtXlsx:SetText(	n_Linha,  5, (c_Alias)->DESCR 	)
    l_Ret := oPrtXlsx:SetText( 	n_Linha,  6, (c_Alias)->STATUS  )

    l_Ret := oPrtXlsx:SetNumber(	n_Linha,  7, (c_Alias)->TOT_ITE	)
    l_Ret := oPrtXlsx:SetNumber(	n_Linha,  8, (c_Alias)->ESTOQUE	)
    l_Ret := oPrtXlsx:SetNumber( 	n_Linha,  9, (c_Alias)->FLT_COM	)
    l_Ret := oPrtXlsx:SetNumber( 	n_Linha, 10, (c_Alias)->DISPONIB)
    l_Ret := oPrtXlsx:SetNumber(	n_Linha, 11, (c_Alias)->HRSMONT)

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
    o_TempTable:AddIndex( "01", {'OP','PROJETO','COMPONENTE'} )
    o_TempTable:Create()

    (c_Temp)->(dbGotop())

    If !(c_Temp)->(Eof())

        While !(c_Temp)->(Eof())

            RecLock(c_Alias,.T.)
            (c_Alias)->TPDOC		:= (c_Temp)->TPDOC
            (c_Alias)->OP			:= (c_Temp)->OP 
            (c_Alias)->PROJETO		:= (c_Temp)->PROJETO
            (c_Alias)->CODIGO		:= (c_Temp)->CODIGO
            (c_Alias)->DESCR		:= (c_Temp)->DESCR
            (c_Alias)->COMPONENTE	:= (c_Temp)->COMPONENTE
            (c_Alias)->QTDESTRUT	:= (c_Temp)->QTDESTRUT
            (c_Alias)->ESTOQUE		:= (c_Temp)->ESTOQUE
            (c_Alias)->FLT_COM		:= (c_Temp)->FLT_COM
            (c_Alias)->DISPONIB		:= (c_Temp)->DISPONIB
            (c_Alias)->OPINICIADA	:= (c_Temp)->OPINICIADA
            (c_Alias)->HRSMONT		:= (c_Temp)->HRSMONT
            (c_Alias)->STATUS		:= (c_Temp)->STATUS
            (c_Alias)->TEMCOMPRA	:= (c_Temp)->TEMCOMPRA
            (c_Alias)->LOCOP		:= (c_Temp)->LOCOP
            (c_Alias)->QTD_EST		:= (c_Temp)->QTD_EST
            (c_Alias)->TOT_ITE		:= (c_Temp)->TOT_ITE

            (c_Temp)->(dbSkip())

        End

    Endif

    (c_Temp)->(dbCloseArea())

Return
