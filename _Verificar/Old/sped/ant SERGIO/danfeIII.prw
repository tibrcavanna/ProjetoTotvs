#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   010                                                // M�ximo de produtos para a primeira p�gina
#DEFINE MAXITEMP2 043                                                // M�ximo de produtos para a pagina 2 (caso nao utilize a op��o de impressao em verso)
#DEFINE MAXITEMP3 015                                                // M�ximo de produtos para a pagina 2 (caso utilize a op��o de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMP4 022                                                // M�ximo de produtos para a pagina 2 (caso contenha main info cpl que suporta a primeira pagina)
#DEFINE MAXITEMC  040                                                // M�xima de caracteres por linha de produtos/servi�os
#DEFINE MAXMENLIN 125                                                // M�ximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    006                                                // M�ximo de dados adicionais na primeira p�gina
#DEFINE MAXMSG2   019                                                // M�ximo de dados adicionais na segunda p�gina
#DEFINE MAXBOXH   800                                                // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE INIBOXH   -10
#DEFINE MAXMENL   080                                                // M�ximo de caracteres por linha de dados adicionais

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PrtNfeSef � Autor � Eduardo Riera         � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rdmake de exemplo para impress�o da DANFE no formato Retrato���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function DANFE_P1(cIdEnt,cVal1,cVal2,oDanfe,oSetup)

Local aArea     := GetArea() 
Local lExistNfe := .F.

oDanfe:SetResolution(78) // Tamanho estipulado para a Danfe
oDanfe:SetLandscape()
oDanfe:SetPaperSize(DMPAPER_A4)
oDanfe:SetMargin(60,60,60,60)
oDanfe:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
If ( !oDanfe:lInJob )
	// ----------------------------------------------
	// Define saida de impress�o
	// ---------------------------------------------
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oDanfe:nDevice := IMP_SPOOL
		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oDanfe:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oDanfe:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oDanfe:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	Endif
EndIf

/*
// ----------------------------------------------
// Nova ordem obrigat�ria para abertura do relat�rio
// ----------------------------------------------
oDanfe:SetResolution(78) // 78dpi
oDanfe:SetPortrait() // Retrato ou Paisagem
oDanfe:SetPaperSize(DMPAPER_A4)
oDanfe:SetMargin(70,70,70,70) // Em pixels: nEsquerda, nSuperior, nDireita, nInferior
// ----------------------------------------------
*/
Private PixelX := odanfe:nLogPixelX()
Private PixelY := odanfe:nLogPixelY()

// ------------------------------------------------------------------------------------------
// Execu��o via Job
// ------------------------------------------------------------------------------------------
If ( oDanfe:lInJob )
	// ------------------------------------------------------------------------------------------
	// Verifica o paramento DanfeDevice no environment do server
	// ------------------------------------------------------------------------------------------
	nDevice := Val(GetSrvProfString("DanfeDevice", StrZero(IMP_PDF,1)) )
	oDanfe:SetDevice( nDevice )
	
	DanfeProc(@oDanfe,.F.,cIdEnt,cVal1,cVal2,@lExistNfe)
Else
	// ------------------------------------------------------------------------------------------
	// Execu��o via thread de smartclient
	// ------------------------------------------------------------------------------------------
	RptStatus({|lEnd| DanfeProc(@oDanfe,@lEnd,cIdEnt,,,@lExistNfe)},"Imprimindo Danfe...")
EndIf

If lExistNfe
	oDanfe:Preview()//Visualiza antes de imprimir
Else
	Aviso("DANFE","Nenhuma NF-e a ser impressa nos parametros utilizados.",{"OK"},3)
EndIf
FreeObj(oDanfe)
oDanfe := Nil
RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �DANFEProc � Autor � Eduardo Riera         � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rdmake de exemplo para impress�o da DANFE no formato Retrato���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                    (OPC) ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function DanfeProc(oDanfe,lEnd,cIdEnt,cVal1,cVal2,lExistNfe)

Local aArea      := GetArea()
Local aNotas     := {}
Local aXML       := {}
Local aAutoriza  := {}
Local cNaoAut    := ""

Local cAliasSF3  := "SF3"
Local cWhere     := ""
Local cAviso     := ""
Local cErro      := ""
Local cAutoriza  := ""
Local cModalidade:= ""
Local cChaveSFT  := ""
Local cAliasSFT  := "SFT"
Local cCondicao	 := ""
Local cIndex	 := ""
Local cChave	 := ""

Local lQuery     := .F.

Local nX         := 0
Local nI		 := 0

Local oNfe
Local nLenNotas
Local lImpDir	 :=GetNewPar("MV_IMPDIR",.F.)
Local nLenarray	 := 0
Local nCursor	 := 0
Local lBreak	 := .F.
Local aGrvSF3    := {}

If Pergunte("NFSIGW",.T.)
	MV_PAR01 := AllTrim(MV_PAR01)
	If !lImpDir
		dbSelectArea("SF3")
		dbSetOrder(5)
		#IFDEF TOP
			If MV_PAR04==1
				cWhere := "%SubString(SF3.F3_CFO,1,1) < '5' AND SF3.F3_FORMUL='S'%"
			ElseIf MV_PAR04==2
				cWhere := "%SubString(SF3.F3_CFO,1,1) >= '5'%"
			EndIf
			cAliasSF3 := GetNextAlias()
			lQuery    := .T.
			
			If Empty(cWhere)
				
				BeginSql Alias cAliasSF3
					
					COLUMN F3_ENTRADA AS DATE
					COLUMN F3_DTCANC AS DATE
					
					SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND
					SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND
					SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND
					SF3.F3_DTCANC = %Exp:Space(8)% AND
					SF3.%notdel%
				EndSql
				
			Else
				BeginSql Alias cAliasSF3
					
					COLUMN F3_ENTRADA AS DATE
					COLUMN F3_DTCANC AS DATE
					
					SELECT	F3_FILIAL,F3_ENTRADA,F3_NFELETR,F3_CFO,F3_FORMUL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_ESPECIE,F3_DTCANC
					FROM %Table:SF3% SF3
					WHERE
					SF3.F3_FILIAL = %xFilial:SF3% AND
					SF3.F3_SERIE = %Exp:MV_PAR03% AND
					SF3.F3_NFISCAL >= %Exp:MV_PAR01% AND
					SF3.F3_NFISCAL <= %Exp:MV_PAR02% AND
					%Exp:cWhere% AND
					SF3.F3_DTCANC = %Exp:Space(8)% AND
					SF3.%notdel%
				EndSql
				
			EndIf
			
		#ELSE
			MsSeek(xFilial("SF3")+MV_PAR03+MV_PAR01,.T.)
			cIndex    		:= CriaTrab(NIL,.F.)
			cChave			:= IndexKey(6)
			cCondicao 		:= 'F3_FILIAL == "' + xFilial("SF3") + '" .And. '
			cCondicao 		+= 'SF3->F3_SERIE =="'+ MV_PAR03+'" .And. '
			cCondicao 		+= 'SF3->F3_NFISCAL >="'+ MV_PAR01+'" .And. '
			cCondicao		+= 'SF3->F3_NFISCAL <="'+ MV_PAR02+'" .And. '
			cCondicao		+= 'Empty(SF3->F3_DTCANC)'
			IndRegua("SF3",cIndex,cChave,,cCondicao)
		#ENDIF
		If MV_PAR04==1
			cWhere := "SubStr(F3_CFO,1,1) < '5' .AND. F3_FORMUL=='S'"
		Elseif MV_PAR04==2
			cWhere := "SubStr(F3_CFO,1,1) >= '5'"
		Else
			cWhere := ".T."
		EndIf
		
		While !Eof() .And. xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
			(cAliasSF3)->F3_SERIE == MV_PAR03 .And.;
			(cAliasSF3)->F3_NFISCAL >= MV_PAR01 .And.;
			(cAliasSF3)->F3_NFISCAL <= MV_PAR02
			
			dbSelectArea(cAliasSF3)
			If  Empty((cAliasSF3)->F3_DTCANC) .And. &cWhere //.And. AModNot((cAliasSF3)->F3_ESPECIE)=="55"
				
				If (SubStr((cAliasSF3)->F3_CFO,1,1)>="5" .Or. (cAliasSF3)->F3_FORMUL=="S") .And. aScan(aNotas,{|x| x[4]+x[5]+x[6]+x[7]==(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA})==0
					
					aadd(aNotas,{})
					aadd(Atail(aNotas),.F.)
					aadd(Atail(aNotas),IIF((cAliasSF3)->F3_CFO<"5","E","S"))
					aadd(Atail(aNotas),(cAliasSF3)->F3_ENTRADA)
					aadd(Atail(aNotas),(cAliasSF3)->F3_SERIE)
					aadd(Atail(aNotas),(cAliasSF3)->F3_NFISCAL)
					aadd(Atail(aNotas),(cAliasSF3)->F3_CLIEFOR)
					aadd(Atail(aNotas),(cAliasSF3)->F3_LOJA)
					
				EndIf
			EndIf
			
			dbSelectArea(cAliasSF3)
			dbSkip()
			If lEnd
				Exit
			EndIf
			If Len(aNotas) >= 50 .Or. 	(cAliasSF3)->(Eof())
				aXml := GetXML(cIdEnt,aNotas,@cModalidade)
				nLenNotas := Len(aNotas)
				For nX := 1 To nLenNotas
					If !Empty(aXML[nX][2])
						If !Empty(aXml[nX])
							cAutoriza   := aXML[nX][1]
							cCodAutDPEC := aXML[nX][5]
						Else
							cAutoriza   := ""
							cCodAutDPEC := ""
						EndIf
						If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,4,5,6")
							If aNotas[nX][02]=="E"
								dbSelectArea("SF1")
								dbSetOrder(1)
								If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4,6"
									RecLock("SF1")
									If !SF1->F1_FIMP$"D"
										SF1->F1_FIMP := "S"
									EndIf
									If SF1->(FieldPos("F1_CHVNFE"))>0
										SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									EndIf
									MsUnlock()
								EndIf
							Else
								dbSelectArea("SF2")
								dbSetOrder(1)
								If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. cModalidade$"1,4,6"
									RecLock("SF2")
									If !SF2->F2_FIMP$"D"
										SF2->F2_FIMP := "S"
									EndIf
									If SF2->(FieldPos("F2_CHVNFE"))>0
										SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										SF2->F2_CODNFE := cAutoriza
									EndIf
									MsUnlock()
								EndIf
							EndIf
							dbSelectArea("SFT")
							dbSetOrder(1)
							If SFT->(FieldPos("FT_CHVNFE"))>0
								cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05]+aNotas[nX][06]+aNotas[nX][07])
								If MsSeek(cChaveSFT)
									Do While !(cAliasSFT)->(Eof ()) .And.;
										cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
										RecLock("SFT")
										SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										SFT->FT_CODNFE := cAutoriza
										MsUnLock()
										//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
										If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
											aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza})
										EndIf
										DbSkip()
									EndDo
								EndIf
							EndIf
							
							cAviso := ""
							cErro  := ""
							oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
							oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
							If Empty(cAviso) .And. Empty(cErro)
								ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7])
								lExistNfe := .T.
							EndIf
						Else
							cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF
						EndIf
					EndIf
					
				Next nX
				aNotas := {}
			EndIf
			dbSelectArea(cAliasSF3)
		EndDo
		If !lQuery
			RetIndex("SF3")
			dbClearFilter()
			Ferase(cIndex+OrdBagExt())
		EndIf
		If !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas n�o foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf
	Else
		//�����������������������������������������������������������Ŀ
		//�Tratamento para quando o parametro MV_IMPDIR esteja        �
		//�Habilitado, neste caso n�o ser� feita a impress�o conforme �
		//�Registros no SF3, e sim buscando XML diretamente do        �
		//�webService, e caso exista ser� impresso.                   �
		//�������������������������������������������������������������
		nLenarray := Val(MV_PAR02) - Val(Alltrim(MV_PAR01))
		nCursor   := Val(MV_PAR01)
		While  !lBreak  .And. nLenarray >= 0
			aNotas := {}
			For nx:=1 To 20
				aadd(aNotas,{})
				aAdd(Atail(aNotas),.F.)
				aadd(Atail(aNotas),IIF(MV_PAR04==1,"E","S"))
				aAdd(Atail(aNotas),"")
				aAdd(Atail(aNotas),MV_PAR03)
				aAdd(Atail(aNotas),Alltrim(Strzero(nCursor,9)))
				aadd(Atail(aNotas),"")
				aadd(Atail(aNotas),"")
				If nCursor==Val(MV_PAR02)
					lBreak :=.T.
					nx:=20
				EndIF
				nCursor++
			Next nX
			aXml:={}
			aXml := GetXML(cIdEnt,aNotas,@cModalidade)
			nLenNotas := Len(aNotas)
			For nx :=1 To nLenNotas
				If !Empty(aXML[nX][2])
					If !Empty(aXml[nX])
						cAutoriza   := aXML[nX][1]
						cCodAutDPEC := aXML[nX][5]
					Else
						cAutoriza   := ""
						cCodAutDPEC := ""
					EndIf
					cAviso := ""
					cErro  := ""
					oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)
					oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)
					If (!Empty(cAutoriza) .Or. !Empty(cCodAutDPEC) .Or. !cModalidade$"1,4,5,6")
						//------------------------------
						If aNotas[nX][02]=="E" .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
							dbSelectArea("SF1")
							dbSetOrder(1)
							If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4,6"
								Do While !Eof() .And. SF1->F1_DOC==aNotas[nX][05] .And. SF1->F1_SERIE==aNotas[nX][04]
									If SF1->F1_FORMUL=='S'
										RecLock("SF1")
										If !SF1->F1_FIMP$"D"
											SF1->F1_FIMP := "S"
										EndIf
										If SF1->(FieldPos("F1_CHVNFE"))>0
											SF1->F1_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
										EndIf
										MsUnlock()
										DbSkip()
									EndIf
								EndDo
							EndIf
						ElseIf aNotas[nX][02]=="S" .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
							dbSelectArea("SF2")
							dbSetOrder(1)
							If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]) .And. cModalidade$"1,4,6"
								RecLock("SF2")
								If !SF2->F2_FIMP$"D"
									SF2->F2_FIMP := "S"
								EndIf
								If SF2->(FieldPos("F2_CHVNFE"))>0
									SF2->F2_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
								EndIf
								MsUnlock()
							EndIf
						EndIf
						dbSelectArea("SFT")
						dbSetOrder(1)
						If SFT->(FieldPos("FT_CHVNFE"))>0
							cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05])
							MsSeek(cChaveSFT)
							Do While !(cAliasSFT)->(Eof ()) .And.;
								cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL
								If (cAliasSFT)->FT_TIPOMOV $"S" .Or. ((cAliasSFT)->FT_TIPOMOV $"E" .And. (cAliasSFT)->FT_FORMUL=='S')
									//Array criado para gravar o SF3 no final, pois a tabela SF3 pode estah em processamento quando se trata de DBF ou AS/400.
									If aScan(aGrvSF3,{|aX|aX[1]+aX[2]+aX[3]+aX[4]+aX[5]==(cAliasSFT)->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_IDENTF3)})==0
										aAdd(aGrvSF3, {(cAliasSFT)->FT_SERIE,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CLIEFOR,(cAliasSFT)->FT_LOJA,(cAliasSFT)->FT_IDENTF3,(cAliasSFT)->FT_CHVNFE,cAutoriza})
									EndIf
									RecLock("SFT")
									SFT->FT_CHVNFE := SubStr(NfeIdSPED(aXML[nX][2],"Id"),4)
									MsUnLock()
									DbSkip()
								EndIf
								DbSkip()
							EndDo
						EndIf
						//-------------------------------
						If Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0")
							ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7])
							lExistNfe := .T.							
						ElseIf Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1")
							ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6],aXml[nX][7])
							lExistNfe := .T.
						EndIf
					Else
						cNaoAut += aNotas[nX][04]+aNotas[nX][05]+CRLF
					EndIf
				EndIf
			Next nx
		EndDo
		If !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas n�o foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf
	EndIf
EndIf
If Len(aGrvSF3)>0 .And. SF3->(FieldPos("F3_CHVNFE"))>0
	For nI := 1 To Len(aGrvSF3)
		If SF3->(MsSeek(xFilial("SF3")+aGrvSF3[nI,1]+aGrvSF3[nI,2]+aGrvSF3[nI,3]+aGrvSF3[nI,4]+aGrvSF3[nI,5])) .And. Empty(SF3->F3_CHVNFE)
			RecLock("SF3")
			SF3->F3_CHVNFE := aGrvSF3[nI,6]
			SF3->F3_CODNFE := aGrvSF3[nI,7]
			MsUnLock()
		EndIf
	Next nI
EndIf
RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   � ImpDet   � Autor � Eduardo Riera         � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Controle de Fluxo do Relatorio.                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                    (OPC) ���
���          �ExpC2: String com o XML da NFe                              ���
���          �ExpC3: Codigo de Autorizacao do fiscal                (OPC) ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ImpDet(oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb)
/*
PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",07,07,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",12,10,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",11,09,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",18,18,.T.,.T.,.F.)// 12
PRIVATE oFont12N   := TFontEx():New(oDanfe,"Times New Roman",12,12,.T.,.T.,.F.)// 13
*/

PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",07,07,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12 
PRIVATE OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12 


PrtDanfe(@oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb)

Return(.T.)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrtDanfe  � Autor �Eduardo Riera          � Data �16.11.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do formulario DANFE grafico conforme laytout no   ���
���          �formato retrato                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrtDanfe()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto grafico de impressao                          ���
���          �ExpO2: Objeto da NFe                                        ���
���          �ExpC3: Codigo de Autorizacao do fiscal                (OPC) ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrtDanfe(oDanfe,oNFE,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb)


Local aTamanho      := {}
Local aSitTrib      := {}
Local aTransp       := {}
Local aDest         := {}
Local aHrEnt 		:= {}
Local aFaturas      := {}
Local aItens        := {}
Local aISSQN        := {}
Local aTotais       := {}
Local aAux          := {}
Local aUF		 := {}
Local nHPage        := 0
Local nVPage        := 0
Local nPosV         := 0
Local nPosVOld      := 0
Local nPosH         := 0
Local nPosHOld      := 0
Local nAuxH         := 0
Local nAuxV         := 0
Local nX            := 0
Local nY            := 0
Local nL			 := 0
Local nJ		 := 0
Local nW		 := 0
Local nTamanho      := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nItem         := 0
Local nMensagem     := 0
Local nBaseICM      := 0
Local nValICM       := 0
Local nBaseICMST    := 0
Local nValICMST     := 0
Local nValIPI       := 0
Local nPICM         := 0
Local nPIPI         := 0
Local nFaturas      := 0
Local nVTotal       := 0
Local nQtd          := 0
Local nVUnit        := 0
Local nVolume	    := 0
Local cAux          := ""
Local cSitTrib      := ""
Local aMensagem     := {}
Local lPreview      := .F.
Local lFlag    		:= .T.
Local nLenFatura
Local nLenVol
Local nLenDet
Local nLenSit
Local nLenItens     := 0
Local nLenMensagens := 0
Local nLen          := 0
Local cUF		 := ""
Local lImpAnfav     := GetNewPar("MV_IMPANF",.F.) 
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local cChaveCont := ""
Local cLogo      := FisxLogo("1")
Local aEspVol   := {} 
Local nColuna:= 0
Local nLinSum	:=	0
Local cMVCODREG		:= SuperGetMV("MV_CODREG", ," ") 
Local aEspecie  := {} 
Local cGuarda   := ""
Local nE		:= 0
Local cEsp		:= ""

Default cDtHrRecCab:= ""
Default dDtReceb   := CToD("")

Private oDPEC    :=oNfeDPEC
Private oNF        := oNFe:_NFe
Private oEmitente  := oNF:_InfNfe:_Emit
Private oIdent     := oNF:_InfNfe:_IDE
Private oDestino   := oNF:_InfNfe:_Dest
Private oTotal     := oNF:_InfNfe:_Total
Private oTransp    := oNF:_InfNfe:_Transp
Private oDet       := oNF:_InfNfe:_Det
Private oFatura    := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
Private oImposto
Private nPrivate   := 0
Private nPrivate2  := 0
Private nXAux	   := 0
Private aInfNf:= {}
oBrush := TBrush():New( , CLR_BLACK )

nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
//������������������������������������������������������������������������Ŀ
//�Carrega as variaveis de impressao                                       �
//��������������������������������������������������������������������������
aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")
//������������������������������������������������������������������������Ŀ
//�Quadro Destinatario                                                     �
//��������������������������������������������������������������������������
aDest := {NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte)+IIF(", SN"$NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte),"",", "+oDestino:_EnderDest:_NRO:Text + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))),;
NoChar(oDestino:_EnderDest:_XBairro:Text,lConverte),;
IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text),;//			oIdent:_DSaiEnt:Text,;
oDestino:_EnderDest:_XMun:Text,;
IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
oDestino:_EnderDest:_UF:Text,;
oDestino:_IE:Text,;
""}
If SFT->FT_TIPOMOV =="S" .and. !Empty(SF2->F2_DOC)
	aadd(aHrEnt,SF2->F2_HORA)
Elseif SFT->FT_TIPOMOV =="E" .and. SF1->F1_FORMUL=="S"
	aadd(aHrEnt,SF1->F1_HORA)
Else
	aadd(aHrEnt,"")
Endif
//������������������������������������������������������������������������Ŀ
//�Calculo do Imposto                                                      �
//��������������������������������������������������������������������������
aTotais := {"","","","","","","","","","",""}
aTotais[01] := Transform(Val(oTotal:_ICMSTOT:_vBC:TEXT),"@ze 999,999,999.99")
aTotais[02] := Transform(Val(oTotal:_ICMSTOT:_vICMS:TEXT),"@ze 9,999,999.99")
aTotais[03] := Transform(Val(oTotal:_ICMSTOT:_vBCST:TEXT),"@ze 999,999,999.99")
aTotais[04] := Transform(Val(oTotal:_ICMSTOT:_vST:TEXT),"@ze 9,999,999.99")
aTotais[05] := Transform(Val(oTotal:_ICMSTOT:_vProd:TEXT),"@ze 9,999,999.99")
aTotais[06] := Transform(Val(oTotal:_ICMSTOT:_vFrete:TEXT),"@ze 9,999,999.99")
aTotais[07] := Transform(Val(oTotal:_ICMSTOT:_vSeg:TEXT),"@ze 9,999,999.99")
aTotais[08] := Transform(Val(oTotal:_ICMSTOT:_vDesc:TEXT),"@ze 9,999,999.99")
aTotais[09] := Transform(Val(oTotal:_ICMSTOT:_vOutro:TEXT),"@ze 9,999,999.99")
If SF1->F1_TIPO <> "D"
	aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@ze 9,999,999.99")
Else
	aTotais[10] := ""
EndIf
aTotais[11] := 	Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@ze 999,999,999.99")
//������������������������������������������������������������������������Ŀ
//�Quadro Faturas                                                          �
//��������������������������������������������������������������������������
If nFaturas > 0
	For nX := 1 To 3
		aAux := {}
		For nY := 1 To Min(9, nFaturas)
			Do Case
				Case nX == 1
					If nFaturas > 1
						AAdd(aAux, AllTrim(oFatura:_Dup[nY]:_nDup:TEXT))
					Else
						AAdd(aAux, AllTrim(oFatura:_Dup:_nDup:TEXT))
					EndIf
				Case nX == 2
					If nFaturas > 1
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup[nY]:_dVenc:TEXT)))
					Else
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup:_dVenc:TEXT)))
					EndIf
				Case nX == 3
					If nFaturas > 1
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup[nY]:_vDup:TEXT), "@E 9999,999,999.99")))
					Else
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup:_vDup:TEXT), "@E 9999,999,999.99")))
					EndIf
			EndCase
		Next nY
		If nY <= 9
			For nY := 1 To 9
				AAdd(aAux, Space(20))
			Next nY
		EndIf
		AAdd(aFaturas, aAux)
	Next nX
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro transportadora                                                   �
//��������������������������������������������������������������������������
aTransp := {"","0","","","","","","","","","","","","","",""}

If Type("oTransp:_ModFrete")<>"U"
	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
EndIf
If Type("oTransp:_Transporta")<>"U"
	aTransp[01] := IIf(Type("oTransp:_Transporta:_xNome:TEXT")<>"U",NoChar(oTransp:_Transporta:_xNome:TEXT,lConverte),"")
	//	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
	If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99")
	EndIf
	aTransp[07] := IIf(Type("oTransp:_Transporta:_xEnder:TEXT")<>"U",NoChar(oTransp:_Transporta:_xEnder:TEXT,lConverte),"")
	aTransp[08] := IIf(Type("oTransp:_Transporta:_xMun:TEXT")<>"U",oTransp:_Transporta:_xMun:TEXT,"")
	aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT")<>"U",oTransp:_Transporta:_UF:TEXT,"")
	aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT")<>"U",oTransp:_Transporta:_IE:TEXT,"")
ElseIf Type("oTransp:_VEICTRANSP")<>"U"
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
EndIf
If Type("oTransp:_Vol")<>"U"
	If ValType(oTransp:_Vol) == "A"
		nX := nPrivate
		nLenVol := Len(oTransp:_Vol)
		For nX := 1 to nLenVol
			nXAux := nX
			nVolume += IIF(!Type("oTransp:_Vol[nXAux]:_QVOL:TEXT")=="U",Val(oTransp:_Vol[nXAux]:_QVOL:TEXT),0)
		Next nX
		aTransp[11]	:= AllTrim(str(nVolume))
		aTransp[12]	:= IIf(Type("oTransp:_Vol:_Esp")=="U","Diversos","")
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		If  Type("oTransp:_Vol[1]:_PesoB") <>"U"
			nPesoB := Val(oTransp:_Vol[1]:_PesoB:TEXT)
			aTransp[15] := AllTrim(str(nPesoB))
		EndIf
		If Type("oTransp:_Vol[1]:_PesoL") <>"U"
			nPesoL := Val(oTransp:_Vol[1]:_PesoL:TEXT)
			aTransp[16] := AllTrim(str(nPesoL))
		EndIf
	Else
		aTransp[11] := IIf(Type("oTransp:_Vol:_qVol:TEXT")<>"U",oTransp:_Vol:_qVol:TEXT,"")
		aTransp[12] := IIf(Type("oTransp:_Vol:_Esp")=="U","",oTransp:_Vol:_Esp:TEXT)
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT")<>"U",oTransp:_Vol:_PesoB:TEXT,"")
		aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT")<>"U",oTransp:_Vol:_PesoL:TEXT,"")
	EndIf
	aTransp[15] := strTRan(aTransp[15],".",",")
	aTransp[16] := strTRan(aTransp[16],".",",")
EndIf


//������������������������������������������������������������������������Ŀ
//�Volumes / Especie Nota de Saida                                         �
//�������������������������������������������������������������������������� 
If(MV_PAR04==2)     
	If !Empty(SF2->(FieldPos("F2_ESPECI1"))) .Or. !Empty(SF2->(FieldPos("SF2_ESPECI2"))) .Or. !Empty(SF2->(FieldPos("F2_ESPECI3"))) .Or. !Empty(SF2->(FieldPos("F2_ESPECI4")))
		aadd(aEspecie,SF2->F2_ESPECI1)
		aadd(aEspecie,SF2->F2_ESPECI2)
		aadd(aEspecie,SF2->F2_ESPECI3)
		aadd(aEspecie,SF2->F2_ESPECI4)
	EndIf 
	 
	nx :=0 
	For nE := 1 To Len(aEspecie)
		If !Empty(aEspecie[nE])
			nx ++   
			cEsp := aEspecie[nE]
		EndIf
	Next 
	
	If nx > 1
		cGuarda := "Diversos"
	Else
		cGuarda := cEsp
	EndIf
	
	If SF2->(FieldPos("F2_ESPECI1")) <>0 .Or. SF2->(FieldPos("F2_PLIQUI")) .Or. SF2->(FieldPos("F2_PBRUTO"))
	  	aadd(aEspVol,{cGuarda,Iif(SF2->F2_PLIQUI>0,str(SF2->F2_PLIQUI),""),Iif(SF2->F2_PBRUTO>0, str(SF2->F2_PBRUTO),"")})
	Endif 
EndIf
//������������������������������������������������������������������������Ŀ
//�Especie Nota de Entrada                                                 �
//��������������������������������������������������������������������������
If(MV_PAR04==1)     
	If !Empty(SF1->(FieldPos("F1_ESPECI1"))) .Or. !Empty(SF1->(FieldPos("SF1_ESPECI2"))) .Or. !Empty(SF1->(FieldPos("F1_ESPECI3"))) .Or. !Empty(SF1->(FieldPos("F1_ESPECI4")))
		aadd(aEspecie,SF1->F1_ESPECI1)
		aadd(aEspecie,SF1->F1_ESPECI2)
		aadd(aEspecie,SF1->F1_ESPECI3)
		aadd(aEspecie,SF1->F1_ESPECI4)
	EndIf 
	 
	nx :=0 
	For nE := 1 To Len(aEspecie)
		If !Empty(aEspecie[nE])
			nx ++   
			cEsp := aEspecie[nE]
		EndIf
	Next 
	
	If nx > 1
		cGuarda := "Diversos"
	Else
		cGuarda := cEsp
	EndIf
	
	If SF1->(FieldPos("F1_ESPECI1")) <>0 .Or. SF1->(FieldPos("F1_PLIQUI")) .Or. SF1->(FieldPos("F1_PBRUTO"))
	  	aadd(aEspVol,{cGuarda,Iif(SF1->F1_PLIQUI>0,str(SF1->F1_PLIQUI),""),Iif(SF1->F1_PBRUTO>0, str(SF1->F1_PBRUTO),"")})
	Endif 
EndIf

//������������Ŀ
//�Tipo do frete    �
//��������������
dbSelectArea("SD2")
dbSetOrder(3)
MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
dbSelectArea("SC5")
dbSetOrder(1)
MsSeek(xFilial("SC5")+SD2->D2_PEDIDO)

If SC5->C5_TPFRETE=="C"
	cModFrete := "0"
ElseIf SC5->C5_TPFRETE=="F"
	cModFrete := "1"
ElseIf SC5->C5_TPFRETE=="T"
	cModFrete := "2"
ElseIf SC5->C5_TPFRETE=="S"
	cModFrete := "9"
Else
	cModFrete := "1"
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro Dados do Produto / Servi�o                                       �
//��������������������������������������������������������������������������
nLenDet := Len(oDet)
For nX := 1 To nLenDet
	nPrivate := nX
	nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)//-Val(IIF(Type("oDet[nPrivate]:_Prod:_vDesc")=="U","",oDet[nX]:_Prod:_vDesc:TEXT))
	nQtd     := Val(oDet[nX]:_Prod:_qTrib:TEXT)
	nVUnit   := Val(oDet[nX]:_Prod:_vUnCom:TEXT)
	nBaseICM := 0
	nValICM  := 0
	nBaseICMST := 0
	nValICMST  := 0
	nValIPI  := 0
	nPICM    := 0
	nPIPI    := 0
	oImposto := oDet[nX]
	cSitTrib := ""
	If Type("oImposto:_Imposto")<>"U"
		If Type("oImposto:_Imposto:_ICMS")<>"U"
			nLenSit := Len(aSitTrib)
			For nY := 1 To nLenSit
				nPrivate2 := nY
				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
					If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT")<>"U"
						nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBC:TEXT"))
						nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
						nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_PICMS:TEXT"))
					EndIf
					cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_ORIG:TEXT")
					cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT")
					If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBCST:TEXT")<>"U" .And. Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_vICMSST:TEXT")<>"U"
						nBaseICMST := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBCST:TEXT"))
						nValICMST  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMSST:TEXT"))
            		EndIf	
				EndIf
			Next nY
		EndIf
		If Type("oImposto:_Imposto:_IPI")<>"U"
			If Type("oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
				nValIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
			EndIf
			If Type("oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
				nPIPI   := Val(oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
			EndIf
		EndIf
	EndIf
	aadd(aItens,{SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,12),;
	SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,MAXITEMC),;
	IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;
	cSitTrib,;
	oDet[nX]:_Prod:_CFOP:TEXT,;
	oDet[nX]:_Prod:_utrib:TEXT,;
	AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))),;
	AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],4))),;
	AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))),;
	AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))),;
	AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))),;
	AllTrim(TransForm(nValIPI,TM(nValIPI,TamSX3("D2_VALIPI")[1],TamSX3("D2_BASEIPI")[2]))),;
	AllTrim(TransForm(nPICM,"@r 99.99%")),;
	AllTrim(TransForm(nPIPI,"@r 99.99%")),;
	AllTrim(TransForm(nBaseICMST,TM(nBaseICMST,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))),;
	AllTrim(TransForm(nValICMST,TM(nValICMST,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))),;
	})
	cAuxItem	:= AllTrim(SubStr(oDet[nX]:_Prod:_cProd:TEXT,13))
	cAux 		:= AllTrim(SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),(MAXITEMC + 1)))	

    lPontilhado := .F.
	While !Empty(cAux) .Or. !Empty(cAuxItem)
		aadd(aItens,{SubStr(cAuxItem,1,11),;
		SubStr(cAux,1,MAXITEMC),;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;                                                         
		"",;
		"",;
		"",;
		""})
		cAux := SubStr(cAux,(MAXITEMC + 1)) 
		cAuxItem	:=	SubStr(cAuxItem,12)		
	    lPontilhado := .T.	
	EndDo
	
	If (Type("oNf:_infnfe:_det[nPrivate]:_Infadprod:TEXT") <> "U" .Or. Type("oNf:_infnfe:_det:_Infadprod:TEXT") <> "U") .And. lImpAnfav
		cAux := AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1))
		
		While !Empty(cAux)
			aadd(aItens,{"",;
			SubStr(cAux,1,MAXITEMC),;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			""})
			cAux := SubStr(cAux,(MAXITEMC + 1))
		    lPontilhado := .T.	
		EndDo
	EndIf

	If lPontilhado
		aadd(aItens,{Replicate("- ",12),;
					Replicate("- ",MAXITEMC),;
					Replicate("- ",15),;
					Replicate("- ",05),;
					Replicate("- ",05),;
					Replicate("- ",05),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",15),;
					Replicate("- ",10),;
					Replicate("- ",10)})
	EndIf

Next nX

//������������������������������������������������������������������������Ŀ
//�Quadro ISSQN                                                            �
//��������������������������������������������������������������������������
aISSQN := {"","","",""}
If Type("oEmitente:_IM:TEXT")<>"U"
	aISSQN[1] := oEmitente:_IM:TEXT
EndIf
If Type("oTotal:_ISSQNtot")<>"U"
	aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@ze 999,999,999.99")
	aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@ze 999,999,999.99")
	aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@ze 999,999,999.99")
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro de informacoes complementares                                    �
//��������������������������������������������������������������������������
aMensagem := {}
If Type("oIdent:_tpAmb:TEXT")<>"U" .And. oIdent:_tpAmb:TEXT=="2"
	cAux := "DANFE emitida no ambiente de homologa��o - SEM VALOR FISCAL"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf 

If Type("oNF:_InfNfe:_infAdic:_infAdFisco:TEXT")<>"U"
	cAux := oNF:_InfNfe:_infAdic:_infAdFisco:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT<>"4"
	cAux := "Protocolo: "+cCodAutSef
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT=="4" .AND. cModalidade $ "1"
	cAux := "Protocolo: "+cCodAutSef
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	cAux := "DANFE emitida anteriormente em conting�ncia DPEC"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If !Empty(cCodAutDPEC) .And. oIdent:_tpEmis:TEXT=="4"
	cAux := "N�mero de Registro DPEC: "+cCodAutDPEC
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If (Type("oIdent:_tpEmis:TEXT")<>"U" .And. !oIdent:_tpEmis:TEXT$"1,4")
	cAux := "DANFE emitida em conting�ncia"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (!Empty(cModalidade) .And. !cModalidade $ "1,4,5") .And. Empty(cCodAutSef)
	cAux := "DANFE emitida em conting�ncia devido a problemas t�cnicos - ser� necess�ria a substitui��o."
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (!Empty(cModalidade) .And. cModalidade $ "5" .And. oIdent:_tpEmis:TEXT=="4")
	cAux := "DANFE impresso em conting�ncia"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	cAux := "DPEC regularmento recebido pela Receita Federal do Brasil."
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (Type("oIdent:_tpEmis:TEXT")<>"U" .And. oIdent:_tpEmis:TEXT$"5")
	cAux := "DANFE emitida em conting�ncia FS-DA"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If Type("oNF:_InfNfe:_infAdic:_infCpl:TEXT")<>"U"
	cAux := oNF:_InfNfe:_infAdic:_InfCpl:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf
If SF1->F1_TIPO == "D"
	If Type("oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT")<>"U"
		cAux := "Valor do Ipi : " + oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT
		While !Empty(cAux)
			aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf
EndIf
If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
	If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
		aInfNf := oNF:_INFNFE:_IDE:_NFREF
	Else
		aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
	EndIf
	
	cAux1 := ""
	cAux2 := ""
	For Nx := 1 to Len(aInfNf)
		If Type("aInfNf["+Str(nX)+"]:_REFNFE:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNFE:TEXT)$cAux1
			If !"CHAVE"$Upper(cAux1)
				cAux1 += "Chave de acesso da NF-E referenciada: "
			EndIf
			cAux1 += aInfNf[nx]:_REFNFE:TEXT+","
		ElseIf Type("aInfNf["+Str(nX)+"]:_REFNF:_NNF:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNF:_NNF:TEXT)$cAux2
			If !"ORIGINAL"$Upper(cAux2)
				cAux2 += " Numero da nota original: "
			EndIf
			cAux2 += aInfNf[nx]:_REFNF:_NNF:TEXT+","
		EndIf
	Next
	
	cAux	:=	""
	If !Empty(cAux1)
		cAux1	:=	Left(cAux1,Len(cAux1)-1)
		cAux 	+= cAux1
	EndIf
	If !Empty(cAux2)
		cAux2	:=	Left(cAux2,Len(cAux2)-1)
		cAux 	+= 	Iif(!Empty(cAux),CRLF,"")+cAux2
	EndIf
	
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro "RESERVADO AO FISCO"                                             �
//��������������������������������������������������������������������������

aResFisco := {}
nBaseIcm  := 0

If GetNewPar("MV_BCREFIS",.F.) .And. SuperGetMv("MV_ESTADO")$"PR"
	If Val(&("oTotal:_ICMSTOT:_VBCST:TEXT")) <> 0
		cAux := "Substitui��o Tribut�ria: Art. 471, II e �1� do RICMS/PR: "
   		nLenDet := Len(oDet)
   		For nX := 1 To nLenDet
	   		oImposto := oDet[nX]
	   		If Type("oImposto:_Imposto")<>"U"
		 		If Type("oImposto:_Imposto:_ICMS")<>"U"
		 			nLenSit := Len(aSitTrib)
		 			For nY := 1 To nLenSit
		 				nPrivate2 := nY
		 				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
		 					If Type("oImposto:_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBCST:TEXT")<>"U"
		 		   				nBaseIcm := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBCST:TEXT"))
		 						cAux +=  oDet[nX]:_PROD:_CPROD:TEXT + ": BCICMS-ST R$" + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))) + " / "	
   		 	  				Endif
   		 	 			Endif
   					Next nY
   	   			Endif
   	 		Endif
   	  	Next nX
	Endif
	While !Empty(cAux)   
		aadd(aResFisco,SubStr(cAux,1,64))
  		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENL) > 1, 63, MAXMENL) +2)
   	EndDo	
Endif  
        
//������������������������������������������������������������������������Ŀ
//�Calculo do numero de folhas                                             �
//��������������������������������������������������������������������������

nFolhas := 1
nLenItens := Len(aItens)
nMsgCompl := Len(aMensagem)

nLen := nLenItens + Len(aMensagem)
If nLen > (MAXITEM + Min(Len(aMensagem), MAXMSG))
	nFolhas += Int((nLen - (MAXITEM + Min(Len(aMensagem), MAXMSG))) / 44)
	If Mod((nLen - (MAXITEM + Min(Len(aMensagem), MAXMSG))), 44) > 0
		nFolhas++
	EndIf
Else

	If Len(aMensagem) > MAXMSG
		nFolhas := nFolhas + 1
		nMsgCompl -= MAXMSG
		While nMsgCompl > 44
			nFolhas := nFolhas + 1
			nMsgCompl -= 44
		EndDo
	EndIf

EndIf  

//������������������������������������������������������������������������Ŀ
//�Inicializacao do objeto grafico                                         �
//��������������������������������������������������������������������������
If oDanfe == Nil
	
	lPreview := .T.
	oDanfe 	:= FWMSPrinter():New("DANFE", IMP_SPOOL)
	oDanfe:SetLandscape()
	oDanfe:Setup()
EndIf

//������������������������������������������������������������������������Ŀ
//�Preenchimento do Array de UF                                            �
//��������������������������������������������������������������������������
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})


//������������������������������������������������������������������������Ŀ
//�Inicializacao da pagina do objeto grafico                               �
//��������������������������������������������������������������������������
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX
nLine  := -42  
nBaseTxt := 180
nBaseCol := 70
/* Comando Say Utilizados
Say( nRow, nCol, cText, oFont, nWidth, cClrText, nAngle )
*/

DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,@nLine,@nBaseCol,@nBaseTxt,aUf)

//������������������������������������������������������������������������Ŀ
//�Quadro destinat�rio/remetente                                           �
//��������������������������������������������������������������������������
Do Case
	Case Type("oDestino:_CNPJ")=="O"
		cAux := TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	Case Type("oDestino:_CPF")=="O"
		cAux := TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99")
	OtherWise
		cAux := Space(14)
EndCase

nLine -= 8
//oDanfe:Box(nLine+197,nBaseCol,nLine+270,nBaseCol+30)
oDanfe:FillRect({nLine+198,nBaseCol,nLine+269,nBaseCol+30},oBrush)
oDanfe:Say(nLine+265,nBaseTxt+1,"DESTINATARIO /",oFont08N:oFont, , CLR_WHITE, 270 )
oDanfe:Say(nLine+260,nBaseTxt+11,"REMETENTE"     ,oFont08N:oFont, ,CLR_WHITE , 270 )

nBaseTxt += 30 
//oDanfe:Say(nLine+195,nBaseTxt,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(nLine+197,nBaseCol+30,nLine+222,542)
oDanfe:Say(nLine+205,nBaseTxt, "NOME/RAZ�O SOCIAL",oFont08N:oFont)
oDanfe:Say(nLine+215,nBaseTxt,NoChar(oDestino:_XNome:TEXT,lConverte),oFont08:oFont)
oDanfe:Box(nLine+197,542,nLine+222,MAXBOXH-40)
oDanfe:Box(nLine+197.5,542.5,nLine+220.5,MAXBOXH-41.5)//BOX NEGRITO
oDanfe:Say(nLine+205,552,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(nLine+215,552,cAux,oFont08:oFont)

oDanfe:Box(nLine+222,nBaseCol+30,nLine+247,402)
oDanfe:Say(nLine+230,nBaseTxt,"ENDERE�O",oFont08N:oFont)
oDanfe:Say(nLine+240,nBaseTxt,aDest[01],oFont08:oFont)
oDanfe:Box(nLine+222,402,nLine+247,602)
oDanfe:Say(nLine+230,412,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(nLine+240,412,aDest[02],oFont08:oFont)
oDanfe:Box(nLine+222,602,nLine+247,MAXBOXH-40)
oDanfe:Say(nLine+230,612,"CEP",oFont08N:oFont)
oDanfe:Say(nLine+240,612,aDest[03],oFont08:oFont)

oDanfe:Box(nLine+247,nBaseCol+30,nLine+270,302)
oDanfe:Say(nLine+255,nBaseTxt,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(nLine+265,nBaseTxt,aDest[05],oFont08:oFont)
oDanfe:Box(nLine+247,302,nLine+270,502)
oDanfe:Say(nLine+255,312,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(nLine+265,312,aDest[06],oFont08:oFont)
oDanfe:Box(nLine+247,502,nLine+270,542)
oDanfe:Say(nLine+255,512,"UF",oFont08N:oFont)
oDanfe:Say(nLine+265,512,aDest[07],oFont08:oFont)
oDanfe:Box(nLine+247,542,nLine+270,MAXBOXH-40)
oDanfe:Box(nLine+247.5,542.5,nLine+268.5,MAXBOXH-41.5)//BOX NEGRITO
oDanfe:Say(nLine+255,552,"INSCRI��O ESTADUAL",oFont08N:oFont)
oDanfe:Say(nLine+265,552,aDest[08],oFont08:oFont)

//nBaseTxt := 790 

oDanfe:Box(nLine+197,MAXBOXH-40,nLine+222,MAXBOXH+70)
oDanfe:Say(nLine+205,MAXBOXH-30,"DATA DE EMISS�O",oFont08N:oFont)
oDanfe:Say(nLine+215,MAXBOXH-30,ConvDate(oIdent:_DEmi:TEXT),oFont08:oFont)
oDanfe:Box(nLine+222,MAXBOXH-40,nLine+247,MAXBOXH+70)
oDanfe:Say(nLine+230,MAXBOXH-30,"DATA ENTRADA/SA�DA",oFont08N:oFont)
oDanfe:Say(nLine+240,MAXBOXH-30,Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) ),oFont08:oFont)
oDanfe:Box(nLine+247,MAXBOXH-40,nLine+272,MAXBOXH+70)
oDanfe:Say(nLine+255,MAXBOXH-30,"HORA ENTRADA/SA�DA",oFont08N:oFont)
oDanfe:Say(nLine+265,MAXBOXH-30,aHrEnt[01],oFont08:oFont)



//������������������������������������������������������������������������Ŀ
//�Quadro fatura                                                           �
//��������������������������������������������������������������������������
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
For nX := 1 To Len(aFaturas)
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][4])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][5])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][6])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][7])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][8])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][9])
	If nY >= 9
		nY := 0
	EndIf
Next nX
              
//������������������������������������������������������������������������Ŀ
//�Fatura / Duplicata                                                      �
//��������������������������������������������������������������������������
//nLine -= 3
nLine -= 5
nBaseTxt -= 30 
//oDanfe:Box(nLine+275,nBaseCol,nLine+310,nBaseCol+30)
oDanfe:FillRect({nLine+276,nBaseCol,nLine+309,nBaseCol+30},oBrush)

oDanfe:Say(nLine+305,nBaseTxt+7,"FATURA",oFont08N:oFont, ,CLR_WHITE , 270 )
nBaseTxt += 30 

nPos1Col := 0
nPos2Col := 0
For Nx := 1 to 8
	oDanfe:Box(nLine+275,nBaseCol+30+nPos1Col,nLine+310,nBaseCol+115.1+nPos2Col)
	nPos1Col += 84.1
	nPos2Col += 84.1
Next
//Ultimo Box
oDanfe:Box(nLine+275,nBaseCol+30+nPos1Col,nLine+310,MAXBOXH+70)


nColuna := nBaseCol+36
If Len(aFaturas) >0
	For nY := 1 To 9
		oDanfe:Say(nLine+287,nColuna,aAux[1][ny][1],oFont08:oFont)
		oDanfe:Say(nLine+296,nColuna,aAux[1][ny][2],oFont08:oFont)
		oDanfe:Say(nLine+305,nColuna,aAux[1][ny][3],oFont08:oFont)
		nColuna:= nColuna+84.1
	Next nY
Endif

//nLine -= 15
nLine -= 18
//������������������������������������������������������������������������Ŀ
//�Calculo do imposto                                                      �
//��������������������������������������������������������������������������
nBaseTxt -= 30 
//oDanfe:Box(nLine+328,nBaseCol,nLine+376,nBaseCol+30)
oDanfe:FillRect({nLine+329,nBaseCol,nLine+375,nBaseCol+30},oBrush)
oDanfe:Say(nLine+372,nBaseTxt,"CALCULO",oFont08N:oFont, ,CLR_WHITE , 270 )
oDanfe:Say(nLine+360,nBaseTxt+7,"DO",oFont08N:oFont, , CLR_WHITE, 270 )
oDanfe:Say(nLine+370,nBaseTxt+14,"IMPOSTO",oFont08N:oFont, , CLR_WHITE, 270 )
nBaseTxt += 30 

oDanfe:Box(nLine+328,nBaseCol+30,nLine+353,262)
oDanfe:Say(nLine+336,nBaseTxt,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
If cMVCODREG$"3" 
	oDanfe:Say(nLine+346,nBaseTxt,aTotais[01],oFont08:oFont)
Endif
oDanfe:Box(nLine+328,262,nLine+353,402)
oDanfe:Say(nLine+336,272,"VALOR DO ICMS",oFont08N:oFont)
If cMVCODREG$"3" 
	oDanfe:Say(nLine+346,272,aTotais[02],oFont08:oFont)
Endif
oDanfe:Box(nLine+328,402,nLine+353,557)
oDanfe:Say(nLine+336,412,"BASE DE CALCULO DO ICMS ST",oFont08N:oFont)
oDanfe:Say(nLine+346,412,aTotais[03],oFont08:oFont)
oDanfe:Box(nLine+328,557,nLine+353,697)
oDanfe:Say(nLine+336,567,"VALOR DO ICMS SUBSTITUI��O",oFont08N:oFont)
oDanfe:Say(nLine+346,567,aTotais[04],oFont08:oFont)
oDanfe:Box(nLine+328,697,nLine+353,MAXBOXH+70)
oDanfe:Say(nLine+336,707,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
oDanfe:Say(nLine+346,707,aTotais[05],oFont08:oFont)


oDanfe:Box(nLine+353,nBaseCol+30,nLine+378,232)
oDanfe:Say(nLine+361,nBaseTxt,"VALOR DO FRETE",oFont08N:oFont)
oDanfe:Say(nLine+371,nBaseTxt,aTotais[06],oFont08:oFont)
oDanfe:Box(nLine+353,232,nLine+378,352)
oDanfe:Say(nLine+361,242,"VALOR DO SEGURO",oFont08N:oFont)
oDanfe:Say(nLine+371,242,aTotais[07],oFont08:oFont)
oDanfe:Box(nLine+353,352,nLine+378,452)
oDanfe:Say(nLine+361,362,"DESCONTO",oFont08N:oFont)
oDanfe:Say(nLine+371,362,aTotais[08],oFont08:oFont)
oDanfe:Box(nLine+353,452,nLine+378,592)
oDanfe:Say(nLine+361,462,"OUTRAS DESPESAS ACESS�RIAS",oFont08N:oFont)
oDanfe:Say(nLine+371,462,aTotais[09],oFont08:oFont)
oDanfe:Box(nLine+353,592,nLine+378,712)
oDanfe:Say(nLine+361,602,"VALOR TOTAL DO IPI",oFont08N:oFont)
oDanfe:Say(nLine+371,602,aTotais[10],oFont08:oFont)
oDanfe:Box(nLine+353,712,nLine+378,MAXBOXH+70)
oDanfe:Say(nLine+361,722,"VALOR TOTAL DA NOTA",oFont08N:oFont)
oDanfe:Say(nLine+371,722,aTotais[11],oFont08:oFont)

nLine -= 3
//������������������������������������������������������������������������Ŀ
//�Transportador/Volumes transportados                                     �
//��������������������������������������������������������������������������
nBaseTxt -= 30 
//oDanfe:Box(nLine+379,nBaseCol,nLine+452,nBaseCol+30)
oDanfe:FillRect({nLine+380,nBaseCol,nLine+451,nBaseCol+30},oBrush)
oDanfe:Say(nLine+446,nBaseTxt   ,"TRANSPORTADOR/" ,oFont08N:oFont, , CLR_WHITE, 270 )
oDanfe:Say(nLine+438,nBaseTxt+7 ,"VOLUMES"        ,oFont08N:oFont, , CLR_WHITE, 270 )
oDanfe:Say(nLine+448,nBaseTxt+14,"TRANSPORTADOS"  ,oFont08N:oFont, , CLR_WHITE, 270 )
nBaseTxt += 30 

oDanfe:Box(nLine+379,nBaseCol+30,nLine+404,402)
oDanfe:Say(nLine+387,nBaseTxt,"RAZ�O SOCIAL",oFont08N:oFont)
oDanfe:Say(nLine+397,nBaseTxt,aTransp[01],oFont08:oFont)
oDanfe:Box(nLine+379,402,nLine+404,482)
oDanfe:Say(nLine+387,412,"FRETE POR CONTA",oFont08N:oFont)
If cModFrete =="0"
	oDanfe:Say(nLine+397,412,"0-EMITENTE",oFont08:oFont)
ElseIf cModFrete =="1"
	oDanfe:Say(nLine+397,412,"1-DEST/REM",oFont08:oFont)
ElseIf cModFrete =="2"
	oDanfe:Say(nLine+397,412,"2-TERCEIROS",oFont08:oFont)
ElseIf cModFrete =="9"
	oDanfe:Say(nLine+397,412,"9-SEM FRETE",oFont08:oFont)
Else
	oDanfe:Say(nLine+397,412,"",oFont08:oFont)
Endif
oDanfe:Box(nLine+379,482,nLine+404,562)
oDanfe:Say(nLine+387,492,"C�DIGO ANTT",oFont08N:oFont)
oDanfe:Say(nLine+397,492,aTransp[03],oFont08:oFont)
oDanfe:Box(nLine+379,562,nLine+404,652)
oDanfe:Say(nLine+387,572,"PLACA DO VE�CULO",oFont08N:oFont)
oDanfe:Say(nLine+397,572,aTransp[04],oFont08:oFont)
oDanfe:Box(nLine+379,652,nLine+404,702)
oDanfe:Say(nLine+387,662,"UF",oFont08N:oFont)
oDanfe:Say(nLine+397,662,aTransp[05],oFont08:oFont)
oDanfe:Box(nLine+379,702,nLine+404,MAXBOXH+70)
oDanfe:Say(nLine+387,712,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(nLine+397,712,aTransp[06],oFont08:oFont)

oDanfe:Box(nLine+404,nBaseCol+30,nLine+429,402)
oDanfe:Say(nLine+412,nBaseTxt,"ENDERE�O",oFont08N:oFont)
oDanfe:Say(nLine+422,nBaseTxt,aTransp[07],oFont08:oFont)
oDanfe:Box(nLine+404,402,nLine+429,652)
oDanfe:Say(nLine+412,412,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(nLine+422,412,aTransp[08],oFont08:oFont)
oDanfe:Box(nLine+404,652,nLine+429,702)
oDanfe:Say(nLine+412,662,"UF",oFont08N:oFont)
oDanfe:Say(nLine+422,662,aTransp[09],oFont08:oFont)
oDanfe:Box(nLine+404,702,nLine+429,MAXBOXH+70)
oDanfe:Say(nLine+412,712,"INSCRI��O ESTADUAL",oFont08N:oFont)
oDanfe:Say(nLine+422,712,aTransp[10],oFont08:oFont)

oDanfe:Box(nLine+429,nBaseCol+30,nLine+454,232)
oDanfe:Say(nLine+437,nBaseTxt,"QUANTIDADE",oFont08N:oFont)
oDanfe:Say(nLine+447,nBaseTxt,aTransp[11],oFont08:oFont)
oDanfe:Box(nLine+429,232,nLine+454,352)
oDanfe:Say(nLine+437,242,"ESPECIE",oFont08N:oFont)
oDanfe:Say(nLine+447,242,aEspVol[1][1],oFont08:oFont)
oDanfe:Box(nLine+429,352,nLine+454,472)
oDanfe:Say(nLine+437,362,"MARCA",oFont08N:oFont)
oDanfe:Say(nLine+447,362,aTransp[13],oFont08:oFont)
oDanfe:Box(nLine+429,472,nLine+454,592)
oDanfe:Say(nLine+437,482,"NUMERA��O",oFont08N:oFont)
oDanfe:Say(nLine+447,482,aTransp[14],oFont08:oFont)
oDanfe:Box(nLine+429,592,nLine+454,712)
oDanfe:Say(nLine+437,602,"PESO BRUTO",oFont08N:oFont)
oDanfe:Say(nLine+447,602,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
oDanfe:Box(nLine+429,712,nLine+454,MAXBOXH+70)
oDanfe:Say(nLine+437,722,"PESO LIQUIDO",oFont08N:oFont)
oDanfe:Say(nLine+447,722,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

//������������������������������������������������������������������������Ŀ
//�Calculo do ISSQN                                                        �
//��������������������������������������������������������������������������

nBaseTxt -= 30 
//oDanfe:Box(nLine+573,nBaseCol,nLine+597,nBaseCol+30)
oDanfe:FillRect({nLine+574,nBaseCol,nLine+596,nBaseCol+30},oBrush)
//oDanfe:Box(nLine+574,nBaseCol+1,nLine+596,nBaseCol+29)
oDanfe:Say(nLine+596,nBaseTxt+7,"ISSQN",oFont08N:oFont, , CLR_WHITE, 270 )
nBaseTxt += 30 

oDanfe:Box(nLine+573,nBaseCol+30,nLine+597,302)
oDanfe:Say(nLine+581,nBaseTxt,"INSCRI��O MUNICIPAL",oFont08N:oFont)
oDanfe:Say(nLine+591,nBaseTxt,aISSQN[1],oFont08:oFont)
oDanfe:Box(nLine+573,302,nLine+597,502)
oDanfe:Say(nLine+581,312,"VALOR TOTAL DOS SERVI�OS",oFont08N:oFont)
oDanfe:Say(nLine+591,312,aISSQN[2],oFont08:oFont)
oDanfe:Box(nLine+573,502,nLine+597,702)
oDanfe:Say(nLine+581,512,"BASE DE C�LCULO DO ISSQN",oFont08N:oFont)
oDanfe:Say(nLine+591,512,aISSQN[3],oFont08:oFont)
oDanfe:Box(nLine+573,702,nLine+597,MAXBOXH+70)
oDanfe:Say(nLine+581,712,"VALOR DO ISSQN",oFont08N:oFont)
oDanfe:Say(nLine+591,712,aISSQN[4],oFont08:oFont)


//������������������������������������������������������������������������Ŀ
//�Dados Adicionais                                                        �
//��������������������������������������������������������������������������
nPosMsg := 0
DanfeInfC(oDanfe,aMensagem,@nBaseTxt,@nBaseCol,@nLine,@nPosMsg,nFolha)

//������������������������������������������������������������������������Ŀ
//�Dados do produto ou servico                                             �
//��������������������������������������������������������������������������
aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][15])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][16])
	If nY >= 16
		nY := 0
	EndIf
Next nX
For nX := 1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")	
	If nY >= 16
		nY := 0
	EndIf
	
Next nX

aColProd := {}
DanfeIT(oDanfe,@nLine,@nBaseCol,@nBaseTxt,nFolha,nFolhas,@aColProd,aMensagem,nPosMsg)                    

lPag1 := .T.
lPag2 := .F.
lPagX := .F.
lInfoAd:= .F.

nFolha++
nLinha    :=nLine+478
nL:=0  

For nY := 1 To nLenItens
	nL++
	If lPag1
		If nL > MAXITEM .And. nFolha == 2
			oDanfe:EndPage()
			oDanfe:StartPage()
			nLinha    	:=	181

			DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,@nLine,@nBaseCol,@nBaseTxt,aUf)			
			DanfeIT(oDanfe,@nLine,@nBaseCol,@nBaseTxt,nFolha,nFolhas,@aColProd,aMensagem,nPosMsg)  
			If nPosMsg > 0
				DanfeInfC(oDanfe,aMensagem,@nBaseTxt,@nBaseCol,@nLine,@nPosMsg,nFolha)
				lInfoAd := .T.
			EndIf	
			nL :=0
			lPag1 := .F.
			lPag2 := .T.
			nLinha := 169
		Endif           
	Endif

	If lPag2  .And. lInfoAd
		If	nL > MAXITEMP4
			nFolha++
			oDanfe:EndPage()
			oDanfe:StartPage()
			nColLim		:=	Iif(!(nfolha-1)%2==0 .And. MV_PAR06==1,435,865)
			nLinha    	:=	181
			
			DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,@nLine,@nBaseCol,@nBaseTxt,aUf)			
			DanfeIT(oDanfe,@nLine,@nBaseCol,@nBaseTxt,nFolha,nFolhas,@aColProd,aMensagem,nPosMsg)  
			nLinha := 169
	
			nL:=0
			lPag2 := .F.
			lPagX := .T.      
			lInfoAd:= .F.
		EndIf
	Else
		If	nL > MAXITEMP2
			nFolha++
			oDanfe:EndPage()
			oDanfe:StartPage()
			nColLim		:=	Iif(!(nfolha-1)%2==0 .And. MV_PAR06==1,435,865)
			nLinha    	:=	181
			
			DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,@nLine,@nBaseCol,@nBaseTxt,aUf)			
			DanfeIT(oDanfe,@nLine,@nBaseCol,@nBaseTxt,nFolha,nFolhas,@aColProd,aMensagem,nPosMsg)  
			nLinha := 169
	
			nL:=0		
		EndIf
	EndIf

	oDanfe:Say(nLinha,aColProd[1][1]+1,aAux[1][1][nY],oFont07:oFont)
	oDanfe:Say(nLinha,aColProd[2][1]+1,aAux[1][2][nY],oFont07:oFont)
	oDanfe:Say(nLinha,aColProd[3][1]+1,aAux[1][3][nY],oFont07:oFont)
	oDanfe:Say(nLinha,aColProd[4][1]+1,aAux[1][4][nY],oFont07:oFont)
	oDanfe:Say(nLinha,aColProd[5][1]+1,aAux[1][5][nY],oFont07:oFont)
	oDanfe:Say(nLinha,aColProd[6][1]+1,aAux[1][6][nY],oFont07:oFont)
	oDanfe:SayAlign(nLinha-5,aColProd[7][1],aAux[1][7][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[8][1],aAux[1][8][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[9][1],aAux[1][9][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[10][1],aAux[1][10][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[11][1],aAux[1][15][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[12][1],aAux[1][11][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[13][1],aAux[1][16][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[14][1],aAux[1][12][nY],oFont07:oFont,45, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[15][1],aAux[1][13][nY],oFont07:oFont,25, 10, , 1,  )
	oDanfe:SayAlign(nLinha-5,aColProd[16][1],aAux[1][14][nY],oFont07:oFont,25, 10, , 1,  )

	nLinha :=nLinha + 10 
	
Next nY 
If nL <= MAXITEM .And. Len(aMensagem) > MAXMSG .And. nFolha == 2 .And. nLenItens <= MAXMSG
	oDanfe:EndPage()
	oDanfe:StartPage()
	nLinha    	:=	181                
	DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,@nLine,@nBaseCol,@nBaseTxt,aUf)
	DanfeIT(oDanfe,@nLine,@nBaseCol,@nBaseTxt,nFolha,nFolhas,@aColProd,aMensagem,nPosMsg)
	If nPosMsg > 0
		DanfeInfC(oDanfe,aMensagem,@nBaseTxt,@nBaseCol,@nLine,@nPosMsg,nFolha)
	EndIf
Endif   
   


//������������������������������������������������������������������������Ŀ
//�Finaliza a Impress�o                                                    �
//��������������������������������������������������������������������������
If lPreview
	//	oDanfe:Preview()
EndIf

oDanfe:EndPage()

Return(.T.)

                                                              
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DanfeCab  � Autor � Roberto Souza        � Data � 13/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do Cabecalho do documento.                       ���
���			 �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FAT/FIS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,nLine,nBaseCol,nBaseTxt,aUf)

Local aTamanho   := {}
//Local aUF		 := {}
Local nHPage     := 0
Local nVPage     := 0
Local nPosVOld   := 0
Local nPosH      := 0
Local nPosHOld   := 0
Local nAuxV      := 0
Local nAuxH      := 0
Local cChaveCont := ""
Local cDataEmi   := ""
Local cDigito    := ""
Local cTPEmis    := ""
Local cValIcm    := ""
Local cICMSp     := ""
Local cICMSs     := ""
Local cUF		 := ""
Local cCNPJCPF	 := ""
Local cLogo      := FisxLogo("1")
Local lConverte  := GetNewPar("MV_CONVERT",.F.)
Private oDPEC    := oNfeDPEC


Default cCodAutSef := ""
Default cCodAutDPEC:= ""
Default cDtHrRecCab:= ""
Default dDtReceb   := CToD("")

nLine    := -42
nBaseCol := 70

// PICOTE DO RECIBO
//oDanfe:Say(MAXBOXV, INIBOXH+80, Replicate("- ",500), oFont08N:oFont, , , 270 )
oDanfe:Say(000, INIBOXH+74, Replicate("- ",150), oFont08N:oFont, , , 90 )

oDanfe:Box(nLine+135, INIBOXH+10, MAXBOXV, INIBOXH+35)
If Len(oEmitente:_xNome:Text) >= 50
	oDanfe:Say(MAXBOXV-10, INIBOXH+20, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte), oFont07N:oFont, , , 270 )
	oDanfe:Say(MAXBOXV-10, INIBOXH+30, "OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07N:oFont, , , 270 )
Else
	oDanfe:Say(MAXBOXV-10, INIBOXH+20, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07N:oFont, , , 270 )
EndIf
	
oDanfe:Box(nLine+500,INIBOXH+35,MAXBOXV,INIBOXH+70)
oDanfe:Say(MAXBOXV-10, INIBOXH+45, "DATA DE RECEBIMENTO", oFont07N:oFont, , , 270)

oDanfe:Box(nLine+135,INIBOXH+35,nLine+500,INIBOXH+70)
oDanfe:Say(MAXBOXV-150, INIBOXH+45, "IDENTIFICA��O E ASSINATURA DO RECEBEDOR", oFont07N:oFont, , , 270)

oDanfe:Box(nLine+042, INIBOXH+10, nLine+135, INIBOXH+70)
oDanfe:Say(MAXBOXV-520, INIBOXH+20, "NF-e", oFont08N:oFont, , , 270)
oDanfe:Say(MAXBOXV-520, INIBOXH+35, "N� "+StrZero(Val(oIdent:_NNf:Text),9), oFont08N:oFont, , , 270)
oDanfe:Say(MAXBOXV-520, INIBOXH+45, "S�RIE "+oIdent:_Serie:Text, oFont08N:oFont, , , 270)


//������������������������������������������������������������������������Ŀ
//�Quadro 1 IDENTIFICACAO DO EMITENTE                                      �
//��������������������������������������������������������������������������

nBaseTxt := 180
oDanfe:Box(nLine+042,nBaseCol,nLine+139,450)
oDanfe:Say(nLine+057,nBaseTxt, "Identifica��o do emitente",oFont12N:oFont)
If len(oEmitente:_xNome:Text)>43
	oDanfe:Say(nLine+070,nBaseTxt,SubStr(NoChar(oEmitente:_xNome:Text,lConverte),1,45), oFont12N:oFont )
	oDanfe:Say(nLine+080,nBaseTxt,SubStr(NoChar(oEmitente:_xNome:Text,lConverte),46,45), oFont12N:oFont )
Else
	oDanfe:Say(nLine+070,nBaseTxt, NoChar(oEmitente:_xNome:Text,lConverte),oFont12N:oFont)
Endif
If len(oEmitente:_xNome:Text)>45
	oDanfe:Say(nLine+090,nBaseTxt, NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte)+", "+oEmitente:_EnderEmit:_Nro:Text,oFont08N:oFont)
Else
	oDanfe:Say(nLine+080,nBaseTxt, NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte)+", "+oEmitente:_EnderEmit:_Nro:Text,oFont08N:oFont)
Endif
If len(oEmitente:_xNome:Text)>45
	If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
		oDanfe:Say(nLine+100,nBaseTxt, "Complemento: " + NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte),oFont08N:oFont)
		oDanfe:Say(nLine+110,nBaseTxt, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		oDanfe:Say(nLine+120,nBaseTxt, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		oDanfe:Say(nLine+130,nBaseTxt, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLine+100,nBaseTxt, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		oDanfe:Say(nLine+110,nBaseTxt, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		oDanfe:Say(nLine+120,nBaseTxt, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf
	
Else
	If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
		oDanfe:Say(nLine+090,nBaseTxt, "Complemento: " + NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte),oFont08N:oFont)
		oDanfe:Say(nLine+100,nBaseTxt, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		oDanfe:Say(nLine+110,nBaseTxt, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		oDanfe:Say(nLine+120,nBaseTxt, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLine+090,nBaseTxt, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		oDanfe:Say(nLine+100,nBaseTxt, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		oDanfe:Say(nLine+110,nBaseTxt, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf
Endif


//������������������������������������������������������������������������Ŀ
//�Quadro 2                                                                �
//��������������������������������������������������������������������������

nBaseTxt := 460
oDanfe:Box(nLine+042,450,nLine+139,602)
oDanfe:Say(nLine+055,nBaseTxt, "DANFE",oFont18N:oFont)
oDanfe:Say(nLine+065,nBaseTxt, "DOCUMENTO AUXILIAR DA",oFont10:oFont)
oDanfe:Say(nLine+075,nBaseTxt, "NOTA FISCAL ELETR�NICA",oFont10:oFont)
oDanfe:Say(nLine+085,nBaseTxt, "0-ENTRADA",oFont10:oFont)
oDanfe:Say(nLine+095,nBaseTxt, "1-SA�DA"  ,oFont10:oFont)
oDanfe:Box(nLine+078,nBaseTxt+50,nLine+092,nBaseTxt+64)
oDanfe:Say(nLine+088,nBaseTxt+54, oIdent:_TpNf:Text,oFont10N:oFont)
oDanfe:Say(nLine+110,nBaseTxt,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
oDanfe:Say(nLine+120,nBaseTxt,"S�RIE "+oIdent:_Serie:Text,oFont10N:oFont)
oDanfe:Say(nLine+130,nBaseTxt,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//������������������������������������������������������������������������Ŀ
//�Logotipo                                     �
//��������������������������������������������������������������������������
If nfolha>=1
	oDanfe:SayBitmap(005,085,cLogo,080,026)
Endif

//������������������������������������������������������������������������Ŀ
//�Codigo de barra                                                         �
//��������������������������������������������������������������������������

nBaseTxt := 612
oDanfe:Box(nLine+042,602,nLine+088,MAXBOXH+70)
oDanfe:Box(nLine+075,602,nLine+077,MAXBOXH+70)
oDanfe:Box(nLine+077,602,nLine+110,MAXBOXH+70)
oDanfe:Box(nLine+105,602,nLine+139,MAXBOXH+70)
oDanfe:Say(nLine+097,nBaseTxt,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont10N:oFont)


If nFolha >= 1
	oDanfe:Say(nLine+087,nBaseTxt,"CHAVE DE ACESSO DA NF-E",oFont09N:oFont)
	nFontSize := 28
	oDanfe:Code128C(nLine+072,nBaseTxt,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
EndIf

If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
	cDataEmi := Substr(oNF:_InfNfe:_IDE:_DEMI:Text,9,2)
	cTPEmis  := "4"
	cValIcm  := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
	cDataEmi := Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2)
	cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
	cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
EndIf
If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
	If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
		cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
		If cUf == "99"
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		EndIf
	ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
		cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
		cCNPJCPF := STRZERO(val(cCNPJCPF),14)
	Else
		cCNPJCPF := ""
	EndIf
	cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
	cChaveCont := cChaveCont+Modulo11(cChaveCont)
EndIf

If Empty(cChaveCont)
	oDanfe:Say(nLine+117,nBaseTxt,"Consulta de autenticidade no portal nacional da NF-e",oFont10:oFont)
	oDanfe:Say(nLine+127,nBaseTxt,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont10:oFont)
Endif

If  !Empty(cCodAutDPEC)
	oDanfe:Say(nLine+117,nBaseTxt,"Consulta de autenticidade no portal nacional da NF-e",oFont10:oFont)
	oDanfe:Say(nLine+127,nBaseTxt,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont10:oFont)
Endif


If nFolha == 1
	If !Empty(cCodAutDPEC)
		nFontSize := 28
		oDanfe:Code128C(nLine+135,nBaseTxt,cCodAutDPEC, nFontSize )
	Endif
Endif

// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
	If nFolha == 1
		If !Empty(cChaveCont)
			nFontSize := 28
			oDanfe:Code128C(nLine+135,nBaseTxt,cChaveCont, nFontSize )
		EndIf
	Else
		If !Empty(cChaveCont)
			nFontSize := 28
			oDanfe:Code128C(nLine+135,nBaseTxt,cChaveCont, nFontSize )
		EndIf
	EndIf
EndIf



//������������������������������������������������������������������������Ŀ
//�Quadro 4   NATUREZA DA OPERACAO /  DADOS NFE / DPEC                     �
//��������������������������������������������������������������������������
nBaseTxt := nBaseCol + 10
oDanfe:Box(nLine+139,nBaseCol,nLine+164,602)
oDanfe:Box(nLine+139,602,nLine+164,MAXBOXH+70)

oDanfe:Say(nLine+148,nBaseTxt,"NATUREZA DA OPERA��O",oFont08N:oFont)
oDanfe:Say(nLine+158,nBaseTxt,oIdent:_NATOP:TEXT,oFont08:oFont)
If(!Empty(cCodAutDPEC))
	oDanfe:Say(nLine+128,610,"N�MERO DE REGISTRO DPEC",oFont08N:oFont)
	
Endif
If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
	oDanfe:Say(nLine+148,610,"PROTOCOLO DE AUTORIZA��O DE USO",oFont08N:oFont)
Endif
If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
	oDanfe:Say(nLine+148,610,"DADOS DA NF-E",oFont08N:oFont)
Endif
oDanfe:Say(nLine+158,610,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
nFolha++


//������������������������������������������������������������������������Ŀ
//�Quadro 5                                                                �
//��������������������������������������������������������������������������
oDanfe:Box(nLine+164,nBaseCol,nLine+189,350)
oDanfe:Box(nLine+164,350,nLine+189,602)
oDanfe:Box(nLine+164,602,nLine+189,MAXBOXH+70)
oDanfe:Say(nLine+172,nBaseTxt,"INSCRI��O ESTADUAL",oFont08N:oFont)
oDanfe:Say(nLine+180,nBaseTxt,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
oDanfe:Say(nLine+172,360,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
oDanfe:Say(nLine+180,362,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
oDanfe:Say(nLine+172,612,"CNPJ",oFont08N:oFont)
oDanfe:Say(nLine+180,612,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)

Return()
  


/*
Static Function Char2Pix(oDanfe,cTexto,oFont)
Local nX := 0
DEFAULT aUltChar2pix := {}
nX := aScan(aUltChar2pix,{|x| x[1] == cTexto .And. x[2] == oFont:oFont})

If nX == 0
	
	aadd(aUltChar2pix,{cTexto,oFont:oFont, oFont:GetTextWidht(cTexto) *(300/PixelX)})
	
	nX := Len(aUltChar2pix)
EndIf

Return(aUltChar2pix[nX][3])

Static Function Char2PixV(oDanfe,cChar,oFont)
Local nX := 0
DEFAULT aUltVChar2pix := {}

cChar := SubStr(cChar,1,1)
nX := aScan(aUltVChar2pix,{|x| x[1] == cChar .And. x[2] == oFont:oFont})
If nX == 0
	
	
	aadd(aUltVChar2pix,{cChar,oFont:oFont, oFont:GetTextWidht(cChar) *(300/PixelY)})
	
	nX := Len(aUltVChar2pix)
EndIf

Return(aUltVChar2pix[nX][3])
*/

Static Function GetXML(cIdEnt,aIdNFe,cModalidade)

Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local oWS
Local cRetorno   := ""
Local cProtocolo := ""
Local cRetDPEC   := ""
Local cProtDPEC  := ""
Local nX         := 0
Local nY         := 0
Local nL			 := 0
Local aRetorno   := {}
Local aResposta  := {}
Local aFalta     := {}
Local aExecute   := {}
Local nLenNFe
Local nLenWS
Local cDHRecbto  := ""
Local cDtHrRec   := ""
Local cDtHrRec1	 := ""
Local nDtHrRec1  := 0
Local lFlag      := .T.
Local dDtRecib	:=	CToD("")

Private oDHRecbto

If Empty(cModalidade)
	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf
EndIf
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN        := "TOTVS"
oWS:cID_ENT           := cIdEnt
oWS:oWSNFEID          := NFESBRA_NFES2():New()
oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
nLenNFe := Len(aIdNFe)
For nX := 1 To nLenNFe
	aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","","",CToD("")})
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nX][4]+aIdNfe[nX][5]
Next nX
oWS:nDIASPARAEXCLUSAO := 0
oWS:_URL := AllTrim(cURL)+"/NFeSBRA.apw"

If oWS:RETORNANOTASNX()
	If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
		For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
			cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
			cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
			cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
			If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
				cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
				cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
			EndIf
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				oDHRecbto		:= XmlParser(cDHRecbto,"","","")
				cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
				nDtHrRec1		:= RAT("T",cDtHrRec)
				
				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf
				dbSelectArea("SF2")
				dbSetOrder(1)
				If MsSeek(xFilial("SF2")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
						RecLock("SF2")
						SF2->F2_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
				dbSelectArea("SF1")
				dbSetOrder(1)
				If MsSeek(xFilial("SF1")+aIdNFe[nX][5]+aIdNFe[nX][4]+aIdNFe[nX][6]+aIdNFe[nX][7])
					If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
						RecLock("SF1")
						SF1->F1_HORA := cDtHrRec1
						MsUnlock()
					EndIf
				EndIf
			EndIf
			nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
			If nY > 0
				aRetorno[nY][1] := cProtocolo
				aRetorno[nY][2] := cRetorno
				aRetorno[nY][4] := cRetDPEC
				aRetorno[nY][5] := cProtDPEC
				aRetorno[nY][6] := cDtHrRec1
				aRetorno[nY][7] := dDtRecib
				
				aadd(aResposta,aIdNfe[nY])
			EndIf
			cRetDPEC := ""
			cProtDPEC:= ""
		Next nX
		For nX := 1 To Len(aIdNfe)
			If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
				aadd(aFalta,aIdNfe[nX])
			EndIf
		Next nX
		If Len(aFalta)>0
			aExecute := GetXML(cIdEnt,aFalta,@cModalidade)
		Else
			aExecute := {}
		EndIf
		For nX := 1 To Len(aExecute)
			nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
			If nY == 0
				aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
			Else
				aRetorno[nY][01] := aExecute[nX][01]
				aRetorno[nY][02] := aExecute[nX][02]
			EndIf
		Next nX
	EndIf
Else
	Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
EndIf

Return(aRetorno)


Static Function ConvDate(cData)
Local dData
cData  := StrTran(cData,"-","")
dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)
  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DANFE     �Autor  �Marcos Taranta      � Data �  10/01/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pega uma posi��o (nTam) na string cString, e retorna o      ���
���          �caractere de espa�o anterior.                               ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posi��o (nTam) for maior que o tamanho da string, ou for um valor
* inv�lido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espa�o anterior a posi��o e retorna a posi��o
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
* Caso n�o encontre nenhum caractere de espa�o, � retornado 0.
*/
nRetorno := 0

Return nRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DanfeIT   � Autor � Roberto Souza        � Data � 13/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do Box de Itens.                                 ���
���			 �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FAT/FIS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DanfeIT(oDanfe,nLine,nBaseCol,nBaseTxt,nFolha,nFolhas,aColProd,aMensagem,nPosMsg)  
Local Nx := 0
oBrush := TBrush():New( , CLR_BLACK )
If nFolha == 1
	nLine -= 2

	nBaseTxt -= 30 
//	oDanfe:Box(nLine+454,nBaseCol,nLine+575,nBaseCol+30)
	oDanfe:FillRect({nLine+455,nBaseCol,nLine+574,nBaseCol+30},oBrush)


	oDanfe:Say(nLine+568,nBaseTxt+7,"DADOS DO PRODUTO / SERVI�O",oFont08N:oFont, ,CLR_WHITE , 270 )
	nBaseTxt += 30 
	aColProd := {}
	AADD(aColProd,{nBaseCol+30,150}) //"COD. PROD"
	AADD(aColProd,{ 150,310 } )		// "DESCRI��O DO PRODUTOS/SERVI�OS"
	AADD(aColProd,{ 310,350 } )		// "NCM/SH"
	AADD(aColProd,{ 350,370 } )		// "CST"
	AADD(aColProd,{ 370,390 } )		// "CFOP"
	AADD(aColProd,{ 390,410 } )		// "UN"
	AADD(aColProd,{ 410,460 } )		// "QUANT."
	AADD(aColProd,{ 460,510 } )		// "V.UNITARIO"
	AADD(aColProd,{ 510,560 } )		// "VLR TOTAL"
	AADD(aColProd,{ 560,610 } )		// "BC.ICMS"
	AADD(aColProd,{ 610,660 } )		// "BC.ICMS ST"
	AADD(aColProd,{ 660,710 } )		// "VLR ICMS"
	AADD(aColProd,{ 710,760 } )		// "VLR ICMS ST"
	AADD(aColProd,{ 760,810 } )		// "VALOR IPI"
	AADD(aColProd,{ 810,840 } )		// "ICMS"
	AADD(aColProd,{ 840,870 } )		// "IPI"
	//AADD(aColProd,{ 810,870)		// "ALIQUOTA"

	oDanfe:Box(nLine+454,nBaseCol+31,nLine+574,MAXBOXH+70)
		
	oDanfe:Box(nLine+454,nBaseCol+30,nLine+469,150)
	oDanfe:Say(nLine+462,nBaseTxt-8,"COD. PROD",oFont08N:oFont)
	oDanfe:Box(nLine+454,150,nLine+469,310)
	oDanfe:Say(nLine+462,152,"DESCRI��O DO PRODUTOS/SERVI�OS",oFont08N:oFont)
	oDanfe:Box(nLine+454,310,nLine+469,350)
	oDanfe:Say(nLine+462,312,"NCM/SH",oFont08N:oFont)
	oDanfe:Box(nLine+454,350,nLine+469,370)
	oDanfe:Say(nLine+462,352,"CST",oFont08N:oFont)
	oDanfe:Box(nLine+454,370,nLine+469,390)
	oDanfe:Say(nLine+462,372,"CFOP",oFont08N:oFont)
	oDanfe:Box(nLine+454,390,nLine+469,410)
	oDanfe:Say(nLine+462,392,"UN",oFont08N:oFont)
	oDanfe:Box(nLine+454,410,nLine+469,460)
	oDanfe:Say(nLine+462,412,"QUANT.",oFont08N:oFont)
	oDanfe:Box(nLine+454,460,nLine+469,510)
	oDanfe:Say(nLine+462,462,"V.UNITARIO",oFont08N:oFont)
	oDanfe:Box(nLine+454,510,nLine+469,560)
	oDanfe:Say(nLine+462,512,"VLR TOTAL",oFont08N:oFont)
	oDanfe:Box(nLine+454,560,nLine+469,610)
	oDanfe:Say(nLine+462,562,"BC.ICMS",oFont08N:oFont)
	oDanfe:Box(nLine+454,610,nLine+469,660)
	oDanfe:Say(nLine+462,612,"BC.ICMS ST",oFont08N:oFont)
	oDanfe:Box(nLine+454,660,nLine+469,710)
	oDanfe:Say(nLine+462,662,"VLR ICMS",oFont08N:oFont)
	oDanfe:Box(nLine+454,710,nLine+469,760)
	oDanfe:Say(nLine+462,712,"VLR ICMS ST",oFont08N:oFont)
	oDanfe:Box(nLine+454,760,nLine+469,810)
	oDanfe:Say(nLine+462,762,"VALOR IPI",oFont08N:oFont)
	oDanfe:Box(nLine+454,810,nLine+469,840)
	oDanfe:Say(nLine+468,813,"ICMS",oFont08N:oFont)
	oDanfe:Box(nLine+454,840,nLine+469,870)
	oDanfe:Say(nLine+468,845,"IPI",oFont08N:oFont)
	oDanfe:Box(nLine+454,810,nLine+461,870)
	oDanfe:Say(nLine+460,818,"ALIQUOTA",oFont08N:oFont)
	
	For Nx :=1 to Len(aColProd)
		oDanfe:Box(nLine+469,aColProd[nx][1],nLine+575,aColProd[nx][2])	
	Next
Else

	If nPosMsg > 0
		nLine -= 265
	
	//	nBaseTxt -= 30 
	//	oDanfe:Box(nLine+454,nBaseCol,MAXBOXV,nBaseCol+30)
		oDanfe:FillRect({nLine+455,nBaseCol,397,nBaseCol+30},oBrush)
		oDanfe:Say(360,nBaseTxt+7,"DADOS DO PRODUTO / SERVI�O",oFont08N:oFont, , CLR_WHITE, 270 )
		nBaseTxt += 30 
		aColProd := {}
		AADD(aColProd,{nBaseCol+30,150}) //"COD. PROD"
		AADD(aColProd,{ 150,310 } )		// "DESCRI��O DO PRODUTOS/SERVI�OS"
		AADD(aColProd,{ 310,350 } )		// "NCM/SH"
		AADD(aColProd,{ 350,370 } )		// "CST"
		AADD(aColProd,{ 370,390 } )		// "CFOP"
		AADD(aColProd,{ 390,410 } )		// "UN"
		AADD(aColProd,{ 410,460 } )		// "QUANT."
		AADD(aColProd,{ 460,510 } )		// "V.UNITARIO"
		AADD(aColProd,{ 510,560 } )		// "VLR TOTAL"
		AADD(aColProd,{ 560,610 } )		// "BC.ICMS"
		AADD(aColProd,{ 610,660 } )		// "BC.ICMS ST"
		AADD(aColProd,{ 660,710 } )		// "VLR ICMS"
		AADD(aColProd,{ 710,760 } )		// "VLR ICMS ST"
		AADD(aColProd,{ 760,810 } )		// "VALOR IPI"
		AADD(aColProd,{ 810,840 } )		// "ICMS"
		AADD(aColProd,{ 840,870 } )		// "IPI"
		//AADD(aColProd,{ 810,870)		// "ALIQUOTA"
	
		oDanfe:Box(nLine+454,nBaseCol+31,398,MAXBOXH+70)
	
		nLineAlt := 454	
		nLineFim := 398				
		oDanfe:Box(nLine+nLineAlt,nBaseCol+30,nLine+469,150)
		oDanfe:Say(nLine+462,nBaseTxt-8,"COD. PROD",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,150,nLine+469,310)
		oDanfe:Say(nLine+462,152,"DESCRI��O DO PRODUTOS/SERVI�OS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,310,nLine+469,350)
		oDanfe:Say(nLine+462,312,"NCM/SH",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,350,nLine+469,370)
		oDanfe:Say(nLine+462,352,"CST",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,370,nLine+469,390)
		oDanfe:Say(nLine+462,372,"CFOP",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,390,nLine+469,410)
		oDanfe:Say(nLine+462,392,"UN",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,410,nLine+469,460)
		oDanfe:Say(nLine+462,412,"QUANT.",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,460,nLine+469,510)
		oDanfe:Say(nLine+462,462,"V.UNITARIO",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,510,nLine+469,560)
		oDanfe:Say(nLine+462,512,"VLR TOTAL",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,560,nLine+469,610)
		oDanfe:Say(nLine+462,562,"BC.ICMS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,610,nLine+469,660)
		oDanfe:Say(nLine+462,612,"BC.ICMS ST",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,660,nLine+469,710)
		oDanfe:Say(nLine+462,662,"VLR ICMS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,710,nLine+469,760)
		oDanfe:Say(nLine+462,712,"VLR ICMS ST",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,760,nLine+469,810)
		oDanfe:Say(nLine+462,762,"VALOR IPI",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,810,nLine+469,840)
		oDanfe:Say(nLine+468,813,"ICMS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,840,nLine+469,870)
		oDanfe:Say(nLine+468,845,"IPI",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,810,nLine+461,870)
		oDanfe:Say(nLine+460,818,"ALIQUOTA",oFont08N:oFont)
		
		For Nx :=1 to Len(aColProd)
			oDanfe:Box(nLine+469,aColProd[nx][1],nLineFim,aColProd[nx][2])	
		Next
		nLine -= 257

	Else 
	
		nLine -= 265
	
	//	nBaseTxt -= 30 
	//	oDanfe:Box(nLine+454,nBaseCol,MAXBOXV,nBaseCol+30)
		oDanfe:FillRect({nLine+455,nBaseCol,MAXBOXV-1,nBaseCol+30},oBrush)
		oDanfe:Say(nLine+768,nBaseTxt+7,"DADOS DO PRODUTO / SERVI�O",oFont08N:oFont, , CLR_WHITE, 270 )
		nBaseTxt += 30 
		aColProd := {}
		AADD(aColProd,{nBaseCol+30,150}) //"COD. PROD"
		AADD(aColProd,{ 150,310 } )		// "DESCRI��O DO PRODUTOS/SERVI�OS"
		AADD(aColProd,{ 310,350 } )		// "NCM/SH"
		AADD(aColProd,{ 350,370 } )		// "CST"
		AADD(aColProd,{ 370,390 } )		// "CFOP"
		AADD(aColProd,{ 390,410 } )		// "UN"
		AADD(aColProd,{ 410,460 } )		// "QUANT."
		AADD(aColProd,{ 460,510 } )		// "V.UNITARIO"
		AADD(aColProd,{ 510,560 } )		// "VLR TOTAL"
		AADD(aColProd,{ 560,610 } )		// "BC.ICMS"
		AADD(aColProd,{ 610,660 } )		// "BC.ICMS ST"
		AADD(aColProd,{ 660,710 } )		// "VLR ICMS"
		AADD(aColProd,{ 710,760 } )		// "VLR ICMS ST"
		AADD(aColProd,{ 760,810 } )		// "VALOR IPI"
		AADD(aColProd,{ 810,840 } )		// "ICMS"
		AADD(aColProd,{ 840,870 } )		// "IPI"
		//AADD(aColProd,{ 810,870)		// "ALIQUOTA"
	
		oDanfe:Box(nLine+454,nBaseCol+31,nLine+675,MAXBOXH+70)
	
		nLineAlt := 454		
		oDanfe:Box(nLine+nLineAlt,nBaseCol+30,nLine+469,150)
		oDanfe:Say(nLine+462,nBaseTxt-8,"COD. PROD",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,150,nLine+469,310)
		oDanfe:Say(nLine+462,152,"DESCRI��O DO PRODUTOS/SERVI�OS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,310,nLine+469,350)
		oDanfe:Say(nLine+462,312,"NCM/SH",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,350,nLine+469,370)
		oDanfe:Say(nLine+462,352,"CST",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,370,nLine+469,390)
		oDanfe:Say(nLine+462,372,"CFOP",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,390,nLine+469,410)
		oDanfe:Say(nLine+462,392,"UN",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,410,nLine+469,460)
		oDanfe:Say(nLine+462,412,"QUANT.",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,460,nLine+469,510)
		oDanfe:Say(nLine+462,462,"V.UNITARIO",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,510,nLine+469,560)
		oDanfe:Say(nLine+462,512,"VLR TOTAL",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,560,nLine+469,610)
		oDanfe:Say(nLine+462,562,"BC.ICMS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,610,nLine+469,660)
		oDanfe:Say(nLine+462,612,"BC.ICMS ST",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,660,nLine+469,710)
		oDanfe:Say(nLine+462,662,"VLR ICMS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,710,nLine+469,760)
		oDanfe:Say(nLine+462,712,"VLR ICMS ST",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,760,nLine+469,810)
		oDanfe:Say(nLine+462,762,"VALOR IPI",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,810,nLine+469,840)
		oDanfe:Say(nLine+468,813,"ICMS",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,840,nLine+469,870)
		oDanfe:Say(nLine+468,845,"IPI",oFont08N:oFont)
		oDanfe:Box(nLine+nLineAlt,810,nLine+461,870)
		oDanfe:Say(nLine+460,818,"ALIQUOTA",oFont08N:oFont)
		
		For Nx :=1 to Len(aColProd)
			oDanfe:Box(nLine+469,aColProd[nx][1],MAXBOXV,aColProd[nx][2])	
		Next
		nLine -= 257	
		
	EndIf	

EndIf


Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � DanfeInfC � Autor � Roberto Souza        � Data � 13/08/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do Box de Informa��es complementares.            ���
���			 �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FAT/FIS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DanfeInfC(oDanfe,aMensagem,nBaseTxt,nBaseCol,nLine,nPosMsg, nFolha )
Local Nx:= 0
Local Nw:= 0
oBrush := TBrush():New( , CLR_BLACK )

If nFolha ==1

	nBaseTxt -= 30 
	//oDanfe:Box(nLine+597,nBaseCol,MAXBOXV,nBaseCol+30)
	oDanfe:FillRect({nLine+598,nBaseCol,MAXBOXV-1,nBaseCol+30},oBrush)
	oBrush:End()
	
	oDanfe:Say(MAXBOXV-25,nBaseTxt+1,"DADOS",oFont08N:oFont, , CLR_WHITE, 270 )
	oDanfe:Say(MAXBOXV-13,nBaseTxt+11,"ADICIONAIS"    ,oFont08N:oFont, ,CLR_WHITE , 270 )
	nBaseTxt += 30 
	
	oDanfe:Box(nLine+597,nBaseCol+30,MAXBOXV,622)
	oDanfe:Say(nLine+606,nBaseTxt,"INFORMA��ES COMPLEMENTARES",oFont08N:oFont)
	
	
	nLenMensagens:= Len(aMensagem)
	nLin:= nLine+618
	
	For nX := 1 To Min(nLenMensagens, MAXMSG)
		oDanfe:Say(nLin,nBaseTxt,aMensagem[nX],oFont07:oFont)
		nLin:= nLin+10
	Next nX
	
	If Nx < nLenMensagens 
		nPosMsg := Nx
	EndIf 
	
	oDanfe:Box(nLine+597,622,MAXBOXV,MAXBOXH+70)
	oDanfe:Say(nLine+606,632,"RESERVADO AO FISCO",oFont08N:oFont)
	
	nLenMensagens:= Len(aResFisco)
	nLin:= nLine+618   
	For nX := 1 To Min(nLenMensagens, MAXMSG)
  		oDanfe:Say(nLin,632,aResFisco[nX],oFont08:oFont)
  		nLin:= nLin+10
	Next

ElseIf nFolha == 2
	nLine :=  0
	nBaseTxt -= 30 
	//oDanfe:Box(nLine+597,nBaseCol,MAXBOXV,nBaseCol+30)
	oDanfe:FillRect({nLine+398,nBaseCol,MAXBOXV-1,nBaseCol+30},oBrush)
	oBrush:End()
	
	oDanfe:Say(MAXBOXV-25,nBaseTxt+1,"DADOS",oFont08N:oFont, , CLR_WHITE, 270 )
	oDanfe:Say(MAXBOXV-13,nBaseTxt+11,"ADICIONAIS"    ,oFont08N:oFont, ,CLR_WHITE , 270 )
	nBaseTxt += 30 
	
	oDanfe:Box(nLine+397,nBaseCol+30,MAXBOXV,622)
	oDanfe:Say(nLine+406,nBaseTxt,"INFORMA��ES COMPLEMENTARES",oFont08N:oFont)
	
	
	nLenMensagens:= Len(aMensagem)
	nLin:= nLine+416
	
	For nX := nPosMsg To nLenMensagens
		oDanfe:Say(nLin,nBaseTxt,aMensagem[nX],oFont07:oFont)
		nLin:= nLin+10
		Nw++
		If Nw >= MAXMSG2
			Exit
		EndIf	
	Next nX
	
	nPosMsg := 0
	
	oDanfe:Box(nLine+397,622,MAXBOXV,MAXBOXH+70)
	oDanfe:Say(nLine+406,632,"RESERVADO AO FISCO",oFont08N:oFont)
	
EndIf	
Return() 

 /*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DANFE     �Autor  �Fabio Santana	     � Data �  04/10/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte caracteres espceiais						          ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/

STATIC FUNCTION NoChar(cString,lConverte) 

Default lConverte := .F.

If lConverte
	cString := (StrTran(cString,"&lt;","<"))  
	cString := (StrTran(cString,"&gt;",">"))
	cString := (StrTran(cString,"&amp;","&"))
	cString := (StrTran(cString,"&quot;",'"'))
	cString := (StrTran(cString,"&#39;","'"))
EndIf	
		
Return(cString)	

