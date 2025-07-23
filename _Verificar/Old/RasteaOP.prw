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
Local cQuebra      := ""
Local cKeyQbr      := ""
Local oTipoSal
Local lRegSD4      := .f.  

Private nQtdOrigEs := 1
Private cProdEst   := Criavar("D3_COD",.F.)
Private cOpEst     := Criavar("D3_OP",.F.)
Private cOpAtu     := Criavar("D3_OP",.F.)
Private nEstru     := 0
Private aHead_1    := {"OP","PRODUTO","QTD OP","SALDO OP","COMPONENTE","QTD EMP","SALDO EMP","ESTOQUE","ENDERECO","SEQUEN","LOCAL","TIPO MOV.","MOVIMENTAÇÕES"} 
Private aHead_2    := {"TIPO","DOCUMENTO","EMISSAO","QUANTIDADE","QTD ENTREGUE","SALDO","ENDERECO","DTA ENTREGA","FORNECEDOR","RESIDUO","TP MOV"}  
Private aMov       := {}
Private dDtaIni    := ctod("")
Private cTitulo    := "Rastreabilidade de OPs"
Private nOpcSaldo  := 3


DEFINE MSDIALOG oDlg FROM  140,000 TO 360,400 TITLE OemToAnsi("Informe Produto e a OP") PIXEL 
@ 10,15 TO 93,185 LABEL '' OF oDlg PIXEL	
@ 20,20 SAY Alltrim(RetTitle("D3_COD")) SIZE 70,9 OF oDlg PIXEL
@ 20,90 MSGET cProdEst F3 "SB1" Picture PesqPict("SD3","D3_COD") Valid (IIf(!Empty(cProdEst),ExistCpo("SB1",cProdEst),.t.)) SIZE 70,9 OF oDlg PIXEL
@ 35,20 SAY Alltrim(RetTitle("D3_OP")) SIZE 70,9 OF oDlg PIXEL
@ 35,90 MSGET cOpEst F3 "SC2OP" Picture PesqPict("SD3","D3_OP") Valid ((Vazio() .Or. ExistCpo("SC2",left(cOpEst,len(alltrim(cOpEst))))) .And. VerIniOP()) SIZE 70,9 OF oDlg PIXEL
@ 50,20 SAY Alltrim("Saldo Empenho") SIZE 70,9 OF oDlg PIXEL
@ 50,90 RADIO oTipoSal VAR nOpcSaldo 3D SIZE 70,10 PROMPT "Empenho=0", "Empenho<>0", "Todos" OF oDlg PIXEL 
DEFINE SBUTTON FROM 97,131 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 97,158 TYPE 2 ACTION (oDlg:End(),lOk:=.F.) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED 

If lOk 
	// Le os empenhos caso a op esteja preenchida
	If !Empty(cOPEst)
		
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial()+left(cOpEst,iif(Empty(cProdEst),6,8)))

        dDtaIni := SC2->C2_EMISSAO

        If Empty(cProdEst)
          cQuebra := SC2->C2_FILIAL+SC2->C2_NUM 
          cKeyQbr := "xFilial()+left(cOpEst,6)"
         Else
          cQuebra := SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM
          cKeyQbr := "xFilial()+left(cOpEst,8)"
        EndIf

		
		While !Eof() .And. cQuebra==&(cKeyQbr)

            cOpAtu := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"  "

		    dbSelectArea("SD4")
		    dbSetOrder(2)
		    dbSeek(xFilial()+cOpAtu)
		    While !Eof() .And. D4_FILIAL+D4_OP==xFilial()+cOpAtu
            
               lRegSD4 := .f.
               
               If nOpcSaldo = 1 
                 If SD4->D4_QUANT = 0
	                 lRegSD4 := .t.
			     EndIf                  						
               ElseIf nOpcSaldo = 2 
                 If SD4->D4_QUANT <> 0
	                 lRegSD4 := .t.
                 EndIf
               Else
                 lRegSD4 := .t.
               EndIf

               If lRegSD4
			      AADD(aEstrutura,{cOpAtu,;
			                       SC2->C2_PRODUTO,;
			                       SC2->C2_QUANT,;
			                       SC2->C2_QUANT-SC2->C2_QUJE,;
			                       SD4->D4_COD,;
			                       SD4->D4_QTDEORI,;
			                       SD4->D4_QUANT,;
			                       POSICIONE("SB2",1,XFILIAL()+SD4->D4_COD+SD4->D4_LOCAL,"B2_QATU"),; 
			                       POSICIONE("SB2",1,XFILIAL()+SD4->D4_COD+SD4->D4_LOCAL,"B2_LOCALIZ"),; 
			                       SD4->D4_TRT,;
			                       SD4->D4_LOCAL,"",0})						
               EndIf

			   dbSelectArea("SD4")
			   dbSkip()

		    End


		    dbSelectArea("SC2") 
		    dbSkip()

            If Empty(cProdEst)
             cQuebra := SC2->C2_FILIAL+SC2->C2_NUM 
             cKeyQbr := "xFilial()+left(cOpEst,6)"
            Else
             cQuebra := SC2->C2_FILIAL+SC2->C2_NUM+SC2->C2_ITEM
             cKeyQbr := "xFilial()+left(cOpEst,8)"
            EndIf

        End
    
    EndIf

EndIf

If !Empty(aEstrutura)
   MsgRun("Gerando Rastreabilidade", cTitulo, { || GeraMov(aEstrutura)} )
   TelaInicial(aEstrutura)
 Else
   Alert("Não ha nenhum empenho para essa OP !!!")
EndIf

Return


Static Function VerIniOP()

// Inicializa produto e quantidade
//If !Empty(cOPEst) .And. SC2->(MsSeek(xFilial("SC2")+left(cOpEst,len(alltrim(cOPEst)))))
//	cProdEst   := SC2->C2_PRODUTO
//EndIf

Return(.t.)


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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize    := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 1, .F., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .t., .t. )	
aPosObj[2][3] -= 14

DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel

	TGroup():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],"Ordem de Produção",, , ,.T.) 

    dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial()+left(cOpEst,iif(Empty(cProdEst),6,8)))
	//dbSeek(xFilial()+left(cOpEst,8))

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


	TButton():New(231,008, "Impressão", , { || MsAguarde ( { || GeraImp(aCols) } )}, 085, 010 ,,,,.T.)  
	TButton():New(251,008, "Excel"    , , { || MsAguarde ( { || GeraExcel(aCols) } )}, 085, 010 ,,,,.T.)  

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
Private cTitulo2 := "Rastreabilidade Movimentos"
Private cLine2   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize    := MsAdvSize()
aObjects := {}       
AAdd( aObjects, { 100, 1, .F., .T., .F. } )
AAdd( aObjects, { 1, 1, .T., .T., .F. } )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .t., .t. )	
aPosObj[2][3] -= 14

nPos := Ascan(aMov,{|x| x[1] == oListBox:AARRAY[oListBox:NAT][1]+oListBox:AARRAY[oListBox:NAT][5]+oListBox:AARRAY[oListBox:NAT][9]})
cDescComp := posicione("SB1",1,xFilial("SB1")+oListBox:AARRAY[oListBox:NAT][5],"B1_DESC")
cDescProd := posicione("SB1",1,xFilial("SB1")+oListBox:AARRAY[oListBox:NAT][2],"B1_DESC")

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

    @aPosObj[2][3] + 1 ,008 Say OemToAnsi("OP :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,020 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][1])

    @aPosObj[2][3] + 1 ,060 Say OemToAnsi("COMPONENTE :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,100 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][5])
    @aPosObj[2][3] + 6 ,100 Say OemToAnsi(AllTrim(cDescComp))

    @aPosObj[2][3] + 1 ,200 Say OemToAnsi("QTD :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,225 Say OemToAnsi(Transform(oListBox:AARRAY[oListBox:NAT][6],"@E 9,999,999.9999"))

    @aPosObj[2][3] + 1 ,305 Say OemToAnsi("SALDO :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,330 Say OemToAnsi(Transform(oListBox:AARRAY[oListBox:NAT][7],"@E 9,999,999.9999"))

    @aPosObj[2][3] + 1 ,385 Say OemToAnsi("VAI EM :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,410 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][2])
    @aPosObj[2][3] + 6 ,410 Say OemToAnsi(AllTrim(cDescProd))

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
	    nPos1:=  Ascan(aMov,{|x| x[1] == aEstrutura[ny,1]+aEstrutura[ny,5]+aEstrutura[ny,9]})
	    If nPos1==0
		   AADD(aMov,{aEstrutura[ny,1]+aEstrutura[ny,5]+aEstrutura[ny,9],{{TRB->TIPO,TRB->DOCTO,DTOC(STOD(TRB->EMISSAO)),TRB->QTD,TRB->QTDENT,TRB->SALDO,TRB->ENDERECO,DTOC(STOD(TRB->DTENT)),TRB->FORNEC,TRB->RESID,TRB->TPMV}}})
  	    Else
	      AADD(aMov[nPos1][2],{TRB->TIPO,TRB->DOCTO,DTOC(STOD(TRB->EMISSAO)),TRB->QTD,TRB->QTDENT,TRB->SALDO,TRB->ENDERECO,DTOC(STOD(TRB->DTENT)),TRB->FORNEC,TRB->RESID,TRB->TPMV})
	    EndIf

        aEstrutura[ny,12] ++
        aEstrutura[ny,11] := TRB->TIPO

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

cQuery := " SELECT 'SC' TIPO, C1_NUM DOCTO, C1_EMISSAO EMISSAO,C1_QUANT QTD, C1_QUJE QTDENT, C1_QUANT - C1_QUJE SALDO, '' ENDERECO, C1_DATPRF DTENT, C1_FORNECE+C1_LOJA FORNEC, C1_RESIDUO RESID, 'N' TPMV "
cQuery += " FROM "+RetSqlName("SC1")+ " SC1 "
cQuery += " WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"'"
cQuery += " AND   SC1.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC1.C1_PRODUTO = '"+cProd+"'"
cQuery += " AND   SC1.C1_OP = '"+cOP+"'"
cQuery += " AND   (SC1.C1_QUANT-SC1.C1_QUJE) > 0 "
cQuery += " AND    SC1.C1_RESIDUO = ' ' "                               
cQuery += " AND    SC1.C1_PEDIDO = ' ' "   
cQuery += " AND    SC1.C1_APROV NOT IN ('B','R') "   

cQuery += " UNION ALL "

cQuery += " SELECT 'PC' TIPO, C7_NUM DOCTO, C7_EMISSAO EMISSAO,C7_QUANT QTD, C7_QUJE QTDENT, C7_QUANT - C7_QUJE SALDO, '' ENDERECO, C7_DATPRF DTENT, C7_FORNECE+C7_LOJA FORNEC, C7_RESIDUO RESID, 'N' TPMV  "
cQuery += " FROM "+RetSqlName("SC7")+ " SC7 "
cQuery += " WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"'"
cQuery += " AND   SC7.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC7.C7_PRODUTO = '"+cProd+"'"
cQuery += " AND   SC7.C7_OP = '"+cOP+"'"  
cQuery += " AND    SC7.C7_CONAPRO = 'L' "            


cQuery += " UNION ALL "

cQuery += " SELECT 'NF' TIPO, D1_DOC+D1_SERIE DOCTO, D1_DTDIGIT EMISSAO,D1_QUANT QTD, D1_QUANT QTDENT, 0 SALDO,'' ENDERECO, D1_DTDIGIT DTENT, D1_FORNECE+D1_LOJA FORNEC, '' RESID, D1_TIPO TPMV   "
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

cQuery += " SELECT 'MV' TIPO, D3_DOC DOCTO,D3_EMISSAO EMISSAO, D3_QUANT QTD, D3_QUANT QTDENT, 0 SALDO, '' ENDERECO ,D3_EMISSAO DTENT, '' FORNEC, '' RESID, D3_TM TPMV "
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta página para paisagem                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oPage:SetPortrait()         //Modo retrato
oPage:SetLandScape()		//Modo paisagem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o tamanho da página                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPage:SetPaperSize(Val(GetProfString(GetPrinterSession(),"PAPERSIZE","1",.T.)))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o setup                                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !( oPage:Setup() )
	Return( Nil )
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem/Define a largura da página                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHPage := oPage:nHorzRes()
nHPage *= ( 300 / oPage:nLogPixelX() )
nHPage -= 100

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a página                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPage:StartPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera os acumuladores do grid                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxItem	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array com o conteúdo do cabeçalho                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd( aAuxItem, {	"Empresa/Filial: " + SM0->M0_CODIGO + "/" + SM0->M0_CODFIL + " - " + AllTrim( SM0->M0_NOME ),;
upper(cTitulo),;
"Página: " + "nPage"  } ) // "nPage" recebe o contador de páginas na funcao u_dbmsr002
aAdd( aAuxItem, { 	"Siga/" + AllTrim( FunName() ) + "/v_" + SubStr( cVersao, 1, 6),;
"",;
"Data Referência: " + DToc( dDataBase ) } )
aAdd( aAuxItem, {	"Hora: " + Time(),;
"",;
"Data Emissão: " + DToc( MsDate() )	} )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ prepara o array do cabeçalho                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCabec	:= { { ;
{	"",;												// 01-Título do Grig
Nil,;													// 02-Fonte do Título
Nil,;													// 03-Posicionamento do Título
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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera os acumuladores do grid                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxItem	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabeçalho das colunas do grid                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial()+left(cOpEst,iif(Empty(cProdEst),6,8)))
//dbSeek(xFilial()+left(cOpEst,8))

aAdd( aAuxItem, { 	"DADOS DA OP " })
aAdd( aAuxItem, { 	"OP      :" + left(cOpEst,8)+SC2->C2_SEQUEN })
aAdd( aAuxItem, { 	"PRODUTO :" + SC2->C2_PRODUTO + " - "+AllTrim(Posicione("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))})
aAdd( aAuxItem, { 	"EMISSÃO :" + DTOC(SC2->C2_EMISSAO) })
aAdd( aAuxItem, { 	"INICIO  :" + DTOC(SC2->C2_DATPRI) })
aAdd( aAuxItem, { 	"PREVISAO:" + DTOC(SC2->C2_DATPRF) })
aAdd( aAuxItem, { 	"ENTREGA :" + DTOC(SC2->C2_DATRF) })
aAdd( aAuxItem, { 	"QUANT.  :" + Transform(SC2->C2_QUANT,"@E 9,999,999.9999")})

aCabIni	:= { { ;
{	"ORDEM DE PRODUÇÃO ",;
2,;													   					// 02-Fonte do Título
"C",;												   					// 03-Posicionamento do Título
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

aAdd( aAuxItem, {"OP","PRODUTO","QTD OP","SALDO OP","COMPONENTE","QTD EMP","SALDO EMP","ESTOQUE","ENDERECO","TIPO MOV","DOCTO","EMISSAO","QTD.","QTD ENTR.","SALDO","DTA ENTREGA","FORNECEDOR","RESIDUO","TP MOV"})
aAdd( aAuxItem, {"","","","","","","","","","","","","","","","","",""}) 


For ny := 1 to len(aOps)

     If Ascan(aAuxItem,{|x| x[1] == aOps[ny,1]}) = 0

       aAdd( aAuxItem, {aOps[ny,1],;
                        aOps[ny,2],;
                        Transform(aOps[ny,3],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,4],"@E 9,999,999.9999"),;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,8],"@E 9,999,999.9999"),; 
                        IIF(aOps[ny,8] > 0,"'"+aOps[ny,9],"*****"),"*****","*****","*****","*****","*****","*****","*****","*****","*****"})
      Else

       aAdd( aAuxItem, {"",;
                        "",;
                        "",;
                        "",;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,8],"@E 9,999,999.9999"),;
                        IIF(aOps[ny,8] > 0,"'"+aOps[ny,9],"*****"),"*****","*****","*****","*****","*****","*****","*****","*****","*****"})

     EndIf

     nPos := Ascan(aMov,{|x| x[1] == aOps[ny,1]+aOps[ny,5]+aOps[ny,9]})

     If nPos <> 0

      For nx := 1 to len(aMov[nPos,2])

         aAdd( aAuxItem, {"","","","","","","","",;
                          aMov[nPos,2][nx,1],;
                          aMov[nPos,2][nx,2],;
                          aMov[nPos,2][nx,3],;
                          Transform(aMov[nPos,2][nx,4],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,5],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,6],"@E 9,999,999.9999"),;
                          aMov[nPos,2][nx,7],;
                          aMov[nPos,2][nx,8],;
                          aMov[nPos,2][nx,9],;
                          aMov[nPos,2][nx,10]})

       Next nx

       aAdd( aAuxItem, {"","","","","","","","","","","","","","","","","",""}) 
     
     Endif

Next ny


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array com o grid                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aItens	:= { { ;
{	cTitulo ,;
2,;													   					// 02-Fonte do Título
"C",;												   						// 03-Posicionamento do Título
.T.,;																			// 04-Imprime Negrito
.T.,;																			// 05-Imprime Sombra
Nil,;												   						// 06-Imprime Box
Nil },;																		// 05-Coluna de Ajuste
{	aClone( aAuxItem ),;								  					// 01-Array com Dados
1,;													   					// 02-Fonte dos Itens do Grid
{"L", "L", "C", "C","L","C","C","L","L","L","C","C","C","C","L","L","L","L"},;		                           // 03-Posicionamento dso Itens do Grid
.T.,;																			// 04-Imprime Negrito
.T.,;												   						// 05-Imprime Sombra
.T.,;												   						// 06-Imprime Box
Nil };													               // 07-Coluna de Ajuste
} }


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera os acumuladores do grid                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAuxItem	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a rotina que monta a imagem do relatório                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun("Gerando Imagem do Relatório", cTitulo, { || RodaImp( nPosV, 0, 0, nHPage, oPage, aCabec, aItens, aCabIni) } )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a página 				                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPage:EndPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha o arquivo temporário e reposiciona no alias de abertura                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RestArea( aAreaAtu )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva o relatorio em imagem JPG                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oPage:SaveAllAsJpeg(cDirDocs+'\'+cNomArq,1140,875,140)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra na tela o relatório gerado                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPage:Preview()

Return( Nil )


Static Function RodaImp(nPosVI, nPosHI, nPosVF, nPosHF, oPage, aCabec, aItens, aCabIni )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara as variáveis da rotina                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aTam	:= { 0, 0 }

Default nPosVI	:= 0
Default nPosHI	:= 0
Default nPosVF	:= 0
Default nPosHF	:= 0


aTam	:= U_DBMSR002(nPosVI,;							// Posição Vertical Inicial
			nPosHI,;											// Posição Horizontal Inicial
			nPosVF,;											// Posição Vertical Final
			nPosHF,;											// Posição Horizontal Final
			oPage,;											// Objeto da página
			{ "2", aCabec },;								// 1= 1Pag/2= todas/3= nenhuma , Array com o Cabeçalho
			aCabIni;											// Array com os dados a serem impressos
			)



aTam	:= U_DBMSR002(aTam[1] + 50,;								// Posição Vertical Inicial
						nPosHI,;											// Posição Horizontal Inicial
						nPosVF,;											// Posição Vertical Final
						nPosHF,;											// Posição Horizontal Final
						oPage,;											// Objeto da página
						{ "2", aCabec },;								// 1= 1Pag/2= todas/3= nenhuma , Array com o Cabeçalho
						aItens;											// Array com os dados a serem impressos
						)


Return( Nil )

//FIM DA IMPRESSAO
Static Function GeraExcel(aOps) 

Local cCabec     := ""
Local aCabExcel  := {"OP","PRODUTO","QTD OP","SALDO OP","COMPONENTE","DESCRICAO","QTD EMP","SALDO EMP","ESTOQUE","ENDERECO","TIPO MOV","DOCTO","EMISSAO","QTD.","QTD ENTR.","SALDO","DTA ENTREGA","FORNECEDOR","RESIDUO","TP MOV"}
Local aComExcel  := {}

dbSelectArea("SC2")
dbSetOrder(1)
//dbSeek(xFilial()+left(cOpEst,8))
dbSeek(xFilial()+left(cOpEst,iif(Empty(cProdEst),6,8)))

cCabec := " DADOS DA OP ;" 
cCabec += " OP      :" + left(cOpEst,8)+SC2->C2_SEQUEN +";"
cCabec += " PRODUTO :" + SC2->C2_PRODUTO + " - "+AllTrim(Posicione("SB1",1,xfilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))+";"
cCabec += " EMISSÃO :" + DTOC(SC2->C2_EMISSAO) +";"
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
                        GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+aOps[ny,5],1),;                                                        
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,8],"@E 9,999,999.9999"),; 
                        IIF(aOps[ny,8] > 0,"'"+aOps[ny,9],"*****"),"*****","*****","*****","*****","*****","*****","*****","*****","*****"})




      Else
/*/
       aAdd( aComExcel, {"",;
                        "",;
                        "",;
                        "",;
                        aOps[ny,5],;
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,8],"@E 9,999,999.9999"),;
                        IIF(aOps[ny,8] > 0,"'"+aOps[ny,9],"*****"),"*****","*****","*****","*****","*****","*****","*****","*****","*****"})
/*/

       aAdd( aComExcel, {aOps[ny,1],;
                        aOps[ny,2],;
                        Transform(aOps[ny,3],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,4],"@E 9,999,999.9999"),;
                        aOps[ny,5],;
                        GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+aOps[ny,5],1),;                                                        
                        Transform(aOps[ny,6],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,7],"@E 9,999,999.9999"),;
                        Transform(aOps[ny,8],"@E 9,999,999.9999"),; 
                        IIF(aOps[ny,8] > 0,"'"+aOps[ny,9],"*****"),"*****","*****","*****","*****","*****","*****","*****","*****","*****"})


     EndIf

     nPos := Ascan(aMov,{|x| x[1] == aOps[ny,1]+aOps[ny,5]+aOps[ny,9]})

     If nPos <> 0

      For nx := 1 to len(aMov[nPos,2])

         aAdd( aComExcel, {"","","","","","","","",;
                          aMov[nPos,2][nx,1],;
                          "."+aMov[nPos,2][nx,2],;
                          aMov[nPos,2][nx,3],;
                          Transform(aMov[nPos,2][nx,4],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,5],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,6],"@E 9,999,999.9999"),;
                          aMov[nPos,2][nx,7],;
                          "."+aMov[nPos,2][nx,8],;
                          aMov[nPos,2][nx,9],;
                          aMov[nPos,2][nx,10]})

       Next nx

       aAdd( aComExcel, {"","","","","","","","","","","","","","","","","",""}) 
     
     Endif

Next ny

DlgToExcel({ {"ARRAY",cCabec,aCabExcel,aComExcel} })

Return