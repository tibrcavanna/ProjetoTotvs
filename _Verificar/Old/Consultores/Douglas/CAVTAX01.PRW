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
		#define STR0001 "Cแlculo do Lote Econ๔mico"
		#define STR0002 "Efetuando Cแlculo do Lote Econ๔mico..."
		#define STR0003 "Selecionando Registros..."
		#define STR0004 "Lote Econ๔mico"
		#define STR0005 "Atualiza็ไo do Consumo do M๊s"
		#define STR0006 "Cแlculos"
		#define STR0007 "Por Peso"
		#define STR0008 "Pela Tend๊ncia"
		#define STR0009 "Incremento:"
		#define STR0010 "N๚mero de Meses:"
		#define STR0011 "Cแlculo do Lote Econ๔mico"
		#define STR0012 "Cแlculo do Ponto de Pedido"
		#define STR0013 "Ajusta Lote Econ๔mico pela"
		#define STR0014 "disponibil.financeira"
		#define STR0015 "Classifica็ไo ABC"
		#define STR0016 "Perํodo de"
		#define STR0017 "Aquisi็ไo(meses)"
		#define STR0018 "Distribui็ไo"
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVTAX01  บAutor  ณMicrosiga           บ Data ณ  01/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
//Sแbados: 53
//Domingos: 53
//Tempo de caf้: 30 minutos. Horas realizadas efetivamente por dia 8h 18 minutos
//Fator de seguran็a: 1,0
//Meses efetivamente trabalhados por colaborador: 12
//Com estas informa็๕es obtemos: 365-53-53-10=249 dias ๚teis no ano
//Horas efetivashomem/m๊s= 249*498=124002 minutos * 1 = 124002/60/12 = 143,08 h/homem/m๊s

Private nValor   := 0
Private nValor2  := 0
Private nValor3  := 0
Private nValor4  := 0
Private nValor5  := 0
Private nHorasEfetivas := 0
Private nValorAjuste := 0
Private nVlrAjTmp := 0

Private cCadastro := OemToAnsi("Cแlculo da taxa horแria Cavanna")

If !Pergunte(cPerg,.T.)
	Return
Endif

bBlocoZ1    := { |lEnd| CAVTAX1a() }

MsAguarde(bBlocoZ1,"Aguarde","Processando registros tabela SD3->Mov.Internos",.F.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVTAX01  บAutor  ณMicrosiga           บ Data ณ  02/15/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia processamento para montagem de arrays de selecao paraบฑฑ
ฑฑบ          ณcalculo da taxa horaria CAVANNA                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
Local oPnlMod
Local oPnlCtb
PRIVATE cMarca   := GetMark( )
Private oMark			:=0
Private lInverte 		:= .f.
Private oFont16
Private nHorasEfetivas := 0


SetKey( VK_F12 ,{|| Pergunte("CAVTAX0001",.T.)})

//	((dias trabalhados no total menos os descontos - 30#dias nao trabalhados)	 * (horas uteis trabalhadas por dia - horas de descan็o )
nHorasEfetivas  := ((mv_par06 - mv_par07 - mv_par08 - mv_par09 - 30) * (528 - mv_par10))

//  		Conversใo para minutos | meses efetivamentos trabalhados e meses pagos
nHorasEfetivas  := ((nHorasEfetivas) / 60)

// 			( Horas efetiva / meses ) * fator de seguran็a
nHorasEfetivas := round(((nHorasEfetivas / mv_par12) * mv_par11), 2)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Tabela de Tipos                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*/
dbSelectArea("SX5")
dbSeek(xFilial("SX5")+"02")
While (X5_FILIAL == xFilial("SX5")) .And. (X5_TABELA == "02")
	cCapital := OemToAnsi(Capital(X5Descri()))
	AADD(aTipo,{.T.,SubStr(X5_chave,1,3)+cCapital})
	dbSkip()
EndDo
/*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a tela de contas contabeis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
_nSaldo := 0

dbSelectArea("CT1")
CT1->(dbGotop())

While CT1->(!Eof()) .And. CT1->CT1_FILIAL == xFilial("CT1")
	
	MsProcTxt( "Verificando contas contแbeis")
	
	If CT1->CT1_BLOQ == '1' .Or. CT1->CT1_CLASSE == '1' .OR. CT1->CT1_XTXLST = .F.
		CT1->( dbSkip() )
		Loop
	EndIf
	_nSaldo := 0
	
	// MOVCONTA("41101","01/01/04","31/12/04","01", "1",3)
	//Retorna o movimento realizado (Tipo de Saldo = 1) na conta contแbil "41101", no perํodo de "01/01/04" a "31/12/04", moeda "01".	

	_nSaldo := MovConta(CT1->CT1_CONTA,mv_par01,mv_par02,"01", "1",3)
	//	_nSaldo := SaldoConta(CT1->CT1_CONTA,mv_par02,"01","1",1)
	_nSaldo := IIF(_nSaldo < 0,_nSaldo*-1,_nSaldo)

	cCapital := OemToAnsi(Capital(CT1->CT1_DESC01))
	AADD(aTipo, {CT1->CT1_XTXOP, CT1->CT1_CONTA, PADR(cCapital,50), _nSaldo})
	
	If _nSaldo > 0 .And. CT1->CT1_XTXOP = .T.
		nValor += _nSaldo
	EndIf
	
	CT1->( dbSkip() )
End

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a tela de contas contabeis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
_nSaldo := 0

_cQuery := " SELECT RA_MAT, RA_CC, RA_HRSMES, RA_NOME, RA_XTAXAOP, RA_REGRA,RA_XATTXEF,RA_CATFUNC  FROM "+RetSqlName("SRA")+" SRA "
_cQuery += " WHERE SRA.D_E_L_E_T_ <> '*' AND SRA.RA_DEMISSA = ' ' "
//_cQuery += " AND RA_DEMISSA <> '' "
_cQuery += " ORDER BY RA_NOME "

If Select("QUESRA") > 0
	dbCloseArea()
EndIf

TCQUERY _cQuery NEW ALIAS "QUESRA"

_aMod  := {}

dbSelectArea("QUESRA")

QUESRA->(dbGotop())

While QUESRA->(!Eof())
	
	_aAreaSRA := GetArea()
	
	// buscando o funcionario
	MsProcTxt( "Verificando Mใo de obra x centro de custo")
	
	// re valoriza็ใo do indicadores
	_nValor2 := 0; _nValor3 := 0; _nValor4 := 0; _nValor5 := 0
	
	// horas apontadas
	_nValor2 := QUESRA->RA_HRSMES
	
	// horas efetivas (ponto eletronico)
	_nValor3 := CavPonto(QUESRA->RA_MAT, mv_par03, mv_par04)
	
	// horas extras
	_nValor4 := CavExtra(QUESRA->RA_MAT, mv_par03, mv_par04)
	
	// horas ausencias
	_nValor5 := CavAusen(QUESRA->RA_MAT, mv_par03, mv_par04)

	// funcionarios que nao batem ponto, eh utilizado a regra padrao de calc. com base na formula acima.
	If QUESRA->RA_REGRA = '02' .OR. (QUESRA->RA_XATTXEF = 'T' .and. QUESRA->RA_CATFUNC = 'A')
	
		_nValor3 := nHorasEfetivas
		
	EndIf	
	
	// lista de funcionario com seus respectivos pontos
	AADD(_aMod, {IIF(QUESRA->RA_XTAXAOP == 'T', .T., .F.),QUESRA->RA_MAT,QUESRA->RA_NOME,_nValor2,_nValor3,_nValor4,_nValor5})
	
	If _nValor2 > 0
		nValor2 += _nValor2
	EndIf
	
	If _nValor3 > 0 .and. QUESRA->RA_XTAXAOP = 'T'
		nValor3 += _nValor3
	EndIf
	
	If _nValor4 > 0 .and. QUESRA->RA_XTAXAOP = 'T'
		nValor4 += _nValor4
	EndIf
	
	If _nValor5 > 0 .and. QUESRA->RA_XTAXAOP = 'T'
		nValor5 += _nValor5
	EndIf
	
	RestArea(_aAreaSRA)
	QUESRA->( dbSkip() )
EndDo

QUESRA->(dbCloseArea())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Tabela de Grupos                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("SBM")
dbSeek(xFilial("SBM"))
While SBM->( !EOF()) .And. SBM->BM_FILIAL == xFilial("SBM") 
	cCapital := OemToAnsi(Capital(SBM->BM_DESC))
	AADD(aGrupo,{.f.,SubStr(SBM->BM_GRUPO,1,5),cCapital})
	SBM->( dbSkip() )
EndDo

//DEFINE FONT oFont  NAME "Courier New"  SIZE 7,16 BOLD
//DEFINE FONT oFont1 NAME "Courier New"  SIZE 7,16

DEFINE FONT oFont  NAME "Arial" SIZE 0,-11
DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont16 NAME "Arial" SIZE 14, -16 BOLD


DEFINE MSDIALOG oDlg TITLE cCadastro From 000,0 To 450,1160 OF oMainWnd PIXEL

//@ 02,15 TO 30,120 LABEL "" OF oDlg  PIXEL
//@ 08,20 CHECKBOX oChk1 VAR lCalc PROMPT OemToAnsi(STR0005) SIZE 90, 10 OF oDlg PIXEL ;oChk1:oFont := oDlg:oFont   										//"Atualizao do Consumo do Ms"
//@ 18,20 CHECKBOX oChk6 VAR lFilial PROMPT OemToAnsi(STR0027) SIZE 90, 10 OF oDlg PIXEL ;oChk6:oFont := oDlg:oFont                              //"Seleciona Filial"
//@ 32,15 TO 92,120 LABEL OemToAnsi(STR0006) OF oDlg  PIXEL    //"C lculos"
//@ 38,20 RADIO oUsado VAR nCalculo 3D SIZE 70,10 PROMPT OemToAnsi(STR0007),OemToAnsi(STR0008) OF oDlg PIXEL      											//"Por Peso"###"Pela Tendncia"
//oUsado:bChange := { || IIF(nCalculo=1,(oGet1:Enable(),oGet2:Disable()),(oGet1:Disable(),oGet2:Enable())) }
//@ 62,20 Say OemToAnsi(STR0009) SIZE 40,10 OF oDlg PIXEL    																													//"Incremento:"
//@ 62,67 MSGET oGet1 VAR nIncre When IIF(nCalculo=1,.T.,.F.) Picture "999" SIZE 15,10 OF oDlg PIXEL
//@ 78,20 Say OemToAnsi(STR0010) SIZE 60,10 OF oDlg PIXEL     																												//"Nฃmero de Meses:"
//@ 78,67 MSGET oGet2 VAR nMeses When IIF(nCalculo=2,.T.,.F.) Picture "999" SIZE 15,10 VALID (nMeses < 13 .And. nMeses > 0) OF oDlg PIXEL
//@ 95,15 TO 154,120 LABEL "" OF oDlg  PIXEL
//@ 103,20 CHECKBOX oChk2 VAR lLote PROMPT OemToAnsi(STR0011) SIZE 80, 10 OF oDlg PIXEL ;oChk2:oFont := oDlg:oFont    										//"C lculo do Lote Econ“mico"
//@ 113,20 CHECKBOX oChk3 VAR lPedido PROMPT OemToAnsi(STR0012) SIZE 80, 10 OF oDlg PIXEL ;oChk3:oFont := oDlg:oFont   	//"C lculo do Ponto de Pedido"
//@ 123,20 CHECKBOX oChk4 VAR lDispoF PROMPT OemToAnsi(STR0013) SIZE 90, 10 OF oDlg PIXEL ;oChk4:oFont := oDlg:oFont    									//"Ajusta Lote Econ“mico pela dispo-"
//@ 133,20 Say OemToAnsi(STR0014) SIZE 80,10 OF oDlg PIXEL    																												//"nibilidade financeira"
//@ 135,70 MSGET nDispoF When lDispoF Picture "@E 99,999,999,999" VALID nDispoF > 0 SIZE 45,10 OF oDlg PIXEL
//@ 02,130 TO 73,300 LABEL OemToAnsi(STR0015) OF oDlg PIXEL    																												//"Classificao ABC"
//@ 12,182 TO 58,219 LABEL "A" OF oDlg  PIXEL
//@ 12,220 TO 58,257 LABEL "B" OF oDlg  PIXEL
//@ 12,258 TO 58,295 LABEL "C" OF oDlg  PIXEL
//@ 18,135 Say OemToAnsi(STR0016) SIZE 45,10 OF oDlg PIXEL   //"Perกodo de"
//@ 25,135 Say OemToAnsi(STR0017) SIZE 45,10 OF oDlg PIXEL   //"Aquisio(meses)"
//@ 38,135 Say OemToAnsi(STR0018) SIZE 45,10 OF oDlg PIXEL   //"Distribuio"
//@ 45,135 Say OemToAnsi(STR0019) SIZE 45,10 OF oDlg PIXEL   //"Percentual (%)"
//@ 20,185 MSGET nA1 Picture "99.9" VALID nA1 >0 SIZE 17,10 OF oDlg PIXEL
//@ 20,223 MSGET nB1 Picture "99.9" VALID nB1 >0 SIZE 17,10 OF oDlg PIXEL
//@ 20,261 MSGET nC1 Picture "99.9" VALID nC1 >0 SIZE 17,10 OF oDlg PIXEL
//@ 40,185 MSGET nA2 Picture "99.9" VALID nA2 >0 SIZE 17,10 OF oDlg PIXEL
//@ 40,223 MSGET nB2 Picture "99.9" VALID nB2 >0 SIZE 17,10 OF oDlg PIXEL
//@ 40,261 MSGET nC2 Picture "99.9" VALID nC2 >0 SIZE 17,10 OF oDlg PIXEL
//@ 60,135 CHECKBOX oChk5 VAR lGrvABC PROMPT OemToAnsi(STR0025) SIZE 74,10 OF oDlg PIXEL ;oChk5:oFont := oDlg:oFont
//Declare oValor Nil

// ------------------------------------------------------------------------------------------

@3,10 Say "Valor total contas contแbeis:"  SIZE 70,10 OF oDlg PIXEL FONT oFont
@3,90 Say oValor VAR nValor picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor:Refresh()

// ------------------------------------------------------------------------------------------

@3,270 Say "Total horas apontadas :"  SIZE 70,10 OF oDlg PIXEL FONT oFont
@3,410 Say oValor2 VAR nValor2 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor2:Refresh()

@13,270 Say "Total horas efetivas do mensalista :"  SIZE 120,10 OF oDlg PIXEL FONT oFont
@13,410 Say oValor3 VAR nValor3 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor3:Refresh()

@23,270 Say "Total horas extras trabalhadas no perํodo  :"  SIZE 120,10 OF oDlg PIXEL FONT oFont
@23,410 Say oValor4 VAR nValor4 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor4:Refresh()

@33,270 Say "Total horas de aus๊ncia  :"  SIZE 120,10 OF oDlg PIXEL FONT oFont
@33,410 Say oValor5 VAR nValor5 picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1
oValor5:Refresh()


@210,50 Say "Taxa Efetiva OP:"  SIZE 130,10 OF oDlg PIXEL FONT oFont16
@210,145 Say oValorEfet VAR (nValor / ( (nValor3+nValor4+nValor5)  )) picture "@E 99,999,999.99" SIZE 90,10 OF oDlg PIXEL FONT oFont16
//@210,135 MSGET nValor Picture "@E 99,999,999.99" VALID nValor >0 SIZE 120, 10 OF oDlg PIXEL FONT oFont16
oValorEfet:Refresh()

// ---------------------------------------------------------------------

@13,10 Say "Valor de ajuste:"  SIZE 70,10 OF oDlg PIXEL FONT oFont
@13,90 MsGet oValorAjuste VAR nValorAjuste Valid AjustVal(nValorAjuste, oValor) picture "@E 99,999,999.99" SIZE 70,10 OF oDlg PIXEL FONT oFont1

//	Horas efetivas do mensalista: 144
//	Horas extras trabalhadas no perํodo ( como sใo dados que digito nใo importa inserir campos com datas mas o ideal seria que pudesse escolher o perํodo e pegasse os campos das horas extras inseridas no sistema):15
//	Horas de aus๊ncia: faltou 1 dia : 8 horas




//	@0.4,15 Say "Quantidade:"   //"Quantidade:"
//	@1.9,28 Say oQtda VAR nQtdTit Picture "@E 99999" SIZE 50,8   										//"Grava Classificacao ABC"

If Len(aTipo) > 0
	oPnlCtb := tPanel():New(042,10,"Plano de Contas",oDlg,,,,,,255,160)
	@ 050,012 LISTBOX oQual VAR cVarQ Fields HEADER OemToAnsi(""),; // "Identificador"
	OemToAnsi("C.Contแbil"),; // "Codigo"
	OemToAnsi("Descri็ใo"),; // "Debito"
	OemToAnsi("$ Saldo contแbil"),; // "Credito"
	OemToAnsi("______");  // "Saldo"
	COLSIZES 50,;
	GetTextWidth(0,"BBBBBBB"),;
	GetTextWidth(0,"BBBBBBBBB"),;
	GetTextWidth(0,"@R 999.999,99"),;
	GetTextWidth(0,"@R 999.999,99"),;
	,OemToAnsi("Contas contแbeis") SIZE 250,145 ON DBLCLICK (aTipo:=xca290tr(oQual:nAt, aTipo, oValor, oValorEfet),oQual:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual,oOk,oNo,@aTipo) SCROLL OF oDlg PIXEL  //"Tipos de Material"
	oQual:SetArray(aTipo)
	oQual:bLine := { || { if(aTipo[oQual:nAt,1],oOk,oNo),aTipo[oQual:nAt,2],aTipo[oQual:nAt,3],aTipo[oQual:nAt,4]}}
	//oQual:Align := CONTROL_ALIGN_ALLCLIENT
EndIf

If Len(_aMod) > 0
	oPnlMod := tPanel():New(042,270,"Mใo de Obra",oDlg,,,,,,365,160)
	@ 050,275 LISTBOX oQual2 VAR cVarQ2 Fields HEADER OemToAnsi(""),; // "Identificador"
	OemToAnsi("Matricula"),; // "Codigo"
	OemToAnsi("Descri็ใo"),; // "Debito"
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
	,OemToAnsi("Mใo de obra") SIZE 300,145 ON DBLCLICK (_aMod:=xca290mo(oQual2:nAt,_aMod,oValor2,oValor3,oValor4,oValor5, oValorEfet),oQual2:Refresh()) ON RIGHT CLICK ListBoxAll(nRow,nCol,@oQual2,oOk,oNo,@_aMod) OF oDlg PIXEL  //"Tipos de Material"
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

//DEFINE SBUTTON FROM 180,640 TYPE 1 ACTION IIF(A290VldPer(nA2,nB2,nC2),(nOpca:=1,oDlg:End()),Help(" ",1,"A290PERC")) ENABLE OF oDlg
// DEFINE SBUTTON FROM 210,340 TYPE 1 ACTION alert("Aguarde...") ENABLE OF oDlg
//(aCabExcel, aItensExcel)
// MSGYesNo("Deseja efetivar a taxa ?")

//	aCabExcel := aClone(aTipo)
 //	aItensExcel := aClone(_aMod)
	
@  210, 330  BUTTON "Efetivar Taxa OP" SIZE 50, 11 ACTION EfetTxOp((nValor/((nValor3+nValor4+nValor5) )), oDlg) OF oDlg PIXEL
@  210, 490  BUTTON "Exportar P/ Excel" SIZE 50, 11 ACTION ExportExcel(aclone(oQual:aarray), aclone(oQual2:aarray)) OF oDlg PIXEL
DEFINE SBUTTON FROM 210,400 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Ponto de Entrada MTA290FIL - p/ adicionar filtro no SB1  |
//ณ (permite a criacao de um botao para customizacao)		 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//If ( lMta290Fil )
//	DEFINE SBUTTON FROM 140,210 TYPE 5 ACTION ( cMTA290Fil:=ExecBlock("MTA290FIL",.F.,.F.) ) ENABLE OF oDlg
//EndIf

//oChk2:BlClicked :=	{|| oChk2:Refresh()}
ACTIVATE MSDIALOG oDlg CENTERED

If nOpca = 1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava Atualizacao do Consumo do Mes no arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lCalc
		aOpt[1,1]:= "x"
	Else
		aOpt[1,1]:=" "
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava Tipo de Calculo e valor p/ formula de calculo no arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava Calculo do Lote Economico no arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava disponibilidade financeira no arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lDispoF
		aOpt[5,1]:="x"
		aOpt[5,2]:=nDispoF
	Else
		aOpt[5,1]:=" "
		aOpt[5,2]:=0
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava Periodos de Aquisicao no arrayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aOpt[6,1]:=nA1
	aOpt[6,2]:=nB1
	aOpt[6,3]:=nC1
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Grava percentuais no array      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aOpt[7,1]:=nA2
	aOpt[7,2]:=nB2
	aOpt[7,3]:=nC2
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Move aTipo p/aOpt               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Move aGrupo p/aOpt              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Ativa ou nao, selecao de Filiais no Array    ณ
	//ณ Se nao ativar, processa somente filial atual ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aOpt[10,1] := lFilial
Else
	aOpt:=NIL
EndIf

DeleteObject(oOk)
DeleteObject(oNo)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Desativa a tecla F12							             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetKey( VK_F12, Nil )

Return aOpt

//Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funo    ณ xca290tr                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descrio ณ Troca marcador entre x e branco                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ  Uso      ณ SigaEST - Advanced                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xca290tr(nIt,aArray,ovalor,oValorEfet)

aArray[nIt,1] := !aArray[nIt,1]

If !aArray[nIt,1]
	nValor -= aArray[nIt,4]
Else
	nValor += aArray[nIt,4]
EndIf

oValor:Refresh()
oValorEfet:Refresh()

Return(aArray)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Funo    ณ xca290mo                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descrio ณ Troca marcador entre x e branco                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ  Uso      ณ SigaEST - Advanced                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xca290mo(nIt,aArray,ovalor2,ovalor3,ovalor4,ovalor5,oValorEfet)

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
oValorEfet:Refresh()

Return(aArray)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVMODSD3 บAutor  ณMicrosiga           บ Data ณ  02/15/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta array de MAO DE OBRA ( MODS )                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | CavPonto บAutor  ณMicrosiga           บ Data ณ  02/15/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a quantidade de horas do Ponto por funcionario  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CavPonto(_cMat,_dDataIni,_dDataFim)

_nQuant			:= 0
_cMvMotAbono 	:= GETMV('CV_MOTABON') // '001', '005', '007', '013', '014', '012', '011', '010', '021' - padrใo
_aMvTmp 		:= strtokarr(_cMvMotAbono,",")
_cParMotAbono 	:= ""

// varrendo os elementos temporแrios
For Nx := 1 To Len(_aMvTmp)
	_cParMotAbono	 += "'" + _aMvTmp[nX] + "',"
Next Nx 

// elimando a ๚ltima virgula
_cParMotAbono := Substr(_cParMotAbono, 1, Len(_cParMotAbono)-1)

// retorna o ponto acumulado
_cQuerySPH := " SELECT SUM(PH_QUANTC) AS QUANTC FROM " + RetSqlName("SPH") + " SPH "
_cQuerySPH += " WHERE PH_FILIAL = '" + xFilial("SPH") + "' AND PH_MAT = '" + _cMat + "' "
_cQuerySPH += " AND PH_DATA BETWEEN '" + Dtos(_dDataIni) + "' AND  '" + Dtos(_dDataFim) + "' "
_cQuerySPH += " AND SPH.D_E_L_E_T_ = ' '  "
_cQuerySPH += " AND (PH_PD IN ('001') OR PH_ABONO IN ("+_cParMotAbono+")) "   // Horas normais tabela SP9 -- ('114','115','116','117')  horas extras

If Select("QUESPH") > 0
	QUESPH->(dbCloseArea())
EndIf

TCQUERY _cQuerySPH NEW ALIAS "QUESPH"

_nQuant += QUESPH->QUANTC

QUESPH->(dbCloseArea())

Return(_nQuant)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | CavExtra บAutor  ณMแrcio Lins         บ Data ณ  23/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a quantidade de horas extras por periodo por mat   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CavExtra(_cMat,_dDataIni,_dDataFim)

Local _nQuant 	:= 0
Local nCnt 		:= 0
Local cStrtab   := ""
Local _cMvVerbTxHr := GETMV('CV_VERBTXH')// '112', '113', '114', '115', '116', '117', '118',  '199', '131'
Local _aMvTmp   := {} //array temporแrio para armazenar os valores dos parโmetros

_aMvTmp 		:= strtokarr(_cMvVerbTxHr,",")
_cParVerbTxHr 	:= ""

// varrendo os elementos temporแrios
For Nx := 1 To Len(_aMvTmp)
	_cParVerbTxHr	 += "'" + _aMvTmp[nX] + "',"
Next Nx 

// elimando a ๚ltima virgula
_cParVerbTxHr := Substr(_cParVerbTxHr, 1, Len(_cParVerbTxHr)-1)

nMesDiff := DateDiffMonth(_dDataIni,_dDataFim)

_cQuery := " SELECT SUM(RD_HORAS) HORAS FROM "+ RetSqlName('SRD') +" SRD "
_cQuery += " WHERE RD_FILIAL = '"+xFilial("SRD")+"' AND RD_MAT = '"+ _cMat +"' "
// se for mais de dois meses, utiliza todo o escopo de horas extras
_cQuery += " AND RD_DATPGT BETWEEN '"+Dtos( FirstDay(MonthSum(_dDataIni, nMesDiff)) )+"' AND '"+Dtos(LastDate(_dDataFim))+"' "
_cQuery += " AND SRD.D_E_L_E_T_ = ' '  "
_cQuery += " AND RD_PD IN ("+_cParVerbTxHr+") "   // Verbas de horas extras

If Select("QUESRC") > 0
	QUESRC->(dbCloseArea())
EndIf

TCQUERY _cQuery NEW ALIAS "QUESRC"

_nQuant += QUESRC->HORAS

QUESRC->(dbCloseArea())

Return(_nQuant)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | CavAusen บAutor  ณMแrccio Lins        บ Data ณ  15/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a quantidade de horas do Ponto por funcionario  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CavAusen(_cMat,_dDataIni,_dDataFim)

	Local _nQuant   := 0
	Local _cMvAusen := GETMV('CV_TXAUSEN')// 'K','J','I','H'
	Local _aMvTmp   := {} //array temporแrio para armazenar os valores dos parโmetros

	_aMvTmp 		:= strtokarr(_cMvAusen,",")
	_cParAusen 	:= ""

	// varrendo os elementos temporแrios
	For Nx := 1 To Len(_aMvTmp)
		_cParAusen	 += "'" + _aMvTmp[nX] + "',"
	Next Nx 

	// elimando a ๚ltima virgula
	_cParAusen := Substr(_cParAusen, 1, Len(_cParAusen)-1)
	
	_cQuery := " SELECT SUM(R8_DURACAO) DURACAO FROM "+RetSqlName("SR8")+" SR8 "
	_cQuery += " WHERE R8_FILIAL = '"+xFilial("SR8")+"' AND R8_MAT = '"+ _cMat +"' "
	_cQuery += " AND R8_DATAINI BETWEEN '"+Dtos(_dDataIni)+"' AND '"+Dtos(_dDataFim)+"' "
	_cQuery += " AND SR8.D_E_L_E_T_ = ' '  "
	_cQuery += " AND R8_TIPO NOT IN ("+_cParAusen+") "
	
	If Select("QUESR8") > 0
		dbCloseArea()
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "QUESR8"
	
	// Retorna a quantidade de dias que o funcionแrios foi afastado
	// e como precisa apresentar a em horas multiplica por 8 ou equivalente 8h/dia
	_nQuant := QUESR8->DURACAO // poderia trazer a informa็ใo em conjunto com a SRA X SR6
	
	QUESR8->(dbCloseArea())
	
Return(_nQuant)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EfetTxOp บAutor  ณMแrcio Lins 		 บ Data ณ  02/15/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetiva็ใo da taxa no custo standard						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EfetTxOp(nValFinal, oDialog)

If MsgYesNo("Aten็ใo: este processo vai pode levar um certo tempo, desejแ continuar ?")
	
	// atualiza apenas a Mใo de Obra (Produto)
	_cQuery := " UPDATE " + RetSqlName("SB1") + " SET B1_CUSTD = '" + cValToChar(round(nValFinal,2)) + "', B1_UCALSTD = '" + DToS(dDatabase) + "' "
	_cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' AND B1_TIPO = 'MO' "
	_cQuery += " AND B1_ATIVO = 'S' "
	_cQuery += " AND D_E_L_E_T_ <> '*' "
	
	// Executando o Update direto na base
	TcSqlExec(_cQuery)
	
	// atualiza o saldo iniciais
	_cQuery := " UPDATE " + RetSqlName("SB2") + " SET B2_CM1 = '" + cValToChar(round(nValFinal,2)) + "', B2_VATU1='" + cValToChar(round(nValFinal,2)) + "' "
	_cQuery += " WHERE B2_FILIAL = '" + xFilial("SB2") + "' AND SUBSTRING(B2_COD, 1, 3)='MOD'"
	_cQuery += " AND D_E_L_E_T_ = ' ' "
	
	// Executando o Update direto na base
	TcSqlExec(_cQuery)
	
	// atualiza o saldo em estoque
	_cQuery := " UPDATE " + RetSqlName("SB9") + " SET B9_VINI1 = '" + cValToChar(round(nValFinal,2)) + "', B9_VINI1 = B9_VINI1 * B9_QINI, B9_CUSTD = '" + cValToChar(round(nValFinal,2)) + "'"
	_cQuery += " WHERE B9_FILIAL = '" + xFilial("SB9") + "' AND B9_DATA BETWEEN '" + DToS(MV_PAR01) + "' AND  '" + DToS(MV_PAR02) + "' AND SUBSTRING(B9_COD, 1, 3)='MOD'"
	_cQuery += " AND D_E_L_E_T_ = ' ' "
	
	// Executando o Update direto na base
	TcSqlExec(_cQuery)
	
	// atualiza apenas a Saldo do Periodo (SD3)
	_cQuery := " UPDATE " + RetSqlName("SD3") + " SET D3_CUSTO1 = (" + cValToChar(round(nValFinal,2)) + " * D3_QUANT) "
	_cQuery += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' AND D3_TIPO = 'MO' "
	_cQuery += " AND D3_EMISSAO BETWEEN  '" + DtoS(mv_par01) + "' AND '" + DtoS(mv_par02) + "' "
	_cQuery += " AND D_E_L_E_T_ <> '*' "
	
	// Executando o Update direto na base
	TcSqlExec(_cQuery)
	
	
	// thank you
	MsgInfo("Taxa Salva com Sucesso!", "Calculo da Taxa Efetiva O.P.")
	
EndIf

oDialog:End()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | AjustVal บAutor  ณMแrcio Lins	     บ Data ณ  05/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajuste nos cแlculos com base na solicita็ใo o Sr. Ricardo  บฑฑ
ฑฑบ          ณ Florio (CEO - Cavanna)                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Calculo da Taxa Efetiva OP (CAVTAX01)                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustVal(nValorA,oValor2)

	// mantem o tempo
	If nVlrAjTmp = 0
		nVlrAjTmp := nValor
	Else
		nValor := nVlrAjTmp
	EndIf
	
	// atualiza
	nValor 	  := nValor + nValorA
	
	oValor:Refresh()
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | ExportExcel บAutor  ณMแrcio Lins	     บ Data ณ  22/04/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajuste nos cแlculos com base na solicita็ใo o Sr. Ricardo  บฑฑ
ฑฑบ          ณ Florio (CEO - Cavanna)                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Calculo da Taxa Efetiva OP (CAVTAX01)                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExportExcel(aCabExcel, aItensExcel)

	Local aFunc := {} //aItensExcel
	Local aPlanoContas := {} //aCabExcel
	   
	// Alterado por Mแrcio lins  - 28/05/14 - Solicita็ใo Riccardo Florio
	// tratamento para exportar apenas os selecionados
	// Funcionแrios
	For Nx := 1 To len(aItensExcel)
		If aItensExcel[Nx][1]
			aAdd(aFunc, aItensExcel[Nx])
		EndIf
	Next Nx
	
	// Plano de Contas
	For Ny := 1 To len(aCabExcel)
		If aCabExcel[Ny][1]
			aAdd(aPlanoContas, aCabExcel[Ny])
		EndIf	
	Next Ny
	
   	DlgToExcel({ {"ARRAY", 	"Plano de Contas", 		{"Selecionado","Conta Contabil","Descri็ใo","Saldo Contabil"}, aPlanoContas },;
	 			 { "ARRAY",  "Mao de Obra", 	  	{"Selecionado","Matricula","Nome", "Horas Apontadas", "Horas Efetivas Mensalistas", "Horas Extras", "Hr. Ausencia"},  aFunc } })


Return