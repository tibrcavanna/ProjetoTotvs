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
/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠имммммммммммммяммммммммммямммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩╠╠
╠╠╨ Programa    ЁDBMSR002  Ё Efetua a impressЦo de um array em formato grАfico conforme   ╨╠╠
╠╠╨             Ё          Ё parБmetros e tipo de fonte utilizado                         ╨╠╠
╠╠лмммммммммммммьммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Autor       Ё 27.12.08 Ё Almir Bandina                                                ╨╠╠
╠╠лмммммммммммммьммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ParБmetros  Ё ExpN1 = PosiГЦo Inicial Vertical do Box                                 ╨╠╠
╠╠╨             Ё ExpN2 = PosiГЦo Inicial Horizontal do Box                               ╨╠╠ 
╠╠╨             Ё ExpN3 = PosiГЦo Final Vertical do Box                                   ╨╠╠
╠╠╨             Ё ExpN4 = PosiГЦo Final Horizontal do Box                                 ╨╠╠
╠╠╨             Ё ExpA1 = Array de ConfiguraГЦo da PАgina                                 ╨╠╠
╠╠╨             Ё         [1] Altura do Box, se altura das linhas menores que o box       ╨╠╠
╠╠╨             Ё         [2] Margens Horizontais                                         ╨╠╠
╠╠╨             Ё         [3] Margens Verticais                                           ╨╠╠
╠╠╨             Ё ExpA2 = Array Multidimensional com os textos                            ╨╠╠
╠╠╨             Ё         [X] Array com as linhas                                         ╨╠╠
╠╠╨             Ё         [X,Y] Array com a coluna Y da linha N                           ╨╠╠
╠╠╨             Ё         [X,Y,Z] Array com os textos de cada coluna de cada linha        ╨╠╠
╠╠╨             Ё      ou [X,Y,N] Texto a ser impresso na "n" linha da coluna             ╨╠╠
╠╠╨             Ё         [X,Y,Z,N] Texto a ser impresso na "n" linha da coluna           ╨╠╠
╠╠╨             Ё ExpO1 = Objeto relativo a pАgina que esta sendo impressa                ╨╠╠
╠╠╨             Ё ExpN5 = Tipo de fonte a ser utilizada (mАximo 3) conforme array private ╨╠╠
╠╠╨             Ё         com a definiГЦo das fontes a serem utilizadas                   ╨╠╠
╠╠╨             Ё ExpA3 = Array com as propriedades do tМtulo quando utiliza um grid      ╨╠╠
╠╠╨             Ё         [C] Texto para o tМtulo                                         ╨╠╠
╠╠╨             Ё         [N] Tipo de fonte a ser utilizado no tМtulo                     ╨╠╠
╠╠╨             Ё         [C] Posicionamento do texto (L=left,R=right,C=center)           ╨╠╠
╠╠╨             Ё         [L] ImpressЦo de fundo com base na cor definida no array com as ╨╠╠
╠╠╨             Ё             fontes                                                      ╨╠╠
╠╠╨             Ё ExpA4 = Array com os posicionamentos de cada coluna                     ╨╠╠
╠╠╨             Ё         L = left, R = Right, C = center                                 ╨╠╠
╠╠╨             Ё ExpN6 = Coluna que receberА a sobra do espaГo das colunas em relaГЦo a  ╨╠╠
╠╠╨             Ё         pАgina                                                          ╨╠╠
╠╠╨             Ё ExpL1 = Identificador para impressЦo do box para cada linha/coluna      ╨╠╠
╠╠╨             Ё ExpA5 = Array contendo informaГУes da imagem                            ╨╠╠
╠╠╨             Ё         [C] Texto com o path e arquivo com a imagem                     ╨╠╠
╠╠╨             Ё         [N] Tamanho da altura da imgem                                  ╨╠╠
╠╠╨             Ё         [N] Tamanho da largura da imagem                                ╨╠╠
╠╠╨             Ё ExpL2 = Identificador para impressЦo em negrito da primeira linha do box╨╠╠
╠╠╨             Ё ExpL3 = Identificador para impressЦo do fundo colorido da primeira linha╨╠╠
╠╠╨             Ё         do box                                                          ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Retorno     Ё ExpA7 = Array com as novas coordenadas                                  ╨╠╠
╠╠╨             Ё         [1] PosiГЦo Inicial Vertical                                    ╨╠╠
╠╠╨             Ё         [2] PosiГЦo Inicial Horizontal                                  ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ObservaГУes Ё                                                                         ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ AlteraГУes  Ё 99.99.99 - Consultor - DescriГЦo da alteraГЦo                           ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠хмммммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
User Function DBMSR002( nPosVIni, nPosHIni, nPosVFim, nPosHFim, oPage, aCab, aImp )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define as variАveis da rotina                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se tem necessidade de imprimir o cabeГalho                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ValType( aCab[1] ) == "C"
	nCab	:= Val( aCab[1] )
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Obtem/Define a largura da pАgina                                                        Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nHPage := oPage:nHorzRes()
nHPage *= ( 300 / oPage:nLogPixelX() )
nHPage -= MARGEMH
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Obtem/Define a altura da pАgina                                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nVPage := oPage:nVertRes() 
nVPage *= ( 300/ oPage:nLogPixelY() )
nVPage -= MARGEMV
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajusta os parБmetros se informado                                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё SE FOR IMPRIMIR O CABEгALHO                                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nCab < 3 .and. nAuxV1 < 150 //Buscar tamanho do cabeГalho 
	ImpCabec( aCab[2], @nAuxV1, @nAuxV2 )
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё IMPRESSцO DO CABEгALHO DO GRID                                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ValType( aImp[01, A1_TITULO, A1_DATA] ) == "C" .And. !Empty( aImp[01, A1_TITULO, A1_DATA] )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime negrito                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A1_TITULO, A1_NEGRI] ) == "L"
		lNegrito	:= aImp[01, A1_TITULO, A1_NEGRI]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime sombreado                                                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A1_TITULO, A1_SOMBR] ) == "L"
		lSombra		:= aImp[01, A1_TITULO, A1_SOMBR]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime o box                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A1_TITULO, A1_BOX] ) == "L"
		lBox		:= aImp[01, A1_TITULO, A1_BOX]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a fonte a ser utilizada                                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A1_TITULO, A1_FONTE] ) == "N"
		nFonte		:= aImp[01, A1_TITULO, A1_FONTE]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define o posicionamento para o texto                                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A1_TITULO, A1_POSIC] ) == "C"
		cPosic		:= aImp[01, A1_TITULO, A1_POSIC]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define o label para impressЦo                                                       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A1_TITULO, A1_DATA] ) == "C"
		cLabel		:= aImp[01, A1_TITULO, A1_DATA]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Obtem o tamanho vertical do texto                                                   Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTxtVTam	:= Char2PixV(	oPage,;
								"X",;
								aFont[nFonte, If( lNegrito, 1, 2 )] )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Obtem o tamanho horizontal do texto                                                 Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTxtHTam	:= Char2PixH(	oPage,;
						  		cLabel,;
								aFont[nFonte, If( lNegrito, 1, 2 )] )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Obtem o espaГo vertical/horizontal do texto                                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nTxtVSpc	:= ( nTxtVTam * .25 )
	nTxtHSpc	:= Char2PixH(	oPage,;
								"X",;
								aFont[nFonte, If( lNegrito, 1, 2 )] )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Calcula os posicionametnos em funГЦo do tamanho do texto e fonte utilizados         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nAuxV1 += ( nTxtVSpc )
	nAuxV2 := ( nAuxV1 + nTxtVTam )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faz a ImpressЦo da sombra                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lSombra
		oPage:FillRect( {	nAuxV1 - nTxtVSpc,;
							nAuxH1,;
							nAuxV2 + nTxtVSpc,;
							nAuxH2 },;
							aFont[nFonte, 3] )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faz a impressЦo do texto alinhado a esquerda                                        Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cPosic == "L"
		oPage:Say(	nAuxV1,;
					nAuxH1,;
					cLabel,;
					aFont[nFonte, If( lNegrito, 1, 2 )] )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faz a impressЦo do texto alinhado a direita                                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ElseIf cPosic == "R"
		oPage:Say(	nAuxV1,;
					nAuxH2 - nTxtHTam,;
					cLabel,;
					aFont[nFonte, If( lNegrito, 1, 2 )] )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Faz a impressЦo do texto centralizado                                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Else
		oPage:Say(	nAuxV1,;
					nAuxH1 + (	( nAuxH2 - nAuxH1 ) - nTxtHTam ) / 2,;
					cLabel,;
					aFont[nFonte,If( lNegrito, 1, 2 )] )
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё AvanГa o posicionamento                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nAuxV1 := ( nAuxV2 + ( nTxtVSpc * 2 ) )
	nAuxV2 := ( nAuxV1 )
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё IMPRESSцO DO DO GRID                                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime negrito                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_NEGRI] ) == "L"
		lNegrito	:= aImp[01, A2_GRID, A2_NEGRI]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime sombreado                                                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_SOMBR] ) == "L"
		lSombra		:= aImp[01, A2_GRID, A2_SOMBR]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime o box                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_BOX] ) == "L"
		lBox		:= aImp[01, A2_GRID, A2_BOX]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a fonte a ser utilizada                                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_FONTE] ) == "N"
		nFonte		:= aImp[01, A2_GRID, A2_FONTE]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a fonte a ser utilizada                                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_AJUST] ) == "N"
		nColAju		:= aImp[01, A2_GRID, A2_AJUST]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Obtem a quantidade de linhas do grid                                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Obtem a quantiade de linhas do grid                                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nLnhQde	:= Len( aImp[01, A2_GRID, A2_DATA] )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Obtem a quantiade de colunas                                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nColQde := Len( aImp[01, A2_GRID, A2_DATA, nLnhQde] )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define a coluna inicial                                                         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nColIni	:= nAuxH1
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cria array com o tamanho e posiГЦo inicial/final horizontal                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nColuna := 1 To nColQde
			nColTam	:= 0
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Obtem o maior texto da coluna de cada linha                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nLinha := 1 To nLnhQde
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o label do texto                                                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o tamanho do label do texto                                       Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define qual o maior texto da coluna                                     Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nColTam < nTxtHTam
					nColTam := nTxtHTam
				EndIf
			Next nLinha
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define o tamanho horizontal de uma letra                                    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nTxtHTam	:= Char2PixH(	oPage,;
										"X",;
										aFont[nFonte, If( lNegrito, 1, 2 )] )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define a posiГЦo inicial da coluna                                          Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColIni	+= nTxtHTam
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define a posiГЦo final da coluna                                            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColFim	:= nColIni + nColTam
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Re-define o tamanho da coluna com os espaГos horizontais do label           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColTam	+= nTxtHTam * 2
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta o array com o tamanho, posiГЦo inicial e posiГЦo final             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aColuna,	{ nColTam, nColIni, nColFim } )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Re-define a posiГЦo inicial para a prСxima coluna                           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColIni	:= ( nColFim + nTxtHTam )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula os tamnhos de cada coluna para comparar posteriormente              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nLnhTam += nColTam
		Next nColuna
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Caso o Tamanho das colunas seja inferior ao do formulАrio, efetua o ajuste      Ё
		//Ё proporcional para cada coluna                                                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nLnhTam <= ( nAuxH2 - nAuxH1 )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё NЦo recebeu a coluna para ajuste, faz a distribuiГЦo entre todas            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nColAju == 0
				nDif := Int( ( ( nAuxH2 -  nAuxH1 ) - nLnhTam ) / nColQde )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Distribui a diferenГa entre as colunas                                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			    For nY := 1 To Len( aColuna )
					aColuna[nY,1] += nDif
					If nY > 1
						aColuna[nY,2] += ( nDif * ( nY - 1 ) )
					EndIf
					aColuna[nY,3] += ( nDif * nY )
				Next nY
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Recebeu a coluna para ajuste, faz o ajuste na coluna informada              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define o tamanho vertiacal da linha                                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nTxtVTam	:= Char2PixV(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nTxtVSpc	:= ( nTxtVTam * .25 )
		nTxtHSpc	:= Char2PixH(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nGrid		:= nAuxV1
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Varre todas as linhas                                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nLinha := 1 To nLnhQde
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё AvanГa o posicionamento                                                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nAuxV1 += ( If( nLinha > 1, nTxtVTam, 0 ) + nTxtVSpc )
			nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )
			For nColuna := 1 To nColQde
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define o posicionamento para o texto                                    Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ValType( aImp[01, A2_GRID, A2_POSIC, nColuna] ) == "C"
					cPosic		:= aImp[01, A2_GRID, A2_POSIC, nColuna]
				Else
					cPosic		:= "L"
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define o label para impressЦo                                           Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A"
					cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o tamanho vertical do texto                                       Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTxtVTam	:= Char2PixV(	oPage,;
											"X",;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o tamanho horizontal do texto                                     Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, 02] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a ImpressЦo da sombra                                               Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lSombra .And. nLinha == 1 .And. nColuna == 1
					oPage:FillRect( {	nAuxV1,;
										nAuxH1,;
										nAuxV2,;
										nAuxH2 },;
										aFont[nFonte, 3] )
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impressЦo do texto alinhado a direita                             Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If cPosic == "R"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,3] - nTxtHTam,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impressЦo do texto alinhado a esquerda                            Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				ElseIf cPosic == "L"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2],;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impress~~ao do texto centralizado                                 Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Else
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2] + (	( aColuna[nColuna,3] - aColuna[nColuna,2] ) - nTxtHTam ) / 2,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				EndIf
			Next nColuna
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se necessita trocar de pАgina                                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nAuxV2 > nVPage
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprime o box se necessАrio                                             Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				For nColuna := 1 To nColQde
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё SС faz o box se necessАrio                                          Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If lBox
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Linha Superior                                                  Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nGrid,;										// Linha Final
									aColuna[Len( aColuna ), 3] + nTxtHSpc )	// Coluna Final
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Linha Inferior                                                  Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						oPage:Line(	nAuxV2 + nTxtVSpc,;							// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[Len( aColuna ), 3] + nTxtHSpc )	// Coluna Final
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Coluna Esquerda                                                 Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[1,2] - nTxtHSpc )					// Coluna Final
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Demais Colunas                                                  Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[nColuna, 3] + nTxtHSpc,;			// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[nColuna, 3] + nTxtHSpc )			// Coluna Final
					EndIf
				Next nColuna
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Encerra a pАgina                                                        Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
				
				oPage:EndPage()
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inicializa nova pАgina                                                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				oPage:StartPage()
								
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inicializa o posicionamento inicial                                     Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nAuxV1	:= MARGEMV
				nAuxV2	:= MARGEMV
				nAuxH1	:= MARGEMH
   
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё SE FOR IMPRIMIR O CABEгALHO                                                             Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nCab == 2
					ImpCabec( aCab[2], @nAuxV1, @nAuxV2 )
				EndIf 
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё AvanГa o posicionamento                                                 Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nAuxV1 += nTxtVSpc
				nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc ) 
				
				NgRID	:= nAuxV1 	
				
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impressЦo da 1a. linha (cabeГalho do grid) na pАgina nova         Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				For nColuna := 1 To nColQde  
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Define o posicionamento para o texto                                    Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If ValType( aImp[01, A2_GRID, A2_POSIC, nColuna] ) == "C"
						cPosic		:= aImp[01, A2_GRID, A2_POSIC, nColuna]
					Else
						cPosic		:= "L"
					EndIf
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Define o label para impressЦo                                           Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" 
						cLabel		:= aImp[01, A2_GRID, A2_DATA, 1, nColuna]
					EndIf
					
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Obtem o tamanho vertical do texto                                       Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nTxtVTam	:= Char2PixV(	oPage,;
												"X",;
												aFont[nFonte, If( lNegrito, 1, 2 )] )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Obtem o tamanho horizontal do texto                                     Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nTxtHTam	:= Char2PixH(	oPage,;
										  		cLabel,;
												aFont[nFonte, 02] )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Faz a ImpressЦo da sombra                                               Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If lSombra .And. nColuna == 1
						oPage:FillRect( {	nAuxV1,;
											nAuxH1,;
											nAuxV2,;
											nAuxH2 },;
											aFont[nFonte, 3] )
					EndIf
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Faz a impressЦo do texto alinhado a direita                         Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If cPosic == "R"
						oPage:Say(	nAuxV1,;
									aColuna[nColuna,03] - nTxtHTam,;
									cLabel,;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Faz a impressЦo do texto alinhado a esquerda                        Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					ElseIf cPosic == "L"
						oPage:Say(	nAuxV1,;
									aColuna[nColuna,02],;
									cLabel,;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Faz a impressЦo do texto centralizado                               Ё
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Else
						oPage:Say(	nAuxV1,;
									aColuna[nColuna,02] + ( ( aColuna[nColuna,03] - aColuna[nColuna,02] ) - nTxtHTam ) / 2,;
									cLabel,;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
					EndIf
				Next nColuna
			EndIf
		Next nLinha
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime o box se necessАrio                                                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lBox
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Varre todas as colunas                                                      Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nColuna := 1 To nColQde
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha Superior                                                          Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				oPage:Line(	nGrid,;											// Linha Inicial
							aColuna[1,2] - nTxtHSpc,;						// Coluna Inicial
							nGrid,;											// Linha Final
							aColuna[Len( aColuna ), 3] + nTxtHSpc )		// Coluna Final
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Linha Inferior                                                          Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				oPage:Line(	nAuxV2 + nTxtVSpc,;								// Linha Inicial
							aColuna[1,2] - nTxtHSpc,;						// Coluna Inicial
							nAuxV2 + nTxtVSpc,;								// Linha Final
							aColuna[Len( aColuna ), 3] + nTxtHSpc )		// Coluna Final
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Coluna Esquerda                                                         Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				oPage:Line(	nGrid,;											// Linha Inicial
							aColuna[1,2] - nTxtHSpc,;						// Coluna Inicial
							nAuxV2 + nTxtVSpc,;								// Linha Final
							aColuna[1,2] - nTxtHSpc )						// Coluna Final
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Demais Colunas                                                          Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				oPage:Line(	nGrid,;											// Linha Inicial
							aColuna[nColuna, 3] + nTxtHSpc,;				// Coluna Inicial
							nAuxV2 + nTxtVSpc,;								// Linha Final
							aColuna[nColuna, 3] + nTxtHSpc )				// Coluna Final
			Next nColuna
		EndIf
	EndIf
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorna os posicionamento final                                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( { nAuxV2, nAuxH1 } )


/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠имммммммммммммяммммммммммямммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩╠╠
╠╠╨ Programa    ЁChar2PixH Ё Define a largura do caracter em pixel de acordo com o tamanho╨╠╠
╠╠╨             Ё          Ё  da fonte                                                    ╨╠╠
╠╠лмммммммммммммьммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Autor       Ё 27.12.08 Ё Almir Bandina                                                ╨╠╠
╠╠лмммммммммммммьммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ParБmetros  Ё ExpO1 = Objeto relativo a pАgina que esta sendo impressa                ╨╠╠
╠╠╨             Ё ExpC1 = Texto a ser calculado                                           ╨╠╠ 
╠╠╨             Ё ExpO2 = Fonte a ser considerada no cАlculo                              ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Retorno     Ё ExpN1 = Tamanho do texto na horizontal                                  ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ObservaГУes Ё                                                                         ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ AlteraГУes  Ё 99.99.99 - Consultor - DescriГЦo da alteraГЦo                           ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠хмммммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function Char2PixH( oPage, cTexto, oFont )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define as variАveis da rotina                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nX := 0

DEFAULT aUltChar2pix := {}  
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se ainda nЦo foi calculado                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nX := aScan( aUltChar2pix,{ |x| x[1] == cTexto .And. x[2] == oFont } )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for calculo novo, acrescenta ao array a informaГЦo                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nX == 0
	aAdd( aUltChar2pix, {	cTexto,;
							oFont,;
							oPage:GetTextWidht( cTexto, oFont) * ( 245 / oPage:nLogPixelX() ) } )  
	nX := Len( aUltChar2pix )
EndIf

Return( aUltChar2pix[nX,3] )


/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠имммммммммммммяммммммммммямммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩╠╠
╠╠╨ Programa    ЁChar2PixH Ё Define a altura do caracter em pixel de acordo com o tamanho ╨╠╠
╠╠╨             Ё          Ё  da fonte                                                    ╨╠╠
╠╠лмммммммммммммьммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Autor       Ё 27.12.08 Ё Almir Bandina                                                ╨╠╠
╠╠лмммммммммммммьммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ParБmetros  Ё ExpO1 = Objeto relativo a pАgina que esta sendo impressa                ╨╠╠
╠╠╨             Ё ExpC1 = Texto a ser calculado                                           ╨╠╠ 
╠╠╨             Ё ExpO2 = Fonte a ser considerada no cАlculo                              ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Retorno     Ё ExpN1 = Tamanho do texto na horizontal                                  ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ObservaГУes Ё                                                                         ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ AlteraГУes  Ё 99.99.99 - Consultor - DescriГЦo da alteraГЦo                           ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠хмммммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Static Function Char2PixV( oPage, cChar, oFont )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define as variАveis da rotina                                                           Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local nX := 0

DEFAULT aUltVChar2pix := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Obtem o primeiro caracter do texto                                                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cChar := SubStr( cChar, 1, 1 )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se ainda nЦo foi calculado                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nX := aScan( aUltVChar2pix,{ |x| x[1] == cChar .And. x[2] == oFont } )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for calculo novo, acrescenta ao array a informaГЦo                                   Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nX == 0
	aAdd( aUltVChar2pix, {	cChar,;
							oFont,;
							oPage:GetTextHeight( cChar, oFont ) * ( ESPLINHA / oPage:nLogPixelY() ) } )
	nX := Len( aUltVChar2pix )
EndIf

Return( aUltVChar2pix[nX,3] ) 


/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠имммммммммммммяммммммммммямммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩╠╠
╠╠╨ Programa    ЁImpCabec  Ё Faz a impressao do cabecalho nas paginas 					  ╨╠╠
╠╠╨             Ё          Ё                                                              ╨╠╠
╠╠лмммммммммммммьммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Autor       Ё 27.12.08 Ё Almir Bandina                                                ╨╠╠
╠╠лмммммммммммммьммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ParБmetros  Ё ExpO1 = Conteudo a ser impresso							              ╨╠╠
╠╠╨             Ё ExpC1 = Posicao                               				          ╨╠╠ 
╠╠╨             Ё ExpO2 = Posicao								                          ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ Retorno     Ё  											                              ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ ObservaГУes Ё                                                                         ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠лмммммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨ AlteraГУes  Ё 99.99.99 - Consultor - DescriГЦo da alteraГЦo                           ╨╠╠
╠╠╨             Ё                                                                         ╨╠╠
╠╠хмммммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/


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
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime negrito                                                           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_NEGRI] ) == "L"
		lNegrito	:= aImp[01, A2_GRID, A2_NEGRI]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime sombreado                                                         Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_SOMBR] ) == "L"
		lSombra		:= aImp[01, A2_GRID, A2_SOMBR]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define se imprime o box                                                             Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_BOX] ) == "L"
		lBox		:= aImp[01, A2_GRID, A2_BOX]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a fonte a ser utilizada                                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_FONTE] ) == "N"
		nFonte		:= aImp[01, A2_GRID, A2_FONTE]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define a fonte a ser utilizada                                                      Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_AJUST] ) == "N"
		nColAju		:= aImp[01, A2_GRID, A2_AJUST]
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Obtem a quantidade de linhas do grid                                                Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A" .And. Len( aImp[01, A2_GRID, A2_DATA] ) <> 0
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Obtem a quantiade de linhas do grid                                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nLnhQde	:= Len( aImp[01, A2_GRID, A2_DATA] )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Obtem a quantiade de colunas                                                    Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nColQde := Len( aImp[01, A2_GRID, A2_DATA, nLnhQde] )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define a coluna inicial                                                         Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nColIni	:= nAuxH1
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Cria array com o tamanho e posiГЦo inicial/final horizontal                     Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nColuna := 1 To nColQde
			nColTam	:= 0
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Obtem o maior texto da coluna de cada linha                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nLinha := 1 To nLnhQde
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o label do texto                                                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		    	cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]

				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o tamanho do label do texto                                       Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define qual o maior texto da coluna                                     Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If nColTam < nTxtHTam
					nColTam := nTxtHTam
				EndIf
			Next nLinha
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define o tamanho horizontal de uma letra                                    Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nTxtHTam	:= Char2PixH(	oPage,;
										"X",;
										aFont[nFonte, If( lNegrito, 1, 2 )] )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define a posiГЦo inicial da coluna                                          Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColIni	+= nTxtHTam
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Define a posiГЦo final da coluna                                            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColFim	:= nColIni + nColTam
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Re-define o tamanho da coluna com os espaГos horizontais do label           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColTam	+= nTxtHTam * 2
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta o array com o tamanho, posiГЦo inicial e posiГЦo final             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aAdd( aColuna,	{ nColTam, nColIni, nColFim } )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Re-define a posiГЦo inicial para a prСxima coluna                           Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nColIni	:= ( nColFim + nTxtHTam )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Acumula os tamnhos de cada coluna para comparar posteriormente              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nLnhTam += nColTam
		Next nColuna
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Caso o Tamanho das colunas seja inferior ao do formulАrio, efetua o ajuste      Ё
		//Ё proporcional para cada coluna                                                   Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nLnhTam <= ( nAuxH2 - nAuxH1 )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё NЦo recebeu a coluna para ajuste, faz a distribuiГЦo entre todas            Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nColAju == 0
				nDif := Int( ( ( nAuxH2 -  nAuxH1 ) - nLnhTam ) / nColQde )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Distribui a diferenГa entre as colunas                                  Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			    For nY := 1 To Len( aColuna )
					aColuna[nY,1] += nDif
					If nY > 1
						aColuna[nY,2] += ( nDif * ( nY - 1 ) )
					EndIf
					aColuna[nY,3] += ( nDif * nY )
				Next nY
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Recebeu a coluna para ajuste, faz o ajuste na coluna informada              Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Define o tamanho vertiacal da linha                                             Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nTxtVTam	:= Char2PixV(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nTxtVSpc	:= ( nTxtVTam * .25 )
		nTxtHSpc	:= Char2PixH(	oPage,;
									"X",;
									aFont[nFonte, If( lNegrito, 1, 2 )] )
		nGrid		:= nAuxV1
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Varre todas as linhas                                                           Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nLinha := 1 To nLnhQde
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё AvanГa o posicionamento                                                     Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nAuxV1 += ( If( nLinha > 1, nTxtVTam, 0 ) + nTxtVSpc )
			nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )
			For nColuna := 1 To nColQde
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define o posicionamento para o texto                                    Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ValType( aImp[01, A2_GRID, A2_POSIC, nColuna] ) == "C"
					cPosic		:= aImp[01, A2_GRID, A2_POSIC, nColuna]
				Else
					cPosic		:= "L"
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Define o label para impressЦo                                           Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ValType( aImp[01, A2_GRID, A2_DATA] ) == "A"  
					cLabel		:= aImp[01, A2_GRID, A2_DATA, nLinha, nColuna]
				EndIf
				If "nPage" $ cLabel
					nPag := oPage:nPage
					cLabel := StrTran(cLabel,"nPage",StrZero(nPag,6))
				Endif
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o tamanho vertical do texto                                       Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTxtVTam	:= Char2PixV(	oPage,;
											"X",;
											aFont[nFonte, If( lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem o tamanho horizontal do texto                                     Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nTxtHTam	:= Char2PixH(	oPage,;
									  		cLabel,;
											aFont[nFonte, 02] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a ImpressЦo da sombra                                               Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lSombra .And. nLinha == 1 .And. nColuna == 1
					oPage:FillRect( {	nAuxV1,;
										nAuxH1,;
										nAuxV2,;
										nAuxH2 },;
										aFont[nFonte, 3] )
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impressЦo do texto alinhado a direita                             Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If cPosic == "R"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,3] - nTxtHTam,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impressЦo do texto alinhado a esquerda                            Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				ElseIf cPosic == "L"
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2],;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Faz a impress~~ao do texto centralizado                                 Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Else
					oPage:Say(	nAuxV1,;
								aColuna[nColuna,2] + (	( aColuna[nColuna,3] - aColuna[nColuna,2] ) - nTxtHTam ) / 2,;
								cLabel,;
								aFont[nFonte, If( nLinha == 1 .And. lNegrito, 1, 2 )] )
				EndIf
			Next nColuna
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Imprime o box se necessАrio                                             Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			For nColuna := 1 To nColQde
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё SС faz o box se necessАrio                                          Ё
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If lBox
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Linha Superior                                                  Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					   	oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nGrid,;										// Linha Final
									aColuna[Len( aColuna ), 3] + nTxtHSpc )	// Coluna Final 
					    
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Linha Inferior                                                  Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					  /* 	oPage:Line( nAuxV2 + nTxtVSpc,;					// Linha Inicial 
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
								   	nAuxV2 + nTxtVSpc ,;				// Linha Final
									aColuna[Len( aColuna ),3] + nTxtHSpc ) 		// Coluna Final   
						*/			
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Coluna Esquerda                                                 Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[1,2] - nTxtHSpc,;					// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[1,2] - nTxtHSpc )					// Coluna Final
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Demais Colunas                                                  Ё
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						oPage:Line(	nGrid,;										// Linha Inicial
									aColuna[nColuna, 3] + nTxtHSpc,;			// Coluna Inicial
									nAuxV2 + nTxtVSpc,;							// Linha Final
									aColuna[nColuna, 3] + nTxtHSpc )			// Coluna Final
					EndIf
			Next nColuna          
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё AvanГa o posicionamento                                                 Ё
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nAuxV1 += nTxtVSpc
			nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )    
		Next nLinha  
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Linha Inferior                                                  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		oPage:Line( nAuxV2,;						// Linha Inicial 
					aColuna[1,2] - nTxtHSpc,;				// Coluna Inicial
				   	nAuxV2,;					// Linha Final
					aColuna[Len( aColuna ),3] + nTxtHSpc )	// Coluna Final 
	EndIf
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё AvanГa o posicionamento                                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nAuxV1 += nTxtVSpc * 10
	nAuxV2 := ( nAuxV1 + nTxtVTam + nTxtVSpc )  

Return( Nil )
