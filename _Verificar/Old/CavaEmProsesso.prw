#include "rwmake.ch"
#INCLUDE 'PROTHEUS.CH'


User Function P7PROCESSO()

Local oProcess
Local aSays		:={}
Local aButtons	:={}
Local nOpca 	:= 0
Local cCadastro := "Registro de Inventario - Em Processo"

Private aTotal  := {}
Private aImp    := {}
Private	nDecVal := TamSX3("B2_CM1")[2] // Retorna o numero de decimais usado no SX3
Private cPerg   := "MTR460"
Private nReg    := 0
Private cArqTemp:= ""
Private aArqTemp  := {}
Private cIndTemp1 := ""
Private cIndTemp2 := ""
Private cArqTemp2 := ""
Private cArqTemp3 := CriaTrab(Nil,.F.)

AADD(aSays,"Esta rotina tem como objetivo gerar o relatorio de Registro de Inventario " )
AADD(aSays,"para produtos em processo - conforme parametros selecionados.")

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca:= 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )

Pergunte(cPerg,.f. )	

FormBatch( cCadastro, aSays, aButtons,, 220, 560 )

If nOpca = 1
	oProcess:= MsNewProcess():New( { |lEnd| OkProces( oProcess, cPerg ) }, "", "", .F. )
	oProcess:Activate()
Endif

Return()   

Static Function OkProces( oObj, cPerg )

Local lObj	    := ValType(oObj) == "O"
Local nMAXPASSO := 3

If lObj
	oObj:SetRegua1(nMAXPASSO)
EndIf

If lObj
	oObj:IncRegua1("Analisando as OPs")  //1
EndIf                                                 

AnalisaOps(oObj)

If lObj
	oObj:IncRegua1("Montando o Relatorio")  //2
EndIf                                                 

MontaRel(cArqTemp,oObj)

If !empty(aImp)
  TelaProcesso()
 Else
  Alert("Nao exitem produtos em processo !!!")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga Arquivos Temporarios                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTemp)
dbCloseArea()
Ferase(cArqTemp+GetDBExtension())
Ferase(cIndTemp1+OrdBagExt())
Ferase(cIndTemp2+OrdBagExt())

Return


Static Function AnalisaOps(oObj)

Local lObj	    := ValType(oObj) == "O"
Local aCampos   := {}
Local aEmAnalise:= {}
Local aSalAtu   := {}
Local aProducao := {}
Local lCusFIFO  := GetMV("MV_CUSFIFO")
Local lQuery    := .F.
Local lEmProcess:= .F.
Local cAliasTop := "SD3"
Local cAliasSD3 := "SD3"
Local nQtMedia  := 0
Local nQtNeces  := 0
Local nQtde     := 0
Local nCusto    := 0
Local nPos      := 0
Local nX        := 0
Local nQtdOrigem:= 0
Local nQtdProduz:= 0
Local cQuery    := ""
Local nDecQtd   := If(TamSX3("B2_QFIM")[2] > 4,3,TamSX3("B2_QFIM")[2])
Local nTmOP     := TamSX3("D3_OP")[1]


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                  ³
//³ mv_par01     // Saldo em Processo (Sim) (Nao)                         ³
//³ mv_par02     // Saldo em Poder 3§ 1=Sim 2=Nao 3=De Terc. 4=Em Terc	  ³
//³ mv_par03     // Almox. de                                    		  ³
//³ mv_par04     // Almox. ate                                            ³
//³ mv_par05     // Produto de                                            ³
//³ mv_par06     // Produto ate                                           ³
//³ mv_par07     // Lista Produtos sem Movimentacao   (Sim)(Nao)          ³
//³ mv_par08     // Lista Produtos com Saldo Negativo (Sim)(Nao)          ³
//³ mv_par09     // Lista Produtos com Saldo Zerado   (Sim)(Nao)          ³
//³ mv_par10     // Pagina Inicial                                        ³
//³ mv_par11     // Quantidade de Paginas                                 ³
//³ mv_par12     // Numero do Livro                                       ³
//³ mv_par13     // Livro/Termos                                          ³
//³ mv_par14     // Data de Fechamento do Relatorio                       ³
//³ mv_par15     // Quanto a Descricao (Normal) (Inclui Codigo)           ³
//³ mv_par16     // Lista Produtos com Custo Zero ?   (Sim)(Nao)          ³
//³ mv_par17     // Lista Custo Medio / Fifo                              ³
//³ mv_par18     // Verifica Sld Processo Dt Emissao Seq Calculo          ³
//³ mv_par19     // Quanto a quebra por aliquota (Nao)(Icms)(Red)         ³
//| mv_par20	 // Lista MOD Processo? (Sim) (Nao) 			          |
//| mv_par21	 // Seleciona Filial? (Sim) (Nao)                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recebe parametros das perguntas                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lSaldProcess:=(mv_par01==1)
lSaldTerceir:=(mv_par02<>2)
cAlmoxIni	:=IIf(mv_par03=="**",Space(02),mv_par03)
cAlmoxFim	:=IIf(mv_par04=="**","ZZ",mv_par04)
cProdIni	:= mv_par05
cProdFim	:= mv_par06
lListProdMov:=(mv_par07==1)
lListProdNeg:=(mv_par08==1)
lListProdZer:=(mv_par09==1)
nPagIni		:= mv_par10
nQtdPag		:= mv_par11
cNrLivro	:= mv_par12
lLivro		:=(mv_par13!=2)
dDtFech		:= mv_par14
lDescrNormal:=(mv_par15==1)
lListCustZer:=(mv_par16==1)
lListCustMed:=(mv_par17==1)
lCalcProcDt	:=(mv_par18==1)
lModProces  :=(mv_par20==1)

AADD(aArqTemp,{"OP"	        ,"C",nTmOP,0})
AADD(aArqTemp,{"TIPO"		,"C",02,0})
AADD(aArqTemp,{"POSIPI"		,"C",10,0})
AADD(aArqTemp,{"PRODUTO"	,"C",15,0})
AADD(aArqTemp,{"DESCRICAO"	,"C",35,0})
AADD(aArqTemp,{"UM"			,"C",02,0})
AADD(aArqTemp,{"QUANTIDADE"	,"N",14,nDecQtd})
AADD(aArqTemp,{"VALOR_UNIT"	,"N",21,nDecVal})
AADD(aArqTemp,{"TOTAL"		,"N",21,nDecVal})

//-- Chave do Arquivo de Trabalho
cKeyInd:= "TIPO+POSIPI+PRODUTO+OP"

//-- Cria Arquivo de Trabalho
cArqTemp :=CriaTrab(aArqTemp)
cIndTemp1:=Substr(CriaTrab(NIL,.F.),1,7)+"1"
cIndTemp2:=Substr(CriaTrab(NIL,.F.),1,7)+"2"

dbUseArea(.T.,,cArqTemp,cArqTemp,.T.,.F.)
IndRegua(cArqTemp,cIndTemp1,cKeyInd,,,"Indice Tempor rio...")
IndRegua(cArqTemp,cIndTemp2,"PRODUTO+OP",,,"Indice Tempor rio...")

Set Cursor Off
DbClearIndex()
DbSetIndex(cIndTemp1+OrdBagExt())
DbSetIndex(cIndTemp2+OrdBagExt())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SALDO EM PROCESSO                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de Trabalho para armazenar as OPs               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{"OP"		,"C",TamSX3("D3_OP")[1]			,0}) // 01 - OP
AADD(aCampos,{"SEQCALC"	,"C",TamSX3("D3_SEQCALC")[1]	,0}) // 02 - SEQCALC
AADD(aCampos,{"DATA1"	,"D",8							,0}) // 03 - DATA1
cArqTemp2:=CriaTrab(aCampos)

dbUseArea(.T.,,cArqTemp2,cArqTemp2,.T.,.F.)
IndRegua(cArqTemp2,cArqTemp2,"OP+SEQCALC+DTOS(DATA1)",,,"Criando Indice...")	//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca saldo em processo                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD3")
dbSetOrder(1) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

cAliasTop := cArqTemp3
cQuery := "SELECT D3_FILIAL, D3_OP, D3_COD, D3_LOCAL, D3_CF, D3_EMISSAO, D3_SEQCALC "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' "
cQuery += "AND SD3.D3_OP <> '" + Criavar("D3_OP",.F.)+ "' "
cQuery += "AND (SD3.D3_CF ='PR0' OR SD3.D3_CF = 'PR1') "
If !Empty(dDtFech) 
	cQuery += "AND SD3.D3_EMISSAO <= '" + DTOS(dDtFech) + "' "
EndIf
cQuery += "AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' 
//cQuery += "AND SD3.D3_OP = 'VB079C01014' "
cQuery += "UNION "
cQuery += "SELECT D3_FILIAL, D3_OP, D3_COD, D3_LOCAL, D3_CF, D3_EMISSAO, D3_SEQCALC "
cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
cQuery += "WHERE SD3.D3_FILIAL='" + xFilial("SD3") + "' "
cQuery += "AND SD3.D3_OP <> '" + Criavar("D3_OP",.F.) + "' "
cQuery += "AND SD3.D3_COD >= '"+cProdIni+"' "
cQuery += "AND SD3.D3_COD <= '"+cProdFim+"' "
cQuery += "AND SD3.D3_CF <>'PR0' AND SD3.D3_CF <>'PR1' "
If !Empty(dDtFech) 
	cQuery += "AND SD3.D3_EMISSAO <= '" + DTOS(dDtFech) + "' "
EndIf
cQuery += "AND SD3.D3_ESTORNO = ' ' "
cQuery += "AND SD3.D_E_L_E_T_ = ' ' "   
//cQuery += "AND SD3.D3_OP = 'VB079C01014' " //_E_L_E_T_ = ' ' "   


cQuery += "ORDER BY "+SqlOrder(SD3->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTemp3,.T.,.T.)

TcSetField(cAliasTop,"D3_EMISSAO","D",8,0)

dbSelectArea( cArqTemp3 )
DbGoTop()
bAcao:= {|| nReg ++ }
dbEval(bAcao,,{||!Eof()},,,.T.)

If lObj
	oObj:SetRegua2(nReg)
Endif

nReg := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena OPs e data de emissao no Arquivo de Trabalho        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( cAliasTop )
DbGoTop()

While !Eof()

    If lObj
     oObj:IncRegua2("Armazenando as OPs")    
    Endif
	
	
	//-- Posiciona tabela SC2
	SC2->(dbSetOrder(1))
	If SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)#(xFilial("SC2")+(cAliasTop)->D3_OP)
		SC2->(MsSeek(xFilial("SC2")+(cAliasTop)->D3_OP))
	EndIf
	
	// Verifica Data de Encerramento da OP
If !Empty(dDtFech) 
	If !Empty(SC2->C2_DATRF) .And. SC2->C2_DATRF <= dDtFech
		dbSkip()
		Loop
	EndIf
Else
	If !Empty(SC2->C2_DATRF) //.And. SC2->C2_DATRF 
		dbSkip()
		Loop
	EndIf
EndIf
	
	// Armazena OPs e Data de Emissao
	dbSelectArea(cArqTemp2)
	If dbSeek((cAliasTop)->D3_OP)
		RecLock(cArqTemp2,.F.)
	Else
        nReg ++
		RecLock(cArqTemp2,.T.)
		Replace OP with (cAliasTop)->D3_OP
	EndIf
	If SubStr((cAliasTop)->D3_CF,1,2) == "PR"
		Replace DATA1 with Max((cAliasTop)->D3_EMISSAO,DATA1)
		If !lCalcProcDt .And. ((cAliasTop)->D3_SEQCALC > SEQCALC)
			Replace SEQCALC With (cAliasTop)->D3_SEQCALC
		EndIf
	EndIf
	MsUnlock()
	
	dbSelectArea(cAliasTop)
	dbSkip()
	
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura ambiente e apaga arquivo temporario                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAliasTop)
dbCloseArea()
dbSelectArea("SD3")

If lObj
	oObj:SetRegua2(nReg)
Endif

nReg := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gravacao do Saldo em Processo                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTemp2) //tabela das OPs
dbGotop()
While !Eof()


    If lObj
     oObj:IncRegua2("Gerando Saldo em Processo")    
    Endif

	
	aProducao := {}
	aEmAnalise:= {}
	
	dbSelectArea("SD3")
	dbSetOrder(1)
	lQuery    := .T.
	cAliasSD3 := GetNextAlias()
	cQuery := "SELECT SD3.D3_FILIAL, SD3.D3_OP, SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_CF, SD3.D3_EMISSAO, "
	cQuery += "SD3.D3_SEQCALC, SD3.D3_CUSTO1, SD3.D3_SEQCALC, SD3.D3_QUANT, SD3.D3_ESTORNO, SD3.D3_PERDA, SD3.R_E_C_N_O_ RECNOSD3 "
	cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += "WHERE SD3.D3_FILIAL='"+xFilial("SD3")+"' "
	cQuery += "AND SD3.D3_OP = '" + (cArqTemp2)->OP + "' "
	cQuery += "AND SD3.D3_ESTORNO = ' ' "
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY " + SqlOrder(SD3->(IndexKey()))
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.T.)
	
	TcSetField(cAliasSD3,"D3_EMISSAO","D",8,0)
	TcSetField(cAliasSD3,"D3_QUANT","N",TamSX3("D3_QUANT")[1],TamSX3("D3_QUANT")[2])
	TcSetField(cAliasSD3,"D3_CUSTO1","N",TamSX3("D3_CUSTO1")[1],TamSX3("D3_CUSTO1")[2])
	
	
	While !Eof() .And. (cAliasSD3)->D3_OP==(cArqTemp2)->OP
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para nao permitir movimento com a data maior que a data de ³
		//| encerramento do relatorio.                                           |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(dDtFech) 
		If (cAliasSD3)->D3_EMISSAO > dDtFech .Or. (cAliasSD3)->D3_ESTORNO == "S"
			dbSkip()
			Loop
		EndIf
    Else
		If (cAliasSD3)->D3_ESTORNO == "S"
			dbSkip()
			Loop
		EndIf
    EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somatoria de todos os apontamentos de producao para esta OP          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr((cAliasSD3)->D3_CF,1,2) == "PR"
			nPos:=Ascan(aProducao,{|x|x[1]==(cAliasSD3)->D3_COD})
			If nPos==0
				AADD(aProducao,{(cAliasSD3)->D3_COD,(cAliasSD3)->D3_QUANT,(cAliasSD3)->D3_CUSTO1,(cAliasSD3)->D3_PERDA,(cArqTemp2)->OP})
			Else
				aProducao[nPos,2] += (cAliasSD3)->D3_QUANT
				aProducao[nPos,3] += (cAliasSD3)->D3_CUSTO1
				aProducao[nPos,4] += (cAliasSD3)->D3_PERDA
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para o Produto                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD3)->D3_COD < cProdIni .Or. (cAliasSD3)->D3_COD > cProdFim .Or.;
		If(lModProces,.T.,IsProdMod((cAliasSD3)->D3_COD))
   			dbSkip()
  			Loop
  		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validacao para o local                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cAliasSD3)->D3_LOCAL < cAlmoxIni .Or. (cAliasSD3)->D3_LOCAL > cAlmoxFim
			dbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Somatoria das Requisicoes para Ordem de Producao                     |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SubStr((cAliasSD3)->D3_CF,1,2) == "RE"
			nPos:=Ascan(aEmAnalise,{|x|x[1]==(cAliasSD3)->D3_COD})
			If nPos==0
				AADD(aEmAnalise,{	(cAliasSD3)->D3_COD								,;	// 01 - Codigo do produto
				(cAliasSD3)->D3_LOCAL							,;	// 02 - Codigo do Armazem
				(cAliasSD3)->D3_QUANT							,;	// 03 - Quantidade
				(cAliasSD3)->D3_CUSTO1							,;	// 04 - Custo na moeda 1
				IIf (lQuery, (cAliasSD3)->RECNOSD3, RECNO())	,;	// 05 - Recno da tabela SD3
				"RE" 											,;	// 06 - Tipo de movimento RE/DE
				(cAliasSD3)->D3_OP                               ;  // 07 - OP
				})
			Else
				aEmAnalise[nPos,3] += (cAliasSD3)->D3_QUANT
				aEmAnalise[nPos,4] += (cAliasSD3)->D3_CUSTO1
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Somatoria das Devolucoes para Ordem de Producao                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf SubStr((cAliasSD3)->D3_CF,1,2) == "DE"
			nPos:=Ascan(aEmAnalise,{|x|x[1]==(cAliasSD3)->D3_COD})
			If nPos==0
				AADD(aEmAnalise,{	(cAliasSD3)->D3_COD								,;	// 01 - Codigo do produto
				(cAliasSD3)->D3_LOCAL							,;	// 02 - Codigo do Armazem
				(cAliasSD3)->D3_QUANT	* (-1)					,;	// 03 - Quantidade
				(cAliasSD3)->D3_CUSTO1	* (-1)					,;	// 04 - Custo na moeda 1
				IIf (lQuery, (cAliasSD3)->RECNOSD3, RECNO())	,;	// 05 - Recno da tabela SD3
				"DE" 											,;	// 06 - Tipo de movimento RE/DE
				(cAliasSD3)->D3_OP                              ;  // 07 - OP
				})
			Else
				aEmAnalise[nPos,3] -= (cAliasSD3)->D3_QUANT
				aEmAnalise[nPos,4] -= (cAliasSD3)->D3_CUSTO1
			EndIf
			
		EndIf
		
		dbSelectArea(cAliasSD3)
		dbSkip()
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ANALISE DE SALDO EM PROCESSO EM ABERTO                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	//-- Posiciona tabela SC2
	SC2->(dbSetOrder(1))
	If SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)#(xFilial("SC2")+(cArqTemp2)->OP)
		SC2->(MsSeek(xFilial("SC2")+(cArqTemp2)->OP))
	EndIf
	
	If SC2->(C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)==(xFilial("SC2")+(cArqTemp2)->OP)
		
		//-- Requisicao para Ordem de Producao
		If Len(aEmAnalise) > 0
			
			//-- Apontamento de producao
			If Len(aProducao) > 0
				
				For nX := 1 To Len(aEmAnalise)
					dbSelectArea("SD4")
					dbSetOrder(2)
					If dbSeek(xFilial("SD4")+(cArqTemp2)->OP+aEmAnalise[nX,1]+aEmAnalise[nX,2])
						//-- Flag utilizado para gravar saldo em processo
						lEmProcess := .F.
						//-- Quantidade Media por Producao
						nQtMedia  := SD4->D4_QTDEORI / SC2->C2_QUANT
						//-- Quantidade necessaria para producao da quantidade apontada
						nQtNeces  := aProducao[1,2] * nQtMedia
						//-- Avalia quantidade em processo
						If (aEmAnalise[nX,3]) > nQtNeces
							lEmProcess := .T.
							//-- Proporciona saldo em processo desta requisicao
							nQtde  := aEmAnalise[nX,3] - nQtNeces
							//-- Custo em processo
							nCusto := (aEmAnalise[nX,4] / aEmAnalise[nX,3]) * nQtde
						EndIf
						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ GRAVA SALDO EM PROCESSO                                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lEmProcess
							// Posiciona tabela SB1
							If SB1->B1_COD!=aEmAnalise[nX,1]
								SB1->(dbSeek(xFilial("SB1")+aEmAnalise[nX,1]))
							EndIf

                            nReg ++							

							If SB1->B1_COD==aEmAnalise[nX,1]
								dbSelectArea(cArqTemp)
								dbSetOrder(2)
								RecLock(cArqTemp,!dbSeek(aEmAnalise[nX,1]+aEmAnalise[nX,7]))
								Replace OP    	    with aEmAnalise[nX,7]
								Replace TIPO		with SB1->B1_TIPO
								Replace POSIPI		with SB1->B1_POSIPI
								Replace PRODUTO		with SB1->B1_COD
								Replace DESCRICAO	with SB1->B1_DESC
								Replace UM			with SB1->B1_UM
								Replace QUANTIDADE 	with QUANTIDADE + nQtde
								Replace TOTAL		with TOTAL 		+ nCusto
								If QUANTIDADE > 0
									Replace VALOR_UNIT	with NoRound(TOTAL/QUANTIDADE,nDecVal)
								EndIf
								MsUnLock()
							EndIf
						EndIf
					EndIf
					
				Next aEmAnalise
				
				
			Else
				
				//-- Considera todo o saldo requisitado para Ordem de Producao como saldo em processo
				For nX := 1 to Len(aEmAnalise)
					
					// Posiciona tabela SB1
					If SB1->B1_COD!=aEmAnalise[nX,1]
						SB1->(dbSeek(xFilial("SB1")+aEmAnalise[nX,1]))
					EndIf

					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ GRAVA SALDO EM PROCESSO                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SB1->B1_COD==aEmAnalise[nX,1]
                        nReg ++							
						dbSelectArea(cArqTemp)
						dbSetOrder(2)
						RecLock(cArqTemp,!dbSeek(SB1->B1_COD+aEmAnalise[nX,7]))
						Replace OP       	with aEmAnalise[nX,7]
						Replace TIPO		with SB1->B1_TIPO
						Replace POSIPI		with SB1->B1_POSIPI
						Replace PRODUTO		with SB1->B1_COD
						Replace DESCRICAO	with SB1->B1_DESC
						Replace UM			with SB1->B1_UM
						Do Case
							Case aEmAnalise[nX,6] == "RE"
								Replace QUANTIDADE 	with QUANTIDADE + aEmAnalise[nX,3]
								Replace TOTAL		with TOTAL 		+ aEmAnalise[nX,4]
							Case aEmAnalise[nX,6] == "DE"
								Replace QUANTIDADE 	with QUANTIDADE - aEmAnalise[nX,3]
								Replace TOTAL		with TOTAL 		- aEmAnalise[nX,4]
						EndCase
						If QUANTIDADE > 0
							Replace VALOR_UNIT	with NoRound(TOTAL/QUANTIDADE,nDecVal)
						EndIf
						MsUnLock()
					EndIf
					
				Next aEmAnalise
				
			EndIf
			
		EndIf
		
	EndIf

	// Finaliza a Query para esta OP
	If lQuery
		dbSelectArea(cAliasSD3)
		dbCloseArea()
	EndIf
	
	dbSelectArea(cArqTemp2)
	dbSkip()
	
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivos temporarios                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTemp2)
dbCloseArea()
Ferase(cArqTemp2+GetDBExtension())
Ferase(cArqTemp2+OrdBagExt())



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca saldo em processo dos materiais de uso indireto        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

/*/
dbSelectArea("SB1")
dbSeek(xFilial("SB1"))

nReg := SB1->(reccount())

If lObj
	oObj:SetRegua2(nReg)
Endif


While !Eof() .And. !lEnd .And. xFilial("SB1")==B1_FILIAL

    If lObj
     oObj:IncRegua2("Gerando Saldo em Processo uso indireto ")     
    Endif
	
	If !RAvalProd(SB1->B1_COD,mv_par20==1)
		dbSkip()
		Loop
	EndIf
	
	If !(SB1->B1_APROPRI == "I")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("SB2")
	If lListCustMed .Or. (!lListCustMed .And. !lCusfifo)
		aSalatu:=CalcEst(SB1->B1_COD,GetMv("MV_LOCPROC"),dDtFech+1,nil)
	Else
		aSalatu:=CalcEstFF(SB1->B1_COD,GetMv("MV_LOCPROC"),dDtFech+1,nil)
	EndIf
	
	dbSelectArea(cArqTemp)
	dbSetOrder(2)
	RecLock(cArqTemp,!dbSeek(SB1->B1_COD+"USO INDIRETO"))
	Replace OP 	        with PADR("USO INDIRETO",nTmOP)
	Replace TIPO		with SB1->B1_TIPO
	Replace POSIPI		with SB1->B1_POSIPI
	Replace PRODUTO		with SB1->B1_COD
	Replace DESCRICAO	with SB1->B1_DESC
	Replace UM			with SB1->B1_UM
	Replace QUANTIDADE 	with QUANTIDADE + aSalAtu[1]
	Replace TOTAL		with TOTAL + aSalAtu[2]
	If QUANTIDADE>0
		Replace VALOR_UNIT with NoRound(TOTAL/QUANTIDADE,nDecVal)
	EndIf
	If nQuebraAliq <> 1
		If nQuebraAliq == 2
			Replace ALIQ with SB1->B1_PICM
		Else
			Replace ALIQ with IIf(SB0->(MsSeek(xFilial("SB0")+SB1->B1_COD)),SB0->B0_ALIQRED,0)
		EndIf
	EndIf
	MsUnlock()
	
	dbSelectArea("SB1")
	dbSkip()
	
EndDo
/*/

Return Nil


Static Function MontaRel(cArqTemp,oObj)

Local cTipoAnt:= "XX"
Local cQuebra := ""
Local cPosIpi := ""
Local nTotIpi := 0
Local nAliq   := 0
Local cKeyQbr := ""
Local lObj	    := ValType(oObj) == "O"
Local cQuebra2 := ""
Local cKeyQbr2 := ""
Local cProduto := ""
Local nTotQtd  := 0
Local nTotPro  := 0

lSaldProcess:=(mv_par01==1)
lSaldTerceir:=(mv_par02<>2)
cAlmoxIni	:=IIf(mv_par03=="**",Space(02),mv_par03)
cAlmoxFim	:=IIf(mv_par04=="**","ZZ",mv_par04)
cProdIni	:= mv_par05
cProdFim	:= mv_par06
lListProdMov:=(mv_par07==1)
lListProdNeg:=(mv_par08==1)
lListProdZer:=(mv_par09==1)
nPagIni		:= mv_par10
nQtdPag		:= mv_par11
cNrLivro	:= mv_par12
lLivro		:=(mv_par13!=2)
dDtFech		:= mv_par14
lDescrNormal:=(mv_par15==1)
lListCustZer:=(mv_par16==1)
lListCustMed:=(mv_par17==1)
lCalcProcDt	:=(mv_par18==1)
lModProces  :=(mv_par20==1)


If lObj
	oObj:SetRegua2(nReg)
Endif


dbSelectArea(cArqTemp)
dbSetOrder(1)
dbGotop()
While !Eof()


    If lObj
     oObj:IncRegua2("Montando Relatorio..")      
    Endif
	
	cTipoAnt := TIPO
	
	While !Eof() .And. cTipoAnt == TIPO
		
		cPosIpi:=POSIPI
		nTotIpi:=0


		cQuebra := cTipoAnt+cPosIpi
		cKeyQbr := 'TIPO+POSIPI'
		
		
		While !Eof() .And. cQuebra==&(cKeyQbr)

             cProduto := PRODUTO
		     cQuebra2 := cTipoAnt+cPosIpi+cProduto
		     cKeyQbr2 := 'TIPO+POSIPI+PRODUTO'
             nTotQtd  := 0
             nTotPro  := 0

		     While !Eof() .And. cQuebra2==&(cKeyQbr2)

		
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			   //³ Controla impressao de Produtos com saldo negativo ou zerado  ³
			   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  If (!lListProdNeg .And. QUANTIDADE<0) .Or. (!lListProdZer .And. QUANTIDADE==0) .Or. (!lListCustZer .And. TOTAL==0)
			     dbSkip()
			 	 Loop
			   Else
				 nTotIpi+=TOTAL
                 nTotQtd+=QUANTIDADE
                 nTotPro+=TOTAL
				 RAcumula(aTotal)
			  EndIf
			
				AADD(aImp,{	TIPO,;
				            Alltrim(POSIPI),;
				            Alltrim(PRODUTO),;
				            Alltrim(DESCRICAO),;
				            UM,;
				            Transform(QUANTIDADE,IF(TamSX3("B2_QFIM")[2]>3,"@E 99,999,999.999",PesqPict("SB2", "B2_QFIM",14))),;
				            Transform(NoRound(TOTAL/QUANTIDADE,nDecVal),PesqPict("SB2", "B2_CM1",18)),;
				            Transform(TOTAL,"@E 999,999,999,999.99"),;
				            OP,;
                            "",;
                            "",;
				            ""})
			
			  dbSelectArea(cArqTemp)
			  dbSkip()
			
			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³ Salta registros Zerados ou Negativos Conforme Parametros        ³
			  //³ Necessario Ajustar Posicao p/ Totalizacao de Grupos (POSIPI)    ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  While !Eof() .And. ((!lListProdNeg.And.QUANTIDADE<0).Or.(!lListProdZer.And.QUANTIDADE==0).Or.(!lListCustZer.And.TOTAL==0))
				dbSkip()
			  EndDo

			  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			  //³ Verifica se imprime total por Produto                        ³
			  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			  If !(cTipoAnt+cPosIpi+cProduto==TIPO+POSIPI+PRODUTO) 
				 aImp[len(aImp),10] := Transform(nTotQtd,"@E 999,999.999")
				 aImp[len(aImp),11] := Transform(nTotPro,"@E 999,999,999,999.99")
                 nTotQtd := 0
                 nTotPro := 0
			  EndIf
			

			End
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se imprime total por POSIPI.                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//			If !(cTipoAnt+cPosIpi==TIPO+POSIPI) 
//				aImp[len(aImp),12] := Transform(nTotIPI,"@E 999,999,999,999.99")
//			EndIf
			
		End
		
	End
	
End

Return

Static Function RAvalProd(cProduto,lConsMod)
Default lConsMod := .F.
Return(cProduto>=cProdIni.And.cProduto<=cProdFim) .And. IIf(lConsMod,.T.,!IsProdMod(cProduto))

Static Function RAcumula(aTotal)

Local nPos:=0

nPos:=Ascan(aTotal,{|x|x[1]=="X".And.x[2]==TIPO})
If nPos==0
	AADD(aTotal,{"X",TIPO,QUANTIDADE,VALOR_UNIT,TOTAL})
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
EndIf

nPos:=Ascan(aTotal,{|x|x[1]=="T".And.x[2]=="TT"})
If nPos==0
	AADD(aTotal,{"T","TT",QUANTIDADE,VALOR_UNIT,TOTAL})
Else
	aTotal[nPos,3]+=QUANTIDADE
	aTotal[nPos,4]+=VALOR_UNIT
	aTotal[nPos,5]+=TOTAL
EndIf

Return Nil

Static Function TelaProcesso()

Local aSize    := {}
Local aObjects := {}       
Local aInfo    := {}
Local cCabec   := "Reg. Inventario de Produtos em Processo"
Private aPosObj  := {}
Private oDlg2 
Private oListBox2, bLine2
Private cTitulo2 := "Inventario - Processos"
Private aHead_2  := {"TIPO","POSIPI","PRODUTO","DESCRICAO","UM","QTD","VLR.UNIT.","VLR.TOTAL","OP","TOT QTD","TOT PROD","TOT IPI"}  
Private cLine2   := "{ aImp[oListBox2:nAt][1] "

For nI:=2 To Len(aHead_2)
	cLine2 += " ,aImp[oListBox2:nAt][" + AllTrim(Str(nI)) + "]"
Next
cLine2 += "}"
bLine2 := &( "{|| " + cLine2 + "}" )                                                                             

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


DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM aSize[7],0 TO aSize[6],aSize[5] OF GetWndDefault() Pixel


	SButton():New(aPosObj[2][3] + 3, aPosObj[2][4] - 30 , 01 , { || oDlg2:End() }, oDlg2, .T. )
	tButton():New(aPosObj[2][3] + 3,aPosObj[2][4] - 250, "Excel", , { || MsAguarde ( { || DlgToExcel({ {"ARRAY",cCabec,aHead_2,aImp} }) } )}, 085, 010 ,,,,.T.)  

	oListBox2 := TWBrowse():New( aPosObj[2][1],aPosObj[2][2]-100,aPosObj[2][4]-10,aPosObj[2][3]-20,,aHead_2,,oDlg2,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox2:SetArray(aImp)
	oListBox2:bLine := bLine2


ACTIVATE DIALOG oDlg2  CENTERED 


Return