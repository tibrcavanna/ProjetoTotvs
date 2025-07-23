#Include 'rwmake.ch'
#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

#Define ENTER  Chr (13) + Chr(10)  // SALTO DE LINHA (CARRIAGE RETURN + LINE FEED)

User Function COMA03()

	Local aArea     := GetArea()
	Local aAreaSF1  := SF1->(GetArea())
	Local _cQry     := ""
	Local cArquivo  := "E:\TOTVS12\protheus_data\SQL\"
	Local _cPerg    := "COMA03"
	Local _aCab     := {}
	Local _aItens   := {}
	Local aLinha    := {}
	Local nTotal    := 0
	Local nOpc      := 3 // Inclusão
	Local n
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	If !Pergunte(_cPerg,.T.)
		Return
	Endif

	DbSelectArea("SF1")
	SF1->(dbSetOrder(1)) //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
	If ! SF1->(dbSeek(xFilial() + MV_PAR01 + MV_PAR02 + MV_PAR04 + MV_PAR05))

		_cQry += " SELECT " + ENTER
		_cQry += " ROW_NUMBER() over( order BY Articolo, Riga_Ordine) as ITEM, " + ENTER
		_cQry += " Nr_Ordine, " + ENTER
		_cQry += " Riga_Ordine, " + ENTER
		_cQry += " Articolo, " + ENTER
		_cQry += " Desc_Articolo, " + ENTER
		_cQry += " Qtà_Ordinata AS [QTD], " + ENTER
		_cQry += " Costo_Unitario_Valuta, " + ENTER
		_cQry += " Importo_Lordo_Valuta, " + ENTER
		_cQry += " BP, " + ENTER
		_cQry += " BusinessPartner, " + ENTER
		_cQry += " Nr_Ricevimento, " + ENTER
		_cQry += " Nr_DocTrasposto" + ENTER
		_cQry += " FROM " + ENTER
		//_cQry += " erpdb.dbo.Analisi_ODA_CPM_104 " + ENTER
		_cQry += " Analisi_ODA_CPM_104 " + ENTER
		_cQry += " WHERE SUBSTRING(BP,3,6) = '" + MV_PAR04           + "'" + ENTER
		If !Empty(MV_PAR08)
			_cQry += "   AND Nr_Ordine = '"   + MV_PAR08  + "'" + ENTER
		EndIf
		_cQry += "   AND Nr_DocTrasposto = '" + CVALTOCHAR(VAL(MV_PAR01))+ "'" + ENTER

		MemoWrite(cArquivo + "COMA03.sql", _cQry)

		If Select("TBL") > 0
			TBL->(dbCloseArea())
		EndIf

		DbUseArea( .T. , 'TOPCONN' , TcGenQry( ,, _cQry) , "TBL" , .T. , .T. )

		Count To nTotal

		aAdd(_aCab,{'F1_TIPO'   ,'N'      ,NIL})
		aAdd(_aCab,{'F1_FORMUL' ,'N'      ,NIL})
		aAdd(_aCab,{'F1_DOC'    ,MV_PAR01 ,NIL})
		aAdd(_aCab,{"F1_SERIE"  ,MV_PAR02 ,NIL})
		aAdd(_aCab,{"F1_EMISSAO",MV_PAR03 ,NIL})
		aAdd(_aCab,{'F1_FORNECE',MV_PAR04 ,NIL})
		aAdd(_aCab,{'F1_LOJA'   ,MV_PAR05 ,NIL})
		aAdd(_aCab,{"F1_ESPECIE",MV_PAR06 ,NIL})
		aAdd(_aCab,{"F1_COND"   ,MV_PAR07 ,NIL})
		aAdd(_aCab,{"F1_STATUS" ,''       ,NIL})

		DbSelectArea("TBL")
		TBL->(DBGOTOP())

		While TBL->(!EOF())

			For n := 1 to nTotal
				aAdd(_aItens,{'D1_ITEM' ,strzero(TBL->ITEM,4)      ,NIL})
				aAdd(_aItens,{'D1_COD'  ,ALLTRIM(TBL->Articolo)    ,NIL})
				aAdd(_aItens,{"D1_QUANT",TBL->QTD                  ,Nil})
				aAdd(_aItens,{"D1_VUNIT",TBL->Costo_Unitario_Valuta,Nil})
				aAdd(_aItens,{"D1_TOTAL",TBL->Importo_Lordo_Valuta ,Nil})
				aAdd(_aItens,{"D1_TES"  ,''                        ,NIL})
				aAdd(_aItens,{"D1_PEDLN",VAL(ALLTRIM(TBL->Nr_Ricevimento)) ,NIL})
				aAdd(aLinha,_aItens)
				_aItens := {}
				TBL->(dbSkip())
			Next n

		EndDo
		TBL->(dbCloseArea())

		MsgRun("Aguarde gerando Pré-Nota de Entrada...","Imp PC LN COMA03",{|| MSExecAuto ( {|x,y,z| MATA140(x,y,z) }, _aCab, aLinha, nOpc)})

		If lMsErroAuto
			mostraerro()
		Else
			Msginfo("Importado com sucesso!","Imp PC LN COMA03")
		EndIf
	Else
		MsgAlert("Nota: " + MV_PAR01 + " já lançada!!!" ,"Imp PC LN COMA03")
	EndIf

	RestArea(aAreaSF1)
	RestArea(aArea)

RETURN
