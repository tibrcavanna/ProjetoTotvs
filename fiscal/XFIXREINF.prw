#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include 'TOPConn.ch'
#Include "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"

Static __lTemDic  As Logical
Static __oTitPaga As Object
Static __oTitRece As Object

//-------------------------------------------------------------------
/*/{Protheus.doc} FIXREINF
FIX para fazer o vinculo da(s) Natureza(s) de Rendimento da EFD-REinf 
para os títulos lançados no sistema antes da vigência do bloco 40
e que serão baixados após o inicio da vigência (Set/2023).
/*/
//-------------------------------------------------------------------
User Function XFIXREINF()
	Local nI            := 0
	Local nX            := 0
	Local aFilFin       := {}
	Local cGrpRead      := ""
	Local aRecnoSM0     := {}
	Local cGrpBkp       := ""
	Local cFilBkp       := ""

	Private cReinfLog   := "REINFLOG"
	Private cDtIni      := "20240401" //Data inicial a ser considera para filtrar a emissão dos títulos (Formato AAAAMMDD)

	TCLink()
	OpenSM0()

	dbSelectArea( "SM0" )
	SM0->(dbGoTop())

	While !SM0->( EOF() )
		AAdd(aRecnoSM0, {SM0->M0_CODIGO, SM0->M0_CODFIL})
		SM0->( dbSkip() )
	Enddo

	cGrpBkp       := aRecnoSM0[1,1]
	cFilBkp       := aRecnoSM0[1,2]

	For nI := 1 To Len(aRecnoSM0)

		If cGrpRead <> aRecnoSM0[nI,1]
			If !Empty(cGrpRead)
				RESET ENVIRONMENT
			Endif

			cGrpRead := aRecnoSM0[nI,1]
			aFilFin  := {}

			For nX := 1 To Len(aRecnoSM0)
				If aRecnoSM0[nX,1] == cGrpRead
					aAdd(aFilFin, aRecnoSM0[nX,2])
				Endif
			Next nX

			PREPARE ENVIRONMENT EMPRESA aRecnoSM0[nI,1] FILIAL aRecnoSM0[nI,2] MODULO "COM"

			REINFLOG()    //Cria Temporario - LOGs
			FIXCOMREINF() //COM
			FIXFATREINF() //FAT
			FIXFINREINF(aFilFin) //FIN
		Else
			cFilAnt := aRecnoSM0[nI,2]
			FIXCOMREINF() //COM
			FIXFATREINF() //FAT
		Endif
	Next nI

	If !Empty(cGrpRead)
		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA cGrpBkp FILIAL cFilBkp MODULO "COM"
	Endif
	FwAlertInfo("OK")
Return

Static Function REINFLOG()

	Local aArea     := GetArea()
	Local aStruct   := {}

	aAdd(aStruct,{"GRUPO"       ,"C", 008, 00}) //Grupo de empresa
	aAdd(aStruct,{"EMPFIL"      ,"C", 008, 00}) //Empresa/filial do documento/título
	aAdd(aStruct,{"DATAPROC"    ,"C", 020, 00}) //Data e hora do processamento
	aAdd(aStruct,{"TIPO"        ,"C", 002, 00}) //DE=Documento de entrada / DS = Documento de Saída / CP = Contas a Pagar / CR = Contas a Receber
	aAdd(aStruct,{"CHAVE"       ,"C", 220, 00}) //Chave do documento/título
	aAdd(aStruct,{"FATC6"       ,"C", 001, 00}) //Identifica se foi atualizada natureza de rendimento no pedido de venda
	aAdd(aStruct,{"FATFKW"      ,"C", 001, 00}) //Identifica se foi criado o registro na FKW referente ao documento de saída
	aAdd(aStruct,{"COMDHR"      ,"C", 001, 00}) //Identifica se foi criado/atualizado o registro na tabela DHR referente ao documento de entrada
	aAdd(aStruct,{"COMFKW"      ,"C", 001, 00}) //Identifica se foi criado o registro na tabela FKW referente ao documento de entrada
	aAdd(aStruct,{"FINFKF"      ,"C", 001, 00}) //Identifica se foi atualizado o registro na tabela FKF referente ao título avulso
	aAdd(aStruct,{"FINFKW"      ,"C", 001, 00}) //Identifica se foi criado o registro na tabela FKW referente ao título avulso

	If !TCCanOpen(cReinfLog)
		MsCreate(cReinfLog, aStruct, 'TOPCONN' )
		dbUseArea( .T., 'TOPCONN', cReinfLog, cReinfLog, .T., .F. )
		(cReinfLog)->(DBCreateIndex('IND1', 'TIPO + CHAVE'))
	else
		dbUseArea( .T., 'TOPCONN', cReinfLog, cReinfLog, .T., .F. )
	Endif
	dbSelectArea( cReinfLog )

	RestArea(aArea)

Return (cReinfLog)

/*
    Inicio das funções de FIX do módulo SIGACOM
    que abrange a gravação da FKW para os
    Documentos de Entrada.
*/

Static Function FIXCOMREINF(aFiliais As Array)

	Default aFiliais   := {cFilAnt}

	Private aDadosDoc   := FixDoc(aFiliais)

	If Len(aDadosDoc) > 0
		FIXDHR(aDadosDoc)
	Endif

Return

Static Function FixDoc(aFiliais As Array)

	Local cQry      := ""
	Local cQryStat  := ""
	Local cF1Ali    := ""
	Local oFindF1   := Nil
	Local aDocs     := {}
	Local nPosDoc   := 0

	Default aFiliais   := {cFilAnt}

	cF1Ali     := GetNextAlias()

	oFindF1 := FWPreparedStatement():New()

	cQry := " SELECT F1.F1_FILIAL, F1.F1_TIPO, F1.F1_DOC, F1.F1_SERIE, F1.F1_FORNECE, F1.F1_LOJA, D1.D1_ITEM, D1.D1_COD, F2Q.F2Q_NATREN, F1.F1_DTDIGIT FROM " + RetSqlName("SF1") + " F1"

	cQry += " INNER JOIN " + RetSqlName("SD1") + " D1"
	cQry += "       ON F1.F1_DOC = D1.D1_DOC"
	cQry += "       AND F1.F1_SERIE = D1.D1_SERIE"
	cQry += "       AND F1.F1_FORNECE = D1.D1_FORNECE"
	cQry += "       AND F1.F1_LOJA = D1.D1_LOJA"
	cQry += "       AND (D1.D1_BASEIRR > 0 OR D1.D1_BASEPIS > 0 OR D1.D1_BASECOF > 0 OR D1.D1_BASECSL > 0)"
	cQry += "       AND D1.D_E_L_E_T_ = ' '"
	cQry += "       AND D1.D1_FILIAL = '" + fwxFilial("SD1") + "'"

	cQry += " INNER JOIN " + RetSqlName("F2Q") + " F2Q"
	cQry += "       ON F2Q.F2Q_PRODUT = D1.D1_COD"
	cQry += "       AND F2Q.D_E_L_E_T_ = ' '"
	cQry += "       AND F2Q.F2Q_FILIAL = '" + fwxFilial("F2Q") + "'"

	cQry += " INNER JOIN " + RetSqlName("SE2") + " E2"
	cQry += "       ON E2.E2_NUM = F1.F1_DOC"
	cQry += "       AND E2.E2_FORNECE = F1.F1_FORNECE"
	cQry += "       AND E2.E2_LOJA = F1.F1_LOJA"
	// cQry += "       AND E2.E2_SALDO > 0"
	cQry += "       AND E2.E2_ORIGEM IN ('MATA100','MATA103')"
	cQry += "       AND E2.D_E_L_E_T_ = ' '"
	cQry += "       AND E2.E2_FILIAL = '" + fwxFilial("SE2") + "'"

	cQry += " WHERE F1.D_E_L_E_T_ = ' '"
	cQry += " AND F1.F1_STATUS = 'A'"
	cQry += " AND F1.F1_FILIAL = '" + fwxFilial("SF1") + "'"
	cQry += " AND F1.F1_EMISSAO > '" + cDtIni + "' "
	cQry += " AND F1.F1_DOC IN ('000000757')
	cQry += " AND F1.F1_FORNECE IN ('001935')
	cQry += " GROUP BY F1.F1_DTDIGIT, F1.F1_FILIAL,F1.F1_TIPO,F1.F1_DOC,F1.F1_SERIE,F1.F1_FORNECE,F1.F1_LOJA,D1.D1_ITEM,D1.D1_COD,F2Q.F2Q_NATREN"
	cQry += " ORDER BY F1.F1_DTDIGIT ASC, F1.F1_DOC, F1.F1_SERIE, F1.F1_FORNECE, F1.F1_LOJA, D1.D1_ITEM"
	cQry := ChangeQuery(cQry)

	oFindF1:SetQuery(cQry)

	cQryStat := oFindF1:GetFixQuery()
	MpSysOpenQuery(cQryStat,cF1Ali)

	While (cF1Ali)->(!EOF())
		nPosDoc := aScan(aDocs,{|x| x[1] == (cF1Ali)->F1_FILIAL .And. x[2] == (cF1Ali)->F1_DOC .And. x[3] == (cF1Ali)->F1_SERIE .And. x[4] == (cF1Ali)->F1_FORNECE .And. x[5] == (cF1Ali)->F1_LOJA})
		If nPosDoc == 0
			aAdd(aDocs,{(cF1Ali)->F1_FILIAL,(cF1Ali)->F1_DOC,(cF1Ali)->F1_SERIE,(cF1Ali)->F1_FORNECE,(cF1Ali)->F1_LOJA,(cF1Ali)->D1_ITEM,(cF1Ali)->D1_COD,(cF1Ali)->F2Q_NATREN})
		Elseif nPosDoc > 0
			aDocs[nPosDoc,6] += "|" + (cF1Ali)->D1_ITEM
			aDocs[nPosDoc,7] += "|" + (cF1Ali)->D1_COD
			aDocs[nPosDoc,8] += "|" + (cF1Ali)->F2Q_NATREN
		Endif
		(cF1Ali)->(DbSkip())
	Enddo

	(cF1Ali)->(DbCloseArea())

Return aDocs

Static Function FIXDHR(aDadosDoc)

	Local nI            := 0
	Local nX            := 0
	Local nY            := 0
	Local aAuxIt        := {}
	Local aAuxPrd       := {}
	Local aAuxNat       := {}
	Local aInDHR	    := {"DHR_NATREN"}
	Local aNotDHR		:= {"DHR_FILIAL","DHR_DOC","DHR_SERIE","DHR_FORNEC","DHR_LOJA"}
	Local aColNatRend   := {}
	Local aFKW          := {}
	Local lGeraDHR      := .F.
	Local lGeraFKW      := .F.
	Local lRegNew       := .F.

	Private aHeadDHR    := COMXHDCO("DHR",aInDHR)
	Private aHdSusDHR   := COMXHDCO("DHR",,aNotDHR)
	Private aColsDHR    := {}
	Private aCoSusDHR   := {}
	Private aHeader     := COMXHDCO("SD1")
	Private cNFiscal    := ""
	Private cSerie      := ""
	Private cA100For    := ""
	Private cLoja       := ""

	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))

	DbSelectArea("SD1")
	SD1->(DbSetOrder(1))

	For nI := 1 To Len(aDadosDoc)
		lGeraDHR      := .F.
		lGeraFKW      := .F.

		aAuxIt  := Separa(aDadosDoc[nI,6],"|")
		aAuxPrd := Separa(aDadosDoc[nI,7],"|")
		aAuxNat := Separa(aDadosDoc[nI,8],"|")

		If SF1->(DbSeek(aDadosDoc[nI,1] + aDadosDoc[nI,2] + aDadosDoc[nI,3] + aDadosDoc[nI,4] + aDadosDoc[nI,5]))
			If Len(aAuxIt) > 0 .And. Len(aAuxNat) > 0 .And. Len(aAuxPrd) > 0
				aColsDHR := {}
				For nX := 1 To Len(aAuxIt)
					aColNatRend := {}
					aAdd(aColNatRend,Array(Len(aHeadDHR)+1))
					For nY := 1 To Len(aHeadDHR)
						aColNatRend[1,nY] := aAuxNat[nX]
					Next nY
					aColNatRend[1,Len(aHeadDHR)+1] := .F.

					aAdd(aColsDHR,{aAuxIt[nX],aColNatRend})

					If SD1->(DbSeek(aDadosDoc[nI,1] + aDadosDoc[nI,2] + aDadosDoc[nI,3] + aDadosDoc[nI,4] + aDadosDoc[nI,5] + aAuxPrd[nX] + aAuxIt[nX]))
						A103INCDHR(aHeadDHR,aColsDHR,nX,.F.) //Gravação DHR
						lGeraDHR := .T.
					Endif
				Next nX
			Endif
		Endif

		aFKW := FIXFKW(aDadosDoc[nI,1],aDadosDoc[nI,2],aDadosDoc[nI,3],aDadosDoc[nI,4],aDadosDoc[nI,5])
		If Len(aFKW) > 0
			cNFiscal    := aDadosDoc[nI,2]
			cSerie      := aDadosDoc[nI,3]
			cA100For    := aDadosDoc[nI,4]
			cLoja       := aDadosDoc[nI,5]
			A103FKW("I",aFKW[1],aFKW[2]) //Gravação FKW
			lGeraFKW    := .T.
		Endif

		DbSelectArea(cReinfLog)
		DbSetIndex('IND1')
		lRegNew := (cReinfLog)->(MsSeek("DE" + aDadosDoc[nI,1] + aDadosDoc[nI,2] + aDadosDoc[nI,3] + aDadosDoc[nI,4] + aDadosDoc[nI,5]))
		If RecLock(cReinfLog,!lRegNew)
			(cReinfLog)->GRUPO    := cEmpAnt
			(cReinfLog)->EMPFIL   := aDadosDoc[nI,1]
			(cReinfLog)->DATAPROC := FWTimeStamp(2, DATE(), TIME())
			(cReinfLog)->TIPO     := "DE"
			(cReinfLog)->CHAVE    := aDadosDoc[nI,1]+aDadosDoc[nI,2]+aDadosDoc[nI,3]+aDadosDoc[nI,4]+aDadosDoc[nI,5]
			(cReinfLog)->COMDHR   := Iif(lGeraDHR,"I","") //I=Insert
			(cReinfLog)->COMFKW   := Iif(lGeraFKW,"I","") //I=Insert
			(cReinfLog)->(MsUnlock())
		Endif
	Next nI

Return

Static Function FIXFKW(cFil,cDoc,cSer,cFor,cLoj)

	Local aRet      := {}
	Local aITD1     := {}
	Local aRecE2    := {}
	Local cQry      := ""
	Local cQryStat  := ""
	Local cD1Ali    := ""
	Local oFindD1   := Nil
	Local cE2Ali    := ""
	Local oFindE2   := Nil
	Local nI        := 0

	//Busca ITENS (SD1)
	cD1Ali     := GetNextAlias()

	oFindD1 := FWPreparedStatement():New()

	cQry    := " SELECT "

	For nI := 1 To Len(aHeader)
		If nI == 1
			cQry += aHeader[nI,2]
		Else
			cQry += ", " + aHeader[nI,2]
		Endif
	Next nI

	cQry    += " FROM " + RetSqlName("SD1") + " D1"
	cQry    += " WHERE D1.D1_FILIAL     = ?"
	cQry    += "   AND D1.D1_DOC        = ?"
	cQry    += "   AND D1.D1_SERIE      = ?"
	cQry    += "   AND D1.D1_FORNECE    = ?"
	cQry    += "   AND D1.D1_LOJA       = ?"
	cQry    += "   AND D1.D_E_L_E_T_ =' ' "
	cQry := ChangeQuery(cQry)

	oFindD1:SetQuery(cQry)

	oFindD1:SetString(1,cFil)
	oFindD1:SetString(2,cDoc)
	oFindD1:SetString(3,cSer)
	oFindD1:SetString(4,cFor)
	oFindD1:SetString(5,cLoj)

	cQryStat := oFindD1:GetFixQuery()
	MpSysOpenQuery(cQryStat,cD1Ali)

	While (cD1Ali)->(!EOF())
		aadd(aITD1,Array(Len(aHeader)+1))
		For nI := 1 To Len(aHeader)
			aITD1[Len(aITD1),nI] := (cD1Ali)->&(aHeader[nI,2])
		Next nI
		aITD1[Len(aITD1),Len(aHeader)+1] := .F.
		(cD1Ali)->(DbSkip())
	Enddo

	(cD1Ali)->(DbCloseArea())

	//Busca TITULOS (SE2)
	cE2Ali     := GetNextAlias()

	oFindE2 := FWPreparedStatement():New()

	cQry    := " SELECT E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO, SE2.R_E_C_N_O_ SE2RECNO"
	cQry    += " FROM " + RetSqlName("SE2") + " SE2"
	cQry    += " WHERE SE2.E2_FILIAL  = ?"
	cQry    += "   AND SE2.E2_FORNECE = ?"
	cQry    += "   AND SE2.E2_LOJA    = ?"
	cQry    += "   AND SE2.E2_PREFIXO = ?"
	cQry    += "   AND SE2.E2_NUM     = ?"
	cQry    += "   AND SE2.E2_TIPO    = ?"
	cQry    += "   AND SE2.D_E_L_E_T_ =' ' "
	cQry := ChangeQuery(cQry)

	oFindE2:SetQuery(cQry)

	oFindE2:SetString(1,cFil)
	oFindE2:SetString(2,cFor)
	oFindE2:SetString(3,cLoj)
	oFindE2:SetString(4,GetAdvFVal("SF1","F1_PREFIXO", cFil + cDoc + cSer + cFor + cLoj,1))
	oFindE2:SetString(5,cDoc)
	oFindE2:SetString(6,MVNOTAFIS)

	cQryStat := oFindE2:GetFixQuery()
	MpSysOpenQuery(cQryStat,cE2Ali)

	While (cE2Ali)->(!EOF())
		aadd(aRecE2,(cE2Ali)->SE2RECNO)
		(cE2Ali)->(DbSkip())
	Enddo

	(cE2Ali)->(DbCloseArea())

	If Len(aITD1) > 0 .And. Len(aRecE2) > 0
		aAdd(aRet,aITD1)
		aAdd(aRet,aRecE2)
	Endif

Return aRet

/*
    Inicio das funções de FIX do módulo SIGAFIN
    que abrange a gravação da FKW para os
    títulos a pagar/recebe sem vinculo com
    notas (doc. entrada/saída)
*/

Static Function FIXFINREINF(aFiliais As Array)
	Local lRetorno   As Logical
	Local cMAEmpSED  As Char
	Local cMAUniSED  As Char
	Local cMAFilSED  As Char
	Local cMAEmpSA1  As Char
	Local cMAUniSA1  As Char
	Local cMAFilSA1  As Char
	Local cMAEmpSA2  As Char
	Local cMAUniSA2  As Char
	Local cMAFilSA2  As Char
	Local cMAEmpSE1  As Char
	Local cMAUniSE1  As Char
	Local cMAFilSE1  As Char
	Local cMAEmpSE2  As Char
	Local cMAUniSE2  As Char
	Local cMAFilSE2  As Char
	Local nTamFilSED As Numeric
	Local nTamFilSA1 As Numeric
	Local nTamFilSA2 As Numeric
	Local nTamFilSE1 As Numeric
	Local nTamFilSE2 As Numeric
	Local nTamEmp    As Numeric
	Local nTamUni    As Numeric
	Local nTamFil    As Numeric
	Local nFiliais   As Numeric
	Local nLinha     As Numeric
	Local aFilAux    As Arry
	Local aLstTipo   As Array

	//Parâmetros de entrada.
	Default aFiliais := {cFilAnt}

	If __lTemDic == Nil
		__lTemDic := cPaisLoc == "BRA" .And. SED->(ColumnPos("ED_NATREN")) > 0
	EndIf

	If (lRetorno := __lTemDic)
		//Inicializa variáveis
		lRetorno := .F.
		cMAEmpSED  := AllTrim(FWModeAccess("SED",1))
		cMAUniSED  := AllTrim(FWModeAccess("SED",2))
		cMAFilSED  := AllTrim(FWModeAccess("SED",3))
		cMAEmpSA1  := AllTrim(FWModeAccess("SA1",1))
		cMAUniSA1  := AllTrim(FWModeAccess("SA1",2))
		cMAFilSA1  := AllTrim(FWModeAccess("SA1",3))
		cMAEmpSA2  := AllTrim(FWModeAccess("SA2",1))
		cMAUniSA2  := AllTrim(FWModeAccess("SA2",2))
		cMAFilSA2  := AllTrim(FWModeAccess("SA2",3))
		cMAEmpSE1  := AllTrim(FWModeAccess("SE1",1))
		cMAUniSE1  := AllTrim(FWModeAccess("SE1",2))
		cMAFilSE1  := AllTrim(FWModeAccess("SE1",3))
		cMAEmpSE2  := AllTrim(FWModeAccess("SE2",1))
		cMAUniSE2  := AllTrim(FWModeAccess("SE2",2))
		cMAFilSE2  := AllTrim(FWModeAccess("SE2",3))
		nTamFilSED := 0
		nTamFilSA1 := 0
		nTamFilSA2 := 0
		nTamFilSE1 := 0
		nTamFilSE2 := 0
		nTamEmp    := Len(FwSM0Layout(,1))
		nTamUni    := Len(FwSM0Layout(,2))
		nTamFil    := Len(FwSM0Layout(,3))
		nFiliais   := Len(aFiliais)
		nLinha     := 0
		aFilAux    := {{},{}}
		aLstTipo   := {}

		If (nTamEmp+nTamUni) == 0
			cMAEmpSED := cMAUniSED := cMAFilSED
			cMAEmpSA1 := cMAUniSA1 := cMAFilSA1
			cMAEmpSA2 := cMAUniSA2 := cMAFilSA2
			cMAEmpSE1 := cMAUniSE1 := cMAFilSE1
			cMAEmpSE2 := cMAUniSE2 := cMAFilSE2
		Else
			If nTamEmp == 0
				cMAEmpSED := cMAUniSED
				cMAEmpSA1 := cMAUniSA1
				cMAEmpSA2 := cMAUniSA2
				cMAEmpSE1 := cMAUniSE1
				cMAEmpSE2 := cMAUniSE2
			ElseIf nTamUni == 0
				cMAUniSED := cMAFilSED
				cMAUniSA1 := cMAFilSA1
				cMAUniSA2 := cMAFilSA2
				cMAUniSE1 := cMAFilSE1
				cMAUniSE2 := cMAFilSE2
			EndIf
		EndIf

		nTamFilSED := (IIf(cMAEmpSED == "C", 0, nTamEmp) + IIf(cMAUniSED == "C", 0, nTamUni) + IIf(cMAFilSED == "C", 0, nTamFil))
		nTamFilSA1 := (IIf(cMAEmpSA1 == "C", 0, nTamEmp) + IIf(cMAUniSA1 == "C", 0, nTamUni) + IIf(cMAFilSA1 == "C", 0, nTamFil))
		nTamFilSA2 := (IIf(cMAEmpSA2 == "C", 0, nTamEmp) + IIf(cMAUniSA2 == "C", 0, nTamUni) + IIf(cMAFilSA2 == "C", 0, nTamFil))
		nTamFilSE1 := (IIf(cMAEmpSE1 == "C", 0, nTamEmp) + IIf(cMAUniSE1 == "C", 0, nTamUni) + IIf(cMAFilSE1 == "C", 0, nTamFil))
		nTamFilSE2 := (IIf(cMAEmpSE2 == "C", 0, nTamEmp) + IIf(cMAUniSE2 == "C", 0, nTamUni) + IIf(cMAFilSE2 == "C", 0, nTamFil))
		aLstTipo   := Strtokarr((MVABATIM+"|"+MV_CRNEG+"|"+MVTXA+"|"+MVTAXA+"|"+MV_CPNEG+"|"+MVINSS+"|"+MVISS+"|"+MVCSABT+"|"+MVCFABT+"|"+MVPIABT+"|SES|CID|INA|PIS|CSL|COF"), "|")

		For nLinha := 1 To nFiliais
			If Empty(aFiliais[nLinha])
				Loop
			EndIf

			lRetorno := .T.
			AAdd(aFilAux[1], xFilial("SE2", aFiliais[nLinha]))
			AAdd(aFilAux[2], xFilial("SE1", aFiliais[nLinha]))
		Next nX

		aFiliais := AClone(aFilAux)

		If lRetorno
			//Atualiza a natureza de rendimentos do contas a pagar
			FinCPag(aFiliais[1], nTamFilSED, nTamFilSA2, nTamFilSE2, aLstTipo)

			//Atualiza a natureza de rendimentos do contas a receber
			FinCRec(aFiliais[2], nTamFilSED, nTamFilSA1, nTamFilSE1, aLstTipo)
		EndIf

		FWFreeArray(aFilAux)
		FwFreeArray(aLstTipo)
	Else
		Help(" ", 1, "ATUAMBREINF", Nil, "Ambiente desatualizado", 2, 0, Nil, Nil, Nil, Nil, Nil, {"Para realizar o ajuste da base, é necessário atualizar o ambiente"})
	EndIf

Return lRetorno

/*/{Protheus.doc} FinCPag
    @type User Function
    @param aFiliais, array unidimensional, lista de filais que serão processadas
    @return Logical, lRetorno, Logico que indica se ocorreu o processamento de atualização
    da natureza de rendimento do títulos a pagar
/*/
Static Function FinCPag(aFiliais As Array, nTamFilSED As Numeric, nTamFilSA2 As Numeric, nTamFilSE2 As Numeric, aLstTipo As Array) As Logical
	Local lRetorno   As Logical
	Local lAchouFKF  As Logical
	Local cTblPagar  As Char
	Local cQuery     As Char
	Local cIdDocFK7  As Char
	Local cTpImpos   As Char
	Local nMenorFil  As Numeric
	Local nTpImpos   As Numeric
	Local nVlrImpos  As Numeric
	Local nBaseImpos As Numeric
	Local nTotal     As Numeric
	Local aDados     As Array

	//Parâmetros de entrada.
	Default aFiliais   := {cFilAnt}
	Default nTamFilSED := 0
	Default nTamFilSA2 := 0
	Default nTamFilSE2 := 0
	Default aLstTipo   := {""}

	//Inicializa variáveis.
	lRetorno   := .T.
	lAchouFKF  := .T.
	cTblPagar  := ""
	cQuery     := ""
	cIdDocFK7  := ""
	cTpImpos   := "SEMIMP"
	nMenorFil  := 0
	nTpImpos   := 0
	nVlrImpos  := 0
	nBaseImpos := 0
	nTotal     := 0
	aDados     := {}

	If __oTitPaga == Nil
		cQuery := "SELECT SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA, SE2.E2_TIPO, SE2.E2_FORNECE, SE2.E2_LOJA, SE2.E2_FILORIG, "
		cQuery += "SE2.E2_PIS, SE2.E2_COFINS, SE2.E2_CSLL, SE2.E2_IRRF, SE2.E2_VALOR, SE2.E2_SALDO, SE2.E2_BASEIRF, SE2.E2_BASEPIS, SE2.E2_BASECOF, "
		cQuery += "SE2.E2_BASECSL, SE2.R_E_C_N_O_, SED.ED_NATREN, SED.ED_CALCIRF, SED.ED_CALCPIS, SED.ED_CALCCOF, SED.ED_CALCCSL, SED.ED_PERCIRF, "
		cQuery += "SED.ED_PERCPIS, SED.ED_PERCCOF, SED.ED_PERCCSL, SA2.A2_RECPIS, SA2.A2_RECCOFI, SA2.A2_RECCSLL, SA2.A2_CALCIRF "
		cQuery += "FROM ? SE2 "

		//Relacionamento: SE2 vs SED
		nMenorFil := IIf(nTamFilSED > nTamFilSE2, nTamFilSE2, nTamFilSED)

		cQuery += "INNER JOIN ? SED ON "
		cQuery += "(SUBSTRING(SE2.E2_FILIAL, 1, " + cValToChar(nMenorFil) + ") = SUBSTRING(SED.ED_FILIAL, 1, " + cValToChar(nMenorFil) + ") "
		cQuery += "AND SE2.E2_NATUREZ = SED.ED_CODIGO "
		cQuery += "AND SE2.D_E_L_E_T_ = SED.D_E_L_E_T_) "

		//Relacionamento: SE2 vs SA2
		nMenorFil := IIf(nTamFilSA2 > nTamFilSE2, nTamFilSE2, nTamFilSA2)

		cQuery += "INNER JOIN ? SA2 ON "
		cQuery += "(SUBSTRING(SE2.E2_FILIAL, 1, " + cValToChar(nMenorFil) + ") = SUBSTRING(SA2.A2_FILIAL, 1, " + cValToChar(nMenorFil) + ") "
		cQuery += "AND SE2.E2_FORNECE = SA2.A2_COD "
		cQuery += "AND SE2.E2_LOJA = SA2.A2_LOJA "
		cQuery += "AND SE2.D_E_L_E_T_ = SA2.D_E_L_E_T_) "

		cQuery += "WHERE "
		cQuery += "SE2.E2_FILIAL IN (?) "
		// cQuery += "AND SE2.E2_SALDO > 0 "
		cQuery += "AND SE2.E2_TIPO NOT IN (?) "
		cQuery += "AND SE2.E2_ORIGEM NOT IN ('MATA100', 'MATA103') "
		cQuery += "AND SE2.D_E_L_E_T_ = ' ' "
		cQuery += "AND SED.ED_NATREN IS NOT NULL AND SED.ED_NATREN <> ' ' "
		cQuery += "AND SE2.E2_EMISSAO > ? "

		cQuery := ChangeQuery(cQuery)
		__oTitPaga := FwPreparedStatement():New(cQuery)
	EndIf

	__oTitPaga:SetNumeric(1, RetSqlName("SE2"))
	__oTitPaga:SetNumeric(2, RetSqlName("SED"))
	__oTitPaga:SetNumeric(3, RetSqlName("SA2"))
	__oTitPaga:SetIn(4, aFiliais)
	__oTitPaga:SetIn(5, aLstTipo)
	__oTitPaga:SetString(6, cDtIni)

	cQuery    := __oTitPaga:GetFixQuery()
	cTblPagar := MpSysOpenQuery(cQuery)

	//Contando os registros e voltando ao topo da query
	nTotal := Contar(cTblPagar,"!Eof()")
	(cTblPagar)->(DbGoTop())

	DbSelectArea("FKF")
	FKF->(DbSetOrder(1))

	While (cTblPagar)->(!Eof())
		cIdDocFK7 := FINBuscaFK7((cTblPagar)->(E2_FILIAL+"|"+E2_PREFIXO+"|"+E2_NUM+"|"+E2_PARCELA+"|"+E2_TIPO+"|"+E2_FORNECE+"|"+E2_LOJA), "SE2", (cTblPagar)->E2_FILORIG)

		If Empty(cIdDocFK7)
			(cTblPagar)->(DbSkip())
			Loop
		EndIf

		lAchouFKF := FKF->(MsSeek(xFilial("FKF", (cTblPagar)->E2_FILORIG)+cIdDocFK7))

		If (!lAchouFKF .Or. (lAchouFKF .And. !Empty(FKF->FKF_NATREN)))
			(cTblPagar)->(DbSkip())
			Loop
		EndIf

		//Atualiza FKF
		RecLock("FKF", .F.)
		FKF->FKF_NATREN := (cTblPagar)->ED_NATREN
		FKF->(MsUnLock())

		For nTpImpos := 1 To 5
			Do Case
			Case nTpImpos == 1 //IRRF
				If (AllTrim((cTblPagar)->ED_CALCIRF) != "S" .Or. (cTblPagar)->ED_PERCIRF <= 0 .Or. (cTblPagar)->E2_BASEIRF == 0 .Or. !AllTrim((cTblPagar)->A2_CALCIRF) $ "1|2" )
					Loop
				EndIf

				cTpImpos   := "IRF"
				nVlrImpos  := (cTblPagar)->E2_IRRF
				nBaseImpos := (cTblPagar)->E2_BASEIRF
			Case nTpImpos == 2 //PIS
				If (AllTrim((cTblPagar)->ED_CALCPIS) != "S" .Or. (cTblPagar)->ED_PERCPIS <= 0 .Or. AllTrim((cTblPagar)->A2_RECPIS) != "2")
					Loop
				EndIf

				cTpImpos   := "PIS"
				nVlrImpos  := (cTblPagar)->E2_PIS
				nBaseImpos := (cTblPagar)->E2_BASEPIS
			Case nTpImpos == 3 //COFINS
				If (AllTrim((cTblPagar)->ED_CALCCOF) != "S" .Or. (cTblPagar)->ED_PERCCOF <= 0 .Or. AllTrim((cTblPagar)->A2_RECCOFI) != "2")
					Loop
				EndIf

				cTpImpos   := "COF"
				nVlrImpos  := (cTblPagar)->E2_COFINS
				nBaseImpos := (cTblPagar)->E2_BASECOF
			Case nTpImpos == 4 //CSLL
				If (AllTrim((cTblPagar)->ED_CALCCSL) != "S" .Or. (cTblPagar)->ED_PERCCSL <= 0 .Or. AllTrim((cTblPagar)->A2_RECCSLL) != "2")
					Loop
				EndIf

				cTpImpos   := "CSL"
				nVlrImpos  := (cTblPagar)->E2_CSLL
				nBaseImpos := (cTblPagar)->E2_BASECSL
			OtherWise // Títulos sem impostos
				If Len(aDados) == 0
					cTpImpos   := "SEMIMP"
					nVlrImpos  := 0
					nBaseImpos := (cTblPagar)->E2_VALOR
				EndIf
			EndCase

			If nBaseImpos > 0
				AAdd(aDados, {;
					(cTblPagar)->E2_FILIAL,;
					cIdDocFK7,;
					cTpImpos,;
					(cTblPagar)->ED_NATREN,;
					100,;
					nBaseImpos,;
					nVlrImpos,;  //valor do impos retido 7
				0,;  //Base imposto nao retido 8
				0,;  //Valor do impoto nao retido 9
				"",; //Numero Processo Judicial 10
				"",; //Tipo Processo 11
				"",; //Cod. Indicativo suspensao 12
				0})
			EndIf
			nBaseImpos := 0
		Next nTpImpos

		//Gravação do FKW
		If Len(aDados) > 0
			lRetorno := F070Grv(aDados, 4, "1")
		EndIf

		If lRetorno
			DbSelectArea(cReinfLog)
			DbSetIndex('IND1')
			lRegNew := (cReinfLog)->(MsSeek("CP" + cIdDocFK7 ))
			If RecLock(cReinfLog,!lRegNew)
				(cReinfLog)->GRUPO    := cEmpAnt
				(cReinfLog)->EMPFIL   := (cTblPagar)->E2_FILIAL
				(cReinfLog)->DATAPROC := FWTimeStamp(2, DATE(), TIME())
				(cReinfLog)->TIPO     := "CP" //Contas a Pagar
				(cReinfLog)->CHAVE    := cIdDocFK7
				(cReinfLog)->FINFKF   := "U" //U=Update
				(cReinfLog)->FINFKW   := "I" //I=Insert
				(cReinfLog)->(MsUnlock())
			Endif
		EndIf

		(cTblPagar)->(DbSkip())

		aDados := {}
	EndDo

	(cTblPagar)->(DbCloseArea())
Return lRetorno

/*/{Protheus.doc} FinCRec
    @type User Function
    @param aFiliais, array unidimensional, lista de filais que serão processadas
    @return Logical, lRetorno, Logico que indica se ocorreu o processamento de atualização
    da natureza de rendimento do títulos a receber
/*/
Static Function FinCRec(aFiliais As Array, nTamFilSED As Numeric, nTamFilSA1 As Numeric, nTamFilSE1 As Numeric, aLstTipo As Array) As Logical
	Local lRetorno   As Logical
	Local lAchouFKF  As Logical
	Local cTblTmp    As Char
	Local cQuery     As Char
	Local cIdDocFK7  As Char
	Local nMenorFil  As Numeric
	Local nTotal     As Numeric
	Local aDados     As Array

	//Parâmetros de entrada.
	Default aFiliais   := {cFilAnt}
	Default nTamFilSED := 0
	Default nTamFilSA1 := 0
	Default nTamFilSE1 := 0
	Default aLstTipo   := {""}

	//Inicializa variáveis.
	lRetorno   := .T.
	lAchouFKF  := .T.
	cTblTmp    := ""
	cQuery     := ""
	cIdDocFK7  := ""
	nMenorFil  := 0
	nTotal     := 0
	aDados     := {}

	If __oTitRece == Nil
		cQuery := "SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_FILORIG, SE1.E1_PIS, "
		cQuery += "SE1.E1_COFINS, SE1.E1_CSLL, SE1.E1_IRRF, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_BASEIRF, SE1.E1_BASEPIS, SE1.E1_BASECOF, SE1.E1_BASECSL, "
		cQuery += "SE1.R_E_C_N_O_, SED.ED_NATREN, SED.ED_CALCIRF, SED.ED_CALCPIS, SED.ED_CALCCOF, SED.ED_CALCCSL, SED.ED_PERCIRF, SED.ED_PERCPIS, "
		cQuery += "SED.ED_PERCCOF,SED.ED_PERCCSL FROM ? SE1 "

		//Relacionamento: SE1 vs SED
		nMenorFil := IIf(nTamFilSED > nTamFilSE1, nTamFilSE1, nTamFilSED)

		cQuery += "INNER JOIN ? SED ON "
		cQuery += "(SUBSTRING(SE1.E1_FILIAL , 1 , " + cValToChar(nMenorFil) + ") = SUBSTRING(SED.ED_FILIAL , 1 , " + cValToChar(nMenorFil) + ") "
		cQuery += "AND SE1.E1_NATUREZ = SED.ED_CODIGO "
		cQuery += "AND SE1.D_E_L_E_T_ = SED.D_E_L_E_T_) "

		//Relacionamento: SE1 vs SA1
		nMenorFil := IIf(nTamFilSA1 > nTamFilSE1, nTamFilSE1, nTamFilSA1)

		cQuery += "INNER JOIN ? SA1 ON "
		cQuery += "(SUBSTRING(SE1.E1_FILIAL , 1 , " + cValToChar(nMenorFil) + ") = SUBSTRING(SA1.A1_FILIAL , 1 , " + cValToChar(nMenorFil) + ") "
		cQuery += "AND SE1.E1_CLIENTE = SA1.A1_COD "
		cQuery += "AND SE1.E1_LOJA = SA1.A1_LOJA "
		cQuery += "AND SE1.D_E_L_E_T_ = SA1.D_E_L_E_T_)"

		//Filtro de linhas
		cQuery += "WHERE "
		cQuery += "SE1.E1_FILIAL IN (?) AND SE1.E1_SALDO > 0 "
		cQuery += "AND SE1.E1_TIPO NOT IN (?) "
		cQuery += "AND SE1.E1_ORIGEM NOT IN ('MATA460', 'MATA461') "
		cQuery += "AND SED.ED_NATREN IS NOT NULL AND SED.ED_NATREN <> ' ' AND SED.ED_CALCIRF = 'S' "
		cQuery += "AND SA1.A1_RECIRRF = '2' AND SE1.D_E_L_E_T_ = ' ' "
		cQuery += "AND SE1.E1_EMISSAO > ? "

		cQuery := ChangeQuery(cQuery)
		__oTitRece := FwPreparedStatement():New(cQuery)
	EndIf

	__oTitRece:SetNumeric(1, RetSqlName("SE1"))
	__oTitRece:SetNumeric(2, RetSqlName("SED"))
	__oTitRece:SetNumeric(3, RetSqlName("SA1"))
	__oTitRece:SetIn(4, aFiliais)
	__oTitRece:SetIn(5, aLstTipo)
	__oTitRece:SetString(6, cDtIni)

	cQuery    := __oTitRece:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)

	//Contando os registros e voltando ao topo da query
	nTotal := Contar(cTblTmp,"!Eof()")
	(cTblTmp)->(DbGoTop())

	DbSelectArea("FKF")
	FKF->(DbSetOrder(1))

	While (cTblTmp)->(!Eof())
		cIdDocFK7 := FINBuscaFK7((cTblTmp)->(E1_FILIAL+"|"+E1_PREFIXO+"|"+E1_NUM+"|"+E1_PARCELA+"|"+E1_TIPO+"|"+E1_CLIENTE+"|"+E1_LOJA), "SE1", (cTblTmp)->E1_FILORIG)

		If Empty(cIdDocFK7)
			(cTblTmp)->(DbSkip())
			Loop
		EndIf

		lAchouFKF := FKF->(MsSeek(xFilial("FKF", (cTblTmp)->E1_FILORIG)+cIdDocFK7))

		If (!lAchouFKF .Or. (lAchouFKF .And. !Empty(FKF->FKF_NATREN)))
			(cTblTmp)->(DbSkip())
			Loop
		EndIf

		//Atualiza FKF
		RecLock("FKF", .F.)
		FKF->FKF_NATREN := (cTblTmp)->ED_NATREN
		FKF->(MsUnLock())

		AAdd(aDados, {;
			(cTblTmp)->E1_FILIAL,;
			cIdDocFK7,;
			"IRF",;
			(cTblTmp)->ED_NATREN,;
			100,;
			(cTblTmp)->E1_BASEIRF,;
			(cTblTmp)->E1_IRRF,;
			0,;  //Base imposto nao retido 8
		0,;  //Valor do impoto nao retido 9
		"",; //Numero Processo Judicial 10
		"",; //Tipo Processo 11
		"",; //Cod. Indicativo suspensao 12
		0})

		//Gravação do FKW
		If Len(aDados) > 0
			lRetorno := F070Grv(aDados, 4, "2")
		EndIf

		If lRetorno
			DbSelectArea(cReinfLog)
			DbSetIndex('IND1')
			lRegNew := (cReinfLog)->(MsSeek("CR" + cIdDocFK7))

			If RecLock(cReinfLog, !lRegNew)
				(cReinfLog)->GRUPO    := cEmpAnt
				(cReinfLog)->EMPFIL   := (cTblTmp)->E1_FILIAL
				(cReinfLog)->DATAPROC := FWTimeStamp(2, DATE(), TIME())
				(cReinfLog)->TIPO     := "CR" //Contas a Receber
				(cReinfLog)->CHAVE    := cIdDocFK7
				(cReinfLog)->FINFKF   := "U" //U=Update
				(cReinfLog)->FINFKW   := "I" //I=Insert
				(cReinfLog)->(MsUnlock())
			Endif
		EndIf

		(cTblTmp)->(DbSkip())
		aDados := {}
	EndDo

	(cTblTmp)->(DbCloseArea())
Return lRetorno

/*
    Inicio das funções de FIX do módulo SIGAFAT
    que abrange a gravação da FKW para os
    Documentos de Saída e atualização do campo
    Natureza de Rendimento (C6_NATREN) do Pedido de Venda
*/
Static Function FIXFATREINF()

	Local aNatAux       := {}
	Local aCountNat     := {}
	Local aCountSE1     := {}
	Local aNatureza     := {}
	Local aTitulos      := {}
	Local aNota         := Array(2)
	Local aNatRend      := Array(4)
	Local aSE1NatRen    := Array(2)
	Local cAliasSD2	    := GetNextAlias()
	Local cAliasSE1	    := ""
	Local cQrySD2       := ""
	Local cQrySE1       := ""
	Local nPosNatRen    := 0
	Local nNatLoop      := 0
	Local nI            := 0
	Local nX            := 0
	Local nZ            := 0
	Local oFatSD2       := Nil
	Local oFatSE1       := Nil

	aNatRend[2] := {}
	aSE1NatRen[2] := {}

	cQrySD2 := "SELECT SC6.R_E_C_N_O_ AS RECSC6, F2Q.F2Q_NATREN, SD2.D2_VALIRRF, SD2.D2_BASEIRR, SD2.D2_SERIE, SD2.D2_DOC "
	cQrySD2 += "FROM  " + RetSqlName("SC6") + "  SC6 "
	cQrySD2 += "INNER JOIN " + RetSqlName("F2Q") + " F2Q "
	cQrySD2 += "ON F2Q.F2Q_FILIAL = '" + FwxFilial("F2Q") + "' "
	cQrySD2 += "AND F2Q.F2Q_PRODUT = SC6.C6_PRODUTO "
	cQrySD2 += "AND F2Q.F2Q_NATREN <> ' ' "
	cQrySD2 += "INNER JOIN " + RetSqlName("SD2") + " SD2 "
	cQrySD2 += "ON SD2.D2_FILIAL = '" + FwxFilial("SD2") + "' "
	cQrySD2 += "AND SD2.D2_PEDIDO = SC6.C6_NUM "
	cQrySD2 += "AND SD2.D2_ITEMPV = SC6.C6_ITEM "
	cQrySD2 += "WHERE SC6.D_E_L_E_T_ = ' ' "
	cQrySD2 += "AND F2Q.D_E_L_E_T_ = ' ' "
	cQrySD2 += "AND SD2.D_E_L_E_T_ = ' ' "

	cQrySD2	:= ChangeQuery(cQrySD2)
	oFatSD2 := FwExecStatement():New(cQrySD2)
	cAliasSD2 := oFatSD2:OpenAlias()

	While (cAliasSD2)->(!Eof())
		If Empty(aNatRend[2])
			aAdd(aNatureza, {(cAliasSD2)->RECSC6 , (cAliasSD2)->F2Q_NATREN} )

			aNota[1] := (cAliasSD2)->D2_SERIE
			aNota[2] := (cAliasSD2)->D2_DOC
			aNatRend[1] := (cAliasSD2)->D2_VALIRRF

			aAdd(aNatRend[2], {(cAliasSD2)->F2Q_NATREN, (cAliasSD2)->D2_VALIRRF, (cAliasSD2)->D2_BASEIRR})
		Else
			aAdd(aNatureza, {(cAliasSD2)->RECSC6 , (cAliasSD2)->F2Q_NATREN} )

			aNatRend[1] += (cAliasSD2)->D2_VALIRRF
			nPosNatRen := aScan(aNatRend[2],{|x| x[1] == (cAliasSD2)->F2Q_NATREN})

			If nPosNatRen == 0
				aAdd(aNatRend[2],{(cAliasSD2)->F2Q_NATREN, (cAliasSD2)->D2_VALIRRF, (cAliasSD2)->D2_BASEIRR})
			Else
				aNatRend[2][nPosNatRen,2] += (cAliasSD2)->D2_VALIRRF
				aNatRend[2][nPosNatRen,3] += (cAliasSD2)->D2_BASEIRR
			Endif
		EndIf

		(cAliasSD2)->(dbSkip())

		If !Empty(aNatRend[2]) .And. aNota[2] <> (cAliasSD2)->D2_DOC
			aAdd(aCountNat, aClone(aNatRend))
			aAdd(aTitulos, aCLone(aNota))

			aNatRend[2] := {}
		EndIf
	EndDo

	(cAliasSD2)->(DbCloseArea())

	For nZ := 1 to Len(aTitulos)

		If oFatSE1 == Nil
			cQrySE1 := " SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, "
			cQrySE1 += " SE1.E1_IRRF, SE1.E1_BASEIRF, SE1.E1_TITPAI "
			cQrySE1 += " FROM ? SE1 "
			cQrySE1 += " WHERE SE1.E1_FILIAL = ? "
			cQrySE1 += " AND SE1.E1_PREFIXO = ? "
			cQrySE1 += " AND SE1.E1_NUM = ? "
			cQrySE1 += " AND SE1.E1_EMISSAO > ? "
			cQrySE1 += " AND SE1.E1_ORIGEM = 'MATA460' "
			cQrySE1 += " AND SE1.D_E_L_E_T_ = ' ' "

			cQrySE1	:= ChangeQuery(cQrySE1)
			oFatSE1 := FwPreparedStatement():New(cQrySE1)
		EndIf

		oFatSE1:SetNumeric(1, RetSqlName("SE1"))
		oFatSE1:SetString(2, FwxFilial("SE1"))
		oFatSE1:SetString(3, aTitulos[nZ][1])
		oFatSE1:SetString(4, aTitulos[nZ][2])
		oFatSE1:SetString(5, cDtIni)

		cQrySE1 := oFatSE1:GetFixQuery()
		cAliasSE1 := MpSysOpenQuery(cQrySE1)

		While (cAliasSE1)->(!Eof())
			If Empty(aSE1NatRen[2])
				aSE1NatRen[1] := (cAliasSE1)->E1_IRRF

				Aadd(aSE1NatRen[2], {(cAliasSE1)->E1_PREFIXO, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_TIPO, (cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA,;
					(cAliasSE1)->E1_IRRF, (cAliasSE1)->E1_BASEIRF, (cAliasSE1)->E1_TITPAI})

				cTitulo := (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_TIPO
			Else
				aSE1NatRen[1] += (cAliasSE1)->E1_IRRF

				Aadd(aSE1NatRen[2], {(cAliasSE1)->E1_PREFIXO, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_TIPO, (cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA,;
					(cAliasSE1)->E1_IRRF, (cAliasSE1)->E1_BASEIRF, (cAliasSE1)->E1_TITPAI})
			EndIf

			DbSelectArea(cReinfLog)
			DbSetIndex('IND1')
			lRegNew := (cReinfLog)->(MsSeek("DS" + cTitulo ))

			If RecLock(cReinfLog,!lRegNew)
				(cReinfLog)->GRUPO    := cEmpAnt
				(cReinfLog)->EMPFIL   := cFilAnt
				(cReinfLog)->DATAPROC := FWTimeStamp(2, DATE(), TIME())
				(cReinfLog)->TIPO     := "DS"
				(cReinfLog)->CHAVE    := cTitulo
				(cReinfLog)->FATC6    := "U" //U=Update
				(cReinfLog)->FATFKW   := "I" //I=Insert
				(cReinfLog)->(MsUnlock())
			Endif

			(cAliasSE1)->(dbSkip())

			If !Empty(aSE1NatRen[2]) .And. cTitulo <> (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_TIPO
				aAdd(aCountSE1, aClone(aSE1NatRen))

				If nNatLoop < nZ
					aAdd(aNatAux, aClone(aCountNat[nZ]))
					nNatloop := nZ
				EndIf

				aSE1NatRen[2] := {}
			EndIf
		EndDo

		(cAliasSE1)->(DbCloseArea())
	Next nZ

	For nX := 1 to Len(aNatureza)
		SC6->(dbGoto(aNatureza[nX][1]))

		IF SC6->C6_NATREN = ' '
			RecLock("SC6",.F.)
			SC6->C6_NATREN	:= aNatureza[nX][2]
			SC6->(MsUnlock())
		EndIf
	Next nX

	aCountNat := aClone(aNatAux)
	FWFreeArray(aNatAux)

	For nI := 1 to Len(aCountNat)
		A461FKW(3,aCountNat[nI], aCountSE1[nI])
	Next nI

Return
