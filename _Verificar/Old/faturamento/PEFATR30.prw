#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ?
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑ?
ฑฑบPrograma  ?PEFATR30  ?Autor ?Renan Rosario      ?Data ? 01/09/2014 บฑ?
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑ?
ฑฑบDescrio ?Impressao da CC-e.                   					  บฑ?
ฑฑ?         ?Layout nosso enquanto aguarda padrao da SEFAZ              บฑ?
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑ?
ฑฑบUso       ?                                                           บฑ?
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑ?
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ?
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿


Nome alterado de CPRTCCE para PEFATR30 para seguir padrใo de nomenclatura Pentair;
Chamado INC0385404 - MODULO CARTA DE CORREวรO;
Paulo Apolinario.  15.12.2015

/*/

User Function PEFATR30()

Local   iw1,iw2,nLin
Local   xBitMap := FisxLogo("1")     ///Logotipo da empresa
Local   MMEMO1  := MMEMO2 := ""
Local   xCGC    := ""
Local   aArea   := GetArea()
Local   cConType:=	"TCPIP"
Private cPerg   := "PEFATR30"

R002SX1(cPerg)

lRsp := Pergunte(cPerg,.T.)

If ( !lRsp )
	Return
EndIf

If Mv_Par03 == 2 //Saida
	DbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	SF2->(dbSeek(xFilial("SF2")+mv_par02+mv_par01))//+SF2->F2_CLIENTE+SF2->F2_LOJA))
	//SF2->(DbGotop())
	cChvNfe  := SF2->F2_CHVNFE
	dEmissao := SF2->F2_EMISSAO
	If ( EOF() .OR. EMPTY(cChvNfe) )
		MsgStop("Aten็ใo! Nota Fiscal nใo existe, Cancelada ou Nota Fiscal Inutilizada.")
		RestArea(aArea)
		Return
	ENDIF	
ElseIf Mv_Par03==1 //Entrada
	DbSelectArea("SF1")
	SF1->(dbSetOrder(1))
	SF1->(dbSeek(xFilial("SF1")+mv_par02+mv_par01))//+SF1->F1_FORNECE+SF1->F1_LOJA))
	cChvNfe  := SF1->F1_CHVNFE
	dEmissao := SF1->F1_EMISSAO
	If ( EOF() .OR. EMPTY(cChvNfe) )
		MsgStop("Aten็ใo! Nota Fiscal nใo existe, Cancelada ou Nota Fiscal Inutilizada.")
		RestArea(aArea)
		Return
	ENDIF		
EndIf

If Mv_Par03==2 //Saํda
	If AllTrim(SF2->F2_TIPO) $ ("B/D")
		DbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		xDestinatario := Alltrim(SA2->A2_NOME)
		IF ( !EMPTY(SA2->A2_CGC) )
			xCGC := IIF(LEN(SA2->A2_CGC) > 11 , TRANSF(SA2->A2_CGC,"@R 99.999.999/9999-99") , TRANSF(SA2->A2_CGC,"@R 999.999.999-99") )
		ENDIF
	Else
		DbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		xDestinatario := Alltrim(SA1->A1_NOME)
		IF ( !EMPTY(SA1->A1_CGC) )
			xCGC := IIF(LEN(SA1->A1_CGC) > 11 , TRANSF(SA1->A1_CGC,"@R 99.999.999/9999-99") , TRANSF(SA1->A1_CGC,"@R 999.999.999-99") )
		ENDIF
	EndIf
ElseIf Mv_Par03==1 //Entrada
	If ! Sf1->F1_Tipo $"DB"
		DbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		SA2->(dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA))
		xDestinatario := AllTrim(SA2->A2_NOME)
		IF ( !EMPTY(SA2->A2_CGC) )
			xCGC := IIF(LEN(SA2->A2_CGC) > 11 , TRANSF(SA2->A2_CGC,"@R 99.999.999/9999-99") , TRANSF(SA2->A2_CGC,"@R 999.999.999-99") )
		ENDIF
	Else
		DbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))
		xDestinatario := Alltrim(SA1->A1_NOME)
		IF ( !EMPTY(SA1->A1_CGC) )
			xCGC := IIF(LEN(SA1->A1_CGC) > 11 , TRANSF(SA1->A1_CGC,"@R 99.999.999/9999-99") , TRANSF(SA1->A1_CGC,"@R 999.999.999-99") )
		EndIf	
	EndIf
EndIf
	
TCCONTYPE(cConType)

cDBSQL   := SuperGetMV("MV_XBDTSS",,"PROTHEUS01\MSSQL") //
cSrvTop  := SuperGetMV("MV_XIPTSS",,"192.168.10.181")//
nPorTop  := SuperGetMV("MV_XPTTSS",,"8001")//

nAmbTOP	 := advConnection()
nHndSQL  := TcLink(cDbSQL,cSrvTop,nPorTop)

vNfeId := mv_par02+mv_par01

If nHndSQL < 0
	Alert("Erro ("+str(nHndSQL,4)+") ao conectar com "+cDbSQL+" em "+cSrvTop + "! Verifique se ha licencas disponiveis." )
	Return
Endif

TCSetConn(nHndSQL)
//////////////////////////////////////////////////////////////
///
///TOP 1 - para pegar sempre a ultima carta de correcao da nf-e
///
cQry := "SELECT TOP 1 ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"+CRLF
cQry += "PROTOCOLO,NFE_CHV,ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_ERP)),'') AS TMEMO1,"+CRLF
cQry += "ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_RET)),'') AS TMEMO2 "+CRLF
cQry += "FROM SPED150"+CRLF
cQry += "WHERE D_E_L_E_T_ = ' '"+CRLF
cQry += "AND NFE_CHV = '"+cChvNfe+"' "+CRLF
cQry += "ORDER BY LOTE DESC"+CRLF
/////
cQry := ChangeQuery(cQry)
/////
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), 'TMP', .T., .T.)
/////
TcSetField("TMP","DATE_EVEN","D",08,0)
/////
dbSelectArea("TMP")
dbGoTop()
/////
If ( Eof() )
	MsgStop("Aten็ใo! Nใo existe Carta de Corre็ใo para a Nota Fiscal informada.")
	TMP->(dbCloseArea())
	TCSetConn(0)		//retorna para a conexใo padrใo do Protheus. Chamado INC0385404. Paulo Apolinario. 15.12.2015
	TCUnlink(nHndSQL)  	//Encerra a conexใo especificada. Chamado INC0385404. Paulo Apolinario. 15.12.2015
	RestArea(aArea)
	Return
Endif

MMEMO1     := TMP->TMEMO1     ///Relativo ao envio
MMEMO2     := TMP->TMEMO2     ///Retorno da SEFAZ
MNFE_CHV   := TMP->NFE_CHV
MID_EVENTO := TMP->ID_EVENTO
MTPEVENTO  := STR(TMP->TPEVENTO,6)
MSEQEVENTO := STR(TMP->SEQEVENTO,1)
MAMBIENTE  := STR(TMP->AMBIENTE,1)+IIF(TMP->AMBIENTE==1," - Produ็ใo", IIF(TMP->AMBIENTE==2," - Homologa็ใo" , ""))
MDATE_EVEN := DTOC(TMP->DATE_EVEN)
MTIME_EVEN := TMP->TIME_EVEN
MVERSAO    := STR(TMP->VERSAO,4,2)
MVEREVENTO := STR(TMP->VEREVENTO,4,2)
MVERTPEVEN := STR(TMP->VERTPEVEN,4,2)
MVERAPLIC  := TMP->VERAPLIC
MCORGAO    := STR(TMP->CORGAO,2)+IIF(TMP->CORGAO==13 , " - AMAZONAS",IIF(TMP->CORGAO==35 , " - SAO PAULO" , ""))
MCSTATEVEN := STR(TMP->CSTATEVEN,3)
MCMOTEVEN  :=  SUBSTR(TMP->CMOTEVEN,1, 56)
MCMOTEVEN2 :=  SUBSTR(TMP->CMOTEVEN, 57, 56)
MPROTOCOLO := STR(TMP->PROTOCOLO,15)

TMP->(dbCloseArea())

RestArea(aArea)

xFone := RTRIM(SM0->M0_TEL)
xFone := STRTRAN(xFone,"(","")
xFone := STRTRAN(xFone,")","")
xFone := STRTRAN(xFone,"-","")
xFone := STRTRAN(xFone," ","")
*
xFax := RTRIM(SM0->M0_FAX)
xFax := STRTRAN(xFax,"(","")
xFax := STRTRAN(xFax,")","")
xFax := STRTRAN(xFax,"-","")
xFax := STRTRAN(xFax," ","")

xRazSoc := rTrim(SM0->M0_NOMECOM)
xEnder  := rTrim(SM0->M0_ENDENT) + " - " + rTrim(SM0->M0_BAIRENT) + " - " + rTrim(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
xFone   := "Fone / Fax: " + Transf(xFone,"@R (99)9999-9999") + IIF(!EMPTY(SM0->M0_FAX) , " / " + Transf(xFax,"@R (99)9999-9999") , "" )
xCnpj   := "C.N.P.J.: " + Transf(SM0->M0_CGC,"@R 99.999.999/9999-99")
xIE     := "I.Estadual: "+SM0->M0_INSC

////
////Extrai dados do Memo
////
MDHEVENTO := ""
iw1 := AT("<dhRegEvento>" , MMEMO2 )
iw2 := AT("</dhRegEvento>" , MMEMO2 )
IF ( iw1 > 0 )
	iw3 := ( iw2 - iw1 )
	MDHEVENTO += SUBS(MMEMO2 , ( iw1+13 ) , ( iw2 - ( iw1 + 13 ) ) )
ENDIF
*
MDESCEVEN := ""
iw1 := AT("<xEvento>" , MMEMO2 )
iw2 := AT("</xEvento>" , MMEMO2 )
IF ( iw1 > 0 )
	iw3 := ( iw2 - iw1 )
	MDESCEVEN += SUBS(MMEMO2 , ( iw1+9 ) , ( iw2 - ( iw1 + 9 ) ) )
ENDIF
*
aCorrec   := {}
MCORRECAO := ""
iw1 := AT("<xCorrecao>" , MMEMO1 )
iw2 := AT("</xCorrecao>" , MMEMO1 )
IF ( iw1 > 0 )
	iw3 := ( iw2 - iw1 )
	MCORRECAO += SUBS(MMEMO1 , ( iw1+11 ) , ( iw2 - ( iw1 + 11 ) ) )
	MCORRECAO += SPACE(10)
	iw1 := 1
	DO WHILE !EMPTY(SUBS(MCORRECAO,iw1,10))
		AADD(aCorrec , SUBS(MCORRECAO,iw1,105) )
		iw1 += 105     ///Nro de caracteres da linha - fica a criterio
	ENDDO
ENDIF
*
aCondic   := {}
MCONDICAO := ""
iw1 := AT("<xCondUso>" , MMEMO1 )
iw2 := AT("</xCondUso>" , MMEMO1 )
IF ( iw1 > 0 )
	AADD(aCondic , "A Carta de Correcao e disciplinada pelo paragrafo 1o-A do art. 7o do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para" )
	AADD(aCondic , "regularizacao  de  erro ocorrido na  emissao de  documento  fiscal, desde que o erro nao esteja relacionado com:  I - as variaveis que" )
	AADD(aCondic , "determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao;" )
	AADD(aCondic , "II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissao ou de saida.        " )
ENDIF


// Cria um novo objeto para impressao
oPrint := TMSPrinter():New("Impressใo da Carta de Corre็ใo Eletronica - CC-e")

// Cria os objetos com as configuracoes das fontes
//                                              Negrito  Subl  Italico
oFont08  := TFont():New( "Times New Roman",,08,,.f.,,,,,.f.,.f. )
oFont08b := TFont():New( "Times New Roman",,08,,.t.,,,,,.f.,.f. )
oFont09  := TFont():New( "Times New Roman",,09,,.f.,,,,,.f.,.f. )
oFont10  := TFont():New( "Times New Roman",,10,,.f.,,,,,.f.,.f. )
oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
oFont11  := TFont():New( "Times New Roman",,11,,.f.,,,,,.f.,.f. )
oFont11b := TFont():New( "Times New Roman",,11,,.t.,,,,,.f.,.f. )
oFont12  := TFont():New( "Times New Roman",,12,,.f.,,,,,.f.,.f. )
oFont12b := TFont():New( "Times New Roman",,12,,.t.,,,,,.f.,.f. )
oFont13b := TFont():New( "Times New Roman",,13,,.t.,,,,,.f.,.f. )
oFont14  := TFont():New( "Times New Roman",,14,,.f.,,,,,.f.,.f. )
oFont24b := TFont():New( "Times New Roman",,24,,.t.,,,,,.f.,.f. )

// Mostra a tela de Setup
oPrint:Setup()

oPrint:SetPortrait()
oPrint:SetPaperSize(9)

// Inicia uma nova pagina
oPrint:StartPage()

oPrint:SetFont(oFont24b)
oPrint:SayBitMap(100,116,xBitMap,600,280)

oPrint:Say(120,780,xRazSoc,oFont13b ,140)
oPrint:Say(180,780,xEnder,oFont10 ,140)
oPrint:Say(230,780,xFone,oFont10 ,140)
oPrint:Say(280,780,xCnpj,oFont10 ,140)
oPrint:Say(330,780,xIE,oFont10 ,140)
*
oPrint:Box(100,1890,390,2400)

oPrint:Line(150,1890,150,2400)
oPrint:Say(104,2020,"Carta de Corre็ใo",oFont11b ,160)
oPrint:Say(170,1920,"S้rie: "+mv_par01,oFont11b ,100)
oPrint:Say(240,1920,"N.Fiscal: "+mv_par02,oFont11b ,100)
oPrint:Say(310,1920,"Dt.Emissใo: "+DTOC(dEmissao),oFont11b ,100)

oPrint:Box(420,100,2000,2400)

oPrint:Say(440,110,"Tipo do evento",oFont12b ,100)
oPrint:Say(440,850,"Data e hora",oFont12b ,100)
oPrint:Say(440,1890,"Protocolo",oFont12b ,100)
oPrint:Say(490,110,"Carta de Corre็ใo NFe",oFont11 ,100)
oPrint:Say(490,850,MDATE_EVEN+"  "+MTIME_EVEN,oFont11 ,140)
oPrint:Say(490,1890,MPROTOCOLO,oFont11 ,140)

oPrint:Say(580,110,"Identifica็ใo do destinatแrio",oFont11b ,200)
oPrint:Say(580,1430,"CNPJ/CPF",oFont11b ,200)
oPrint:Say(630,110,xDestinatario,oFont11b ,800)
oPrint:Say(630,1430,xCGC,oFont11b ,260)

oPrint:Say(740,110,"DADOS DO EVENTO DA CARTA DE CORREวรO",oFont11b ,250)
oPrint:Say(800,110,"Versใo do evento",oFont11b ,100)
oPrint:Say(800,670,"Id evento",oFont11b ,100)
oPrint:Say(800,1890,"Tipo do evento",oFont11b ,100)
oPrint:Say(850,110,MVERSAO,oFont11 ,80)
oPrint:Say(850,670,MID_EVENTO,oFont11 ,400)
oPrint:Say(850,1890,MTPEVENTO,oFont11 ,120)

oPrint:Say(940,110,"Identifica็ใo do ambiente",oFont11b ,140)
oPrint:Say(940,670,"C๓digo do ๓rgใo de recep็ใo do evento",oFont11b ,240)
oPrint:Say(940,1430,"Chave de acesso da NF-e vinculada ao evento",oFont11b ,250)
oPrint:Say(990,110,MAMBIENTE,oFont11 ,80)
oPrint:Say(990,670,MCORGAO,oFont11 ,240)
oPrint:Say(990,1430,MNFE_CHV,oFont11 ,880)

oPrint:Say(1050,110,"Data e hora do recebimento do evento",oFont11b ,400)
oPrint:Say(1050,1430,"Sequencial do evento",oFont11b ,100)
oPrint:Say(1050,1890,"Versใo do tipo do evento",oFont11b ,200)
oPrint:Say(1100,110,MDHEVENTO,oFont11 ,200)
oPrint:Say(1100,1430,MSEQEVENTO,oFont11 ,20)
oPrint:Say(1100,1890,MVERTPEVEN,oFont11 ,200)

oPrint:Say(1170,110,"Versใo do aplicativo que",oFont11b ,100)
oPrint:Say(1210,110,"recebeu o evento",oFont11b ,100)
oPrint:Say(1170,670,"C๓digo de status do registro do evento",oFont11b ,300)
oPrint:Say(1170,1430,"Descri็ใo literal do status de registro do evento",oFont11b ,300)
oPrint:Say(1260,110,MVERAPLIC,oFont11 ,80)
oPrint:Say(1220,670,MCSTATEVEN,oFont11 ,60)
oPrint:Say(1220,1430,MCMOTEVEN,oFont11 ,300)
oPrint:Say(1270,1430,MCMOTEVEN2,oFont11 ,300)

oPrint:Say(1340,110,"Descri็ใo do evento",oFont11b ,100)
oPrint:Say(1390,110,MDESCEVEN,oFont11 ,100)
///
///Deixei um gap de 4 linhas para o texto - se o texto for maior ter?que alterar a linha onde comeca a Condicao de Uso
///
oPrint:Say(1450,110,"Texto da Carta de Corre็ใo",oFont11b ,300)
nLin := 1450
FOR iw1:=1 TO LEN(aCorrec)
	nLin += 50
	oPrint:Say(nLin,110,aCorrec[iw1],oFont11 ,2000)
NEXT

oPrint:Say(1700,110,"Condi็๕es de uso",oFont11b ,100)

nLin := 1700
FOR iw2:=1 TO LEN(aCondic)
	nLin += 50
	oPrint:Say(nLin,110,aCondic[iw2],oFont11 ,2000)
NEXT

oPrint:EndPage()

oPrint:Preview()

TCSetConn(0)		//retorna para a conexใo padrใo do Protheus. Chamado INC0385404. Paulo Apolinario. 15.12.2015
TCUnlink(nHndSQL)  	//Encerra a conexใo especificada. Chamado INC0385404. Paulo Apolinario. 15.12.2015

Return .F.

/*
ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ?
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ?
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑ?
ฑฑบPrograma  ณR002SX1   บAutor  ณRENAN ROSARIO       ?Data ? 21/12/12   บฑ?
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑ?
ฑฑบDesc.     ณAtualiza grupo de preguntas                                 บฑ?
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑ?
ฑฑบUso       ณPENTAIR                                                     บฑ?
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑ?
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ?
ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ?
*/
Static Function R002SX1(cPerg)
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )
Local lAtuHelp := .F.

aEstrut := { 'X1_GRUPO'  , 'X1_ORDEM'  , 'X1_PERGUNT', 'X1_PERSPA' , 'X1_PERENG' , 'X1_VARIAVL', 'X1_TIPO'   , ;
'X1_TAMANHO', 'X1_DECIMAL', 'X1_PRESEL' , 'X1_GSC'    , 'X1_VALID'  , 'X1_VAR01'  , 'X1_DEF01'  , ;
'X1_DEFSPA1', 'X1_DEFENG1', 'X1_CNT01'  , 'X1_VAR02'  , 'X1_DEF02'  , 'X1_DEFSPA2', 'X1_DEFENG2', ;
'X1_CNT02'  , 'X1_VAR03'  , 'X1_DEF03'  , 'X1_DEFSPA3', 'X1_DEFENG3', 'X1_CNT03'  , 'X1_VAR04'  , ;
'X1_DEF04'  , 'X1_DEFSPA4', 'X1_DEFENG4', 'X1_CNT04'  , 'X1_VAR05'  , 'X1_DEF05'  , 'X1_DEFSPA5', ;
'X1_DEFENG5', 'X1_CNT05'  , 'X1_F3'     , 'X1_PYME'   , 'X1_GRPSXG' , 'X1_HELP'   , 'X1_PICTURE', ;
'X1_IDFIL'   }

//
// Perguntas KINR002

aAdd(aDados,{ cPerg,"01" , "S้rie                       ?",   ""   ,  ""    , "mv_ch1" , "C" ,   03   ,   0   ,   0   , "G" , "          "  , "mv_par01", "            " , "     " , "     " , "   " , "   " , "             " , "     " , "     " , "   " , "   " , "      " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "    " })
aAdd(aDados,{ cPerg,"02" , "Nota Fiscal                 ?",   ""   ,  ""    , "mv_ch2" , "C" ,   09   ,   0   ,   0   , "G" , "          "  , "mv_par02", "            " , "     " , "     " , "   " , "   " , "             " , "     " , "     " , "   " , "   " , "      " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "    " })
aAdd(aDados,{ cPerg,"03" , "Nota de Entrada ou Saํda    ?",   ""   ,  ""    , "mv_ch3" , "N" ,   01   ,   0   ,   0   , "C" , "          "  , "mv_par03", "Entrada     " , "     " , "     " , "   " , "   " , "Saida        " , "     " , "     " , "   " , "   " , "      " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "    " })
//
// Atualizando dicionแrio
//
dbSelectArea( 'SX1' )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( 'SX1', .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
		lAtuHelp:= .T.
	EndIf
Next nI

// Atualiza Helps
IF lAtuHelp
	R002HLP(cPerg)
ENDIF

RestArea( aAreaDic )
RestArea( aArea )

Return
/*
ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ?
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ?
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑ?
ฑฑบPrograma  ?R002HLP  บAutor  ณRenan Rosario       ?Data ? 20/08/2014 บฑ?
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑ?
ฑฑบDesc.     ณAtualiza help das perguntas                                 บฑ?
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑ?
ฑฑบUso       ณPENTAIR                                                     บฑ?
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑ?
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ?
ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ?
*/
Static Function R002HLP(cPerg)
Local aHelp		:= {}
Local nCnt		:= 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณHelps Perguntas PEN10R10                    ?
//ณaHelp[1]  - Sequencial do grupo de perguntas?
//ณaHelp[2]  - Help portugues                  ?
//ณaHelp[3]  - Help Ingles                     ?
//ณaHelp[4]  - Help Espanhol                   ?
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

aAdd(aHelp, {'01',{'Informe o N๚mero da serie da nota.'},{},{}})
aAdd(aHelp, {'02',{'Informe o N๚mero da nota desejada.'},{},{}})
aAdd(aHelp, {'03',{'Informe se a nota ?de Entrada ou Saํda.'},{},{}})
FOR nCnt:=1 TO len(aHelp)
	PutHelp( 'P.'+cPerg+aHelp[nCnt][1]+'.', aHelp[nCnt][2], aHelp[nCnt][3], aHelp[nCnt][4], .T. )
NEXT nCnt
Return
