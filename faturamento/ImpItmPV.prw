#Include "Totvs.ch"
/*/
{Protheus.doc} ImpPrev
Importa itens do pedido a partir de arquivo CSV
@type  Function
@author Rafael Mattiuzzo
@since 24/01/2023
@version 1.0
/*/
User Function ImpItmPv

	Processa({|| ExecImpPv()},"Aguarde...","Carregando Registros...")

Return
//#####################################################
//#####################################################
//#####################################################
Static Function ExecImpPv

	Local nLin 			:= 0
	Local nX			:= 0
	Local nY            := 0
	Local aReadCSV 		:= {}
	Local aDadosCfo		:= {}
	Local cEst  		:= ""

	Private cTipo		:= "Arquivos CSV|*.CSV|Todos os Arquivos|*.*"
	Private cRetArq		:= cGetFile(cTipo,OemToAnsi("Selecione o Diretorio onde deseja salvar os arquivos"),,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE)
	Private oLeTxt
	Private cLineRead	:= ""
	Private cTitle		:= ""
	Private aItmPv		:= {}
	Private aErros		:= {}

	If M->C5_TIPO <> ("B/D")
		SA1->( DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI) )
		cEst	:= SA1->A1_EST
	Else
		SA2->( DbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI) )
		cEst	:= SA2->A2_EST
	EndIf

	If FT_FUse( cRetArq ) <> -1

		FT_FGotop()

		While ( !fT_fEof() )

			cLineRead := FT_FREADLN()

			AADD(aReadCSV,Separa(cLineRead,";",.T.))

			fT_fSkip()

			nLin++
		End

		fT_fUse()

		ProcRegua( Len(aReadCSV) )

		For nX := 2 to Len(aReadCSV)
			IncProc("Leitura da linha " + cValToChar(nX) + " de " + cValToChar(Len(aReadCSV)) + "...")
			aAdd( aItmPV, { aReadCSV[nX,01], aReadCSV[nX,02], aReadCSV[nX,03], aReadCSV[nX,04], aReadCSV[nX,05], aReadCSV[nX,06], aReadCSV[nX,07], aReadCSV[nX,08], aReadCSV[nX,09], aReadCSV[nX,10], aReadCSV[nX,11], aReadCSV[nX,12], aReadCSV[nX,13], aReadCSV[nX,14] } )
		Next

		If Len(aItmPv) > 0
			For nX := 1 to Len( aItmPv )
				IncProc("Processando linha " + cValToChar(nX) + " de " + cValToChar(Len(aItmPv)) + "...")
				cItem := GdFieldGet("C6_ITEM",Len(aCols))

				aAdd(aCols,Array(Len(aHeader)+1))

				For nY	:= 1 To Len(aHeader)
					If ( AllTrim(aHeader[nY][2]) == "C6_ITEM" )
						aCols[Len(aCols)][nY] := Soma1(cItem)
					Else
						If (aHeader[nY,2] <> "C6_REC_WT") .And. (aHeader[nY,2] <> "C6_ALI_WT")
							aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
						EndIf
					EndIf
				Next nY

				N := Len(aCols)

				aCols[N][Len(aHeader)+1] := .F.

				A410Produto(aItmPv[nX,01],.F.)
				GdFieldPut("C6_PRODUTO",aItmPv[nX,01],Len(aCols))
				A410MultT("M->C6_PRODUTO",aItmPv[nX,01])

				If ExistTrigger("C6_PRODUTO")
					RunTrigger(2,N,Nil,,"C6_PRODUTO")
				Endif

				A410SegUm(.T.)

				A410MultT("M->C6_QTDVEN",Val(aItmPv[nX,02]))

				If ExistTrigger("C6_QTDVEN")
					RunTrigger(2,N,Nil,,"C6_QTDVEN")
				Endif

				GdFieldPut("C6_PRCVEN"		,Val(aItmPv[nX,03])	,Len(aCols))
				A410MultT("M->C6_PRCVEN"	,Val(aItmPv[nX,03]))

				If ExistTrigger("C6_PRCVEN")
					RunTrigger(2,N,Nil,,"C6_PRCVEN")
				Endif

				GdFieldPut("C6_TES"	  		,aItmPv[nX,04]			,Len(aCols))

				SF4->( DbSetOrder(01) )
				If SF4->( DbSeek( xFilial("SF4") + aItmPv[nX,04] ) )

					aAdd(aDadosCfo,{"OPERNF","S"})
					aAdd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
					aAdd(aDadosCfo,{"UFDEST",cEst})

					cCfop := MaFisCfo(,SF4->F4_CF,aDadosCfo)
					GdFieldPut("C6_CF",cCfop,Len(aCols))
					GdFieldPut("C6_CLASFIS",SB1->B1_ORIGEM+SF4->F4_SITTRIB,Len(aCols))

				EndIf
			Next
		Else

		EndIf

		FWAlertSuccess("Processo de Importação Finalizado!","Processamento")

	EndIf

Return
