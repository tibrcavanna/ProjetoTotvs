#Include "Rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTDescrNFEºAutor  ³Marcelo Henrique    º Data ³  18/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Editar a descrição a ser utilizada nos itens do RPS conformeº±±
±±º          ³os produtos informados                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 Recompur                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//   MTDESCRNFE                               enfield42
User Function ImportPed()
Private lMsErroAuto:= .f.
cIndex := CriaTrab(Nil, .F.)
dbUseArea(.T., "DBFCDX", "\PEDIDOST.DBF", "PEDIDO", .T., .F.)
dbSelectArea("PEDIDO")
IndRegua("PEDIDO", cIndex, "CLIENTE+LOJA", , , "Selecionando Registros...")
dbGoTop()    
Processa({|| IniProc()}, "Processando arquivo, Por favor aguarde.")

Static Function IniProc()

While PEDIDO->(!EOF())
	
	dbSelectArea("SA1")
	
	IF SA1->(!dbSeek(xFilial("SA1")+substr(PEDIDO->CLIENTE,1,6)+substr(PEDIDO->LOJA,1,2)))
		dbSelectArea("PEDIDO")
		PEDIDO->(dbSkip())
		Loop
	Endif
		If EMPTY(SA1->A1_X_OPER=="PAG")
		cOper := "08"
	Else
		cOper := "01"
	EndIf

	dbSelectArea("CC2")
	  
	IF cc2->(!dbSeek(xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN))                               
	vFrete := 0.00
	Else
		vFrete := CC2->CC2_FRETE
	Endif
	
	cNumSC5 := GetSXENum("SC5","C5_NUM")
	RollBAckSx8()
	
	aCab:={	{"C5_NUM",	cNumSC5,    Nil},; 	// Numero do pedido
	{"C5_TIPO"   ,	"N"    ,	    Nil},; 	// Tipo de pedido	//{"C5_FILIAL" ,"01"             ,Nil},;
	{"C5_CLIENTE",	SA1->A1_COD    ,Nil},; 	// Codigo do cliente
	{"C5_LOJAENT",	SA1->A1_LOJA   ,Nil},; 	// Loja para entrada
	{"C5_LOJACLI",	SA1->A1_LOJA   ,Nil},; 	// Loja do cliente	
	{"C5_MENNOTA",	PEDIDO->MENNOTA,Nil},; 	// Mensagem Para Nota
	{"C5_FRETE"  ,	CC2->CC2_FRETE ,Nil},; 	// Valoro Frete
	{"C5_X_OPER"  ,	SA1->A1_X_OPER ,Nil},; 	// Valoro Frete
	{"C5_CONDPAG",	SA1->A1_COND   ,Nil}} 	// Codigo da condicao de pagamanto 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza sequencia do item            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cItemSC6 := strZero(1,TamSX3("C6_ITEM")[1])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o campo TS dos itens da medição    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aItem:={}
	aItens:={}
	//	aAdd(aItem,{})
	cCliente := PEDIDO->CLIENTE+PEDIDO->LOJA

	While cCliente == PEDIDO->CLIENTE+PEDIDO->LOJA
		IF SB1->(!dbSeek(xFilial("SB1")+substr(PEDIDO->PRODUTO,1,15)))
			dbSelectArea("PEDIDO")
			PEDIDO->(dbSkip())
			Loop
		ENDIF
	
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera item do pedido de venda          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aItem:={}
				  
  aadd(aItem,{"C6_ITEM",cItemSC6,Nil})			
  aadd(aItem,{"C6_PRODUTO",SB1->B1_COD  ,Nil})			
  aadd(aItem,{"C6_QTDVEN",PEDIDO->QTDE  ,Nil})			
  aadd(aItem,{"C6_PRCVEN",PEDIDO->VLUNIT,Nil})			
  aadd(aItem,{"C6_PRUNIT",PEDIDO->VLUNIT,Nil})			
//  aadd(aItem,{"C6_VALOR",PEDIDO->VLTOTAL,Nil})			
  aadd(aItem,{"C6_OPER",cOper           ,Nil})	
/*				
				aadd(aItem,{"C6_ITEM"    ,cItemSC6        ,Nil})// Numero do Pedido
				aadd(aItem,{"C6_PRODUTO" ,SB1->B1_COD     ,Nil})// Codigo do Produto
				//aadd(aItem,{"C6_UM"      ,SB1->B1_UM      ,Nil})// Unidade de Medida Primar.
				aadd(aItem,{"C6_QTDVEN"  ,PEDIDO->QTDE    ,Nil})// Quantidade Vendida
		  //		aadd(aItem,{"C6_QTDLIB"	 ,PEDIDO->QTDE    ,Nil})// Quantidade Vendida
				aadd(aItem,{"C6_PRCVEN"  ,PEDIDO->VLUNIT  ,Nil})// Preco Unitario Liquido
				aadd(aItem,{"C6_PRUNIT"  ,PEDIDO->VLUNIT  ,Nil})// Preco Unitario Liquido
				aadd(aItem,{"C6_VALOR"   ,PEDIDO->VLTOTAL ,Nil})// Valor Total do Item
			   //	aadd(aItem,{"C6_LOCAL"   ,SB1->B1_LOCPAD  ,Nil})// Local
			 //	aadd(aItem,{"C6_DESCRI"  ,SB1->B1_DESC    ,Nil})// Descricao
		   //		aadd(aItem,{"C6_ENTREG"  ,dDatabase       ,Nil})// Data da Entrega
		 //		aadd(aItem,{"C6_CLI"     ,SA1->A1_COD     ,Nil})// Cliente
		 //		aadd(aItem,{"C6_LOJA"    ,SA1->A1_LOJA    ,Nil})// Loja do Cliente
				aadd(aItem,{"C6_TES"     ,cTes            ,Nil})// TES
				//aadd(aItem,{"C6_CF"      ,"5405"          ,Nil})// CFOP
				//aadd(aItem,{"C6_NUM"     ,cNumSC5         ,Nil})// Numero do Item no Pedido
        */
				aadd(aItens,aItem)
		cItemSC6 := If(Empty(cItemSC6),strZero(1,TamSX3("C6_ITEM")[1]),Soma1(cItemSC6))
		dbSelectArea("PEDIDO")                                                               
		
		PEDIDO->(dbSkip())
	Enddo
	
	MsExecAuto({|x,y,z| mata410(x,y,z) }, aCab,    aItens,3)
	If lMsErroAuto
		MostraErro()
	Else
	EndIf
//	ProcRegua(PEDIDO->(RecCount()))
	cNumPed := SC5->C5_NUM
	dbSelectArea("PEDIDO")
	
Enddo



