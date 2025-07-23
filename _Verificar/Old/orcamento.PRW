#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"


User Function ORCAMENTO()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg := NIL
LOCAL cString	:= "SCJ"
PRIVATE titulo 	:= ""
PRIVATE nLastKey:= 0
PRIVATE cPerg	:= "ORCAME    "
PRIVATE nomeProg:= FunName()

AjustaSx1()

If ! Pergunte(cPerg,.T.)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Orcamento                      		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := FunName()            //Nome Default do relatorio em Disco

PRIVATE cTitulo := "Impressão do Orcamento de Vendas"
PRIVATE oPrn    := NIL
PRIVATE oFont1  := NIL
PRIVATE oFont2  := NIL
PRIVATE oFont3  := NIL
PRIVATE oFont4  := NIL
PRIVATE oFont5  := NIL
PRIVATE oFont6  := NIL
Private nLastKey := 0
Private nLin := 1650 // Linha de inicio da impressao das clausulas contratuais

DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
DEFINE FONT oFont6 NAME "Courier New" BOLD

oFont08	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
oFont10	 := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
oFont14	 := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont16	 := TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)
oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont12  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont12N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont16N := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont06	 := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela de Entrada de Dados - Parametros                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLastKey  := IIf(LastKey() == 27,27,nLastKey)

If nLastKey == 27
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do lay-out / impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oPrn := TMSPrinter():New(cTitulo)
oPrn:Setup()
oPrn:SetPortrait() //SetLandsCape()//SetPortrait() //SetLansCape()
oPrn:StartPage()
Imprimir()
oPrn:EndPage()
oPrn:End()

DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL

@ 015,017 SAY "Esta rotina tem por objetivo imprimir"	OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 030,017 SAY "o impresso customizado:"					OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE
@ 045,017 SAY "Orcamento de Venda" 						OF oDlg PIXEL Size 150,010 FONT oFont6 COLOR CLR_HBLUE

@ 06,167 BUTTON "&Imprime" 		SIZE 036,012 ACTION oPrn:Print()   	OF oDlg PIXEL
@ 28,167 BUTTON "Pre&view" 		SIZE 036,012 ACTION oPrn:Preview() 	OF oDlg PIXEL
@ 49,167 BUTTON "Sai&r"    		SIZE 036,012 ACTION oDlg:End()     	OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

oPrn:End()


Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ IMPRIMIR  ¦ Autor ¦ J.Marcelino Correa   ¦ Data ¦03.06.2005¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao Pedido de Vendas   					          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pelkote                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
STATIC FUNCTION Imprimir()

Orcamento()

Ms_Flush()

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ORCAMENTO ¦ Autor ¦ J.Marcelino Correa   ¦ Data ¦03.06.2005¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao 										          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Pelkote                                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
STATIC FUNCTION Orcamento()


oPrn:StartPage()


cBitMap := "\logo\cavanna.bmp"
oPrn:SayBitmap(0050,0050,cBitMap,433,250)			// Imprime logo da Empresa: comprimento X altura

oPrn:Box(0180,0550,0415,2300) //box dados cliente


dbSelectArea("SCJ")
dbSetOrder(01)
If dbSeek(xFilial("SCJ")+mv_par01)
	
	dbSelectArea("SA1")
	dbSetOrder(01)
	dbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA)
	
    dbSelectArea("SE4")
	dbSetOrder(01)
	dbSeek(xFilial("SE4")+SCJ->CJ_CONDPAG)
	
	
	oPrn:Box(0030,1770,0130,2300) //box do numero
	oPrn:Say(0030,1070, "Orcamento de Vendas No",oFont14N)
	oPrn:Say(0045,1920,OemToAnsi(SCJ->CJ_NUM),oFont14)
    
	oPrn:Say(0200,0600,"Cliente:",oFont12N)
	oPrn:Say(0200,0800,OemToAnsi(SA1->A1_NOME),oFont12)

	oPrn:Say(0250,0600,"Data   :",oFont12N)
	oPrn:Say(0250,0800,OemToAnsi(DTOC(SCJ->CJ_EMISSAO)),oFont12)

    xContato := Posicione("SU5",1,xFilial("SU5")+SCJ->CJ_CONTATO,"U5_CONTAT")
	oPrn:Say(0300,0600,"Ao Sr(a):",oFont12N)
	oPrn:Say(0300,0800,OemToAnsi(Alltrim(xContato)),oFont12)

	oPrn:Say(0300,1500,"Fone : ",oFont12N)
	oPrn:Say(0300,1700,OemToAnsi(Posicione("SU5",1,xFilial("SU5")+SCJ->CJ_CONTATO,"U5_FONE")),oFont12)
	
	oPrn:Box(0450,0050,0520,2300) //box dos itens

	oPrn:Say(0455,0100,"Codigo"  	            	,oFont12N)
	oPrn:Say(0455,0270,"Descricao"	            	,oFont12N)
	oPrn:Say(0455,1080,"Qtd."        	            ,oFont12N)
	oPrn:Say(0455,1200,"UN"         	            ,oFont12N)
	oPrn:Say(0455,1360,"Prc.Unit."     	            ,oFont12N)
	oPrn:Say(0455,1660,"Prc.Total"     	            ,oFont12N)
	oPrn:Say(0455,1910,"IPI %"       	            ,oFont12N)
	oPrn:Say(0455,2100,"Prazo Ent."	                ,oFont12N)
	
	dbSelectArea("SCK")
	dbSetOrder(01)
	dbSeek(xFilial("SCK")+SCJ->CJ_NUM)
	
	nLin    := 0550
	nTotal  := 0

	While !Eof() .And. SCK->CK_FILIAL+SCK->CK_NUM == SCJ->CJ_FILIAL+SCJ->CJ_NUM


		nPercIPI  := Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_IPI")
		nTotal    += SCK->CK_VALOR
        nDiasEnt  := (SCK->CK_ENTREG-SCJ->CJ_EMISSAO)

		oPrn:Say(nLin,0050,OemToAnsi(SCK->CK_PRODUTO),oFont08)
		oPrn:Say(nLin,0270,OemToAnsi(SCK->CK_DESCRI),oFont08)
		oPrn:Say(nLin,1050,Transform(SCK->CK_QTDVEN,"@E 9,999.99"),oFont08)
		oPrn:Say(nLin,1200,OemToAnsi(SCK->CK_UM),oFont08)
		oPrn:Say(nLin,1350,Transform(SCK->CK_PRCVEN,"@E 9,999,999.99",),oFont08)
		oPrn:Say(nLin,1650,Transform(SCK->CK_VALOR ,"@E 9,999,999.99",),oFont08)
		oPrn:Say(nLin,1900,Transform(nPercIPI ,"@E 99.99",),oFont08)
        If nDiasEnt = 0
		  oPrn:Say(nLin,2100,OemToAnsi("Imediato"),oFont08)
		 Else
		  oPrn:Say(nLin,2100,Transform(nDiasEnt ,"@E 999",)+" Dias",oFont08)
        EndIf

		nLin+=0050

        If mv_par02 = 1
          cDesc    := alltrim(MSMM(posicione("SB1",1,xfilial("SB1")+SCK->CK_PRODUTO,"B1_DESC_P")))
          If !empty(cDesc)
            For nX := 1 to MlCount(AllTrim(cDesc),40)
		       oPrn:Say(nLin,0270,OemToAnsi(MemoLine(AllTrim(cDesc),40,nX)),oFont08)
	           nLin+=0050
		    Next nX
          EndIf
        EndIf
		
	    dbSelectArea("SCK")
		dbSkip()


        If nLin >= 2150
	      oPrn:Box(nLin,0050,nLin+70,2300) //box do total
	      oPrn:Say(nLin+7,0100,"CONTINUA...."        	,oFont12N)

          oPrn:Box(2870,0050,2872,2300)
          oPrn:Say(2900,0700,OemToAnsi("Cavanna Sistemas e Maquinas de Embalagem Ltda"),oFont12)
          oPrn:Say(2950,0670,OemToAnsi("Rua Alberto Correia Francfort, 103/121 Embu SP Brasil"),oFont12)
          oPrn:Say(3000,0770,OemToAnsi("E-mail vendas@cavannagroup.com"),oFont12)
          oPrn:Say(3050,0690,OemToAnsi("Tel.: ++55 11 2198.5700 - Fax: ++55 11 2198.5723") ,oFont12)
          oPrn:Say(3100,0850,OemToAnsi("CNPJ  06.088.544/0001-33")  ,oFont12)

          oPrn:EndPage()
          oPrn:StartPage()

          oPrn:SayBitmap(0050,0050,cBitMap,433,300)			// Imprime logo da Empresa: comprimento X altura
	      oPrn:Box(0030,1770,0130,2300) //box do numero
	      oPrn:Say(0030,1070, "Orcamento de Vendas No",oFont14N)
	      oPrn:Say(0045,1920,OemToAnsi(SCJ->CJ_NUM),oFont14)

	      oPrn:Box(0450,0050,0520,2300) //box dos itens

	      oPrn:Say(0455,0100,"Codigo"  	     ,oFont12N)
	      oPrn:Say(0455,0270,"Descricao"	 ,oFont12N)
	      oPrn:Say(0455,1080,"Qtd."        	 ,oFont12N)
	      oPrn:Say(0455,1200,"UN"         	 ,oFont12N)
	      oPrn:Say(0455,1360,"Prc.Unit."     ,oFont12N)
	      oPrn:Say(0455,1660,"Prc.Total"     ,oFont12N)
	      oPrn:Say(0455,1910,"IPI %"       	 ,oFont12N)
	      oPrn:Say(0455,2100,"Prazo Ent."	 ,oFont12N)
	      nLin    := 0550

       Endif

	EndDo
	
	oPrn:Box(nLin,0050,nLin+70,2300) //box do total
	oPrn:Say(nLin+7,0100,"TOTAL   -   sem ipi"        	,oFont12N)
	oPrn:Say(nLin+7,1650,Transform(nTotal,"@E 9,999,999.99",),oFont12N)

	

End

dbSelectArea("SCJ") 

oPrn:Say(2200,0050,OemToAnsi("Cond. Pagto:"),oFont12N)
oPrn:Say(2200,0400,OemToAnsi(UPPER(AllTrim(SE4->E4_DESCRI))),oFont12)   

oPrn:Say(2300,0050,OemToAnsi("Validade:"),oFont12N)
oPrn:Say(2300,0400,Transform((SCJ->CJ_VALIDA-SCJ->CJ_EMISSAO),"@E 999",)+" Dias",oFont12N)

oPrn:Say(2400,0050,OemToAnsi("Frete:"),oFont12N)
oPrn:Say(2400,0400,Transform(SCJ->CJ_FRETE,"@E 9,999,999.99",),oFont12N)

cLocalEnt := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENT+SCJ->CJ_LOJAENT,"A1_NOME")
oPrn:Say(2450,0050,OemToAnsi("Local Entrega:"),oFont12N)
oPrn:Say(2450,0400,OemToAnsi(UPPER(AllTrim(cLocalEnt))),oFont12)   

cEntrega := Iif(SCJ->CJ_FRETE<>0,"FOB","CIF")
oPrn:Say(2500,0050,OemToAnsi("Tipo Entrega:"),oFont12N)
oPrn:Say(2500,0400,OemToAnsi(UPPER(AllTrim(cEntrega))),oFont12)   


//cDescMoed:= Alltrim(Subs(GetMV("MV_MOEDA"+Alltrim(Str(SCJ->CJ_MOEDA))),1,6))
cDescMoed:= GetMv("MV_MOEDA"+Alltrim(Str(SCJ->CJ_MOEDA))) //Alltrim(&("MV_MOEDA"+Alltrim(Str(SCJ->CJ_MOEDA))))
oPrn:Say(2600,0050,OemToAnsi("Valores em :"),oFont12N)
oPrn:Say(2600,0400,OemToAnsi(UPPER(AllTrim(cDescMoed))),oFont12)   

cObs := SCJ->CJ_OBS
oPrn:Say(2700,0050,OemToAnsi("Observação :"),oFont12N)
oPrn:Say(2700,0400,OemToAnsi(UPPER(AllTrim(cObs))),oFont12)   

cUser := SCJ->CJ_USUARIO
oPrn:Say(2800,0050,OemToAnsi("Responsavel pela Informação"),oFont12N)
oPrn:Say(2800,0650,OemToAnsi(UPPER(cUser)),oFont12) 


oPrn:Box(2870,0050,2872,2300)
oPrn:Say(2900,0700,OemToAnsi("Cavanna Sistemas e Maquinas de Embalagem Ltda"),oFont12)
oPrn:Say(2950,0670,OemToAnsi("Rua Alberto Correia Francfort, 103/121 Embu SP Brasil"),oFont12)
oPrn:Say(3000,0770,OemToAnsi("E-mail vendas@cavannagroup.com"),oFont12)
oPrn:Say(3050,0690,OemToAnsi("Tel.: ++55 11 2198.5700 - Fax: ++55 11 2198.5723") ,oFont12)
oPrn:Say(3100,0850,OemToAnsi("CNPJ  06.088.544/0001-33")  ,oFont12)


oPrn:EndPage()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿±±
±±³Fun‡…o    ³ AjustaSX1    ³Autor ³  J.Marcelino Correa  ³    03.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-´±±
±±³Descri‡…o ³ Ajusta perguntas do SX1                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

Local aArea := GetArea()

PutSx1(cPerg,"01","No Orcamento de Vendas        ?"," "," ","mv_ch1","C",6,0,0,	"G","","   ","","","mv_par01"," "," "," ","",	" "," "," "," "," "," ", " "," "," "," ",	" "," ",{"Informe numero do Orcamento    "},{"Informe o numero do Orcamento          "},{"Informe o Numero do Orcamento       "})
PutSx1(cPerg,"02","Desc. Detalhada               ?"," ","  ","mv_ch2","N",1,0,2     ,"C","","","","","mv_par02","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","")

RestArea(aArea)

Return

