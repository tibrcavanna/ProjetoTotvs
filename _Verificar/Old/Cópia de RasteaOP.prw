#include "prothesp.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

User Function RasteaOP()

Local aEstrutura   := {}
Local i:=0,nx:=0
Local oDlg
Local lOk          := .T.
Local aAreaSD4     := SD4->(GetArea())

Private nQtdOrigEs := 1
Private cProdEst   := Criavar("D3_COD",.F.)
Private cOpEst     := Criavar("D3_OP",.F.)
Private cOpAtu     := Criavar("D3_OP",.F.)
Private nEstru     := 0
Private aHead_1    := {"OP","PRODUTO","QTD OP","SALDO OP","COMPONENTE","QTD EMP","SALDO EMP","SEQUEN","LOCAL","MOVIMENTA��ES"} 
Private aHead_2    := {"TIPO","DOCUMENTO","QUANTIDADE","QTD ENTREGUE","SALDO","DTA ENTREGA","FORNECEDOR","RESIDUO","TP MOV"}  
Private aMov       := {}
Private dDtaIni    := ctod("")
Private cTitulo    := "Rasteabilidade de OPs"


DEFINE MSDIALOG oDlg FROM  140,000 TO 300,400 TITLE OemToAnsi("Informe Produto e a OP") PIXEL 
@ 10,15 TO 63,185 LABEL '' OF oDlg PIXEL	
@ 20,20 SAY Alltrim(RetTitle("D3_COD")) SIZE 70,9 OF oDlg PIXEL
@ 20,90 MSGET cProdEst F3 "SB1" Picture PesqPict("SD3","D3_COD") Valid (NaoVazio() .Or. ExistCpo("SB1",cProdEst)) SIZE 70,9 OF oDlg PIXEL
@ 35,20 SAY Alltrim(RetTitle("D3_OP")) SIZE 70,9 OF oDlg PIXEL
@ 35,90 MSGET cOpEst F3 "SC2OP" Picture PesqPict("SD3","D3_OP") Valid ((Vazio() .Or. ExistCpo("SC2",left(cOpEst,8))) .And. VerIniOP()) SIZE 70,9 OF oDlg PIXEL
//@ 35,95 MSGET nQtdOrigEs Picture PesqPict("SD3","D3_QUANT") Valid (Positivo() .And. NaoVazio()) SIZE 60,9 OF oDlg PIXEL
DEFINE SBUTTON FROM 67,131 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 67,158 TYPE 2 ACTION (oDlg:End(),lOk:=.F.) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED 

If lOk .And. !Empty(cProdEst) //.And. nQtdOrigEs > 0

	// Le os empenhos caso a op esteja preenchida
	If !Empty(cOPEst)
		
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial()+left(cOpEst,8))

        dDtaIni := SC2->C2_EMISSAO

        While !eof() .and. SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM == xFilial()+left(cOpEst,8)

            cOpAtu := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"  "

		    dbSelectArea("SD4")
		    dbSetOrder(2)
		    dbSeek(xFilial()+cOpAtu)
		    While !Eof() .And. D4_FILIAL+D4_OP==xFilial()+cOpAtu

			    AADD(aEstrutura,{cOpAtu,;
			                     SC2->C2_PRODUTO,;
			                     SC2->C2_QUANT,;
			                     SC2->C2_QUANT-SC2->C2_QUJE,;
			                     SD4->D4_COD,;
			                     SD4->D4_QTDEORI,;
			                     SD4->D4_QUANT,;
			                     SD4->D4_TRT,;
			                     SD4->D4_LOCAL,0})						

			   dbSelectArea("SD4")
			   dbSkip()

		    End


		    dbSelectArea("SC2") 
		    dbSkip()

        End
    
    EndIf

EndIf

If !Empty(aEstrutura)
   MsgRun("Gerando Rasteabilidade", cTitulo, { || GeraMov(aEstrutura)} )
   TelaInicial(aEstrutura)
 Else
   Alert("N�o ha nenhum empenho para essa OP !!!")
EndIf

Return


Static Function VerIniOP()

// Inicializa produto e quantidade
If !Empty(cOPEst) .And. SC2->(MsSeek(xFilial("SC2")+left(cOpEst,8)))
	cProdEst   := SC2->C2_PRODUTO
EndIf

Return


Static Function TelaInicial(aCols)

Local aSize    := {}
Local aObjects := {}       
Local aInfo    := {}

Private aPosObj  := {}
Private oDlg 
Private oListBox, bLine
Private cLine   := "{ aCols[oListBox:nAt][1] "

For nI:=2 To Len(aHead_1)
	cLine += " ,aCols[oListBox:nAt][" + AllTrim(Str(nI)) + "]"
Next
cLine += "}"
bLine := &( "{|| " + cLine + "}" )                                                                             

//��������������������������������������������������������������������������Ŀ
//� Monta Dialog...                                                          �
//����������������������������������������������������������������������������
aSize    := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 1, .F., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .t., .t. )	
aPosObj[2][3] -= 14

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel

	TGroup():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],"Ordem de Produ��o",, , ,.T.) 

    dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial()+left(cOpEst,8))

    @031,008 Say OemToAnsi("OP :") COLOR CLR_HBLUE
    @041,008 Say SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN

    @056,008 Say OemToAnsi("PRODUTO :") COLOR CLR_HBLUE
    @066,008 Say SC2->C2_PRODUTO
    @076,008 Say AllTrim(Posicione("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))

    @091,008 Say OemToAnsi("INICIO :") COLOR CLR_HBLUE
    @101,008 Say OemToAnsi(DTOC(SC2->C2_DATPRI)) 

    @116,008 Say OemToAnsi("PREVISAO:") COLOR CLR_HBLUE
    @126,008 Say OemToAnsi(DTOC(SC2->C2_DATPRF)) 

    @141,008 Say OemToAnsi("QUANTIDADE :") COLOR CLR_HBLUE
    @151,008 Say OemToAnsi(Transform(SC2->C2_QUANT,"@E 9,999,999.9999")) 

    @166,008 Say OemToAnsi("EMISSAO :") COLOR CLR_HBLUE
    @176,008 Say OemToAnsi(DTOC(SC2->C2_EMISSAO)) 

    @191,008 Say OemToAnsi("ENTREGA :") COLOR CLR_HBLUE
    @201,008 Say OemToAnsi(DTOC(SC2->C2_DATRF)) 


	TButton():New(251,008, "Impress�o", , { || MsAguarde ( { || GeraImp(aCols) } )}, 085, 010 ,,,,.T.)  
	TButton():New(271,008, "Excel"    , , { || MsAguarde ( { || GeraExcel(aCols) } )}, 085, 010 ,,,,.T.)  

	SButton():New(aPosObj[2][3] + 3, aPosObj[2][4] - 30 , 01 , { || oDlg:End() }, oDlg, .T. )

	oListBox := TWBrowse():New( aPosObj[2][1],aPosObj[2][2],aPosObj[2][4]-100,aPosObj[2][3]-20,,aHead_1,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aCols)
	oListBox:bLDblClick := {|| TelaMovimentos(),oListBox:Refresh() }
	oListBox:bLine      := bLine


ACTIVATE DIALOG oDlg  CENTERED 


Return


Static Function TelaMovimentos()

Local aSize    := {}
Local aObjects := {}       
Local aInfo    := {}

Private aPosObj  := {}
Private oDlg2 
Private oListBox2, bLine2
Private cTitulo2 := "Rasteabilidade Movimentos"
Private cLine2   := ""

//��������������������������������������������������������������������������Ŀ
//� Monta Dialog...                                                          �
//����������������������������������������������������������������������������
aSize    := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 1, .F., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .t., .t. )	
aPosObj[2][3] -= 14

nPos := Ascan(aMov,{|x| x[1] == oListBox:AARRAY[oListBox:NAT][1]+oListBox:AARRAY[oListBox:NAT][5]+oListBox:AARRAY[oListBox:NAT][8]})

If nPos = 0
   Return()
Endif

cLine2   := "{ aMov["+AllTrim(Str(nPos))+"][2][oListBox2:nAt][1] "

For nI:=2 To Len(aHead_2)
	cLine2 += " ,aMov["+AllTrim(Str(nPos))+"][2][oListBox2:nAt][" + AllTrim(Str(nI)) + "]"
Next
cLine2 += "}"
bLine2 := &( "{|| " + cLine2 + "}" )                                                                             

DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel


	SButton():New(aPosObj[2][3] + 3, aPosObj[2][4] - 30 , 01 , { || oDlg2:End() }, oDlg2, .T. )

    @aPosObj[2][3] + 3 ,008 Say OemToAnsi("OP :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 3 ,020 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][1])

    @aPosObj[2][3] + 3 ,060 Say OemToAnsi("COMPONENTE :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 3 ,100 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][5])

    @aPosObj[2][3] + 3 ,200 Say OemToAnsi("QTD :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 3 ,225 Say OemToAnsi(Transform(oListBox:AARRAY[oListBox:NAT][6],"@E 9,999,999.9999"))

    @aPosObj[2][3] + 3 ,345 Say OemToAnsi("SALDO :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 3 ,370 Say OemToAnsi(Transform(oListBox:AARRAY[oListBox:NAT][7],"@E 9,999,999.9999"))


	oListBox2 := TWBrowse():New( aPosObj[2][1],aPosObj[2][2]-100,aPosObj[2][4]-10,aPosObj[2][3]-20,,aHead_2,,oDlg2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox2:SetArray(aMov[nPos][2])
	oListBox2:bLine      := bLine2


ACTIVATE DIALOG oDlg2  CENTERED 


Return

Static Function GeraMov(aEstrutura)

Local nPos1  := 0

aMov := {}

For ny := 1 to len(aEstrutura)

    GeraTRB(aEstrutura[ny,1],aEstrutura[ny,5])

    dbSelectArea("TRB")
    While !eof()
	    nPos1:=  Ascan(aMov,{|x| x[1] == aEstrutura[ny,1]+aEstrutura[ny,5]+aEstrutura[ny,8]})
	    If nPos1==0
		   AADD(aMov,{aEstrutura[ny,1]+aEstrutura[ny,5]+aEstrutura[ny,8],{{TRB->TIPO,TRB->DOCTO,TRB->QTD,TRB->QTDENT,TRB->SALDO,DTOC(STOD(TRB->DTENT)),TRB->FORNEC,TRB->RESID,TRB->TPMV}}})
  	    Else
	      AADD(aMov[nPos1][2],{TRB->TIPO,TRB->DOCTO,TRB->QTD,TRB->QTDENT,TRB->SALDO,DTOC(STOD(TRB->DTENT)),TRB->FORNEC,TRB->RESID,TRB->TPMV})
	    EndIf

        aEstrutura[ny,10] ++

        dbSelectArea("TRB")
        dbSkip()
    End

   If SELECT("TRB") > 0
     TRB->(dbClosearea())
   Endif


Next ny

Return


Static Function GeraTRB(cOP,cProd)

Local cQuery := ""

If SELECT("TRB") > 0
   TRB->(dbClosearea())
Endif

cQuery := " SELECT 'SC' TIPO, C1_NUM DOCTO, C1_QUANT QTD, C1_QUJE QTDENT, C1_QUANT - C1_QUJE SALDO, C1_DATPRF DTENT, C1_FORNECE+C1_LOJA FORNEC, C1_RESIDUO RESID, 'N' TPMV
cQuery += " FROM "+RetSqlName("SC1")+ " SC1 "
cQuery += " WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"'"
cQuery += " AND   SC1.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC1.C1_PRODUTO = '"+cProd+"'"
cQuery += " AND   SC1.C1_OP = '"+cOP+"'"

cQuery += " UNION ALL "

cQuery += " SELECT 'PC' TIPO, C7_NUM DOCTO, C7_QUANT QTD, C7_QUJE QTDENT, C7_QUANT - C7_QUJE SALDO, C7_DATPRF DTENT, C7_FORNECE+C7_LOJA FORNEC, C7_RESIDUO RESID, 'N' TPMV
cQuery += " FROM "+RetSqlName("SC7")+ " SC7 "
cQuery += " WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"'"
cQuery += " AND   SC7.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC7.C7_PRODUTO = '"+cProd+"'"
cQuery += " AND   SC7.C7_OP = '"+cOP+"'"

cQuery += " UNION ALL "

cQuery += " SELECT 'NF' TIPO, D1_DOC+D1_SERIE DOCTO, D1_QUANT QTD, D1_QUANT QTDENT, 0 SALDO, D1_DTDIGIT DTENT, D1_FORNECE+D1_LOJA FORNEC, '' RESID, D1_TIPO TPMV
cQuery += " FROM "+RetSqlName("SD1")+ " SD1 "
cQuery += " WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"'"
cQuery += " AND   SD1.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SD1.D1_TIPO <> 'D' "   
cQuery += " AND   SD1.D1_COD = '"+cProd+"'"
cQuery += " AND   SD1.D1_OP IN ('"+cOP+"' , '' ) "
cQuery += " AND   SD1.D1_DTDIGIT >= '"+dtos(dDtaIni)+"'"
cQuery += " AND   SD1.D1_PEDIDO+SD1.D1_ITEMPC = (SELECT TOP 1 C7_NUM+C7_ITEM FROM "+RetSqlName("SC7")+ " SC7 "
cQuery += "                                      WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"'"
cQuery += "                                        AND SC7.C7_PRODUTO = '"+cProd+"'"
cQuery += "                                        AND SC7.C7_OP = '"+cOP+"' "
cQuery += "                                        AND SC7.D_E_L_E_T_ = '')

cQuery += " UNION ALL "

cQuery += " SELECT 'MV' TIPO, D3_DOC DOCTO, D3_QUANT QTD, D3_QUANT QTDENT, 0 SALDO, D3_EMISSAO DTENT, '' FORNEC, '' RESID, D3_TM TPMV
cQuery += " FROM "+RetSqlName("SD3")+ " SD3 "
cQuery += " WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"'"
cQuery += " AND   SD3.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SD3.D3_ESTORNO = '' "   
cQuery += " AND   SD3.D3_COD = '"+cProd+"'"
cQuery += " AND   SD3.D3_OP = '"+cOP+"'"

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)

dbSelectArea("TRB")   
dbGotop()


Return

//IMPRESSAO


Static Function GeraImp(aOps)

Local aAreaAtu	:= GetArea()


Private oPage		:= TMSPrinter():New( cTitulo )
Private oFontA		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
Private oFontAN		:= TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
Private oFontB		:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
Private oFontBN		:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
Private oFontC		:= TFont():New("Arial",15,15,,.F.,,,,.T.,.F.)
Private oFontCN		:= TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
Private oBrushA		:= TBrush():New( "", CLR_LIGHTGRAY )
Private oBrushB		:= TBrush():New( "", CLR_LIGHTGRAY )
Private oBrushC		:= TBrush():New( "", CLR_LIGHTGRAY )

Private aCabec	  := {}
Private aCabIni	  := {}
Private aItens	  := {}

Private aResumo  := {}
Private aAuxItem := {}
Private aTotGer  := {}
Private nPosV	  := 0

//�����������������������������������������������������������������������������������������Ŀ
//� Seta p�gina para paisagem                                                                �
//�������������������������������������������������������������������������������������������
//oPage:SetPortrait()         //Modo retrato
oPage:SetLandScape()		//Modo paisagem

//�����������������������������������������������������������������������������������������Ŀ
//� Define o tamanho da p�gina                                                              �
//�������������������������������������������������������������������������������������������
oPage:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))
//�����������������������������������������������������������������������������������������Ŀ
//� Inicializa o setup                                                                      �
//�������������������������������������������������������������������������������������������
If !( oPage:Setup() )
	Return( Nil )
EndIf
//�����������������������������������������������������������������������������������������Ŀ
//� Obtem/Define a largura da p�gina                                                        �
//�������������������������������������������������������������������������������������������
nHPage := oPage:nHorzRes()
nHPage *= ( 300 / oPage:nLogPixelX() )
nHPage -= 100

//�������������������������������������������������������������������������������������Ŀ
//� Inicializa a p�gina                                                                 �
//���������������������������������������������������������������������������������������
oPage:StartPage()

//�������������������������������������������������������������������������������������Ŀ
//� Zera os acumuladores do grid                                                        �
//���������������������������������������������������������������������������������������
aAuxItem	:= {}
//�������������������������������������������������������������������������������������Ŀ
//� Monta o array com o conte�do do cabe�alho                                           �
//���������������������������������������������������������������������������������������
aAdd( aAuxItem, {	"Empresa/Filial: " + SM0->M0_CODIGO + "/" + SM0->M0_CODFIL + " - " + AllTrim( SM0->M0_NOME ),;
upper(cTitulo),;
"P�gina: " + "nPage"  } ) // "nPage" recebe o contador de p�ginas na funcao u_dbmsr002
aAdd( aAuxItem, { 	"Siga/" + AllTrim( FunName() ) + "/v_" + SubStr( cVersao, 1, 6),;
"",;
"Data Refer�ncia: " + DToc( dDataBase ) } )
aAdd( aAuxItem, {	"Hora: " + Time(),;
"",;
"Data Emiss�o: " + DToc( MsDate() )	} )
//�������������������������������������������������������������������������������������Ŀ
//� prepara o array do cabe�alho                                                        �
//���������������������������������������������������������������������������������������
aCabec	:= { { ;
{	"",;												// 01-T�tulo do Grig
Nil,;													// 02-Fonte do T�tulo
Nil,;													// 03-Posicionamento do T�tulo
Nil,;													// 04-Imprime Negrito
Nil,;													// 05-Imprime Sombra
Nil,;													// 06-Imprime Box
Nil },;													// 05-Coluna de Ajuste
{	aClone( aAuxItem ),;								// 01-Array com Dados
1,;														// 02-Fonte dos Itens do Grid
{ "L", "C", "L" },;										// 03-Posicionamento dso Itens do Grid
.F.,;													// 04-Imprime Negrito
.F.,;													// 05-Imprime Sombra
.T.,;													// 06-Imprime Box
2 } ;												    // 08-Numero de paginas
} }


//�������������������������������������������������������������������������������������Ŀ
//� Zera os acumuladores do grid                                                        �
//���������������������������������������������������������������������������������������
aAuxItem	:= {}

//�������������������������������������������������������������������������������������Ŀ
//� Monta o cabe�alho das colunas do grid                                               �
//���������������������������������������������������������������������������������������
dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial()+left(cOpEst,8))

aAdd( aAuxItem, { 	"DADOS DA OP " })
aAdd( aAuxItem, { 	"OP      :" + left(cOpEst,8)+SC2->C2_SEQUEN })
aAdd( aAuxItem, { 	"PRODUTO :" + SC2->C2_PRODUTO + " - "+AllTrim(Posicione("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))})
aAdd( aAuxItem, { 	"EMISS�O :" + DTOC(SC2->C2_EMISSAO) })
aAdd( aAuxItem, { 	"INICIO  :" + DTOC(SC2->C2_DATPRI) })
aAdd( aAuxItem, { 	"PREVISAO:" + DTOC(SC2->C2_DATPRF) })
aAdd( aAuxItem, { 	"ENTREGA :" + DTOC(SC2->C2_DATRF) })
aAdd( aAuxItem, { 	"QUANT.  :" + Transform(SC2->C2_QUANT,"@E 9,999,999.9999")})

aCabIni	:= { { ;
{	"ORDEM DE PRODU��O ",;
2,;													   					// 02-Fonte do T�tulo
"C",;												   					// 03-Posicionamento do T�tulo
.T.,;																	// 04-Imprime Negrito
.T.,;																	// 05-Imprime Sombra
Nil,;												   					// 06-Imprime Box
Nil },;																	// 05-Coluna de Ajuste
{	aClone( aAuxItem ),;								  				// 01-Array com Dados
1,;													   					// 02-Fonte dos Itens do Grid
{"L" },;		                                                        // 03-Posicionamento dso Itens do Grid
.T.,;																	// 04-Imprime Negrito
.T.,;												   					// 05-Imprime Sombra
.T.,;												   					// 06-Imprime Box
Nil };													                // 07-Coluna de Ajuste
} }
 

aAuxItem	:= {}

aAdd( aAuxItem, {"OP","PRODUTO","QTD OP","SALDO OP","COMPONENTE","QTD EMP","SALDO EMP","TIPO MOV","DOCTO","QTD.","QTD ENTR.","SALDO","DTA ENTREGA","FORNECEDOR","RESIDUO","TP MOV"})
aAdd( aAuxItem, {"","","","","","","","","","","","","","","",""}) 


For ny := 1 to len(aOps)

     If Ascan(aAuxItem,{|x| x[1] == aOps[ny,1]}) = 0

       aAdd( aAuxItem, {aOps[ny,1],;
                        aOps[ny,2],;
                        Transform(aOps[ny,3],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,4],"@E 9,999,999.9999"),;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        "*****","*****","*****","*****","*****","*****","*****","*****","*****"})
      Else

       aAdd( aAuxItem, {"",;
                        "",;
                        "",;
                        "",;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        "*****","*****","*****","*****","*****","*****","*****","*****","*****"})

     EndIf

     nPos := Ascan(aMov,{|x| x[1] == aOps[ny,1]+aOps[ny,5]+aOps[ny,8]})

     If nPos <> 0

      For nx := 1 to len(aMov[nPos,2])

         aAdd( aAuxItem, {"","","","","","","",;
                          aMov[nPos,2][nx,1],;
                          aMov[nPos,2][nx,2],;
                          Transform(aMov[nPos,2][nx,3],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,4],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,5],"@E 9,999,999.9999"),;
                          aMov[nPos,2][nx,6],;
                          aMov[nPos,2][nx,7],;
                          aMov[nPos,2][nx,8],;
                          aMov[nPos,2][nx,9]})

       Next nx

       aAdd( aAuxItem, {"","","","","","","","","","","","","","","",""}) 
     
     Endif

Next ny


//�������������������������������������������������������������������������������������Ŀ
//� Monta o array com o grid                                                            �
//���������������������������������������������������������������������������������������
aItens	:= { { ;
{	cTitulo ,;
2,;													   					// 02-Fonte do T�tulo
"C",;												   						// 03-Posicionamento do T�tulo
.T.,;																			// 04-Imprime Negrito
.T.,;																			// 05-Imprime Sombra
Nil,;												   						// 06-Imprime Box
Nil },;																		// 05-Coluna de Ajuste
{	aClone( aAuxItem ),;								  					// 01-Array com Dados
1,;													   					// 02-Fonte dos Itens do Grid
{"L", "L", "C", "C","L","C","C","L","L","C","C","C","L","L","L","L"},;		                           // 03-Posicionamento dso Itens do Grid
.T.,;																			// 04-Imprime Negrito
.T.,;												   						// 05-Imprime Sombra
.T.,;												   						// 06-Imprime Box
Nil };													               // 07-Coluna de Ajuste
} }


//�������������������������������������������������������������������������������������Ŀ
//� Zera os acumuladores do grid                                                        �
//���������������������������������������������������������������������������������������
aAuxItem	:= {}

//�������������������������������������������������������������������������������������Ŀ
//� Executa a rotina que monta a imagem do relat�rio                                    �
//���������������������������������������������������������������������������������������
MsgRun("Gerando Imagem do Relat�rio", cTitulo, { || RodaImp( nPosV, 0, 0, nHPage, oPage, aCabec, aItens, aCabIni) } )
//�������������������������������������������������������������������������������������Ŀ
//� Finaliza a p�gina 				                                                    �
//���������������������������������������������������������������������������������������
oPage:EndPage()

//�����������������������������������������������������������������������������������������Ŀ
//� Fecha o arquivo tempor�rio e reposiciona no alias de abertura                           �
//�������������������������������������������������������������������������������������������

RestArea( aAreaAtu )

//�����������������������������������������������������������������������������������������Ŀ
//� Salva o relatorio em imagem JPG                                                         �
//�������������������������������������������������������������������������������������������
//oPage:SaveAllAsJpeg(cDirDocs+'\'+cNomArq,1140,875,140)

//�����������������������������������������������������������������������������������������Ŀ
//� Mostra na tela o relat�rio gerado                                                       �
//�������������������������������������������������������������������������������������������
oPage:Preview()

Return( Nil )


Static Function RodaImp(nPosVI, nPosHI, nPosVF, nPosHF, oPage, aCabec, aItens, aCabIni )

//�����������������������������������������������������������������������������������������Ŀ
//� Declara as vari�veis da rotina                                                          �
//�������������������������������������������������������������������������������������������
Local aTam	:= { 0, 0 }

Default nPosVI	:= 0
Default nPosHI	:= 0
Default nPosVF	:= 0
Default nPosHF	:= 0


aTam	:= U_DBMSR002(nPosVI,;							// Posi��o Vertical Inicial
			nPosHI,;											// Posi��o Horizontal Inicial
			nPosVF,;											// Posi��o Vertical Final
			nPosHF,;											// Posi��o Horizontal Final
			oPage,;											// Objeto da p�gina
			{ "2", aCabec },;								// 1= 1Pag/2= todas/3= nenhuma , Array com o Cabe�alho
			aCabIni;											// Array com os dados a serem impressos
			)



aTam	:= U_DBMSR002(aTam[1] + 50,;								// Posi��o Vertical Inicial
						nPosHI,;											// Posi��o Horizontal Inicial
						nPosVF,;											// Posi��o Vertical Final
						nPosHF,;											// Posi��o Horizontal Final
						oPage,;											// Objeto da p�gina
						{ "2", aCabec },;								// 1= 1Pag/2= todas/3= nenhuma , Array com o Cabe�alho
						aItens;											// Array com os dados a serem impressos
						)


Return( Nil )

//FIM DA IMPRESSAO
Static Function GeraExcel(aOps) 

Local cCabec     := ""
Local aCabExcel  := {"OP","PRODUTO","QTD OP","SALDO OP","COMPONENTE","QTD EMP","SALDO EMP","TIPO MOV","DOCTO","QTD.","QTD ENTR.","SALDO","DTA ENTREGA","FORNECEDOR","RESIDUO","TP MOV"}
Local aComExcel  := {}

dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial()+left(cOpEst,8))

cCabec := " DADOS DA OP ;" 
cCabec += " OP      :" + left(cOpEst,8)+SC2->C2_SEQUEN +";"
cCabec += " PRODUTO :" + SC2->C2_PRODUTO + " - "+AllTrim(Posicione("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))+";"
cCabec += " EMISS�O :" + DTOC(SC2->C2_EMISSAO) +";"
cCabec += " INICIO  :" + DTOC(SC2->C2_DATPRI) +";"
cCabec += " PREVISAO:" + DTOC(SC2->C2_DATPRF) +";"
cCabec += " ENTREGA :" + DTOC(SC2->C2_DATRF) +";"
cCabec += " QUANT.  :" + Transform(SC2->C2_QUANT,"@E 9,999,999.9999")

For ny := 1 to len(aOps)

     If Ascan(aComExcel,{|x| x[1] == aOps[ny,1]}) = 0

       aAdd( aComExcel, {aOps[ny,1],;
                        aOps[ny,2],;
                        Transform(aOps[ny,3],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,4],"@E 9,999,999.9999"),;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        "*****","*****","*****","*****","*****","*****","*****","*****","*****"})
      Else

       aAdd( aComExcel, {"",;
                        "",;
                        "",;
                        "",;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        "*****","*****","*****","*****","*****","*****","*****","*****","*****"})

     EndIf

     nPos := Ascan(aMov,{|x| x[1] == aOps[ny,1]+aOps[ny,5]+aOps[ny,8]})

     If nPos <> 0

      For nx := 1 to len(aMov[nPos,2])

         aAdd( aComExcel, {"","","","","","","",;
                          aMov[nPos,2][nx,1],;
                          "."+aMov[nPos,2][nx,2],;
                          Transform(aMov[nPos,2][nx,3],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,4],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,5],"@E 9,999,999.9999"),;
                          aMov[nPos,2][nx,6],;
                          "."+aMov[nPos,2][nx,7],;
                          aMov[nPos,2][nx,8],;
                          aMov[nPos,2][nx,9]})

       Next nx

       aAdd( aComExcel, {"","","","","","","","","","","","","","","",""}) 
     
     Endif

Next ny

DlgToExcel({ {"ARRAY",cCabec,aCabExcel,aComExcel} })

Return