#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "TBICONN.CH"

#Define ENTER  Chr(10) + Chr (13)
/* Programa para gerar a tabela bilver.
   Data: 18/10/2021
   	
*/
User Function CTBI001()

	Local _cSQL    := ""
	Local aPergs   := {}
	Local dDataDe  := FirstDate(Date())
	Local dDataAt  := LastDate(Date())
	Local dDataini := ""
	Local dDatafim := ""
	Local dDataAnt := ""
	Local cDir     := GetSrvProfString("RootPath","\SQL\" )
	
	If Select("SX6") == 0                  // Chamada Via Programas do Protheus ou Menu do Modulo ou do IDE 

		Prepare Environment Empresa "01" Filial "01" MODULO "CTB"

		dDataini := dtos(dDataDe)
		dDatafim := dtos(dDataAt)
		dDataAnt := dtos(lastday(dDataDe - 1))		
	//
	Else
		aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
		aAdd(aPergs, {1, "Data Até", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
		//
		If ParamBox(aPergs, "Informe os parâmetros")

			dDataini := dtos(MV_PAR01)
			dDatafim := dtos(MV_PAR02)
			dDataAnt := dtos(lastday(MV_PAR01 - 1))

		Endif

	Endif
	
			// Excluo registros para não duplicar.
				_cSQL := "DELETE FROM bilver WHERE AnnoMese = '" +left(dDatafim,6) + "'"
				TcSQLExec(_cSQL)
			//
			
			_cSQL := "INSERT INTO bilver " + ENTER
			_cSQL += "SELECT " + ENTER
			_cSQL += " RTRIM(CT1_CONTA) AS [Conta] " + ENTER
			_cSQL += ",CASE " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '01' THEN 'Ativo' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '02' THEN 'Passivo' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '03' THEN 'Patrimonio Liquido' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '04' THEN 'Resultado' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '05' THEN 'Compensacao' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '09' THEN 'Outras' ELSE '' END AS [Tipo] " + ENTER
			_cSQL += ",RTRIM(CT1_DESC01) AS [Descricao] " + ENTER
			_cSQL += ",ROUND(ISNULL(SUM(CQ0_DEBITO),0) - ISNULL(SUM(CQ0_CREDIT),0),2) AS [Importo] " + ENTER
			_cSQL += ",left('"+dDatafim+"',4) AS [Anno] " + ENTER
			_cSQL += ",substring('"+dDatafim+"',5,2) AS [Mese] " + ENTER
			_cSQL += ",left('"+dDatafim+"',6) AS [AnnoMese] " + ENTER
			_cSQL += ",'" +dDatafim+"' AS [Data] " + ENTER
			_cSQL += ",'Protheus' AS [notes] " + ENTER
			_cSQL += "FROM " + RetSqlName("CQ0") + " CQ0 (NOLOCK) " + ENTER
			_cSQL += "INNER JOIN " + RetSqlName("CT1") +" CT1 (NOLOCK) " + ENTER
			_cSQL += "ON CT1.CT1_FILIAL  = CT1.CT1_FILIAL " + ENTER
			_cSQL += "AND CT1.CT1_CONTA  = CQ0.CQ0_CONTA " + ENTER
			_cSQL += "AND CT1.D_E_L_E_T_ = '' " + ENTER
			_cSQL += " WHERE CQ0.D_E_L_E_T_ = ' ' " + ENTER
			_cSQL += " AND CQ0.CQ0_FILIAL = '01' " + ENTER
			_cSQL += " AND CQ0.CQ0_MOEDA  = '01' " + ENTER
			_cSQL += " AND CQ0.CQ0_TPSALD = '1' " + ENTER
			_cSQL += " AND CQ0_DATA <= '"+dDatafim + "'" + ENTER
			_cSQL += " AND left(CQ0_CONTA,1) < '3' " + ENTER
			_cSQL += " GROUP BY CT1.CT1_CONTA, CT1.CT1_NATCTA, CT1.CT1_DESC01 " + ENTER
			_cSQL += " UNION ALL " + ENTER
			_cSQL += "  SELECT " + ENTER
			_cSQL += "  CONTA " + ENTER
			_cSQL += ", CASE " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '01' THEN 'Ativo' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '02' THEN 'Passivo' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '03' THEN 'Patrimonio Liquido' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '04' THEN 'Resultado' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '05' THEN 'Compensacao' " + ENTER
			_cSQL += "	WHEN CT1_NATCTA = '09' THEN 'Outras' ELSE '' END AS [Tipo] " + ENTER
			_cSQL += ",RTRIM(CT1_DESC01) AS [Descrição] " + ENTER
			_cSQL += ",CASE " + ENTER
			_cSQL += "	WHEN substring('"+dDatafim+"',5,2) = '12' " + ENTER
			_cSQL += "		THEN ROUND( ISNULL(SUM(SLDANTDEB),0) - ISNULL(SUM(SLDANTCRD),0),2) " + ENTER
			_cSQL += "		ELSE ROUND( ISNULL(SUM(SALDODEBATU),0) - ISNULL(SUM(SALDOCRDATU),0),2) " + ENTER
			_cSQL += "	END as [Importo] " + ENTER
			_cSQL += ",left('"+dDatafim+"',4) AS [Anno] " + ENTER
			_cSQL += ",substring('"+dDatafim+"',5,2) AS [Mese] " + ENTER
			_cSQL += ",left('"+dDatafim+"',6) AS [AnnoMese] " + ENTER
			_cSQL += ",'" +dDatafim+"' AS [Data] " + ENTER
			_cSQL += ",'Protheus' AS [notes] " + ENTER
			_cSQL += " FROM " + ENTER
			_cSQL += " ( SELECT " + ENTER
			_cSQL += "	 ISNULL(SUM(CQ1_DEBITO),0) SALDODEB " + ENTER
			_cSQL += "	,ISNULL(SUM(CQ1_CREDIT),0) SALDOCRD " + ENTER
			_cSQL += "	,0 SLDANTDEB " + ENTER
			_cSQL += "	,0 SLDANTCRD " + ENTER
			_cSQL += "	,0 SALDODEBLP " + ENTER
			_cSQL += "	,0 SALDOCRDLP " + ENTER
			_cSQL += "	,0 SALDODEBATU " + ENTER
			_cSQL += "	,0 SALDOCRDATU " + ENTER
			_cSQL += "	,CQ1_CONTA CONTA " + ENTER
			_cSQL += "   FROM " + RetSqlName("CQ1") + ENTER
			_cSQL += "   WHERE D_E_L_E_T_ = ' ' " + ENTER
			_cSQL += "   AND  CQ1_FILIAL = '01' " + ENTER
			_cSQL += "   AND CQ1_MOEDA = '01' " + ENTER
			_cSQL += "   AND CQ1_TPSALD = '1' " + ENTER
			_cSQL += "   AND CQ1_DATA = '"+dDatafim + "'" + ENTER
			_cSQL += "   GROUP BY " + ENTER
			_cSQL += "   CQ1_CONTA " + ENTER
			_cSQL += "   UNION ALL " + ENTER
			_cSQL += "   SELECT " + ENTER
			_cSQL += "    0 SALDODEB " + ENTER
			_cSQL += "   ,0 SALDOCRD " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ0_DEBITO),0) SLDANTDEB " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ0_CREDIT),0) SLDANTCRD " + ENTER
			_cSQL += "   ,0 SALDODEBLP " + ENTER
			_cSQL += "   ,0 SALDOCRDLP " + ENTER
			_cSQL += "   ,0 SALDODEBATU " + ENTER
			_cSQL += "   ,0 SALDOCRDATU " + ENTER
			_cSQL += "   ,CQ0_CONTA CONTA " + ENTER
			_cSQL += "   FROM "+ RetSqlName("CQ0") + ENTER
			_cSQL += "   WHERE " + ENTER
			_cSQL += "   D_E_L_E_T_ = ' ' " + ENTER
			_cSQL += "   AND  CQ0_FILIAL = '01' " + ENTER
			_cSQL += "   AND CQ0_MOEDA = '01' " + ENTER
			_cSQL += "   AND CQ0_TPSALD = '1' " + ENTER
			_cSQL += "   AND CQ0_DATA <= '"+dDataAnt +"'"+ ENTER
			_cSQL += "   GROUP BY " + ENTER
			_cSQL += "   CQ0_CONTA " + ENTER
			_cSQL += "   UNION ALL " + ENTER
			_cSQL += "   SELECT " + ENTER
			_cSQL += "    0 SALDODEB " + ENTER
			_cSQL += "   ,0 SALDOCRD " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ1_DEBITO),0) SLDANTDEB " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ1_CREDIT),0) SLDANTCRD " + ENTER
			_cSQL += "   ,0 SALDODEBLP " + ENTER
			_cSQL += "   ,0 SALDOCRDLP " + ENTER
			_cSQL += "   ,0 SALDODEBATU " + ENTER
			_cSQL += "   ,0 SALDOCRDATU " + ENTER
			_cSQL += "   ,CQ1_CONTA CONTA " + ENTER
			_cSQL += "   FROM " + RetSqlName("CQ1") +  ENTER
			_cSQL += "   WHERE " + ENTER
			_cSQL += "   D_E_L_E_T_ = ' ' " + ENTER
			_cSQL += "   AND  CQ1_FILIAL = '01' " + ENTER
			_cSQL += "   AND CQ1_MOEDA = '01' " + ENTER
			_cSQL += "   AND CQ1_TPSALD = '1' " + ENTER
			_cSQL += "   AND CQ1_DATA >= '" + dDataini +"'"+  ENTER
			_cSQL += "   AND CQ1_DATA <= '" + dDatafim +"'"+ ENTER
			_cSQL += "   and CQ1_LP <> 'Z' " + ENTER
			_cSQL += "   GROUP BY " + ENTER
			_cSQL += "   CQ1_CONTA " + ENTER
			_cSQL += "   UNION ALL " + ENTER
			_cSQL += "   SELECT " + ENTER
			_cSQL += "    0 SALDODEB " + ENTER
			_cSQL += "   ,0 SALDOCRD " + ENTER
			_cSQL += "   ,0 SLDANTDEB " + ENTER
			_cSQL += "   ,0 SLDANTCRD " + ENTER
			_cSQL += "   ,0 SALDODEBLP " + ENTER
			_cSQL += "   ,0 SALDOCRDLP " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ0_DEBITO),0) SALDODEBATU " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ0_CREDIT),0) SALDOCRDATU " + ENTER
			_cSQL += "   ,CQ0_CONTA CONTA " + ENTER
			_cSQL += "   FROM " + RetSqlName("CQ0") + ENTER
			_cSQL += "   WHERE " + ENTER
			_cSQL += "   D_E_L_E_T_ = ' ' " + ENTER
			_cSQL += "   AND  CQ0_FILIAL = '01' " + ENTER
			_cSQL += "   AND CQ0_MOEDA = '01' " + ENTER
			_cSQL += "   AND CQ0_TPSALD = '1' " + ENTER
			_cSQL += "   AND CQ0_DATA <= '" + dDataAnt +"'"+ ENTER
			_cSQL += "   GROUP BY " + ENTER
			_cSQL += "   CQ0_CONTA " + ENTER
			_cSQL += "   UNION ALL " + ENTER
			_cSQL += "   SELECT " + ENTER
			_cSQL += "    0 SALDODEB " + ENTER
			_cSQL += "   ,0 SALDOCRD " + ENTER
			_cSQL += "   ,0 SLDANTDEB " + ENTER
			_cSQL += "   ,0 SLDANTCRD " + ENTER
			_cSQL += "   ,0 SALDODEBLP " + ENTER
			_cSQL += "   ,0 SALDOCRDLP " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ1_DEBITO),0) SALDODEBATU " + ENTER
			_cSQL += "   ,ISNULL(SUM(CQ1_CREDIT),0) SALDOCRDATU " + ENTER
			_cSQL += "   ,CQ1_CONTA CONTA " + ENTER
			_cSQL += "   FROM " + RetSqlName("CQ1")  + ENTER
			_cSQL += "   WHERE " + ENTER
			_cSQL += "   D_E_L_E_T_ = ' ' " + ENTER
			_cSQL += "   AND  CQ1_FILIAL = '01' " + ENTER
			_cSQL += "   AND CQ1_MOEDA = '01' " + ENTER
			_cSQL += "   AND CQ1_TPSALD = '1' " + ENTER
			_cSQL += "   AND CQ1_DATA >= '" +dDataini +"'"+ ENTER
			_cSQL += "   AND CQ1_DATA <= '" +dDatafim +"'"+ ENTER
			_cSQL += "   GROUP BY " + ENTER
			_cSQL += "   CQ1_CONTA) SALDO " + ENTER
			_cSQL += "		INNER JOIN "+ RetSqlName("CT1") + " CT1 (NOLOCK) " + ENTER
			_cSQL += "			ON CT1.CT1_FILIAL  = CT1.CT1_FILIAL " + ENTER
			_cSQL += "			AND CT1.CT1_CONTA  = SALDO.CONTA " + ENTER
			_cSQL += "			AND CT1.D_E_L_E_T_ = '' " + ENTER
			_cSQL += "		WHERE LEFT(CONTA,1) > '2' " + ENTER
			_cSQL += "		GROUP BY  CONTA , CT1.CT1_NATCTA  , CT1.CT1_DESC01 "
			//
			Memowrite(cDir + "\SQL\" + "ctbi001.sql", _cSQL)
			//
			If TcSQLExec(_cSQL) < 0
				//
				If Select("SX6") == 0 
					Conout("Erro ao processar a query. CTBI001")
				Else
					MsgStop( "TcSQLError() " + TcSQLError(), 'Cavanna' )
					Return( Nil )
				Endif
				//
			Else
				//
				If Select("SX6") == 0 
					Conout("Processo executado com sucesso. CTBI001 ")
				Else
					MsgInfo( "Incluido os registro na tabela Bilver com Sucesso!!!", 'Bilver - Cavanna' )				
				Endif//
			Endif
		//
	If Select("SX6") == 0 
		RESET ENVIRONMENT
	Endif
Return

User Function BilverExc()

	Local _cSQL    := ""
	Local aPergs   := {}
	Local dDataDe  := FirstDate(Date())
	Local dDataAt  := LastDate(Date())

	aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Até", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
	//
	If ParamBox(aPergs, "Informe os parâmetros")

		dDataini := dtos(MV_PAR01)
		dDatafim := dtos(MV_PAR02)

		If MSGYESNO("Deseja gerar a tabela Bilver em Excel?","Gerar Excel Bilver")
			_cSQL := "SELECT Conta, Tipo, Descricao, Importo, Left(AnnoMese,4) , Mese, AnnoMese, Data, notes "
			_cSQL += "FROM bilver WHERE AnnoMese = '" +left(dDatafim,6) + "'"
			U_zQry2Excel(_cSQL,"Bilver")
		Else	
			MsgInfo("Obrigado!!! Caso necessite verifique a view no SQL!","Info Bilver - Cavanna")	
		Endif
	EndIf

Return
