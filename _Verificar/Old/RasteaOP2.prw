#include "prothesp.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

User Function RastOP2()

Local i:=0,nx:=0
Local oDlg
Local lOk          := .T.
Local nPos         := 0

Private nQtdOrigEs := 1
Private cProdEst   := Criavar("D3_COD",.F.)
Private cOpEst     := Criavar("D3_OP",.F.)
Private cOpAtu     := Criavar("D3_OP",.F.)
Private nEstru     := 0
Private aHead_1    := {"LINHA","NIVEL","PRODUTO","COMPONENTE","TIPO","DESCRICAO","UM","SEQUEN","DTA INI","DTA FIM","ALMOX.","QTD ESTRU","QTD ESTOQUE","ENDERECO","QTD EMP","SALDO EMP","OP","EMISSAO OP","PREVISAO OP","APONT. OP","QTD OP","SALDO OP","MOVIMENTAÇÕES","K1"} 
Private aHead_2    := {"TIPO","DOCUMENTO","EMISSAO","QUANTIDADE","QTD ENTREGUE","SALDO","ENDERECO","DTA ENTREGA","FORNECEDOR"}  
Private aMov       := {}
Private dDtaIni    := ctod("")
Private cTitulo    := "Rastreabilidade de OPs"
Private nOpcSaldo  := 3
Private nCntItens  := 0
Private aEstrutura   := {}
Private _aEstrutura :={}

DEFINE MSDIALOG oDlg FROM  140,000 TO 360,400 TITLE OemToAnsi("Informe Produto e a OP") PIXEL 
@ 10,15 TO 93,185 LABEL '' OF oDlg PIXEL	
@ 20,20 SAY Alltrim(RetTitle("D3_COD")) SIZE 70,9 OF oDlg PIXEL
@ 20,90 MSGET cProdEst F3 "SB1" Picture PesqPict("SD3","D3_COD") Valid (IIf(!Empty(cProdEst),ExistCpo("SB1",cProdEst),.t.)) SIZE 70,9 OF oDlg PIXEL
@ 35,20 SAY Alltrim(RetTitle("D3_OP")) SIZE 70,9 OF oDlg PIXEL
@ 35,90 MSGET cOpEst F3 "SC2" Picture PesqPict("SD3","D3_OP") SIZE 70,9 OF oDlg PIXEL
DEFINE SBUTTON FROM 97,131 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
DEFINE SBUTTON FROM 97,158 TYPE 2 ACTION (oDlg:End(),lOk:=.F.) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED 

If Empty(cProdEst)
   Alert("Informe um codigo de Produto !!!")
   lOk := .f.
EndIf

If lOk 


    MsgRun("Analisando Estrutura", cTitulo, { || VerEstru(cProdEst)} )
    MsgRun("Analisando Estrutura Pai", cTitulo, { || VerPai()} )

	// Le os empenhos caso a op esteja preenchida
	If !Empty(cOPEst)
		
        MsgRun("Analisando Ordem de Producao", cTitulo, { || VerOps(cOPEst)} )

    EndIf

EndIf

If !Empty(aEstrutura)
  If !Empty(cOPEst)
    MsgRun("Gerando Rastreabilidade", cTitulo, { || GeraMov(aEstrutura)} )
  EndIf
  TelaInicial(aEstrutura)
 Else
   Alert("Não ha estrutura para esse produto !!!")
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

	TGroup():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],"Produto",, , ,.T.) 


    @056,008 Say OemToAnsi("PRODUTO :") COLOR CLR_HBLUE
    @066,008 Say cProdEst
    @076,008 Say AllTrim(Posicione("SB1",1,xfilial("SB1")+cProdEst,"B1_DESC"))

    @141,008 Say OemToAnsi("ITENS ESTRUTURA :") COLOR CLR_HBLUE
    @151,008 Say OemToAnsi(Transform(nCntItens,"@E 99999")) 


	//TButton():New(251,008, "Impressão", , { || MsAguarde ( { || GeraImp(aCols) } )}, 085, 010 ,,,,.T.)  
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

nPos := Ascan(aMov,{|x| x[1] == oListBox:AARRAY[oListBox:NAT][16]+oListBox:AARRAY[oListBox:NAT][4]+oListBox:AARRAY[oListBox:NAT][8]})
cDescComp := posicione("SB1",1,xFilial("SB1")+oListBox:AARRAY[oListBox:NAT][4],"B1_DESC")
cDescProd := posicione("SB1",1,xFilial("SB1")+oListBox:AARRAY[oListBox:NAT][3],"B1_DESC")

If nPos = 0
   Return()
Endif

cLine2   := "{ aMov["+AllTrim(Str(nPos))+"][2][oListBox2:nAt][1] "

For nI:=2 To Len(aHead_2)
	cLine2 += " ,aMov["+AllTrim(Str(nPos))+"][2][oListBox2:nAt][" + AllTrim(Str(nI)) + "]"
Next nI

cLine2 += "}"
bLine2 := &( "{|| " + cLine2 + "}" )                                                                             

DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel


	SButton():New(aPosObj[2][3] + 3, aPosObj[2][4] - 30 , 01 , { || oDlg2:End() }, oDlg2, .T. )

    @aPosObj[2][3] + 1 ,008 Say OemToAnsi("OP :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,020 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][16])

    @aPosObj[2][3] + 1 ,060 Say OemToAnsi("COMPONENTE :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,100 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][4])
    @aPosObj[2][3] + 6 ,100 Say OemToAnsi(AllTrim(cDescComp))

    @aPosObj[2][3] + 1 ,200 Say OemToAnsi("QTD :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,225 Say OemToAnsi(Transform(oListBox:AARRAY[oListBox:NAT][14],"@E 9,999,999.9999"))

    @aPosObj[2][3] + 1 ,305 Say OemToAnsi("SALDO :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,330 Say OemToAnsi(Transform(oListBox:AARRAY[oListBox:NAT][15],"@E 9,999,999.9999"))

    @aPosObj[2][3] + 1 ,385 Say OemToAnsi("VAI EM :") COLOR CLR_HBLUE
    @aPosObj[2][3] + 1 ,410 Say OemToAnsi(oListBox:AARRAY[oListBox:NAT][3])
    @aPosObj[2][3] + 6 ,410 Say OemToAnsi(AllTrim(cDescProd))

	oListBox2 := TWBrowse():New( aPosObj[2][1],aPosObj[2][2]-100,aPosObj[2][4]-10,aPosObj[2][3]-20,,aHead_2,,oDlg2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox2:SetArray(aMov[nPos][2])
	oListBox2:bLine := bLine2


ACTIVATE DIALOG oDlg2  CENTERED 


Return

Static Function GeraMov(aEstrutura)

Local nPos1  := 0

aMov := {}

For ny := 1 to len(aEstrutura)

 If !empty(aEstrutura[ny,16])  //op
//		_aEstrutura[1]                                      

//    If type(aEstrutura[ny,16]) == "N"  
//	    GeraTRB(aEstrutura[ny,17],aEstrutura[ny,4]) //op, componente
//    Else
	    GeraTRB(_aEstrutura[1][1],aEstrutura[ny,4]) //op, componente
//    EndIf
    
    dbSelectArea("TRB")
    While !eof()
	    nPos1:=  Ascan(aMov,{|x| x[1] == aEstrutura[ny,16]+aEstrutura[ny,4]+aEstrutura[ny,8]})
	    If nPos1==0
		   AADD(aMov,{_aEstrutura[1][1]+aEstrutura[ny,4]+aEstrutura[ny,8],{{TRB->TIPO,TRB->DOCTO,STOD(TRB->EMISSAO),TRB->QTD,TRB->QTDENT,TRB->SALDO,STOD(TRB->DTENT),TRB->FORNEC}}})
  	    Else
	      AADD(aMov[nPos1][2],{TRB->TIPO,TRB->DOCTO,STOD(TRB->EMISSAO),TRB->QTD,TRB->QTDENT,TRB->SALDO,STOD(TRB->DTENT),TRB->FORNEC})
	    EndIf

//        aEstrutura[ny,22] := aEstrutura[ny,22] + TRB->TIPO +"/"

        dbSelectArea("TRB")
        dbSkip()
    End

   If SELECT("TRB") > 0
     TRB->(dbClosearea())
   Endif

 EndIf

Next ny

Return


Static Function GeraTRB(cOP,cProd)

Local cQuery := ""

If SELECT("TRB") > 0
   TRB->(dbClosearea())
Endif                          

cQuery := " SELECT 'SC' TIPO, C1_NUM DOCTO, C1_EMISSAO EMISSAO,C1_QUANT QTD, C1_QUJE QTDENT, C1_QUANT - C1_QUJE SALDO, C1_DATPRF DTENT, C1_FORNECE+C1_LOJA FORNEC, C1_RESIDUO RESID, 'N  ' TPMV
cQuery += " FROM "+RetSqlName("SC1")+ " SC1 "
cQuery += " WHERE SC1.C1_FILIAL='"+xFilial("SC1")+"'"
cQuery += " AND   SC1.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC1.C1_PRODUTO = '"+cProd+"'"
cQuery += " AND   SC1.C1_OP = '"+cOP+"'"     
cQuery += " AND    SC1.C1_RESIDUO = ' ' "                               
cQuery += " AND    SC1.C1_PEDIDO = ' ' "   
cQuery += " AND    SC1.C1_APROV NOT IN ('B','R') "   

cQuery += " UNION ALL "

cQuery += " SELECT 'PC' TIPO, C7_NUM DOCTO, C7_EMISSAO EMISSAO,C7_QUANT QTD, C7_QUJE QTDENT, C7_QUANT - C7_QUJE SALDO, C7_DATPRF DTENT, C7_FORNECE+C7_LOJA FORNEC, C7_RESIDUO RESID, 'N  ' TPMV
cQuery += " FROM "+RetSqlName("SC7")+ " SC7 "
cQuery += " WHERE SC7.C7_FILIAL='"+xFilial("SC7")+"'"
cQuery += " AND   SC7.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC7.C7_PRODUTO = '"+cProd+"'"
cQuery += " AND   SC7.C7_OP = '"+cOP+"'"
cQuery += " AND    SC7.C7_CONAPRO = 'L' "            

cQuery += " UNION ALL "

cQuery += " SELECT 'NF' TIPO, D1_DOC+D1_SERIE DOCTO, D1_DTDIGIT EMISSAO,D1_QUANT QTD, D1_QUANT QTDENT, 0 SALDO, D1_DTDIGIT DTENT, D1_FORNECE+D1_LOJA FORNEC, ' ' RESID, D1_TIPO TPMV
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

cQuery += " SELECT 'MV' TIPO, D3_DOC DOCTO,D3_EMISSAO EMISSAO, D3_QUANT QTD, D3_QUANT QTDENT, 0 SALDO, D3_EMISSAO DTENT, '' FORNEC, ' ' RESID, D3_TM TPMV
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

Return( Nil )

//FIM DA IMPRESSAO

Static Function GeraExcel(aOps) 

Local cCabec     := ""
Local aCabExcel  := {}
Local aComExcel  := {}
//                        1      2         3           4         5        6         7     8         9        10        11        12             13          14       15         16        17    18            19             20          21        22           23         24
Private aCabExcel := {"LINHA","NIVEL","PRODUTO","COMPONENTE","TIPO","DESCRICAO","UM","SEQUEN","DTA INI","DTA FIM","ALMOX.","QTD ESTRU","QTD ESTOQUE","ENDERECO","QTD EMP","SALDO EMP","OP","EMISSAO OP","PREVISAO OP","APONT. OP","QTD OP","SALDO OP","MOVIMENTAÇÕES","K1"} //,; 
//                      "TIPO","DOCUMENTO","EMISSAO","QUANTIDADE","QTD ENTREGUE","SALDO","DTA ENTREGA","FORNECEDOR"}  

cCabec := " PRODUTO :" + cProdEst + " - "+AllTrim(Posicione("SB1",1,xfilial("SB1")+cProdEst,"B1_DESC"))+";"

For ny := 1 to len(aOps)


       aAdd( aComExcel, {aOps[ny,1],;
                         aOps[ny,2],;
                         aOps[ny,3],;
                         aOps[ny,4],;
                         aOps[ny,5],;
                         aOps[ny,6],;
                         aOps[ny,7],;
                         aOps[ny,8],;
                         aOps[ny,9],;                                                        
                         aOps[ny,10],;                                                        
                         aOps[ny,11],;                                                        
                         Transform(aOps[ny,12],"@E 9,999,999.9999"),;
                         Transform(aOps[ny,13],"@E 9,999,999.9999"),;
                         Transform(aOps[ny,14],"@E 9,999,999.9999"),;
                         Transform(aOps[ny,15],"@E 9,999,999.9999"),;
                         aOps[ny,16],;
                         aOps[ny,17],;
                         aOps[ny,18],;
                         aOps[ny,19],;
                         Transform(aOps[ny,20],"@E 9,999,999.9999"),;
                         Transform(aOps[ny,21],"@E 9,999,999.9999"),;
                         aOps[ny,22],;
                         aOps[ny,23]}) //,;
//                         "*****","*****","*****","*****","*****","*****","*****","*****"})
/*/
     nPos := Ascan(aMov,{|x| x[1] == aOps[ny,16]+aOps[ny,4]+aOps[ny,8]})

     If nPos <> 0

      For nx := 1 to len(aMov[nPos,2])

         aAdd( aComExcel, {"MVT","","","","","","","","","","","","","","","","","","","","","",;
                          aMov[nPos,2][nx,1],;
                          "."+aMov[nPos,2][nx,2],;
                          aMov[nPos,2][nx,3],;
                          Transform(aMov[nPos,2][nx,4],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,5],"@E 9,999,999.9999"),;
                          Transform(aMov[nPos,2][nx,6],"@E 9,999,999.9999"),;
                          aMov[nPos,2][nx,7],;
                          "."+aMov[nPos,2][nx,8]})

       Next nx
     
     Endif
/*/

Next ny

DlgToExcel({ {"ARRAY",cCabec,aCabExcel,aComExcel} })

Return


Static Function VerEstru(cProd)

Local nNivel     := 2
Local nQuantPai  := 1
Local nQtdBase   := 1

Private lNegEstr:=GETMV("MV_NEGESTR")

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProd)
  dbSelectArea("SG1")
  dbSetOrder(1)
  If dbSeek(xFilial("SG1")+cProd)
    MR225Expl(cProd,nQuantPai,nNivel,RetFldProd(SB1->B1_COD,"B1_OPC"),nQtdBase,SB1->B1_REVATU,.t.)
  EndIf
EndIf

Return

Static Function MR225Expl(cProduto,nQuantPai,nNivel,cOpcionais,nQtdBase,cRevisao,lPri)

LOCAL nReg,nQuantItem := 0
LOCAL nPrintNivel
LOCAL nX        := 0
LOCAL aObserv   := {}
LOCAL aAreaSB1  :={}
LOCAL cAteNiv   := "999"

dbSelectArea("SG1")
While !Eof() .And. G1_FILIAL+G1_COD == xFilial("SG1")+cProduto

	nReg       := Recno()
	nQuantItem := ExplEstr(nQuantPai,,cOpcionais,cRevisao)
	dbSelectArea("SG1")
	If nNivel <= Val(cAteNiv) // Verifica ate qual Nivel devera ser impresso
		If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))
             If lPri
				dbSelectArea("SB1")
				aAreaSB1:=GetArea()
				dbSeek(xFilial("SB1")+cProduto)
                   Aadd(aEstrutura,{ "000001" ,;                    //LINHA
                                     "001",;     				  //nivel
                                     cProduto,;  				  //produto
				                     cProduto,;          		  // componente
				                     SB1->B1_TIPO,; 			  //tipo
				                     SubStr(SB1->B1_DESC,1,34),; //descricao
				                     SB1->B1_UM,;  				  //UM
                                     "",;        				  //SEQUENCIA
			                         ctod(""),;	                  //DT INI
			                         ctod(""),;	                  //DT FIM
                                     "01",;                       //LOCAL
			                         1,;                          //QTD ESTRU
                                     POSICIONE("SB2",1,XFILIAL()+cProduto+"01","B2_QATU"),;  //ESTOQUE
                                     POSICIONE("SB2",1,XFILIAL()+cProduto+"01","B2_LOCALIZ"),;  //ESTOQUE
                                     0,;                         //QTD EMPENHO
                                     0,;                         //SALDO EMPENHO
                                     "",;                        //OP
                                     CTOD(""),;                  //EMIS OP
                                     CTOD(""),;                  //PREV OP
                                     CTOD(""),;                  //ENCER OP
                                     0,;                         //QTD OP
                                     0,;                         //SALDO OP
                                     "",;                        //MOVIMENTOS
                                     0,""})                     // K1

				RestArea(aAreaSB1)
				dbSelectArea("SG1")
                lPri := .f.
		      EndIf

			  SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
		
               Aadd(aEstrutura,{ StrZero(Len(aEstrutura)+1,6),; //LINHA
                                 StrZero(nNivel,3),; 		     //nivel
                                 G1_COD,;  				         //produto
				                 G1_COMP,;          		     // componente
				                 SB1->B1_TIPO,; 			     //tipo
				                 SubStr(SB1->B1_DESC,1,34),;    //descricao
				                 SB1->B1_UM,;  				     //UM
                                 Substr(G1_TRT,1,3),;           //SEQUENCIA
			                     G1_INI,;	                     //DT INI
			                     G1_FIM,;	                     //DT FIM
                                 "01",;                            //LOCAL
                                 nQuantItem,;                    //QTD ESTRU
                                 POSICIONE("SB2",1,XFILIAL()+G1_COMP+"01","B2_QATU"),;  //ESTOQUE
                                 POSICIONE("SB2",1,XFILIAL()+G1_COMP+"01","B2_LOCALIZ"),;  //ESTOQUE
                                 0,;                             //QTD EMPENHO
                                 0,;                             //SALDO EMPENHO
                                 "",;                            //OP
                                 CTOD(""),;                      //EMIS OP
                                 CTOD(""),;                      //PREV OP
                                 CTOD(""),;                      //ENCER OP
                                 0,;                             //QTD OP
                                 0,;                             //SALDO OP
                                 "",;                            //MOVIMENTOS
                                 0,""})                          //K1

			
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Verifica se existe sub-estrutura                ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			   dbSelectArea("SG1")
			   If dbSeek(xFilial("SG1")+G1_COMP)
				 //MR225Expl(G1_COD,nQuantItem,nNivel+1,cOpcionais,nQtdBase,SB1->B1_REVATU,.f.)
			   EndIf
			
			   dbGoto(nReg)
		EndIf
	EndIf
	
	dbSkip()
	
	nCntItens++

EndDo

nCntItens := LEN(aEstrutura)-1

Return()

Static Function VerPai()

Local nPos := 0

If !empty(aEstrutura)

  For nx := 2 to len(aEstrutura)

	 nPos:=  Ascan(aEstrutura,{|x| x[4] == aEstrutura[nx,3]})

     If nPos <> 0

        aEstrutura[nx,24] := aEstrutura[nPos,3]          

     EndIf

  Next nx

EndIf

Return

Static Function VerOps(cCodOp)

Local cQuery  := ""
Local cCodPai := ""
If SELECT("TRBSC2") > 0
   TRBSC2->(dbClosearea())
Endif

cQuery := " SELECT * 
cQuery += " FROM "+RetSqlName("SC2")+ " SC2 "
cQuery += " WHERE SC2.C2_FILIAL='"+xFilial("SC2")+"'"
cQuery += " AND   SC2.D_E_L_E_T_ <> '*' "   
cQuery += " AND   SC2.C2_NUM LIKE '%"+Alltrim(cCodOp)+"%'"
cQuery += " ORDER BY C2_NUM,C2_ITEM,C2_SEQUEN

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBSC2", .F., .T.)

dbSelectArea("TRBSC2")    
dbGotop()                              

While !Eof() 

    cOpAtu := TRBSC2->C2_NUM+TRBSC2->C2_ITEM+TRBSC2->C2_SEQUEN+"  "

    IF !Empty(TRBSC2->C2_SEQPAI)
         dbSelectArea("SC2")
         dbSetOrder(1)
         If dbSeek(xFilial()+TRBSC2->C2_NUM+TRBSC2->C2_ITEM+TRBSC2->C2_SEQPAI)
            cCodPai := SC2->C2_PRODUTO
          Else
           cCodPai := TRBSC2->C2_PRODUTO
         EndIf
      Else
       cCodPai := TRBSC2->C2_PRODUTO
    EndIf
    
    dbSelectArea("SD4")
	dbSetOrder(2)
	dbSeek(xFilial()+cOpAtu)
	While !Eof() .And. D4_FILIAL+D4_OP==xFilial()+cOpAtu
            

	              nPos :=  AchaEstru(TRBSC2->C2_PRODUTO+SD4->D4_COD+SD4->D4_TRT+cCodPai,1) // Ascan(aEstrutura,{|x| x[3]+x[4]+x[8]+x[23] == TRBSC2->C2_PRODUTO+SD4->D4_COD+SD4->D4_TRT+cCodPai})

                  If nPos <> 0

                     aEstrutura[nPos][11] := SD4->D4_LOCAL 
                     aEstrutura[nPos][13] := POSICIONE("SB2",1,XFILIAL()+SD4->D4_COD+SD4->D4_LOCAL,"B2_QATU") 
                     aEstrutura[nPos][14] := SD4->D4_QTDEORI
                     aEstrutura[nPos][15] := SD4->D4_QUANT 
                     aEstrutura[nPos][16] := cOpAtu
                     aEstrutura[nPos][17] := STOD(TRBSC2->C2_EMISSAO)
                     aEstrutura[nPos][18] := STOD(TRBSC2->C2_DATPRF)
                     aEstrutura[nPos][19] := STOD(TRBSC2->C2_DATRF)
                     aEstrutura[nPos][20] := TRBSC2->C2_QUANT
                     aEstrutura[nPos][21] := TRBSC2->C2_QUANT-TRBSC2->C2_QUJE

                   Else
	                 
	                 nPos :=  AchaEstru(TRBSC2->C2_PRODUTO+SD4->D4_COD+SD4->D4_TRT,2) 

                     If nPos <> 0

                       aEstrutura[nPos][11] := SD4->D4_LOCAL 
                       aEstrutura[nPos][13] := POSICIONE("SB2",1,XFILIAL()+SD4->D4_COD+SD4->D4_LOCAL,"B2_QATU") 
                       aEstrutura[nPos][14] := SD4->D4_QTDEORI
                       aEstrutura[nPos][15] := SD4->D4_QUANT 
                       aEstrutura[nPos][16] := cOpAtu
                       aEstrutura[nPos][17] := STOD(TRBSC2->C2_EMISSAO)
                       aEstrutura[nPos][18] := STOD(TRBSC2->C2_DATPRF)
                       aEstrutura[nPos][19] := STOD(TRBSC2->C2_DATRF)
                       aEstrutura[nPos][20] := TRBSC2->C2_QUANT
                       aEstrutura[nPos][21] := TRBSC2->C2_QUANT-TRBSC2->C2_QUJE

			        Else                                 
			                                   
			          If Len(_aEstrutura) == 0                   
				          AADD(_aEstrutura,{cOpAtu})
				      EndIf    
			     
			          AADD(aEstrutura,{StrZero(Len(aEstrutura)+1,6),;
			                           "OPS",;
			                           TRBSC2->C2_PRODUTO,;
			                           SD4->D4_COD,;
                                       posicione("SB1",1,xFilial()+SD4->D4_COD,"B1_TIPO"),;
                                       LEFT(posicione("SB1",1,xFilial()+SD4->D4_COD,"B1_DESC"),34),;
                                       posicione("SB1",1,xFilial()+SD4->D4_COD,"B1_UM"),;
			                           SD4->D4_TRT,;
                                       CTOD(""),;
                                       CTOD(""),;
			                           SD4->D4_LOCAL,;
                                       0,;
			                           POSICIONE("SB2",1,XFILIAL()+SD4->D4_COD+SD4->D4_LOCAL,"B2_QATU"),; 
			                           POSICIONE("SB2",1,XFILIAL()+SD4->D4_COD+SD4->D4_LOCAL,"B2_LOCALIZ"),; 
			                           SD4->D4_QTDEORI,;
			                           SD4->D4_QUANT,;  
			                           cOpAtu,;
                                       STOD(TRBSC2->C2_EMISSAO),;
                                       STOD(TRBSC2->C2_DATPRF),;
                                       STOD(TRBSC2->C2_DATRF),;
                                       TRBSC2->C2_QUANT,;
			                           TRBSC2->C2_QUANT-TRBSC2->C2_QUJE,;
			                           "",0,""})						

	                   AchaEstru(SD4->D4_COD,3) 


                    EndIf
                                                                 '
                  EndIf

			      dbSelectArea("SD4")
			      dbSkip()

	 End


     dbSelectArea("TRBSC2") 
     dbSkip()


End

If SELECT("TRBSC2") > 0
   TRBSC2->(dbClosearea())
Endif

//Monta a coluna K1 estoque-saldo empenho
For nt := 1 to len(aEstrutura)
  aEstrutura[nt,23] := aEstrutura[nt,13]-aEstrutura[nt,15]   
Next nt

Return()


Static Function AchaEstru(cChave,nTipo)

Local nRetorno := 0
Local nt       := 0

// Ascan(aEstrutura,{|x| x[3]+x[4]+x[8]+x[23] == TRBSC2->C2_PRODUTO+SD4->D4_COD+SD4->D4_TRT+cCodPai})
DO CASE

 CASE nTipo = 1
   For nt := 1 to len(aEstrutura)

/*/
     If aEstrutura[nt,3]+aEstrutura[nt,4]+aEstrutura[nt,8]+aEstrutura[nt,24] = cChave      
         If Empty(aEstrutura[nt,16])
           nRetorno := nt
           Exit
         EndIf
     EndIf   
/*/

         If Empty(aEstrutura[nt,16])
           nRetorno := nt
           Exit
         EndIf


 
   Next nt

 CASE nTipo = 2

  For nt := 1 to len(aEstrutura)

     If aEstrutura[nt,3]+aEstrutura[nt,4]+aEstrutura[nt,8] = cChave      
         If Empty(aEstrutura[nt,16])
           nRetorno := nt
           Exit
         EndIf
     EndIf
 
  Next nt

 CASE nTipo = 3

  For nt := 1 to len(aEstrutura)

     If aEstrutura[nt,4] = cChave      
         If Empty(aEstrutura[nt,22]) .AND. AllTrim(aEstrutura[nt,2]) <> "OPS"
           aEstrutura[nt,22] := "OPS/"
         EndIf
     EndIf
 
  Next nt

ENDCASE

Return(nRetorno)