#include 'totvs.ch'
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"


#DEFINE IMP_PDF 6
#DEFINE nAzulPet RGB(1,107,138)
#DEFINE nCinza   RGB(191,191,191)

#DEFINE oPAzulP TBrush():New(,nAzulPet)
#DEFINE oPCinza TBrush():New(,nCinza)

//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2



/*/{Protheus.doc} PEFAT01
Gera relatório em PDF com informações formatadas, incluindo cabeçalho, tabela de itens e visualização do documento, utilizando recursos gráficos do Protheus.
@type function
@version 1.0
@author Lucas Apolinario
@since 15/09/2025
*/
User Function PEFAT01()
	Local aArea     := FwGetArea()
    Local cFonte    := "Arial"
    Local cFile     := "_"+FwTimeStamp()+".pdf"
    Local lDisabeSetup := .T.

	Private nPag 	:= 1
	Private nLinha 	:= 0
	Private nLinFin := 2500
	Private nTamMax := 010

	Private oFnt8   := TFont():New( cFonte, NIL,  8, NIL, .F., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt8N  := TFont():New( cFonte, NIL,  8, NIL, .T., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt10  := TFont():New( cFonte, NIL, 10, NIL, .F., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt10N := TFont():New( cFonte, NIL, 10, NIL, .T., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt12  := TFont():New( cFonte, NIL, 12, NIL, .F., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt12N := TFont():New( cFonte, NIL, 12, NIL, .T., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt14  := TFont():New( cFonte, NIL, 14, NIL, .F., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt14N := TFont():New( cFonte, NIL, 14, NIL, .T., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt16  := TFont():New( cFonte, NIL, 16, NIL, .F., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt16N := TFont():New( cFonte, NIL, 16, NIL, .T., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt20  := TFont():New( cFonte, NIL, 20, NIL, .F., NIL, NIL, NIL, NIL, .F., .F. )
	Private oFnt20N := TFont():New( cFonte, NIL, 20, NIL, .T., NIL, NIL, NIL, NIL, .F., .F. )
	
	DbSelectArea("SD2")
	SD2->(DbSetOrder(8))
	IF SD2->(MsSeek(xFilial("SD2") + SC9->C9_PEDIDO))

		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))
		IF SF2->(MsSeek(xFilial("SF2") + SD2->D2_DOC + SD2->D2_SERIE))
	

			oPrint := FWMSPrinter():New( cFile, IMP_PDF, /*lAdjustToLegacy*/, /*cPathInServer*/, lDisabeSetup )
			oPrint:SetPortrait()
			oPrint:SetPaperSize( 9 ) // A4 - 210mm x 297mm  - 620 x 876
			oPrint:SetViewPDF(.T.)

			
			FWMsgRun(, {|| startImp() }, "Processando", "Processando dados para o relatório!")
     

			oPrint:EndPage()
			oPrint:Preview()

			FreeObj(oPrint)

		ENDIF
	else
		FWALERTWARNING("Não há nota fiscal gerada com o pedido posicionado!", "Atenção")
	ENDIF

	SF2->(DbCloseArea())
	SD2->(DbCloseArea())

	FwRestArea(aArea)
Return



/*/{Protheus.doc} startImp
realiza chamada das funcoes de impressao de cabecalho
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
/*/
static function startImp()

	IF cCabecalho()
		nLinha := 900
		cHeaderTable()
		FWMsgRun(, {|oSay| cImpItems(oSay) }, "Processando", "Processando dados para o relatório!")
		cImpRod()
	ENDIF

Return

/*/{Protheus.doc} cCabecalho
Função responsável por montar e executar a query que busca os dados do cabeçalho da nota fiscal, pedido e cliente, para impressão do relatório.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
@return Logical, .T. se encontrou os dados do cabeçalho, .F. caso contrário.
/*/
Static Function cCabecalho()
	Local _cQuery 		:= ""
	Local oStateQry 	:= Nil
	Local _lRet         := .f.

	IF SELECT("QTEMP") > 0
		QTEMP->(DbCloseArea())
	EndIf

	_cQuery += " SELECT TOP 1 F2_DOC,F2_SERIE,F2_EMISSAO,CK_NUM,C5_NUM,C5_CLIENTE,A1_NOME,A1_END,A1_COMPLEM,A1_BAIRRO,A1_MUN,A1_EST,A1_ENDENT,A1_COMPENT,A1_BAIRROE,A1_MUNE,A1_ESTE   " 
	_cQuery += " FROM "+RETSQLNAME("SF2")+" SF2   " 
	_cQuery += " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL " 
	_cQuery += "        AND SD2.D2_DOC = SF2.F2_DOC                     " 
	_cQuery += "        AND SD2.D2_SERIE = SF2.F2_SERIE                 " 
	_cQuery += "        AND SD2.D2_CLIENTE = SF2.F2_CLIENTE             " 
	_cQuery += "        AND SD2.D2_LOJA = SF2.F2_LOJA                   " 
	_cQuery += "        AND SD2.D_E_L_E_T_ = ' '                        " 
	_cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+" SC5 ON SC5.C5_FILIAL = SD2.D2_FILIAL  " 
	_cQuery += "        AND SC5.C5_CLIENTE = SD2.D2_CLIENTE             " 
	_cQuery += "        AND SC5.C5_LOJACLI = SD2.D2_LOJA                " 
	_cQuery += "        AND SC5.C5_NUM = SD2.D2_PEDIDO                  " 
	_cQuery += "        AND SC5.D_E_L_E_T_ = ' '                        " 
	_cQuery += " LEFT JOIN "+RETSQLNAME("SCK")+" SCK ON SCK.CK_FILIAL = SC5.C5_FILIAL  " 
	_cQuery += "        AND SCK.CK_NUMPV = SC5.C5_NUM                   " 
	_cQuery += "        AND SCK.D_E_L_E_T_ = ' '                        " 
	_cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD = SC5.C5_CLIENTE   " 
	_cQuery += "        AND SA1.A1_LOJA = SC5.C5_LOJACLI                " 
	_cQuery += "        AND SA1.D_E_L_E_T_ = ' '                        " 
	_cQuery += " WHERE  SF2.F2_DOC         = ?                          " 
	_cQuery += "        AND SF2.F2_SERIE   = ?                          " 
	_cQuery += "        AND SF2.F2_FILIAL  = ?                          "
	_cQuery += "        AND SF2.F2_CLIENTE = ?                          "
	_cQuery += "        AND SF2.F2_LOJA    = ?                          "
	_cQuery += "        AND SF2.D_E_L_E_T_ = ''                         "

	oStateQry := FWPreparedStatement():New()
	oStateQry:SetQuery(_cQuery)
	oStateQry:SetString(1,SF2->F2_DOC)
	oStateQry:SetString(2,SF2->F2_SERIE)
	oStateQry:SetString(3,xFilial("SF2"))
	oStateQry:SetString(4,SF2->F2_CLIENTE)
	oStateQry:SetString(5,SF2->F2_LOJA)

	_cQuery := oStateQry:GetFixQuery()



	PLSQUERY(_cQuery, "QTEMP")
	
	IF ! QTEMP->(eof())
		_lRet := .t.
		oPrint:StartPage()

		// Logotipo
		IF File(GetSrvProfString('Startpath', '') + "cavannanobg.png")
			oPrint:SayBitMap(180,200,GetSrvProfString('Startpath', '') + "cavannanobg.png",220,220)
		ENDIF
		// Linha Azul do Logotipo
		oPrint:FillRect({285,370,295,2200},oPAzulP)


		oPrint:SayAlign(420,210,"Nº Nota Fiscal",oFnt12N,gLargura("Nº Nota Fiscal",oFnt12N),gAltura("Nº Nota Fiscal",oFnt12N),,PAD_LEFT,0)
		oPrint:SayAlign(470,210,QTEMP->F2_DOC,oFnt12,gLargura(QTEMP->F2_DOC,oFnt12),gAltura(QTEMP->F2_DOC,oFnt12),,PAD_LEFT,0)

		oPrint:SayAlign(420,540,"Data de Emissão",oFnt12N,gLargura("Data de Emissão",oFnt12N),gAltura("Data de Emissão",oFnt12N),,PAD_CENTER,0)
		oPrint:SayAlign(470,590,DTOC(QTEMP->F2_EMISSAO),oFnt12,gLargura(DTOC(QTEMP->F2_EMISSAO),oFnt12),gAltura(DTOC(QTEMP->F2_EMISSAO),oFnt12),,PAD_CENTER,0)



		oPrint:SayAlign(420,980,"Nº do Orçamento de Venda",oFnt12N,gLargura("Nº do Orçamento de Venda",oFnt12N),gAltura("Nº do Orçamento de Venda",oFnt12N),,PAD_LEFT,0)
		oPrint:SayAlign(470,980,QTEMP->CK_NUM,oFnt12,gLargura(QTEMP->CK_NUM,oFnt12),gAltura(QTEMP->CK_NUM,oFnt12),,PAD_LEFT,0)

		oPrint:SayAlign(420,1450,"Nº do Pedido",oFnt12N,gLargura("Nº do Pedido",oFnt12N),gAltura("Nº do Pedido",oFnt12N),,PAD_LEFT,0)
		oPrint:SayAlign(470,1450,QTEMP->C5_NUM,oFnt12,gLargura(QTEMP->C5_NUM,oFnt12),gAltura(QTEMP->C5_NUM,oFnt12),,PAD_LEFT,0)

		oPrint:SayAlign(420,1800,"Cliente",oFnt12N,gLargura("Cliente",oFnt12N),gAltura("Cliente",oFnt12N),,PAD_LEFT,0)
		oPrint:SayAlign(470,1800,QTEMP->C5_CLIENTE,oFnt12,gLargura(QTEMP->C5_CLIENTE,oFnt12),gAltura(QTEMP->C5_CLIENTE,oFnt12),,PAD_LEFT,0)


		oPrint:SayAlign(550,210,"PACKING LIST",oFnt20N,gLargura("PACKING LIST",oFnt20N),gAltura("PACKING LIST",oFnt20N),,PAD_LEFT,0)


		oPrint:SayAlign(650,210,"Endereço do Cliente:",oFnt12N,gLargura("Endereço do Cliente:",oFnt12N),gAltura("Endereço do Cliente:",oFnt12N),,PAD_LEFT,0)
		oPrint:SayAlign(650,540,Alltrim(QTEMP->A1_NOME),oFnt12,gLargura(Alltrim(QTEMP->A1_NOME),oFnt12),gAltura(Alltrim(QTEMP->A1_NOME),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(700,540,Alltrim(QTEMP->A1_END),oFnt12,gLargura(Alltrim(QTEMP->A1_END),oFnt12),gAltura(Alltrim(QTEMP->A1_END),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(730,540,Alltrim(QTEMP->A1_COMPLEM),oFnt12,gLargura(Alltrim(QTEMP->A1_COMPLEM),oFnt12),gAltura(Alltrim(QTEMP->A1_COMPLEM),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(760,540,Alltrim(QTEMP->A1_BAIRRO),oFnt12,gLargura(Alltrim(QTEMP->A1_BAIRRO),oFnt12),gAltura(Alltrim(QTEMP->A1_BAIRRO),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(790,540,Alltrim(QTEMP->A1_MUN) + " - " + Alltrim(QTEMP->A1_EST),oFnt12,gLargura(Alltrim(QTEMP->A1_MUN) + " - " + Alltrim(QTEMP->A1_EST),oFnt12),gAltura(Alltrim(QTEMP->A1_MUN) + " - " + Alltrim(QTEMP->A1_EST),oFnt12),,PAD_LEFT,0)

		oPrint:SayAlign(650,1300,"Endereço de Entrega:",oFnt12N,gLargura("Endereço de Entrega:",oFnt12N),gAltura("Endereço de Entrega:",oFnt12N),,PAD_LEFT,0)
		oPrint:SayAlign(650,1630,Alltrim(QTEMP->A1_NOME),oFnt12,gLargura(Alltrim(QTEMP->A1_NOME),oFnt12),gAltura(Alltrim(QTEMP->A1_NOME),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(700,1630,Alltrim(QTEMP->A1_ENDENT),oFnt12,gLargura(Alltrim(QTEMP->A1_ENDENT),oFnt12),gAltura(Alltrim(QTEMP->A1_ENDENT),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(730,1630,Alltrim(QTEMP->A1_COMPENT),oFnt12,gLargura(Alltrim(QTEMP->A1_COMPENT),oFnt12),gAltura(Alltrim(QTEMP->A1_COMPENT),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(760,1630,Alltrim(QTEMP->A1_BAIRROE),oFnt12,gLargura(Alltrim(QTEMP->A1_BAIRROE),oFnt12),gAltura(Alltrim(QTEMP->A1_BAIRROE),oFnt12),,PAD_LEFT,0)
		oPrint:SayAlign(790,1630,Alltrim(QTEMP->A1_MUNE) + " - " + Alltrim(QTEMP->A1_ESTE),oFnt12,gLargura(Alltrim(QTEMP->A1_MUNE) + " - " + Alltrim(QTEMP->A1_ESTE),oFnt12),gAltura(Alltrim(QTEMP->A1_MUNE) + " - " + Alltrim(QTEMP->A1_ESTE),oFnt12),,PAD_LEFT,0)
	EndIf

	QTEMP->(DbCloseArea())

Return _lRet


/*/{Protheus.doc} cHeaderTable
Cabeçalho da tabela de itens do Packing List. Desenha as colunas e títulos do relatório de itens.
@type function
@version  12.2410
@author Lucas Apolinario
@since 22/09/2025
/*/
Static Function cHeaderTable()
	Local aArea   :=  FwGetArea()

	oPrint:FillRect({nLinha,210, nLinha+100,2200},oPCinza)

	oPrint:Line( nLinha, 210, nLinha, 2200)
	oPrint:Line( nLinha+100, 210, nLinha+100, 2200)
	oPrint:Line( nLinha, 210, nLinha+100, 210)
	oPrint:SayAlign(nLinha, 210, 'Pos.', oFnt10N, gLargura("Pos.", oFnt10N),gAltura("Pos.", oFnt10N), /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 280, nLinha+100, 280)
	oPrint:SayAlign(nLinha, 310, 'Codigo - Descrição', oFnt10N, gLargura("Codigo - Descrição",oFnt10N ), gAltura("Codigo - Descrição",oFnt10N ), /*nClrText*/, PAD_CENTER, 0) 

	oPrint:Line( nLinha, 700, nLinha+100, 700)
	oPrint:SayAlign(nLinha, 715, 'Quant.', oFnt10N, gLargura("Quant.", oFnt10N),gAltura("Quant.", oFnt10N), /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 850, nLinha+100, 850)
	oPrint:SayAlign(nLinha, 880, 'Material', oFnt10N, gLargura("Material", oFnt10N),gAltura("Material", oFnt10N), /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 1070, nLinha+100, 1070)
	oPrint:SayAlign(nLinha, 1070, 'Peso Líquido Unitário (KG)', oFnt10N, gLargura("Peso Líquido Unitário (KG)", oFnt10N)/2,gAltura("Peso Líquido Unitário (KG)", oFnt10N)*2, /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 1270, nLinha+100, 1270)
	oPrint:SayAlign(nLinha, 1270, 'Peso Líquido Total (KG)', oFnt10N, gLargura("Peso Líquido Total (KG)", oFnt10N)/2,gAltura("Peso Líquido Total (KG)", oFnt10N)*2, /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 1490, nLinha+100, 1490)
	oPrint:SayAlign(nLinha, 1490, 'Cert. Origem', oFnt10N, gLargura("Cert. Origem", oFnt10N),gAltura("Cert. Origem", oFnt10N), /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 1710, nLinha+100, 1710)
	oPrint:SayAlign(nLinha, 1900, 'Foto', oFnt10N, gLargura("Foto", oFnt10N),gAltura("Foto", oFnt10N), /*nClrText*/, PAD_CENTER, 0) 
	oPrint:Line( nLinha, 2200, nLinha+100, 2200)

	nLinha += 100

	FwRestArea(aArea)

Return

/*/{Protheus.doc} cImpItems
Função responsável por imprimir os itens do Packing List no relatório.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
/*/
static Function cImpItems(oSay)
	Local nCol 		:= 210
	Local nAltura 	:= 200
	Local nLargura 	:= 70
	Local nProxLin  := 0
	Local _nX       := 0
	Local _nY       := 0
	Local _cProd    := ''
	Local _cConteudo := ''
	Local cDirPhoto := '\dirdoc\co'+cEmpAnt+'\shared\'
	Local _cPhoto   := ''
	Local _cQuery   := ""
	Local oStateQry := Nil
	Local _nTQuery:= 0


	oSay:SetText("Processando items...")

	if SELECT("QTEMP") > 0
		QTEMP->(DbCloseArea())
	EndIf

	_cQuery += " SELECT D2_ITEM, D2_COD, B1_DESC, D2_QUANT, B5_CEME, B1_PESO, B1_PESO, B5_CERT  " 
	_cQuery += " FROM "+RetSqlName("SF2")+" SF2   " 
	_cQuery += " INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL   " 
	_cQuery += "        AND SD2.D2_DOC = SF2.F2_DOC   " 
	_cQuery += "        AND SD2.D2_SERIE = SF2.F2_SERIE   " 
	_cQuery += "        AND SD2.D2_CLIENTE = SF2.F2_CLIENTE   " 
	_cQuery += "        AND SD2.D2_LOJA = SF2.F2_LOJA   " 
	_cQuery += "        AND SD2.D_E_L_E_T_ = ' '   " 
	_cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = SD2.D2_FILIAL AND SB1.B1_COD = SD2.D2_COD  " 
	_cQuery += " LEFT JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = SD2.D2_FILIAL AND SB5.B5_COD = SD2.D2_COD   " 
	_cQuery += " WHERE  SF2.F2_DOC         = ?                          " 
	_cQuery += "        AND SF2.F2_SERIE   = ?                          " 
	_cQuery += "        AND SF2.F2_FILIAL  = ?                          "
	_cQuery += "        AND SF2.F2_CLIENTE = ?                          "
	_cQuery += "        AND SF2.F2_LOJA    = ?                          "
	_cQuery += "        AND SF2.D_E_L_E_T_ = ''                         "
	_cQuery += "        ORDER BY D2_ITEM ASC                            "

	oStateQry := FWPreparedStatement():New()
	oStateQry:SetQuery(_cQuery)
	oStateQry:SetString(1,SF2->F2_DOC)
	oStateQry:SetString(2,SF2->F2_SERIE)
	oStateQry:SetString(3,xFilial("SF2"))
	oStateQry:SetString(4,SF2->F2_CLIENTE)
	oStateQry:SetString(5,SF2->F2_LOJA)

	_cQuery := oStateQry:GetFixQuery()



	DBUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QTEMP", .T., .T. )
	
	Count to _nTQuery
	

	QTEMP->(DBGOTOP())

	IF _nTQuery > 0 
		DbSelectArea("AC9")
		AC9->(DbSetOrder(2))
		DbSelectArea("ACB")
		ACB->(DbSetOrder(1))


		WHILE QTEMP->(!EOF())
			_nX++
			_cPhoto := ''
			
			oSay:SetText("Item "+cValToChar(_nX) + " de " + cValToChar(_nTQuery) + "...")
          
			_cProd := QTEMP->D2_COD

			fQuebra(.t.,10)

			if AC9->(MsSeek(xFilial("AC9")  + "SB1" + xFilial("AC9") + AVKEY(_cProd,"B1_PROD")))
				IF ACB->(MsSeek(xFilial("ACB") + AC9->AC9_CODOBJ))
					_cPhoto := cDirPhoto + ACB->ACB_OBJETO
				ENDIF
			ENDIF
		

			nLargura 	:= 70
			nCol 		:= 210
			nProxLin 	:= nLinha + nAltura

			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX DO "POS."
			oPrint:SayAlign(nLinha, nCol+10, QTEMP->D2_ITEM, oFnt10, nCol+nLargura,nLinFin+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			nCol += nLargura
			nLargura := 420

			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX DO "CODIGO - DESCRIÇÃO
			_cConteudo := Alltrim(QTEMP->D2_COD) +" - " +Alltrim(QTEMP->B1_DESC)
			if len(_cConteudo) > 25
				_cSubLin := nLinha
				
				for _nY := 1 to 5
					oPrint:SayAlign(_cSubLin, nCol+10, AllTrim(SUBSTR(_cConteudo,1,25)), oFnt10, nCol+nLargura, nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
					_cConteudo := AllTrim(SUBSTR(_cConteudo,26))
					_cSubLin := _cSubLin + 20
				next
			else
				oPrint:SayAlign(nLinha, nCol+10, Alltrim(QTEMP->D2_COD) +" - " +Alltrim(QTEMP->B1_DESC), oFnt10, nCol+nLargura, nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			EndIf

			nCol += nLargura
			nLargura:= 150
			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX DA QUANTIDADE
			oPrint:SayAlign(nLinha, nCol+10, cValToChar(QTEMP->D2_QUANT), oFnt10,nCol+nLargura,nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			nCol += nLargura
			nLargura := 220

			_cConteudo := Alltrim(QTEMP->B5_CEME)
			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX DO MATERIAL

			if len(_cConteudo) > 15
				_cSubLin := nLinha
				for _nY := 1 to 15
					oPrint:SayAlign(_cSubLin, nCol+10, Alltrim(SUBSTR(_cConteudo,1,15)), oFnt9, nCol+nLargura,nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
					_cConteudo := AllTrim(SUBSTR(_cConteudo,16))
					_cSubLin := _cSubLin + 20
				next 
			else
				oPrint:SayAlign(nLinha, nCol+10, QTEMP->B5_CEME, oFnt10, nCol+nLargura,nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			EndIf

			nCol += nLargura
			nLargura := 203
			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX PESO UNITARIO
			oPrint:SayAlign(nLinha, nCol+10, cValToChar(QTEMP->B1_PESO), oFnt10, nCol+nLargura,nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			nCol += nLargura - 3
			nLargura := 220
			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX PESO TOTAL
			oPrint:SayAlign(nLinha, nCol+10, cValToChar(QTEMP->B1_PESO*QTEMP->D2_QUANT), oFnt10, nCol+nLargura,nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			nCol += nLargura
			nLargura := 220 + 2
			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX CERT. ORIGEM
			oPrint:SayAlign(nLinha, nCol+10, QTEMP->B5_CERT, oFnt10,nCol+nLargura,nLinha+nAltura, /*nClrText*/, PAD_LEFT, 0) 
			nCol += nLargura
			nLargura := 490
			oPrint:Box( nLinha, nCol, nLinha+nAltura,   nCol+nLargura, "-4") // BOX DA FOTO
			oPrint:SayBitmap( nLinha+15, nCol+100, _cPhoto, 170, 170 )

			nLinha := nProxLin


			IF _nX == _nTQuery
				fQuebra(.F.,500)
				nLinha += 100
				cAdicional()
			ENDIF


			QTEMP->(DBSKIP())

		ENDDO	

		ACB->(DbCloseArea())
		AC9->(DbCloseArea())

	EndIf

	QTEMP->(DbCloseArea())

Return




/*/{Protheus.doc} gAltura
Função responsável por retornar a altura do texto informado, utilizando a fonte especificada.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
@param cTexto, character, Texto a ser medido
@param oFonte, object, Fonte utilizada para medir o texto
@return numeric, Altura do texto em pixels
/*/
Static Function gAltura(cTexto, oFonte)

	IF oPrint != NIL
		nValor := oPrint:GetTextHeight(cTexto,oFonte)
	ENDIF

Return nValor



/*/{Protheus.doc} gAltura
Função responsável por retornar a largura do texto informado, utilizando a fonte especificada.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
@param cTexto, character, Texto a ser medido
@param oFonte, object, Fonte utilizada para medir o texto
@return numeric, largura do texto em pixels
/*/
Static Function gLargura(cTexto, oFonte)

	IF oPrint != NIL
		nValor := oPrint:GetTextWidth(cTexto,oFonte)
	ENDIF

Return nValor


/*/{Protheus.doc} fQuebra
Função responsável por realizar a quebra de página no relatório, iniciando uma nova página quando necessário.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
@param lHeader, logical, Indica se deve imprimir o cabeçalho na nova página
@param nLimit, numeric, Limite inferior para quebra de página
@return variant, Sem retorno
/*/
Static Function fQuebra(lHeader, nLimit)
    If nLinha >= nLinFin-nLimit
		nLinha := 100
		cImpRod()
        oPrint:StartPage()
		nPag++

		if lHeader
        	cHeaderTable()
		EndIf

    EndIf

Return

/*/{Protheus.doc} cAdicional
Função responsável por buscar e compor informações adicionais do relatório, como termos, transportadora, volumes, especificações e posição fiscal.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
@return variant, informações adicionais do relatório
/*/
Static function cAdicional()
	Local aArea	    := FwGetArea()
	Local _cQuery   := ''
	Local oStateQry := Nil
	Local _cNCM     := ''
	Local _cEnd     := ''
	Local _nX       := 0
	Local _nTot     := 0

	Local aFieldSM0 := { ;
    "M0_CODIGO",;    //Posição [1]
    "M0_CODFIL",;    //Posição [2]
    "M0_NOMECOM",;   //Posição [3]
    "M0_CGC",;       //Posição [4]
    "M0_INSCM",;     //Posição [5]
    "M0_CIDENT",;    //Posição [6]
    "M0_ESTENT",;    //Posição [7]
    "M0_ENDENT",;    //Posição [8]
    "M0_BAIRENT",;   //Posição [9]
    "M0_CEPENT",;    //Posição [10]
    "M0_COMPENT",;   //Posição [11]
    "M0_TEL";        //Posição [12]
	}

	Local aSM0Data2 := {}

	aSM0Data2 := FWSM0Util():GetSM0Data(, SF2->F2_FILIAL, aFieldSM0)

	_cEnd := Alltrim(aSM0Data2[8][2]) + "-" + Alltrim(aSM0Data2[9][2])+ "-" + Alltrim(aSM0Data2[10][2]) +"-"+ Alltrim(aSM0Data2[6][2]) + "-" + Alltrim(aSM0Data2[7][2])
	//M0_END+M0_BAIRRO+M0_CEP+M0_MUN+M0_EST


	_cQuery += " SELECT C5_XTERMOS,C5_XMTRAN,F2_VOLUME1,F2_ESPECI1,B1_POSIPI   " 
	_cQuery += " FROM  "+RetSqlName("SF2")+" SF2   " 
	_cQuery += " INNER JOIN "+RETSQLNAME("SD2")+"  SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL   " 
	_cQuery += "        AND SD2.D2_DOC = SF2.F2_DOC   " 
	_cQuery += "        AND SD2.D2_SERIE = SF2.F2_SERIE   " 
	_cQuery += "        AND SD2.D2_CLIENTE = SF2.F2_CLIENTE   " 
	_cQuery += "        AND SD2.D2_LOJA = SF2.F2_LOJA   " 
	_cQuery += "        AND SD2.D_E_L_E_T_ = ' '   " 
	_cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+" SC5 ON SC5.C5_FILIAL = SD2.D2_FILIAL   " 
	_cQuery += "        AND SC5.C5_CLIENTE = SD2.D2_CLIENTE   " 
	_cQuery += "        AND SC5.C5_LOJACLI = SD2.D2_LOJA   " 
	_cQuery += "        AND SC5.C5_NUM = SD2.D2_PEDIDO   " 
	_cQuery += "        AND SC5.D_E_L_E_T_ = ' '   " 
	_cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_COD = SD2.D2_COD   " 
	_cQuery += " WHERE  SF2.F2_DOC = ?             " 
	_cQuery += "        AND SF2.F2_SERIE = ?      " 
	_cQuery += "        AND SF2.F2_FILIAL = ?      " 
	_cQuery += "        AND SF2.F2_CLIENTE = ?     " 
	_cQuery += "        AND SF2.F2_LOJA = ?        " 
	_cQuery += "        AND SF2.D_E_L_E_T_ = ' '   " 



	oStateQry := FWPreparedStatement():New()
	oStateQry:SetQuery(_cQuery)
	oStateQry:SetString(1,SF2->F2_DOC)
	oStateQry:SetString(2,SF2->F2_SERIE)
	oStateQry:SetString(3,xFilial("SF2"))
	oStateQry:SetString(4,SF2->F2_CLIENTE)
	oStateQry:SetString(5,SF2->F2_LOJA)

	_cQuery := oStateQry:GetFixQuery()

	IF SELECT("QADD") > 0
		QTEMP->(DbCloseArea())
	ENDIF

	DBUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QADD", .T., .T. )

	Count to _nTot

	QADD->(DBGOTOP())
	

	fQuebra(.f.,10)

	oPrint:SayAlign(nLinha,210,"Termos de entrega:",oFnt12N,gLargura("Termos de entrega:",oFnt12N),gAltura("Termos de entrega:",oFnt12N),,PAD_LEFT,0)
	oPrint:SayAlign(nLinha,540,Alltrim(QADD->C5_XTERMOS),oFnt12,gLargura(Alltrim(QADD->C5_XTERMOS),oFnt12),gAltura(Alltrim(QADD->C5_XTERMOS),oFnt12),,PAD_LEFT,0)
	nLinha += 100
	oPrint:SayAlign(nLinha,210,"Meios de Transporte:",oFnt12N,gLargura("Meios de Transporte:",oFnt12N),gAltura("Meios de Transporte:",oFnt12N),,PAD_LEFT,0)
	oPrint:SayAlign(nLinha,540,Alltrim(QADD->C5_XMTRAN),oFnt12,gLargura(Alltrim(QADD->C5_XMTRAN),oFnt12),gAltura(Alltrim(QADD->C5_XMTRAN),oFnt12),,PAD_LEFT,0)
	nLinha += 100
	oPrint:SayAlign(nLinha,210,"Volumes:",oFnt12N,gLargura("Volumes:",oFnt12N),gAltura("Volumes:",oFnt12N),,PAD_LEFT,0)
	oPrint:SayAlign(nLinha,540,cValToChar(SF2->F2_VOLUME1)+ SF2->F2_ESPECI1,oFnt12,gLargura(cValToChar(SF2->F2_VOLUME1)+ SF2->F2_ESPECI1,oFnt12),gAltura(cValToChar(SF2->F2_VOLUME1)+ SF2->F2_ESPECI1,oFnt12),,PAD_LEFT,0)
	nLinha += 200
	oPrint:SayAlign(nLinha,210,"Codigo Tarifa:",oFnt12N,gLargura("Codigo Tarifa:",oFnt12N),gAltura("Codigo Tarifa:",oFnt12N),,PAD_LEFT,0)
	
	WHILE QADD->(!EOF())
		_nX++

		IF _nX == _nTot .and. !(Alltrim(QADD->B1_POSIPI) $ _cNCM )
			_cNCM += Alltrim(QADD->B1_POSIPI)
		EndIf

		if !(Alltrim(QADD->B1_POSIPI) $ _cNCM ) .and. Empty(_cNCM)
			_cNCM += Alltrim(QADD->B1_POSIPI)
		EndIf

		if !(Alltrim(QADD->B1_POSIPI) $ _cNCM ) 
			_cNCM += "," + Alltrim(QADD->B1_POSIPI)
		EndIf

		QADD->(DBSKIP())
	ENDDO

	QADD->(DbCloseArea())

	oPrint:SayAlign(nLinha,540,_cNCM,oFnt12,gLargura(_cNCM,oFnt12),gAltura(_cNCM,oFnt12),,PAD_LEFT,0)
	
	nLinha += 200
	oPrint:SayAlign(nLinha,210,"Endereço do remetente:",oFnt12N,gLargura("Endereço do remetente:",oFnt12N),gAltura("Endereço do remetente:",oFnt12N),,PAD_LEFT,0)
	oPrint:SayAlign(nLinha,540,_cEnd,oFnt12,gLargura(_cEnd,oFnt12),gAltura(_cEnd,oFnt12),,PAD_LEFT,0)

	FwRestArea(aArea)

Return


/*/{Protheus.doc} cImpRod
Rodapé do relatório Packing List.
@type function
@version 12.2410
@author Lucas Apolinario
@since 22/09/2025
/*/
static function cImpRod()
	Local nLinRod := nLinFin + 200

	oPrint:SayAlign(nLinRod, 700, 'Cavanna Máquinas e Sistemas para Embalagens Ltda', oFnt10, 1000, 20, CLR_GRAY, PAD_CENTER, 0) 
    nLinRod+=50
    oPrint:SayAlign(nLinRod,500, 'Rua Alberto Belesso, 640 - Parque Industrial II – PO BOX: 373 - Jundiaí - 13213-170 - SP – BRASIL – Phone : (5511) 4431-8700', oFnt10, 2000, 20, CLR_GRAY, PAD_LEFT, 0) 
    nLinRod+=50
    oPrint:SayAlign(nLinRod, 710, 'E-mail: vendas@cavannagroup.com / www.cavanna.com', oFnt10, 1000, 20, CLR_GRAY, PAD_CENTER, 0) 
	nLinRod+=50
	oPrint:SayAlign(nLinRod, 730, 'CNPJ: 06.088.544/0001-33', oFnt10, 1000, 20, CLR_GRAY, PAD_CENTER, 0) 
    //Direita
	nLinRod+=100
    cTexto := 'Pagina '+cValToChar(nPag)
    oPrint:SayAlign(nLinRod, 1750, cTexto, oFnt10, 500, 20, , PAD_RIGHT,0 )

    oPrint:EndPage()


Return
                          
