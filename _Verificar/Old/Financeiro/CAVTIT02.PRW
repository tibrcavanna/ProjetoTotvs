#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 09/01/04
#include "topconn.ch"        // incluido pelo assistente de conversao do AP6 IDE em 09/01/04

#IFNDEF WINDOWS
	#DEFINE PSay SAY
#ENDIF


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP6 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 09/01/04 ==>         #DEFINE PSay SAY
#ENDIF
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё CAVTIT02 Ё Autor ЁWilson Ascencio        Ё Data Ё 14/09/98 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Relatorio de Acompanhamento dos Pgtos.e Recebimentos       Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
User Function CAVTIT02()        // incluido pelo assistente de conversao do AP6 IDE em 09/01/04

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis obrigatorias dos programas de relatorio            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetPrvt("CPERG,TITULO,CDESC1,CDESC2,CDESC3,CSTRING")
SetPrvt("AORD,WNREL,ARETURN,NLASTKEY,TAMANHO,NTIPO")
SetPrvt("CRODATXT,NCNTIMPR,CQUEBRA,CCOND,CNOMARQ,LI")
SetPrvt("M_PAG,AMESES,MES1,MES2,MES3,CMESES")
SetPrvt("CABEC1,CABEC2,CNOMARQ2,WVLRBXA,WTOTBXA,WVLRBXM")
SetPrvt("WTOTBXM,WVLRSAU,WTOTSAU,WVLRTMES1,WVLRTMES2,WVLRTMES3")
SetPrvt("WVLRTPOST,WVLRTPED1,WVLRTPED2,WVLRTPED3,WTOTVEN,WTOTAVEN")
SetPrvt("WTOTAMES1,WTOTMES2,WTOTMES3,WTOTAPOST,EMIOPCU,EMIOBRPER")
SetPrvt("EMITOTACU,EMITOTPER,WWTOTMES1,WTOTMES1,WTOTPOST,WFORMES1")
SetPrvt("WFORMES2,WFORMES3,WFORAMES1,WFORAMES2,WFORAMES3,WTOTORC")
SetPrvt("WTOTV,WTOTORC1,WACUM1,WEMINATACU,EMINATACU,WEMINATPER")
SetPrvt("WBXANATACU,WBXANATPER,WNAT,WABENATACU2,WWTOTMES2,WWTOTMES3")
SetPrvt("WWTOTPOST,WWFORMES1,WWFORMES2,WWFORMES3,WWACUM,WWTOTORC")
SetPrvt("HOUVE,NGPEMINATACU,NGPEMINATPER,NGPBXANATACU,NGPBXANATPER,NGPNAT")
SetPrvt("NGPNATACU2,NGPTOTMES1,NGPTOTMES2,NGPTOTMES3,NGPTOTPOST,NGPFORMES1")
SetPrvt("NGPFORMES2,NGPFORMES3,NGPACUM,NGPTOTORC,NGREMINATACU,NGREMINATPER")
SetPrvt("NGRBXANATACU,NGRBXANATPER,NGRNAT,NGRNATACU2,NGRTOTMES1,NGRTOTMES2")
SetPrvt("NGRTOTMES3,NGRTOTPOST,NGRFORMES1,NGRFORMES2,NGRFORMES3,NGRACUM")
SetPrvt("NGRTOTORC,ACAMPOS,CTRAB,CIND,WNATUREZA,NOP")
SetPrvt("NTOTOP,NATANT,EMINATPER,BXANATACU,BXANATPER,ABENATACU")
SetPrvt("ABENATACU2,NVALDESACU,NVALDESPER,WTOTAMES2,WTOTAMES3,WOP")
SetPrvt("WACUM,")



titulo   := "Relatorio de Acompanhamento Financeiro"
cDesc1   := "Relatorio desenvolvido em RdMake exclusivo para Cavanna."
cDesc2   := "Exibe os titulos pagos/recebidos no periodo desejado,alem"
cDesc3   := "da carteira em aberto e os valores acumulados."
cString  := "SE2"
aOrd     := {}
wnrel    := "CAVTIT02"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis padrao de todos os relatorios                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aReturn:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey:= 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

cPerg := "MAPS190001"

PutSx1(cPerg,"01","Periodo de   ?","","","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Periodo ate  ?","","","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"03","Natureza de  ?","","","mv_ch3","C",6,0,0,"G","","SED","","","mv_par03","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"04","Natureza ate ?","","","mv_ch4","C",6,0,0,"G","","SED","","","mv_par04","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"05","Op de        ?","","","mv_ch5","C",13,0,0,"G","","SC2","","","mv_par05","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"06","Op ate       ?","","","mv_ch6","C",13,0,0,"G","","SC2","","","mv_par06","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Data base    ?","","","mv_ch7","D",8,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",,,,"")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica as perguntas selecionadas                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Pergunte(cPerg,.T.)
	Return
EndIf

Pergunte(cPerg,.F.)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Envia controle para a funcao SETPRINT                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

//titulo:= titulo + " Periodo de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd)

nLastKey:=IIf(LastKey()==27,27,nLastKey)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
nLastKey:=IIf(LastKey()==27,27,nLastKey)
If nLastKey == 27
	Return
Endif
#IFDEF WINDOWS
	RptStatus({|| C885Imp()})// Substituido pelo assistente de conversao do AP6 IDE em 09/01/04 ==> 	RptStatus({|| Execute(C885Imp)})
	// Substituido pelo assistente de conversao do AP6 IDE em 09/01/04 ==> 	FUNCTION C885Imp
	Static FUNCTION C885Imp()
#ENDIF
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё C885IMP  Ё       Ё                       Ё      Ё          Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Chamada do Relatorio                                       Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis locais exclusivas deste programa                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Tamanho  := "G"
nTipo    := 0
cRodaTxt := "REGISTRO(S)"
nCntImpr := 0

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis utilizadas na totalizacao do relatorio             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuebra		:=""


//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa os codigos de caracter Comprimido/Normal da impressora Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nTipo  := IIF(aReturn[4]==1,15,18)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Contadores de linha e pagina                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
li := 80
m_pag := 1

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria o cabecalho.                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

// MESES ACUMULADOS
AMESES := {}

AMESES := ARRAY(12)
AMESES := {"  JANEIRO  "," FEVEREIRO ","   MARCO   ","   ABRIL   ",;
"    MAIO   ","   JUNHO   ","   JULHO   ","   AGOSTO  ",;
"  SETEMBRO ","  OUTUBRO  "," NOVEMBRO  ","  DEZEMBRO "}
If Day(mv_par02 + 1) == 1
	if MONTH(mv_par02) == 12
		Mes1 := 1
	else
		Mes1:= MONTH(mv_par02) + 1
	Endif
else
	Mes1:= MONTH(mv_par02)
Endif
if Mes1 == 12
	Mes2 := 1
else
	Mes2:= Mes1 + 1
endif

if Mes2 == 12
	Mes3 := 1
else
	Mes3:= Mes2 + 1
endif

CMESES :=" "+  AMESES[Mes1]+ " | "+AMESES[Mes2]+ " | " +AMESES[Mes3] + " | "


cabec1 := "OP                              |------PAGOS / RECEBIDOS-----|-------- EM ABERTO ---------|------------------ A VENCER DESMEMBRADO ----------------|"
cabec1 := cabec1 + "------ COMPRAS EM ABERTO + PREVISAO -----|   ACUMULADO  |     TOTAL    |"
cabec2 := "NATUREZA FINANCEIRA             | ANTERIOR          PERIODO  |  VENCIDO          A VENCER |" + CMESES + "MESES POSTER.|"
cabec2 := cabec2 + CMESES + "    TOTAL    |    ORCADO    |"

cString:="SE1"
aOrd   :={}

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis para controlar cursor de progressao     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetRegua(LastRec())

dbSelectArea("SE2")

//titulo:= "Relatorio de Acompanhamento Financeiro" + " Periodo de " +;
//dtoc(mv_par01) + " ate " + dtoc(mv_par02)

//Cria arquivo temporario para  o arquivo de pedidos de compras
//
aCampos := { {"PD_OP"      ,"C",06,0 } ,;
{"PD_TOTAL"   ,"N",14,2 } ,;
{"PD_PEDIDO"  ,"C",06,0 } ,;
{"PD_DATPRF"  ,"D",08,0 } ,;
{"PD_NATUR"   ,"C",10,0 }}

cTrab  := CriaTrab(aCampos,.T.)
cInd   := "DTOS(PD_DATPRF)+PD_NATUR" //+ PD_OP + PD_PEDIDO + PD_ITEM"


cNomArq 	:= CriaTrab(aCampos,.T.)
DbUseArea(.T.,,cTrab,"PED",.F.,.F.)
cNomArq1 := Subs(cNomArq,1,7)+"A"
IndRegua("PED",cNomArq1,"DTOS(PD_DATPRF)+PD_NATUR",,,"Selecionando Registros...")
cNomArq2 := Subs(cNomArq,1,7)+"B"
IndRegua("PED",cNomArq2,"PD_NATUR+DTOS(PD_DATPRF)",,,"Selecionando Registros...")
dbClearIndex()
//#IFNDEF TOP
dbSetIndex(cNomArq1+OrdBagExt())
dbSetIndex(cNomArq2+OrdBagExt())
//#ENDIF
//IndRegua("PED",cTrab,cInd,,,"Selecionando Pedidos de Compras...")

//_cQuery  := " SELECT * FROM "+RetSqlName("SC7")+" SC7 "
//_cQuery  += " WHERE SC7.D_E_L_E_T_ = ' ' AND SC7.C7_FILIAL = '"+xFilial("SC7")+"' "
//_cQuery  += " AND C7_ENCER <> 'E' AND LEFT(C7_OP,5) BETWEEN '"+Left(mv_par05,6)+"' AND '"+Left(mv_par06,6)+"' "

cDataCor1:= Subs(DTOS(ddatabase),1,4)+StrZero((Val(Subs(DTOS(ddatabase),5,2))-1),2)
cDataCor2:= Subs(DTOS(ddatabase),1,4)+StrZero((Val(Subs(DTOS(ddatabase),5,2))),2)

//+StrZero(Val(Right(Dtoc(ddatabase)),2),2)
                                    
_cQuery := " SELECT DISTINCT LEFT(C2_NUM,5)+C2_ITEM+C2_SEQUEN  AS C2_NUM FROM "+RetSqlName("SC2")+" SC2 "
_cQuery += " WHERE C2_FILIAL = '"+xFilial("SC2")+"' AND D_E_L_E_T_ = ' ' " 
_cQuery += " AND C2_ITEM = '01' "
_cQuery += " AND C2_SEQUEN = '001' "    
_cQuery += " AND LEFT(C2_NUM,5) BETWEEN '"+Left(mv_par05,5)+"' AND '"+Left(mv_par06,5)+"' "
_cQuery += " ORDER BY C2_NUM  " 

If Select("QUESC2") > 0 
   dbcloseArea()
EndIf                                               

TCQUERY _cQuery NEW ALIAS "QUESC2"
          
While !Eof()

	_aAreaSC2 := GetArea()        
	
	If Empty(QUESC2->(C2_NUM))
	   QUESC2->(dbSkip())
	   Loop
	EndIf   
	
	_cQuery := " UPDATE "+RetSqlName("SE2")+" SET E2_XOP = '"+LEFT(QUESC2->C2_NUM,5)+" 01001' "
	_cQuery += " FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
	_cQuery += " INNER JOIN "+RetSqlName("SE2")+" SE2 ON (SE2.D_E_L_E_T_ = ' ' AND E2_NUM+E2_FORNECE+E2_LOJA = D1_DOC+D1_FORNECE+D1_LOJA) "
	_cQuery += " WHERE LEFT(D1_OP,5) = '"+LEFT(QUESC2->C2_NUM,5)+"' "
	_cQuery += " AND SD1.D_E_L_E_T_ = ' ' " 
	_cQuery += " AND LEFT(SE2.E2_XOP,5) <> '"+LEFT(QUESC2->C2_NUM,5)+"' " 
    TCSQLEXEC(_cQuery)
                                             
	_cQuery := " UPDATE "+RetSqlName("SE1")+" SET E1_XOP = '"+LEFT(QUESC2->C2_NUM,5)+" 01001' "
	_cQuery += " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK) "
	_cQuery += " INNER JOIN "+RetSqlName("SE1")+" SE1 ON (SE1.D_E_L_E_T_ = ' ' AND E1_NUM+E1_CLIENTE+E1_LOJA = D2_DOC+D2_CLIENTE+D2_LOJA) "
	_cQuery += " WHERE LEFT(D2_OP,5) = '"+LEFT(QUESC2->C2_NUM,5)+"' "
	_cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
	_cQuery += " AND LEFT(SE1.E1_XOP,5) <> '"+LEFT(QUESC2->C2_NUM,5)+"' " 
    TCSQLEXEC(_cQuery)

	_cQuery := " UPDATE "+RetSqlName("SE1")+" SET E1_XOP = '"+LEFT(QUESC2->C2_NUM,5)+" 01001' "
	_cQuery += " FROM "+RetSqlName("SD2")+" SD2 (NOLOCK) "
	_cQuery += " INNER JOIN "+RetSqlName("SE1")+" SE1 ON (SE1.D_E_L_E_T_ = ' ' AND E1_NUM+E1_CLIENTE+E1_LOJA = D2_DOC+D2_CLIENTE+D2_LOJA) "
	_cQuery += " WHERE LEFT(D2_PEDIDO,5) = '"+LEFT(QUESC2->C2_NUM,5)+"' "
	_cQuery += " AND SD2.D_E_L_E_T_ = ' ' "
	_cQuery += " AND LEFT(SE1.E1_XOP,5) <> '"+LEFT(QUESC2->C2_NUM,5)+"' " 
    TCSQLEXEC(_cQuery)


	mv_par05:=mv_par06 := LEFT(QUESC2->C2_NUM,5)
	
	dbSelectArea("PED")
	zap
	
	wVlrBxA:=wTotBxA:=0
	wVlrBxM:=wTotBxM:=0
	wVlrSaU:=wTotSaU:=0
	wVlrTMes1:=wVlrTMes2:=wVlrTMes3:=wVlrTPost:=0
	wVlrTPed1:=wVlrTPed2:=wVlrTPed3:=0
	wTotVen:=wTotaVen:= wTotaMes1:=wTotMes2:=wTotMes3:=wTotaPost:=wTotSa:=0  // totais vencidos e a vencer
	EmiOPcu:=EmiObrPer:=0
	EmiTotAcu:=EmiTotPer:=0
	wwTotMes1:=0
	wTotMes1:=wTotMes2:=wTotMes3:=wTotPost:=0
	wForMes1:=wForMes2:=wForMes3:=0
	wForaMes1:=wForaMes2:=wForaMes3:= 0
	wTotOrc:=0
	wtotv:=0
	wtotorc1:=0
	wacum1:=0
	wEmiNatAcu:=0
	wEmiNatAcu:= 0
	eminatacu:=0
	wEmiNatPer:= 0
	wBxaNatAcu:= 0
	wBxaNatPer:= 0
	wNat:= 0
	wAbeNatAcu2:= 0
	wwTotMes2:= 0
	wwTotMes3:= 0
	wwTotPost:= 0
	wwForMes1:= 0
	wwForMes2:= 0
	wwForMes3:= 0
	wTotaMes1:= 0
	wTotaMes2:= 0
	wTotaMes3:= 0
	wwAcum:=0
	wwTotOrc:=0
	
	// Totais GP
	nGPEmiNatAcu   := 0
	nGPEmiNatPer   := 0
	nGPBxaNatAcu   := 0
	nGPBxaNatPer   := 0
	nGPNat      := 0
	nGPNatAcu2  := 0
	nGPTotMes1  := 0
	nGPTotMes2  := 0
	nGPTotMes3  := 0
	nGPTotPost  := 0
	nGPForMes1  := 0
	nGPForMes2  := 0
	nGPForMes3  := 0
	nGPAcum     := 0
	nGPTotOrc   := 0
	
	// Totais GR
	nGREmiNatAcu   := 0
	nGREmiNatPer   := 0
	nGRBxaNatAcu   := 0
	nGRBxaNatPer   := 0
	nGRNat      := 0
	nGRNatAcu2  := 0
	nGRTotMes1  := 0
	nGRTotMes2  := 0
	nGRTotMes3  := 0
	nGRTotPost  := 0
	nGRForMes1  := 0
	nGRForMes2  := 0
	nGRForMes3  := 0
	nGRAcum     := 0
	nGRTotOrc   := 0
	_nRecRes1 := 0
	_nRecRes2 := 0
	_nRecRes3 := 0
	_nRecRes4 := 0
	_nRecRes5 := 0
	_nRecRes6 := 0
	_nRecRes7 := 0
	_nRecRes8 := 0
	_nRecRes9 := 0
	_nRecResA := 0
	_nRecResB := 0
	_nRecResC := 0
	_nRecResD := 0
	
	_nPagRes1 := 0
	_nPagRes2 := 0
	_nPagRes3 := 0
	_nPagRes4 := 0
	_nPagRes5 := 0
	_nPagRes6 := 0
	_nPagRes7 := 0
	_nPagRes8 := 0
	_nPagRes9 := 0
	_nPagResA := 0
	_nPagResB := 0
	_nPagResC := 0
	_nPagResD := 0
	_nCustoRE := 0
	_nQuantRE := 0
	_nCustoDE := 0
	_nQuantDE := 0
	
	titulo:= "Relatorio de Acompanhamento Financeiro" +;
	" Periodo de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	li:= 7
	
	li++               
	
	cQuebra := LEFT(QUESC2->C2_NUM,5)

		li := li+1
		@ li,000 PSay "Ordem de produГЦo: " + cQuebra
		li := li+1
		@ li,000 PSay repl("_",220)
		li := li+1

	
	_cQuery  := " SELECT SUM(C7_TOTAL) AS C7_TOTAL,LEFT(C7_OP,5) AS C7_OP,C7_NUM, "
	_cQuery  += " CASE WHEN SUBSTRING(C7_DATPRF,1,6) <= '"+cDataCor1+"' THEN '"+cDataCor2+"' ELSE SUBSTRING(C7_DATPRF,1,6) END C7_DATPRF , "
	_cQuery  += " A2_NATUREZ FROM "+RetSqlName("SC7")+" SC7 (NOLOCK) "
	_cQuery  += " LEFT OUTER JOIN "+RetSqlName("SA2")+" SA2 ON (SA2.D_E_L_E_T_ = ' ' AND A2_COD = C7_FORNECE AND A2_LOJA = C7_LOJA ) "
	_cQuery  += " WHERE SC7.D_E_L_E_T_ = ' ' "
	_cQuery  += " AND C7_FILIAL = '"+xFilial("SC7")+"' "
	_cQuery  += " AND C7_ENCER <> 'E' "
	_cQuery  += " AND ( C7_QUANT-C7_QUJE ) > 0 "
	_cQuery  += " AND LEFT(C7_OP,5) BETWEEN '"+Left(mv_par05,5)+"' AND '"+Left(mv_par06,5)+"' "
	_cQuery  += " GROUP BY C7_FILIAL,C7_NUM,LEFT(C7_OP,5),C7_DATPRF,A2_NATUREZ "
	
	If Select("QUESC7") > 1
		dbCloseArea()
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "QUESC7"
	
	dbSelectArea("QUESC7")
	
	Do While !eof() .And. LEFT(QUESC7->C7_OP,5) <= LEFT(mv_par06,5)
		
		_aAreaSC7 := GetArea()
		
		DbSelectArea("PED")
		DbSetOrder(1)
		_cChave := (QUESC7->C7_DATPRF +"01") + QUESC7->A2_NATUREZ //+ LEFT(QUESC7->C7_OP,5)
		If !dbSeek(_cChave)
			RecLock("PED",.t.)
			REPLACE PD_PEDIDO  WITH QUESC7->C7_NUM
			//		REPLACE PD_ITEM    WITH QUESC7->C7_ITEM
			REPLACE PD_OP      WITH LEFT(QUESC7->C7_OP,5)
			REPLACE PD_TOTAL   WITH QUESC7->C7_TOTAL
			REPLACE PD_DATPRF  WITH STOD(QUESC7->C7_DATPRF +"01")
			REPLACE PD_NATUR   WITH QUESC7->A2_NATUREZ
			MsUnlock()
		Else
			RecLock("PED",.F.)
			PED->PD_TOTAL  := PED->PD_TOTAL +  QUESC7->C7_TOTAL
			MsUnlock()
		EndIf
		
		RestArea(_aAreaSC7)
		DbSkip()
		
	Enddo
	
	//DbSelectArea("PED")
	//copy to douglas.dbf
	//alert(1)
	
	QUESC7->(dbCloseArea())
	
	/*/
	_cQuery := " SELECT * FROM "+RetSqLName("SC2")+" SC2 (NOLOCK) "
	_cQuery += " WHERE D_E_L_E_T_ = ' ' AND "
	_cQuery += " SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
	_cQuery += " AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN BETWEEN '"+mv_par05+"'  AND  '"+mv_par06+"' "
	_cQuery += " ORDER BY C2_NUM+C2_ITEM+C2_SEQUEN "
	
	If Select("QUESC2") > 0
		dbCloseArea()
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "QUESC2"
	/*/
	
	EmiNatAcu:=0
	EmiNatPer:=0
	BxaNatAcu:=0
	BxaNatPer:=0
	AbeNatAcu:=0
	AbeNatAcu2:=0
	_lFez  := .f.
	
	//--------------------------------------------------------------------------------------------------------------------------------------//
	//fim da criacao do arquivo temporario do SC7
	//DbSelectArea("QUESC2")
	//Do While !Eof() .And. QUESC2->(C2_NUM+C2_ITEM+C2_SEQUEN) <= mv_par06
	
	//	wNatureza := space(00)
	//	cQuebra 	 := QUESC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
	//	nOP       := QUESC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
	Private nTotOP    := 0
	
	_cQuery := " SELECT SUM(E2_VALOR) AS E2_VALOR,SUM(E2_SALDO) AS E2_SALDO,E2_XOP, "
	_cQuery += " E2_NATUREZ,E2_EMISSAO,SUBSTRING(E2_VENCREA,1,6)+'01' AS E2_VENCREA, "
	_cQuery += " E2_PREFIXO,E2_NUM,E2_FORNECE,E2_LOJA,E2_PARCELA,E2_TIPO "
	_cQuery += " FROM "+RetSqlName("SE2")+" SE2 (NOLOCK) "
	_cQuery += " WHERE LEFT(E2_XOP,5) BETWEEN '"+LEFT(MV_PAR05,5)+"' AND '"+LEFT(mv_par06,5)+"' "
	_cQuery += " AND D_E_L_E_T_ = ' ' "
	//_cQuery += " AND E2_NATUREZ = '0102' "
	_cQuery += " GROUP BY E2_XOP,E2_NATUREZ,E2_EMISSAO,SUBSTRING(E2_VENCREA,1,6)+'01',E2_PREFIXO,E2_NUM,E2_FORNECE,E2_LOJA,E2_PARCELA,E2_TIPO "
	_cQuery += " ORDER BY E2_NATUREZ,E2_XOP,SUBSTRING(E2_VENCREA,1,6)+'01' "
	
	If Select("QUESE2") > 0
		dbcloseArea()
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "QUESE2"
	
	_lTemSE2 := .F.
	
	DbSelectArea("QUESE2")
	While !Eof()
		_lTemSE2 := .T.
		
		_aAreaSE2 := GetArea()
		cQuebra   := QUESE2->E2_XOP
		nTotOP    := 0
		
		ProcRegua(RecCount())
		//	If DbSeek(xFilial("SE2")+cQuebra,.F.)
		
		//	titulo:= "Relatorio de Acompanhamento Financeiro" +;
		//	" Periodo de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
		//	If li > 58
		//		cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		//		li := li-1
		//	EndIf
		
		
		
		While !Eof() .And. Rtrim(QUESE2->E2_XOP) == Rtrim(cQuebra)//==
			
			NatAnt := QUESE2->E2_NATUREZ
			
			EmiNatAcu:=0
			EmiNatPer:=0
			BxaNatAcu:=0
			BxaNatPer:=0
			AbeNatAcu:=0
			AbeNatAcu2:=0
			wForMes1:=wForMes2:=wForMes3:=0
			_aAreaSE21 := GetArea()
			
			While !Eof() .And. LEFT(QUESE2->E2_XOP,5) == LEFT(cQuebra,5) .AND. QUESE2->E2_NATUREZ == NatAnt //==
				
				//If QUESE2->E2_emissao < DTOS(mv_par01)
				//	DBSKIP()
				//	LOOP
				//Endif
				
				_aAreaSE22 := GetArea()
				
				If QUESE2->E2_EMISSAO <=DTOS(mv_par02)
					
					IncRegua()
					//If li > 58
					//	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
					//	li := li-1
					//EndIf
					
					//Realizando tratamento sobre arquivo de Baixas (SE5) para DESCONTOS (E5_TIPODOC=DC)
					nValDesAcu :=0
					nValDesPer :=0
					DbSelectArea("SE5")
					DbSetOrder(7)
					DbGotop()
					If DbSeek(xFilial()+QUESE2->E2_PREFIXO+QUESE2->E2_NUM+QUESE2->E2_PARCELA+QUESE2->E2_TIPO)
						Do While !EOF() .AND. SE5->E5_PREFIXO == QUESE2->E2_PREFIXO .AND.;
							SE5->E5_NUMERO  == QUESE2->E2_NUM .AND.;
							SE5->E5_PARCELA == QUESE2->E2_PARCELA .AND.;
							SE5->E5_TIPO    == QUESE2->E2_TIPO
							
							IF SE5->E5_CLIFOR != QUESE2->E2_FORNECE
								DBSKIP()
								LOOP
							ENDIF
							
							IF SE5->E5_SITUACA == "C"
								DBSKIP()
								LOOP
							ENDIF
							
							/*/
							If (DTOS(E5_DATA)>DTOS(mv_par07))
								DBSKIP()
								LOOP
							Endif
							/*/
							
							If (DTOS(E5_DATA)<DTOS(mv_par01))    //Valores Acumulados ate a data inicial
								IF E5_TIPODOC $ "VL/BA/V2/CP/LJ"  //Tipos de Movimentos
									BxaNatAcu := BxaNatAcu - E5_VALOR
								ELSEIF E5_TIPODOC $ "ES"
									BxaNatAcu := BxaNatAcu + E5_VALOR
								ENDIF
							Else
								If (DTOS(E5_DATA)<=DTOS(mv_par02))  //Valores no Periodo ate a data final
									IF E5_TIPODOC $ "VL/BA/V2/CP/LJ"
										BxaNatPER := BxaNatPER - E5_VALOR
									ELSEIF E5_TIPODOC $ "ES"
										BxaNatPER := BxaNatPER + E5_VALOR
									ENDIF
								Else                               //Valores a Vencer nada
									//  Estas duas linhas estao inibidas acredito que precisam retornar a funcionar.
									//	AbeNatAcu2 := AbeNatAcu2 - E5_VALOR
									//	wTotaVen   := wTotaVen - E5_VALOR
								EndIf
							Endif
							
							DbSelectArea("SE5")
							DbSkip()
							
						EndDo
					EndIf
					
					If QUESE2->E2_VENCREA < DTOS(mv_par01).and. QUESE2->E2_SALDO#0.00
						EmiNatAcu := EmiNatAcu - QUESE2->E2_SALDO
						EmiOPcu := EmiOPcu - QUESE2->E2_SALDO
						EmiTotAcu := EmiTotAcu - QUESE2->E2_SALDO
					Else
						EmiNatPer := EmiNatPer - QUESE2->E2_SALDO
						EmiObrPer := EmiObrPer - QUESE2->E2_SALDO
						EmiTotPer := EmiTotPer - QUESE2->E2_SALDO
					Endif
					
					If QUESE2->E2_VENCREA < DTOS(mv_par02) .and. QUESE2->E2_SALDO#0.00
						AbeNatAcu := AbeNatAcu - QUESE2->E2_SALDO
						wVlrSaU   := wVlrSaU - QUESE2->E2_SALDO
						wTotSaU   := wTotSaU - QUESE2->E2_SALDO
						wTotVen   := wTotVen - QUESE2->E2_SALDO
					Else
						If QUESE2->E2_VENCREA >= DTOS(mv_par02)
							AbeNatAcu2 := AbeNatAcu2 - QUESE2->E2_SALDO
							wVlrSaU    := wVlrSaU - QUESE2->E2_SALDO
							wTotSaU    := wTotSaU - QUESE2->E2_SALDO
							wTotaVen   := wTotaVen - QUESE2->E2_SALDO
							Do Case
								Case Month(Stod(QUESE2->E2_VENCREA)) == Mes1
									wTotMes1  := wTotMes1 - QUESE2->E2_SALDO
									wTotaMes1 := wTotaMes1 - QUESE2->E2_SALDO
									wVlrTMes1 := wVlrTMes1 - QUESE2->E2_SALDO
								Case Month(Stod(QUESE2->E2_VENCREA)) == Mes2
									wTotMes2  := wTotMes2 - QUESE2->E2_SALDO
									wTotaMes2 := wTotaMes2 - QUESE2->E2_SALDO
									wVlrTMes2 := wVlrTMes2 - QUESE2->E2_SALDO
								Case Month(Stod(QUESE2->E2_VENCREA)) == Mes3
									wTotMes3  := wTotMes3 - QUESE2->E2_SALDO
									wTotaMes3 := wTotaMes3 - QUESE2->E2_SALDO
									wVlrTMes3 := wVlrTMes3 - QUESE2->E2_SALDO
								Otherwise
									wTotPost  := wTotPost - QUESE2->E2_SALDO
									wTotaPost := wTotaPost - QUESE2->E2_SALDO
									wVlrTPost := wVlrTPost - QUESE2->E2_SALDO
							EndCase
						EndIf
					EndIf
					
					
					DbSelectArea("SED")
					DbSeek(xFilial()+NatAnt)
					
					//				If LEFT(QUESE2->E2_VENCREA,5) < cDataCor2
					//					_cChave := cDataCor2+"01" + QUESE2->E2_NATUREZ
					//				Else
					//					_cChave := QUESE2->E2_VENCREA + QUESE2->E2_NATUREZ //+ LEFT(QUESC7->C7_OP,5)
					//				EndIf
					
					//				DbSelectArea("PED")
					//				wOP:= cQuebra		//left(SA9->A9_TECNICO,3)
					//				dbSetOrder(1)
					//				dbSeek(_cChave)
					
					
					RestArea(_aAreaSE2)
					
					/*/
					wEmiNatAcu:= wEminatacu + eminatacu
					wEmiNatPer:= weminatper + eminatper
					wBxaNatAcu:= wbxanatacu + bxanatacu
					wBxaNatPer:= wBxaNatPer + bxanatper
					wNat:= wNat + AbeNatAcu
					wAbeNatAcu2:= wabenatacu2 + abenatacu2
					wwTotMes1:= wwTotMes1 + wTotMes1
					wwTotMes2:= wwTotMes2 + wtotmes2
					wwTotMes3:= wwTotMes3 + wTotMes3
					wwTotPost:= wwtotpost + wtotpost
					wwForMes1:= wwForMes1 + wForMes1
					wwForMes2:= wwForMes2 + wForMes2
					wwForMes3:= wwForMes3 + wForMes3
					//				wwAcum   := wwacum + wacum
					/*/
					
					//		DbSelectArea("SE2")
				EndIf
				
				RestArea(_aAreaSE22)
				QUESE2->(dbSkip())
				
			EndDo
			
			_cNat := NatAnt
			
			_aAreaSE2QUE := GetArea()
			
			DbSelectArea("PED")
			DBGOTOP()
			Do While ! eof()
				If  RTRIM(PED->PD_NATUR) <> Rtrim(_cNat)
					dbSkip()
					Loop
				EndIf
				
				//				if PED->PD_NATUR == SED->ED_CODIGO
				Do Case
					Case Month(PED->PD_DATPRF) <= Mes1
						wForMes1 +=  PED->PD_TOTAL
						wForaMes1 += PED->PD_TOTAL
						wVlrTPed1 += PED->PD_TOTAL
					Case Month(PED->PD_DATPRF) == Mes2
						wForMes2 +=  PED->PD_TOTAL
						wForaMes2 += PED->PD_TOTAL
						wVlrTPed2 += PED->PD_TOTAL
					Case Month(PED->PD_DATPRF) == Mes3
						wForMes3 += PED->PD_TOTAL
						wForaMes3 += PED->PD_TOTAL
						wVlrTPed3 += PED->PD_TOTAL
				EndCase
				//				Endif
				DbSelectArea("PED")
				DbSkip()
				//	_cNat := RTRIM(PD_NATUR)
			Enddo
			
			@ li,000 PSay NatAnt
			@ li,008 PSay "|"
			@ li,009 PSay Left(GetAdvFVal("SED","ED_DESCRIC",xFilial("SED")+NatAnt,1),23)
			//			@ li,007 PSay  int(EmiNatAcu)    PICTURE "@e 9999,999,999"
			//        @ li,020 PSay  int(EmiNatPer)    PICTURE "@e 9999,999,999"
			@ li,033 PSay "|"
			@ li,034 PSay  int(BxaNatAcu)    PICTURE "@e 9999,999,999"
			@ li,047 PSay "|"
			@ li,048 PSay  int(BxaNatPer)    PICTURE "@e 9999,999,999"
			
			@ li,062 PSay "|"    //AQUI
			@ li,063 PSay  int(AbeNatAcu)    PICTURE "@e 9999,999,999"
			@ li,075 PSay "|"    //AQUI
			@ li,077 PSay  int(AbeNatAcu2)   PICTURE "@e 9999,999,999"
			@ li,090 PSay "|"
			@ li,091 PSay  int(wTotMes1)     PICTURE "@e 999,999,999"
			@ li,104 PSay "|"
			@ li,105 PSay  int(wTotMes2)     PICTURE "@e 999,999,999"
			@ li,118 PSay "|"
			@ li,119 PSay  int(wTotMes3)     PICTURE "@e 999,999,999"
			@ li,132 PSay "|"
			@ li,133 PSay  int(wTotPost)     PICTURE "@e 9999,999,999"
			@ li,147 PSay "|"
			@ li,148 PSay  int(wForMes1)*-1     PICTURE "@e 9999,999,999"
			@ li,161 PSay "|"
			@ li,162 PSay  int(wForMes2)*-1     PICTURE "@e 9999,999,999"
			@ li,175 PSay "|"
			@ li,176 PSay  int(wForMes3)*-1     PICTURE "@e 9999,999,999"
			@ li,189 PSay "|"
			
			wAcum:= (BxaNatAcu + BxaNatPer + AbeNatAcu + AbeNatAcu2)
			wAcum:= wAcum + ((wForMes1*-1) + (wForMes2*-1) + (wForMes3*-1))
			wtotv:=wtotv + wtotven
			wTotSa += wTotSaU
			
			
			@ li,190 PSay  int(wAcum)        PICTURE "@e 99999,999,999"
			@ li,204 PSay "|"
			
			wTotOrc := 0
			_lFez := .f.
			
			If !_lFez
				wOP := QUESE2->E2_XOP
				
				DbSelectArea("SZA") //left(SA9->A9_TECNICO,3)
				DbSetOrder(3)
				If DbSeek(xFilial("SZA") + NatAnt + wOP)
					@ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
					wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
					_lFez := .T.
				Else
					DbSetOrder(1)
					If DbSeek(xFilial("SZA")+ wOP + NatAnt)
						@ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
						wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
					Else
						@ li,205 PSay 0              PICTURE "@e 99999,999,999"
						_lFez := .T.
					EndIf
				EndIf
			Else
				@ li,205 PSay 0              PICTURE "@e 99999,999,999"
			EndIf
			
			@ li,219 PSay "|"
			
			
			li:=li+1
			
			RestArea(_aAreaSE2QUE)
			_nPagRes1 += BxaNatAcu
			_nPagRes2 += BxaNatPer
			_nPagRes3 += AbeNatAcu
			_nPagRes4 += abenatacu2
			_nPagRes5 += wTotMes1
			_nPagRes6 += wTotMes2
			_nPagRes7 += wTotMes3
			_nPagRes8 += wTotpost
			_nPagRes9 += (wForMes1*-1)
			_nPagResA += (wForMes2*-1)
			_nPagResB += (wForMes3*-1)
			_nPagResC += wacum
			
			wwTotOrc += wTotOrc
			wBxaNatAcu +=BxaNatAcu
			wBxaNatPer+= BxaNatPer
			wNat+= AbeNatAcu
			wAbeNatAcu2+= abenatacu2
			wwTotMes1+= wTotMes1
			wwTotMes2+= wtotmes2
			wwTotMes3+= wTotMes3
			wwTotPost+= wtotpost
			wwForMes1+= (wForMes1*-1)
			wwForMes2+= (wForMes2*-1)
			wwForMes3+= (wForMes3*-1)
			wwAcum   += wacum
			
			RestArea(_aAreaSE21)
			
			wVlrBxA   := wVlrBxA + BxaNatACU
			wVlrBxM   := wVlrBxM + BxaNatPER
			wTotBxA   := wTotBxA + BxaNatACU
			wTotBxM   := wTotBxM + BxaNatPER
			wacum1:= wacum1 + wAcum
			
			BxaNatPer := AbeNatAcu := abenatacu2 := 0
			wTotMes1  := wTotMes2:= wTotMes3 := 0
			wtotpost  :=0
			wForMes1  := wForMes2 := wForMes3:= wacum := 0
			wtotven   :=0
			wTotSaU   :=0
			wForMes1  :=0
			wForaMes1 :=0
			wVlrTPed1 :=0
			wForMes2  :=0
			wForaMes2 :=0
			wVlrTPed2 :=0
			wForMes3  :=0
			wForaMes3 :=0
			wVlrTPed3 :=0
			
			//		dbSkip()
			///////////////////
		EndDo
		
		@ li,000 PSay repl("-",220)
		li:=li+1
		
		@ li,000 PSay "T P" // Left(SED->ED_CODIGO,5)
		@ li,007 PSay "|"
		//	@ li,007 PSay  int(wEmiNatAcu)      PICTURE "@e 9999,999,999"
		//	@ li,020 PSay  int(wEmiNatPer)      PICTURE "@e 9999,999,999"
		@ li,032 PSay "|"
		@ li,033 PSay  int(wBxaNatAcu)      PICTURE "@e 9999,999,999"
		@ li,046 PSay "|"
		@ li,047 PSay  int(wBxaNatPer)      PICTURE "@e 9999,999,999"
		@ li,061 PSay "|"    //AQUI
		@ li,062 PSay  int(wNat)            PICTURE "@e 9999,999,999"
		@ li,074 PSay "|"    //AQUI
		@ li,076 PSay  int(wAbeNatAcu2)     PICTURE "@e 9999,999,999"
		@ li,089 PSay "|"
		@ li,090 PSay  int(wwTotMes1)       PICTURE "@e 999,999,999"
		@ li,103 PSay "|"
		@ li,104 PSay  int(wwTotMes2)       PICTURE "@e 999,999,999"
		@ li,117 PSay "|"
		@ li,118 PSay  int(wwTotMes3)       PICTURE "@e 999,999,999"
		@ li,131 PSay "|"
		@ li,132 PSay  int(wwTotPost)       PICTURE "@e 9999,999,999"
		@ li,146 PSay "|"
		@ li,147 PSay  int(wwForMes1)*-1       PICTURE "@e 9999,999,999"
		@ li,160 PSay "|"
		@ li,161 PSay  int(wwForMes2)*-1       PICTURE "@e 9999,999,999"
		@ li,174 PSay "|"
		@ li,175 PSay  int(wwForMes3)*-1       PICTURE "@e 9999,999,999"
		@ li,188 PSay "|"
		@ li,189 PSay  int(wwAcum)          PICTURE "@e 99999,999,999"
		@ li,203 PSay "|"
		@ li,204 PSay  int(wwTotOrc)        PICTURE "@e 99999,999,999"
		@ li,218 PSay "|"
		
		li:=li+1
		@ li,000 PSay repl("-",220)
		li:=li+1
		
		//	wtotorc1:= wtotorc1 + wtotorc
		
		nGPEmiNatAcu := nGPEmiNatAcu + wEmiNatAcu
		nGPEmiNatPer := nGPEmiNatPer + wEmiNatPer
		nGPBxaNatAcu := nGPBxaNatAcu + wBxaNatAcu
		nGPBxaNatPer := nGPBxaNatPer + wBxaNatPer
		nGPNat      := nGPNat + wNat
		nGPNatAcu2  := nGPNatAcu2 + wAbeNatAcu2
		nGPTotMes1  := nGPTotMes1 + wwTotMes1
		nGPTotMes2  := nGPTotMes2 + wwTotMes2
		nGPTotMes3  := nGPTotMes3 + wwTotMes3
		nGPTotPost  := nGPTotPost + wwTotPost
		nGPForMes1  := nGPForMes1 + wwForMes1
		nGPForMes2  := nGPForMes2 + wwForMes2
		nGPForMes3  := nGPForMes3 + wwForMes3
		nGPAcum     := nGPAcum + wwAcum
		nGPTotOrc   := nGPTotOrc + wwTotOrc
		nTotOP    := nTotOP + wwTotOrc
		
		wEmiNatAcu:=wEmiNatPer:=wBxaNatAcu:=wBxaNatPer:=wNat:=wAbeNatAcu2:=0
		wwTotMes1:=wwTotMes2:=wwTotMes3:=wwTotPost:=0
		wwForMes1:=wwForMes2:=wwForMes3:=0
		wwTotOrc := 0
		
	EndDo
	
	QUESE2->(dbCloseArea())
	//========================================================================================================================================================
	
	If !_lTemSE2
		
		
		//titulo:= "Relatorio de Acompanhamento Financeiro" +;
		//" Periodo de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
		//If li > 58
		//	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		//	li := li-1
		//EndIf
		
		DbSelectArea("PED")
		dbSetOrder(2)
		DBGOTOP()
		
		_cNat := PED->PD_NATUR
		cQuebra := PED->PD_OP
		
//		li := li+1
///		@ li,000 PSay "Ordem de produГЦo: " + cQuebra
//		li := li+1
//		@ li,000 PSay repl("_",220)
//		li := li+1
		
		Do While ! eof()
			
			_aAreaSE2QUE := GetArea()
			
			if PED->PD_NATUR == _cNat
				_lFez := .F.
				Do Case
					Case Month(PED->PD_DATPRF) <= Mes1
						wForMes1 +=  PED->PD_TOTAL
						wForaMes1 += PED->PD_TOTAL
						wVlrTPed1 += PED->PD_TOTAL
					Case Month(PED->PD_DATPRF) == Mes2
						wForMes2 +=  PED->PD_TOTAL
						wForaMes2 += PED->PD_TOTAL
						wVlrTPed2 += PED->PD_TOTAL
					Case Month(PED->PD_DATPRF) == Mes3
						wForMes3 += PED->PD_TOTAL
						wForaMes3 += PED->PD_TOTAL
						wVlrTPed3 += PED->PD_TOTAL
				EndCase
			EndIf
			
			DbSelectArea("PED")
			RestArea(_aAreaSE2QUE)
			DbSkip()
			
			If _cNat <> PED->PD_NATUR
				
				@ li,000 PSay _cNat
				@ li,008 PSay "|"
				@ li,009 PSay Left(GetAdvFVal("SED","ED_DESCRIC",xFilial("SED")+_cNat,1),23)
				//			@ li,007 PSay  int(EmiNatAcu)    PICTURE "@e 9999,999,999"
				//        @ li,020 PSay  int(EmiNatPer)    PICTURE "@e 9999,999,999"
				@ li,033 PSay "|"
				@ li,034 PSay  int(BxaNatAcu)    PICTURE "@e 9999,999,999"
				@ li,047 PSay "|"
				@ li,048 PSay  int(BxaNatPer)    PICTURE "@e 9999,999,999"
				
				@ li,062 PSay "|"    //AQUI
				@ li,063 PSay  int(AbeNatAcu)    PICTURE "@e 9999,999,999"
				@ li,075 PSay "|"    //AQUI
				@ li,077 PSay  int(AbeNatAcu2)   PICTURE "@e 9999,999,999"
				@ li,090 PSay "|"
				@ li,091 PSay  int(wTotMes1)     PICTURE "@e 999,999,999"
				@ li,104 PSay "|"
				@ li,105 PSay  int(wTotMes2)     PICTURE "@e 999,999,999"
				@ li,118 PSay "|"
				@ li,119 PSay  int(wTotMes3)     PICTURE "@e 999,999,999"
				@ li,132 PSay "|"
				@ li,133 PSay  int(wTotPost)     PICTURE "@e 9999,999,999"
				@ li,147 PSay "|"
				@ li,148 PSay  int(wForMes1)*-1     PICTURE "@e 9999,999,999"
				@ li,161 PSay "|"
				@ li,162 PSay  int(wForMes2)*-1     PICTURE "@e 9999,999,999"
				@ li,175 PSay "|"
				@ li,176 PSay  int(wForMes3)*-1     PICTURE "@e 9999,999,999"
				@ li,189 PSay "|"
				
				wAcum:= (BxaNatAcu + BxaNatPer + AbeNatAcu + AbeNatAcu2)
				wAcum:= wAcum + ((wForMes1*-1) + (wForMes2*-1) + (wForMes3*-1))
				wtotv:=wtotv + wtotven
				wTotSa += wTotSaU
				
				
				@ li,190 PSay  int(wAcum)        PICTURE "@e 99999,999,999"
				@ li,204 PSay "|"
				
				wTotOrc := 0
				
				_aAreaSE2QUE:= GetArea()
				
				If !_lFez
					wOP := PED->PD_OP
					
					DbSelectArea("SZA") //left(SA9->A9_TECNICO,3)
					DbSetOrder(3)
					If DbSeek(xFilial("SZA") + _cNat + wOP)
						@ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
						wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
						_lFez := .T.
					Else
						DbSetOrder(1)
						If DbSeek(xFilial("SZA")+ wOP +  _cNat)
							@ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
							wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
						Else
							@ li,205 PSay 0              PICTURE "@e 99999,999,999"
							_lFez := .T.
						EndIf
					EndIf
				Else
					@ li,205 PSay 0              PICTURE "@e 99999,999,999"
				EndIf
				
				@ li,219 PSay "|"
				
				RestArea(_aAreaSE2QUE)
				
				
				
				li:=li+1
				_cNat := PED->PD_NATUR
				
				wwTotMes1+= wTotMes1
				wwTotMes2+= wtotmes2
				wwTotMes3+= wTotMes3
				wwTotPost+= wtotpost
				wwForMes1+= (wForMes1*-1)
				wwForMes2+= (wForMes2*-1)
				wwForMes3+= (wForMes3*-1)
				wwTotOrc	+= wTotOrc
				wwAcum   += wacum
				
				BxaNatPer := AbeNatAcu := abenatacu2 := 0
				wTotMes1  := wTotMes2:= wTotMes3 := 0
				wtotpost  :=0
				wForMes1  := wForMes2 := wForMes3:= wacum := 0
				wtotven   :=0
				wTotSaU   :=0
				wForMes1  :=0
				wForaMes1 :=0
				wVlrTPed1 :=0
				wForMes2  :=0
				wForaMes2 :=0
				wVlrTPed2 :=0
				wForMes3  :=0
				wForaMes3 :=0
				wVlrTPed3 :=0
				
			Endif
			
			
			
			
		Enddo
		
		@ li,000 PSay repl("-",220)
		li:=li+1
		
		@ li,000 PSay "T P" // Left(SED->ED_CODIGO,5)
		@ li,007 PSay "|"
		//	@ li,007 PSay  int(wEmiNatAcu)      PICTURE "@e 9999,999,999"
		//	@ li,020 PSay  int(wEmiNatPer)      PICTURE "@e 9999,999,999"
		@ li,032 PSay "|"
		@ li,033 PSay  int(wBxaNatAcu)      PICTURE "@e 9999,999,999"
		@ li,046 PSay "|"
		@ li,047 PSay  int(wBxaNatPer)      PICTURE "@e 9999,999,999"
		@ li,061 PSay "|"    //AQUI
		@ li,062 PSay  int(wNat)            PICTURE "@e 9999,999,999"
		@ li,074 PSay "|"    //AQUI
		@ li,076 PSay  int(wAbeNatAcu2)     PICTURE "@e 9999,999,999"
		@ li,089 PSay "|"
		@ li,090 PSay  int(wwTotMes1)       PICTURE "@e 999,999,999"
		@ li,103 PSay "|"
		@ li,104 PSay  int(wwTotMes2)       PICTURE "@e 999,999,999"
		@ li,117 PSay "|"
		@ li,118 PSay  int(wwTotMes3)       PICTURE "@e 999,999,999"
		@ li,131 PSay "|"
		@ li,132 PSay  int(wwTotPost)       PICTURE "@e 9999,999,999"
		@ li,146 PSay "|"
		@ li,147 PSay  int(wwForMes1)*-1       PICTURE "@e 9999,999,999"
		@ li,160 PSay "|"
		@ li,161 PSay  int(wwForMes2)*-1       PICTURE "@e 9999,999,999"
		@ li,174 PSay "|"
		@ li,175 PSay  int(wwForMes3)*-1       PICTURE "@e 9999,999,999"
		@ li,188 PSay "|"
		@ li,189 PSay  int(wwAcum)          PICTURE "@e 99999,999,999"
		@ li,203 PSay "|"
		@ li,204 PSay  int(wwTotOrc)        PICTURE "@e 99999,999,999"
		@ li,218 PSay "|"
		
		li:=li+1
		@ li,000 PSay repl("-",220)
		li:=li+1
		
		//	wtotorc1:= wtotorc1 + wtotorc
		
		nGPEmiNatAcu := nGPEmiNatAcu + wEmiNatAcu
		nGPEmiNatPer := nGPEmiNatPer + wEmiNatPer
		nGPBxaNatAcu := nGPBxaNatAcu + wBxaNatAcu
		nGPBxaNatPer := nGPBxaNatPer + wBxaNatPer
		nGPNat      := nGPNat + wNat
		nGPNatAcu2  := nGPNatAcu2 + wAbeNatAcu2
		nGPTotMes1  := nGPTotMes1 + wwTotMes1
		nGPTotMes2  := nGPTotMes2 + wwTotMes2
		nGPTotMes3  := nGPTotMes3 + wwTotMes3
		nGPTotPost  := nGPTotPost + wwTotPost
		nGPForMes1  := nGPForMes1 + wwForMes1
		nGPForMes2  := nGPForMes2 + wwForMes2
		nGPForMes3  := nGPForMes3 + wwForMes3
		nGPAcum     := nGPAcum + wwAcum
		nGPTotOrc   := nGPTotOrc + wwTotOrc
		nTotOP    := nTotOP + wwTotOrc
		
		wEmiNatAcu:=wEmiNatPer:=wBxaNatAcu:=wBxaNatPer:=wNat:=wAbeNatAcu2:=0
		wwTotMes1:=wwTotMes2:=wwTotMes3:=wwTotPost:=0
		wwForMes1:=wwForMes2:=wwForMes3:=0
		
	EndIf
	
	
	
	wBxaNatPer:=0
	wNat:=0
	wAbeNatAcu2:=0
	wwTotMes1:=0
	wwTotMes2:=0
	wwTotMes3:=0
	wwTotPost:=0
	wwForMes1:=0
	wwForMes2:=0
	wwForMes3:=0
	wwAcum:=0
	wwTotOrc :=0
	
	
	//========================================================================================================================================================
	
	_cQuery := " SELECT SUM(E1_VALOR) AS E1_VALOR,SUM(E1_SALDO) AS E1_SALDO,E1_XOP, "
	_cQuery += " E1_NATUREZ,E1_EMISSAO,SUBSTRING(E1_VENCREA,1,6)+'01' AS E1_VENCREA, "
	_cQuery += " E1_PREFIXO,E1_NUM,E1_CLIENTE,E1_LOJA,E1_PARCELA,E1_TIPO "
	_cQuery += " FROM "+RetSqlName("SE1")+" SE1 (NOLOCK) "
	_cQuery += " WHERE LEFT(E1_XOP,5) BETWEEN '"+LEFT(MV_PAR05,5)+"' AND '"+LEFT(mv_par06,5)+"' "
	_cQuery += " AND D_E_L_E_T_ = ' ' "
	_cQuery += " GROUP BY E1_XOP,E1_NATUREZ,E1_EMISSAO,SUBSTRING(E1_VENCREA,1,6)+'01',E1_PREFIXO,E1_NUM,E1_CLIENTE,E1_LOJA,E1_PARCELA,E1_TIPO "
	_cQuery += " ORDER BY E1_NATUREZ,E1_XOP,SUBSTRING(E1_VENCREA,1,6)+'01' "
	
	If Select("QUESE1") > 0
		dbcloseArea()
	EndIf
	
	TCQUERY _cQuery NEW ALIAS "QUESE1"
	
	DbSelectArea("QUESE1")
	While !Eof()
		
		_aAreaSE1 := GetArea()
		cQuebra   := QUESE1->E1_XOP
		nTotOP    := 0
		
		ProcRegua(RecCount())
		
		li := li+1
		
		While !Eof() .And. Rtrim(QUESE1->E1_XOP) == Rtrim(cQuebra)//==
			NatAnt := QUESE1->E1_NATUREZ
			EmiNatAcu:=0
			EmiNatPer:=0
			BxaNatAcu:=0
			BxaNatPer:=0
			AbeNatAcu:=0
			AbeNatAcu2:=0
			wForMes1:=wForMes2:=wForMes3:=0
			_aAreaSE11 := GetArea()
			
			While !Eof() .And. LEFT(QUESE1->E1_XOP,5) == LEFT(cQuebra,5) .AND. QUESE1->E1_NATUREZ == NatAnt //==
				
				/*/
				If QUESE1->E1_emissao < DTOS(mv_par01)
					DBSKIP()
					LOOP
				Endif
				/*/
				
				_aAreaSE12 := GetArea()
				
				If QUESE1->E1_EMISSAO <=DTOS(mv_par02)
					
					IncRegua()
					//If li > 58
					//	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
					//	li := li-1
					//EndIf
					
					//Realizando tratamento sobre arquivo de Baixas (SE5) para DESCONTOS (E5_TIPODOC=DC)
					nValDesAcu :=0
					nValDesPer :=0
					DbSelectArea("SE5")
					DbSetOrder(7)
					DbGotop()
					If DbSeek(xFilial()+QUESE1->E1_PREFIXO+QUESE1->E1_NUM+QUESE1->E1_PARCELA+QUESE1->E1_TIPO)
						Do While !EOF() .AND. SE5->E5_PREFIXO == QUESE1->E1_PREFIXO .AND.;
							SE5->E5_NUMERO  == QUESE1->E1_NUM .AND.;
							SE5->E5_PARCELA == QUESE1->E1_PARCELA .AND.;
							SE5->E5_TIPO    == QUESE1->E1_TIPO
							
							IF SE5->E5_CLIFOR != QUESE1->E1_CLIENTE
								DBSKIP()
								LOOP
							ENDIF
							
							IF SE5->E5_SITUACA == "C" .OR. SE5->E5_TIPODOC == "DC"
								DBSKIP()
								LOOP
							ENDIF
							
							/*/
							If (DTOS(E5_DATA)>DTOS(mv_par07))
								DBSKIP()
								LOOP
							Endif
							/*/
							
							If (DTOS(E5_DATA)<DTOS(mv_par01))    //Valores Acumulados ate a data inicial
								IF E5_TIPODOC $ "VL/BA/V2/CP/LJ"  //Tipos de Movimentos
									BxaNatAcu := BxaNatAcu - E5_VALOR
								ELSEIF E5_TIPODOC $ "ES"
									BxaNatAcu := BxaNatAcu + E5_VALOR
								ENDIF
							Else
								If (DTOS(E5_DATA)<=DTOS(mv_par02))  //Valores no Periodo ate a data final
									IF E5_TIPODOC $ "VL/BA/V2/CP/LJ"
										BxaNatPER := BxaNatPER - E5_VALOR
									ELSEIF E5_TIPODOC $ "ES"
										BxaNatPER := BxaNatPER + E5_VALOR
									ENDIF
								Else                               //Valores a Vencer nada
									//  Estas duas linhas estao inibidas acredito que precisam retornar a funcionar.
									//	AbeNatAcu2 := AbeNatAcu2 - E5_VALOR
									//	wTotaVen   := wTotaVen - E5_VALOR
								EndIf
							Endif
							
							DbSelectArea("SE5")
							DbSkip()
							
						EndDo
					EndIf
					
					If QUESE1->E1_VENCREA < DTOS(mv_par01).and. QUESE1->E1_SALDO#0.00
						EmiNatAcu := EmiNatAcu - QUESE1->E1_SALDO
						EmiOPcu := EmiOPcu - QUESE1->E1_VALOR
						EmiTotAcu := EmiTotAcu - QUESE1->E1_SALDO
					Else
						EmiNatPer := EmiNatPer - QUESE1->E1_SALDO
						EmiObrPer := EmiObrPer - QUESE1->E1_SALDO
						EmiTotPer := EmiTotPer - QUESE1->E1_SALDO
					Endif
					
					If QUESE1->E1_VENCREA < DTOS(mv_par02) .and. QUESE1->E1_SALDO#0.00
						AbeNatAcu := AbeNatAcu - QUESE1->E1_SALDO
						wVlrSaU   := wVlrSaU - QUESE1->E1_SALDO
						wTotSaU   := wTotSaU - QUESE1->E1_SALDO
						wTotVen   := wTotVen - QUESE1->E1_SALDO
					Else
						If QUESE1->E1_VENCREA >= DTOS(mv_par02)
							AbeNatAcu2 := AbeNatAcu2 - QUESE1->E1_SALDO
							wVlrSaU    := wVlrSaU - QUESE1->E1_SALDO
							wTotSaU    := wTotSaU - QUESE1->E1_SALDO
							wTotaVen   := wTotaVen - QUESE1->E1_SALDO
							Do Case
								Case Month(Stod(QUESE1->E1_VENCREA)) == Mes1
									wTotMes1  := wTotMes1 - QUESE1->E1_SALDO
									wTotaMes1 := wTotaMes1 - QUESE1->E1_SALDO
									wVlrTMes1 := wVlrTMes1 - QUESE1->E1_SALDO
								Case Month(Stod(QUESE1->E1_VENCREA)) == Mes2
									wTotMes2  := wTotMes2 - QUESE1->E1_SALDO
									wTotaMes2 := wTotaMes2 - QUESE1->E1_SALDO
									wVlrTMes2 := wVlrTMes2 - QUESE1->E1_SALDO
								Case Month(Stod(QUESE1->E1_VENCREA)) == Mes3
									wTotMes3  := wTotMes3 - QUESE1->E1_SALDO
									wTotaMes3 := wTotaMes3 - QUESE1->E1_SALDO
									wVlrTMes3 := wVlrTMes3 - QUESE1->E1_SALDO
								Otherwise
									wTotPost  := wTotPost - QUESE1->E1_SALDO
									wTotaPost := wTotaPost - QUESE1->E1_SALDO
									wVlrTPost := wVlrTPost - QUESE1->E1_SALDO
							EndCase
						EndIf
					EndIf
					
					
					DbSelectArea("SED")
					DbSeek(xFilial()+NatAnt)
					
					RestArea(_aAreaSE1)
					
					/*/
					wEmiNatAcu:= wEminatacu + eminatacu
					wEmiNatPer:= weminatper + eminatper
					wBxaNatAcu:= wbxanatacu + bxanatacu
					wBxaNatPer:= wbxanatper + bxanatper
					wNat:= wNat + AbeNatAcu
					wAbeNatAcu2:= wabenatacu2 + abenatacu2
					wwTotMes1:= wwTotMes1 + wTotMes1
					wwTotMes2:= wwTotMes2 + wtotmes2
					wwTotMes3:= wwTotMes3 + wTotMes3
					wwTotPost:= wwtotpost + wtotpost
					wwForMes1:= wwForMes1 + wForMes1
					wwForMes2:= wwForMes2 + wForMes2
					wwForMes3:= wwForMes3 + wForMes3
					/*/
					//wwAcum   := wwacum + wacum
					//wwTotOrc:= wwTotOrc + wTotOrc
					//EmiNatAcu:=EmiNatPer:=BxaNatAcu:=BxaNatPer:=AbeNatAcu:=AbeNatAcu2:=0
					//wTotMes1:=wTotMes2:=wTotMes3:=wTotPost:=0
					//wForMes1:=wForMes2:=wForMes3:=wtotOrc:=0
					
					//		DbSelectArea("SE1")
				EndIf
				
				RestArea(_aAreaSE12)
				QUESE1->(dbSkip())
				
			EndDo
			
			_cNat := NatAnt
			
			_aAreaSE2QUE := GetArea()
			
			DbSelectArea("PED")
			DBGOTOP()
			Do While ! eof()
				If  RTRIM(PED->PD_NATUR) <> Rtrim(_cNat)
					dbSkip()
					Loop
				EndIf
				
				//				if PED->PD_NATUR == SED->ED_CODIGO
				Do Case
					Case Month(PED->PD_DATPRF) <= Mes1
						wForMes1 +=  PED->PD_TOTAL
						wForaMes1 += PED->PD_TOTAL
						wVlrTPed1 += PED->PD_TOTAL
					Case Month(PED->PD_DATPRF) == Mes2
						wForMes2 +=  PED->PD_TOTAL
						wForaMes2 += PED->PD_TOTAL
						wVlrTPed2 += PED->PD_TOTAL
					Case Month(PED->PD_DATPRF) == Mes3
						wForMes3 += PED->PD_TOTAL
						wForaMes3 += PED->PD_TOTAL
						wVlrTPed3 += PED->PD_TOTAL
				EndCase
				//				Endif
				DbSelectArea("PED")
				DbSkip()
				//	_cNat := RTRIM(PD_NATUR)
			Enddo
			
			@ li,000 PSay NatAnt
			@ li,008 PSay "|"
			@ li,009 PSay Left(GetAdvFVal("SED","ED_DESCRIC",xFilial("SED")+NatAnt,1),23)
			//			@ li,007 PSay  int(EmiNatAcu)    PICTURE "@e 9999,999,999"
			//        @ li,020 PSay  int(EmiNatPer)    PICTURE "@e 9999,999,999"
			@ li,033 PSay "|"
			@ li,034 PSay  int(BxaNatAcu)*-1    PICTURE "@e 9999,999,999"
			@ li,047 PSay "|"
			@ li,048 PSay  int(BxaNatPer)*-1    PICTURE "@e 9999,999,999"
			
			@ li,062 PSay "|"    //AQUI
			@ li,063 PSay  int(AbeNatAcu)*-1    PICTURE "@e 9999,999,999"
			@ li,075 PSay "|"    //AQUI
			@ li,077 PSay  int(AbeNatAcu2)*-1   PICTURE "@e 9999,999,999"
			@ li,090 PSay "|"
			@ li,091 PSay  int(wTotMes1)*-1     PICTURE "@e 999,999,999"
			@ li,104 PSay "|"
			@ li,105 PSay  int(wTotMes2)*-1     PICTURE "@e 999,999,999"
			@ li,118 PSay "|"
			@ li,119 PSay  int(wTotMes3)*-1     PICTURE "@e 999,999,999"
			@ li,132 PSay "|"
			@ li,133 PSay  int(wTotPost)*-1     PICTURE "@e 9999,999,999"
			@ li,147 PSay "|"
			@ li,148 PSay  int(wForMes1)*-1     PICTURE "@e 9999,999,999"
			@ li,161 PSay "|"
			@ li,162 PSay  int(wForMes2)*-1     PICTURE "@e 9999,999,999"
			@ li,175 PSay "|"
			@ li,176 PSay  int(wForMes3)*-1     PICTURE "@e 9999,999,999"
			@ li,189 PSay "|"
			
			wAcum:= (BxaNatAcu + BxaNatPer + AbeNatAcu + AbeNatAcu2)
			wAcum:= wAcum + ((wForMes1*-1) + (wForMes2*-1) + (wForMes3*-1))
			wtotv:=wtotv + wtotven
			wTotSa += wTotSaU
			
			wForMes1 :=  0
			wForaMes1 := 0
			wVlrTPed1 := 0
			wForMes2 :=  0
			wForaMes2 := 0
			wVlrTPed2 := 0
			wForMes3 := 0
			wForaMes3 :=0
			wVlrTPed3 :=0
			
			
			@ li,190 PSay  int(wAcum)*-1        PICTURE "@e 99999,999,999"
			@ li,204 PSay "|"
			
			wTotOrc := 0
			
			If !_lFez
				
				wOP := QUESE1->E1_XOP
				
				DbSelectArea("SZA") //left(SA9->A9_TECNICO,3)
				DbSetOrder(3)
				If DbSeek(xFilial("SZA") + NatAnt + wOP)
					@ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
					wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
					_lFez := .T.
				Else
					DbSetOrder(1)
					If DbSeek(xFilial("SZA")+ wOP + NatAnt)
						@ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
						wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
					Else
						@ li,205 PSay 0              PICTURE "@e 99999,999,999"
						_lFez := .T.
					EndIf
				EndIf
			Else
				@ li,205 PSay 0              PICTURE "@e 99999,999,999"
			EndIf
			
			@ li,219 PSay "|"
			
			li:=li+1
			
			RestArea(_aAreaSE2QUE)
			_nRecRes1 += BxaNatAcu
			_nRecRes2 += BxaNatPer
			_nRecRes3 += AbeNatAcu
			_nRecRes4 += abenatacu2
			_nRecRes5 += wTotMes1
			_nRecRes6 += wTotMes2
			_nRecRes7 += wTotMes3
			_nRecRes8 += wTotpost
			_nRecRes9 += (wForMes1*-1)
			_nRecResA += (wForMes2*-1)
			_nRecResB += (wForMes3*-1)
			_nRecResC += wacum
			
			wwTotOrc += wTotOrc
			wBxaNatAcu +=BxaNatAcu
			wBxaNatPer+= BxaNatPer
			wNat+= AbeNatAcu
			wAbeNatAcu2+= abenatacu2
			wwTotMes1+= wTotMes1
			wwTotMes2+= wtotmes2
			wwTotMes3+= wTotMes3
			wwTotPost+= wtotpost
			wwForMes1+= (wForMes1*-1)
			wwForMes2+= (wForMes2*-1)
			wwForMes3+= (wForMes3*-1)
			wwAcum   += wacum
			
			wVlrBxA   := wVlrBxA + BxaNatACU
			wVlrBxM   := wVlrBxM + BxaNatPER
			wTotBxA   := wTotBxA + BxaNatACU
			wTotBxM   := wTotBxM + BxaNatPER
			wacum1:= wacum1 + wAcum
			
			
			RestArea(_aAreaSE11)
			//		dbSkip()
			BxaNatAcu:=BxaNatPer:= AbeNatAcu := abenatacu2 := 0
			wTotMes1 := wTotMes2:= wTotMes3 := 0
			wtotpost := 0
			wForMes1 := wForMes2 := wForMes3:= wacum := 0
			wtotven := 0
			wTotSaU := 0
			
			///////////////////
		EndDo
		
	EndDo
	
	@ li,000 PSay repl("-",220)
	li:=li+1
	
	@ li,000 PSay "T R" // Left(SED->ED_CODIGO,5)
	@ li,007 PSay "|"
	//@ li,007 PSay int(wEmiNatAcu)          PICTURE "@e 9999,999,999"
	//@ li,020 PSay int(wEmiNatPer)          PICTURE "@e 9999,999,999"
	@ li,032 PSay "|"
	@ li,033 PSay int(wBxaNatAcu)*-1          PICTURE "@e 9999,999,999"
	@ li,046 PSay "|"
	@ li,047 PSay  int(wBxaNatPer)*-1      PICTURE "@e 9999,999,999"
	@ li,061 PSay "|"    //AQUI
	@ li,062 PSay  int(wNat)*-1            PICTURE "@e 9999,999,999"
	@ li,074 PSay "|"    //AQUI
	@ li,076 PSay  int(wAbeNatAcu2)*-1     PICTURE "@e 9999,999,999"
	@ li,089 PSay "|"
	@ li,090 PSay  int(wwTotMes1)*-1       PICTURE "@e 999,999,999"
	@ li,103 PSay "|"
	@ li,104 PSay  int(wwTotMes2)*-1       PICTURE "@e 999,999,999"
	@ li,117 PSay "|"
	@ li,118 PSay  int(wwTotMes3)*-1       PICTURE "@e 999,999,999"
	@ li,131 PSay "|"
	@ li,132 PSay  int(wwTotPost)*-1       PICTURE "@e 9999,999,999"
	@ li,146 PSay "|"
	@ li,147 PSay  int(wwForMes1)*-1       PICTURE "@e 9999,999,999"
	@ li,160 PSay "|"
	@ li,161 PSay  int(wwForMes2)*-1       PICTURE "@e 9999,999,999"
	@ li,174 PSay "|"
	@ li,175 PSay  int(wwForMes3)*-1       PICTURE "@e 9999,999,999"
	@ li,188 PSay "|"
	@ li,189 PSay  int(wwAcum)*-1          PICTURE "@e 99999,999,999"
	@ li,203 PSay "|"
	@ li,204 PSay  int(wwTotOrc)*-1        PICTURE "@e 99999,999,999"
	@ li,218 PSay "|"
	
	li:=li+1
	@ li,000 PSay repl("-",220)
	li:=li+1
	
	nGREmiNatAcu := nGREmiNatAcu + wEmiNatAcu
	nGREmiNatPer := nGREmiNatPer + wEmiNatPer
	nGRBxaNatAcu := nGRBxaNatAcu + wBxaNatAcu
	nGRBxaNatPer := nGRBxaNatPer + wBxaNatPer
	nGRNat      := nGRNat + wNat
	nGRNatAcu2  := nGRNatAcu2 + wAbeNatAcu2
	nGRTotMes1  := nGRTotMes1 + wwTotMes1
	nGRTotMes2  := nGRTotMes2 + wwTotMes2
	nGRTotMes3  := nGRTotMes3 + wwTotMes3
	nGRTotPost  := nGRTotPost + wwTotPost
	nGRForMes1  := nGRForMes1 + wwForMes1
	nGRForMes2  := nGRForMes2 + wwForMes2
	nGRForMes3  := nGRForMes3 + wwForMes3
	nGRAcum     := nGRAcum + wwAcum
	nGRTotOrc   := nGRTotOrc + wwTotOrc
	nTotOP    := nTotOP + wwTotOrc
	
	wEmiNatAcu:=wEmiNatPer:=wBxaNatAcu:=wBxaNatPer:=wNat:=wAbeNatAcu2:=0
	wwTotMes1:=wwTotMes2:=wwTotMes3:=wwTotPost:=0
	wwForMes1:=wwForMes2:=wwForMes3:=0
	wwAcum   := 0
	wwTotOrc := 0
	
	QUESE1->(dbCloseArea())
	
	//======================================================================================================================================
	IF li != 80 //.and. houve
		// Totais G P   - WCS
		li:=li+1
		@ li,000 PSay repl("=",220)
		li:=li+1
		@ li,000 PSay "RESULTADO "
		//	@ li,006 PSay "|"
		//	@ li,007 PSay int(nGPEmiNatAcu)      PICTURE "@e 9999,999,999"
		//	@ li,020 PSay int(nGPEmiNatPer)          PICTURE "@e 9999,999,999"
		@ li,032 PSay "|"
		@ li,033 PSay int((_nRecRes1*-1)-(_nPagRes1*-1))  PICTURE "@e 9999,999,999"
		@ li,046 PSay "|"
		@ li,047 PSay int((_nRecRes2*-1)-(_nPagRes2*-1))         PICTURE "@e 9999,999,999"
		@ li,061 PSay "|"    //AQUI
		@ li,062 PSay int((_nRecRes3*-1)-(_nPagRes3*-1))    PICTURE "@e 9999,999,999"
		@ li,074 PSay "|"    //AQUI
		@ li,076 PSay int((_nRecRes4*-1)-(_nPagRes4*-1))   PICTURE "@e 9999,999,999"
		@ li,089 PSay  "|"
		@ li,090 PSay int((_nRecRes5*-1)-(_nPagRes5*-1))     PICTURE "@e 999,999,999"
		@ li,103 PSay "|"
		@ li,104 PSay int((_nRecRes6*-1)-(_nPagRes6*-1))     PICTURE "@e 999,999,999"
		@ li,117 PSay "|"
		@ li,118 PSay int((_nRecRes7*-1)-(_nPagRes7*-1))     PICTURE "@e 999,999,999"
		@ li,131 PSay "|"
		@ li,132 PSay int((_nRecRes8*-1)-(_nPagRes8*-1))     PICTURE "@e 9999,999,999"
		@ li,146 PSay "|"
		@ li,147 PSay int((_nRecRes9*-1)-(_nPagRes9*-1))    PICTURE "@e 9999,999,999"
		@ li,160 PSay "|"
		@ li,161 PSay int((_nRecResA*-1)-(_nPagResA*-1))    PICTURE "@e 9999,999,999"
		@ li,174 PSay "|"
		@ li,175 PSay int((_nRecResB*-1)-(_nPagResB*-1))     PICTURE "@e 9999,999,999"
		@ li,188 PSay "|"
		@ li,189 PSay int((_nRecResC*-1)-(_nPagResC*-1))        PICTURE "@e 99999,999,999"
		@ li,203 PSay "|"
		@ li,204 PSay 0 PICTURE "@e 99999,999,999"
		@ li,218 PSay "|"
		li:=li+1
		@ li,000 PSay repl("=",220)
		li:=li+1
		
		// Totais G R   - WCS
		/*/
		@ li,000 PSay "G R"
		@ li,006 PSay "|"
		//	@ li,007 PSay int(nGREmiNatAcu)      PICTURE "@e 9999,999,999"
		//	@ li,020 PSay int(nGREmiNatPer)          PICTURE "@e 9999,999,999"
		@ li,032 PSay "|"
		@ li,033 PSay int(nGRBxaNatAcu)          PICTURE "@e 9999,999,999"
		@ li,046 PSay "|"
		@ li,047 PSay int(nGRBxaNatPer)          PICTURE "@e 9999,999,999"
		@ li,061 PSay "|"    //AQUI
		@ li,062 PSay int(nGRNat)    PICTURE "@e 9999,999,999"
		@ li,074 PSay "|"    //AQUI
		@ li,076 PSay int(nGRNatAcu2)   PICTURE "@e 9999,999,999"
		@ li,089 PSay  "|"
		@ li,090 PSay int(nGRTotMes1)     PICTURE "@e 999,999,999"
		@ li,103 PSay "|"
		@ li,104 PSay int(nGRTotMes2)     PICTURE "@e 999,999,999"
		@ li,117 PSay "|"
		@ li,118 PSay int(nGRTotMes3)     PICTURE "@e 999,999,999"
		@ li,131 PSay "|"
		@ li,132 PSay int(nGRTotPost)     PICTURE "@e 9999,999,999"
		@ li,146 PSay "|"
		@ li,147 PSay int(nGRForMes1)     PICTURE "@e 9999,999,999"
		@ li,160 PSay "|"
		@ li,161 PSay int(nGRForMes2)     PICTURE "@e 9999,999,999"
		@ li,174 PSay "|"
		@ li,175 PSay int(nGRForMes3)     PICTURE "@e 9999,999,999"
		@ li,188 PSay "|"
		@ li,189 PSay int(nGRAcum)        PICTURE "@e 99999,999,999"
		@ li,203 PSay "|"
		@ li,204 PSay int(nGRTotOrc) PICTURE "@e 99999,999,999"
		@ li,218 PSay "|"
		/*/
		
		/*/
		@ li,000 PSay "Geral:"
		//	@ li,006 PSay "|"
		//	@ li,008 PSay int(EmiTotAcu)          PICTURE "@e 999,999,999"
		//	@ li,020 PSay int(EmiTotPer)          PICTURE "@e 9999,999,999"
		@ li,032 PSay "|"
		@ li,033 PSay int(wTotBxA)            PICTURE "@e 9999,999,999"
		@ li,046 PSay "|"
		@ li,047 PSay int(wTotBxM)            PICTURE "@e 9999,999,999"
		@ li,061 PSay "|"
		@ li,062 PSay int(wtotv)              PICTURE "@e 9999,999,999"
		@ li,074 PSay "|"    //AQUI
		@ li,076 PSay int(wTotSa)            PICTURE "@e 9999,999,999"
		@ li,089 PSay "|"
		@ li,090 PSay int(wVlrTMes1)     PICTURE "@e 999,999,999"
		@ li,103 PSay "|"
		@ li,104 PSay int(wVlrTMes2)     PICTURE "@e 999,999,999"
		@ li,117 PSay "|"
		@ li,118 PSay int(wVlrTMes3)     PICTURE "@e 999,999,999"
		@ li,131 PSay "|"
		@ li,132 PSay int(wVlrTPost)     PICTURE "@e 9999,999,999"
		@ li,146 PSay "|"
		@ li,147 PSay int(wVlrTPed1)     PICTURE "@e 9999,999,999"
		@ li,160 PSay "|"
		@ li,161 PSay int(wVlrTPed2)     PICTURE "@e 9999,999,999"
		@ li,174 PSay "|"
		@ li,175 PSay int(wVlrTPed3)     PICTURE "@e 9999,999,999"
		@ li,188 PSay "|"
		@ li,190 PSay int(wAcum1)        PICTURE "@e 9999,999,999"
		@ li,203 PSay "|"
		@ li,204 PSay int(nGRTotOrc)+int(nGPTotOrc)   PICTURE "@e 99999,999,999"
		@ li,218 PSay "|"
		/*/
		
		li++
		@ li,000 PSay repl("-",220)
		li:=li+1
		@ li,000 PSAY "NOTA FISCAL DE SAIDA ->" /////PSay repl("-",220)
		
		_cQuery := "SELECT SUM(D2_TOTAL) D2_TOTAL,D2_DOC,D2_EMISSAO,D2_PEDIDO FROM "+RetSqlName("SD2")+" SD2 "
		_cQuery += "WHERE SD2.D_E_L_E_T_ = ' ' AND D2_FILIAL = '"+xFilial("SD2")+"' "
		_cQuery += "AND D2_PEDIDO BETWEEN '"+Left(mv_par05,5)+"' AND '"+Left(mv_par06,5)+"' "
		_cQuery += "GROUP BY D2_DOC,D2_EMISSAO,D2_PEDIDO "
		
		If Select("QUESD2") > 0
			dbCloseArea()
		EndIf
		
		TCQUERY _cQuery NEW ALIAS "QUESD2"
		
		While !Eof()
			
			@ li,000 PSAY "NOTA FISCAL DE SAIDA -> " /////PSay repl("-",220)
			@ li,032 PSay "|"
			@ li,035 PSAY QUESD2->D2_DOC
			@ li,046 PSay "|"
			@ li,050 PSAY DTOC(STOD(QUESD2->D2_EMISSAO))
			@ li,061 PSay "|"
			@ li,062 PSAY Transform(QUESD2->D2_TOTAL,"@e 9,999,999.99")
			@ li,074 PSay "|"
			li++
			
			QUESD2->(dbSkip())
			
		EndDo
		
		QUESD2->(dbCloseArea())
		
		li++
		@ li,000 PSay repl("-",220)
		li:=li+1
		@ li,000 PSay "Movimentos internos:            |    Valor    |   Quantidade |  "
		li:=li+1
		@ li,000 PSay repl("-",220)
		li:=li+1
		
		_cQuery := " SELECT SUM(D3_CUSTO1) D3_CUSTO1,SUM(D3_QUANT) D3_QUANT,LEFT(D3_CF,2) D3_CF,LEFT(D3_OP,5) D3_OP FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) "
		_cQuery += " WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"' "
		_cQuery += " AND LEFT(D3_OP,5) BETWEEN '"+Left(mv_par05,5)+"' AND '"+Left(mv_par06,5)+"' "
		_cQuery += " AND LEFT(D3_CF,2) IN ('RE','DE') "
		_cQuery += " GROUP BY D3_FILIAL,LEFT(D3_CF,2),LEFT(D3_OP,5) "
		_cQuery += " ORDER BY LEFT(D3_CF,2) DESC "
		
		
		If Select("QUESD3") > 0
			dbCloseArea()
		EndIf
		
		TCQUERY _cQuery NEW ALIAS "QUESD3"
		
		While !Eof()
			
			@ li,008 PSay QUESD3->D3_CF
			@ li,032 PSay "|"
			
			If LEFT(QUESD3->D3_CF,2) == "RE"
				_nCustoRE := QUESD3->D3_CUSTO1                               '
				_nQuantRE := QUESD3->D3_QUANT
			Else
				_nCustoDE := QUESD3->D3_CUSTO1
				_nQuantDE := QUESD3->D3_QUANT
			EndIf
			
			@ li,033 PSay Int(QUESD3->D3_CUSTO1) PICTURE "@e 99999,999,99"
			@ li,046 PSay "|"
			@ li,047 PSay Int(QUESD3->D3_QUANT) PICTURE "@e 99999,999,999"
			@ li,061 PSay "|"    //AQUI
			li++
			
			QUESD3->(dbSkip())
		EndDo
		
		@ li,000 PSay repl("-",220)
		li++
		_nCustoRE := int( _nCustoRE - _nCustoDE )
		_nQuantRE := int( _nQuantRE - _nQuantDE )
		
		@ li,000 PSay " (RE - DE ) TOTAL ----------> "
		@ li,032 PSay "|"
		@ li,033 PSay Transform(_nCustoRE,"@e 99999,999,99")
		@ li,046 PSay "|"
		@ li,047 PSay Transform(_nQuantRE,"@e 99999,999,999")
		@ li,061 PSay "|"
		li++
		@ li,000 PSay repl("-",220)
		
		dbSelectArea("QUESD3")
		dbCloseArea()
		
		Roda(nCntImpr,cRodaTxt,Tamanho)
	EndIF
	                  
	RestArea(_aAreaSC2)
	QUESC2->(dbSkip())

EndDo
                     
dbSelectArea("QUESC2")
dbCloseArea("QUESC2")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Devolve as ordens originais do arquivo                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Ferase(cNomArq1+GetdbExtension())
Ferase(cNomArq2+GetdbExtension())
Ferase(cNomArq1+OrdBagExt())
Ferase(cNomArq2+OrdBagExt())

RetIndex("SE2")
Set Filter to
RetIndex("SE1")
Set Filter to
RetIndex("SC7")
Set Filter to

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga indice e arquivo temporario de trabalho                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("PED")
DbCloseArea()

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()
