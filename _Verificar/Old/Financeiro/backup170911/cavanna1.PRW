#include "rwmake.ch" 
#include "protdef.ch" 
User Function cavanna1()	//QUALI18()        // incluido pelo assistente de conversao do AP6 IDE em 09/01/04

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CPERG,TITULO,CDESC1,CDESC2,CDESC3,CSTRING")                              
SetPrvt("AORD,WNREL,ARETURN,NLASTKEY,TAMANHO,NTIPO")
SetPrvt("CRODATXT,NCNTIMPR,CQUEBRA,CCOND,CNOMARQ,LI")
SetPrvt("M_PAG,AMESES,MES1,MES2,MES3,CMESES")
SetPrvt("CABEC1,CABEC2,CNOMARQ2,WVLRBXA,WTOTBXA,WVLRBXM")
SetPrvt("WTOTBXM,WVLRSAU,WTOTSAU,WVLRTMES1,WVLRTMES2,WVLRTMES3")
SetPrvt("WVLRTPOST,WVLRTPED1,WVLRTPED2,WVLRTPED3,WTOTVEN,WTOTAVEN")
SetPrvt("WTOTAMES1,WTOTMES2,WTOTMES3,WTOTAPOST,EMIOBRACU,EMIOBRPER")
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
SetPrvt("NGRTOTORC,ACAMPOS,CTRAB,CIND,WNATUREZA,NOBRA")
SetPrvt("NTOTOBRA,NATANT,EMINATPER,BXANATACU,BXANATPER,ABENATACU")
SetPrvt("ABENATACU2,NVALDESACU,NVALDESPER,WTOTAMES2,WTOTAMES3,WOBRA")
SetPrvt("WACUM,")
WNATUREZA := " "
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QUALI18  ³ Autor ³Wilson Ascencio        ³ Data ³ 14/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de Acompanhamento dos Pgtos.e Recebimentos       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
cPerg := "MAPS19"		//QUAL180000"

DbSelectArea("SX1") 

cPerg := Padr(cPerg,10)

/*If ! ( SX1->(DbSeek(cPerg+"01")) )
   Reclock("SX1",.t.)
   SX1->X1_GRUPO   := cPerg
   SX1->X1_ORDEM   := "01"
   SX1->X1_PERGUNT := "Periodo Baixas. De :"
   SX1->X1_VARIAVL := "mv_ch1"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO := 8
   SX1->X1_DECIMAL := 0
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := ""
   SX1->X1_VAR01   := "mv_par01"
   SX1->X1_DEF01   := ""
EndIf

If ! ( SX1->(DbSeek(cPerg+"02")) )
   Reclock("SX1",.t.)
   SX1->X1_GRUPO   := cPerg
   SX1->X1_ORDEM   := "02"
   SX1->X1_PERGUNT := "Periodo Baixas. Ate:"
   SX1->X1_VARIAVL := "mv_ch2"
   SX1->X1_TIPO    := "D"
   SX1->X1_TAMANHO := 8
   SX1->X1_DECIMAL := 0
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := ""
   SX1->X1_VAR01   := "mv_par02"
   SX1->X1_DEF01   := ""
EndIf

If ! ( SX1->(DbSeek(cPerg+"03")) )
   Reclock("SX1",.t.)
   SX1->X1_GRUPO   := cPerg
   SX1->X1_ORDEM   := "03"
   SX1->X1_PERGUNT := "Da Natureza ........"
   SX1->X1_VARIAVL := "mv_ch3"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := 10
   SX1->X1_DECIMAL := 0
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := ""
   SX1->X1_VAR01   := "mv_par03"
   SX1->X1_DEF01   := ""
EndIf

If ! ( SX1->(DbSeek(cPerg+"04")) )
   Reclock("SX1",.t.)
   SX1->X1_GRUPO   := cPerg
   SX1->X1_ORDEM   := "04"
   SX1->X1_PERGUNT := "Ate a Natureza ....."
   SX1->X1_VARIAVL := "mv_ch4"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := 10
   SX1->X1_DECIMAL := 0
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := ""
   SX1->X1_VAR01   := "mv_par04"
   SX1->X1_DEF01   := ""
EndIf

If ! ( SX1->(DbSeek(cPerg+"05")) )
   Reclock("SX1",.t.)
   SX1->X1_GRUPO   := cPerg
   SX1->X1_ORDEM   := "05"
   SX1->X1_PERGUNT := "Da Obra ............"
   SX1->X1_VARIAVL := "mv_ch5"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := 5
   SX1->X1_DECIMAL := 0
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := ""
   SX1->X1_VAR01   := "mv_par05"
   SX1->X1_DEF01   := ""
EndIf

If ! ( SX1->(DbSeek(cPerg+"06")) )
   Reclock("SX1",.t.)
   SX1->X1_GRUPO   := cPerg
   SX1->X1_ORDEM   := "06"
   SX1->X1_PERGUNT := "Ate a Obra ........."
   SX1->X1_VARIAVL := "mv_ch6"
   SX1->X1_TIPO    := "C"
   SX1->X1_TAMANHO := 5
   SX1->X1_DECIMAL := 0
   SX1->X1_PRESEL  := 0
   SX1->X1_GSC     := "G"
   SX1->X1_VALID   := ""
   SX1->X1_VAR01   := "mv_par06"
   SX1->X1_DEF01   := ""
EndIf

If ! ( SX1->(DbSeek(cPerg+"07")) )
	Reclock("SX1",.t.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "07"
	SX1->X1_PERGUNT := "Data Base .........."
	SX1->X1_VARIAVL := "mv_ch7"
	SX1->X1_TIPO    := "D"
	SX1->X1_TAMANHO := 8
	SX1->X1_DECIMAL := 0
	SX1->X1_PRESEL  := 0
	SX1->X1_GSC     := "G"
	SX1->X1_VALID   := ""
	SX1->X1_VAR01   := "mv_par07"
	SX1->X1_DEF01   := ""
EndIf

/*If ! ( SX1->(DbSeek(cPerg+"08")) )
	Reclock("SX1",.t.)
	SX1->X1_GRUPO   := cPerg
	SX1->X1_ORDEM   := "08"
	SX1->X1_PERGUNT := "Somente c/ Movimento"
	SX1->X1_VARIAVL := "mv_ch8"
	SX1->X1_TIPO    := "C"
	SX1->X1_TAMANHO := 1
	SX1->X1_DECIMAL := 0
	SX1->X1_PRESEL  := 2
	SX1->X1_GSC     := "C"
	SX1->X1_VALID   := ""
	SX1->X1_VAR01   := "mv_par08"
	SX1->X1_DEF01   := "Sim"
	SX1->X1_DEF02   := "Nao" 
	//SX1->X1_HELP    := "Sim - Imprime somente quando houver obra" 
EndIf*/
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis obrigatorias dos programas de relatorio            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
titulo		   	:= "Relatorio de Acompanhamento Financeiro - Analitico"
cDesc1		:= "Relatorio desenvolvido em RdMake exclusivo para Cavanna"
cDesc2   	:= "Exibe os titulos pagos/recebidos no periodo desejado,alem"
cDesc3   	:= "da carteira em aberto e os valores acumulados."
cString  	:= "SE2"
aOrd     	:= {}
wnrel    		:= "Cavanna1"		//QUALI18"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis padrao de todos os relatorios                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aReturn:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nLastKey:= 0
cPerg := "MAPS19"	//	QUAL180000"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

RptStatus({|| C885Imp()})



Static FUNCTION C885Imp()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C885IMP  ³       ³                       ³      ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis locais exclusivas deste programa                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Tamanho  := "G"
nTipo    := 0
cRodaTxt := "REGISTRO(S)"
nCntImpr := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas na totalizacao do relatorio             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuebra		:=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao de Filtragem do SE2                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCond := 'E2_FILIAL=="'+xFilial("SE2")+'".And.'
cCond :=cCond+ 'E2_NATUREZ>="'+mv_par03+'".And.E2_NATUREZ<="'+mv_par04+'".And.'
//cCond :=cCond+ 'E2_XCC>="'+mv_par05+'".And.E2_XCC<="'+mv_par06+'"'
cCond :=cCond+ 'E2_ITEMD>="'+mv_par05+'".And.E2_ITEMD<="'+mv_par06+'"'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq := CriaTrab("",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE2")
//IndRegua("SE2",cNomArq,"E2_FILIAL+E2_XCC+E2_NATUREZ+DTOS(E2_VENCREA)",,cCond,"Selecionando Registros...")
IndRegua("SE2",cNomArq,"E2_FILIAL+E2_ITEMD+E2_NATUREZ+DTOS(E2_VENCREA)",,cCond,"Selecionando Registros...")
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para controlar cursor de progressao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(LastRec())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTipo  := IIF(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contadores de linha e pagina                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
li := 80
m_pag := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o cabecalho.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

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

                                                                                                                                                                                              
cabec1 := "COMANDA |-- COMPRAS/FATURAMENTO ---|-- PAGAMENTOS/RECEBIMENTOS -|------- EM ABERTO ---------|------------------ A VENCER DESMEMBRADO ----------------|"
cabec1 := cabec1 + "------ COMPRAS EM ABERTO + PREVISAO -----|   ACUMULADO  |     TOTAL    |"
cabec2 := "NATUR.|    ACUMULADO   NO PERIODO|    ACUMULADO    NO PERIODO | VENCIDO          A VENCER |" + CMESES + "MESES POSTER.|"
cabec2 := cabec2 + CMESES + "    TOTAL    |    ORCADO    |"

cString:="SE1"
aOrd   :={}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao de Filtragem do SE1                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCond := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
cCond :=cCond+ 'E1_NATUREZ>="'+mv_par03+'".And.E1_NATUREZ<="'+mv_par04+'".And.'
//cCond :=cCond+ 'E1_XCC>="'+mv_par05+'".And.E1_XCC<="'+mv_par06+'"'
cCond :=cCond+ 'E1_ITEMD>="'+mv_par05+'".And.E1_ITEMD<="'+mv_par06+'"'


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq2 := CriaTrab("",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE1")
//IndRegua("SE1",cNomArq2,"E1_FILIAL+E1_XCC+E1_NATUREZ+DTOS(E1_VENCREA)",,cCond,"Selecionando Registros...")
IndRegua("SE1",cNomArq2,"E1_FILIAL+E1_ITEMD+E1_NATUREZ+DTOS(E1_VENCREA)",,cCond,"Selecionando Registros...")
dbGoTop()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis para controlar cursor de progressao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(LastRec())

dbSelectArea("SE2")
wVlrBxA:=wTotBxA:=0
wVlrBxM:=wTotBxM:=0
wVlrSaU:=wTotSaU:=0
wVlrTMes1:=wVlrTMes2:=wVlrTMes3:=wVlrTPost:=0
wVlrTPed1:=wVlrTPed2:=wVlrTPed3:=0
wTotVen:=wTotaVen:= wTotaMes1:=wTotMes2:=wTotMes3:=wTotaPost:=0  // totais vencidos e a vencer
EmiObrAcu:=EmiObrPer:=0
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

houve  :=.f.
dbSelectArea("SA9")
DbGoTop()

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


titulo:= "Relatorio de Acompanhamento Financeiro" + " Periodo de " +;
         dtoc(mv_par01) + " ate " + dtoc(mv_par02)


//Cria arquivo temporario para  o arquivo de pedidos de compras
//

aCampos := {  {"PD_PEDIDO"  ,"C",06,0 } ,;
              {"PD_ITEM"    ,"C",02,0 } ,;
              {"PD_OBRA"    ,"C",09,0 } ,;
              {"PD_TOTAL"   ,"N",14,2 } ,;
              {"PD_DATPRF"   ,"D",08,0 } ,;
              {"PD_NATUR"   ,"C",10,0 } }
                    
cTrab  := CriaTrab(aCampos,.T.)
//cInd   := "PD_OBRA + PD_PEDIDO + PD_ITEM"  MHD
cInd   := "PD_ITEM + PD_PEDIDO + PD_OBRA"  
DbUseArea(.T.,,cTrab,"PED",.F.,.F.)
IndRegua("PED",cTrab,cInd,,,"Selecionando Pedidos de Compras...")

dbSelectArea("SC7")
DbSetOrder(1)
DbGoTop()
SetRegua(LastRec()) 
//dbSeek(xFilial("SC7")+DTOS(mv_par01))
Do While ! eof()
   if SC7->C7_ENCER == "E"
      DbSkip()
      loop
   endif
   if SC7->C7_DATPRF <= mv_par02
      DbSkip()
      loop
   endif

   //if SC7->C7_CC < mv_par05 .or. SC7->C7_CC > mv_par06
   if SC7->C7_ITEMCTA < mv_par05 .or. SC7->C7_ITEMCTA > mv_par06
      DbSkip()
      loop
   Endif         
  
	if SC7->C7_EMISSAO > mv_par07
    	DbSkip()
	    loop
	Endif                                                     
	
	dbSelectArea("SA2")  //INCLUIDO MHD
	DbSetOrder(1)        
	DbSeek(xfilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial() + SC7->C7_PRODUTO)

   DbSelectArea("PED")
   RecLock("PED",.t.)
   REPLACE PD_PEDIDO  WITH SC7->C7_NUM
   REPLACE PD_ITEM    WITH SC7->C7_ITEM
   REPLACE PD_OBRA    WITH SC7->C7_ITEMCTA
   REPLACE PD_TOTAL   WITH SC7->C7_TOTAL
   REPLACE PD_DATPRF  WITH SC7->C7_DATPRF
   REPLACE PD_NATUR   WITH SA2->A2_NATUREZ    //SB1->B1_NATUREZ MHD
   MsUnlock()
   DbCommit()
   DbSelectArea("SC7")
   DbSetOrder(1)
   DbSkip()
   IncRegua()
Enddo


/*DbSelectArea("AF8")
dbSetOrder(08)			//  CODOBR               

If Empty(mv_par05)
	dbSeek(xFIlial("AF8")+"0")
Else
	dbSeek(xFIlial("AF8")+mv_par05)
EndIf
*/
//MHD  
DbSelectArea("CTD")
dbSetOrder(01)			//  CODOBR               

If Empty(mv_par05)
	dbgotop()
Else
	dbSeek(xFIlial("CTD")+mv_par05)
EndIf

//Do While !Eof() .And. AF8->AF8_CODOBR <= mv_par06
//   cQuebra 	:= SUBSTR(AF8->AF8_CODOBR,1,9)
//   nObra   	:= AF8->AF8_DESCRI
//   nTotObra := 0
   
Do While !Eof() .And. CTD->CTD_ITEM <= mv_par06
   cQuebra := CTD->CTD_ITEM
   nObra   	:= CTD->CTD_DESC01
   nTotObra := 0
     
   DbSelectArea("SE2")
   If DbSeek(xFilial("SE2")+cQuebra,.F.)
     titulo:= "Relatorio de Acompanhamento Financeiro" +;
     " Periodo de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
     If li > 58 .OR. houve==.f.
        cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
        li := li-1
     EndIf      
     houve:=.t.

     li := li+1
     @ li,000 PSay cQuebra + " " + nObra
     li := li+1
     @ li,000 PSay repl("_",220)
     li := li+1

     While !Eof() .And. E2_ITEMD == cQuebra//==
       NatAnt := E2_NATUREZ
       EmiNatAcu:=0
       EmiNatPer:=0
       BxaNatAcu:=0
       BxaNatPer:=0
       AbeNatAcu:=0
       AbeNatAcu2:=0

       //While !Eof() .And. E2_XCC == cQuebra .AND. E2_NATUREZ == NatAnt //==
       While !Eof() .And. E2_ITEMD == cQuebra .AND. E2_NATUREZ == NatAnt //==
          If (DTOS(E2_emissao)>DTOS(mv_par07))
             DBSKIP()
             LOOP
          Endif

          If (DTOS(E2_emissao)<=DTOS(mv_par02))

                IncRegua()
        		If li > 58
		        	cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
                    li := li-1
                EndIf

                //Realizando tratamento sobre arquivo de Baixas (SE5) para DESCONTOS (E5_TIPODOC=DC)
                nValDesAcu :=0
                nValDesPer :=0
                DbSelectArea("SE5")
                DbSetOrder(7)
                DbGotop()
                If DbSeek(xFilial()+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
                   Do While !EOF() .AND. SE5->E5_PREFIXO == SE2->E2_PREFIXO .AND.;
                         SE5->E5_NUMERO  == SE2->E2_NUM .AND.;
                         SE5->E5_PARCELA == SE2->E2_PARCELA .AND.;
                         SE5->E5_TIPO    == SE2->E2_TIPO 

                         IF SE5->E5_CLIFOR != SE2->E2_FORNECE
                            DBSKIP()
                            LOOP
                         ENDIF

                         IF SE5->E5_SITUACA == "C"
                            DBSKIP()
                            LOOP
                         ENDIF
                         
                         If (DTOS(E5_DATA)>DTOS(mv_par07))
                            DBSKIP()
                            LOOP
                         Endif
             
                                                     
//                         If (DTOS(E5_DATA)<DTOS(mv_par01))    //Valores Acumulados
//                            IF E5_TIPODOC $ "VL/BA/V2/CP/LJ"
//                               BxaNatAcu := BxaNatAcu - E5_VALOR
//                            ELSEIF E5_TIPODOC $ "ES"
//                               BxaNatAcu := BxaNatAcu + E5_VALOR
//                            ENDIF
//                         Else
//                            If (DTOS(E5_DATA)<=DTOS(mv_par02))  //Valores no Periodo
//                               IF E5_TIPODOC $ "VL/BA/V2/CP/LJ"
//                                  BxaNatPER := BxaNatPER - E5_VALOR
//                               ELSEIF E5_TIPODOC $ "ES"
//                                  BxaNatPER := BxaNatPER + E5_VALOR
//                               ENDIF
//                          Else                               //Valores a Vencer
//                               AbeNatAcu2 := AbeNatAcu2 - E5_VALOR
//                               wTotaVen   := wTotaVen - E5_VALOR
//                            EndIf
//                         Endif
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

                   DbSelectArea("SE2")
                   If (DTOS(E2_EMISSAO)<DTOS(mv_par01))
                      EmiNatAcu := EmiNatAcu - ((E2_VALOR-E2_SALDO)+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_VALJUR-SE2->E2_DESCONT) //(E2_SALDO + E2_VALLIQ)
                      EmiObrAcu := EmiObrAcu - ((E2_VALOR-E2_SALDO)+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_VALJUR-SE2->E2_DESCONT) //(E2_SALDO + E2_VALLIQ)
                      EmiTotAcu := EmiTotAcu - ((E2_VALOR-E2_SALDO)+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_VALJUR-SE2->E2_DESCONT) //(E2_SALDO + E2_VALLIQ)
                   Else
                       EmiNatPer := EmiNatPer - ((E2_VALOR-E2_SALDO)+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_VALJUR-SE2->E2_DESCONT)//(E2_SALDO + E2_VALLIQ)
                       EmiObrPer := EmiObrPer - ((E2_VALOR-E2_SALDO)+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_VALJUR-SE2->E2_DESCONT)//(E2_SALDO + E2_VALLIQ)
                       EmiTotPer := EmiTotPer - ((E2_VALOR-E2_SALDO)+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_VALJUR-SE2->E2_DESCONT)//(E2_SALDO + E2_VALLIQ)
                   Endif

                   DbSelectArea("SE2")

                   If (DTOS(E2_VENCREA) < DTOS(mv_par02)) .and. E2_SALDO#0.00
                      AbeNatAcu := AbeNatAcu - E2_SALDO
                      wVlrSaU   := wVlrSaU - E2_SALDO
                      wTotSaU   := wTotSaU - E2_SALDO
                      wTotVen   := wTotVen - E2_SALDO
                   Else
                      If (DTOS(E2_VENCREA) >= DTOS(mv_par02))
                         AbeNatAcu2 := AbeNatAcu2 - E2_SALDO
                         wVlrSaU    := wVlrSaU - E2_SALDO
                         wTotSaU    := wTotSaU - E2_SALDO
                         wTotaVen   := wTotaVen - E2_SALDO
 
                         Do Case 
                            Case Month(E2_VENCREA) == Mes1  
                                 wTotMes1  := wTotMes1 - E2_SALDO
                                 wTotaMes1 := wTotaMes1 - E2_SALDO
                                 wVlrTMes1 := wVlrTMes1 - E2_SALDO
                            Case Month(E2_VENCREA) == Mes2
                                 wTotMes2  := wTotMes2 - E2_SALDO
                                 wTotaMes2 := wTotaMes2 - E2_SALDO
                                 wVlrTMes2 := wVlrTMes2 - E2_SALDO
                            Case Month(E2_VENCREA) == Mes3
                                 wTotMes3  := wTotMes3 - E2_SALDO
                                 wTotaMes3 := wTotaMes3 - E2_SALDO
                                 wVlrTMes3 := wVlrTMes3 - E2_SALDO
                         Otherwise
                                 wTotPost  := wTotPost - E2_SALDO
                                 wTotaPost := wTotaPost - E2_SALDO
                                 wVlrTPost := wVlrTPost - E2_SALDO
                         EndCase
                      EndIf
                   Endif

                dbSkip()
         Else
                dbSkip()
          Endif
       Enddo

       wVlrBxA   := wVlrBxA + BxaNatACU
       wVlrBxM   := wVlrBxM + BxaNatPER
       wTotBxA   := wTotBxA + BxaNatACU
       wTotBxM   := wTotBxM + BxaNatPER

       DbSelectArea("SED")
       DbSeek(xFilial()+NatAnt)

       wForMes1:=wForMes2:=wForMes3:=0

       DbSelectArea("PED")
//       wobra:= left(SA9->A9_TECNICO,3)
       wobra:= cQuebra	//left(SA9->A9_TECNICO,5)
       DbSeek(wobra)

       Do While ! eof() .and. PED->PD_OBRA == wobra  //==

          if PED->PD_NATUR == SED->ED_CODIGO
             Do Case
                Case Month(PED->PD_DATPRF) == Mes1
                   wForMes1 := wForMes1 - PED->PD_TOTAL
                   wForaMes1 := wForaMes1 - PED->PD_TOTAL
                   wVlrTPed1 := wVlrTPed1 - PED->PD_TOTAL
                Case Month(PED->PD_DATPRF) == Mes2
                   wForMes2 := wForMes2 - PED->PD_TOTAL
                   wForaMes2 := wForaMes2 - PED->PD_TOTAL
                   wVlrTPed2 := wVlrTPed2 - PED->PD_TOTAL
                Case Month(PED->PD_DATPRF) == Mes3
                   wForMes3 := wForMes3 - PED->PD_TOTAL
                   wForaMes3 := wForaMes3 - PED->PD_TOTAL
                   wVlrTPed3 := wVlrTPed3 - PED->PD_TOTAL
             EndCase
          Endif
          DbSelectArea("PED")
          DbSkip()
       Enddo

       @ li,000 PSay Left(SED->ED_CODIGO,5)
       @ li,006 PSay "|"           
       @ li,007 PSay  int(EmiNatAcu)    PICTURE "@e 9999,999,999"
       @ li,020 PSay  int(EmiNatPer)    PICTURE "@e 9999,999,999"
       @ li,033 PSay "|"
       @ li,034 PSay  int(BxaNatAcu)    PICTURE "@e 9999,999,999"
       @ li,048 PSay  int(BxaNatPer)    PICTURE "@e 9999,999,999"
       @ li,062 PSay "|"    //AQUI
       @ li,063 PSay  int(AbeNatAcu)    PICTURE "@e 9999,999,999"
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
       @ li,148 PSay  int(wForMes1)     PICTURE "@e 9999,999,999"
       @ li,161 PSay "|"
       @ li,162 PSay  int(wForMes2)     PICTURE "@e 9999,999,999"
       @ li,175 PSay "|"
       @ li,176 PSay  int(wForMes3)     PICTURE "@e 9999,999,999"
       @ li,189 PSay "|"
       wAcum:= (BxaNatAcu + BxaNatPer + AbeNatAcu + AbeNatAcu2)
       wAcum:= wAcum + (wForMes1 + wForMes2 + wForMes3)
       @ li,190 PSay  int(wAcum)        PICTURE "@e 99999,999,999"
       @ li,204 PSay "|"

       DbSelectArea("SZA")  //MHD  - CRIADO ARQUIVO PARA MANUTENÇÃO
       //If DbSeek(xFilial() + SA9->A9_TECNICO + SED->ED_CODIGO)
       If DbSeek(xFilial() + cQuebra + SED->ED_CODIGO)
          @ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
          wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
       Else
          @ li,205 PSay 0              PICTURE "@e 99999,999,999"
       EndIf
       
       @ li,219 PSay "|"
       
       wNatureza:= wNatureza + (alltrim(SED->ED_CODIGO) + "@")
              
       li:=li+1

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
        wwAcum   := wwacum + wacum
        wwTotOrc:= wwTotOrc + wTotOrc
       EmiNatAcu:=EmiNatPer:=BxaNatAcu:=BxaNatPer:=AbeNatAcu:=AbeNatAcu2:=0
       wTotMes1:=wTotMes2:=wTotMes3:=wTotPost:=0
       wForMes1:=wForMes2:=wForMes3:=wtotOrc:=0

       DbSelectArea("SE2")
    Enddo
///////////////////


	//
	// 16.11.2009
	// totaliza as remessas saidas do estoque e enviadas para obra
	//
	nTotRemessa := 0
	dbSelectArea("SD2")
	dbOrderNickName("D2OBRA")	     							// filial+ccusto
	If dbSeek(xFilial("SD2")+cQuebra,.F.)
	    //While !Eof() .And. D2_CCUSTO == cQuebra
	    While !Eof() .And. D2_ITEMCC == cQuebra

	          If (DTOS(D2_emissao) < DTOS(mv_par01))
    	         DBSKIP()
        	     LOOP
	          Endif

	          If (DTOS(D2_emissao) > DTOS(mv_par02))
    	         DBSKIP()
        	     LOOP
	          Endif

				nTotRemessa+=D2_TOTAL
				
				dbSkip()
		EndDo
		nTotRemessa := nTotRemessa*(-1)
	EndIf
	@ li,000 PSay "Estoq" 
    @ li,006 PSay "|"
       @ li,033 PSay "|"
       @ li,062 PSay "|"    //AQUI
       @ li,090 PSay "|"
       @ li,104 PSay "|"  
       @ li,118 PSay "|"
       @ li,132 PSay "|"
       @ li,147 PSay "|"
       @ li,161 PSay "|"
       @ li,175 PSay "|"
       @ li,189 PSay "|"
       @ li,190 PSay  int(nTotRemessa)          PICTURE "@e 99999,999,999"
       @ li,204 PSay "|"
       @ li,219 PSay "|"

	Li++
	wwAcum+=nTotRemessa



       @ li,000 PSay "T P" // Left(SED->ED_CODIGO,5)
       @ li,006 PSay "|"
       @ li,007 PSay  int(wEmiNatAcu)      PICTURE "@e 9999,999,999"
       @ li,020 PSay  int(wEmiNatPer)      PICTURE "@e 9999,999,999"
       @ li,033 PSay "|"
       @ li,034 PSay  int(wBxaNatAcu)      PICTURE "@e 9999,999,999"
       @ li,048 PSay  int(wBxaNatPer)      PICTURE "@e 9999,999,999"
       @ li,062 PSay "|"    //AQUI
       @ li,063 PSay  int(wNat)            PICTURE "@e 9999,999,999"
       @ li,077 PSay  int(wAbeNatAcu2)     PICTURE "@e 9999,999,999"
       @ li,090 PSay "|"
       @ li,091 PSay  int(wwTotMes1)       PICTURE "@e 999,999,999"
       @ li,104 PSay "|"  
       @ li,105 PSay  int(wwTotMes2)       PICTURE "@e 999,999,999"
       @ li,118 PSay "|"
       @ li,119 PSay  int(wwTotMes3)       PICTURE "@e 999,999,999"
       @ li,132 PSay "|"
       @ li,133 PSay  int(wwTotPost)       PICTURE "@e 9999,999,999"
       @ li,147 PSay "|"
       @ li,148 PSay  int(wwForMes1)       PICTURE "@e 9999,999,999"
       @ li,161 PSay "|"
       @ li,162 PSay  int(wwForMes2)       PICTURE "@e 9999,999,999"
       @ li,175 PSay "|"
       @ li,176 PSay  int(wwForMes3)       PICTURE "@e 9999,999,999"
       @ li,189 PSay "|"
       @ li,190 PSay  int(wwAcum)          PICTURE "@e 99999,999,999"
       @ li,204 PSay "|"
       @ li,205 PSay  int(wwTotOrc)        PICTURE "@e 99999,999,999"
       @ li,219 PSay "|"

       li:=li+1
       @ li,000 PSay repl("-",220)
       li:=li+1

///////////////////

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
       nTotObra    := nTotObra + wwTotOrc

       wEmiNatAcu:=wEmiNatPer:=wBxaNatAcu:=wBxaNatPer:=wNat:=wAbeNatAcu2:=0
       wwTotMes1:=wwTotMes2:=wwTotMes3:=wwTotPost:=0
       wwForMes1:=wwForMes2:=wwForMes3:=0
       wwAcum:=wwTotOrc:=0
   

	Else		//  para orcamento sem movimentacao
	
      DbSelectArea("SZA") // NAO TEM MHD
      If DbSeek(xFilial() + cQuebra + SED->ED_CODIGO)
          @ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
          wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
      Else
          @ li,205 PSay 0              PICTURE "@e 99999,999,999"
      EndIf
      @ li,219 PSay "|"

   Endif

   DbSelectArea("SE1")
   DbGotop()
   
   /*If MV_PAR08 = 1
         DbSelectArea("SE5")
         DbSetOrder(7)
         DbGotop()
         DbSeek(xFilial()+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
         if EOF()     
            DbSelectArea("SA9")
            DbSkip()
            Loop
         endif
   Endif*/
   
   If DbSeek(xFilial("SE1")+cQuebra,.F.) 
        If li > 58
           cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
           li := li-1
        EndIf
        IF houve==.f.
           @ li,000 PSay cQuebra + " " + nObra
           @ li,000 PSay repl("_",220)
           li := li+1
           houve:=.t.
        Endif
    //while !Eof() .And. E1_XCC == cQuebra     //==
    while !Eof() .And. E1_ITEMD == cQuebra     //==
   
/*  
         If (DTOS(E1_VENCREA)>DTOS(mv_par07))
             DBSKIP()
             LOOP
         Endif
*/
       NatAnt := E1_NATUREZ
       EmiNatAcu:=0
       EmiNatPer:=0
       BxaNatAcu:=0
       BxaNatPer:=0
       AbeNatAcu:=0
       AbeNatAcu2:=0
       wTotMes1:=0
       wTotMes2:=0
       wTotMes3:=0
       wTotPost:=0

       //While !Eof() .And. E1_XCC == cQuebra .AND. E1_NATUREZ == NatAnt //==
       While !Eof() .And. E1_ITEMD == cQuebra .AND. E1_NATUREZ == NatAnt //==
/*
         If (DTOS(E1_VENCREA)>DTOS(mv_par07))
             DBSKIP()
             LOOP
         Endif
*/
         If (DTOS(E1_emissao)<=DTOS(mv_par02))

                IncRegua()
	         	If li > 58
                   cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
                   li := li-1
        		EndIf

                nValDesAcu :=0
                nValDesPer :=0
                DbSelectArea("SE5")
                DbSetOrder(7)
                DbGotop()
                If DbSeek(xFilial()+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
                   Do While !EOF() .AND. SE5->E5_PREFIXO == SE1->E1_PREFIXO .AND.;
                         SE5->E5_NUMERO  == SE1->E1_NUM .AND.;
                         SE5->E5_PARCELA == SE1->E1_PARCELA .AND.;
                         SE5->E5_TIPO    == SE1->E1_TIPO 

                         IF SE5->E5_CLIFOR != SE1->E1_CLIENTE
                            DBSKIP()
                            LOOP
                         ENDIF

                         IF SE5->E5_SITUACA == "C" .OR. SE5->E5_TIPODOC == "DC"
                            DBSKIP()
                            LOOP
                         ENDIF
                          
                         If (DTOS(E5_DATA)>DTOS(mv_par07))
                             DBSKIP()
                             LOOP
                         Endif

                         If (DTOS(E5_DATA)<DTOS(mv_par01))       //Valores Acumulados
                            IF E5_TIPODOC $ "ES"
                               BxaNatAcu := BxaNatAcu - E5_VALOR
                            ElseIF E5_TIPODOC $ "VL/BA/V2/D2/CP/LJ/DC"
                               BxaNatAcu := BxaNatAcu + E5_VALOR
                            ENDIF
                         Else
                            If (DTOS(E5_DATA)<=DTOS(mv_par02))       //Valores no Periodo
                               IF E5_TIPODOC $ "ES"
                                  BxaNatPER := BxaNatPER - E5_VALOR
                               ElseIF E5_TIPODOC $ "VL/BA/V2/D2/CP/LJ/DC"
                                  BxaNatPER := BxaNatPER + E5_VALOR
                               ENDIF
                            Else                               //Valores a Vencer
//                               wTotaVen  := wTotaVen + E5_VALOR
//                               AbeNatAcu2:= AbeNatAcu2 + E5_VALOR
                            EndIf
                         Endif

                         DbSelectArea("SE5")
                         DbSkip()

                      EndDo
                   EndIf

                   DbSelectArea("SE1")
                   If (DTOS(E1_EMISSAO)<DTOS(mv_par01))
                      EmiNatAcu := EmiNatAcu + E1_VALOR    //(E1_SALDO + E1_VALLIQ)
                      EmiObrAcu := EmiObrAcu + E1_VALOR    //(E1_SALDO + E1_VALLIQ)
                      EmiTotAcu := EmiTotAcu + E1_VALOR    //(E1_SALDO + E1_VALLIQ)
                   Else
                       EmiNatPer := EmiNatPer + E1_VALOR   //(E1_SALDO + E1_VALLIQ)
                       EmiObrPer := EmiObrPer + E1_VALOR   //(E1_SALDO + E1_VALLIQ)
                       EmiTotPer := EmiTotPer + E1_VALOR   //(E1_SALDO + E1_VALLIQ)
                   Endif
                   DbSelectArea("SE1")

                If (DTOS(E1_VENCREA) < DTOS(mv_par02)) .and. E1_SALDO#0.00
                   AbeNatAcu := AbeNatAcu + E1_SALDO
                   wVlrSaU   := wVlrSaU + E1_SALDO
                   wTotSaU   := wTotSaU + E1_SALDO
                   wTotVen   := wTotVen + E1_SALDO
                Else
                  If (DTOS(E1_VENCREA) >= DTOS(mv_par02))
                   AbeNatAcu2:= AbeNatAcu2 + E1_SALDO
                   wVlrSaU   := wVlrSaU + E1_SALDO
                   wTotSaU   := wTotSaU + E1_SALDO
                   wTotaVen  := wTotaVen + E1_SALDO

                   Do Case
                      Case Month(E1_VENCREA) == Mes1
                         wTotMes1  := wTotMes1 + E1_SALDO
                         wTotaMes1 := wTotaMes1 + E1_SALDO
                         wVlrTMes1 := wVlrTMes1 + E1_SALDO
                      Case Month(E1_VENCREA) == Mes2
                         wTotMes2  := wTotMes2 + E1_SALDO
                         wTotaMes2 := wTotaMes2 + E1_SALDO
                         wVlrTMes2 := wVlrTMes2 + E1_SALDO
                      Case Month(E1_VENCREA) == Mes3
                         wTotMes3  := wTotMes3 + E1_SALDO
                         wTotaMes3 := wTotaMes3 + E1_SALDO
                         wVlrTMes3 := wVlrTMes3 + E1_SALDO
                      OtherWise
                         wTotPost  := wTotPost + E1_SALDO
                         wTotaPost := wTotaPost + E1_SALDO
                         wVlrTPost := wVlrTPost + E1_SALDO
                   EndCase
                 EndIf
                Endif

          EndIF

          DbSelectArea("SE1")
          dbSkip()

       Enddo

       wVlrBxA   := wVlrBxA + BxaNatACU
       wVlrBxM   := wVlrBxM + BxaNatPER
       wTotBxA   := wTotBxA + BxaNatACU
       wTotBxM   := wTotBxM + BxaNatPER

       DbSelectArea("SED")
       DbSeek(xFilial()+NatAnt)

       wForMes1:=wForMes2:=wForMes3:=0

       DbSelectArea("PED")
       DbGoTop()
//       wobra:= left(SA9->A9_TECNICO,3)
       wobra:= cQuebra	//left(SA9->A9_TECNICO,5)
       DbSeek(wobra)

       Do While ! eof() .and. PED->PD_OBRA == wobra//==
          if PED->PD_NATUR == SED->ED_CODIGO
             Do Case
                Case Month(PED->PD_DATPRF) == Mes1
                   wForMes1  := wForMes1 - PED->PD_TOTAL
                   wForaMes1 := wForaMes1 - PED->PD_TOTAL
                   wVlrTPed1 := wVlrTPed1 - PED->PD_TOTAL
                Case Month(PED->PD_DATPRF) == Mes2
                   wForMes2  := wForMes2 - PED->PD_TOTAL
                   wForaMes2 := wForaMes2 - PED->PD_TOTAL
                   wVlrTPed2 := wVlrTPed2 - PED->PD_TOTAL
                Case Month(PED->PD_DATPRF) == Mes3
                   wForMes3  := wForMes3 - PED->PD_TOTAL
                   wForaMes3 := wForaMes3 - PED->PD_TOTAL
                   wVlrTPed3 := wVlrTPed3 - PED->PD_TOTAL
             EndCase
          Endif
          DbSelectArea("PED")
          DbSkip()
       Enddo

       @ li,000 PSay Left(SED->ED_CODIGO,5)
       @ li,006 PSay "|"
       @ li,007 PSay int(EmiNatAcu)          PICTURE "@e 9999,999,999"
       @ li,020 PSay int(EmiNatPer)          PICTURE "@e 9999,999,999"
       @ li,033 PSay "|"
       @ li,034 PSay int(BxaNatAcu)          PICTURE "@e 9999,999,999"
       @ li,048 PSay int(BxaNatPer)          PICTURE "@e 9999,999,999"
       @ li,062 PSay "|"    //AQUI
       @ li,063 PSay int(AbeNatAcu)    PICTURE "@e 9999,999,999"
       @ li,077 PSay int(AbeNatAcu2)   PICTURE "@e 9999,999,999"
       @ li,090 PSay "|"
       @ li,091 PSay int(wTotMes1)     PICTURE "@e 999,999,999"
       @ li,104 PSay "|"
       @ li,105 PSay int(wTotMes2)     PICTURE "@e 999,999,999"
       @ li,118 PSay "|"
       @ li,119 PSay int(wTotMes3)     PICTURE "@e 999,999,999"
       @ li,132 PSay "|"
       @ li,133 PSay int(wTotPost)     PICTURE "@e 9999,999,999"
       @ li,147 PSay "|"
       @ li,148 PSay int(wForMes1)     PICTURE "@e 9999,999,999"
       @ li,161 PSay "|"
       @ li,162 PSay int(wForMes2)     PICTURE "@e 9999,999,999"
       @ li,175 PSay "|"
       @ li,176 PSay int(wForMes3)     PICTURE "@e 9999,999,999"
       @ li,189 PSay "|"
       wAcum:= (BxaNatAcu + BxaNatPer + AbeNatAcu + AbeNatAcu2)
       wAcum:= wAcum + (wForMes1 + wForMes2 + wForMes3)
       @ li,190 PSay int(wAcum)        PICTURE "@e 99999,999,999"
       @ li,204 PSay "|"

       DbSelectArea("SZA")
       //If DbSeek(xFilial() + SA9->A9_TECNICO + SED->ED_CODIGO)
       If DbSeek(xFilial() + cQuebra + SED->ED_CODIGO)
          @ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
          wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
       Else
          @ li,205 PSay 0              PICTURE "@e 99999,999,999"
       EndIf
       @ li,219 PSay "|"

       wNatureza:= wNatureza + (alltrim(SED->ED_CODIGO) + "@")

       li:=li+1

        wEmiNatAcu:= wEminatacu + eminatacu
        wEmiNatPer:= weminatper + eminatper
        wBxaNatAcu:= wbxanatacu + bxanatacu
        wBxaNatPer:= wbxanatper + bxanatper
        wNat:= wnat + abenatacu
        wAbeNatAcu2:= wabenatacu2 + abenatacu2
        wwTotMes1:= wwTotMes1 + wTotMes1
        wwTotMes2:= wwTotMes2 + wtotmes2
        wwTotMes3:= wwTotMes3 + wTotMes3
        wwTotPost:= wwtotpost + wtotpost
        wwForMes1:= wwForMes1 + wForMes1
        wwForMes2:= wwForMes2 + wForMes2
        wwForMes3:= wwForMes3 + wForMes3
        wwAcum   := wwAcum    + wAcum
        wwTotOrc := wwTotOrc + wTotOrc
       EmiNatAcu:=EmiNatPer:=BxaNatAcu:=BxaNatPer:=AbeNatAcu:=AbeNatAcu2:=0
       wTotMes1:=wTotMes2:=wTotMes3:=wTotPost:=0
       wForMes1:=wForMes2:=wForMes3:=wtotOrc:=0


       DbSelectArea("SE1")

     Enddo
///////////////////

       @ li,000 PSay "T R" // Left(SED->ED_CODIGO,5)
       @ li,006 PSay "|"
       @ li,007 PSay int(wEmiNatAcu)          PICTURE "@e 9999,999,999"
       @ li,020 PSay int(wEmiNatPer)          PICTURE "@e 9999,999,999"
       @ li,033 PSay "|"
       @ li,034 PSay int(wBxaNatAcu)          PICTURE "@e 9999,999,999"
       @ li,048 PSay int(wBxaNatPer)          PICTURE "@e 9999,999,999"
       @ li,062 PSay "|"    //AQUI
       @ li,063 PSay int(wNat)    PICTURE "@e 9999,999,999"
       @ li,077 PSay int(wAbeNatAcu2)   PICTURE "@e 9999,999,999"
       @ li,090 PSay "|"
       @ li,091 PSay int(wwTotMes1)     PICTURE "@e 999,999,999"
       @ li,104 PSay "|"
       @ li,105 PSay int(wwTotMes2)     PICTURE "@e 999,999,999"
       @ li,118 PSay "|"
       @ li,119 PSay int(wwTotMes3)     PICTURE "@e 999,999,999"
       @ li,132 PSay "|"
       @ li,133 PSay int(wwTotPost)     PICTURE "@e 9999,999,999"
       @ li,147 PSay "|"
       @ li,148 PSay int(wwForMes1)     PICTURE "@e 9999,999,999"
       @ li,161 PSay "|"
       @ li,162 PSay int(wwForMes2)     PICTURE "@e 9999,999,999"
       @ li,175 PSay "|"
       @ li,176 PSay int(wwForMes3)     PICTURE "@e 9999,999,999"
       @ li,189 PSay "|"
       @ li,190 PSay int(wwAcum)        PICTURE "@e 99999,999,999"
       @ li,204 PSay "|"
       @ li,205 PSay int(wwTotOrc) PICTURE "@e 99999,999,999"
       @ li,219 PSay "|"

       li:=li+1
       @ li,000 PSay repl("-",220)
       li:=li+1

//////////////////

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
       nTotObra    := nTotObra + wwTotOrc

       wEmiNatAcu:=wEmiNatPer:=wBxaNatAcu:=wBxaNatPer:=wNat:=wAbeNatAcu2:=0
       wwTotMes1:=wwTotMes2:=wwTotMes3:=wwTotPost:=0
       wwForMes1:=wwForMes2:=wwForMes3:=0
       wwAcum   := 0
       wwTotOrc := 0
	   
   Endif

   // Verifica se tem outra natureza que nao foi impressa acima
   // assim verifica todos os pedidos

   DbSelectArea("SED")
   DbGoTop()
   Do While ! eof()
      if ! Alltrim(SED->ED_CODIGO) $ wNatureza
         wForMes1:=wForMes2:=wForMes3:=0

         DbSelectArea("PED")
//         wobra:= left(SA9->A9_TECNICO,3)
         wobra:= cQuebra	//left(SA9->A9_TECNICO,5)
         DbSeek(wobra)

         Do While ! eof() .and. PED->PD_OBRA == wobra    //==
            if PED->PD_NATUR == SED->ED_CODIGO
               Do Case
                  Case Month(PED->PD_DATPRF) == Mes1
                     wForMes1  := wForMes1 - PED->PD_TOTAL
                     wForaMes1 := wForaMes1 - PED->PD_TOTAL
                     wVlrTPed1 := wVlrTPed1 - PED->PD_TOTAL
                  Case Month(PED->PD_DATPRF) == Mes2
                     wForMes2  := wForMes2 - PED->PD_TOTAL
                     wForaMes2 := wForaMes2 - PED->PD_TOTAL
                     wVlrTPed2 := wVlrTPed2 - PED->PD_TOTAL
                  Case Month(PED->PD_DATPRF) == Mes3
                     wForMes3  := wForMes3 - PED->PD_TOTAL
                     wForaMes3 := wForaMes3 - PED->PD_TOTAL
                     wVlrTPed3 := wVlrTPed3 - PED->PD_TOTAL
               EndCase
            Endif
            DbSelectArea("PED")
            DbSkip()
         Enddo
      Endif
      if wForMes1 <> 0 .or. wForMes2 <> 0 .or. wForMes3 <> 0
         titulo:= "Relatorio de Acompanhamento Financeiro" +;
         " Periodo de " + dtoc(mv_par01) + " ate " + dtoc(mv_par02)
         If li > 58
            cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
            li := li-1
         EndIf

         @ li,000 PSay Left(SED->ED_CODIGO,5)
         @ li,006 PSay "|"
         @ li,007 PSay int(EmiNatAcu)          PICTURE "@e 9999,999,999"
         @ li,020 PSay int(EmiNatPer)          PICTURE "@e 9999,999,999"
         @ li,033 PSay "|"
         @ li,034 PSay int(BxaNatAcu)          PICTURE "@e 9999,999,999"
         @ li,048 PSay int(BxaNatPer)          PICTURE "@e 9999,999,999"
         @ li,062 PSay "|"    //AQUI
         @ li,063 PSay int(AbeNatAcu)    PICTURE "@e 9999,999,999"
         @ li,077 PSay int(AbeNatAcu2)   PICTURE "@e 9999,999,999"
         @ li,090 PSay "|"
         @ li,091 PSay int(wTotMes1)     PICTURE "@e 999,999,999"
         @ li,104 PSay "|"
         @ li,105 PSay int(wTotMes2)     PICTURE "@e 999,999,999"
         @ li,118 PSay "|"
         @ li,119 PSay int(wTotMes3)     PICTURE "@e 999,999,999"
         @ li,132 PSay "|"
         @ li,133 PSay int(wTotPost)     PICTURE "@e 9999,999,999"
         @ li,147 PSay "|"
         @ li,148 PSay int(wForMes1)     PICTURE "@e 9999,999,999"
         @ li,161 PSay "|"
         @ li,162 PSay int(wForMes2)     PICTURE "@e 9999,999,999"
         @ li,175 PSay "|"
         @ li,176 PSay int(wForMes3)     PICTURE "@e 9999,999,999"
         @ li,189 PSay "|"
         wAcum:= (BxaNatAcu + BxaNatPer + AbeNatAcu + AbeNatAcu2)
         wAcum:= wAcum + (wForMes1 + wForMes2 + wForMes3)
         @ li,190 PSay int(wAcum)        PICTURE "@e 99999,999,999"
         @ li,204 PSay "|"
   
   
         DbSelectArea("SZA")
         //If DbSeek(xFilial() + SA9->A9_TECNICO + SED->ED_CODIGO)
         If DbSeek(xFilial() + cQuebra + SED->ED_CODIGO)
            @ li,205 PSay int(SZA->ZA_VLRTOT) PICTURE "@e 99999,999,999"
            wTotOrc:= wTotOrc + SZA->ZA_VLRTOT
         Else
            @ li,205 PSay 0              PICTURE "@e 99999,999,999"
         EndIf
         @ li,219 PSay "|"

         houve := .t.
         li:=li + 1
      Endif
      wForMes1:=wForMes2:=wForMes3:=0
      DbSelectArea("SED")
      DbSkip()
   Enddo

   If houve
      If li > 58
         cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
         li := li-1
      EndIf
       //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Inicializa variaveis para controlar cursor de progressao     ³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       wTotaMes1:=wTotaMes2:=wTotaMes3:=0

      @ li,000 PSay "T/Obra"
      @ li,006 PSay "|"
      @ li,007 PSay int(EmiObrAcu)          PICTURE "@e 9999,999,999"
      @ li,020 PSay int(EmiObrPer)          PICTURE "@e 9999,999,999"
      @ li,033 PSay "|"
      @ li,034 PSay int(wVlrBxA)            PICTURE "@e 9999,999,999"
      @ li,048 PSay int(wVlrBxM)            PICTURE "@e 9999,999,999"
      @ li,062 PSay "|"
      @ li,063 PSay int(wTotVen)            PICTURE "@e 9999,999,999" // alterado impressao dos
      @ li,077 PSay int(wTotaVen)           PICTURE "@e 9999,999,999" 
      @ li,090 PSay "|"
      @ li,091 PSay int(wTotaMes1)     PICTURE "@e 999,999,999"
      @ li,104 PSay "|"
      @ li,105 PSay int(wTotaMes2)     PICTURE "@e 999,999,999"
      @ li,118 PSay "|"
      @ li,119 PSay int(wTotaMes3)     PICTURE "@e 999,999,999"
      @ li,132 PSay "|"
      @ li,133 PSay int(wTotaPost)     PICTURE "@e 9999,999,999"
      @ li,147 PSay "|"
      @ li,148 PSay int(wForaMes1)     PICTURE "@e 9999,999,999"
      @ li,161 PSay "|"
      @ li,162 PSay int(wForaMes2)     PICTURE "@e 9999,999,999"
      @ li,175 PSay "|"
      @ li,176 PSay int(wForaMes3)     PICTURE "@e 9999,999,999"
      @ li,189 PSay "|"
      wAcum:= (wVlrBxA + wVlrBxM + wTotVen + wTotaVen)
      wAcum:= wAcum + (wForaMes1 + wForaMes2 + wForaMes3)
      wtotv:=wtotv + wtotven
      @ li,191 PSay int(wAcum)        PICTURE "@e 9999,999,999"
      @ li,204 PSay "|"
      @ li,205 PSay int(nTotObra)       PICTURE "@e 99999,999,999"
      @ li,219 PSay "|"
      wacum1:= wacum1 + wAcum
      wtotorc1:= wtotorc1 + wtotorc
      li:=li+1
      @ li,000 PSay repl("-",220)
      li:=li+1
   Endif

   wVlrBxA:=wVlrBxM:=wVlrSaU:=0
   EmiObrAcu:=EmiObrPer:=0
   wTotVen:=wTotaVen:=wTotaMes1:=wTotaMes2:=wTotaMes3:=wTotaPost:=0
   wForMes1:=wForMes2:=wForMes3:=0
   wForaMes1:=wForaMes2:=wForaMes3:=wTotOrc:=0   

   houve:=.f.
//   DbSelectArea("SA9")
//   DbSkip()
  
   //DbSelectArea("AF8")       //mhd
   DbSElectArea("CTD")
   DbSkip()

EndDo

IF li != 80 //.and. houve
// Totais G P   - WCS
   @ li,000 PSay "G P" 
   @ li,006 PSay "|"
   @ li,007 PSay int(nGPEmiNatAcu)      PICTURE "@e 9999,999,999"  
   @ li,020 PSay int(nGPEmiNatPer)          PICTURE "@e 9999,999,999"
   @ li,033 PSay "|"
   @ li,034 PSay int(nGPBxaNatAcu)          PICTURE "@e 9999,999,999"
   @ li,048 PSay int(nGPBxaNatPer)          PICTURE "@e 9999,999,999" 
   @ li,062 PSay "|"    //AQUI
   @ li,063 PSay int(nGPNat)    PICTURE "@e 9999,999,999"
   @ li,077 PSay int(nGPNatAcu2)   PICTURE "@e 9999,999,999"
   @ li,090 PSay  "|"
   @ li,091 PSay int(nGPTotMes1)     PICTURE "@e 999,999,999"
   @ li,104 PSay "|"  
   @ li,105 PSay int(nGPTotMes2)     PICTURE "@e 999,999,999"
   @ li,118 PSay "|"
   @ li,119 PSay int(nGPTotMes3)     PICTURE "@e 999,999,999"
   @ li,132 PSay "|"
   @ li,133 PSay int(nGPTotPost)     PICTURE "@e 9999,999,999"
   @ li,147 PSay "|"
   @ li,148 PSay int(nGPForMes1)     PICTURE "@e 9999,999,999"
   @ li,161 PSay "|"
   @ li,162 PSay int(nGPForMes2)     PICTURE "@e 9999,999,999"
   @ li,175 PSay "|"
   @ li,176 PSay int(nGPForMes3)     PICTURE "@e 9999,999,999"
   @ li,189 PSay "|"
   @ li,190 PSay int(nGPAcum)        PICTURE "@e 99999,999,999"
   @ li,204 PSay "|"
   @ li,205 PSay int(nGPTotOrc) PICTURE "@e 99999,999,999"
   @ li,219 PSay "|"
   li:=li+1
   @ li,000 PSay repl("-",220)
   li:=li+1

   // Totais G R   - WCS
   @ li,000 PSay "G R" 
   @ li,006 PSay "|"
   @ li,007 PSay int(nGREmiNatAcu)      PICTURE "@e 9999,999,999"
   @ li,020 PSay int(nGREmiNatPer)          PICTURE "@e 9999,999,999"
   @ li,033 PSay "|"
   @ li,034 PSay int(nGRBxaNatAcu)          PICTURE "@e 9999,999,999"
   @ li,048 PSay int(nGRBxaNatPer)          PICTURE "@e 9999,999,999"
   @ li,062 PSay "|"    //AQUI
   @ li,063 PSay int(nGRNat)    PICTURE "@e 9999,999,999"
   @ li,077 PSay int(nGRNatAcu2)   PICTURE "@e 9999,999,999"
   @ li,090 PSay  "|"
   @ li,091 PSay int(nGRTotMes1)     PICTURE "@e 999,999,999"
   @ li,104 PSay "|"  
   @ li,105 PSay int(nGRTotMes2)     PICTURE "@e 999,999,999"
   @ li,118 PSay "|"
   @ li,119 PSay int(nGRTotMes3)     PICTURE "@e 999,999,999"
   @ li,132 PSay "|"
   @ li,133 PSay int(nGRTotPost)     PICTURE "@e 9999,999,999"
   @ li,147 PSay "|"
   @ li,148 PSay int(nGRForMes1)     PICTURE "@e 9999,999,999"
   @ li,161 PSay "|"
   @ li,162 PSay int(nGRForMes2)     PICTURE "@e 9999,999,999"
   @ li,175 PSay "|"
   @ li,176 PSay int(nGRForMes3)     PICTURE "@e 9999,999,999"
   @ li,189 PSay "|"
   @ li,190 PSay int(nGRAcum)        PICTURE "@e 99999,999,999"
   @ li,204 PSay "|"
   @ li,205 PSay int(nGRTotOrc) PICTURE "@e 99999,999,999"
   @ li,219 PSay "|"
   li:=li+1
   @ li,000 PSay repl("-",220)
   li:=li+1
  
   @ li,000 PSay "Geral:"
   @ li,006 PSay "|"
   @ li,008 PSay int(EmiTotAcu)          PICTURE "@e 999,999,999"
   @ li,020 PSay int(EmiTotPer)          PICTURE "@e 9999,999,999"
   @ li,033 PSay "|"
   @ li,034 PSay int(wTotBxA)            PICTURE "@e 9999,999,999"
   @ li,048 PSay int(wTotBxM)            PICTURE "@e 9999,999,999"
   @ li,062 PSay "|"
   //@ li,063 PSay int(wtotv)              PICTURE "@e 9999,999,999"
   @ li,077 PSay int(wTotSaU)            PICTURE "@e 9999,999,999"
   @ li,090 PSay "|"
   @ li,091 PSay int(wVlrTMes1)     PICTURE "@e 999,999,999"
   @ li,104 PSay "|"
   @ li,105 PSay int(wVlrTMes2)     PICTURE "@e 999,999,999"
   @ li,118 PSay "|"
   @ li,119 PSay int(wVlrTMes3)     PICTURE "@e 999,999,999"
   @ li,132 PSay "|"
   @ li,133 PSay int(wVlrTPost)     PICTURE "@e 9999,999,999"
   @ li,147 PSay "|"
   @ li,148 PSay int(wVlrTPed1)     PICTURE "@e 9999,999,999"
   @ li,161 PSay "|"
   @ li,162 PSay int(wVlrTPed2)     PICTURE "@e 9999,999,999"
   @ li,175 PSay "|"
   @ li,176 PSay int(wVlrTPed3)     PICTURE "@e 9999,999,999"
   @ li,189 PSay "|"
   @ li,191 PSay int(wAcum1)        PICTURE "@e 9999,999,999"
   @ li,204 PSay "|"
   @ li,205 PSay int(nGRTotOrc)+int(nGPTotOrc)   PICTURE "@e 99999,999,999"
   @ li,219 PSay "|"

   li:=li+1
   @ li,000 PSay repl("-",220)

   Roda(nCntImpr,cRodaTxt,Tamanho)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RetIndex("SE2")
Set Filter to
RetIndex("SE1")
Set Filter to
RetIndex("SC7")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice e arquivo temporario de trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq :=cNomArq+ OrdBagExt()
Delete File &(cNomArq)
cNomArq2 :=cNomArq2+ OrdBagExt()
Delete File &(cNomArq2)
DbSelectArea("PED")
DbCloseArea()
Ferase(cTrab+".dbf")
Ferase(cTrab+".dbf")

Set Device to Screen

If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()