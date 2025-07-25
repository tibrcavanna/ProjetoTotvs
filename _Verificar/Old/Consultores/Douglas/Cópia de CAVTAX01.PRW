#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

#ifdef SPANISH
	#define STR0001 "Calculo del lote economico"
	#define STR0002 "Efectuando calculo del lote economico..."
	#define STR0003 "Seleccionando registros..."
	#define STR0004 "Lote economico"
	#define STR0005 "Actualizacion de consumo del mes"
	#define STR0006 "Calculos"
	#define STR0007 "Por peso"
	#define STR0008 "Por la tendencia"
	#define STR0009 "Incremento:"
	#define STR0010 "Numero de meses:"
	#define STR0011 "Calculo del lote economico"
	#define STR0012 "Calculo del punto de pedido"
	#define STR0013 "Ajusta Lote Economico por la"
	#define STR0014 "nibilidad financiera"
	#define STR0015 "Clasificacion ABC"
	#define STR0016 "Periodo de"
	#define STR0017 "Adquisicion(meses)"
	#define STR0018 "Distribucion"
	#define STR0019 "Porcentaje (%)"
	#define STR0020 "Tipos de material"
	#define STR0021 "Grupos de material"
	#define STR0022 "Estabilidad"
	#define STR0023 "Por estaciones"
	#define STR0024 "Invertir seleccion"
	#define STR0025 "Grabar clasificacion ABC"
	#define STR0026 "Actualizar "
	#define STR0027 "Selecciona Sucursal"
#else
	#ifdef ENGLISH
		#define STR0001 "Economic Lot Calculation "
		#define STR0002 "Calculating the Economic Lot..."
		#define STR0003 "Selecting Records..."
		#define STR0004 "Economic Lot  "
		#define STR0005 "Updating Monthly Consumption"
		#define STR0006 "Calculations"
		#define STR0007 "By Weight"
		#define STR0008 "By Trend "
		#define STR0009 "Increase:"
		#define STR0010 "Number of Months"
		#define STR0011 "Economic Lot Calculation"
		#define STR0012 "Point of Order Calculation"
		#define STR0013 "Adjusts Economic Lot according to"
		#define STR0014 "financial availability"
		#define STR0015 "ABC Classification"
		#define STR0016 "Period"
		#define STR0017 "Purchase(months)"
		#define STR0018 "Distribution"
		#define STR0019 "Percentage (%)"
		#define STR0020 "Types of Material"
		#define STR0021 "Groups of Material"
		#define STR0022 "Stability"
		#define STR0023 "Seasonality"
		#define STR0024 "Invert Selection"
		#define STR0025 "Save ABC Classification"
		#define STR0026 "Update "
		#define STR0027 "Select Branch"
	#else
		#define STR0001 "C�lculo do Lote Econ�mico"
		#define STR0002 "Efetuando C�lculo do Lote Econ�mico..."
		#define STR0003 "Selecionando Registros..."
		#define STR0004 "Lote Econ�mico"
		#define STR0005 "Atualiza��o do Consumo do M�s"
		#define STR0006 "C�lculos"
		#define STR0007 "Por Peso"
		#define STR0008 "Pela Tend�ncia"
		#define STR0009 "Incremento:"
		#define STR0010 "N�mero de Meses:"
		#define STR0011 "C�lculo do Lote Econ�mico"
		#define STR0012 "C�lculo do Ponto de Pedido"
		#define STR0013 "Ajusta Lote Econ�mico pela"
		#define STR0014 "disponibil.financeira"
		#define STR0015 "Classifica��o ABC"
		#define STR0016 "Per�odo de"
		#define STR0017 "Aquisi��o(meses)"
		#define STR0018 "Distribui��o"
		#define STR0019 "Percentual (%)"
		#define STR0020 "Tipos de Material"
		#define STR0021 "Grupos de Material"
		#define STR0022 "Estabilidade"
		#define STR0023 "Sazonalidade"
		#define STR0024 "Inverter Selecao"
		#define STR0025 "Gravar Classificacao ABC"
		#define STR0026 "Atualizar "
		#define STR0027 "Seleciona Filial"
	#endif
#endif



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVTAX01  �Autor  �Microsiga           � Data �  01/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User function CAVTAX01()

SetKey( VK_F12 ,{|| Pergunte("CAVTAX0001",.T.)})

cPerg := "CAVTAX0001"

PutSx1(cPerg,"01","Per.Estoque de  ?","","","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Per.EStoque ate ?","","","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"03","Per.Folha de    ?","","","mv_ch3","D",8,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"04","Per.Folha ate   ?","","","mv_ch4","D",8,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"05","Ano Base        ?","","","mv_ch5","C",4,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"06","Dias totais ano ?","","","mv_ch6","N",3,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"07","Feriados        ?","","","mv_ch7","N",3,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"08","Sabados         ?","","","mv_ch8","N",3,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"09","Domingos        ?","","","mv_ch9","N",3,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"10","Tempo descanso  ?","","","mv_chA","N",3,0,0,"G","","","","","mv_par10","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"11","Fator descanso  ?","","","mv_chB","N",4,2,0,"G","","","","","mv_par11","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"12","Meses efet.trab ?","","","mv_chC","N",3,0,0,"G","","","","","mv_par12","","","","","","","","","","","","","","","","",,,,"")

//Memoria de calculo de calculo
//Ano base 2011
//Dias totais no ano: 365
//Feriados: 10
//S�bados: 53
//Domingos: 53
//Tempo de caf�: 30 minutos. Horas realizadas efetivamente por dia 8h 18 minutos
//Fator de seguran�a: 0,9
//Meses efetivamente trabalhados por colaborador: 11
//Com estas informa��es obtemos: 365-53-53-10=249 dias �teis no ano
//Horas efetivashomem/m�s= 249*498=124002 minutos * 0,9= 111601,80/60/13= 143,08 h/homem/m�s

Private nValor := 0
Private nValor2 := 0
Private nValor3 := 0
Private nValor4 := 0
Private nValor5 := 0

Private cCadastro := OemToAnsi("C�lculo da taxa hor�ria Cavanna")

If !Pergunte(cPerg,.T.)
	Return
Endif

bBlocoZ1    := { |lEnd| CAVTAX1a() }

MsAguarde(bBlocoZ1,"Aguarde","Processando registros tabela SD3->Mov.Internos",.F.)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVTAX01  �Autor  �Microsiga           � Data �  02/15/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inicia processamento para montagem de arrays de selecao para���
���          �calculo da taxa horaria CAVANNA                             ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static function CAVTAX1a()

Local oDlg,oQual,oQual2,oUsado,nCalculo:=1,oChk1,oChk2,oChk3,oChk4,lCalc,lLote,;
lPedido,lDispoF,aTipo:={},aGrupo:={},nIncre:=nMeses:=nDispoF:=0,;
nA1:=nB1:=nC1:=1,nA2:=nB2:=30,nC2:=40,oGet1,oGet2,nOpca:=2,aOpt[10][3],;
oChkQual,oChkQual2,lQual:=.T.,lQual2:=.T.,oChk5,oChk6,lFilial
Local oOk   := LoadBitmap( GetResources(), "LBOK")
Local oNo   := LoadBitmap( GetResources(), "LBNO")
Local cVarQ := cVarQ2 := "  "
Local cCapital
Local i := 0
Local oFont,oFont1
PRIVATE cMarca   := GetMark( )
Private oMark			:=0
Private lInverte 		:= .f.


SetKey( VK_F12 ,{|| Pergunte("CAVTAX0001",.T.)})

//�������������������������������������������������������������Ŀ
//�Monta a Tabela de Tipos                                      �
//���������������������������������������������������������������
/*/
dbSelectArea("SX5")
dbSeek(xFilial("SX5")+"02")
While (X5_FILIAL == xFilial("SX5")) .And. (X5_TABELA == "02")
	cCapital := OemToAnsi(Capital(X5Descri()))
	AADD(aTipo,{.T.,SubStr(X5_chave,1,3)+cCapital})
	dbSkip()
EndDo
/*/

//����������������������������������Ŀ
//�Monta a tela de contas contabeis  �
//������������������������������������
_nSaldo := 0

dbSelectArea("CT1")
dbGotop()
While !Eof() .And. (CT1_FILIAL == xFilial("CT1"))
	
	MsProcTxt( "Verificando contas cont�beis")
	
	If CT1_BLOQ == '1'  .Or. Left(CT1_CONTA,1) <> '3'  .Or. CT1_CLASSE == '1'
		dbSkip()
		Loop
	EndIf
	_nSaldo := 0
	
	_nSaldo := SaldoConta(CT1_CONTA,dDatabase,"01","1",1)
	_nSaldo := IIF(_nSaldo < 0,_nSaldo*-1,_nSaldo)
	
	cCapital := OemToAnsi(Capital(CT1_DESC01))
	AADD(aTipo,{IIF(_nSAldo>0,.T.,.F.),CT1_CONTA,PADR(cCapital,50),_nSaldo})
	
	If _nSaldo > 0
		nValor += _nSaldo
	EndIf
	
	dbSkip()
EndDo

//����������������������������������Ŀ
//�Monta a tela de contas contabeis  �
//������������������������������������
_nSaldo := 0

_cQuery := " SELECT B1_FILIAL,B1_COD,B1_DESC FROM "+RetSqlName("SB1")+" "
_cQuery += " WHERE D_E_L_E_T_ = ' ' AND LEFT(B1_COD,3) = 'MOD' OR B1_TIPO = 'HR' "
_cQuery += " AND B1_MSBLQL <> '1' "
_cQuery += " ORDER BY B1_COD "

If Select("QUESB1") > 0
	dbCloseArea()
EndIf

TCQUERY _cQuery NEW ALIAS "QUESB1"

_aMod  := {}

dbSelectArea("QUESB1")
dbGotop()
While !Eof()
	
	_aAreaSB1 := GetArea()
	
	If LEN(RTRIM(QUESB1->B1_COD)) < 7
		dbSkip()
		Loop
	EndIf
	
	MsProcTxt( "Verificando M�o de obra x centro de custo")
	
	/*/
	If CT1_BLOQ == '1'  .Or. Left(CT1_CONTA,1) <> '3'  .Or. CT1_CLASSE == '1'
		dbSkip()
		Loop
	EndIf
	_nSaldo := 0
	
	_nSaldo := SaldoConta(CT1_CONTA,dDatabase,"01","1",1)
	_nSaldo := IIF(_nSaldo < 0,_nSaldo*-1,_nSaldo)
	
	cCapital := OemToAnsi(Capital(CT1_DESC01))     
	/*/
	_nValor2 := 0; _nValor3 := 0
	
	_nValor2 := CAVMODSD3(QUESB1->B1_COD,mv_par01,mv_par02)
	
	// calcula o valor total 
	_nValor3 := CAVMODPON(QUESB1->B1_COD,mv_par03,mv_par04)
	
	AADD(_aMod,{IIF(_nValor2>0,.T.,.F.),QUESB1->B1_COD,QUESB1->B1_DESC,_nValor2,CAVMODPON(QUESB1->B1_COD,mv_par03,mv_par04),0,0})
	
	If _nValor2 > 0
		nValor2 += _nValor2
	EndIf
	
	If _nValor3 > 0 
		nValor3 += _nValor3
	EndIf
	
	RestArea(_aAreaSB1)
	dbSkip()
EndDo

dbSelectArea("QUESB1")
dbCloseArea()

//��������������������������������������������������������������Ŀ
//�Monta a Tabela de Grupos                                      �
//����������������������������������������������������������������
dbSelectArea("SBM")
dbSeek(xFilial("SBM"))
While !EOF() .And. BM_FILIAL == xFilial("SBM")
	cCapital := OemToAnsi(Capital(BM_DESC))
	AADD(aGrupo,{.f.,SubStr(BM_GRUPO,1,5),cCapital})
	dbSkip()
EndDo

//DEFINE FONT oFont  NAME "Courier New"  SIZE 7,16 BOLD
//DEFINE FONT oFont1 NAME "Courier New"  SIZE 7,16

DEFINE FONT oFont  NAME "Arial" SIZE 0,-11
DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11 BOLD

DEFINE MSDIALOG oDlg TITLE cCadastro From 000,0 To 645,1275 OF oMainWnd PIXEL

//@ 02,15 TO 30,120 LABEL "" OF oDlg  PIXEL
//@ 08,20 CHECKBOX oChk1 VAR lCalc PROMPT OemToAnsi(STR0005) SIZE 90, 10 OF oDlg PIXEL ;oChk1:oFont := oDlg:oFont   										//"Atualiza��o do Consumo do M�s"
//@ 18,20 CHECKBOX oChk6 VAR lFilial PROMPT OemToAnsi(STR0027) SIZE 90, 10 OF oDlg PIXEL ;oChk6:oFont := oDlg:oFont                              //"Seleciona Filial"
//@ 32,15 TO 92,120 LABEL OemToAnsi(STR0006) OF oDlg  PIXEL    //"C�lculos"
//@ 38,20 RADIO oUsado VAR nCalculo 3D SIZE 70,10 PROMPT OemToAnsi(STR0007),OemToAnsi(STR0008) OF oDlg PIXEL      											//"Por Peso"###"Pela Tend�ncia"
//oUsado:bChange := { || IIF(nCalculo=1,(oGet1:Enable(),oGet2:Disable()),(oGet1:Disable(),oGet2:Enable())) }
//@ 62,20 Say OemToAnsi(STR0009) SIZE 40,10 OF oDlg PIXEL    																													//"Incremento:"
//@ 62,67 MSGET oGet1 VAR nIncre When IIF(nCalculo=1,.T.,.F.) Picture "999" SIZE 15,10 OF oDlg PIXEL
//@ 78,20 Say OemToAnsi(STR0010) SIZE 60,10 OF oDlg PIXEL     																												//"N�mero de Meses:"
//@ 78,67 MSGET oGet2 VAR nMeses When IIF(nCalculo=2,.T.,.F.) Picture "999" SIZE 15,10 VALID (nMeses < 13 .And. nMeses > 0) OF oDlg PIXEL
//@ 95,15 TO 154,120 LABEL "" OF oDlg  PIXEL
//@ 103,20 CHECKBOX oChk2 VAR lLote PROMPT OemToAnsi(STR0011) SIZE 80, 10 OF oDlg PIXEL ;oChk2:oFont := oDlg:oFont    										//"C�lculo do Lote Econ�mico"
//@ 113,20 CHECKBOX oChk3 VAR lPedido PROMPT OemToAnsi(STR0012) SIZE 80, 10 OF oDlg PIXEL ;oChk3:oFont := oDlg:oFont   	//"C�lculo do Ponto de Pedido"
//@ 123,20 CHECKBOX oChk4 VAR lDispoF PROMPT OemToAnsi(STR0013) SIZE 90, 10 OF oDlg PIXEL ;oChk4:oFont := oDlg:oFont    									//"Ajusta Lote Econ�mico pela dispo-"
//@ 133,20 Say OemToAnsi(STR0014) SIZE 80,10 OF oDlg PIXEL    																												//"nibilidade financeira"
//@ 135,70 MSGET nDispoF When lDispoF Picture "@E 99,999,999,999" VALID nDispoF > 0 SIZE 45,10 OF oDlg PIXEL
//@ 02,130 TO 73,300 LABEL OemToAnsi(STR0015) OF oDlg PIXEL    																												//"Classifica��o ABC"
//@ 12,182 TO 58,219 LABEL "A" OF oDlg  PIXEL
//@ 12,220 TO 58,257 LABEL "B" OF oDlg  PIXEL
//@ 12,258 TO 58,295 LABEL "C" OF oDlg  PIXEL
//@ 18,135 Say OemToAnsi(STR0016) SIZE 45,10 OF oDlg PIXEL   //"Per�odo de"
//@ 25,135 Say OemToAnsi(STR0017) SIZE 45,10 OF oDlg PIXEL   //"Aquisi��o(meses)"
//@ 38,135 Say OemToAnsi(STR0018) SIZE 45,10 OF oDlg PIXEL   //"Distribui��o"
//@ 45,135 Say OemToAnsi(STR0019) SIZE 45,10 OF oDlg PIXEL   //"Percentual (%)"
//@ 20,185 MSGET nA1 Picture "99.9" VALID nA1 >0 SIZE 17,10 OF oDlg PIXEL
//@ 20,223 MSGET nB1 Picture "99.9" VALID nB1 >0 SIZE 17,10 OF oDlg PIXEL
//@ 20,261 MSGET nC1 Picture "99.9" VALID nC1 >0 SIZE 17,10 OF oDlg PIXEL
//@ 40,185 MSGET nA2 Picture "99.9" VALID nA2 >0 SIZE 17,10 OF oDlg PIXEL
//@ 40,223 MSGET nB2 Picture "99.9" VALID nB2 >0 SIZE 17,10 OF oDlg PIXEL
//@ 40,261 MSGET nC2 Picture "99.9" VALID nC2 >0 SIZE 17,10 OF oDlg PIXEL
//@ 60,135 CHECKBOX oChk5 VAR lGrvABC PROMPT OemToAnsi(STR0025) SIZE 74,10 OF oDlg PIXEL ;oChk5:oFont := oDlg:oFont
//Declare oValor Nil

@3,10 Say "Valor total contas cont�beis:"  SIZE 70,10 OF oDlg PIXEL FONT oFont
@3,90 Say oValor VAR nValor picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor:Refresh()

@3,270 Say "Total horas apontadas :"  SIZE 70,10 OF oDlg PIXEL FONT oFont
@3,410 Say oValor2 VAR nValor2 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor2:Refresh()

@13,270 Say "Total horas efetivas do mensalista :"  SIZE 120,10 OF oDlg PIXEL FONT oFont
@13,410 Say oValor3 VAR nValor3 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor3:Refresh()

@23,270 Say "Total horas extras trabalhadas no per�odo  :"  SIZE 120,10 OF oDlg PIXEL FONT oFont
@23,410 Say oValor4 VAR nValor4 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor4:Refresh()

@33,270 Say "Total horas de aus�ncia  :"  SIZE 120,10 OF oDlg PIXEL FONT oFont
@33,410 Say oValor5 VAR nValor5 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor5:Refresh()


//	Horas efetivas do mensalista: 144
//	Horas extras trabalhadas no per�odo ( como s�o dados que digito n�o importa inserir campos com datas mas o ideal seria que pudesse escolher o per�odo e pegasse os campos das horas extras inseridas no sistema):15
//	Horas de aus�ncia: faltou 1 dia : 8 horas




//	@0.4,15 Say "Quantidade:"   //"Quantidade:"
//	@1.9,28 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8   										//"Grava Classificacao ABC"
If Len(aTipo) > 0
	@ 050,010 LISTBOX oQual VAR cVarQ Fields HEADER OemToAnsi(""),; // "Identificador"
	OemToAnsi("C.Cont�bil"),; // "Codigo"
	OemToAnsi("Descri��o"),; // "Debito"
	OemToAnsi("$ Saldo cont�bil"),; // "Credito"
	OemToAnsi("______");  // "Saldo"
	COLSIZES 50,;
	GetTextWidth(0,"BBBBBBB"),;
	GetTextWidth(0,"BBBBBBBBB"),;
	GetTextWidth(0,"@R 999.999,99"),;
	GetTextWidth(0,"@R 999.999,99"),;
	,OemToAnsi("Contas cont�beis") SIZE 250,150 ON DBLCLICK (aTipo:=xca290tr(oQual:nAt,aTipo,oValor),oQual:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual,oOk,oNo,@aTipo) SCROLL OF oDlg PIXEL  //"Tipos de Material"
	oQual:SetArray(aTipo)
	oQual:bLine := { || { if(aTipo[oQual:nAt,1],oOk,oNo),aTipo[oQual:nAt,2],aTipo[oQual:nAt,3],aTipo[oQual:nAt,4]}}
	//oQual:Align := CONTROL_ALIGN_ALLCLIENT
EndIf

If Len(_aMod) > 0
	@ 050,265 LISTBOX oQual2 VAR cVarQ2 Fields HEADER OemToAnsi(""),; // "Identificador"
	OemToAnsi("Produto"),; // "Codigo"
	OemToAnsi("Descri��o"),; // "Debito"
	OemToAnsi("Hr.Apontadas"),; // "Credito"
	OemToAnsi("Hr.Efet.Mensalista"),; // "Credito"
	OemToAnsi("Hr.Extras"),; // "Credito"
	OemToAnsi("Hr.Ausencia"),; // "Credito"
	COLSIZES 50,;
	GetTextWidth(0,"BBBBBBB"),;
	GetTextWidth(0,"BBBBBBBBB"),;
	GetTextWidth(0,"@R 9.999,99"),;
	GetTextWidth(0,"@R 9.999,99"),;
	GetTextWidth(0,"@R 9.999,99"),;
	GetTextWidth(0,"@R 9.999,99"),;
	,OemToAnsi("M�o de obra") SIZE 350,150 ON DBLCLICK (_aMod:=xca290mo(oQual2:nAt,_aMod,oValor2,oValor3,oValor4,oValor5),oQual2:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual2,oOk,oNo,@_aMod) OF oDlg PIXEL  //"Tipos de Material"
	oQual2:SetArray(_aMod)
	//	oQual2:bLine := { || {if(aTipo[oQual2:nAt,1],oOk,oNo),aTipo[oQual2:nAt,2]}}
	//oQual2:bLine := { || { if(_aMod[oQual2:nAt,1],oOk,oNo),_aMod[oQual2:nAt,2],_aMod[oQual2:nAt,3],_aMod[oQual2:nAt,4]}}
	oQual2:bLine := { || { if(_aMod[oQual2:nAt,1],oOk,oNo),_aMod[oQual2:nAt,2],_aMod[oQual2:nAt,3],_aMod[oQual2:nAt,4],_aMod[oQual2:nAt,5],_aMod[oQual2:nAt,6],_aMod[oQual2:nAt,7]}}
	//oQual2:bMark := {|| CAVTAXa(oValor)}
	//oQual2:Align := CONTROL_ALIGN_ALLCLIENT
EndIf

//If Len(aGrupo) > 0
//	@ 76,225 LISTBOX oQual2 VAR cVarQ2 Fields HEADER "",OemToAnsi(STR0021) SIZE 75,50 ON DBLCLICK (aGrupo:=xca290tr(oQual2:nAt,aGrupo),oQual2:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual2,oOk,oNo,@aGrupo) NOSCROLL OF oDlg  PIXEL   //"Grupos de Material"
//	oQual2:SetArray(aGrupo)
//	oQual2:bLine := { || {if(aGrupo[oQual2:nAt,1],oOk,oNo),aGrupo[oQual2:nAt,2]}}
//	@ 127,225 CHECKBOX oChkQual2 VAR lQual2 PROMPT OemToAnsi(STR0024) SIZE 50, 10 OF oDlg PIXEL ON CLICK (AEval(aGrupo, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}),oQual2:Refresh(.F.)) //"Inverter Selecao"
//EndIf

DEFINE SBUTTON FROM 180,640 TYPE 1 ACTION IIF(A290VldPer(nA2,nB2,nC2),(nOpca:=1,oDlg:End()),Help(" ",1,"A290PERC")) ENABLE OF oDlg
DEFINE SBUTTON FROM 180,670 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

//����������������������������������������������������������Ŀ
//� Ponto de Entrada MTA290FIL - p/ adicionar filtro no SB1  |
//� (permite a criacao de um botao para customizacao)		 �
//������������������������������������������������������������
//If ( lMta290Fil )
//	DEFINE SBUTTON FROM 140,210 TYPE 5 ACTION ( cMTA290Fil:=ExecBlock("MTA290FIL",.F.,.F.) ) ENABLE OF oDlg
//EndIf

//oChk2:BlClicked :=	{|| oChk2:Refresh()}
ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = 1
	//���������������������������������������������Ŀ
	//� Grava Atualizacao do Consumo do Mes no array�
	//�����������������������������������������������
	If lCalc
		aOpt[1,1]:= "x"
	Else
		aOpt[1,1]:=" "
	EndIf
	
	//�������������������������������������������������������������Ŀ
	//� Grava Tipo de Calculo e valor p/ formula de calculo no array�
	//���������������������������������������������������������������
	If nCalculo=1
		aOpt[2,1]:="x"
		aOpt[2,2]:=nIncre
		aOpt[3,1]:=" "
		aOpt[3,2]:=0
	Else
		aOpt[2,1]:=" "
		aOpt[2,2]:=0
		aOpt[3,1]:="x"
		aOpt[3,2]:=nMeses
	EndIf
	
	//�����������������������������������������Ŀ
	//� Grava Calculo do Lote Economico no array�
	//�������������������������������������������
	If lLote
		aOpt[4,1]:="x"
		If lPedido
			aOpt[4,2]:="x"
		EndIf
	Else
		If lPedido
			aOpt[4,2]:="x"
		Else
			aOpt[4,2]:=" "
		EndIf
		aOpt[4,1]:=" "
	EndIf
	
	//������������������������������������������Ŀ
	//� Grava disponibilidade financeira no array�
	//��������������������������������������������
	If lDispoF
		aOpt[5,1]:="x"
		aOpt[5,2]:=nDispoF
	Else
		aOpt[5,1]:=" "
		aOpt[5,2]:=0
	EndIf
	
	//�������������������������������������Ŀ
	//� Grava Periodos de Aquisicao no array�
	//���������������������������������������
	aOpt[6,1]:=nA1
	aOpt[6,2]:=nB1
	aOpt[6,3]:=nC1
	//���������������������������������Ŀ
	//� Grava percentuais no array      �
	//�����������������������������������
	aOpt[7,1]:=nA2
	aOpt[7,2]:=nB2
	aOpt[7,3]:=nC2
	
	//���������������������������������Ŀ
	//� Move aTipo p/aOpt               �
	//�����������������������������������
	aOpt[8][1]:=""
	nArr:=0
	For i:=1 To Len(aTipo)
		If aTipo[i][1]
			nArr++
			aOpt[8][1] := aOpt[8][1]+SubStr(aTipo[i,2],1,2)+"|"
		EndIf
	Next i
	If nArr == Len(aTipo)
		aOpt[8][1]:="**"
	EndIf
	
	//���������������������������������Ŀ
	//� Move aGrupo p/aOpt              �
	//�����������������������������������
	aOpt[9][1]:=""
	nArr:=0
	For i:=1 To Len(aGrupo)
		If aGrupo[i][1]
			nArr++
			aOpt[9][1] := aOpt[9][1]+SubStr(aGrupo[i,2],1,4)+"|"
		EndIf
	Next i
	If nArr == Len(aGrupo) .And. !Empty(aOpt[9][1])
		aOpt[9][1]:="**"
	ElseIf !Empty(aOpt[9][1])
		aOpt[9][1] := aOpt[9][1]+Space(Len(SB1->B1_GRUPO))+"|"
	EndIf
	
	//����������������������������������������������Ŀ
	//� Ativa ou nao, selecao de Filiais no Array    �
	//� Se nao ativar, processa somente filial atual �
	//������������������������������������������������
	aOpt[10,1] := lFilial
Else
	aOpt:=NIL
EndIf

DeleteObject(oOk)
DeleteObject(oNo)

//��������������������������������������������������������������Ŀ
//� Desativa a tecla F12							             �
//����������������������������������������������������������������
SetKey( VK_F12, Nil )

Return aOpt

//Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � xca290tr                                                   ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Troca marcador entre x e branco                            ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaEST - Advanced                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function xca290tr(nIt,aArray,ovalor)

aArray[nIt,1] := !aArray[nIt,1]

If !aArray[nIt,1]
	nValor -= aArray[nIt,4]
Else
	nValor += aArray[nIt,4]
EndIf

oValor:Refresh()

Return(aArray)


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    � xca290tr                                                   ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Troca marcador entre x e branco                            ���
��������������������������������������������������������������������������Ĵ��
���  Uso      � SigaEST - Advanced                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function xca290mo(nIt,aArray,ovalor2,ovalor3,ovalor4,ovalor5)

aArray[nIt,1] := !aArray[nIt,1]

If !aArray[nIt,1]
	nValor2 -= aArray[nIt,4]      
	nValor3 -= aArray[nIt,5]      
	nValor4 -= aArray[nIt,6]      
	nValor5 -= aArray[nIt,7]      
Else
	nValor2 += aArray[nIt,4]
	nValor3 += aArray[nIt,5]      
	nValor4 += aArray[nIt,6]      
	nValor5 += aArray[nIt,7]      
EndIf

oValor2:Refresh()
oValor3:Refresh()
oValor4:Refresh()
oValor5:Refresh()

Return(aArray)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVMODSD3 �Autor  �Microsiga           � Data �  02/15/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta array de MAO DE OBRA ( MODS )                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CAVMODSD3(_cProd,_dDataIni,_dDataFim)

_nQuant := 0

_cQuery := " SELECT D3_FILIAL,D3_COD,SUM(D3_QUANT) AS D3_QUANT FROM "+RetSqlName("SD3")+" (NOLOCK) "
_cQuery += " WHERE D3_FILIAL = '"+xFilial("SD3")+"' AND D3_COD = '"+_cProd+"' "
_cQuery += " AND D3_EMISSAO BETWEEN '"+Dtos(_dDataIni)+"' AND '"+Dtos(_dDataFim)+"' "
_cQuery += " AND D_E_L_E_T_ = ' ' "
_cQuery += " GROUP BY D3_FILIAL,D3_COD "

If Select("QUESD3") > 0
	dbCloseArea()
EndIf

TCQUERY _cQuery NEW ALIAS "QUESD3"

_nQuant := QUESD3->D3_QUANT

dbSelectArea("QUESD3")
dbCloseArea()

Return(_nQuant)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVMODPON �Autor  �Microsiga           � Data �  02/15/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Monta array de MAO DE OBRA ( MODS ) COM HORAS PONTO ELETRO  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CAVMODPON(_cProd,_dDataIni,_dDataFim)

_nQuant := 0

_cQuery := " SELECT PC_FILIAL,PC_CC,SUM(PC_QUANTC) AS PC_QUANTC FROM "+RetSqlName("SPC")+" SPC "
_cQuery += " INNER JOIN "+RetSqlName("SRA")+" SRA ON (SRA.D_E_L_E_T_ = ' ' AND RA_MAT = PC_MAT)  "
_cQuery += " INNER JOIN "+RetSqlName("SP9")+" SP9 ON (SP9.D_E_L_E_T_ = ' ' AND P9_CODIGO = PC_PD) "
_cQuery += " WHERE PC_FILIAL = '"+xFilial("SPC")+"' AND LEFT(RTRIM(PC_MAT),4) = '"+LEFT(RTRIM(Subs(_cProd,4,Len(_cProd))),4)+"' "
_cQuery += " AND PC_DATA BETWEEN '"+Dtos(_dDataIni)+"' AND '"+Dtos(_dDataFim)+"' "
_cQuery += " AND SPC.D_E_L_E_T_ = ' '  "
_cQuery += " AND RA_SITFOLH <> 'D' "
_cQuery += " AND PC_PD = '001' "   // Horas normais tabela SP9
_cQuery += " GROUP BY PC_FILIAL,PC_CC  "

If Select("QUESPC") > 0
	dbCloseArea()
EndIf

TCQUERY _cQuery NEW ALIAS "QUESPC"

_nQuant := QUESPC->PC_QUANTC

dbSelectArea("QUESPC")
dbCloseArea()

Return(_nQuant)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVCALCX  �Autor  �Microsiga           � Data �  02/15/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa o calc. CAVANNA de   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CAVCALCX(_cProd,_dDataIni,_dDataFim)


Return(_nQuant)
