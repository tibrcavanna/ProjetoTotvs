#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"


#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   022                                                // M�ximo de produtos para a primeira p�gina
#DEFINE MAXITEMP2 060                                                // M�ximo de produtos para as p�ginas adicionais
#DEFINE MAXITEMC  040                                                // M�xima de caracteres por linha de produtos/servi�os
#DEFINE MAXMENLIN 125                                                // M�ximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    010                                                // M�ximo de dados adicionais por p�gina

Static aUltChar2pix
Static aUltVChar2pix
//--------------------------------------------------------------
/*/{Protheus.doc} TFontEx
Classe auxiliar de TFont criada para otimizar a impress�o

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
Class TFontEx From LongClassName
	DATA cClassName
	DATA oFont
	DATA aFntWidth
	
	METHOD New() Constructor
	METHOD GetTextWidht()
EndClass
       
//--------------------------------------------------------------
/*/{Protheus.doc} New
M�todo contrutor da classe

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
METHOD New( oDanfe,cName,nWidth,nHeight,lBold,lUnderline,lItalic ) Class TFontEx
Local nX
	::cClassName := 'TFontEx'	
	// Cria fonte
	::oFont := TFont():New( cName,nWidth,nHeight,,lBold,,,,lUnderline,lItalic )

	// Alimenta vetor com as larguras desta fonte
	::aFntWidth := {}
	// Verifica binario para execu��o da rotina que retorna lagura da fonte
	If GetBuild() >= '7.00.081215P-20090316'
		//::aFntWidth := GetFontPixWidths( cName,Abs(nHeight),lBold,lItalic ) // OLD
	  oDanfe:GetFontWidths( ::oFont, ::aFntWidth )	
	Else
 		For nX := 1 To 255
	 		Aadd( ::aFntWidth, oDanfe:GetTextWidth(Chr(nX),::oFont) )
		Next  
	Endif
Return

//--------------------------------------------------------------
/*/{Protheus.doc} GetTextWidht
Retorna largura do texto baseado na fonte

@author  Ricardo Mansano
@since   26/05/2009
@version 10.1.1.4
/*/
//--------------------------------------------------------------
METHOD GetTextWidht( cTexto ) Class TFontEx
Local nX
Local nWidht := 0
Local      nLen   := Len( AllTrim( cTexto ) )

For nX := 1 to nLen
	nWidht += ::aFntWidth[ Asc( SubStr( cTexto, nX, 1 ) ) ]
next nX


Return( nWidht )


//------------------------//------------------------//------------------------

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

User Function PrtNfeSef(cIdEnt)

Local aArea     := GetArea()

Local oDanfe

oDanfe := TMSPrinter():New("DANFE - DOCUMENTO AUXILIAR DA NOTA FISCAL ELETR�NICA")
oDanfe:SetPortrait()
oDanfe:Setup()

Private PixelX := odanfe:nLogPixelX()
Private PixelY := odanfe:nLogPixelY()
	
RptStatus({|lEnd| DanfeProc(@oDanfe,@lEnd,cIdEnt)},"Imprimindo Danfe...")

If MV_PAR05==1 
	oDanfe:Preview()//Visualiza antes de imprimir
Else 
	oDanfe:Print()//Imprimir direto
EndIf

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

Static Function DanfeProc(oDanfe,lEnd,cIdEnt)

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

Local oNfe 
Local nLenNotas
Local lImpDir	 :=GetNewPar("MV_IMPDIR",.F.)
Local nLenarray	 := 0
Local nCursor	 := 0
Local lBreak	 := .F.

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
				    			If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4"
									RecLock("SF1")
									If !SF1->F1_FIMP$"D"
										SF1->F1_FIMP := "S"
									EndIf
									If SF1->(FieldPos("F1_CHVNFE"))>0
										SF1->F1_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)
									EndIf			    			   
									MsUnlock()
			    				EndIf				    			 
							Else
					    		dbSelectArea("SF2")
					    		dbSetOrder(1)
					    		If MsSeek(xFilial("SF2")+aNotas[nX][05]+aNotas[nX][04]+aNotas[nX][06]+aNotas[nX][07]) .And. cModalidade$"1,4"
									RecLock("SF2")
									If !SF2->F2_FIMP$"D"
										SF2->F2_FIMP := "S"
									EndIf
									If SF2->(FieldPos("F2_CHVNFE"))>0
										SF2->F2_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)       
									EndIf
									MsUnlock()
				    			EndIf
							EndIf
							dbSelectArea("SFT")
							dbSetOrder(1)
							If SFT->(FieldPos("FT_CHVNFE"))>0
								cChaveSFT	:=	(xFilial("SFT")+aNotas[nX][02]+aNotas[nX][04]+aNotas[nX][05]+aNotas[nX][06]+aNotas[nX][07])							
								MsSeek(cChaveSFT)
								Do While !(cAliasSFT)->(Eof ()) .And.;
									     cChaveSFT==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
									   RecLock("SFT")
									   SFT->FT_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)
								   	   MsUnLock()
								   	   DbSkip()
								EndDo							
	                        EndIf
							
							cAviso := ""
							cErro  := ""
							oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)					
							oNfeDPEC := XmlParser(aXML[nX][4],"_",@cAviso,@cErro)					
							If Empty(cAviso) .And. Empty(cErro)	
							    ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])					    
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
			    			If MsSeek(xFilial("SF1")+aNotas[nX][05]+aNotas[nX][04]) .And. SF1->(FieldPos("F1_FIMP"))<>0 .And. cModalidade$"1,4"
								Do While !Eof() .And. SF1->F1_DOC==aNotas[nX][05] .And. SF1->F1_SERIE==aNotas[nX][04]
							   		If SF1->F1_FORMUL=='S'
								   		RecLock("SF1")
										If !SF1->F1_FIMP$"D"
											SF1->F1_FIMP := "S"
										EndIf
										If SF1->(FieldPos("F1_CHVNFE"))>0
											SF1->F1_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)
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
									SF2->F2_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)       
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
								   	RecLock("SFT")
								   	SFT->FT_CHVNFE := SubStr(SpedNfeId(aXML[nX][2],"Id"),4)
							   	   	MsUnLock()
							   	   	DbSkip()
							   	EndIf
							   	DbSkip()	
							EndDo							
	      				EndIf															
	//-------------------------------										
						If Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==1 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="0") 	
						    ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])					    		
						
						ElseIf Empty(cAviso) .And. Empty(cErro) .And. MV_PAR04==2 .And. (oNfe:_NFE:_INFNFE:_IDE:_TPNF:TEXT=="1") 	
						    ImpDet(@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,aXml[nX][6])					
						
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
Static Function ImpDet(oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",09,09,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",07,07,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,07,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,06,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12

PrtDanfe(@oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

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
Static Function PrtDanfe(oDanfe,oNFE,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

Local aTamanho      := {}
Local aSitTrib      := {}
Local aTransp       := {}
Local aDest         := {}
Local aFaturas      := {}
Local aItens        := {}
Local aISSQN        := {}
Local aTotais       := {}
Local aAux          := {}
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
Local nTamanho      := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nItem         := 0
Local nMensagem     := 0
Local nBaseICM      := 0
Local nValICM       := 0
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
Local nLenFatura        
Local nLenVol  
Local nLenDet 
Local nLenSit     
Local nLenItens     := 0
Local nLenMensagens := 0
Local nLen          := 0

Default cDtHrRecCab:= ""

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
aDest := {oDestino:_EnderDest:_Xlgr:Text+IIF(", SN"$oDestino:_EnderDest:_Xlgr:Text,"",", "+oDestino:_EnderDest:_NRO:Text + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + oDestino:_EnderDest:_xcpl:Text)),;
			oDestino:_EnderDest:_XBairro:Text,;
			IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
			IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text),;//			oIdent:_DSaiEnt:Text,;
			oDestino:_EnderDest:_XMun:Text,;
			IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
			oDestino:_EnderDest:_UF:Text,;
			oDestino:_IE:Text,;
			""}
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
aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@ze 9,999,999.99")
aTotais[11] := 	Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@ze 999,999,999.99")	
//������������������������������������������������������������������������Ŀ
//�Quadro Faturas                                                          �
//��������������������������������������������������������������������������
If nFaturas > 0
	For nX := 1 To Min(3,nFaturas)
		aadd(aFaturas,{"TITULO","VENCTO","VALOR"})
	Next nX
	nLenFatura := Len(aFaturas)+1
	For nX := nLenFatura To 3
		aadd(aFaturas,{Space(20),Space(10),Space(14)})
	Next nX
	If nFaturas > 1
		For nX := 1 To Min(3,nFaturas)
			aadd(aFaturas,{oFatura:_Dup[nX]:_nDup:TEXT,ConvDate(oFatura:_Dup[nX]:_dVenc:TEXT),TransForm(Val(oFatura:_Dup[nX]:_vDup:TEXT),"@e 9999,999,999.99")})
		Next nX
	Else
		aadd(aFaturas,{oFatura:_Dup:_nDup:TEXT,ConvDate(oFatura:_Dup:_dVenc:TEXT),TransForm(Val(oFatura:_Dup:_vDup:TEXT),"@e 9999,999,999.99")})
	EndIf
EndIf
//������������������������������������������������������������������������Ŀ
//�Quadro transportadora                                                   �
//��������������������������������������������������������������������������
aTransp := {"","0","","","","","","","","","","","","","",""}
                                   
If Type("oTransp:_ModFrete")<>"U"
	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
EndIf
If Type("oTransp:_Transporta")<>"U"
	aTransp[01] := IIf(Type("oTransp:_Transporta:_xNome:TEXT")<>"U",oTransp:_Transporta:_xNome:TEXT,"")
//	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
	If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99")
	EndIf
	aTransp[07] := IIf(Type("oTransp:_Transporta:_xEnder:TEXT")<>"U",oTransp:_Transporta:_xEnder:TEXT,"")
	aTransp[08] := IIf(Type("oTransp:_Transporta:_xMun:TEXT")<>"U",oTransp:_Transporta:_xMun:TEXT,"")
	aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT")<>"U",oTransp:_Transporta:_UF:TEXT,"")
	aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT")<>"U",oTransp:_Transporta:_IE:TEXT,"")
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
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",oTransp:_Vol:_Marca:TEXT)
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
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",oTransp:_Vol:_Marca:TEXT)
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT")<>"U",oTransp:_Vol:_PesoB:TEXT,"")
		aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT")<>"U",oTransp:_Vol:_PesoL:TEXT,"")		
    EndIf
    aTransp[15] := strTRan(aTransp[15],".",",")
    aTransp[16] := strTRan(aTransp[16],".",",")    
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
	aadd(aItens,{oDet[nX]:_Prod:_cProd:TEXT,;
					SubStr(oDet[nX]:_Prod:_xProd:TEXT,1,MAXITEMC),;
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
					AllTrim(TransForm(nPIPI,"@r 99.99%"))})
	cAux := AllTrim(SubStr(oDet[nX]:_Prod:_xProd:TEXT,(MAXITEMC + 1)))
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
					""})
		cAux := SubStr(cAux,(MAXITEMC + 1))
	EndDo
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

If Type("oIdent:_tpAmb:TEXT")<>"U" .And. oIdent:_tpAmb:TEXT=="2"
	cAux := "DANFE emitida no ambiente de homologa��o - SEM VALOR FISCAL"
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
 
If Type("oNF:_INFNFE:_IDE:_NFREF:_REFNF:_NNF:TEXT")<>"U" 
	cAux := "Numero da nota original : " + oNF:_INFNFE:_IDE:_NFREF:_REFNF:_NNF:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf


//������������������������������������������������������������������������Ŀ
//�Calculo do numero de folhas                                             �
//��������������������������������������������������������������������������
nFolhas := 1
nLenItens := Len(aItens)
nLen := nLenItens + Len(aMensagem)
If nLen > (MAXITEM + Min(Len(aMensagem), MAXMSG))
	nFolhas += Int((nLen - (MAXITEM + Min(Len(aMensagem), MAXMSG))) / MAXITEMP2)
	If Mod((nLen - (MAXITEM + Min(Len(aMensagem), MAXMSG))), MAXITEMP2) > 0
		nFolhas++
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Inicializacao do objeto grafico                                         �
//��������������������������������������������������������������������������
If oDanfe == Nil
	lPreview := .T.
	oDanfe 	:= TMSPrinter():New("DANFE - Documento Auxiliar da Nota Fiscal Eletr�nica")
	oDanfe:SetPortrait()
	oDanfe:Setup()
EndIf
//������������������������������������������������������������������������Ŀ
//�Inicializacao da pagina do objeto grafico                               �
//��������������������������������������������������������������������������
oDanfe:StartPage()
oDanfe:SetPaperSize(9)
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX

//������������������������������������������������������������������������Ŀ
//�Definicao do Box - Recibo de entrega                                    �
//��������������������������������������������������������������������������
aTamanho := ImpBox(0,0,0,nHPage-Char2Pix(oDanfe,Repl("X",22),oFont10N),;
	{	{"RECEBEMOS DE "+oEmitente:_xNome:Text+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO"},;
		{{"DATA DE RECEBIMENTO"," "},{"IDENTIFICA��O E ASSINATURA DO RECEBEDOR",PadR(" ",200)}}},;
	oDanfe)
	
aTamanho := ImpBox(0,nHPage-Char2Pix(oDanfe,Repl("X",20),oFont10N),0,nHPage,;
	{	{{PadC("NF-e",20),PadC("N. "+StrZero(Val(oIdent:_NNf:Text),9),20),PadC("S�RIE "+oIdent:_Serie:Text,20)}}},;
		oDanfe,2)

nPosV    := aTamanho[1]+(VBOX/2)
oDanfe:Line(nPosV,HMARGEM,nPosV,nHPage) 
nPosV    += (VBOX/2)
nPosV := DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)
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
aTamanho := ImpBox(nPosV,0,0,nHPage-Char2Pix(oDanfe,Repl("X",22),oFont08),;
	{	{{"NOME/RAZ�O SOCIAL",oDestino:_XNome:TEXT},{"CNPJ/CPF",cAux}},;
		{{"ENDERE�O",aDest[01]},{"BAIRRO/DISTRITO",aDest[02]},{"CEP",aDest[03]}},;
		{{"MUNICIPIO",aDest[05]},{"FONE/FAX",aDest[06]},{"UF",aDest[07]},{"INSCRI��O ESTADUAL",aDest[08]}}},;
	oDanfe,1,"DESTINAT�RIO/REMETENTE")
	
aTamanho := ImpBox(nPosV,nHPage-Char2Pix(oDanfe,Repl("X",20),oFont08),0,nHPage,;
	{	{{"DATA DE EMISS�O",ConvDate(oIdent:_DEmi:TEXT)}},;
		{{"DATA ENTRADA/SA�DA", Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) )  }},;
		{{"HORA ENTRADA/SA�DA",aDest[09]}}},;
	oDanfe,1,"")
nPosV    := aTamanho[1]+VSPACE
//������������������������������������������������������������������������Ŀ
//�Quadro fatura                                                           �
//��������������������������������������������������������������������������
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
nLenFatura := Len(aFaturas)
For nX := 1 To nLenFatura
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	If nY >= 9
		nY := 0
	EndIf
Next nX

aTamanho := ImpBox(nPosV,0,0,nHPage,aAux,oDanfe,1,"FATURA")
nPosV    := aTamanho[1]+VSPACE
//������������������������������������������������������������������������Ŀ
//�Calculo do imposto                                                      �
//��������������������������������������������������������������������������
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"BASE DE CALCULO DO ICMS",aTotais[01]},{"VALOR DO ICMS",aTotais[02]},{"BASE DE CALCULO DO ICMS SUBSTITUI��O",aTotais[03]},{"VALOR DO ICMS SUBSTITUI��O",aTotais[04]},{"VALOR TOTAL DOS PRODUTOS",aTotais[05]}},;
		{{"VALOR DO FRETE",aTotais[06]},{"VALOR DO SEGURO",aTotais[07]},{"DESCONTO",aTotais[08]},{"OUTRAS DESPESAS ACESS�RIAS",aTotais[09]},{"VALOR DO IPI",aTotais[10]},{"VALOR TOTAL DA NOTA",aTotais[11]}}},;
	oDanfe,1,"CALCULO DO IMPOSTO")
nPosV    := aTamanho[1]+VSPACE
//������������������������������������������������������������������������Ŀ
//�Transportador/Volumes transportados                                     �
//��������������������������������������������������������������������������
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"RAZ�O SOCIAL",aTransp[01]},{"FRETE POR CONTA","0-EMITENTE/1-DESTINATARIO [" + aTransp[02] + "]"},{"C�DIGO ANTT",aTransp[03]},{"PLACA DO VE�CULO",aTransp[04]},{"UF",aTransp[05]},{"CNPJ/CPF",aTransp[06]}},;
		{{"ENDERE�O",aTransp[07]},{"MUNICIPIO",aTransp[08]},{"UF",aTransp[09]},{"INSCRI��O ESTADUAL",aTransp[10]}},;
		{{"QUANTIDADE",aTransp[11]},{"ESPECIE",aTransp[12]},{"MARCA",aTransp[13]},{"NUMERA��O",aTransp[14]},{"PESO BRUTO",aTransp[15]},{"PESO LIQUIDO",aTransp[16]}}},;
	oDanfe,1,"TRANSPORTADOR/VOLUMES TRANSPORTADOS")

nPosV    := aTamanho[1]+VSPACE
//������������������������������������������������������������������������Ŀ
//�Dados do produto ou servico                                             �
//��������������������������������������������������������������������������
aAux := {{{"COD.PROD."},{"DESCRI��O DO PRODUTO/SERVI�O"},{"NCM/SH"},{"CST"},{"CFOP"},{"UN"},{"QUANTIDADE"},{"V.UNITARIO"},{"V.TOTAL"},;
		{"BC.ICMS"},{"V.ICMS"},{"V.IPI"},{"A.ICM"},{"A.IPI"}}}
nY := 0
nLenItens := Len(aItens)
For nX := 1 To MIN(MAXITEM,nLenItens)
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][02])
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
	If nY >= 14
		nY := 0
	EndIf
Next nX
For nX := MIN(MAXITEM,nLenItens) To MAXITEM
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
	If nY >= 14
		nY := 0
	EndIf	
Next nX

aTamanho := ImpBox(nPosV,0,0,nHPage,;
	aAux,;
	oDanfe,3,"DADOS DO PRODUTO / SERVI�O",{"L","L","L","L","L","L","R","R","R","R","R","R","R","R"},0,;
	{.T., .F., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T.})
	
//�������������������������������������Ŀ
//�Pontilhado entre os produtos/servi�os�
//���������������������������������������
// Monta o pontilhado
If Len(aAux) > 0
	If Len(aAux[1]) > 1
		If Len(aAux[1][2]) > 3
			// 3 pois com apenas uma linha de produtos o array ter� 3, uma para o cabe�alho dos campos, uma linha do produto em si e outra em branco
			// Calcula a posi��o vertical do pontilhado (utiliza-se oFont08 para o calculo pois na fun��o ImpBox � a fonte usada neste box
			nAuxV := nPosV + ((Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE) * 3)
			For nX := 3 To Len(aAux[1][2])
				nAuxV += SAYVSPACE
				If !Empty(aAux[1][1][nX]) .And. Empty(aAux[1][1][nX - 1])
					// Estamos tratando um novo produto com uma linha de descri��o de um produto anterior antes dele
					// Escreve o pontilhado
					For nY := HMARGEM To nHPage
						oDanfe:Say(nAuxV, nY, ".", oFont08:oFont)
						nY += 20
					Next nY
				EndIf
				nAuxV += (Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE * 2)
			Next nX
		EndIf
	EndIf
EndIf

nPosV    := aTamanho[1]+VSPACE
//������������������������������������������������������������������������Ŀ
//�Calculo do ISSQN                                                        �
//��������������������������������������������������������������������������
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{{"INSCRI��O MUNICIPAL",aISSQN[1]},{"VALOR TOTAL DOS SERVI�OS",aISSQN[2]},{"BASE DE C�LCULO DO ISSQN",aISSQN[3]},{"VALOR DO ISSQN",aISSQN[4]}}},;
	oDanfe,1,"C�LCULO DO ISSQN")
nPosV    := aTamanho[1]+VSPACE
//������������������������������������������������������������������������Ŀ
//�Dados Adicionais                                                        �
//��������������������������������������������������������������������������
nPosVOld := nPosV+(VSPACE/2)
nPosV += VBOX*4
nPosHOld := HMARGEM
nPosH    := nHPage
	oDanfe:Say(nPosVOld,nPosHold,"DADOS ADICIONAIS",oFont11N:oFont)
nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	oDanfe:Box(nPosVOld,nPosHOld,nVPage,nPosH)
	nAuxH := nPosHOld+010
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont11N),nAuxH,"INFORMA��ES COMPLEMENTARES",oFont11N:oFont)	
	nAuxH := (nHPage/2)+10
	oDanfe:Box(nPosVOld,nAuxH+305,nVPage,nPosH)
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont07N),nAuxH+320,"RESERVADO AO FISCO",oFont11N:oFont)	
	nAuxH := nPosHOld+010
	nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
	nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	nLenMensagens := Len(aMensagem)
	nMensagem := 1
	For nX := nMensagem To Min(nLenMensagens, MAXMSG)
		nPosVOld += Char2PixV(oDanfe,"X",oFont12)*2
		oDanfe:Say(nPosVOld,nAuxH,aMensagem[nX],oFont12:oFont)
		nMensagem++
	Next nX
//������������������������������������������������������������������������Ŀ
//�Finalizacao da pagina do objeto grafico                                 �
//��������������������������������������������������������������������������
oDanfe:EndPage()
nItem := MAXITEM+1
nLenItens := Len(aItens)
nLenMensagens := Len(aMensagem)
While nItem <= nLenItens .Or. nMensagem <= nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)
EndDo
//������������������������������������������������������������������������Ŀ
//�Finaliza a Impress�o                                                    �
//�������������������������������������������������������������������������� 
If lPreview
	oDanfe:Preview()
EndIf
Return(.T.)

//������������������������������������������������������������������������Ŀ
//�Definicao do Cabecalho do documento                                     �
//��������������������������������������������������������������������������
Static Function DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

Local aTamanho   := {}
Local aUF		 := {}
Local cLogo      := FisxLogo("1")
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

Private oDPEC    :=oNfeDPEC

Default cCodAutSef := ""
Default cCodAutDPEC:= ""
Default cDtHrRecCab:= ""

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

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
//������������������������������������������������������������������������Ŀ
//�Quadro 1                                                                �
//��������������������������������������������������������������������������
nPosVOld := nPosV
nPosV    := nPosV + 380
nPosHOld := HMARGEM
nPosH    := 1128
	//oDanfe:Box(nPosVOld,nPosHOld,nPosV,nPosH)
	oDanfe:SayBitmap(nPosVOld+5,nPosHOld+5,cLogo,300,090)	
	nAuxV := nPosVOld + SAYVSPACE
    nAuxH := nPosHOld+SAYHSPACE+320
	oDanfe:Say(nAuxV,nAuxH,"identifica��o do Emitente",oFont08N:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE+100	
	oDanfe:Say(nAuxV,nAuxH,oEmitente:_xNome:Text,oFont08N:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE
	oDanfe:Say(nAuxV,nAuxH,oEmitente:_EnderEmit:_xLgr:Text+", "+oEmitente:_EnderEmit:_Nro:Text,oFont10:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE
	If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
	    oDanfe:Say(nAuxV,nAuxH,"Complemento: " + oEmitente:_EnderEmit:_xCpl:TEXT,oFont10:oFont)
		nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE
	EndIf
	oDanfe:Say(nAuxV,nAuxH,oEmitente:_EnderEmit:_xBairro:Text+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont10:oFont)
	nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE
	oDanfe:Say(nAuxV,nAuxH,oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont10:oFont)  
	nAuxV += Char2PixV(oDanfe,"X",oFont08N)+SAYVSPACE
	oDanfe:Say(nAuxV,nAuxH,"Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont10:oFont)
//������������������������������������������������������������������������Ŀ
//�Quadro 2                                                                �
//��������������������������������������������������������������������������
nPosHOld := nPosH+HSPACE
nPosH    := nPosHOld + 360
nAuxV := nPosVOld
oDanfe:Say(nAuxV,nPosHOld,"DANFE",oFont18N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont18N) + (SAYVSPACE*3)
nAuxH := nPosHOld
oDanfe:Say(nAuxV,nAuxH,"DOCUMENTO AUXILIAR DA",oFont07:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont08) + SAYVSPACE
oDanfe:Say(nAuxV,nAuxH,"NOTA FISCAL ELETR�NICA",oFont07:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont08) + SAYVSPACE
oDanfe:Say(nAuxV+10,nAuxH,"0-ENTRADA",oFont08:oFont)
oDanfe:Say(nAuxV+40,nAuxH,"1-SA�DA"  ,oFont08:oFont)
oDanfe:Box(nAuxV+10,nAuxH+170,nAuxV+50,nAuxH+210)
oDanfe:Say(nAuxV+15,nAuxH+180,oIdent:_TpNf:Text,oFont08:oFont)
nAuxV += 10
//oDanfe:Say(nAuxV,nAuxH,IIf(oIdent:_TpNf:Text=="1","SA�DA","ENTRADA"),oFont18N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont18N) + (SAYVSPACE*3)
oDanfe:Say(nAuxV,nAuxH,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont11) + SAYVSPACE
oDanfe:Say(nAuxV,nAuxH,"S�RIE "+oIdent:_Serie:Text,oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont11) + SAYVSPACE
oDanfe:Say(nAuxV,nAuxH,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
nAuxV += Char2PixV(oDanfe,"X",oFont11) + SAYVSPACE
nPosHOld := nPosH+HSPACE
nPosH    := nHPage
//oDanfe:Box(nPosVOld,nPosHOld,nPosV,nPosH) 
//������������������������������������������������������������������������Ŀ
//�Codigo de barra                                                         �
//��������������������������������������������������������������������������
If nFolha == 1
	oDanfe:Box(260,1448,nPosV,nPosH) 
	oDanfe:Box(260,1108,nPosV,nPosH) 
	oDanfe:Box(510,1448,nPosV,nPosH) 
	oDanfe:Box(420,1448,nPosV,nPosH) 
	oDanfe:Box(520,1448,nPosV,nPosH) 
	MSBAR3("CODE128",2.4*(300/PixelY),12.4*(299/PixelX),SubStr(oNF:_InfNfe:_ID:Text,4),oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
	oDanfe:Say(430,1463,"CHAVE DE ACESSO DA NF-E",oFont07N:oFont)	
	oDanfe:Say(450,1463,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont10N:oFont)		
Else
	oDanfe:Box(030,1448,nPosV,nPosH) 
	oDanfe:Box(030,1108,nPosV,nPosH) 
	oDanfe:Box(260,1448,nPosV,nPosH) 
	oDanfe:Box(180,1448,nPosV,nPosH)
	oDanfe:Box(270,1448,nPosV,nPosH) 	 
	MSBAR3("CODE128",0.37*(300/PixelY),12.4*(299/PixelX),SubStr(oNF:_InfNfe:_ID:Text,4),oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)
	oDanfe:Say(200,1463,"CHAVE DE ACESSO DA NF-E",oFont07N:oFont)	
	oDanfe:Say(225,1463,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont10N:oFont)	
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

If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
	If nFolha == 1
		If !Empty(cChaveCont)
			MSBAR3("CODE128",4.5*(300/PixelY),12.4*(300/PixelX),cChaveCont,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)	
		EndIf
	Else
		If !Empty(cChaveCont)	
			MSBAR3("CODE128",2.4*(300/PixelY),12.4*(300/PixelX),cChaveCont,oDanfe,/*lCheck*/,/*Color*/,/*lHorz*/,.02960,0.9,/*lBanner*/,/*cFont*/,"C",.F.)	
		EndIf
	EndIf		
Else
	If nFolha == 1
		oDanfe:Say(560,1463,"Consulta de autenticidade no portal nacional da NF-e",oFont10:oFont)	
		oDanfe:Say(590,1463,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont10:oFont)		
	Else
		oDanfe:Say(300,1463,"Consulta de autenticidade no portal nacional da NF-e",oFont10:oFont)	
		oDanfe:Say(330,1463,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont10:oFont)			
	EndIf
EndIf

//������������������������������������������������������������������������Ŀ
//�Quadro 4                                                                �
//��������������������������������������������������������������������������
nPosV += VSPACE
aTamanho := ImpBox(nPosV,0,0,nHPage,;
	{	{	{"NATUREZA DA OPERA��O",oIdent:_NATOP:TEXT},;
			{IIF(!Empty(cCodAutDPEC),"N�MERO DE REGISTRO DPEC",IIF(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1","PROTOCOLO DE AUTORIZA��O DE USO",IIF((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25","DADOS DA NF-E",""))),;
			IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999")))}},;
		{	{"INSCRI��O ESTADUAL",IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,"")},;
			{"INSC.ESTADUAL DO SUBST.TRIB.",IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,"")},;
			{"CNPJ",TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99"))}}},;
	oDanfe)
	
nPosV := aTamanho[1]

nFolha++      
Return(nPosV)

//������������������������������������������������������������������������Ŀ
//�Impressao do Complemento da NFe                                         �
//��������������������������������������������������������������������������
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)

Local nAuxV         := 0
Local nX            := 0
Local nY            := 0
Local nHPage        := 0 
Local nVPage        := 0 
Local nPosV         := VMARGEM
Local aAux          := {}
Local nLenItens     := Len(aItens)
Local nLenMensagens := Len(aMensagem)
Local nItemOld	    := nItem
Local nMensagemOld  := nMensagem
Local nForItens     := 0
Local nForMensagens := 0
Local lItens        := .F.
Local lMensagens    := .F.

If (nLenItens - (nItemOld - 1)) > 0
	lItens := .T.
EndIf
If (nLenMensagens - (nMensagemOld - 1)) > 0
	lMensagens := .T.
EndIf

oDanfe:StartPage()
nPosV := DanfeCab(oDanfe,nPosV,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab)
//������������������������������������������������������������������������Ŀ
//�Dados do produto ou servico                                             �
//��������������������������������������������������������������������������
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes() 
nVPage *= (300/PixelY)
nVPage -= VBOX
nPosV  += (VBOX/2)
//������������������������������������������������������������������������Ŀ
//�Dados do produto ou servico                                             �
//��������������������������������������������������������������������������
aAux := {{{"COD.PROD."},{"DESCRI��O DO PRODUTO/SERVI�O"},{"NCM/SH"},{"CST"},{"CFOP"},{"UN"},{"QUANTIDADE"},{"V.UNITARIO"},{"V.TOTAL"},;
		{"BC.ICMS"},{"V.ICMS"},{"V.IPI"},{"A.ICM"},{"A.IPI"}}}
nY := 0
nForItens := Min(nLenItens, MAXITEMP2 + (nItemOld - 1) - Min(nLenMensagens - (nMensagemOld - 1), Int(MAXITEMP2 / 2)))
For nX := nItem To nForItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][02])
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
	If nY >= 14
		nY := 0
	EndIf
	nItem++
Next nX

If lItens
	aTamanho := ImpBox(nPosV,0,Iif(lMensagens, 0, nVPage),nHPage,;
		aAux,;
		oDanfe,3,"DADOS DO PRODUTO / SERVI�O",{"L","L","L","L","L","L","R","R","R","R","R","R","R","R"},0,;
		{.T., .F., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T.})
	
	//�������������������������������������Ŀ
	//�Pontilhado entre os produtos/servi�os�
	//���������������������������������������
	// Monta o pontilhado
	If Len(aAux) > 0
		If Len(aAux[1]) > 1
			If Len(aAux[1][2]) > 3
				// 3 pois com apenas uma linha de produtos o array ter� 3, uma para o cabe�alho dos campos, uma linha do produto em si e outra em branco
				// Calcula a posi��o vertical do pontilhado (utiliza-se oFont08 para o calculo pois na fun��o ImpBox � a fonte usada neste box
				nAuxV := nPosV + ((Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE) * 3)
				For nX := 3 To Len(aAux[1][2])
					nAuxV += SAYVSPACE
					If !Empty(aAux[1][1][nX]) .And. Empty(aAux[1][1][nX - 1])
						// Estamos tratando um novo produto com uma linha de descri��o de um produto anterior antes dele
						// Escreve o pontilhado
						For nY := HMARGEM To nHPage
							oDanfe:Say(nAuxV, nY, ".", oFont08:oFont)
							nY += 20
						Next nY
					EndIf
					nAuxV += (Char2PixV(oDanfe, "X", oFont08) + SAYVSPACE * 2)
				Next nX
			EndIf
		EndIf
	EndIf
	
	nPosV := aTamanho[1]+VSPACE
EndIf

//������������������
//�Dados Adicionais�
//������������������
If lMensagens
	nPosVOld := nPosV+(VSPACE/2)
	nPosV += VBOX*4
	nPosHOld := HMARGEM
	nPosH    := nHPage
	oDanfe:Say(nPosVOld,nPosHold,"DADOS ADICIONAIS",oFont11N:oFont)
	nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
	nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	oDanfe:Box(nPosVOld,nPosHOld,nVPage,nPosH)
	nAuxH := nPosHOld+010
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont11N),nAuxH,"INFORMA��ES COMPLEMENTARES",oFont11N:oFont)
	nAuxH := (nHPage/2)+10
	oDanfe:Box(nPosVOld,nAuxH+305,nVPage,nPosH)
	oDanfe:Say(nPosVOld+Char2PixV(oDanfe,"X",oFont07N),nAuxH+320,"RESERVADO AO FISCO",oFont11N:oFont)
	nAuxH := nPosHOld+010
	nPosV    += Char2PixV(oDanfe,"X",oFont11N)*2
	nPosVOld += Char2PixV(oDanfe,"X",oFont11N)*2
	nLenMensagens := Len(aMensagem)
	nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1) - (nItem - nItemOld))
	For nX := nMensagem To nForMensagens
		nPosVOld += Char2PixV(oDanfe,"X",oFont12)*2
		oDanfe:Say(nPosVOld,nAuxH,aMensagem[nX],oFont12:oFont)
		nMensagem++
	Next nX
EndIf

//������������������������������������������������������������������������Ŀ
//�Finalizacao da pagina do objeto grafico                                 �
//��������������������������������������������������������������������������
oDanfe:EndPage()
Return(.T.)

Static Function Char2Pix(oDanfe,cTexto,oFont)
Local nX := 0
DEFAULT aUltChar2pix := {}
nX := aScan(aUltChar2pix,{|x| x[1] == cTexto .And. x[2] == oFont:oFont})

If nX == 0
	
	//aadd(aUltChar2pix,{cTexto,oFont:oFont,oDanfe:GetTextWidht(cTexto,oFont)*(300/PixelX)})
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
                                                                    
	//aadd(aUltVChar2pix,{cChar,oFont:oFont,oDanfe:GetTextWidht(cChar,oFont)*(300/PixelY)})
	aadd(aUltVChar2pix,{cChar,oFont:oFont, oFont:GetTextWidht(cChar) *(300/PixelY)})

	nX := Len(aUltVChar2pix)
EndIf

Return(aUltVChar2pix[nX][3])


Static Function GetXML(cIdEnt,aIdNFe,cModalidade)

Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local oWS
Local cRetorno   := ""
Local cProtocolo := ""
Local cRetDPEC   := ""
Local cProtDPEC  := ""
Local nX         := 0
Local nY         := 0
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
	aadd(aRetorno,{"","",aIdNfe[nX][4]+aIdNfe[nX][5],"","",""}) 
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
			    cDtHrRec		:= oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT
			    nDtHrRec1		:= RAT("T",cDtHrRec)
	
				If nDtHrRec1 <> 0
					cDtHrRec1 := SubStr(cDtHrRec,nDtHrRec1+1)
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
EndIf

Return(aRetorno)

Static Function ConvDate(cData)

Local dData
cData  := StrTran(cData,"-","")
dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)

Static Function ImpBox(nPosVIni,nPosHIni,nPosVFim,nPosHFim,aImp,oDanfe,nTpFont,cTitulo,aAlign,nColAjuste,aColAjuste)

Local aTamanho      := {}
Local nX            := 0
Local nY            := 0
Local nZ            := 0
Local nLenColAjuste := 0
Local nMaxnX        := Len(aImp)
Local nMaxnY        := 0
Local nMaxnZ        := 0
Local nPosV1        := nPosVIni
Local nPosV2        := nPosVIni
Local nPosH1        := nPosHIni
Local nPosH2        := nPosHIni
Local nAuxH         := 0
Local nAuxV         := 0
Local nTam          := 0
Local nDif          := 0
Local nMaxTam       := 0
//Local cMaxTam       := ""
Local aFont         := {{oFont07N,oFont08},{oFont10N,oFont11},{oFont11N,oFont12}}
Local lTitulo       := .T.
Local lTemTit       := .F.
Local nCharPix
Local nLenAlign
Local nForAlign
Local nLenTam

DEFAULT nTpFont    := 1
DEFAULT aAlign     := {}
DEFAULT nColAjuste := 0
/**
 * Caso o nColAjuste seja 0, este array ter� quais campos ir�o receber o ajuste
 * de tamanho, utilizando booleano para cada coluna do box.
 */
DEFAULT aColAjuste := {}

For nX := 1 To nMaxnX

	nMaxnY  := Len(aImp[nX])
	nPosV1  := IIF(nPosV1 == 0 , VMARGEM , nPosV1 )
	nPosV2  := nPosV1 + VBOX	
	
	/**
	 * O array � limpo para as pr�ximas dimens�es.
	 */
	aTamanho := {}
	
	/**
	 * Completa o array de ajuste de colunas de acordo com o n�mero de posi��es
	 * que o array de dados possui.
	 */
	If Len(aColAjuste) < nMaxnY
		For nY := (Len(aColAjuste) + 1) To nMaxnY
			AAdd(aColAjuste, .T.)
		Next nY
	EndIf
	
	//----------------------------------------
	// [TODO - Confirmar l�gica]
	// Foi alterado para aumentar performance
	//----------------------------------------
	/*
	For nY := 1 To nMaxnY
		If Len(aAlign) < nY
			aadd(aAlign,"L")
		EndIf
	Next nY
	*/	              
	/**
	 * Popula o array de alinhamentos para bater o n�mero de posi��es com o array
	 * de dados.
	 * Adiciona alinhamentos a esquerda ("L") para tanto.
	 */
	nLenAlign := Len(aAlign)
	nForAlign := (nMaxnY - nLenAlign)
	If nForAlign > 0
		For nY := 1 To nForAlign
			aadd(aAlign,"L")
		Next nY
	Endif 
	//----------------------------------------
	
	/**
	 * Popula as posi��es vazias do array aTamanho com o tamanho flex�vel que o
	 * Box ter�, caso o n�mero de posi��es dele n�o bata com o n�mero de posi��es
	 * do array aImp.
	 */
	For nY := 1 To nMaxnY
		If Valtype(aImp[nX][nY]) == "A"
			nMaxnZ := Len(aImp[nX][nY])
			nMaxTam := 0 //cMaxTam:= ""
			For nZ := 1 To nMaxnZ
				If nMaxTam < (oDanfe:GetTextWidth(aImp[nX][nY][nZ], aFont[nTpFont][IIf(nZ==1, 1, 2)]:oFont) + HSPACE * 2) //cMaxTam < Len(AllTrim(aImp[nX][nY][nZ]))
					nMaxTam := oDanfe:GetTextWidth(aImp[nX][nY][nZ], aFont[nTpFont][IIf(nZ==1, 1, 2)]:oFont) + HSPACE * 2 //cMaxTam := AllTrim(aImp[nX][nY][nZ])
				EndIf
			Next nZ
			//aadd(aTamanho,(Char2Pix(oDanfe,cMaxTam,aFont[nTpFont][2])+HSPACE+IIF(nZ>1,SAYVSPACE*nTpFont,-1*SAYVSPACE)))
			AAdd(aTamanho, nMaxTam)
		Else
			//aadd(aTamanho,(Char2Pix(oDanfe,aImp[nX][nY],aFont[nTpFont][2])+HSPACE))
			AAdd(aTamanho, oDanfe:GetTextWidth(aImp[nX][nY], aFont[nTpFont][2]:oFont) + HSPACE * 2)
		EndIf
	Next nY
    /**
     * Caso o tamanho de cada coluna somados n�o de o tamanho total da p�gina,
     * o espa�o restante � ou distribuido igualmente entre as colunas (caso
     * nColAjuste == 0) ou na coluna especificada na vari�vel nColAjuste.
     */
    nTam := 0
    nLenTam := Len(aTamanho)
    For nY := 1 To nLenTam
		nTam += aTamanho[nY]
	Next nY	
	If nTam <= (nPosHFim - nPosHIni)
		If nColAjuste == 0
			nLenColAjuste := 0
			For nY := 1 To Len(aColAjuste)
				If aColAjuste[nY]
					nLenColAjuste++
				EndIf
			Next nY
			nDif := Int(((nPosHFim - nPosHIni - IIF(nPosHIni == 0 , HMARGEM , nPosHIni )) - nTam) / nLenColAjuste)
			nLenTam := Len(aTamanho)
		    For nY := 1 To nLenTam
		    	If aColAjuste[nY]
					aTamanho[nY] += nDif
				EndIf
			Next nY
		Else
			nDif := Int(((nPosHFim - nPosHIni - IIF(nPosHIni == 0 , HMARGEM , nPosHIni )) - nTam))
			aTamanho[nColAjuste] += nDif
		EndIf
	EndIf
	
	/**
	 * Desenha o(s) box(es) e a(s) informa��o(�es).
	 */
	For nY := 1 To nMaxnY
		nPosH1 := IIF(nPosH1 == 0 , HMARGEM , nPosH1 )
		If cTitulo <> Nil .And. lTitulo
			lTitulo := .F.
			lTemTit := .T.
			oDanfe:Say(nPosV1,nPosH1,cTitulo,aFont[nTpFont][1]:oFont)	

			nCharPix := Char2PixV(oDanfe,"X",aFont[nTpFont][1])+SAYVSPACE
			nPosV1 += nCharPix 
			nPosV2 += nCharPix
		EndIf		
		If Valtype(aImp[nX][nY]) == "A"

			nMaxnZ := Len(aImp[nX][nY])
			If nY == nMaxnY
				nPosH2 := nPosHFim
				If nMaxnY > 1
					nPosH1 := Max(nPosH1,nPosHFim-aTamanho[nY])
				EndIf
			Else
				nPosH2 := Min(nPosHFim,nPosH1+aTamanho[nY])
			EndIf

			If nMaxnZ >= 2 .And. nY == 1
				If nPosVFim <> 0
					nPosV2 := nPosVFim
				Else
					nAuxV := 0
					For nZ := 1 To nMaxnZ
						nAuxV += Char2PixV(oDanfe,"X",aFont[nTpFont][IIf(nZ==1,1,2)])+IIF(nZ>1,SAYVSPACE*nTpFont,-1*SAYVSPACE)
					Next nZ
					nAuxV := Int(nAuxV/(VBOX + VSPACE))
					nPosV2 += (VBOX + VSPACE)*nAuxV
				EndIf
			EndIf
			oDanfe:Box(nPosV1,nPosH1,nPosV2,nPosHFim)
			If aAlign[nY] == "R"
				nAuxH := nPosH2 - HSPACE
			Else
				nAuxH := nPosH1 + SAYHSPACE
			EndIf
			nAuxV := nPosV1
			For nZ := 1 To nMaxnZ									
				nAuxV += Char2PixV(oDanfe,"X",aFont[nTpFont][IIf(nZ==1,1,2)])+IIF(nZ>1,SAYVSPACE*nTpFont,-1*SAYVSPACE)
				
				/**
				 * Trata o tag [ e ].
				 */
				cInf := ""
				cBox := ""
				
				If At("[", aImp[nX][nY][nZ]) > 0 .And. At("]", aImp[nX][nY][nZ]) > 0 .And. (At("]", aImp[nX][nY][nZ]) - At("[", aImp[nX][nY][nZ])) > 0
					If At("[", aImp[nX][nY][nZ]) > 1
						cInf := Substr(aImp[nX][nY][nZ], 1, At("[", aImp[nX][nY][nZ]) - 1)
					EndIf
					cBox := Substr(aImp[nX][nY][nZ], At("[", aImp[nX][nY][nZ]) + 1, At("]", aImp[nX][nY][nZ]) - At("[", aImp[nX][nY][nZ]) - 1)
				Else
					cInf := aImp[nX][nY][nZ]
				EndIf
				
				If aAlign[nY] == "R"
					oDanfe:Say(nAuxV,;
						nAuxH - (oDanfe:GetTextWidth(aImp[nX][nY][nZ], aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + IIf(!Empty(cBox), oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 4, 0)),;
						aImp[nX][nY][nZ],;
						aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					If !Empty(cBox)    // Monta o box caso exista
						oDanfe:Box(nAuxV - VSPACE,;
							nAuxH - (oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 3),;
							nAuxV + oDanfe:GetTextHeight("X", aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + VSPACE,;
							nAuxH - HSPACE)
						oDanfe:Say(nAuxV, nAuxH - (oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 2), cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					EndIf
				Else
					oDanfe:Say(nAuxV,nAuxH,cInf,aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					If !Empty(cBox)    // Monta o box caso exista
						oDanfe:Box(nAuxV - VSPACE,;
							nAuxH + oDanfe:GetTextWidth(cInf, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE,;
							nAuxV + oDanfe:GetTextHeight("X", aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + VSPACE,;
							nAuxH + oDanfe:GetTextWidth(cInf, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE + oDanfe:GetTextWidth(cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 2)
						oDanfe:Say(nAuxV, nAuxH + oDanfe:GetTextWidth(cInf, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont) + HSPACE * 2, cBox, aFont[nTpFont][IIf(nZ==1,1,2)]:oFont)
					EndIf
				EndIf
			Next nZ
			nPosH1 := nPosH2
		Else
			If nY == nMaxnY
				nPosH2 := nPosHFim
			Else
				nPosH2 := Min(nPosHFim,aTamanho[nY])
			EndIf
			
			oDanfe:Box(nPosV1,nPosH1,nPosV2,nPosHFim)
			If aAlign[nY] == "R"
				nAuxH := nPosH2 - Char2Pix(oDanfe,aImp[nX][nY],aFont[nTpFont][2]) - HSPACE
			Else
				nAuxH := nPosH1 + SAYHSPACE
			EndIf
			nAuxV := nPosV1+Char2PixV(oDanfe,aImp[nX][nY],aFont[nTpFont][2])
			oDanfe:Say(nAuxV,nAuxH,aImp[nX][nY],aFont[nTpFont][2]:oFont)
			nPosH1 := nPosH2
		EndIf
    Next nY
    nPosV1 := nPosV2 + IIF(lTemTit,0,VSPACE)
    nPosV2 := 0
    nPosH1 := nPosHIni
    nPosH2 := 0
Next nX

Return({nPosV1,nPosH1})

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
