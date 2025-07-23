#include 'totvs.ch'
#include 'topconn.ch'


user function uCorrAtf()
	local oSay := NIL
	local aSays        := {}
	local aButtons     := {}
	local lOk          := .F.

	aAdd(aSays, "Esse programa tem como objetivo corrigir")
	aAdd(aSays, "os registros do ativo fixo que nao foram depreciados.")

	aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
	aAdd(aButtons, { 2, .T., {|| lOk := .F., FechaBatch() }} )
	FormBatch("Correção Ativo Fixo - Cavanna", aSays, aButtons)

	If lOk
		FwMsgRun(NIL, {|oSay| procAj(oSay)}, "Processando", "Iniciando Processamento...")
	EndIf

return()


// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

static function procAj(op_Say)

	local cMoedaAtf 	:= SuperGetMV("MV_ATFMOED")
	local nSldAcelMP	:= 0
	local nTaxa         := 0.008333
	aValorMoed := {}
	nSldAcelMP := 0
	nSldAcelM1 := 0

	cQuery := ""
	cQuery += " SELECT * FROM AUX_ATF WHERE STATUS = ''"
	cQuery += " ORDER BY CBASE, ITEM, PERIODO
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery( cQuery, 'QRY' )
	QRY->( DbGoTop() )
	If QRY->( !Eof() )
		While QRY->( !Eof() )

			dbSelectArea("SN3")
			dbSetOrder(1)
			If dbSeek(FWxFilial("SN3") + QRY->CBASE + QRY->ITEM)

				BEGIN TRANSACTION
					op_Say:SetText("Atualizando ATF: " + QRY->CBASE) // ALTERA O TEXTO CORRETO
					ProcessMessages() // FORÇA O DESCONGELAMENTO DO SMARTCLIENT

					reclock("SN3",.F.)
					SN3->N3_VRDACM1 += Round( QRY->VALOR, X3Decimal("N3_VRDACM1") )
					SN3->N3_VRDBAL1 += Round( QRY->VALOR, X3Decimal("N3_VRDBAL1") )

					// If	round(ABS(SN3->N3_VRDACM1) + ABS(nSldAcelM1) +ABS(SN3->N3_VRCDA1),2) >= ABS(SN3->N3_VORIG1) + ABS(SN3->N3_AMPLIA1) .And.;
						// 		(ABS(&('SN3->N3_VRDACM'+cMoedaAtf)) + ABS(nSldAcelMP)) >= (ABS(&('SN3->N3_VORIG'+cMoedaAtf)) + IIf(	cMoedaAtf == '1',ABS(SN3->N3_VRCACM1),0) + ABS(&('SN3->N3_AMPLIA'+cMoedaAtf))) .And.;
						// 		Empty( SN3->N3_FIMDEPR )
					// 	If 	((SN3->N3_VORIG1 + SN3->N3_VRCACM1 + SN3->N3_AMPLIA1)-(SN3->N3_VRDACM1 + SN3->N3_AMPLIA1 + SN3->N3_VRCDA1)) < 0
					// 		SN3->N3_VRDACM1 += 	(SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1)-(SN3->N3_VRDACM1 + SN3->N3_VRCDA1)
					// 		SN3->N3_VRDBAL1 += 	(SN3->N3_VORIG1 + SN3->N3_AMPLIA1 + SN3->N3_VRCACM1)-(SN3->N3_VRDACM1 + SN3->N3_VRCDA1)
					// 	EndIf
					// EndIf
					SN3->(MsUnlock())



					dbSelectArea("SN4")
					dbSetOrder(1)
					Reclock("SN4",.T.)
					SN4->N4_FILIAL  := xFilial("SN4")
					SN4->N4_CBASE   := SN3->N3_CBASE
					SN4->N4_ITEM    := SN3->N3_ITEM
					SN4->N4_TIPO    := SN3->N3_TIPO
					SN4->N4_OCORR   := "06" 	//Depreciação
					SN4->N4_TIPOCNT := "4" 		//DEPREC ACUM
					SN4->N4_CONTA   := SN3->N3_CCDEPR
					SN4->N4_DATA    := sTod(QRY->PERIODO)
					SN4->N4_TPSALDO := '1'
					SN4->N4_HORA    := substr(Time(),1,5)
					SN4->N4_VLROC1  := Round( QRY->VALOR, X3Decimal("N4_VLROC1") )
					SN4->N4_TXDEPR  := nTaxa
					SN4->N4_CCUSTO  := SN3->N3_CCCDEP
					SN4->N4_SUBCTA  := SN3->N3_SUBCCDE
					SN4->N4_CLVL    := SN3->N3_CLVLCDE
					SN4->N4_SEQ     := SN3->N3_SEQ
					SN4->(MsUnlock())



					dbSelectArea("SN4")
					dbSetOrder(1)
					Reclock("SN4",.T.)
					SN4->N4_FILIAL  := xFilial("SN4")
					SN4->N4_CBASE   := SN3->N3_CBASE
					SN4->N4_ITEM    := SN3->N3_ITEM
					SN4->N4_TIPO    := SN3->N3_TIPO
					SN4->N4_OCORR   := "06" 	//Depreciação
					SN4->N4_TIPOCNT := "3" 		//despesa de depreciacao
					SN4->N4_CONTA   := SN3->N3_CDEPREC
					SN4->N4_DATA    := sTod(QRY->PERIODO)
					SN4->N4_VLROC1  := Round( QRY->VALOR, X3Decimal("N4_VLROC1") )
					SN4->N4_TPSALDO := '1'
					SN4->N4_HORA    := substr(Time(),1,5)
					SN4->N4_TXDEPR  := nTaxa
					SN4->N4_CCUSTO  := SN3->N3_CCDESP
					SN4->N4_SUBCTA  := SN3->N3_SUBCDEP
					SN4->N4_CLVL    := SN3->N3_CLVLDEP
					SN4->N4_SEQ     := SN3->N3_SEQ
					SN4->(MsUnlock())

					aValorMoed := AtfMultMoe(,,{|x| IIf(x=1,QRY->VALOR,0) })

					ATFSaldo(	SN3->N3_CCDEPR , sTod(QRY->PERIODO), '4', Abs(QRY->VALOR),0,0,0,0 ,;
						"+", nTaxa, SN3->N3_SUBCCDE,, SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
					ATFSaldo(	SN3->N3_CDEPREC,sTod(QRY->PERIODO),'4', Abs(QRY->VALOR),0,0,0,0 ,;
						"+",nTaxa,SN3->N3_SUBCDEP,,SN3->N3_CLVLDEP,SN3->N3_CCDESP,"3", aValorMoed )

					cQryUpd := "UPDATE AUX_ATF SET STATUS = 'X' FROM AUX_ATF WHERE CBASE = '" + QRY->CBASE + ;
						"' AND ITEM = '" + QRY->ITEM + "' AND PERIODO = '" + QRY->PERIODO + "'"
					TCSQLEXEC(cQryUpd)

				END TRANSACTION

			EndIf


			QRY->(dbSkip())
		EndDo
	EndIf

return()
