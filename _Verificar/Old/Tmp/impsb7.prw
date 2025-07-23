#Include "PROTHEUS.Ch"
#include "topconn.ch"
#INCLUDE "RWMAKE.CH" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FGEN009  ³ Autor ³ Mauro Nagata          ³ Data ³ 19/12/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para leitura de arquivo CSV com codigo e          ³±±
±±³          ³ descricao do produto                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function IMPSB7()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg
Local oCombo
Local cLine
Local cArq		 := SPACE(100)
Local cCombo	 := ''
Local lContinua  := .T.
Local lErrorFile := .F.
Local nZ		 := 0
Local nI		 := 0
Local nFileHandle:= 0
Local aCombo	 := {'Arquivos CSV'}
Local aTable	 := {}

DEFINE MSDIALOG oDlg FROM 107,99  TO 400,520 TITLE "Importação de Dados" Of oDlg PIXEL
DEFINE FONT oBold NAME "Arial" SIZE 0, 12 BOLD

@ 0,0 BITMAP oBmp RESNAME "LOGIN" Of oDlg SIZE 100,200 NOBORDER When .F. PIXEL

@ 8 ,53 SAY "" of oDlg SIZE 80,9 PIXEL FONT oBold
@ 15, 50 TO 17,230 Label '' Of oDlg PIXEL
@ 20, 53 SAY "Esta rotina tem o objetivo de importar um arquivo de INVENTARIO." SIZE 160,200 Of oDlg PIXEL
@ 56, 53 SAY "Arquivo" Of oDlg PIXEL
@ 56, 80 MSGET cArq Picture '@' Of oDlg PIXEL SIZE 80,9
@ 56,160 BUTTON "Procurar" SIZE 30 ,11   FONT oDlg:oFont ACTION (cArq:=cGetFile("Arquivos CSV (*.CSV) |PRODUTO*.CSV|","Selecionar",,"SERVIDOR\data\",.F.,GETF_NOCHANGEDIR,.T.))  OF oDlg PIXEL
@ 75, 53 SAY "Formato" Of oDlg PIXEL
@ 75, 80 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 76 ,50 OF oDlg PIXEL

@130,155 BUTTON "Confirma" SIZE 35 ,10   FONT oDlg:oFont ACTION (lContinua := .T.,oDlg:End())  OF oDlg PIXEL
@130,117 BUTTON "Cancela" SIZE 35 ,10   FONT oDlg:oFont ACTION (lContinua := .F.,oDlg:End())  OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

If lContinua .And.Empty(cArq)
	MsgBox("Escolha o Arquivo Correto","Arquivo Invalido","ALERT")
ElseIf lContinua
	FT_FUSE(cArq)
	FT_FGOTOP()
	nX := 0
	nFileHandle := FCreate(Substr(cArq,1,Len(cArq)-4)+"_Erro.csv") // abre o novo arquivo _x.csv para gravacao
	nFileHdl    := FCreate(Substr(cArq,1,Len(cArq)-4)+"_Ok.csv") // abre o novo arquivo _x.csv para gravacao
	
	Do While !FT_FEOF()
		
		lConf   := .T.
		
		cLine   := FT_FREADLN()   //compoe cada linha do arquivo		
		cResStr := cLine          //compoe a string para gravar no arquivo _x.csv
		cLine   := cLine + ";"    //adiciona ; no final de cada linha
		
		//indica o cabecalho do arquivo portanto esse linha sera pulada
		If Substr(cLine,1,20) == "COD;DESC;"
			FWrite(nFileHandle, cResStr) // grava no arquivo _x.csv o cabecalho
			FWrite(nFileHandle, Chr(13) + Chr(10)) // nova linha
			FT_FSKIP()
			Loop
		EndIf
		
		Aadd(aTable,{})
		nPosAtu := 0
		_cTipo 	:= 0
		nY      := 0 //numero da coluna
		//compoe cada string da linha separando pelo delimitador ;
		Do While (nPosAtu := At(";", cLine)) > 0
			
			cString := Substr(cLine, 1,nPosAtu-1)
			Do While Subs(cString,1,1) == '"' .And. Subs(cString,Len(cString),1) != '"'
				cString += Subs(cLine, nPosAtu,1)
				nPosAtu++
				If nPosAtu > (len(cLine)+1)
					lErrorFile := .T.
					Exit
				EndIf
			EndDo
			If lErrorFile
				Exit
			Endif
			cString := STRTRAN(cString,'"','')
			nY++
			Do Case // validacao das colunas obrigatorias
				Case nY == 1 // validacao do campo Codigo do Produto - Verifica se ja existe!
					If !Empty(cString)
						//Busca estado valido
						DbSelectArea("SB7")
						DbSetOrder(1)
						If !DbSeek(xFilial("SB7")+Pad(cString,15))
							cString := "["+cString+"] - Valor nao definido ou inconsistente"
						EndIf
					Else
						cString := "["+cString+"] - Valor nao definido ou inconsistente"
					EndIf
				Case nY == 2 .Or. nY == 5 // validacao dos campos Descricao e Armazem
					If Empty(cString)
						cString := "["+cString+"] - Valor nao definido ou inconsistente"
					EndIf
					/*
					Case nY == 3 // validacao do campo Tipo
					If !(Val(cString) >= 1 .And. Val(cString) <= 7)
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Case nY == 4 // validacao do campo Unidade
					If !Empty(cString)
					//Busca estado valido
					DbSelectArea("SAH")
					DbSetOrder(1)
					If !(DbSeek(cString))
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Else
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Case nY == 6 // validacao do Grupo de Produto
					If !Empty(cString)
					//Busca regiao valida
					DbSelectArea("SBM")
					DbSetOrder(1)
					If !(DbSeek(cString))
					cString := "Valor nao definido ou inconsistente"
					EndIf
					EndIf
					Case nY == 7 .Or. nY == 10 .Or. nY == 41 .Or. nY == 42 .Or. nY == 43 // validacao dos campos Ultimo Preco, Custo de Reposicao e Tab de Precos 1-2-3
					cString := Transform(Val(cString),"@E 999999999.9999")
					Case nY == 12 // validacao do campo Meda
					If !Empty(cString)
					If !(Val(cString) >= 1 .And. Val(cString) <= 5)
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Else
					cString := "1"
					EndIf
					Case nY == 14 .Or. nY == 15 // validacao dos campos Tipos de Entrada e Saida
					If !Empty(cString)
					//Busca regiao valida
					DbSelectArea("SF4")
					DbSetOrder(1)
					If !(DbSeek(cString))
					cString := "Valor nao definido ou inconsistente"
					EndIf
					EndIf
					Case nY == 16 .Or. nY == 33 .Or. nY == 34 .Or. nY == 35 // validacao dos campos Fora Estado, Calcula PIS, COFINS e CSLL
					If !(Val(cString) >= 1 .And. Val(cString) <= 2) .And. !Empty(cString)
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Case nY == 18 .Or. nY == 19 // validacao dos campos Peso Bruto e Liquido
					cString := Transform(Val(cString),"@E 999999.9999")
					Case nY == 20 .Or. nY == 21 .Or. nY == 24 .Or. nY == 25 // validacao dos campos Ponto de Pedido, Seguranca, Lote Minimo e Economico
					cString := Transform(Val(cString),"@E 999999999.99")
					Case nY == 22 // validacao do campo Entrega
					cString := Transform(Val(cString),"@E 99999")
					Case nY == 23 // validacao do campo Tipo Prazo
					If !(Val(cString) >= 1 .And. Val(cString) <= 5) .And. !Empty(cString)
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Case nY == 26 // validacao do campo Tpo Dec Op
					If !Empty(cString)
					If !(Val(cString) >= 1 .And. Val(cString) <= 2)
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Else
					cString := "1"
					EndIf
					Case (nY >= 27 .And. nY <= 29) .Or. (nY >= 36 .And. nY <= 40) // validacao dos campos Aliq. ICMS, IPI e ISS, Perc. PIS, CSLL e COFINS, Red. COFINS e PIS
					cString := Transform(Val(cString),"@E 99.99")
					Case nY == 32 // validacao do campo Origem
					If !(Val(cString) >= 0 .And. Val(cString) <= 2) .And. !Empty(cString)
					cString := "Valor nao definido ou inconsistente"
					EndIf
					Case nY == 30 .Or. nY == 31  // validacao dos campos Solid. Entrada e Saida
					cString := Transform(Val(cString),"@E 999.99")
					*/
			EndCase
			aAdd(aTable[Len(aTable)],cString) //adiciona ao array
			cLine := Subs(cLine, nPosAtu + 1) //Corta o elemento adicionado ao array
		EndDo
		
		If lErrorFile
			Exit
		Endif
		
		nX++ // posicao do array
		
		// verifica se existe inconsistencia no array
		For nI := 1 To Len(aTable[nx])
			If "Valor nao definido ou inconsistente" $ aTable[nX][nI]
				lConf := .F.
				Exit
			EndIf
		Next
		
		// caso nao tenha inconsistencia, executa a gravacao
		If lConf
			//abre a tabela SB1 para gravacao
			If DbSeek(xFilial("SB7")+Pad(aTable[nX][1],15))
				RecLock("SB7",.F.)
				
				// informacoes cadastrais
				/*
				SB1->B1_CODPROD		:= aTable[nX][1]
				*/
			  
				SB7->B7_FILIAL := "01"
				SB7->B7_COD 		:= aTable[nX][1]
				SB7->B7_LOCAL 	:= aTable[nX][2]
				dbSelectArea("SB1")                                                                                                                                    
				dbSetorder(1)
				dbSeek(Xfilial("SB1")+aTable[nX][1])
				_cTipo			            := SB1->B1_DESC    
				SB7->B7_TIPO		:= _cTipo
				SB7->B7_DOC 		:= "INV3112"
				SB7->B7_QUANT	:= aTable[nX][3]
				SB7->B7_DATA 	:= dDatabase()

				//cdescr	     	:= aTable[nX][2]
				/*
				SB1->B1_TIPO		:= aTable[nX][3]
				SB1->B1_CODUM		:= aTable[nX][4]
				SB1->B1_LOCAL		:= aTable[nX][5]
				SB1->B1_CODGRP		:= aTable[nX][6]
				SB1->B1_UPRC 		:= Val(Transform(aTable[nX][7],"@E 999999999.9999"))
				SB1->B1_UCOM		:= Ctod(Substr(aTable[nX][8],1,2)+"/"+Substr(aTable[nX][8],3,2)+"/"+Substr(aTable[nX][8],5,2),"ddmmyy")
				SB1->B1_NCM			:= aTable[nX][9]
				SB1->B1_CUSTD		:= Val(Transform(aTable[nX][10],"@E 999999999.9999"))
				SB1->B1_DATREF		:= Ctod(Substr(aTable[nX][11],1,2)+"/"+Substr(aTable[nX][11],3,2)+"/"+Substr(aTable[nX][11],5,2),"ddmmyy")
				SB1->B1_MCUSTD		:= aTable[nX][12]
				SB1->B1_UCALSTD		:= Ctod(Substr(aTable[nX][13],1,2)+"/"+Substr(aTable[nX][13],3,2)+"/"+Substr(aTable[nX][13],5,2),"ddmmyy")
				SB1->B1_TE			:= aTable[nX][14]
				SB1->B1_TS			:= aTable[nX][15]
				SB1->B1_FORAEST		:= aTable[nX][16]
				SB1->B1_CODBAR		:= aTable[nX][17]
				SB1->B1_PESO		:= Val(Transform(aTable[nX][18],"@E 999999.9999"))
				SB1->B1_PESLIQ		:= Val(Transform(aTable[nX][19],"@E 999999.9999"))
				// MRP
				SB1->B1_EMIN		:= Val(Transform(aTable[nX][20],"@E 999999999.99"))
				SB1->B1_ESTSEG		:= Val(Transform(aTable[nX][21],"@E 999999999.99"))
				SB1->B1_PE			:= Val(Transform(aTable[nX][22],"@E 99999"))
				SB1->B1_TIPE		:= aTable[nX][23]
				SB1->B1_LE			:= Val(Transform(aTable[nX][24],"@E 999999999.99"))
				SB1->B1_LM			:= Val(Transform(aTable[nX][25],"@E 999999999.99"))
				SB1->B1_TIPODEC		:= aTable[nX][26]
				// Impostos
				SB1->B1_PICM		:= Val(Transform(aTable[nX][27],"@E 99.99"))
				SB1->B1_IPI			:= Val(Transform(aTable[nX][28],"@E 99.99"))
				SB1->B1_ALIQISS		:= Val(Transform(aTable[nX][29],"@E 99.99"))
				SB1->B1_PICMENT		:= Val(Transform(aTable[nX][30],"@E 999.99"))
				SB1->B1_PICMRET		:= Val(Transform(aTable[nX][31],"@E 999.99"))
				SB1->B1_ORIGEM		:= aTable[nX][32]
				SB1->B1_PIS			:= aTable[nX][33]
				SB1->B1_COFINS		:= aTable[nX][34]
				SB1->B1_CSLL		:= aTable[nX][35]
				SB1->B1_PPIS		:= Val(Transform(aTable[nX][36],"@E 99.99"))
				SB1->B1_PCOFINS		:= Val(Transform(aTable[nX][37],"@E 99.99"))
				SB1->B1_PCSLL		:= Val(Transform(aTable[nX][38],"@E 99.99"))
				SB1->B1_REDPIS		:= Val(Transform(aTable[nX][39],"@E 99.99"))
				SB1->B1_REDCOF		:= Val(Transform(aTable[nX][40],"@E 99.99"))
				// Tabela de precos
				SB1->B1_PRV1		:= Val(Transform(aTable[nX][41],"@E 999999999.9999"))
				SB1->B1_PRV2		:= Val(Transform(aTable[nX][42],"@E 999999999.9999"))
				SB1->B1_PRV3		:= Val(Transform(aTable[nX][43],"@E 999999999.9999"))
				// Campos novos
				//			SB1->B1_CODCST		:= aTable[nX][44]
				//			SB1->B1_CLFISC		:= aTable[nX][45]
				*/
				dbCommit()
				MsUnLock()

				For nI := 1 To Len(aTable[nx])
					cResStr := aTable[nX][nI] + ";"+If(nI==Len(aTable[nx]),cDescAnt,"")
					FWrite(nFileHdl, cResStr) // grava no arquivo _Ok.csv a linha inconsistente
				Next
				FWrite(nFileHdl, Chr(13) + Chr(10)) // nova linha
			EndIf
		Else // caso tenha inconsistencia, executa a gravacao no _x.csv
			For nI := 1 To Len(aTable[nx])
				cResStr := aTable[nX][nI] + If(nI==Len(aTable[nx]),"",";")
				FWrite(nFileHandle, cResStr) // grava no arquivo _Erro.csv a linha inconsistente
			Next
			FWrite(nFileHandle, Chr(13) + Chr(10)) // nova linha
		EndIf
		
		FT_FSKIP()
		
	EndDo
	
	FClose(nFileHandle) // finaliza o arquivo _Erro.csv de gravacao
	FClose(nFileHdl) // finaliza o arquivo _Ok.csv de gravacao
	
	cCaminho := Substr(cArq,1,Len(cArq)-4)+"_Erro.csv"
	cCaminh1 := Substr(cArq,1,Len(cArq)-4)+"_Ok.csv"
	
	DEFINE MSDIALOG oDlg FROM 150,220 TO 388,640 TITLE "Importar" PIXEL
	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	
	@ 1,2 SAY "Esta rotina gerou o seguinte arquivo em:" of oDlg
	@ 2,2 SAY cCaminho of oDlg FONT oBold // Arquivo
	@ 3,2 SAY cCaminh1 of oDlg FONT oBold // Arquivo
	@ 4,2 SAY "Utilize este arquivo para simples conferência ou no caso de correção da(s)" of oDlg
	@ 5,2 SAY "linha(s)  inválida(s).  Use como referência o(s) campo(s)  com o conteú do" of oDlg
	@ 6,2 SAY "'Valor nao definido ou inconsistente' para identificação dos erros." of oDlg
	
	@100,157 BUTTON '<< Ok >>' SIZE 35 ,10   FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL
	
	ACTIVATE MSDIALOG oDlg //CENTERED
EndIf

Return( .T. )

