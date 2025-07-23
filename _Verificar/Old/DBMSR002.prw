#INCLUDE "PROTHEUS.CH"
#DEFINE A1_TITULO	01
#DEFINE A1_DATA	01
#DEFINE A1_FONTE	02
#DEFINE A1_POSIC	03
#DEFINE A1_NEGRI	04
#DEFINE A1_SOMBR	05
#DEFINE A1_BOX		06
#DEFINE A1_AJUST	07
#DEFINE A2_GRID	02
#DEFINE A2_DATA	01
#DEFINE A2_FONTE	02
#DEFINE A2_POSIC	03
#DEFINE A2_NEGRI	04
#DEFINE A2_SOMBR	05
#DEFINE A2_BOX		06
#DEFINE A2_AJUST	07
#DEFINE A2_PAGINA	08
#DEFINE MARGEMV 	100
#DEFINE MARGEMH 	100
#DEFINE BOXV		110    
#DEFINE ESPLINHA	500    
/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    �DBMSR002  � Efetua a impress�o de um array em formato gr�fico conforme   ���
���             �          � par�metros e tipo de fonte utilizado                         ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 27.12.08 � Almir Bandina                                                ���
�����������������������������������������������������������������������������������������͹��
��� Par�metros  � ExpN1 = Posi��o Inicial Vertical do Box                                 ���
���             � ExpN2 = Posi��o Inicial Horizontal do Box                               ��� 
���             � ExpN3 = Posi��o Final Vertical do Box                                   ���
���             � ExpN4 = Posi��o Final Horizontal do Box                                 ���
���             � ExpA1 = Array de Configura��o da P�gina                                 ���
���             �         [1] Altura do Box, se altura das linhas menores que o box       ���
���             �         [2] Margens Horizontais                                         ���
���             �         [3] Margens Verticais                                           ���
���             � ExpA2 = Array Multidimensional com os textos                            ���
���             �         [X] Array com as linhas                                         ���
���             �         [X,Y] Array com a coluna Y da linha N                           ���
���             �         [X,Y,Z] Array com os textos de cada coluna de cada linha        ���
���             �      ou [X,Y,N] Texto a ser impresso na "n" linha da coluna             ���
���             �         [X,Y,Z,N] Texto a ser impresso na "n" linha da coluna           ���
���             � ExpO1 = Objeto relativo a p�gina que esta sendo impressa                ���
���             � ExpN5 = Tipo de fonte a ser utilizada (m�ximo 3) conforme array private ���
���             �         com a defini��o das fontes a serem utilizadas                   ���
���             � ExpA3 = Array com as propriedades do t�tulo quando utiliza um grid      ���
���             �         [C] Texto para o t�tulo                                         ���
���             �         [N] Tipo de fonte a ser utilizado no t�tulo                     ���
���             �         [C] Posicionamento do texto (L=left,R=right,C=center)           ���
���             �         [L] Impress�o de fundo com base na cor definida no array com as ���
���             �             fontes                                                      ���
���             � ExpA4 = Array com os posicionamentos de cada coluna                     ���
���             �         L = left, R = Right, C = center                                 ���
���             � ExpN6 = Coluna que receber� a sobra do espa�o das colunas em rela��o a  ���
���             �         p�gina                                                          ���
���             � ExpL1 = Identificador para impress�o do box para cada linha/coluna      ���
���             � ExpA5 = Array contendo informa��es da imagem                            ���
���             �         [C] Texto com o path e arquivo com a imagem                     ���
���             �         [N] Tamanho da altura da imgem                                  ���
���             �         [N] Tamanho da largura da imagem                                ���
���             � ExpL2 = Identificador para impress�o em negrito da primeira linha do box���
���             � ExpL3 = Identificador para impress�o do fundo colorido da primeira linha���
���             �         do box                                                          ���
�����������������������������������������������������������������������������������������͹��
��� Retorno     � ExpA7 = Array com as novas coordenadas                                  ���
���             �         [1] Posi��o Inicial Vertical                                    ���
���             �         [2] Posi��o Inicial Horizontal                                  ���
�����������������������������������������������������������������������������������������͹��
��� Observa��es �                                                                         ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������͹��
��� Altera��es  � 99.99.99 - Consultor - Descri��o da altera��o                           ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
User Function DBMSR002( nPosVIni, nPosHIni, nPosVFim, nPosHFim, oPage, aCab, aImp )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local aFont		:= {	{ oFontAN, oFontA, oBrushA },;		// Os objetos fonts A, B e C
						{ oFontBN, oFontB, oBrushB },;		// devem ser declarados como private
						{ oFontCN, oFontC, oBrushC } }		// na rotina principal
Local aColuna	:= {}
Local lNegrito	:= .F.
Local lSombra	:= .F.
Local lBox		:= .F.
Local nCab		:= 3
Local nFonte	:= 1
Local nTxtHTam	:= 0
Local nTxtHSpc	:= 0
Local nTxtVTam	:= 0
Local nTxtVSpc	:= 0
Local nAuxV1	:= MARGEMV
Local nAuxV2	:= MARGEMV
Local nAuxH1	:= MARGEMH
Local nAuxH2	:= oPage:nHorzRes() - MARGEMH
Local nColuna	:= 0
Local nColTam	:= 0
Local nColIni	:= 0
Local nColFim	:= 0
Local nColQde	:= 0
Local nColAju	:= 0
Local nLinha	:= 0
Local nLnhQde	:= 0
Local nLnhTam	:= 0
Local nGrid		:= oPage:nVertRes() - MARGEMV
Local nY		:= 0
Local nDif		:= 0
Local cPosic	:= "L"
Local cLabel	:= ""  

Private nPag
Private aUltChar2pix	:= {}
Private aUltVChar2pix	:= {}
//�����������������������������������������������������������������������������������������Ŀ
//� Verifica se tem necessidade de imprimir o cabe�alho                                     �
//�������������������������������������������������������������������������������������������
If ValType( aCab[1] ) == "C"
	nCab	:= Val( aCab[1] )
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� Obtem/Define a largura da p�gina                                                        �
//�������������������������������������������������������������������������������������������
nHPage := oPage:nHorzRes()
nHPage *= ( 300 / oPage:nLogPixelX() )
nHPage -= MARGEMH
//�����������������������������������������������������������������������������������������Ŀ
//� Obtem/Define a altura da p�gina                                                         �
//�������������������������������������������������������������������������������������������
nVPage := oPage:nVertRes() 
nVPage *= ( 300/ oPage:nLogPixelY() )
nVPage -= MARGEMV
//�����������������������������������������������������������������������������������������Ŀ
//� Ajusta os par�metros se informado                                                       �
//�������������������������������������������������������������������������������������������
If Valtype( nPosVIni ) == "N" .And. nPosVIni <> 0
	nAuxV1	:= nPosVIni
EndIf
If Valtype( nPosVFim ) == "N" .And. nPosVFim <> 0
	nAuxV2	:= nPosVFim
EndIf
If ValType( nPosHIni ) == "N" .And. nPosHIni <> 0
	nAuxH1	:= nPosHIni
EndIf
If ValType( nPosHFim ) == "N" .And. nPosHFim <> 0
	nAuxH2	:= nPosHFim
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� SE FOR IMPRIMIR O CABE�ALHO                                                             �
//�������������������������������������������������������������������������������������������
If nCab < 3 .and. nAuxV1 < 150 //Buscar tamanho do cabe�alho 
	ImpCabec( aCab[2], @nAuxV1, @nAuxV2 )
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� IMPRESS�O DO CABE�ALHO DO GRID                                                          �
//�������������������������������������������������������������������������������������������
If ValType( aImp[01, A1_TITULO, A1_DATA] ) == "C" .And. !Empty( aImp[01, A1_TITULO, A1_DATA] )
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime negrito                                                           �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A1_TITULO, A1_NEGRI] ) == "L"
		lNegrito	:= aImp[01, A1_TITULO, A1_NEGRI]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime sombreado                                                         �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A1_TITULO, A1_SOMBR] ) == "L"
		lSombra		:= aImp[01, A1_TITULO, A1_SOMBR]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime o box                                                             �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A1_TITULO, A1_BOX] ) == "L"
		lBox		:= aImp[01, A1_TITULO, A1_BOX]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define a fonte a ser utilizada                                                      �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A1_TITULO, A1_FONTE] ) == "N"
		nFonte		:= aImp[01, A1_TITULO, A1_FONTE]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define o posicionamento para o texto                                                �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A1_TITULO, A1_POSIC] ) == "C"
		cPosic		:= aImp[01, A1_TITULO, A1_POSIC]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define o label para impress�o                                                       �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A1_TITULO, A1_DATA] ) == "C"
		cLabel		:= aImp[01, A1_TITULO, A1_DATA]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Obtem o tamanho vertical do texto                                                   �
	//���������������������������������������������������������������������������������������
	nTxtVTam	:= Char2PixV(	oPage,;
								"X",;
								aFont[nFonte, If( lNegrito, 1, 2 )] )
	//�������������������������������������������������������������������������������������Ŀ
	//� Obtem o tamanho horizontal do texto                                                 �
	//���������������������������������������������������������������������������������������
	nTxtHTam	:= Char2PixH(	oPage,;
						  		cLabel,;
								aFont[nFonte, If( lNegrito, 1, 2 )] )
	//�������������������������������������������������������������������������������������Ŀ
	//� Obtem o espa�o vertical/horizontal do texto                                         �
	//���������������������������������������������������������������������������������������
	nTxtVSpc	:= ( nTxtVTam * .25 )
	nTxtHSpc	:= Char2PixH(	oPage,;
								"X",;
								aFont[nFonte, If( lNegrito, 1, 2 )] )
	//�������������������������������������������������������������������������������������Ŀ
	//� Calcula os posicionametnos em fun��o do tamanho do texto e fonte utilizados         �
	//���������������������������������������������������������������������������������������
	nAuxV1 += ( nTxtVSpc )
	nAuxV2 := ( nAuxV1 + nTxtVTam )
	//�������������������������������������������������������������������������������������Ŀ
	//� Faz a Impress�o da sombra                                                           �
	//���������������������������������������������������������������������������������������
	If lSombra
		oPage:FillRect( {	nAuxV1 - nTxtVSpc,;
							nAuxH1,;
							nAuxV2 + nTxtVSpc,;
							nAuxH2 },;
							aFont[nFonte, 3] )
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Faz a impress�o do texto alinhado a esquerda                                        �
	//���������������������������������������������������������������������������������������
	If cPosic == "L"
		oPage:Say(	nAuxV1,;
					nAuxH1,;
					cLabel,;
					aFont[nFonte, If( lNegrito, 1, 2 )] )
	//�������������������������������������������������������������������������������������Ŀ
	//� Faz a impress�o do texto alinhado a direita                                         �
	//���������������������������������������������������������������������������������������
	ElseIf cPosic == "R"
		oPage:Say(	nAuxV1,;
					nAuxH2 - nTxtHTam,;
					cLabel,;
					aFont[nFonte, If( lNegrito, 1, 2 )] )
	//�������������������������������������������������������������������������������������Ŀ
	//� Faz a impress�o do texto centralizado                                               �
	//���������������������������������������������������������������������������������������
	Else
		oPage:Say(	nAuxV1,;
					nAuxH1 + (	( nAuxH2 - nAuxH1 ) - nTxtHTam ) / 2,;
					cLabel,;
					aFont[nFonte,If( lNegrito, 1, 2 )] )
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Avan�a o posicionamento                                                             �
	//���������������������������������������������������������������������������������������
	nAuxV1 := ( nAuxV2 + ( nTxtVSpc * 2 ) )
	nAuxV2 := ( nAuxV1 )
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� IMPRESS�O DO DO GRID                                                                    �
//������������������������������������������������������������������������������������������� 
If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime negrito                                                           �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_NEGRI] ) == "L"
		lNegrito	:= aImp[01, A2_GRID, A2_NEGRI]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime sombreado                                                         �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_SOMBR] ) == "L"
		lSombra		:= aImp[01, A2_GRID, A2_SOMBR]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime o box                                                             �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_BOX] ) == "L"
		lBox		:= aImp[01, A2_GRID, A2_BOX]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define a fonte a ser utilizada                                                      �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_FONTE] ) == "N"
		nFonte		:= aImp[01, A2_GRID, A2_FONTE]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define a fonte a ser utilizada                                                      �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_AJUST] ) == "N"
		nColAju		:= aImp[01, A2_GRID, A2_AJUST]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Obtem a quantidade de linhas do grid                                                �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
		//���������������������������������������������������������������������������������Ŀ
		//� Obtem a quantiade de linhas do grid                                             �
		//�����������������������������������������������������������������������������������
		nLnhQde	:= Len( aImp[01, A2_GRID, A2_DATA] )
		//���������������������������������������������������������������������������������Ŀ
		//� Obtem a quantiade de colunas                                                    �
		//�����������������������������������������������������������������������������������
		nColQde := Len( aImp[01, A2_GRID, A2_DATA, nLnhQde] )
		//���������������������������������������������������������������������������������Ŀ
		//� Define a coluna inicial                                                         �
		//�����������������������������������������������������������������������������������
		nColIni	:= nAuxH1
		//���������������������������������������������������������������������������������Ŀ
		//� Cria array com o tamanho e posi��o inicial/final horizontal                     �
		//�����������������������������������������������������������������������������������
		For nColuna := 1 To nColQde
			nColTam	:= 0
			//�����������������������������������������������������������������������������Ŀ
			//� Obtem o maior texto da coluna de cada linha                                 �
			//�������������������������������������������������������������������������������
			For nLinha := 1 To nLnhQde
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o label do texto                                                  �
				//���������������������������������������������������������������������������
				cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o tamanho do label do texto                                       �
				//���������������������������������������������������������������������������
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Define qual o maior texto da coluna                                     �
				//���������������������������������������������������������������������������
				If nColTam < nTxtHTam
					nColTam := nTxtHTam
				EndIf
			Next nLinha
			//�����������������������������������������������������������������������������Ŀ
			//� Define o tamanho horizontal de uma letra                                    �
			//�������������������������������������������������������������������������������
			nTxtHTam	:= Char2PixH(	oPage,;
										"X",;
										aFont[nFonte, If( lNegrito, 1, 2 )] )
			//�����������������������������������������������������������������������������Ŀ
			//� Define a posi��o inicial da coluna                                          �
			//�������������������������������������������������������������������������������
			nColIni	+= nTxtHTam
			//�����������������������������������������������������������������������������Ŀ
			//� Define a posi��o final da coluna                                            �
			//�������������������������������������������������������������������������������
			nColFim	:= nColIni + nColTam
			//�����������������������������������������������������������������������������Ŀ
			//� Re-define o tamanho da coluna com os espa�os horizontais do label           �
			//�������������������������������������������������������������������������������
			nColTam	+= nTxtHTam * 2
			//�����������������������������������������������������������������������������Ŀ
			//� Alimenta o array com o tamanho, posi��o inicial e posi��o final             �
			//�������������������������������������������������������������������������������
			aAdd( aColuna,	{ nColTam, nColIni, nColFim } )
			//�����������������������������������������������������������������������������Ŀ
			//� Re-define a posi��o inicial para a pr�xima coluna                           �
			//�������������������������������������������������������������������������������
			nColIni	:= ( nColFim + nTxtHTam )
			//�����������������������������������������������������������������������������Ŀ
			//� Acumula os tamnhos de cada coluna para comparar posteriormente              �
			//�������������������������������������������������������������������������������
			nLnhTam += nColTam
		Next nColuna
		//���������������������������������������������������������������������������������Ŀ
		//� Caso o Tamanho das colunas seja inferior ao do formul�rio, efetua o ajuste      �
		//� proporcional para cada coluna                                                   �
		//�����������������������������������������������������������������������������������
		If nLnhTam <= ( nAuxH2 - nAuxH1 )
			//�����������������������������������������������������������������������������Ŀ
			//� N�o recebeu a coluna para ajuste, faz a distribui��o entre todas            �
			//�������������������������������������������������������������������������������
			If nColAju == 0
				nDif := Int( ( ( nAuxH2 -  nAuxH1 ) - nLnhTam ) / nColQde )
				//�������������������������������������������������������������������������Ŀ
				//� Distribui a diferen�a entre as colunas                                  �
				//���������������������������������������������������������������������������
			    For nY := 1 To Len( aColuna )
					aColuna[nY,1] += nDif
					If nY > 1
						aColuna[nY,2] += ( nDif * ( nY - 1 ) )
					EndIf
					aColuna[nY,3] += ( nDif * nY )
				Next nY
			//�����������������������������������������������������������������������������Ŀ
			//� Recebeu a coluna para ajuste, faz o ajuste na coluna informada              �
			//�������������������������������������������������������������������������������
			Else
				nDif := Int( ( ( nAuxH2 - nAuxH1 ) - nLnhTam ) )
				For nY := nColAju To Len( aColuna )
					If nY == nColAju
						aColuna[nY,1]	+= nDif
					Else
						aColuna[nY,2] += nDif
					EndIf
					aColuna[nY,3] += nDif
				Next nY
			EndIf
		EndIf
		//���������������������������������������������������������������������������������Ŀ
		//� Define o tamanho vertiacal da linha                                             �
		//�����������������������������������������������������������������������������������
		nTxtVTam	:= Char2PixV(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nTxtVSpc	:= ( nTxtVTam * .25 )
		nTxtHSpc	:= Char2PixH(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nGrid		:= nAuxV1
		//���������������������������������������������������������������������������������Ŀ
		//� Varre todas as linhas                                                           �
		//�����������������������������������������������������������������������������������
		For nLinha := 1 To nLnhQde
			//�����������������������������������������������������������������������������Ŀ
			//� Avan�a o posicionamento                                                     �
			//�������������������������������������������������������������������������������
			nAuxV1 += ( If( nLinha > 1, nTxtVTam, 0 ) + nTxtVSpc )
			nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )
			For nColuna := 1 To nColQde
				//�������������������������������������������������������������������������Ŀ
				//� Define o posicionamento para o texto                                    �
				//���������������������������������������������������������������������������
				If ValType( aImp[01, A2_GRID, A2_POSIC, nColuna] ) == "C"
					cPosic		:= aImp[01, A2_GRID, A2_POSIC, nColuna]
				Else
					cPosic		:= "L"
				EndIf
				//�������������������������������������������������������������������������Ŀ
				//� Define o label para impress�o                                           �
				//���������������������������������������������������������������������������
				If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A"
					cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]
				EndIf
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o tamanho vertical do texto                                       �
				//���������������������������������������������������������������������������
				nTxtVTam	:= Char2PixV(	oPage,;
											"X",;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o tamanho horizontal do texto                                     �
				//���������������������������������������������������������������������������
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, 02] )
				//�������������������������������������������������������������������������Ŀ
				//� Faz a Impress�o da sombra                                               �
				//���������������������������������������������������������������������������
				If lSombra .And. nLinha == 1 .And. nColuna == 1
					oPage:FillRect( {	nAuxV1,;
										nAuxH1,;
										nAuxV2,;
										nAuxH2 },;
										aFont[nFonte, 3] )
				EndIf
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress�o do texto alinhado a direita                             �
				//���������������������������������������������������������������������������
				If cPosic == "R"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,3] - nTxtHTam,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress�o do texto alinhado a esquerda                            �
				//���������������������������������������������������������������������������
				ElseIf cPosic == "L"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2],;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress~~ao do texto centralizado                                 �
				//���������������������������������������������������������������������������
				Else
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2] + (	( aColuna[nColuna,3] - aColuna[nColuna,2] ) - nTxtHTam ) / 2,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				EndIf
			Next nColuna
			//�����������������������������������������������������������������������������Ŀ
			//� Verifica se necessita trocar de p�gina                                      �
			//�������������������������������������������������������������������������������
			If nAuxV2 > nVPage
				//�������������������������������������������������������������������������Ŀ
				//� Imprime o box se necess�rio                                             �
				//���������������������������������������������������������������������������
				For nColuna := 1 To nColQde
					//���������������������������������������������������������������������Ŀ
					//� S� faz o box se necess�rio                                          �
					//�����������������������������������������������������������������������
					If lBox
						//�����������������������������������������������������������������Ŀ
						//� Linha Superior                                                  �
						//�������������������������������������������������������������������
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nGrid,;										// Linha Final
									aColuna[Len( aColuna ), 3] + nTxtHSpc )	// Coluna Final
						//�����������������������������������������������������������������Ŀ
						//� Linha Inferior                                                  �
						//�������������������������������������������������������������������
						oPage:Line(	nAuxV2 + nTxtVSpc,;							// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[Len( aColuna ), 3] + nTxtHSpc )	// Coluna Final
						//�����������������������������������������������������������������Ŀ
						//� Coluna Esquerda                                                 �
						//�������������������������������������������������������������������
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[1,2] - nTxtHSpc )					// Coluna Final
						//�����������������������������������������������������������������Ŀ
						//� Demais Colunas                                                  �
						//�������������������������������������������������������������������
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[nColuna, 3] + nTxtHSpc,;			// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[nColuna, 3] + nTxtHSpc )			// Coluna Final
					EndIf
				Next nColuna
				//�������������������������������������������������������������������������Ŀ
				//� Encerra a p�gina                                                        �
				//��������������������������������������������������������������������������� 
				
				oPage:EndPage()
				//�������������������������������������������������������������������������Ŀ
				//� Inicializa nova p�gina                                                  �
				//���������������������������������������������������������������������������
				oPage:StartPage()
								
				//�������������������������������������������������������������������������Ŀ
				//� Inicializa o posicionamento inicial                                     �
				//���������������������������������������������������������������������������
				nAuxV1	:= MARGEMV
				nAuxV2	:= MARGEMV
				nAuxH1	:= MARGEMH
   
				//�����������������������������������������������������������������������������������������Ŀ
				//� SE FOR IMPRIMIR O CABE�ALHO                                                             �
				//�������������������������������������������������������������������������������������������
				If nCab == 2
					ImpCabec( aCab[2], @nAuxV1, @nAuxV2 )
				EndIf 
				
				//�������������������������������������������������������������������������Ŀ
				//� Avan�a o posicionamento                                                 �
				//���������������������������������������������������������������������������
				nAuxV1 += nTxtVSpc
				nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc ) 
				
				NgRID	:= nAuxV1 	
				
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress�o da 1a. linha (cabe�alho do grid) na p�gina nova         �
				//���������������������������������������������������������������������������
				For nColuna := 1 To nColQde  
					//�������������������������������������������������������������������������Ŀ
					//� Define o posicionamento para o texto                                    �
					//���������������������������������������������������������������������������
					If ValType( aImp[01, A2_GRID, A2_POSIC, nColuna] ) == "C"
						cPosic		:= aImp[01, A2_GRID, A2_POSIC, nColuna]
					Else
						cPosic		:= "L"
					EndIf
					//�������������������������������������������������������������������������Ŀ
					//� Define o label para impress�o                                           �
					//���������������������������������������������������������������������������
					If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" 
						cLabel		:= aImp[01, A2_GRID, A2_DATA, 1, nColuna]
					EndIf
					
					//�������������������������������������������������������������������������Ŀ
					//� Obtem o tamanho vertical do texto                                       �
					//���������������������������������������������������������������������������
					nTxtVTam	:= Char2PixV(	oPage,;
												"X",;
												aFont[nFonte, If( lNegrito, 1, 2 )] )
					//�������������������������������������������������������������������������Ŀ
					//� Obtem o tamanho horizontal do texto                                     �
					//���������������������������������������������������������������������������
					nTxtHTam	:= Char2PixH(	oPage,;
										  		cLabel,;
												aFont[nFonte, 02] )
					//�������������������������������������������������������������������������Ŀ
					//� Faz a Impress�o da sombra                                               �
					//���������������������������������������������������������������������������
					If lSombra .And. nColuna == 1
						oPage:FillRect( {	nAuxV1,;
											nAuxH1,;
											nAuxV2,;
											nAuxH2 },;
											aFont[nFonte, 3] )
					EndIf
					//���������������������������������������������������������������������Ŀ
					//� Faz a impress�o do texto alinhado a direita                         �
					//�����������������������������������������������������������������������
					If cPosic == "R"
						oPage:Say(	nAuxV1,;
									aColuna[nColuna,03] - nTxtHTam,;
									cLabel,;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
					//���������������������������������������������������������������������Ŀ
					//� Faz a impress�o do texto alinhado a esquerda                        �
					//�����������������������������������������������������������������������
					ElseIf cPosic == "L"
						oPage:Say(	nAuxV1,;
									aColuna[nColuna,02],;
									cLabel,;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
					//���������������������������������������������������������������������Ŀ
					//� Faz a impress�o do texto centralizado                               �
					//�����������������������������������������������������������������������
					Else
						oPage:Say(	nAuxV1,;
									aColuna[nColuna,02] + ( ( aColuna[nColuna,03] - aColuna[nColuna,02] ) - nTxtHTam ) / 2,;
									cLabel,;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
					EndIf
				Next nColuna
			EndIf
		Next nLinha
		//���������������������������������������������������������������������������������Ŀ
		//� Imprime o box se necess�rio                                                     �
		//�����������������������������������������������������������������������������������
		If lBox
			//�����������������������������������������������������������������������������Ŀ
			//� Varre todas as colunas                                                      �
			//�������������������������������������������������������������������������������
			For nColuna := 1 To nColQde
				//�������������������������������������������������������������������������Ŀ
				//� Linha Superior                                                          �
				//���������������������������������������������������������������������������
				oPage:Line(	nGrid,;											// Linha Inicial
							aColuna[1,2] - nTxtHSpc,;						// Coluna Inicial
							nGrid,;											// Linha Final
							aColuna[Len( aColuna ), 3] + nTxtHSpc )		// Coluna Final
				//�������������������������������������������������������������������������Ŀ
				//� Linha Inferior                                                          �
				//���������������������������������������������������������������������������
				oPage:Line(	nAuxV2 + nTxtVSpc,;								// Linha Inicial
							aColuna[1,2] - nTxtHSpc,;						// Coluna Inicial
							nAuxV2 + nTxtVSpc,;								// Linha Final
							aColuna[Len( aColuna ), 3] + nTxtHSpc )		// Coluna Final
				//�������������������������������������������������������������������������Ŀ
				//� Coluna Esquerda                                                         �
				//���������������������������������������������������������������������������
				oPage:Line(	nGrid,;											// Linha Inicial
							aColuna[1,2] - nTxtHSpc,;						// Coluna Inicial
							nAuxV2 + nTxtVSpc,;								// Linha Final
							aColuna[1,2] - nTxtHSpc )						// Coluna Final
				//�������������������������������������������������������������������������Ŀ
				//� Demais Colunas                                                          �
				//���������������������������������������������������������������������������
				oPage:Line(	nGrid,;											// Linha Inicial
							aColuna[nColuna, 3] + nTxtHSpc,;				// Coluna Inicial
							nAuxV2 + nTxtVSpc,;								// Linha Final
							aColuna[nColuna, 3] + nTxtHSpc )				// Coluna Final
			Next nColuna
		EndIf
	EndIf
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� Retorna os posicionamento final                                                         �
//�������������������������������������������������������������������������������������������
Return( { nAuxV2, nAuxH1 } )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    �Char2PixH � Define a largura do caracter em pixel de acordo com o tamanho���
���             �          �  da fonte                                                    ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 27.12.08 � Almir Bandina                                                ���
�����������������������������������������������������������������������������������������͹��
��� Par�metros  � ExpO1 = Objeto relativo a p�gina que esta sendo impressa                ���
���             � ExpC1 = Texto a ser calculado                                           ��� 
���             � ExpO2 = Fonte a ser considerada no c�lculo                              ���
�����������������������������������������������������������������������������������������͹��
��� Retorno     � ExpN1 = Tamanho do texto na horizontal                                  ���
�����������������������������������������������������������������������������������������͹��
��� Observa��es �                                                                         ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������͹��
��� Altera��es  � 99.99.99 - Consultor - Descri��o da altera��o                           ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Static Function Char2PixH( oPage, cTexto, oFont )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local nX := 0

DEFAULT aUltChar2pix := {}  
//�����������������������������������������������������������������������������������������Ŀ
//� Verifica se ainda n�o foi calculado                                                     �
//�������������������������������������������������������������������������������������������
nX := aScan( aUltChar2pix,{ |x| x[1] == cTexto .And. x[2] == oFont } )
//�����������������������������������������������������������������������������������������Ŀ
//� Se for calculo novo, acrescenta ao array a informa��o                                   �
//�������������������������������������������������������������������������������������������
If nX == 0
	aAdd( aUltChar2pix, {	cTexto,;
							oFont,;
							oPage:GetTextWidht( cTexto, oFont) * ( 245 / oPage:nLogPixelX() ) } )  
	nX := Len( aUltChar2pix )
EndIf

Return( aUltChar2pix[nX,3] )


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    �Char2PixH � Define a altura do caracter em pixel de acordo com o tamanho ���
���             �          �  da fonte                                                    ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 27.12.08 � Almir Bandina                                                ���
�����������������������������������������������������������������������������������������͹��
��� Par�metros  � ExpO1 = Objeto relativo a p�gina que esta sendo impressa                ���
���             � ExpC1 = Texto a ser calculado                                           ��� 
���             � ExpO2 = Fonte a ser considerada no c�lculo                              ���
�����������������������������������������������������������������������������������������͹��
��� Retorno     � ExpN1 = Tamanho do texto na horizontal                                  ���
�����������������������������������������������������������������������������������������͹��
��� Observa��es �                                                                         ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������͹��
��� Altera��es  � 99.99.99 - Consultor - Descri��o da altera��o                           ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/
Static Function Char2PixV( oPage, cChar, oFont )
//�����������������������������������������������������������������������������������������Ŀ
//� Define as vari�veis da rotina                                                           �
//�������������������������������������������������������������������������������������������
Local nX := 0

DEFAULT aUltVChar2pix := {}
//�����������������������������������������������������������������������������������������Ŀ
//� Obtem o primeiro caracter do texto                                                      �
//�������������������������������������������������������������������������������������������
cChar := SubStr( cChar, 1, 1 )
//�����������������������������������������������������������������������������������������Ŀ
//� Verifica se ainda n�o foi calculado                                                     �
//�������������������������������������������������������������������������������������������
nX := aScan( aUltVChar2pix,{ |x| x[1] == cChar .And. x[2] == oFont } )
//�����������������������������������������������������������������������������������������Ŀ
//� Se for calculo novo, acrescenta ao array a informa��o                                   �
//�������������������������������������������������������������������������������������������
If nX == 0
	aAdd( aUltVChar2pix, {	cChar,;
							oFont,;
							oPage:GetTextHeight( cChar, oFont ) * ( ESPLINHA / oPage:nLogPixelY() ) } )
	nX := Len( aUltVChar2pix )
EndIf

Return( aUltVChar2pix[nX,3] ) 


/*�������������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������ͻ��
��� Programa    �ImpCabec  � Faz a impressao do cabecalho nas paginas 					  ���
���             �          �                                                              ���
�����������������������������������������������������������������������������������������͹��
��� Autor       � 27.12.08 � Almir Bandina                                                ���
�����������������������������������������������������������������������������������������͹��
��� Par�metros  � ExpO1 = Conteudo a ser impresso							              ���
���             � ExpC1 = Posicao                               				          ��� 
���             � ExpO2 = Posicao								                          ���
�����������������������������������������������������������������������������������������͹��
��� Retorno     �  											                              ���
�����������������������������������������������������������������������������������������͹��
��� Observa��es �                                                                         ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������͹��
��� Altera��es  � 99.99.99 - Consultor - Descri��o da altera��o                           ���
���             �                                                                         ���
�����������������������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������*/


Static Function ImpCabec( aImp, nAuxV1, nAuxV2 )

Local aFont		:= {	{ oFontAN, oFontA, oBrushA },;		// Os objetos fonts A, B e C
						{ oFontBN, oFontB, oBrushB },;		// devem ser declarados como private
						{ oFontCN, oFontC, oBrushC } }		// na rotina principal
Local aColuna	:= {}
Local lNegrito	:= .F.
Local lSombra	:= .F.
Local lBox		:= .F.
//Local nAuxV1	:= MARGEMV
//Local nAuxV2	:= MARGEMV
Local nAuxH1	:= MARGEMH
Local nAuxH2	:= oPage:nHorzRes() - MARGEMH
Local nLnhTam	:= 0

If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime negrito                                                           �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_NEGRI] ) == "L"
		lNegrito	:= aImp[01, A2_GRID, A2_NEGRI]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime sombreado                                                         �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_SOMBR] ) == "L"
		lSombra		:= aImp[01, A2_GRID, A2_SOMBR]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define se imprime o box                                                             �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_BOX] ) == "L"
		lBox		:= aImp[01, A2_GRID, A2_BOX]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define a fonte a ser utilizada                                                      �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_FONTE] ) == "N"
		nFonte		:= aImp[01, A2_GRID, A2_FONTE]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Define a fonte a ser utilizada                                                      �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_AJUST] ) == "N"
		nColAju		:= aImp[01, A2_GRID, A2_AJUST]
	EndIf
	//�������������������������������������������������������������������������������������Ŀ
	//� Obtem a quantidade de linhas do grid                                                �
	//���������������������������������������������������������������������������������������
	If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
		//���������������������������������������������������������������������������������Ŀ
		//� Obtem a quantiade de linhas do grid                                             �
		//�����������������������������������������������������������������������������������
		nLnhQde	:= Len( aImp[01, A2_GRID, A2_DATA] )
		//���������������������������������������������������������������������������������Ŀ
		//� Obtem a quantiade de colunas                                                    �
		//�����������������������������������������������������������������������������������
		nColQde := Len( aImp[01, A2_GRID, A2_DATA, nLnhQde] )
		//���������������������������������������������������������������������������������Ŀ
		//� Define a coluna inicial                                                         �
		//�����������������������������������������������������������������������������������
		nColIni	:= nAuxH1
		//���������������������������������������������������������������������������������Ŀ
		//� Cria array com o tamanho e posi��o inicial/final horizontal                     �
		//�����������������������������������������������������������������������������������
		For nColuna := 1 To nColQde
			nColTam	:= 0
			//�����������������������������������������������������������������������������Ŀ
			//� Obtem o maior texto da coluna de cada linha                                 �
			//�������������������������������������������������������������������������������
			For nLinha := 1 To nLnhQde
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o label do texto                                                  �
				//��������������������������������������������������������������������������
		    	cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]

				//�������������������������������������������������������������������������Ŀ
				//� Obtem o tamanho do label do texto                                       �
				//���������������������������������������������������������������������������
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Define qual o maior texto da coluna                                     �
				//���������������������������������������������������������������������������
				If nColTam < nTxtHTam
					nColTam := nTxtHTam
				EndIf
			Next nLinha
			//�����������������������������������������������������������������������������Ŀ
			//� Define o tamanho horizontal de uma letra                                    �
			//�������������������������������������������������������������������������������
			nTxtHTam	:= Char2PixH(	oPage,;
										"X",;
										aFont[nFonte, If( lNegrito, 1, 2 )] )
			//�����������������������������������������������������������������������������Ŀ
			//� Define a posi��o inicial da coluna                                          �
			//�������������������������������������������������������������������������������
			nColIni	+= nTxtHTam
			//�����������������������������������������������������������������������������Ŀ
			//� Define a posi��o final da coluna                                            �
			//�������������������������������������������������������������������������������
			nColFim	:= nColIni + nColTam
			//�����������������������������������������������������������������������������Ŀ
			//� Re-define o tamanho da coluna com os espa�os horizontais do label           �
			//�������������������������������������������������������������������������������
			nColTam	+= nTxtHTam * 2
			//�����������������������������������������������������������������������������Ŀ
			//� Alimenta o array com o tamanho, posi��o inicial e posi��o final             �
			//�������������������������������������������������������������������������������
			aAdd( aColuna,	{ nColTam, nColIni, nColFim } )
			//�����������������������������������������������������������������������������Ŀ
			//� Re-define a posi��o inicial para a pr�xima coluna                           �
			//�������������������������������������������������������������������������������
			nColIni	:= ( nColFim + nTxtHTam )
			//�����������������������������������������������������������������������������Ŀ
			//� Acumula os tamnhos de cada coluna para comparar posteriormente              �
			//�������������������������������������������������������������������������������
			nLnhTam += nColTam
		Next nColuna
		//���������������������������������������������������������������������������������Ŀ
		//� Caso o Tamanho das colunas seja inferior ao do formul�rio, efetua o ajuste      �
		//� proporcional para cada coluna                                                   �
		//�����������������������������������������������������������������������������������
		If nLnhTam <= ( nAuxH2 - nAuxH1 )
			//�����������������������������������������������������������������������������Ŀ
			//� N�o recebeu a coluna para ajuste, faz a distribui��o entre todas            �
			//�������������������������������������������������������������������������������
			If nColAju == 0
				nDif := Int( ( ( nAuxH2 -  nAuxH1 ) - nLnhTam ) / nColQde )
				//�������������������������������������������������������������������������Ŀ
				//� Distribui a diferen�a entre as colunas                                  �
				//���������������������������������������������������������������������������
			    For nY := 1 To Len( aColuna )
					aColuna[nY,1] += nDif
					If nY > 1
						aColuna[nY,2] += ( nDif * ( nY - 1 ) )
					EndIf
					aColuna[nY,3] += ( nDif * nY )
				Next nY
			//�����������������������������������������������������������������������������Ŀ
			//� Recebeu a coluna para ajuste, faz o ajuste na coluna informada              �
			//�������������������������������������������������������������������������������
			Else
				nDif := Int( ( ( nAuxH2 - nAuxH1 ) - nLnhTam ) )
				For nY := nColAju To Len( aColuna )
					If nY == nColAju
						aColuna[nY,1]	+= nDif
					Else
						aColuna[nY,2] += nDif
					EndIf
					aColuna[nY,3] += nDif
				Next nY
			EndIf
		EndIf
		//���������������������������������������������������������������������������������Ŀ
		//� Define o tamanho vertiacal da linha                                             �
		//�����������������������������������������������������������������������������������
		nTxtVTam	:= Char2PixV(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nTxtVSpc	:= ( nTxtVTam * .25 )
		nTxtHSpc	:= Char2PixH(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nGrid		:= nAuxV1
		//���������������������������������������������������������������������������������Ŀ
		//� Varre todas as linhas                                                           �
		//�����������������������������������������������������������������������������������
		For nLinha := 1 To nLnhQde
			//�����������������������������������������������������������������������������Ŀ
			//� Avan�a o posicionamento                                                     �
			//�������������������������������������������������������������������������������
			nAuxV1 += ( If( nLinha > 1, nTxtVTam, 0 ) + nTxtVSpc )
			nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )
			For nColuna := 1 To nColQde
				//�������������������������������������������������������������������������Ŀ
				//� Define o posicionamento para o texto                                    �
				//���������������������������������������������������������������������������
				If ValType( aImp[01, A2_GRID, A2_POSIC, nColuna] ) == "C"
					cPosic		:= aImp[01, A2_GRID, A2_POSIC, nColuna]
				Else
					cPosic		:= "L"
				EndIf
				//�������������������������������������������������������������������������Ŀ
				//� Define o label para impress�o                                           �
				//���������������������������������������������������������������������������
				If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A"  
					cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]
				EndIf
				If "nPage" $ cLabel
					nPag := oPage:nPage
					cLabel := StrTran(cLabel,"nPage",StrZero(nPag,6))
				Endif
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o tamanho vertical do texto                                       �
				//���������������������������������������������������������������������������
				nTxtVTam	:= Char2PixV(	oPage,;
											"X",;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Obtem o tamanho horizontal do texto                                     �
				//���������������������������������������������������������������������������
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, 02] )
				//�������������������������������������������������������������������������Ŀ
				//� Faz a Impress�o da sombra                                               �
				//���������������������������������������������������������������������������
				If lSombra .And. nLinha == 1 .And. nColuna == 1
					oPage:FillRect( {	nAuxV1,;
										nAuxH1,;
										nAuxV2,;
										nAuxH2 },;
										aFont[nFonte, 3] )
				EndIf
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress�o do texto alinhado a direita                             �
				//���������������������������������������������������������������������������
				If cPosic == "R"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,3] - nTxtHTam,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress�o do texto alinhado a esquerda                            �
				//���������������������������������������������������������������������������
				ElseIf cPosic == "L"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2],;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//�������������������������������������������������������������������������Ŀ
				//� Faz a impress~~ao do texto centralizado                                 �
				//���������������������������������������������������������������������������
				Else
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2] + (	( aColuna[nColuna,3] - aColuna[nColuna,2] ) - nTxtHTam ) / 2,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				EndIf
			Next nColuna
			//�������������������������������������������������������������������������Ŀ
			//� Imprime o box se necess�rio                                             �
			//���������������������������������������������������������������������������
			For nColuna := 1 To nColQde
				//���������������������������������������������������������������������Ŀ
				//� S� faz o box se necess�rio                                          �
				//�����������������������������������������������������������������������
				If lBox
						//�����������������������������������������������������������������Ŀ
						//� Linha Superior                                                  �
						//�������������������������������������������������������������������
					   	oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nGrid,;										// Linha Final
									aColuna[Len( aColuna ), 3] + nTxtHSpc )	// Coluna Final 
					    
						//�����������������������������������������������������������������Ŀ
						//� Linha Inferior                                                  �
						//�������������������������������������������������������������������
					  /* 	oPage:Line( nAuxV2 + nTxtVSpc,;					// Linha Inicial 
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
								   	nAuxV2 + nTxtVSpc ,;				// Linha Final
									aColuna[Len( aColuna ),3] + nTxtHSpc ) 		// Coluna Final   
						*/			
						//�����������������������������������������������������������������Ŀ
						//� Coluna Esquerda                                                 �
						//�������������������������������������������������������������������
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[1,2] - nTxtHSpc )					// Coluna Final
						//�����������������������������������������������������������������Ŀ
						//� Demais Colunas                                                  �
						//�������������������������������������������������������������������
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[nColuna, 3] + nTxtHSpc,;			// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[nColuna, 3] + nTxtHSpc )			// Coluna Final
					EndIf
			Next nColuna          
			
			//�������������������������������������������������������������������������Ŀ
			//� Avan�a o posicionamento                                                 �
			//���������������������������������������������������������������������������
			nAuxV1 += nTxtVSpc
			nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )    
		Next nLinha  
		//�����������������������������������������������������������������Ŀ
		//� Linha Inferior                                                  �
		//�������������������������������������������������������������������
		oPage:Line( nAuxV2,;						// Linha Inicial 
					aColuna[1,2] - nTxtHSpc,;				// Coluna Inicial
				   	nAuxV2,;					// Linha Final
					aColuna[Len( aColuna ),3] + nTxtHSpc )	// Coluna Final 
	EndIf
EndIf

//�������������������������������������������������������������������������Ŀ
//� Avan�a o posicionamento                                                 �
//���������������������������������������������������������������������������
	nAuxV1 += nTxtVSpc * 10
	nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )  

Return( Nil )
