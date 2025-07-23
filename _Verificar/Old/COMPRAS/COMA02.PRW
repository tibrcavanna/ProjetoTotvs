#Include 'rwmake.ch'
#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"

#Define ENTER  Chr(10) + Chr (13) // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)

User Function COMA02(cFornec,cProduto,cDoc)

	Local aArea     := GetArea()
	Local _cQry     := ""
	Local _nRet     := 0
	Local cArquivo  := "E:\TOTVS12\protheus_data\SQL\"

	_cQry += " SELECT " + ENTER
	_cQry += " Data_Inserimento_Ordine, " + ENTER
	_cQry += " Nr_Ordine, " + ENTER
	_cQry += " Riga_Ordine, " + ENTER
	_cQry += " Articolo, " + ENTER
	_cQry += " Desc_Articolo, " + ENTER
	_cQry += " BP, " + ENTER
	_cQry += " BusinessPartner, " + ENTER
	_cQry += " Nr_Ricevimento, " + ENTER
	_cQry += " Nr_DocTrasposto" + ENTER
	_cQry += " FROM " + ENTER
	//_cQry += " erpdb.dbo.Analisi_ODA_CPM_104 " + ENTER
	_cQry += " Analisi_ODA_CPM_104 " + ENTER
	_cQry += " WHERE SUBSTRING(BP,3,6) = '" + cFornec            + "'" + ENTER
	_cQry += "   AND Articolo        = '" + ALLTRIM(cProduto)    + "'" + ENTER
	_cQry += "   AND Nr_DocTrasposto = '" + CVALTOCHAR(VAL(cDoc))+ "'" + ENTER

	MemoWrite(cArquivo + "COMA02.sql", _cQry)

	If Select("WORK") > 0
		WORK->(dbCloseArea())
	EndIf

	DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, _cQry) , "WORK" , .T. , .T. )

	If !Empty(WORK->Nr_Ricevimento)
		_nRet := VAL(ALLTRIM(WORK->Nr_Ricevimento))
	EndIf

	RestArea(aArea)

Return _nRet
