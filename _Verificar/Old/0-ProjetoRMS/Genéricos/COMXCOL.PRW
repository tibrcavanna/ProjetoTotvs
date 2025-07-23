#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPConn.ch'
#INCLUDE 'COMXCOL.ch'
#INCLUDE "FILEIO.CH"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COMXCOL  ºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fonte com as funcoes do monitor e engines de Compras para  º±±
±±º          ³ TOTVS Colaboracao.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras X TOTVS Colaboracao                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ComXColab ºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monitor de Compras para Totvs Colaboracao                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras X TOTVS Colaboracao                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function COMXCOL()
Local aCores  	:= {}
Local aCoresNew	:= {}
Local aIndSDS	:= {}
Local lRet    	:= .T.
Local lInverte  := .F.
Local cFilBrw 	:= ""
Local cFilSQL 	:= ""

Private lMVImpXML  := SuperGetMv("MV_IMPXML",.F.,.F.) .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
Private aRotina	  := MenuDef()
Private cMarca	  := GetMark()
Private cCadastro := Iif(lMVImpXML,STR0190,STR0001) //-- "Importador XML" ## Monitor TOTVS Colaboração
Private aRegMark  := {}
Private lToma4NFOri	:= .T.
Private cFilQry     := ''

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01: Documento de 					³
//³ mv_par02: Documento ate 				³
//³ mv_par03: Serie de 						³
//³ mv_par04: Serie ate 					³
//³ mv_par05: Fornecedor de 				³
//³ mv_par06: Fornecedor ate 				³
//³ mv_par07: Emissao de 					³
//³ mv_par08: Emissao ate 					³
//³ mv_par09: Importacao de 				³
//³ mv_par10: Importacao ate 				³
//³ mv_par11: Mostra gerados: 1=Sim ; 2=Nao	³
//³ mv_par12: Quanto ao PC					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. Pergunte("MTA140I",.T.)
	aAdd(aCores,{'DS_STATUS == "P"','BR_VERMELHO'})	// -- "Documento Gerado"
	aAdd(aCores,{'DS_STATUS == "E"','BR_PRETO'})	// -- "Documento c/ Ocorrência"
	aAdd(aCores,{'DS_TIPO == "N"','BR_VERDE'})		// -- "Documento Normal"
	aAdd(aCores,{'DS_TIPO == "O"','BR_AZUL'})		// -- "Docto. de Bonificação"
	aAdd(aCores,{'DS_TIPO == "D"','BR_AMARELO'})	// -- "Docto. de Devolução"
	aAdd(aCores,{'DS_TIPO == "B"','BR_CINZA'})		// -- "Docto. de Beneficiamento"
	aAdd(aCores,{'DS_TIPO == "C"','BR_PINK'})		// -- "Docto. de Compl. Preço"
	aAdd(aCores,{'DS_TIPO == "T"','BR_LARANJA'})	// -- "Docto. de Transporte"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para incluir/alterar opcoes de cores de legenda no Browse ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("COMXACOR")
		aCoresNew := ExecBlock("COMXACOR",.F.,.F.,{aCores})
		If ValType(aCoresNew) == "A"
			aCores := aCoresNew
		EndIf
	EndIf

	//-- Monta filtro ISAM
	cFilBrw := 'DS_DOC >= "' +mv_par01 +'" .And. DS_DOC <= "' +mv_par02 +'" .And. '
	cFilBrw += SerieNfId("SDS",3,"DS_SERIE") + ' >= "' +mv_par03 +'" .And. ' + SerieNFId("SDS",3,"DS_SERIE") + '<= "' +mv_par04 +'" .And. '
	cFilBrw += 'DS_FORNEC >= "' +mv_par05 +'" .And. DS_FORNEC <= "' +mv_par06 +'" .And. '
	cFilBrw += 'DToS(DS_EMISSA) >= "'  +DToS(mv_par07) +'" .And. DToS(DS_EMISSA) <= "'  +DToS(mv_par08) +'" .And. '
	cFilBrw += 'DToS(DS_DATAIMP) >= "'  +DToS(mv_par09) +'" .And. DToS(DS_DATAIMP) <= "'  +DToS(mv_par10) +'"'
	If mv_par11 == 2
		cFilBrw += ' .And. DS_STATUS <> "P"'
	EndIf
	
	// ATENCAO:
	// Filtro identico ao feito acima, mas em sintaxe SQL. Quando alterar o filtro acima, 
	// incluir o mesmo criterio na query abaixo.
	cFilQry := "DS_DOC >= '" + mv_par01 + "' AND DS_DOC <= '" + mv_par02 + "' AND "
	cFilQry += SerieNfId("SDS",3,"DS_SERIE") + " >= '" + mv_par03 + "' AND " + SerieNfId("SDS",3,"DS_SERIE") + " <= '" + mv_par04 + "' AND "
	cFilQry += "DS_FORNEC >= '" + mv_par05 + "' AND DS_FORNEC <= '" + mv_par06 + "' AND "
	cFilQry += "DS_EMISSA >= '" + DToS(mv_par07) + "' AND DS_EMISSA <= '" + DToS(mv_par08) + "' AND "
	cFilQry += "DS_DATAIMP >= '" + DToS(mv_par09) + "' AND DS_DATAIMP <= '" + DToS(mv_par10) + "'"
	
	If MV_PAR11 == 2
		
		cFilQry += " AND DS_STATUS <> 'P'"
		
	EndIf
	MsgRun(STR0002,STR0003,{|| CursorWait(),CursorArrow(),MarkBrow("SDS","DS_OK",'DS_STATUS == "P"',,lInverte,cMarca,'COMXALL()',,,,'ComXMark(1)',,,,aCores,,,cFilBrw)}) //-- Aplicando filtros e preparando inferface... # Aguarde
	
	//Limpando a marca ao sair da tela
	COMXALL(1)
EndIf
                    
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  ºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta as opcoes de rotina.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOL                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotAlt		:= {}
PRIVATE aRotina	:= {}

aAdd(aRotina,{STR0039,"PesqBrw"		,0,1,0,.F.}) 					// Pesquisar
aAdd(aRotina,{STR0052,"StaticCall(COMXCOL,Visualizar)",0,2,0,NIL})	// Visualizar
aAdd(aRotina,{"Alterar","StaticCall(COMXCOL,Vincular)",0,4,0,nil})	// Vinc. Docto
aAdd(aRotina,{STR0054,"StaticCall(COMXCOL,GerarDocs)",0,4,0,nil}) 	// Gerar Docto
aAdd(aRotina,{STR0056,"StaticCall(COMXCOL,Excluir)",0,4,0,nil})   	// Excluir
aAdd(aRotina,{STR0057,"StaticCall(COMXCOL,Reprocessa)",0,3,0,nil})	// Reprocessar
aAdd(aRotina,{STR0051,"StaticCall(COMXCOL,Legenda)",0,5,0,.F.})	// Legenda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novos itens no menu aRotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("COMCOLRT")
	aRotAlt := ExecBlock("COMCOLRT",.F.,.F.,{aRotina})
	If ValType(aRotAlt) == 'A'
		aRotina := aRotAlt
	Endif
Endif

Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VisualizarºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta interface pra visualizacao do documento.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Visualizar()
Return MontaTela(2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Vincular ºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta interface vinculo do documento com pedidos/nf origem.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Vincular()
Local lRet := .T.
Local lRemet := .F.

If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F" // Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve permitir vincular pedido
	lRemet := .T.
EndIf

If SDS->DS_STATUS == "P"
	Aviso(STR0004,STR0005,{"OK"}) //-- Atenção # Esta ação não pode ser executada para documentos já gerados.
	lRet := .F.
EndIf
     
If !(SDS->DS_TIPO $ "NDC")
	If !lRemet							// Quando for CT-e referente a envio de mercadoria deve permitir vinculo com pedido, caso contrario nao deve permitir
		Aviso(STR0004,STR0006,{"OK"})	//-- Atenção # Esta ação pode ser executada apenas para documentos do tipo Normal, Devolução, Complemento ou CT-e referente a envio de mercadoria.
		lRet := .F.
	EndIf
EndIf

If lRet
	lRet := MontaTela(4)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COMITIG ºAutor  ³ Rodrigo M Pontes    º Data ³  09/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca por produto iguais em itens diferentes na NF originalº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function COMITIG(cForDel,cLojDel,cDocDel,cSerDel )

Local cQuery	:= ""
Local aRet		:= {}

If Select("ITIG") > 0
	ITIG->(DbCloseArea())
Endif

cQuery := " SELECT DT_COD,"
cQuery += "        Count(*) AS QTD_PRD"
cQuery += " FROM " + RetSqlName("SDT")
cQuery += " WHERE  D_E_L_E_T_ = '*'"
cQuery += " AND DT_FORNEC = '" +cForDel + "' AND DT_LOJA = '" +cLojDel + "'" 
cQuery += " AND DT_DOC = '" +cDocDel + "' AND DT_SERIE = '" +cSerDel + "'"
cQuery += " AND DT_ORIGIN = '1'"
cQuery += " GROUP  BY DT_COD"
cQuery += " HAVING Count(*) > 1"

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"ITIG",.T.,.T.)

DbSelectArea("ITIG")
While ITIG->(!EOF())
	aAdd(aRet,ITIG->DT_COD)
	ITIG->(DbSkip())
Enddo

ITIG->(DbCloseArea())

If Len(aRet) == 0
	If Select("IGIT") > 0
		IGIT->(DbCloseArea())
	Endif

	cQuery := " SELECT DT_COD,"
	cQuery += "        Count(*) AS QTD_PRD"
	cQuery += " FROM " + RetSqlName("SDT")
	cQuery += " WHERE  D_E_L_E_T_ = ''"
	cQuery += " AND DT_FORNEC = '" +cForDel + "' AND DT_LOJA = '" +cLojDel + "'" 
	cQuery += " AND DT_DOC = '" +cDocDel + "' AND DT_SERIE = '" +cSerDel + "'"
	cQuery += " AND DT_ORIGIN = ''"
	cQuery += " GROUP  BY DT_COD"
	cQuery += " HAVING Count(*) > 1"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"IGIT",.T.,.T.)
	
	DbSelectArea("IGIT")
	While IGIT->(!EOF())
		aAdd(aRet,IGIT->DT_COD)
		IGIT->(DbSkip())
	Enddo
	
	IGIT->(DbCloseArea())
Endif

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GDNFORIG ºAutor  ³ Rodrigo M Pontes   º Data ³  09/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca pelo NF original, quando foi importada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GDNFORIG(aNoFields,cForDel,cLojDel,cDocDel,cSerDel,nTNF)

Local cQuery		:= ""
Local nX			:= 0
Local aColsNFORIG	:= {}

Default nTNF := 0

If Select("GDNF") > 0
	GDNF->(DbCloseArea())
Endif

If Len(aHeader) == 0
	aHeader := GetaHeader("SDT",,aNoFields,,,)
Endif
	
For nX := 1 To Len(aHeader)
	If SDT->(FieldPos(aHeader[nX,2])) > 0
		If Empty(cQuery)
			cQuery := " SELECT " + AllTrim(aHeader[nX,2])
		Else
			cQuery += " , " + AllTrim(aHeader[nX,2])
		Endif
	Endif
Next nX

cQuery += " FROM " + RetSqlName("SDT")
cQuery += " WHERE DT_FILIAL = '" +xFilial("SDT") + "' "
cQuery += " AND DT_FORNEC = '" +cForDel + "' AND DT_LOJA = '" +cLojDel + "'" 
cQuery += " AND DT_DOC = '" +cDocDel + "' AND DT_SERIE = '" +cSerDel + "'" 
cQuery += " AND DT_ORIGIN = '1' AND D_E_L_E_T_ = '*' "
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"GDNF",.T.,.T.)

DbSelectArea("GDNF")
If GDNF->(!EOF())
	While GDNF->(!EOF())
		AAdd(aColsNFORIG,Array(Len(aHeader)+1))
		
		For nX := 1 to Len(aHeader)
			If IsHeadRec(aHeader[nX][2])
			    aColsNFORIG[Len(aColsNFORIG)][nX] := 0
			ElseIf IsHeadAlias(aHeader[nX][2])
			    aColsNFORIG[Len(aColsNFORIG)][nX] := "SDT"
			Else
				If SDT->(FieldPos(aHeader[nX,2])) > 0
					aColsNFORIG[Len(aColsNFORIG)][nX] := &("GDNF->"+aHeader[nX][2])
				Endif
			EndIf
			aColsNFORIG[Len(aColsNFORIG)][Len(aHeader)+1] := .F.
		Next nX
		
		GDNF->(DbSkip())
	Enddo
Endif

GDNF->(DbCloseArea())

If Len(aColsNFORIG) == 0
	If Select("NFGD") > 0
		NFGD->(DbCloseArea())
	Endif
	
	cQuery := ""
	For nX := 1 To Len(aHeader)
		If SDT->(FieldPos(aHeader[nX,2])) > 0
			If Empty(cQuery)
				cQuery := " SELECT " + AllTrim(aHeader[nX,2])
			Else
				cQuery += " , " + AllTrim(aHeader[nX,2])
			Endif
		Endif
	Next nX
	
	cQuery += " FROM " + RetSqlName("SDT")
	cQuery += " WHERE DT_FILIAL = '" +xFilial("SDT") + "' "
	cQuery += " AND DT_FORNEC = '" +cForDel + "' AND DT_LOJA = '" +cLojDel + "'" 
	cQuery += " AND DT_DOC = '" +cDocDel + "' AND DT_SERIE = '" +cSerDel + "'" 
	cQuery += " AND DT_ORIGIN = '' AND D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"NFGD",.T.,.T.)
	
	DbSelectArea("NFGD")
	If NFGD->(!EOF())
		While NFGD->(!EOF())
			AAdd(aColsNFORIG,Array(Len(aHeader)+1))
			
			For nX := 1 to Len(aHeader)
				If IsHeadRec(aHeader[nX][2])
				    aColsNFORIG[Len(aColsNFORIG)][nX] := 0
				ElseIf IsHeadAlias(aHeader[nX][2])
				    aColsNFORIG[Len(aColsNFORIG)][nX] := "SDT"
				Else
					If SDT->(FieldPos(aHeader[nX,2])) > 0
						aColsNFORIG[Len(aColsNFORIG)][nX] := &("NFGD->"+aHeader[nX][2])
					Endif
				EndIf
				aColsNFORIG[Len(aColsNFORIG)][Len(aHeader)+1] := .F.
			Next nX
			
			NFGD->(DbSkip())
		Enddo
	Endif
	
	NFGD->(DbCloseArea())
Endif	

Return aColsNFORIG

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MontaTela ºAutor  ³Microsiga           º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta interface de visualização e vinculo do documeto.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc: opcao de rotina acionada (2=Visualizar;4Vincular)	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Visualizar e Vincular                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaTela(nOpc)
Local lRet   	:= .F.
Local oDlg      := NIL
Local oEnchoice := NIL
Local oFolder	:= NIL
Local oComboFrt := NIL
Local oSize     := FwDefSize():New()
Local aCpsAlt	:= If(nOpc == 4,{"DT_NFORI","DT_SERIORI","DT_ITEMORI","DT_TES"},{})
Local aUsrCpo	:= {}
Local aNoFields := {}
Local aButtons  := {}
Local aPosCab   := {}
Local aPosIts   := {}
Local aPosRdp	:= {}
Local aFolders  := {STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0184} //-- Totais # Dados DANFE # Dados da NF-e # Dados da Importação # Dados da Geração # Ocorrência # Impostos
Local cSeek	    := ""
Local cStatus	:= ""
Local bWhile	:= {|| SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE)}
Local nTotDoc	:= Iif(SDS->DS_TIPO<>"T",SDS->(DS_VALMERC+DS_DESPESA+DS_FRETE+DS_SEGURO-DS_DESCONT),SDS->(DS_VALMERC+DS_DESPESA+DS_SEGURO-DS_DESCONT))
Local nX		:= 0
Local nY		:= 0
Local nMultPC	:= 0
Local nPosPed	:= 0
Local nPosItPC	:= 0

Local aColsAnt  := {}
Local cFilBkp   := cFilAnt
Local lRemet	:= .F.
Local lGrava	:= .T.
Local cFilSDT	:= xFilial("SDT")

Private aHeader   := {}
Private aCols	  := {}
Private aHeadImp	:= {}	
Private aColsImp	:= {}
Private oGetDados	:= NIL
Private oNewGet		:= NIL

//-- Se filial diferente, troca
If PadR(cFilAnt,Len(AllTrim(SDS->DS_FILIAL))) # AllTrim(SDS->DS_FILIAL)
	Do Case
		Case FWModeAccess("SB2",3) == "E"
			cFilAnt := SDS->DS_FILIAL
		Case FWModeAccess("SB2",2) == "E" .Or. FWModeAccess("SB2",1) == "E"
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt+SDS->DS_FILIAL))
			cFilAnt := SM0->M0_CODFIL
	EndCase
EndIf

cSeek := cFilSDT+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
									
oSize:AddObject("CABEC",100,20,.T.,.T.) // Totalmente dimensionavel
oSize:AddObject("ITENS",100,40,.T.,.T.) // Totalmente dimensionavel 
oSize:AddObject("RODAP",100,40,.T.,.T.) // Totalmente dimensionavel
oSize:lProp := .T. 						 // Proporcional             
oSize:aMargins := {0,0,0,3}			  	 // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() 	   					 // Dispara os calculos de coordenadas

aPosCab := {oSize:GetDimension("CABEC","LININI"),oSize:GetDimension("CABEC","COLINI"),;
			oSize:GetDimension("CABEC","LINEND"),oSize:GetDimension("CABEC","COLEND")}
aPosIts := {oSize:GetDimension("ITENS","LININI"),oSize:GetDimension("ITENS","COLINI"),;
			oSize:GetDimension("ITENS","LINEND"),oSize:GetDimension("ITENS","COLEND")}
aPosRdp := {oSize:GetDimension("RODAP","LININI"),oSize:GetDimension("RODAP","COLINI"),;
			oSize:GetDimension("RODAP","LINEND"),oSize:GetDimension("RODAP","COLEND")}

//-- Tratamento para que seja possivel alterar os campos da nota origem
If nOpc == 4 .And. SDS->DS_TIPO $ "DC"
	aRotina[2,4] := 6
EndIf

// Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve exibir os campos para vinculo com pedido
If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F"
	lRemet := .T.
EndIf

//-- Retira campos que nao sao usados pelo tipo de documento
If SDS->DS_TIPO $ "DC"
	aNoFields := {"DT_PEDIDO","DT_ITEMPC"}
ElseIf SDS->DS_TIPO == "N"
	aNoFields := {"DT_NFORI","DT_SERIORI","DT_ITEMORI"}
ElseIf SDS->DS_TIPO == "T"
	If lRemet
		aNoFields := {"DT_PRODFOR","DT_DESCFOR","DT_NFORI","DT_SERIORI","DT_ITEMORI"}
	Else
		aNoFields := {"DT_PRODFOR","DT_DESCFOR","DT_PEDIDO","DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI"}
	EndIf
Else
	aNoFields := {"DT_PEDIDO","DT_ITEMPC","DT_NFORI","DT_SERIORI","DT_ITEMORI"}
EndIf

RegToMemory("SDS",.F.,.T.)

//nOpc = 6 ->Nota Original
If nOpc <> 6
	FillGetDados(2,"SDT",3,cSeek,bWhile,,aNoFields,,,,,.F.,@aHeader,@aCols,{||ColAtuLeg(@aHeader,@aCols)})
Else
	aCols := GDNFORIG(aNoFields,SDS->DS_FORNEC,SDS->DS_LOJA,SDS->DS_DOC,SDS->DS_SERIE)
Endif

//-- Limpa descrição do campo para ajustar tamanho na tela.
If (nPosLeg:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_LEGENDA"})) > 0
	aHeader[nPosLeg][1] := ""
Endif

aSort(aCols,,,{|x,y| x[GDFieldPos("DT_ITEM")] < y[GDFieldPos("DT_ITEM")]}) //-- Ordena por item

For nX := 1 To Len(aCols)
	If Empty(AllTrim(aCols[nX][GdFieldPos("DT_DESC")]))
		aCols[nX][GdFieldPos("DT_DESC")] := Posicione("SB1",1,xFilial("SB1") + PadR(aCols[nX][GdFieldPos("DT_COD")],TamSx3("B1_COD")[1]),"B1_DESC")
	Endif
Next nX

aUsrCpo := ComxUsrCpo(@aCpsAlt) // -- Validar campos de usuário na SDT
aColsAnt := aClone(aCols)
Define MsDialog oDlg From oSize:aWindSize[1],oSize:aWindSize[2] To oSize:aWindSize[3],oSize:aWindSize[4];
					 Title STR0001 +" - " +If(nOpc == 2,STR0013,STR0014) Of oMainWnd Pixel //-- Monitor TOTVS Colaboração # Visualização # Vincular Documento

oEnchoice := MsMGet():New("SDS",,2,,,,,aPosCab,,,,,,oDlg) 
oGetDados := MsNewGetDados():New(aPosIts[1],aPosIts[2],aPosIts[3],aPosIts[4],If(nOpc==4 .Or. nOpc==2 .Or. nOpc == 6,2,4),,,,aCpsAlt,,Len(aCols)/*9999*/,,,,oDlg,@aHeader,@aCols)
oFolder   := TFolder():New(aPosRdp[1],aPosRdp[2],aFolders,,oDlg,,,,.T.,,aPosRdp[4]-aPosRdp[2],aPosRdp[3]-aPosRdp[1])

//-- Montagem dos campos do rodape

//-- Vlr. Mercadoria
TSay():New(10,10,{|| RetTitle("DS_VALMERC")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
TGet():New(08,70,{|| SDS->DS_VALMERC},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_VALMERC"),,,,,,,.T.,,,,,,,.T.,,,"DS_VALMERC")
//-- Vlr. Frete
TSay():New(30,10,{|| RetTitle("DS_FRETE")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
TGet():New(28,70,{|| Iif(SDS->DS_TIPO<>"T",SDS->DS_FRETE,0)},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_FRETE"),,,,,,,.T.,,,,,,,.T.,,,"DS_FRETE")
//-- Vlr. Seguro
TSay():New(10,180,{|| RetTitle("DS_SEGURO")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
TGet():New(08,250,{|| SDS->DS_SEGURO},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_SEGURO"),,,,,,,.T.,,,,,,,.T.,,,"DS_SEGURO")
//-- Vlr. Despesas
TSay():New(30,180,{|| RetTitle("DS_DESPESA")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
TGet():New(28,250,{|| SDS->DS_DESPESA},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_DESPESA"),,,,,,,.T.,,,,,,,.T.,,,"DS_DESPESA")
//-- Descontos
TSay():New(10,350,{|| RetTitle("DS_DESCONT")},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
TGet():New(08,430,{|| SDS->DS_DESCONT},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_DESCONT"),,,,,,,.T.,,,,,,,.T.,,,"DS_DESCONT")
//-- Total do documento
TSay():New(70,10,{|| "Total do documento"},oFolder:aDialogs[1],,,,,,.T.,,,50,10)
TGet():New(68,70,{|| nTotDoc},oFolder:aDialogs[1],50,10,PesqPict("SDS","DS_VALMERC"),,,,,,,.T.,,,,,,,.T.,,,"nTotDoc")

//-- Transportadora
TSay():New(10,10,{|| RetTitle("DS_TRANSP")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(08,50,{|| SDS->DS_TRANSP},oFolder:aDialogs[2],40,10,PesqPict("SDS","DS_TRANSP"),,,,,,,.T.,,,,,,,.T.,,,"DS_TRANSP")
//-- Placa
TSay():New(30,10,{|| RetTitle("DS_PLACA")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(28,50,{|| SDS->DS_PLACA},oFolder:aDialogs[2],40,10,PesqPict("SDS","DS_PLACA"),,,,,,,.T.,,,,,,,.T.,,,"DS_PLACA")
//-- Peso Liquido
TSay():New(10,110,{|| RetTitle("DS_PLIQUI")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(08,160,{|| SDS->DS_PLIQUI},oFolder:aDialogs[2],70,10,PesqPict("SDS","DS_PLIQUI"),,,,,,,.T.,,,,,,,.T.,,,"DS_PLIQUI")
//-- Peso Bruto
TSay():New(30,110,{|| RetTitle("DS_PBRUTO")},oFolder:aDialogs[2],,,,,,.T.,,,5400,10)
TGet():New(28,160,{|| SDS->DS_PBRUTO},oFolder:aDialogs[2],70,10,PesqPict("SDS","DS_PBRUTO"),,,,,,,.T.,,,,,,,.T.,,,"DS_PBRUTO")
//-- Tipo de frete
TSay():New(50,10,{|| RetTitle("DS_TPFRETE")},oFolder:aDialogs[2],,,,,,.T.,,,5400,10)
oComboFrt := TComboBox():New(48,50,{|| SDS->DS_TPFRETE},{"C=CIF","F=FOB","T=Por Terceiros","S=Sem Frete"},70,10,oFolder:aDialogs[2],,,,,,.T.,,,,,,,,,"DS_TPFRETE")
oComboFrt:Disable()
//-- Especie 1
TSay():New(10,290,{|| RetTitle("DS_ESPECI1")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(08,330,{|| SDS->DS_ESPECI1},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI1"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI1")
//-- Especie 2
TSay():New(30,290,{|| RetTitle("DS_ESPECI2")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(28,330,{|| SDS->DS_ESPECI2},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI2"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI2")
//-- Especie 3
TSay():New(50,290,{|| RetTitle("DS_ESPECI3")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(48,330,{|| SDS->DS_ESPECI3},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI3"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI3")
//-- Especie 4
TSay():New(70,290,{|| RetTitle("DS_ESPECI4")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(68,330,{|| SDS->DS_ESPECI4},oFolder:aDialogs[2],90,10,PesqPict("SDS","DS_ESPECI4"),,,,,,,.T.,,,,,,,.T.,,,"DS_ESPECI4")
//-- Volume 1
TSay():New(10,440,{|| RetTitle("DS_VOLUME1")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(08,480,{|| SDS->DS_VOLUME1},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME1"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME1")
//-- Volume 2
TSay():New(30,440,{|| RetTitle("DS_VOLUME2")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(28,480,{|| SDS->DS_VOLUME2},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME2"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME2")
//-- Volume 3
TSay():New(50,440,{|| RetTitle("DS_VOLUME3")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(48,480,{|| SDS->DS_VOLUME3},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME3"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME3")
//-- Volume 4
TSay():New(70,440,{|| RetTitle("DS_VOLUME4")},oFolder:aDialogs[2],,,,,,.T.,,,40,10)
TGet():New(68,480,{|| SDS->DS_VOLUME4},oFolder:aDialogs[2],50,10,PesqPict("SDS","DS_VOLUME4"),,,,,,,.T.,,,,,,,.T.,,,"DS_VOLUME4")

//-- Chave NF-e
TSay():New(10,10,{|| RetTitle("DS_CHAVENF")},oFolder:aDialogs[3],,,,,,.T.,,,50,10)
TGet():New(08,70,{|| SDS->DS_CHAVENF},oFolder:aDialogs[3],230,10,PesqPict("SDS","DS_CHAVENF"),,,,,,,.T.,,,,,,,.T.,,,"DS_CHAVENF")
//-- Versao NF-e
TSay():New(30,10,{|| RetTitle("DS_VERSAO")},oFolder:aDialogs[3],,,,,,.T.,,,50,10)
TGet():New(28,70,{|| SDS->DS_VERSAO},oFolder:aDialogs[3],50,10,PesqPict("SDS","DS_VERSAO"),,,,,,,.T.,,,,,,,.T.,,,"DS_VERSAO")
//-- Nome do arquivo
TSay():New(50,10,{|| RetTitle("DS_ARQUIVO")},oFolder:aDialogs[3],,,,,,.T.,,,50,10)
TGet():New(48,70,{|| SDS->DS_ARQUIVO},oFolder:aDialogs[3],230,10,PesqPict("SDS","DS_ARQUIVO"),,,,,,,.T.,,,,,,,.T.,,,"DS_ARQUIVO")

//-- Usuario
TSay():New(10,10,{|| RetTitle("DS_USERIMP")},oFolder:aDialogs[4],,,,,,.T.,,,50,10)
TGet():New(08,70,{|| SDS->DS_USERIMP},oFolder:aDialogs[4],100,10,PesqPict("SDS","DS_USERIMP"),,,,,,,.T.,,,,,,,.T.,,,"DS_USERIMP")
//-- Data
TSay():New(30,10,{|| RetTitle("DS_DATAIMP")},oFolder:aDialogs[4],,,,,,.T.,,,50,10)
TGet():New(28,70,{|| SDS->DS_DATAIMP},oFolder:aDialogs[4],50,10,PesqPict("SDS","DS_DATAIMP"),,,,,,,.T.,,,,,,,.T.,,,"DS_DATAIMP")
//-- Hora
TSay():New(50,10,{|| RetTitle("DS_HORAIMP")},oFolder:aDialogs[4],,,,,,.T.,,,50,10)
TGet():New(48,70,{|| SDS->DS_HORAIMP},oFolder:aDialogs[4],50,10,PesqPict("SDS","DS_HORAIMP"),,,,,,,.T.,,,,,,,.T.,,,"DS_HORAIMP")

//-- Usuario
TSay():New(10,10,{|| RetTitle("DS_USERPRE")},oFolder:aDialogs[5],,,,,,.T.,,,50,10)
TGet():New(08,70,{|| SDS->DS_USERPRE},oFolder:aDialogs[5],100,10,PesqPict("SDS","DS_USERPRE"),,,,,,,.T.,,,,,,,.T.,,,"DS_USERPRE")
//-- Data
TSay():New(30,10,{|| RetTitle("DS_DATAPRE")},oFolder:aDialogs[5],,,,,,.T.,,,50,10)
TGet():New(28,70,{|| SDS->DS_DATAPRE},oFolder:aDialogs[5],50,10,PesqPict("SDS","DS_DATAPRE"),,,,,,,.T.,,,,,,,.T.,,,"DS_DATAPRE")
//-- Hora
TSay():New(50,10,{|| RetTitle("DS_HORAPRE")},oFolder:aDialogs[5],,,,,,.T.,,,50,10)
TGet():New(48,70,{|| SDS->DS_HORAPRE},oFolder:aDialogs[5],50,10,PesqPict("SDS","DS_HORAPRE"),,,,,,,.T.,,,,,,,.T.,,,"DS_HORAPRE")

//-- Ocorrencia
TMultiGet():New(10,10,{|| SDS->DS_DOCLOG},oFolder:aDialogs[6],aPosRdp[4]*0.96,oFolder:nHeight*0.35,,,,,,.T.,,,,,,.T.)

//-- Impostos
	
Aadd(aHeadImp, {" ","LEGENDA", "@BMP", 2, 0,,, 'C',,'V'})
Aadd(aHeadImp, {AllTrim("Imposto"),"IMPOSTO","@!",25,0,,,'C',,'R'})
Aadd(aHeadImp, {AllTrim("Valor TES"),"VALORT","@E 999,999,999.99",14,2,"ColVlrCols()",,'N',,'R'})
Aadd(aHeadImp, {AllTrim("Valor XML"),"VALORX","@E 999,999,999.99",14,2,,,'N',,'R'})
Aadd(aHeadImp, {AllTrim("Aliq. TES"),"ALIQT","@E 999,999,999.99",14,2,"ColAlqCols()",,'N',,'R'})
Aadd(aHeadImp, {AllTrim("Aliq. XML"),"ALIQX","@E 999,999,999.99",14,2,,,'N',,'R'})

TSay():New(10,10,{|| "Impostos:"},oFolder:aDialogs[7],,,,,,.T.,,,50,10)
oNewGet := MsNewGetDados():New(10,45,90,385,If(nOpc==4,2,4), "AllwaysTrue", "AllwaysTrue", /*cIniCpos*/, {"VALORT","ALIQT"},, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder:aDialogs[7],@aHeadImp,@aColsImp)
ColLoadImp(@oNewGet)
oGetDados:oBrowse:bChange := {|| ColImpRefresh()}
oGetDados:Refresh()

If nOpc == 4 .And. ( SDS->DS_TIPO $ "DCN" .Or. lRemet )
	aAdd(aButtons, {"PEDIDO", {|| Documentos(oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_COD")],.F.,nMultPC:=1,aColsAnt)}, If(SDS->DS_TIPO $ "NT",STR0015,STR0016),If(SDS->DS_TIPO $ "NT",STR0017,STR0018)}) //-- Pedido de Compra (Item) # Documento Origem # PC (Item) # Origem
	If SDS->DS_TIPO $ "NT"
		aAdd(aButtons, {"SOLICITA", {|| Documentos(oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_COD")],.T.,nMultPC:=2,aColsAnt)},STR0019,STR0020}) //-- Pedido de Compra (Doc.) # PC (Doc.)
	EndIf
	
	If SDS->DS_TIPO $ "DCN" .Or. (SDS->DS_TIPO == "T" .And. lRemet)
		aAdd(aButtons, {"DESVINC",{|| Documentos(oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_COD")],.T.,nMultPC:=3,aColsAnt)},"Desvincular"})
	Endif
EndIf

aAdd(aButtons,{'LEGENDA',{|| COLLegIt()},STR0051,STR0051}) //Legenda

Activate MsDialog oDlg On Init(EnchoiceBar(oDlg,{|| lRet := .T.,IIF(IIF(SDS->DS_TIPO=="D",ComXTudoOk(),.T.),oDlg:End(),)}, {|| IIF(SDS->DS_TIPO=="D",ComXGetAnt(aColsAnt),),oDlg:End()},,aButtons))

//-- Restaura aCols para Getdados principal
aCols:= aClone(oGetDados:aCols)

// Verifica se houve vinculo com pedido de compra
If lRet .And. nOpc == 4 .And. (SDS->DS_TIPO $ "N" .Or. (SDS->DS_TIPO $ "T" .And. lRemet))
	// Verifica se o aCols esta igual ao aColsAnt para nao gravar registros novamente sem necessidade
	nPosPed  := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_PEDIDO"})
	nPosItPC := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_ITEMPC"})
	nPosTES	 := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_TES"})
	If Len(aColsAnt) == Len(aCols)
		For nX := 1 To Len(aColsAnt)
			If aColsAnt[nX][nPosPed]!=aCols[nX][nPosPed] .Or. aColsAnt[nX][nPosItPC]!=aCols[nX][nPosItPC]
				nOpc := 5
				lGrava := .T.
				Exit
			Elseif aColsAnt[nX][nPosTES]!=aCols[nX][nPosTES] //Alterou TES
				lGrava := .T.
				Exit
			Elseif Len(aUsrCpo) > 0
				lGrava := .T.
				Exit
			Else
				lGrava := .F.
			EndIf
		Next nX
	Else
		nOpc := 5
	EndIf
EndIf

If lRet .And. nOpc == 4 //-- Caso tenha processado o vinculo
	If lGrava
		For nX := 1 To Len(aCols)
			SDT->(dbGoTo(aCols[nX,Len(aHeader)]))
			If !(SDS->DS_TIPO $ "N" .Or. lRemet)	//-- Grava pedido e item
				//-- Grava nota, serie e item origem
				RecLock("SDT",.F.)
				SDT->DT_NFORI   := aCols[nX,GDFieldPos("DT_NFORI")]
				SDT->DT_SERIORI := aCols[nX,GDFieldPos("DT_SERIORI")]
				SDT->DT_ITEMORI := aCols[nX,GDFieldPos("DT_ITEMORI")]
				SDT->(MsUnLock())
			EndIf
		Next nX
		
		//-- Grava Impostos e Tes
		For nX := 1 To Len(aCols)
			SDT->(dbGoTo(aCols[nX,Len(aHeader)]))
			RecLock("SDT",.F.)
			SDT->DT_TES		:= aCols[nX][GdFieldPos("DT_TES")]
			SDT->DT_TESIPI	:= aCols[nX][GdFieldPos("DT_TESIPI")] 	
			SDT->DT_TESICM	:= aCols[nX][GdFieldPos("DT_TESICM")]  	
			SDT->DT_TESISS	:= aCols[nX][GdFieldPos("DT_TESISS")]  	
			SDT->DT_TESPIS	:= aCols[nX][GdFieldPos("DT_TESPIS")]  	
			SDT->DT_TESCOF	:= aCols[nX][GdFieldPos("DT_TESCOF")]  	
			SDT->DT_TESICST	:= aCols[nX][GdFieldPos("DT_TESICST")]  	
			SDT->DT_ALIQIPI	:= aCols[nX][GdFieldPos("DT_ALIQIPI")] 	
			SDT->DT_ALIQICM	:= aCols[nX][GdFieldPos("DT_ALIQICM")] 	
			SDT->DT_ALIQISS	:= aCols[nX][GdFieldPos("DT_ALIQISS")] 	
			SDT->DT_ALIQPIS	:= aCols[nX][GdFieldPos("DT_ALIQPIS")] 	
			SDT->DT_ALIQCOF	:= aCols[nX][GdFieldPos("DT_ALIQCOF")]
			SDT->DT_ALIICST	:= aCols[nX][GdFieldPos("DT_ALIICST")]
			For nY	:= 1 To Len(aUsrCpo)
				SDT->&("DT_"+SUBSTR(aUsrCpo[nY],4)) := aCols[nX][GdFieldPos("DT_"+SUBSTR(aUsrCpo[nY],4))]
			Next nY	
			MsUnlock() 	
		Next nX
	EndIf
ElseIf lRet .And. nOpc == 5		//-- Opcao por vinculo de multiplos pedidos
	For nX := 1 To Len(aColsAnt)
		SDT->(dbGoTo(aColsAnt[nX,Len(aHeader)]))
		// Marca item original para que possa ser recuperado ao desvincular os pedidos
		RecLock("SDT",.F.)
		SDT->DT_ORIGIN := Iif(Empty(SDT->DT_ORIGIN),"1","2")
		SDT->(MsUnLock())

		// Deleta item
		RecLock("SDT",.F.)
		SDT->(dbDelete())
		SDT->(MsUnLock())
	Next nX

	//--Grava novos itens

	nPosDTItem := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_ITEM"})

	For nX := 1 To Len(aCols)
		SDT->(DbSetOrder(4))
		If SDT->(DbSeek(xFilial("SDT")+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE+aCols[nX,nPosDTItem]))
			lNovo := .F.
		Else
			lNovo := .T.
		EndIf

		RecLock("SDT",lNovo)
		SDT->DT_FILIAL	:= xFilial("SDT")
		SDT->DT_FORNEC	:= SDS->DS_FORNEC
		SDT->DT_LOJA	:= SDS->DS_LOJA
		SDT->DT_DOC		:= SDS->DS_DOC
		SDT->DT_SERIE	:= SDS->DS_SERIE
		SDT->DT_CNPJ	:= SDS->DS_CNPJ
		For nY := 1 To Len(aHeader)
			SDT->(FieldPut(SDT->(FieldPos(aHeader[nY][2])),aCols[nX][nY]))
		Next nY
		//2-Novo registro com pedido vinculado, 3-Novo registro sem pedido vinculado
		SDT->DT_ORIGIN	:= Iif(!Empty(aCols[nX][nPosPed]),"2","3")
		MsUnlock()
	Next nX
EndIf

If ExistBlock("COMCOLSD")
	ExecBlock("COMCOLSD",.F.,.F.,{aCols,aHeader})
EndIf

cFilAnt := cFilBkp

aRotina[2,4] := 2

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ColImpRefresh
TOTVS COLABORAÇAO 2.0
Atualiza grid de impostos. 
@author		Flavio Lopes Rasta
@since		06/04/2015
@version	P11
/*/
//-------------------------------------------------------------------
Function ColImpRefresh(lColAtuImp)

Default lColAtuImp := .F.

ColLoadImp(@oNewGet,lColAtuImp)	

Return

Function ColVlrCols()
Local n := oGetDados:nAt
Local nImp := oNewGet:nAt
Local oOK			:= LoadBitmap(GetResources(),'BR_VERDE')
Local oNO			:= LoadBitmap(GetResources(),'BR_VERMELHO') 

oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_TESIPI"})]	:= If(nImp ==1,M->VALORT,aCols[1][3])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_TESICM"})]	:= If(nImp ==2,M->VALORT,aCols[2][3])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_TESISS"})]	:= If(nImp ==3,M->VALORT,aCols[3][3])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_TESPIS"})]	:= If(nImp ==4,M->VALORT,aCols[4][3])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_TESCOF"})]	:= If(nImp ==5,M->VALORT,aCols[5][3]) 	
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_TESICST"})]	:= If(nImp ==6,M->VALORT,aCols[6][3])  

//-- Atualiza leganda da linha
If(M->VALORT == aCols[nImp][4] .And. aCols[nImp][5] == aCols[nImp][6])
	aCols[nImp][1] := oOK
Else
	aCols[nImp][1] := oNO
Endif

oGetDados:Refresh()
oNewGet:Refresh()	
Return .T.

Function ColAlqCols()
Local n := oGetDados:nAt
Local nImp := oNewGet:nAt 
Local oOK			:= LoadBitmap(GetResources(),'BR_VERDE')
Local oNO			:= LoadBitmap(GetResources(),'BR_VERMELHO')

oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ALIQIPI"})]	:= If(nImp ==1,M->ALIQT,aCols[1][5]) 	
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ALIQICM"})]	:= If(nImp ==2,M->ALIQT,aCols[2][5])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ALIQISS"})]	:= If(nImp ==3,M->ALIQT,aCols[3][5])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ALIQPIS"})]	:= If(nImp ==4,M->ALIQT,aCols[4][5])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ALIQCOF"})]	:= If(nImp ==5,M->ALIQT,aCols[5][5])
oGetDados:aCols[n][aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ALIICST"})]	:= If(nImp ==6,M->ALIQT,aCols[6][5])

//-- Atualiza leganda da linha
If(aCols[nImp][3] == aCols[nImp][4] .And. M->ALIQT == aCols[nImp][6])
	aCols[nImp][1] := oOK
Else
	aCols[nImp][1] := oNO
Endif

oGetDados:Refresh()
oNewGet:Refresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ColLoadImp
TOTVS COLABORAÇAO 2.0
Carrega Grid de impostos no monitor. 

@param		oBrowse, object, Objeto do browse.<br><b>Obrigatório

@author		Flavio Lopes Rasta
@since		06/04/2015
@version	P11
/*/
//-------------------------------------------------------------------
Function ColLoadImp(oNewGet)
Local oOK			:= LoadBitmap(GetResources(),'BR_VERDE')
Local oNO			:= LoadBitmap(GetResources(),'BR_VERMELHO')
Local aImpostos	:= {"IPI","ICMS","ISS","PIS","COFINS","ICMS ST"}
Local nPosValTes	:= 0
Local nPosValXml	:= 0
Local nPosAlqTes	:= 0
Local nPosAlqXml	:= 0
Local nX			:= 1
Local nAt			:= oGetDados:nAt
Local nValorTes 	:= 0
Local nAliqTes		:= 0
Local lMVDiviZer	:= SuperGetMv("MV_DIVIZER",.F.,.F.)

aColsImp:= {}

For nX:=1 To Len(aImpostos)
	If aImpostos[nX] == "ICMS ST"
		nPosValTes := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_TESICST"})
		nPosAlqTes := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_ALIICST"})
		nPosValXml := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_XMLICST"})
		nPosAlqXml := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_XALICST"})
	Else
		nPosValTes := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_TES"+SubStr(aImpostos[nX],1,3)})
		nPosAlqTes := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_ALIQ"+SubStr(aImpostos[nX],1,3)})
		nPosValXml := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_XML"+SubStr(aImpostos[nX],1,3)})
		nPosAlqXml := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_XALQ"+SubStr(aImpostos[nX],1,3)})
	Endif
	
	nPosLegend := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_LEGENDA"})
	
	nValorTes	:= oGetDados:aCols[nAt][nPosValTes]
	nAliqTes	:= If(lMVDiviZer .And. (nValorTes == 0),0,oGetDados:aCols[nAt][nPosAlqTes])
	
	aAdd(aColsImp,{})
	aAdd(aTail(aColsImp),If(nValorTes == oGetDados:aCols[nAt][nPosValXml] .And. nAliqTes == oGetDados:aCols[nAt][nPosAlqXml],oOK,oNO))
	aAdd(aTail(aColsImp),aImpostos[nX])
	aAdd(aTail(aColsImp),nValorTes)
	aAdd(aTail(aColsImp),oGetDados:aCols[nAt][nPosValXml])
	aAdd(aTail(aColsImp),nAliqTes)
	aAdd(aTail(aColsImp),oGetDados:aCols[nAt][nPosAlqXml])
	aAdd(aTail(aColsImp),.F.)
Next nX

If ExistBlock("COLDVIMP")
	aColsImp := ExecBlock("COLDVIMP",.F.,.F.,{"COMXCOL",aColsImp})
Endif

If ValType(oNewGet) <> "U"
	oNewGet:SetArray(@aColsImp)
EndIf

If (nPos:=aScan(aColsImp,{|x| x[1]:cName == "BR_VERMELHO"})) > 0
	oGetDados:aCols[nAt][nPosLegend] := aColsImp[nPos][1]:cName 
Else
	oGetDados:aCols[nAt][nPosLegend] := aColsImp[1][1]:cName
Endif

oGetDados:Refresh()

If ValType(oNewGet) <> "U"
	oNewGet:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COMXALL  ºAutor  ³Rodrigo de Toledo	 º Data ³  11/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para marcar todos os registros da MarkBrowse.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOL                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/    
Function COMXALL(nOpc)

Local nRecno	:= SDS->(Recno())
Local nPosReg 	:= aScan(aRegMark,{|x| x == nRecno})
Local cUpd		:= ""

Default nOpc := 2

If nOpc == 2
	SDS->(dbGoTop())
	While !SDS->(EOF())
		If SDS->DS_STATUS <> 'P'
			Reclock("SDS",.F.)
			SDS->DS_OK := If(SDS->DS_OK == cMarca,"",cMarca)
			SDS->(MsUnlock())
			
			nPosReg := aScan(aRegMark,{|x| x == SDS->(Recno())})
			
			//Armazena ou exclui os registros de aRegMark conforme a marcacao.
			If IsMark("DS_OK",cMarca)
				If nPosReg == 0
					aAdd(aRegMark,SDS->(Recno()))
				EndIf
			Else
				If nPosReg > 0
					aDel(aRegMark,nPosReg)
					aSize(aRegMark,(Len(aRegMark)-1))
				EndIf
			EndIf
		EndIf
		SDS->(dbSkip())
	EndDo
Elseif nOpc == 1
	cUpd := " UPDATE " + RetSqlName("SDS") 
	cUpd += " SET DS_OK = ''"
	cUpd += " WHERE DS_STATUS <> 'P'"
	cUpd += " AND DS_OK <> ''"
	cUpd += " AND D_E_L_E_T_ = ''"
	
	TCSqlExec(cUpd)
Endif

SDS->(dbGoto(nRecno))    
Return
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±± 
±±ºPrograma  ³ ComXMark	ºAutor  ³TOTVS				 º Data ³  28/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para armazenar os numeros dos registros marcados na º±±
±±º            MarkBrowse para que não seja necessário percorrer toda a   º±±
±±º            tabela SDS para gerar os documentos.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOL                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ComXMark(nAcao)

Local aArea   := GetArea()
Local nRecno  := Recno()
Local nPosReg := aScan(aRegMark,{|x| x == nRecno})
Local cQuery  := ''
Local cAliAt  := ''
Local cCpoAt  := ''
Local nPos		:= 0

If nAcao == 1
	
	//Codigo para tratamento da marcacao de registros na MarkBrowse.
	RecLock("SDS",.F.)
	SDS->DS_OK := Iif( IsMark("DS_OK",cMarca) , Space(Len(SDS->DS_OK)) , cMarca )
	SDS->(MsUnlock())
	SDS->(dbCommit())
	
	//Armazena ou exclui os registros de aRegMark conforme a marcacao.
	If IsMark("DS_OK",cMarca)
		If nPosReg == 0
			aAdd(aRegMark,SDS->(Recno()))
		EndIf
	Else
		If nPosReg > 0
			aDel(aRegMark,nPosReg)
			aSize(aRegMark,(Len(aRegMark)-1))
		EndIf
	EndIf

Else
	
	cQuery := "SELECT R_E_C_N_O_ SDSREC, DS_OK "
	cQuery += "FROM " + RetSqlName('SDS') + " "
	cQuery += "WHERE D_E_L_E_T_ = ' ' "
	cQuery += "AND DS_FILIAL = '" + xFilial('SDS') + "' "
	cQuery += "AND DS_OK = '" + cMarca + "'"
	
	If !Empty(cFilQry)
		
		cQuery += " AND " + cFilQry
			
	EndIf
		
	cQuery := ChangeQuery(cQuery)
		
	cAliAt := 'TMP2'
	DbUseArea(.T., "TOPCONN", TCGenQry(,, cQuery), cAliAt, .T., .T.)
		
	cCpoAt := 'SDSREC'
	
	(cAliAt)->(DbGoTop())
	
	If (cAliAt)->(!EOF())
		aRegMark := {}
	Endif
	
	While (cAliAt)->(!EOF())
		
		If (cAliAt)->DS_OK == cMarca
			
			nPos := aScan(aRegMark, (cAliAt)->&(cCpoAt))
			If nPos == 0
				AAdd(aRegMark, (cAliAt)->&(cCpoAt))
			Endif
			
		EndIf
		
		(cAliAt)->(DbSkip())
		
	EndDo
	
	If cAliAt == 'TMP2'
		
		If Select(cAliAt) > 0
			
			(cAliAt)->(DbCloseArea())
			
		EndIf
		
	EndIf
	
EndIf

RestArea(aArea)
MarkBRefresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GerarDocsºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa a geracao dos documentos fiscais.			      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                      			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GerarDocs()
Local nRegs   	:= 0
Local nRecno  	:= SDS->(Recno())
Local nQtdNF		:= 0
Local nX 			:= 1
Local aDivFis		:= {}
Local nProcOpc	:= 2
Local lProcessa 	:= .T.
Local lCAuto		:= .F.
Local aDivNFPed	:= {}
Local nQtdPC		:= 0
Local nPrcPC		:= 0
Local nPos			:= 0
Local nY			:= 0
Local cMsg			:= ""
Local cAliqICMS	:= GetMV("MV_ALIQICM")
Local aAliqICMS	:= StrTokArr(cAliqICMS, "/")
Local lVldICMS	:= .T.

// Chama a funcao COMXMARK() para preencher o array aRegMark a cada clique no botão "Gerar Docto".
// Caso contrario nao aparece a mensagem de confirmacao da geracao dos documentos no segundo clique.
// Sendo necessario sair e entrar novamente na rotina.
ComXMark(2)

nQtdNF := Len(aRegMark)

If nQtdNF > 0 .And. (lProcessa := MsgYesNo(STR0021,STR0022)) //-- Confirma a geração de documento para os itens selecionados? # Atenção
		
	SDT->(DbSetOrder(1))
	For nX:=1 To nQtdNF
		SDS->(dbGoTo(aRegMark[nX]))
		SDT->(DbSeek(xFilial("SDT")+SDS->(DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
		While !SDT->(Eof()) .And. SDT->(DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
			If 	SDT->DT_TESIPI <> SDT->DT_XMLIPI	.Or.;
				SDT->DT_TESICM <> SDT->DT_XMLICM	.Or.;
				SDT->DT_TESISS <> SDT->DT_XMLISS	.Or.;
				SDT->DT_TESPIS <> SDT->DT_XMLPIS	.Or.;
				SDT->DT_TESCOF <> SDT->DT_XMLCOF	.Or.;
				SDT->DT_TESICST <> SDT->DT_XMLICST	.Or.;
				SDT->DT_ALIQIPI <> SDT->DT_XALQIPI .Or.;
				SDT->DT_ALIQICM	<> SDT->DT_XALQICM .Or.;
				SDT->DT_ALIQISS	<> SDT->DT_XALQISS .Or.;
				SDT->DT_ALIQPIS	<> SDT->DT_XALQPIS .Or.;
				SDT->DT_ALIQCOF	<> SDT->DT_XALQCOF .Or.;
				SDT->DT_ALIICST <> SDT->DT_XALICST
			
				If SDT->DT_ALIQICM <> SDT->DT_XALQICM
					lVldICMS := (Ascan(aAliqICMS,cValToChar(SDT->DT_XALQICM)) > 0)
				EndIf
			
				aAdd(aDivFis,SDS->(Recno()))
				Exit
			Endif
			SDT->(DbSkip())
		EndDo	
	Next nX
	 
	If !lVldICMS //Valida ICMS mas apenas informa que aliquota não esta cadastrada no parametro
		Aviso(STR0120, STR0182, {STR0077}) // "Divergência Fiscal"##"A alíquota informada no XML não condiz com as alíquotas configuradas no parâmetro MV_ALIQICM, a nota não será gerada."##"OK"
		lProcessa := .T.
	ElseIf Len(aDivFis) > 0
		nProcOpc := Aviso(STR0120, STR0121 + CRLF + STR0122 + CRLF + STR0123 + CRLF + STR0124,{STR0125, STR0126, STR0127}, 2) //"Divergência Fiscal"##"Existem itens com divergência fiscal, qual opção deseja executar?"##"Cancelar - Para sair."##" Ignorar - Para importar mesmo com divergencia."##"Conformes - Apenas os documentos que não tem divergência."## "Cancelar"##"Ignorar"##"Conformes"
		If nProcOpc == 1
			lProcessa := .F. 
		ElseIf nProcOpc == 2
			lProcessa := .T.
			lCAuto	:= .T.
		ElseIf nProcOpc == 3
			For nX:=1 To Len(aDivFis)
				aDel(aRegMark,Ascan(aRegMark,{|x| x == aDivFis[nX]}))
			Next nX
			
			aSize(aRegMark,Len(aRegMark) - Len(aDivFis))
			
			If Len(aRegMark) > 0
				nQtdNF	:= Len(aRegMark)
				lCAuto	:= .T.
			Else
				lProcessa := .F.
			Endif
		Endif
	Else
		lProcessa := .T.
		lCAuto	:= .T.
	Endif
	
	If lProcessa
		SDT->(DbSetOrder(1))
		For nX:=1 To nQtdNF
			SDS->(dbGoTo(aRegMark[nX]))
			SDT->(DbSeek(xFilial("SDT")+SDS->(DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
			While !SDT->(Eof()) .And. SDT->(DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDS->(DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
				If !Empty(SDT->DT_PEDIDO) .And. !Empty(SDT->DT_ITEMPC)
					nQtdPC	:= Posicione("SC7",1,xFilial("SC7") + PadR(SDT->DT_PEDIDO,TamSx3("C7_NUM")[1]) + PadR(SDT->DT_ITEMPC,TamSx3("C7_ITEM")[1]),"C7_QUANT")
					nPrcPC	:= Posicione("SC7",1,xFilial("SC7") + PadR(SDT->DT_PEDIDO,TamSx3("C7_NUM")[1]) + PadR(SDT->DT_ITEMPC,TamSx3("C7_ITEM")[1]),"C7_PRECO")
					
					If nQtdPC <> SDT->DT_QUANT .Or. nPrcPc <> SDT->DT_VUNIT
						nPos := aScan(aDivNFPed,{|x| x[1]+x[2] == SDT->DT_DOC+SDT->DT_SERIE})
						If nPos == 0
							aAdd(aDivNFPed,{SDT->DT_DOC,SDT->DT_SERIE,{SDT->DT_ITEM}})
						Else
							aAdd(aDivNFPed[nPos,3],SDT->DT_ITEM)
						Endif	
					Endif
				Endif
				SDT->(DbSkip())
			Enddo	
		Next nX
		
		If Len(aDivNFPed) > 0
			cMsg += STR0128 + CRLF //"Existem divergências entre o valor unitário e/ou quantidade da(s) NF(s) com o(s) Pedido(s) relacionado(s)"
			
			For nX := 1 To Len(aDivNFPed)
				cMsg += STR0129 + aDivNFPed[nX,1] + STR0130 + aDivNFPed[nX,2] + STR0131 //"NF: "##Serie:##Item(ns) NF: (
				For nY := 1 To Len(aDivNFPed[nX,3])
					If nY == 1
						cMsg += aDivNFPed[nX,3,nY]
					Else
						cMsg += ", " + aDivNFPed[nX,3,nY]
					Endif
				Next nY
				cMsg += ")" + CRLF
			Next nX
			
			cMsg += CRLF + STR0132 + CRLF + STR0133 + CRLF + ; //"Qual opção deseja executar?"##"OK - Gerar documento com as divergências. "
					 STR0134 //"Cancelar - Realizar o ajuste manualmente."
						 
			nProcOpc := Aviso(STR0135,cMsg, {STR0077,STR0125},3) //"Divergência NF - Pedido"## "Ok"##Cancelar
			If nProcOpc == 1
				lProcessa := .T.
			Elseif nProcOpc == 2
				lProcessa := .F.
			Endif
		Endif
	Endif
	
Else
	lProcessa := .F.
Endif
If lProcessa
	Processa({|| ProcDocs(nQtdNF,.F.,lCAuto),STR0001 +" - " +STR0023}) //-- Monitor TOTVS Colaboração # Geração de Documentos	
	SDS->(dbGoTo(nRecno))
	aRegMark := {}
Endif

	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ProcDocs ºAutor  ³ Andre Anjos 		 º Data ³  08/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa a geracao dos documentos a partir de SDS/SDT      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nRegs:    total de registros a serem processados.		  º±±
±±           | lNFeAut:  indica se gera automaticamenteo documentos		  º±±
±±           |           classificados.									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GerarDocs												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcDocs(nRegs,lNFeAut,lCAuto,lJob)
Local aCabec 	:= {}
Local aItens 	:= {}
Local aErro  	:= {}
Local aRetPARA	:= {}
Local cErro  	:= ""
Local cFilBkp	:= cFilAnt
Local nX	 	:= 0
Local nY		:= 0
Local nCount 	:= 0 
Local lRet		:= .F.
Local lProcessa	:= .T.
Local lImpXML	:= .T.	// Esta variavel fara com que a nota seja gerada com os valores de impostos do XML, quando a nota for gerada de forma automatica
Local lClass	:= .F.
Local lNFImpMan := .F.
Local nComCol1	:= SuperGetMV("MV_COMCOL1",.F.,0)
Local cComCol2	:= SuperGetMV("MV_COMCOL2",.F.,"NDCOTB")
Local lCteClass := SuperGetMV("MV_CTECLAS",.F.,.F.)
Local lComxProc	:= ExistBlock("COMXPROC")
Local lCOMXPARA := ExistBlock("COMXPARA")
Local lCOLF1D1	:= ExistBlock("COLF1D1")
Local lCOLSTTS	:= ExistBlock("COLSTTS")
Local lClaTodos	:= .F.
Local lPreTodos	:= .F.

Default lNFeAut := .F.
Default lCAuto	:= .F.	// Esta variavel determina se sera gerada Pre Nota (.F.) ou documento classificado (.T.)
Default lJob    := .F.

Private lMSErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.
 
ProcRegua(nRegs)
For nY := 1 To nRegs
	If !lNFeAut
		SDS->(dbGoTo(aRegMark[nY]))
	EndIf

	lProcessa := .T.

	// Verifica se o tipo da NF esta contido no paramentro para geracao automatica
	If lNFeAut .And. !(SDS->DS_TIPO $ cComCol2)
		lProcessa := .F.
	EndIf

	//Valida processamento do documento
	If lComxProc
		lProcessa := ExecBlock("COMXPROC",.F.,.F.)
	EndIf
	
	If lCOMXPARA
		aRetPARA := ExecBlock("COMXPARA",.F.,.F.,{ nComCol1, lCteClass })
		
		If ValType(aRetPARA) == "A" .And. Len(aRetPARA) > 0
			If ValType(aRetPARA[1]) == "N"
				nComCol1  := aRetPARA[1]
			EndIf
			If ValType(aRetPARA[2]) == "L" 
				lCteClass := aRetPARA[2]
			EndIf
		EndIf
	EndIf
		
	If lProcessa
		If lNFeAut .And. SDS->DS_TIPO != "C" 
			aCabec := MontaSF1(lCteClass,nComCol1)
			aItens := MontaSD1(lImpXML,lCteClass,nComCol1)
			aItens := aSort(aItens,,,{|x,y| x[1,2] < y[1,2]})

			If lCOLF1D1
				aRetPe := ExecBlock("COLF1D1",.F.,.F.,{aCabec,aItens})
				If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
					If ValType(aRetPe[1]) == "A"
						aCabec := aClone(aRetPe[1])
					EndIf
					If ValType(aRetPe[2]) == "A" 
						aItens := aClone(aRetPe[2])
					EndIf
				EndIf
			EndIf

			//Verifica se NF ja foi importada/incluida manualmente.
			lNFImpMan := COLIMPMAN(aCabec)
			
			If !lNFImpMan
				lClass := .F.
				lClass := ColVerTes(aItens)
				If (lRet := (SDS->DS_STATUS <> "E"))
		        	If nComCol1 == 1 .And. !(SDS->DS_TIPO $ "OC") .And. !lCteClass .And. !lClass
			        	lRet := .T.
			        	MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
			    	ElseIf (nComCol1 == 2 .And. SDS->DS_TIPO != "D") .Or. (SDS->DS_TIPO $ "OCT") .Or. (lClass .And. lCAuto)
						lRet   := IIf(SDS->DS_TIPO $ "OCT",.T.,COLNfeAut(aCabec,aItens))
						If lRet
							MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)
						EndIf
					Else
						lRet := .F.
					EndIf
				EndIf
			Else
				lRet := .F.
				aErro := GetHlpSoluc("EXISTNF")
				cErro := "EXISTNF" + CRLF
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] + CRLF
				Next nX
				RecLock("SDS",.F.)
					Replace SDS->DS_DOCLOG With cErro
					Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnLock())
			EndIf
		ElseIf lJob .Or. (SDS->DS_OK == cMarca)
			lRet := .T.
			nCount++
			IncProc(STR0024 +AllTrim(SDS->DS_DOC) +"/" +SerieNfId("SDS",2,"DS_SERIE") +"(" +StrZero(nCount,2) +STR0025 +StrZero(nRegs,2) +")") //-- Processando documento # de		
			
			//-- Se filial diferente, troca
			If PadR(cFilAnt,Len(AllTrim(SDS->DS_FILIAL))) # AllTrim(SDS->DS_FILIAL)
				Do Case
					Case FWModeAccess("SB2",3) == "E"
						cFilAnt := SDS->DS_FILIAL
					Case FWModeAccess("SB2",2) == "E" .Or. FWModeAccess("SB2",1) == "E"
						SM0->(dbSetOrder(1))
						SM0->(dbSeek(cEmpAnt+SDS->DS_FILIAL))
						cFilAnt := SM0->M0_CODFIL
				EndCase
			EndIf
			
			//-- Esvazia log
			RecLock("SDS",.F.)
			SDS->DS_DOCLOG := CriaVar("DS_DOCLOG",.F.)
			SDS->(MsUnLock())
			
			aCabec := MontaSF1(lCteClass)
			aItens := MontaSD1(lCAuto,lCteClass,nComCol1)
			
			aItens := aSort(aItens,,,{|x,y| x[1,2] < y[1,2]})
			
			If lCOLF1D1
				aRetPe := ExecBlock("COLF1D1",.F.,.F.,{aCabec,aItens})
				If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
					If ValType(aRetPe[1]) == "A"
						aCabec := aClone(aRetPe[1])
					EndIf
					If ValType(aRetPe[2]) == "A" 
						aItens := aClone(aRetPe[2])
					EndIf
				EndIf
			EndIf
			
			//Verifica se NF ja foi importada/incluida manualmente.
			lNFImpMan := COLIMPMAN(aCabec)
			
			If !lNFImpMan
				lClass := .F.
				lClass := ColVerTes(aItens)
				If Empty(SDS->DS_DOCLOG) //-- Se nao houve erro na montagem dos dados, continua
					lMSErroAuto := .F.
					If (SDS->DS_TIPO $ "OC") .Or. (lClass .And. lCAuto) .Or. (lCAuto .And. COLNfeAut(aCabec,aItens)) .Or. (SDS->DS_TIPO == "T" .And. lCteClass)
						//Mensagem para decidir a geração do documento (classificado ou pré-nota)
						If !lPreTodos .And. !lClaTodos
							nOpc := Aviso(STR0137,STR0141 + CRLF + AllTrim(SDS->DS_DOC)+"|"+AllTrim(SDS->DS_SERIE),{STR0142,STR0185,STR0143,STR0186,STR0144},2) //Atenção#Documento possui TES nos itens, deseja gerar o documento classificado ou pré-nota?#Classificado#Clas p/ todos#Pre-nota#Pre p/ todos#Abortar
						Elseif lPreTodos
							nOpc := 3
						Elseif lClaTodos
							nOpc := 1
						Endif
						
						If nOpc <> 5
							If nOpc == 3 .Or. nOpc == 4 //Pré-Nota
								If nOpc == 4
									lPreTodos := .T.
								Endif
								
								For nX := 1 To Len(aItens)
									nPosTes := aScan(aItens[nX],{|x| x[1] == "D1_TES"})
									If nPosTes > 0
										aDel(aItens[nX],nPosTes)
										aSize(aItens[nX],Len(aItens[nX])-1)
									Endif
								Next nX
								MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
							Else
								If nOpc == 2
									lClaTodos := .T.
								Endif
								MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabec,aItens,3)	
							Endif
						Else
							lRet := .F.
							Exit
						Endif						
					Else
						For nX := 1 To Len(aItens)
							nPosTes := aScan(aItens[nX],{|x| x[1] == "D1_TES"})
							If nPosTes > 0
								aDel(aItens[nX],nPosTes)
								aSize(aItens[nX],Len(aItens[nX])-1)
							Endif
						Next nX
						
						MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
				   	EndIf
				Else
					lRet := .F.
				EndIf
			Else
				lRet := .F.
				aErro := GetHlpSoluc("EXISTNF")
				cErro := "EXISTNF" + CRLF
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] + CRLF
				Next nX
				RecLock("SDS",.F.)
					Replace SDS->DS_DOCLOG With cErro
					Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnLock())
			EndIf
		Else
			lRet := .F.
		EndIf
		If lRet
		   	//-- Grava resultado do processamento na SDS
		   	RecLock("SDS",.F.)
		   	Replace SDS->DS_OK	With ''
		   	If !lMsErroAuto
		   		Replace SDS->DS_USERPRE	With cUserName
		   		Replace SDS->DS_DATAPRE	With dDataBase
		   		Replace SDS->DS_HORAPRE	With Time()
		   		Replace SDS->DS_STATUS	With 'P'
		   		Replace SDS->DS_DOCLOG	With ''
			Else
				aErro := GetAutoGRLog()
				cErro := ""
				For nX := 1 To Len(aErro)
					cErro += aErro[nX] +CRLF
				Next nX
				Replace SDS->DS_DOCLOG With cErro
				Replace SDS->DS_STATUS With 'E'
			EndIf
			
			If lCOLSTTS
				ExecBlock("COLSTTS",.F.,.F.,)
			Endif
			
			SDS->(MsUnLock())
		EndIf			
		If lNFeAut
			Exit
		EndIf
			cFilAnt := cFilBkp
	 EndIf
	Next nY
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COLIMPMAN ºAutor  ³Microsiga          º Data ³  08/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se documento ja foi incluido de forma manual      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet: retorno ja documento ja existe ou não                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ProcDocs                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function COLIMPMAN(aCabec)

Local aArea	:= GetArea()
Local nPFil	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_FILIAL"})
Local nPDoc	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_DOC"})
Local nPSer	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_SERIE"})
Local nPFor	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_FORNECE"})
Local nPLoj	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_LOJA"})
Local nPTip	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TIPO"})
Local nPChv	:= aScan(aCabec,{|x| AllTrim(x[1]) == "F1_CHVNFE"})
Local nTFil	:= TamSx3("F1_FILIAL")[1]
Local nTDoc	:= TamSx3("F1_DOC")[1] 
Local nTSer	:= TamSx3("F1_SERIE")[1]
Local nTFor	:= TamSx3("F1_FORNECE")[1]
Local nTLoj	:= TamSx3("F1_LOJA")[1]
Local nTTip	:= TamSx3("F1_TIPO")[1]
Local nTChv	:= TamSx3("F1_CHVNFE")[1]
Local cFil		:= ""
Local cDoc		:= "" 
Local cSer		:= ""
Local cFor		:= ""
Local cLoj		:= ""
Local cTip		:= ""
Local cChv		:= ""
Local lRet		:= .F.

//Busca pela chave do documento
If nPFil > 0 .And. nPChv > 0
	cFil		:= PadR(aCabec[nPFil,2],nTFil)
	cChv		:= PadR(aCabec[nPChv,2],nTChv)
	
	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))
	If SF1->(DbSeek(cFil+cChv))
		lRet := .T.
	Endif
	
//Busca pelo numero+serie+fornecedor+loja+tipo
ElseIf nPFil > 0 .And. nPDoc > 0 .And. nPSer > 0 .And. nPFor > 0 .And. nPLoj > 0 .And. nPTip > 0
	cFil		:= PadR(aCabec[nPFil,2],nTFil)
	cDoc		:= PadR(aCabec[nPDoc,2],nTDoc) 
	cSer		:= PadR(aCabec[nPSer,2],nTSer)
	cFor		:= PadR(aCabec[nPFor,2],nTFor)
	cLoj		:= PadR(aCabec[nPLoj,2],nTLoj)
	cTip		:= PadR(aCabec[nPTip,2],nTTip)
	
	DbSelectArea("SF1")
	SF1->(DbSetOrder(1))
	If SF1->(DbSeek(cFil+cDoc+cSer+cFor+cLoj+cTip))
		lRet := .T.
	Endif
Endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MontaSF1 ºAutor  ³Microsiga           º Data ³  08/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta cabecalho para rotina automatica com os dados do SDS º±±
±±º          ³ posicionado.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aRet: array para uso na rotina automatica.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ProcDocs                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaSF1(lCteClass,nComCol1)
Local aRet	 	 	:= {}
Local cTipoNF	 	:= ""
Local cCondPagto 	:= ""
Local aAreaSDS		:= SDS->(GetArea())
Local lRemet		:= .F.
Local cFilSDT 		:= xFilial("SDT")
Local cFilSF1		:= xFilial("SF1")
Local cHoraRMT 		:= SuperGetMv("MV_HORARMT",.F.,"2")
Local lvldFret 		:= SuperGetMV("MV_VALFRET",.F.,.F.)
Local aHorario 		:= {}
Local lNfOri   		:= .F.
Local lF1CteOD		:= SF1->(ColumnPos("F1_UFORITR")) > 0 .And. SF1->(ColumnPos("F1_MUORITR")) > 0 .And. SF1->(ColumnPos("F1_UFDESTR")) > 0 .And. SF1->(ColumnPos("F1_MUDESTR")) > 0
Local lDSCteOD		:= SDS->(ColumnPos("DS_UFORITR")) > 0 .And. SDS->(ColumnPos("DS_MUORITR")) > 0 .And. SDS->(ColumnPos("DS_UFDESTR")) > 0 .And. SDS->(ColumnPos("DS_MUDESTR")) > 0

Default lCteClass	:= .F.
Default nComCol1	:= 0

Do Case
	Case SDS->DS_TIPO == "T"
		cTipoNF := "C"
	Case SDS->DS_TIPO == "O"
		cTipoNF := "N"
	Otherwise
		cTipoNF := SDS->DS_TIPO
EndCase

// Quando a empresa for remetente da mercadoria (FOB) nao deve passar F1_TPFRETE na rotina automatica, caso contrario vai cair na validacao A103FRETE que nao permite vincular pedido de compra a documentos com TPFRETE preenchido
If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F"
	lRemet := .T.
EndIf

aAdd(aRet,{"F1_FILIAL",  SDS->DS_FILIAL,	Nil})
If AllTrim(SDS->DS_ESPECI) == "CTE"
	SDT->(dbSetOrder(2))
	lNfOri := SDT->(dbSeek(cFilSDT+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
	If lRemet .And. lNfOri .And. (AllTrim(SDT->DT_COD) $ AllTrim(SuperGetMV("MV_XMLPFCT",.F.,"")) .Or. (empty(SDT->DT_NFORI) .and. (ExistBlock("A116ICOMP") .Or. ExistBlock("A116PRDF") .Or. ExistBlock("A116ITPCT"))))     
		cTipoNF := "N" 
		
		// Verifica a TAG <TpCte> para analisar se a nota eh complementar.	
			If SDS->DS_TPCTE == 'C' // CT-e de Complemento de Valores
					cTipoNF := "C"
			EndIf
		aAdd(aRet,{"F1_TIPO",cTipoNF,Nil})
	Else
		aAdd(aRet,{"F1_TIPO",cTipoNF,Nil})
	EndIf
Else
	aAdd(aRet,{"F1_TIPO",  cTipoNF,			Nil})
EndIf

// Quando a empresa for remetente da mercadoria (FOB) e tiver Pedido nao deve passar F1_TPFRETE na rotina automatica, caso contrario vai cair na validacao A103FRETE que nao permite vincular pedido de compra a documentos com TPFRETE preenchido
If lRemet 
	SDT->(dbSetOrder(2))
	SDT->(MsSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
	lRemet := !EMPTY(SDT->DT_PEDIDO) .And. !lvldFret
EndIf

aAdd(aRet,{"F1_FORMUL",  SDS->DS_FORMUL,	Nil})
aAdd(aRet,{"F1_DOC",     SDS->DS_DOC,		Nil})
aAdd(aRet,{"F1_SERIE",   SDS->DS_SERIE,		Nil})
aAdd(aRet,{"F1_EMISSAO", SDS->DS_EMISSA,	Nil})
aAdd(aRet,{"F1_FORNECE", SDS->DS_FORNEC,	Nil})
aAdd(aRet,{"F1_LOJA",    SDS->DS_LOJA,		Nil})
aAdd(aRet,{"F1_ESPECIE", SDS->DS_ESPECI,	Nil})
aAdd(aRet,{"F1_DTDIGIT", dDataBase,			Nil})
aAdd(aRet,{"F1_EST",     SDS->DS_EST,		Nil})
aAdd(aRet,{"F1_CHVNFE",  SDS->DS_CHAVENF,	Nil})

If SDS->DS_TIPO <> "T"
	aAdd(aRet,{"F1_FRETE",   SDS->DS_FRETE,		Nil})
EndIf

aAdd(aRet,{"F1_DESPESA", SDS->DS_DESPESA,	Nil})
aAdd(aRet,{"F1_DESCONT", SDS->DS_DESCONT,	Nil})
aAdd(aRet,{"F1_SEGURO",  SDS->DS_SEGURO,	Nil})
If !Empty(SDS->DS_TRANSP)
	aAdd(aRet,{"F1_TRANSP",SDS->DS_TRANSP,	Nil})
EndIf
aAdd(aRet,{"F1_PLACA",   SDS->DS_PLACA,		Nil})	
aAdd(aRet,{"F1_PLIQUI",  SDS->DS_PLIQUI	,	Nil})
aAdd(aRet,{"F1_PBRUTO",  SDS->DS_PBRUTO	,	Nil})
aAdd(aRet,{"F1_ESPECI1", SDS->DS_ESPECI1,	Nil})		
aAdd(aRet,{"F1_VOLUME1", SDS->DS_VOLUME1,	Nil})
aAdd(aRet,{"F1_ESPECI2", SDS->DS_ESPECI2,	Nil})
aAdd(aRet,{"F1_VOLUME2", SDS->DS_VOLUME2,	Nil})
aAdd(aRet,{"F1_ESPECI3", SDS->DS_ESPECI3,	Nil})
aAdd(aRet,{"F1_VOLUME3", SDS->DS_VOLUME3,	Nil})
aAdd(aRet,{"F1_ESPECI4", SDS->DS_ESPECI4,	Nil})
aAdd(aRet,{"F1_VOLUME4", SDS->DS_VOLUME4,	Nil})
aAdd(aRet,{"F1_TPCTE"  , SDS->DS_TPCTE  ,	Nil})

If !lRemet	// Nao deve passar TPFRETE quando for CT-e com pedido e a empresa for remetente da mercadoria (FOB). Para os outros casos deve passar,
	aAdd(aRet,{"F1_TPFRETE", SDS->DS_TPFRETE,	Nil})
EndIf

If SDS->DS_BASEICM > 0
	aAdd(aRet,{"F1_BASEICM"	, SDS->DS_BASEICM	, Nil})
EndIf
If SDS->DS_VALICM > 0
	aAdd(aRet,{"F1_VALICM"	, SDS->DS_VALICM	, Nil})
EndIf

aAdd(aRet,{"F1_CODNFE"	, SDS->DS_CODNFE	, Nil})
aAdd(aRet,{"F1_NUMRPS"	, SDS->DS_NUMRPS	, Nil})
aAdd(aRet,{"F1_NFELETR"	, SDS->DS_DOC		, Nil})
aAdd(aRet,{"F1_EMINFE"	, SDS->DS_EMISSA	, Nil})
aAdd(aRet,{"F1_HORNFE"	, SDS->DS_HORNFE	, Nil})
aAdd(aRet,{"F1_ORIGEM"	, "COMXCOL"			, Nil})

If SuperGetMv("MV_HORANFE",.F.,.F.)
	//Parametro MV_HORARMT habilitado pega a hora do smartclient, caso contrario a hora do servidor
	If cHoraRMT == '1' //Horario do SmartClient
		aAdd(aRet,{"F1_HORA",GetRmtTime(), Nil}) 
	ElseIf cHoraRMT == '2' //Horario do servidor
		aAdd(aRet,{"F1_HORA",Time(), Nil})
	ElseIf cHoraRMT =='3' //Horario de acordo com o estado da filial corrente
		aHorario := A103HORA()
		If !Empty(aHorario[2])
			aAdd(aRet,{"F1_HORA",aHorario[2], Nil})
		EndIf
	Endif
Endif

//Modalidade transporte - CTe
If SDS->DS_TIPO == "T" .And. SDS->(ColumnPos("DS_MODAL")) > 0
	aAdd(aRet,{"F1_MODAL"	, SDS->DS_MODAL	, Nil})
Endif		
					
//-- Preenche condicao de pagamento para tipos de documento que geram NF
Do Case
	Case SDS->DS_TIPO == "C" //-- Complemento de preco
		//-- Obtem cond. pagto utilizada na nota origem
		SDT->(dbSetOrder(2))
		SDT->(dbSeek(cFilSDT+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
		While Empty(cCondPagto) .And. SDT->(!EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == cFilSDT+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
			SF1->(dbSetOrder(1))
			If SF1->(dbSeek(cFilSF1+SDT->(DT_NFORI+DT_SERIORI+DT_FORNEC+DT_LOJA))) .And. !Empty(SF1->F1_COND)
				cCondPagto := SF1->F1_COND
			EndIf
			SDT->(dbSkip())
		End
		aAdd(aRet,{"F1_COND",cCondPagto,Nil})
	Case SDS->DS_TIPO == "T" //-- Conhecimento de transporte
		If nComCol1 == 2 .Or. lCteClass
			//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
			CTe_RetTES(NIL,NIL,@cCondPagto,2)
			aAdd(aRet,{"F1_COND",cCondPagto,Nil})
		EndIf
		
		//CTE com UF/Municipio de Origem e Destino
		If lF1CteOD .And. lDSCteOD .And. !Empty(SDS->DS_UFORITR) .And. !Empty(SDS->DS_MUORITR) .And. !Empty(SDS->DS_UFDESTR) .And. !Empty(SDS->DS_MUDESTR)
			aAdd(aRet,{"F1_UFORITR",SDS->DS_UFORITR,Nil})
			aAdd(aRet,{"F1_MUORITR",SDS->DS_MUORITR,Nil})
			aAdd(aRet,{"F1_UFDESTR",SDS->DS_UFDESTR,Nil})
			aAdd(aRet,{"F1_MUDESTR",SDS->DS_MUDESTR,Nil})
		Endif
EndCase

//Tipo de Complemento
If cTipoNF == "C"
	If SDS->DS_TIPO == "T" //CTE
		aAdd(aRet,{"F1_TPCOMPL","3", Nil })
	ElseIf SDS->DS_TIPO == "C" //Complemento
		SDT->(dbSetOrder(2))
		SDT->(MsSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
		If SDT->DT_QUANT > 0
			aAdd(aRet,{"F1_TPCOMPL","2", Nil })	// Complemento de Quantidade
		Else
			aAdd(aRet,{"F1_TPCOMPL","1", Nil })	// Complemento de Preco
		EndIf
	EndIf
EndIf

//-- Flag colab para tratamentos especificos
aAdd(aRet,{"COLAB","S",NIL})

RestArea(aAreaSDS)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MontaSD1 ºAutor  ³Microsiga           º Data ³  08/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monta itens para rotina automatica com os dados do SDS 	  º±±
±±º          ³ posicionado.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aRet: array para uso na rotina automatica.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ProcDocs                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaSD1(lImposto,lCteClass,nComCol1)

Local aRet	    := {} 
Local cTES_CT	:= ""
Local aAreaSDS	:= SDS->(GetArea())
Local cFilSA5	:= xFilial("SA5")
Local cFilSD1	:= xFilial("SD1")
Local cFilSDT	:= xFilial("SDT")
Local cOper	:= ""
Local lTpCte  := .T.
Local cFornOri	:= ""
Local cLojaOri	:= ""
Local cTesNFNorm	:= ""
Local lFCPAnt	:= SDT->(ColumnPos("DT_XBFCPAN")) > 0 .And. SDT->(ColumnPos("DT_XAFCPAN")) > 0 .And. SDT->(ColumnPos("DT_XVFCPAN")) > 0
Local lFCPST	:= SDT->(ColumnPos("DT_XBFCPST")) > 0 .And. SDT->(ColumnPos("DT_XAFCPST")) > 0 .And. SDT->(ColumnPos("DT_XVFCPST")) > 0
Local lDTClasFis:= SDT->(ColumnPos("DT_CLASFIS")) > 0
Local lD1FCPAnt	:= SD1->(ColumnPos("D1_BFCPANT")) > 0 .And. SD1->(ColumnPos("D1_AFCPANT")) > 0 .And. SD1->(ColumnPos("D1_VFCPANT")) > 0
Local lD1FCPST	:= SD1->(ColumnPos("D1_BSFCPST")) > 0 .And. SD1->(ColumnPos("D1_ALFCPST")) > 0 .And. SD1->(ColumnPos("D1_VFECPST")) > 0
Local lQtdZero	:= .F.
Local lVlrZero	:= .F.
Local lRet		:= .T.

Default lImposto:= .F.
Default lCteClass	:= .F.
Default nComCol1	:= 0

SDT->(dbSetOrder(2))
SDT->(dbSeek(cFilSDT+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
While SDT->(!EOF()) .AND. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == cFilSDT+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
	aAdd(aRet,{})
	
	aAdd(aTail(aRet),{"D1_ITEM",   SDT->DT_ITEM, 	 NIL})
	aAdd(aTail(aRet),{"D1_COD",    SDT->DT_COD,	 NIL})
	
	//Local
	If !Empty(SDT->DT_LOCAL)
		aAdd(aTail(aRet),{"D1_LOCAL",    SDT->DT_LOCAL,	 NIL})
	Endif
	
	If !Empty(SDT->DT_PEDIDO)
		aAdd(aTail(aRet),{"D1_PEDIDO", SDT->DT_PEDIDO,	 NIL})
		aAdd(aTail(aRet),{"D1_ITEMPC", SDT->DT_ITEMPC,	 NIL})
	EndIf
	If !Empty(SDT->DT_NFORI)
		aAdd(aTail(aRet),{"D1_NFORI",  SDT->DT_NFORI,	 NIL})
		aAdd(aTail(aRet),{"D1_SERIORI",SDT->DT_SERIORI, NIL})
		aAdd(aTail(aRet),{"D1_ITEMORI",SDT->DT_ITEMORI, NIL})
	EndIf
	If !SDS->DS_TIPO $ "C"
		If SDS->DS_TIPO == "T"
			If SDS->DS_TPFRETE == "F" // Somente quando a empresa e remetente da mercadoria (FOB) deve gerar nota com quantidade 1, caso contrario nao e para enviar quantidade (ficara zerada)
				// Verifica a TAG <TpCte> para analisar se a nota eh complementar.
				lTpCte := .T.
				
					If SDS->DS_TPCTE == 'C' .Or. (SDS->DS_TPCTE == 'N' .And. !Empty(SDT->DT_NFORI)) // CT-e de Complemento de Valores
						lTpCte := .F.
					EndIf
				
				If lTpCte
					aAdd(aTail(aRet),{"D1_QUANT",  SDT->DT_QUANT, 	 NIL}) 
				EndIf
				
			EndIf
			
			cFornOri := Posicione("SF1",8,xFilial("SF1") + SDT->DT_CHVNFO,"F1_FORNECE")
			cLojaOri := Posicione("SF1",8,xFilial("SF1") + SDT->DT_CHVNFO,"F1_LOJA")

			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))

			If SD1->(dbSeek(xFilial('SD1') + SDT->DT_NFORI + SDT->DT_SERIORI + cFornOri + cLojaOri + SDT->DT_COD + SDT->DT_ITEMORI))
				aAdd(aTail(aRet),{"D1_CONTA",SD1->D1_CONTA, NIL})
				aAdd(aTail(aRet),{"D1_CC",SD1->D1_CC, NIL})
			EndIf
		Else
			aAdd(aTail(aRet),{"D1_QUANT",  SDT->DT_QUANT, 	 NIL})
		EndIf
	EndIf
	
	aAdd(aTail(aRet),{"D1_VUNIT",  SDT->DT_VUNIT, 	 NIL})
	
	If SDS->DS_TIPO $ "CT"
		aAdd(aTail(aRet),{"D1_TOTAL",SDT->DT_VUNIT,NIL})
	Else
		aAdd(aTail(aRet),{"D1_TOTAL",SDT->DT_TOTAL,NIL})
	EndIf
	
	cOper := ColConDHJ(SDT->DT_CODCFOP) 
	If !Empty(cOper)
		aAdd(aTail(aRet),{"D1_OPER", cOper, NIL})
	EndIf	
	
	aAdd(aTail(aRet),{"D1_VALFRE",	SDT->DT_VALFRE,	 NIL})
	aAdd(aTail(aRet),{"D1_SEGURO",	SDT->DT_SEGURO,	 NIL})
	aAdd(aTail(aRet),{"D1_DESPESA",	SDT->DT_DESPESA, NIL})
	aAdd(aTail(aRet),{"D1_VALDESC",SDT->DT_VALDESC, NIL})
	
	If SDT->DT_PICM > 0
		aAdd(aTail(aRet),{"D1_PICM", SDT->DT_PICM, Nil })
	EndIf
	
	aAdd(aTail(aRet),{"CFOP", SDT->DT_CFOP, Nil }) //-- "CFOP" Variável ao qual armazena o valor do campo DT_CFOP		
	
	If !Empty(SDT->DT_FCICOD)
		aAdd(aTail(aRet),{"D1_FCICOD", SDT->DT_FCICOD, Nil}) // Armazena o valor do campo DT_FCICOD
	EndIf	

	If !Empty(SDT->DT_LOTE) .And. !Empty(SDT->DT_DTVALID) .And. (Rastro(SDT->DT_COD))
		aAdd(aTail(aRet),{"D1_LOTECTL", SDT->DT_LOTE   , Nil})
		aAdd(aTail(aRet),{"D1_DTVALID", SDT->DT_DTVALID, Nil})
		
		If SDT->(FieldPos("DT_DFABRIC")) > 0
			aAdd(aTail(aRet),{"D1_DFABRIC", SDT->DT_DFABRIC, Nil})
		Endif 
	EndIf 
	
	//-- Realiza validacoes pertinentes e preenche TES
	Do Case 
		Case SDS->DS_TIPO == "C" //-- Complemento de preco
			//-- Valida vinculo com documento origem
			If Empty(SDT->DT_NFORI)
				RecLock("SDS",.F.)
				Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG +CRLF+CRLF +STR0026 +SDT->DT_ITEM +STR0027 //-- Por tratar-se de um documento de complemento de preço, deverá ser realizado o vínculo com o documento origem para o item # deste documento.
				Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnlock())
			EndIf
			//-- Obtem TES
			If nComCol1 == 2
				SA5->(dbSetOrder(1))
				If SA5->(dbSeek(cFilSA5+SDT->(DT_FORNEC+DT_LOJA+DT_COD))) .And. Empty(SA5->A5_TESCP)
					RecLock("SDS",.F.)
					Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG +CRLF+CRLF +;
												STR0028 +AllTrim(SDT->DT_COD) +STR0029 +AllTrim(SDS->DS_FORNEC) +'/' +AllTrim(SDS->DS_LOJA) +STR0030 //-- Por tratar-se de um documento de complemento de preço, deverá ser identificado o tipo de entrada para o produto # e fornecedor # no campo "TE p/ Compl." (A5_TESCP) no cadastro de Produto X Fornecedor.
					Replace SDS->DS_STATUS With 'E'
					SDS->(MsUnlock())
				Else
					aAdd(aTail(aRet),{"D1_TES",SA5->A5_TESCP,NIL})
				EndIf
			EndIf
		Case SDS->DS_TIPO == "T" //-- Conhecimento de transporte
			If nComCol1 == 2 .Or. lCteClass
				//-- Obtem cond. pagto para utilizacao no CT-e (MV_XMLCPCT)
				CTe_RetTES(NIL,@cTES_CT,NIL,3)
				// -- Valida config. do parametro MV_XMLCPCT
				If Empty(cTES_CT)
					RecLock("SDS",.F.)
					Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG +CRLF+CRLF +STR0031 //-- Por tratar-se de um documento de transporte, deverá ser identificado o tipo de entrada a ser utilizado através do parâmetro MV_XMLCPCT.
					Replace SDS->DS_STATUS With 'E'
					SDS->(MsUnlock())
					Exit
				Else
					IF SDS->DS_FRETE > 0
						If Posicione("SF4",1,xFilial("SF4") + Padr(cTES_CT,TamSx3("F4_CODIGO")[1]),"F4_DUPLIC") == "N"
							aAdd(aTail(aRet),{"D1_TES",cTES_CT,NIL})
						Else
							RecLock("SDS",.F.)
							Replace SDS->DS_DOCLOG With SDS->DS_DOCLOG+CRLF+CRLF+"Por tratar-se de um CT-e onde não sera pago o valor de frete a TES não deve gerar duplicata."
							Replace SDS->DS_STATUS With 'E'
							SDS->(MsUnlock())
							Exit
						EndIf
					Else
						aAdd(aTail(aRet),{"D1_TES",cTES_CT,NIL})
					EndIf
				EndIf
			Endif
			aAdd(aTail(aRet),{"D1_ORIGLAN","FR", Nil })
		Case SDS->DS_TIPO == "O"
			SA5->(dbSetOrder(1))
			If SA5->(dbSeek(cFilSA5+SDT->DT_FORNEC+SDT->DT_LOJA+SDT->DT_COD)) .And. Empty(SA5->A5_TESBP)
				RecLock("SDS",.F.)
				Replace SDS->DS_DOCLOG With STR0032 +AllTrim(SDT->DT_COD) +STR0029 +AllTrim(SDS->DS_FORNEC) +'/' +AllTrim(SDS->DS_LOJA) +STR0033 //-- Por tratar-se de um documento de bonificação, deverá ser identificado o tipo de entrada para o produto # e fornecedor # no campo "TE p/ Bonif." (A5_TESBP) no cadastro de Produto X Fornecedor.
				Replace SDS->DS_STATUS With 'E'
				SDS->(MsUnlock())
			Else
				aAdd(aTail(aRet),{"D1_TES", SA5->A5_TESBP,  NIL})
			EndIf
		Otherwise
			If Empty(SDT->DT_TES)
				SC7->(DbSetOrder(14))
				If !Empty(SDT->DT_PEDIDO) .And. !Empty(SDT->DT_ITEMPC)
					If SC7->(DbSeek(xFilial("SC7")+SDT->DT_PEDIDO+SDT->DT_ITEMPC)) .And. !Empty(SC7->C7_TES)
						cTesNFNorm := SC7->C7_TES
						aAdd(aTail(aRet),{"D1_TES",cTesNFNorm,  NIL})
					EndIf
				Else
					cTesNFNorm := MaTESInt(1,ColConDHJ(SDT->DT_CODCFOP),SDS->DS_FORNEC,SDS->DS_LOJA,"F",SDT->DT_COD)
					aAdd(aTail(aRet),{"D1_TES", cTesNFNorm  ,  NIL})
				EndIf
			Else
				cTesNFNorm := SDT->DT_TES
				aAdd(aTail(aRet),{"D1_TES",SDT->DT_TES,  NIL})
			EndIf
			
			If !Empty(cTesNFNorm)
				lQtdZero := Posicione("SF4",1,xFilial("SF4")+cTesNFNorm,"F4_QTDZERO") == "1"
				lVlrZero := Posicione("SF4",1,xFilial("SF4")+cTesNFNorm,"F4_VLRZERO") == "1"
				
				If SDT->DT_QUANT == 0 .And. SDT->DT_VUNIT == 0 //TES precisa ser Vlr Zero e Qtd Zero
					lRet := lQtdZero .And. lVlrZero
				Elseif SDT->DT_QUANT > 0 .And. SDT->DT_VUNIT == 0 //TES precisa ser Vlr Zero
					lRet := lVlrZero
				Elseif SDT->DT_QUANT == 0 .And. SDT->DT_VUNIT > 0 //TES precisa ser Qtd Zero 
					lRet := lQtdZero
				Endif
				
				If !lRet 
					RecLock("SDS",.F.)
					Replace SDS->DS_DOCLOG With STR0063 + AllTrim(SDT->DT_ITEM) + STR0189 //"Item: "#" não esta configurada com a TES correta. Verifique configuração da TES (Valor Zero e/ou Quantidade Zero)"
					Replace SDS->DS_STATUS With 'E'
					SDS->(MsUnlock())
				Endif
			Endif
 	EndCase
 	
 	If lDTClasFis .And. !Empty(SDT->DT_CLASFIS)
 		aAdd(aTail(aRet),{"D1_CLASFIS", 	SDT->DT_CLASFIS,  NIL})
 	Endif

	If lImposto .And. SDS->DS_TIPO <> "T"
		aAdd(aTail(aRet),{"D1_VALIPI", 	SDT->DT_XMLIPI,  NIL})
		aAdd(aTail(aRet),{"D1_VALICM", 	SDT->DT_XMLICM,  NIL})
		aAdd(aTail(aRet),{"D1_VALISS", 	SDT->DT_XMLISS,  NIL})
		aAdd(aTail(aRet),{"D1_VALIMP6", SDT->DT_XMLPIS,  NIL})
		aAdd(aTail(aRet),{"D1_VALIMP5", SDT->DT_XMLCOF,  NIL})
		aAdd(aTail(aRet),{"D1_VLSLXML", SDT->DT_XMLICST,  NIL})
		aAdd(aTail(aRet),{"D1_ICMSRET", SDT->DT_XMLICST,  NIL})
		
		aAdd(aTail(aRet),{"D1_IPI", 	SDT->DT_XALQIPI,  NIL})
		aAdd(aTail(aRet),{"D1_PICM", 	SDT->DT_XALQICM,  NIL})
		aAdd(aTail(aRet),{"D1_ALIQISS", SDT->DT_XALQISS,  NIL})
		aAdd(aTail(aRet),{"D1_ALQIMP6", SDT->DT_XALQPIS,  NIL})
		aAdd(aTail(aRet),{"D1_ALQIMP5",	SDT->DT_XALQCOF,  NIL})
		aAdd(aTail(aRet),{"D1_ALIQSOL",	SDT->DT_XALICST,  NIL})
		
		If lFCPAnt .And. lD1FCPAnt
		 	aAdd(aTail(aRet),{"D1_BFCPANT"  , SDT->DT_XBFCPAN, Nil})
			aAdd(aTail(aRet),{"D1_AFCPANT"  , SDT->DT_XAFCPAN, Nil})
			aAdd(aTail(aRet),{"D1_VFCPANT"  , SDT->DT_XVFCPAN, Nil})
		Endif
		
		If lFCPST .And. lD1FCPST
		 	aAdd(aTail(aRet),{"D1_BSFCPST"  , SDT->DT_XBFCPST, Nil})
			aAdd(aTail(aRet),{"D1_ALFCPST"  , SDT->DT_XAFCPST, Nil})
			aAdd(aTail(aRet),{"D1_VFECPST"  , SDT->DT_XVFCPST, Nil})
		Endif
	EndIf

	SDT->(dbSkip())
EndDo

RestArea(aAreaSDS)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ COLNfeAutºAutor  ³Rodrigo Toledo      º Data ³  04/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao das tabelas SE4/SF4 para geracao automatica 	  º±±
±±º          ³ dos documentos TOTVS Colaboracao                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCabec: Cabecalho documento de entrada		  			  º±±
±±º			 ³ cItens: Itens documento de entrada		  				  º±±
±±º			 ³ cCGCEmit: CNPJ do emitente		  				  		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet: (True/False) verifica se passou todas as validacoes  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function COLNfeAut(aCabec,aItens,lClassAut)
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSF4 := SF4->(GetArea())
Local aAreaSE4 := SE4->(GetArea())
Local aAreaSA1 := SA1->(GetArea())
Local aAreaSA2 := SA2->(GetArea())
Local lRet     := .T.
Local nX       := 0
Local nPosFor  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_FORNECE"})
Local nPosLoj  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_LOJA"})
Local nPosTpNF := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TIPO"})
Local nPosCPg  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_COND"})
Local nPosFre  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TPFRETE"})
Local nPosPrd  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_COD"})
Local nPosPed  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_PEDIDO"})
Local nPosItPC := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_ITEMPC"})
Local nPosTes  := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_TES"})
Local nPosQtde := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_QUANT"})
Local nPosPrec := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_VUNIT"})
Local cCodTes  := ""
Local cCondPg  := ""
Local clQuery  := ""
Local clArqSQL := "TMP"  
Local lGerDupl := .F.
Local cFilSA1	 := xFilial("SA1")
Local cFilSA2  	 := xFilial("SA2")
Local cFilSB1	 := xFilial("SB1") 
Local cFilSC7	 := xFilial("SC7")
Local cFilSE4	 := xFilial("SE4")
Local cFilSF4	 := xFilial("SF4")
Local lCOMCOLF4	 := ExistBlock("COMCOLF4")
Default lClassAut	:= .F.

// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// | Verifica se o tipo NF esta contido no paramentro para geracao automatica |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(SDS->DS_TIPO $ SuperGetMV("MV_COMCOL2",.F.,.F.))
	lRet := .F.
ElseIf aCabec[nPosTpNF,2] == "N" .And. ExistBlock("COMCOL2")
	lRet := ExecBlock("COMCOL2",.F.,.F.,{aCabec,aItens})
	If ValType(lRet) <> "L"
		lRet := .F.
	EndIf
EndIf

If lRet
	SB1->(dbSetOrder(1))
	SF4->(dbSetOrder(1))
	For nX := 1 To Len(aItens)	
		nPosPrd  := aScan(aItens[nX],{|x| AllTrim(x[1]) == "D1_COD"})
		nPosTes  := aScan(aItens[nX],{|x| AllTrim(x[1]) == "D1_TES"})
		cCodTes := ""
		If nPosTes > 0
			cCodTes := aItens[nX][nPosTes][2]
		EndIf
		If Empty(cCodTes)
			SB1->(DbSeek(cFilSB1+aItens[nX][nPosPrd][2])) //Codigo do Produto
			cCodTes := SB1->B1_TE
		EndIf
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 	 
		// |  Ponto de entrada para obter o codigo da TES |	
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If lCOMCOLF4
			cCodTes := ExecBlock("COMCOLF4",.F.,.F.,{aCabec[nPosFor,2],aCabec[nPosLoj,2],aItens[nX][nPosPrd][2],cCodTes})
			If ValType(cCodTes) # "C" .Or. !SF4->(dbSeek(cFilSF4+cCodTes))
				cCodTes := SB1->B1_TE
			EndIf
		EndIf
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// |  Caso nao encontre a TES cancelar a operacao |
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cCodTes)
			lRet := .F.
			Exit
		ElseIf nPosTes > 0
			If Empty(aItens[nX][nPosTes][2])
				aItens[nX][nPosTes][2] := cCodTes
			EndIf
		Else
			aAdd(aItens[nX],{"D1_TES",cCodTes, NIL})
		EndIf
	Next nX
EndIf

If !lRet .And. lClassAut
	lRet:= .T.
Endif
                              
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// |  Ponto de entrada para obter a cond de pagto |
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	SF4->(dbSetOrder(1))
	For nX := 1 To Len(aItens)
		nPosTes  := aScan(aItens[nX],{|x| AllTrim(x[1]) == "D1_TES"})
		If SF4->(dbSeek(cFilSF4+aItens[nX][nPosTes][2])) .And. SF4->F4_DUPLIC == "S"
			lGerDupl := .T.
			Exit
		EndIf
	Next nX
	If lGerDupl
		SE4->(dbSetOrder(1))
		If Empty(cCondPg)
			If aCabec[nPosTpNF,2] $ "B"
				SA1->(dbSetOrder(1))
				If SA1->(dbSeek(cFilSA1+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
					cCondPg	:= SA1->A1_COND
				EndIf
			Else
				SA2->(dbSetOrder(1))
				If SA2->(dbSeek(cFilSA2+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
					cCondPg	:= SA2->A2_COND
				EndIf
			EndIf		
		EndIf
		If ExistBlock("A140ICOND")
			cCondPg := ExecBlock("A140ICOND",.F.,.F.,{aCabec[1][nPosFor],aCabec[1][nPosLoj],cCondPg})
			If ValType(cCondPg) # "C" .Or. !SE4->(dbSeek(cFilSE4+cCondPg))
				lRet := .F.
			EndIf
		EndIf
		If lRet   
			If !Empty(cCondPg) .And. nPosCPg > 0
				aCabec[nX][nPosCPg][2] := cCondPg
			ElseIf !Empty(cCondPg)
				aAdd(aCabec,{"F1_COND",cCondPg, NIL})
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSE4)
RestArea(aAreaSA1)
RestArea(aAreaSA2)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReprocessaºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre interface para o reprocessamento de arquivos XML com  º±±
±±º			 ³ erros ou excluidos.  									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                      			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Reprocessa()
Local lProc		:= .F.
Local lAviso	:= .F. 
Local oDlg			:= NIL
Local oBrowse		:= NIL
Local nX			:= 0
Local cCombo		:= ""
Local cFlag		:= ""
Local aArquivos	:= {}
Local aPosObj := {}
Local aSize		:= MsAdvSize()
Local oSize
Local aHeadCols := {}

If CKO->(ColumnPos("CKO_CNPJIM"))>0
	aHeadCols := {" ",RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),SerieNfId("SDS",7,"DS_SERIE"),RetTitle("DS_NOMEFOR"),STR0145,STR0146,STR0147,STR0148,RetTitle("CKO_CNPJIM")} //Empresa de Processamento#Filial de Processamento#Código do Erro#Descrição do Erro#CNPJ SIGAMAT
Else
	aHeadCols := {" ",RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),SerieNfId("SDS",7,"DS_SERIE"),RetTitle("DS_NOMEFOR"),STR0145,STR0146,STR0147,STR0148} //Empresa de Processamento#Filial de Processamento#Código do Erro#Descrição do Erro
EndIf

Define MsDialog oDlg Title STR0035 From aSize[1],aSize[2] To aSize[1]+450,aSize[2]+797 Pixel //-- Reprocessar Documentos

oSize := FwDefSize():New(.F.,,,oDlg)

oSize:AddObject('GRID'  ,100,100,.T.,.T.)
oSize:AddObject('FOOT'  ,100,20 ,.T.,.F.)			

oSize:aMargins 	:= { 3, 3, 3, 3 }
oSize:Process()

aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'XSIZE')-15,oSize:GetDimension('GRID'  , 'YSIZE')})
aAdd(aPosObj,{oSize:GetDimension('FOOT'  , 'LININI'),oSize:GetDimension('FOOT'  , 'COLINI'),oSize:GetDimension('FOOT'  , 'LINEND'),oSize:GetDimension('FOOT'  , 'COLEND')})

cCombo := STR0036 //-- Documentos com erro
TComboBox():New(aPosObj[2][1],aPosObj[2][2]+130,{|u| If(PCount()>0,cCombo:=u,cCombo)},{STR0036,STR0037},085,20,oDlg,,{|| Carga(@oBrowse,cCombo)},,,,.T.,,,,,,,,,'cCombo') //-- Documentos com erro # Documentos excluídos

oBrowse := TCBrowse():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4],,aHeadCols,,oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)

Carga(@oBrowse,cCombo)//-- Carrega arquivos no browse

TButton():New(aPosObj[2][1],aPosObj[2][2],STR0038,oDlg,{|| aEval(@oBrowse:aArray,{|x| x[1] := !x[1]}),oBrowse:Refresh() },50,11,,,.F.,.T.,.F.,,.F.,,,.F.) //-- Inverte Sel.
TButton():New(aPosObj[2][1],aPosObj[2][2]+60,STR0039,oDlg,{|| PesquiArq(@oBrowse)},50,11,,,.F.,.T.,.F.,,.F.,,,.F.) //-- Pesquisar

Define SButton From aPosObj[2][1],aPosObj[2][2]+330 Type 1 Action (aArquivos := aClone(oBrowse:aArray),lProc := .T., oDlg:End()) Enable Of oDlg
Define SButton From aPosObj[2][1],aPosObj[2][2]+360 Type 2 Action oDlg:End() Enable Of oDlg

Activate MsDialog oDlg Centered
	
If cCombo $ STR0036
	cFlag:= '2'
Else
	cFlag:= '1'
Endif

If lProc
	For nX := 1 To Len(aArquivos)
		If aArquivos[nX,1]
			
				ColGrvFil(aArquivos[nX,2],cFlag,aArquivos[nX,6],aArquivos[nX,7],aArquivos[nX,10])
				lAviso          := .T. //Exibe o Aviso se pelo menos um arquivo for selecionado
				oColab 			:= ColaboracaoDocumentos():New()
				oColab:cQueue   := SubStr(aArquivos[nX,2],1,3)
				oColab:cModelo  := ""
				oColab:cTipoMov := '2'
				oColab:cFlag    := cFlag
				oColab:cNomeArq := aArquivos[nX,2]
				oColab:Consultar()
				oColab:cFlag    := '0'
				oColab:FlegaDocumento()
		EndIf
	Next nX

	If lAviso 
		Aviso(STR0004,Iif(lMVImpXML,STR0191,STR0040),{"OK"}) //-- Atenção # Os arquivos selecionados foram movidos para a fila de reprocessamento. Quando disponíveis, os documentos serão apresentados no Monitor TOTVS Colaboração.
	Endif
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CargaºAutor  ³ Andre Anjos/Flavio Lopes º Data ³  19/09/14 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que carrega os arquivos no browse de reprocessamentoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oBrowse: browse dos arquivos a serem reprocessados.		  º±±
±±º			 ³ cCombo: opção selecionada no combo de documentos.		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Reprocessa												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Carga(oBrowse,cCombo)
Local aArea			:= SDS->(GetArea())
Local aArquivo		:= {}
Local aXMLs			:= {}
Local aDocs			:= {}
Local aFiles   	 := {}
Local cError		:= ""
Local cWarning		:= ""
Local cTagRem		:= ""
Local cTagDest		:= ""	
Local cFlag			:= If(cCombo == STR0036,'2','1') //-- Documentos com erro
Local lVldImport	:= If(cCombo == STR0036,.F.,.T.) //-- Documentos com erro
Local lAddArq		:= .T.
Local oFullXML		:= NIL
Local oColab		:= NIL
Local oOK			:= LoadBitmap(GetResources(),'LBOK')
Local oNO			:= LoadBitmap(GetResources(),'LBNO')
Local cXMLOri		:= ""
Local cXMLEncod		:= ""
Local nHandle		:= 0
Local nLength		:= 0
Local nX			:= 1
Local nY			:= 1
Local cCGCP	:= ""
Local cNum		:= ""
Local cSerie	:= ""
Local cForn	:= ""
Local aAreaSDS:= {}
Local lFilRep		:= SuperGetMV("MV_FILREP",.F.,.T.)

If cFlag == '1'
		
	If lFilRep	
		BeginSql Alias "TMPSDS"	
	
			SELECT 
				DS_ARQUIVO 
			FROM 
				%table:SDS%
			WHERE
				D_E_L_E_T_ = '*'
			AND
				DS_FILIAL = %exp:cFilAnt%
			AND
				DS_ARQUIVO IN (SELECT CKO_ARQUIV
	                              FROM   CKOCOL
	                              WHERE  D_E_L_E_T_ = ''
	                                     AND CKO_FLAG = '1')
			GROUP BY 
				DS_FILIAL,DS_CHAVENF,DS_ARQUIVO
		EndSql
	Else
		BeginSql Alias "TMPSDS"	
	
			SELECT 
				DS_ARQUIVO 
			FROM 
				%table:SDS%
			WHERE
				D_E_L_E_T_ = '*'
			AND
				DS_ARQUIVO IN (SELECT CKO_ARQUIV
	                              FROM   CKOCOL
	                              WHERE  D_E_L_E_T_ = ''
	                                     AND CKO_FLAG = '1')
			GROUP BY 
				DS_FILIAL,DS_CHAVENF,DS_ARQUIVO
		EndSql
	Endif
		
	While TMPSDS->(!EOF())
		aAdd(aDocs,TMPSDS->DS_ARQUIVO)
		TMPSDS->(dbSkip())
	EndDo
	
	TMPSDS->(dbCloseArea())
	
ElseIf cFlag == '2'
	aDocs	:= {"109","319","214","006"}//Recebimento- NF-e, NFS-e, CT-e, AV-e
Endif

SDS->(dbSetOrder(2))
	
If cFlag == '1' 
	For nX := 1 To Len(aDocs)
		lAddArq := .T.
		    
		oColab 			:= ColaboracaoDocumentos():New()
		oColab:cModelo := ""
		oColab:cTipoMov := '2'
		oColab:cFlag := cFlag
		oColab:cEmpProc := cEmpAnt 
		oColab:cFilProc := cFilAnt 
		oColab:cQueue := SubStr(aDocs[nX],1,3)
		oColab:aNomeArq := {{aDocs[nX]}}
		
		If !Empty(oColab:aNomeArq)
			aXMLs := oColab:aNomeArq
					
			For nY := 1 To Len(aXMLs)
				oColab:cNomeArq := aXMLs[nY,1]
				oColab:cFlag := cFlag
				oColab:Consultar()
				cXmlOri := oColab:cXmlRet
				oColab:cNomeArq := aXMLs[nY,1]
				If 	oColab:cFlag # '0'
					If !Empty(cXMLOri)
						If SubStr(cXMLOri,1,1) != "<"
							nPosPesq := At("<",cXMLOri)
							cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
						EndIf
					EndIf

					cXMLEncod := EncodeUtf8(cXMLOri)
					// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
					If Empty(cXMLEncod)
						cStrXML := cXMLOri
				        cXMLOri := A140IRemASC(cStrXML)
						cXMLEncod := EncodeUtf8(cXMLOri)
					EndIf
					If Empty(cXMLEncod)
						cXMLEncod := cXMLOri
					EndIf
					
					If !Empty(cXMLEncod)
						oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
					EndIf
					//-- Se nao houver Erro na sintaxe do XML adiciona no array
					If Empty(cError)
						If !Empty(oFullXML) .And. ( ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" .Or.; //-- Nota normal, devolucao, beneficiamento, bonificacao
						  								ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O" ) //-- Aviso de Embarque
							
							If ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
								If lVldImport
									lAddArq := COLFINSDS(2,Right(AllTrim(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_ID:Text),44))
								Endif
								
								If lAddArq
									aAdd(aArquivo,{})
									aAdd(aTail(aArquivo),.F.) 																			//-- Nome do arquivo
									aAdd(aTail(aArquivo),aXMLs[nY,1]) 																	//-- Nome do arquivo
									aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_NNF:Text)		//-- Numero do Doc.
									aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_SERIE:Text)  //-- Serie Doc.
									aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_EMIT:_XNOME:Text)	//-- Razao Social do fornecedor			
									aAdd(aTail(aArquivo),oColab:cEmpProc)
									aAdd(aTail(aArquivo),oColab:cFilProc)
									aAdd(aTail(aArquivo),oColab:cCodErrErp)
									aAdd(aTail(aArquivo),oColab:cMsgErrErp)
									aAdd(aTail(aArquivo),oColab:cCnpjImp)
								Endif
							Else
								If lVldImport
									lAddArq := COLFINSDS(2,Right(AllTrim(oFullXML:_NFEPROC:_NFE:_InfNfe:_Id:Text),44))
								Endif
								
								If lAddArq
									aAdd(aArquivo,{})
									aAdd(aTail(aArquivo),.F.) 													//-- Nome do arquivo
									aAdd(aTail(aArquivo),aXMLs[nY,1]) 											//-- Nome do arquivo
									aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_nNF:Text)	//-- Numero do Doc.
									aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_Serie:Text) //-- Serie Doc.
									aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Emit:_xNome:Text)//-- Razao Social do fornecedor
									aAdd(aTail(aArquivo),oColab:cEmpProc)
									aAdd(aTail(aArquivo),oColab:cFilProc)
									aAdd(aTail(aArquivo),oColab:cCodErrErp)
									aAdd(aTail(aArquivo),oColab:cMsgErrErp)
									aAdd(aTail(aArquivo),oColab:cCnpjImp)
								Endif
							EndIf
							
						ElseIf !Empty(oFullXML) .And. Empty(cError) .And. ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
							If lAddArq .And. lVldImport
								lAddArq := COLFINSDS(2,Right(AllTrim(oFullXML:_CteProc:_CTe:_InfCTe:_Id:Text),44))
							EndIf
							
							If lAddArq
								aAdd(aArquivo,{})
								aAdd(aTail(aArquivo),.F.) 														//-- Nome do arquivo	
								aAdd(aTail(aArquivo),aXMLs[nY,1]) 												//-- Nome do arquivo
								aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Ide:_nCt:Text)  		//-- Numero do Doc.
								aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Ide:_Serie:Text)  	//-- Serie Doc.
								aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Emit:_xNome:Text) 	//-- Razao Social do fornecedor
								aAdd(aTail(aArquivo),oColab:cEmpProc)
								aAdd(aTail(aArquivo),oColab:cFilProc)
								aAdd(aTail(aArquivo),oColab:cCodErrErp)
								aAdd(aTail(aArquivo),oColab:cMsgErrErp)
								aAdd(aTail(aArquivo),oColab:cCnpjImp)
							EndIf 
	
						ElseIf !Empty(oFullXML) .And. Empty(cError) .And. ValType(XmlChildEx(oFullXML,"_PROCNEOGRIDNFSE")) == "O" 
							cCGCP	:= oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_NEOGRIDRPS:_RPS:_PRESTADOR:_CNPJPREST:TEXT
							cNum	:= oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_RETNEOGRIDNFSE:_NNFSE:TEXT
							cForn	:= oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_NEOGRIDRPS:_RPS:_PRESTADOR:_RSOCIALPREST:TEXT
				
							If lAddArq .And. lVldImport
								dbSelectArea("SA2")
								dbSetOrder(3)
								If dbSeek(xFilial('SA2')+AllTrim(cCGCP))
									aAreaSDS := SDS->(GetArea())
									SDS->(dbsetorder(1))
									lAddArq := COLFINSDS(1,PADL(cNum,TamSX3("DS_DOC")[1],"0"),PADR(cSerie,TamSX3("DS_SERIE")[1]),SA2->A2_COD,SA2->A2_LOJA)
									RestArea(aAreaSDS)
								EndIf
							EndIf
							
							If lAddArq 
								aAdd(aArquivo,{})
								aAdd(aTail(aArquivo),.F.)
								aAdd(aTail(aArquivo),aXMLs[nY,1])
								aAdd(aTail(aArquivo),cNum)
								aAdd(aTail(aArquivo),"")
								aAdd(aTail(aArquivo),cForn)
								aAdd(aTail(aArquivo),oColab:cEmpProc)
								aAdd(aTail(aArquivo),oColab:cFilProc)
								aAdd(aTail(aArquivo),oColab:cCodErrErp)
								aAdd(aTail(aArquivo),oColab:cMsgErrErp)
								aAdd(aTail(aArquivo),oColab:cCnpjImp)
							EndIf	
						EndIf
					EndIf		
				   	oFullXML := Nil //-- Limpa objeto pra descarregar a memoria
					DelClassIntf()	//-- Limpa memoria
				EndIf
			Next nY
		Endif
	
		aXMLs 	:= {}
		oColab	:= NIL
	Next nX
Elseif cFlag == '2'
	lAddArq := .T.
	
	oColab 			:= ColaboracaoDocumentos():New()
	oColab:cModelo 	:= ""
	oColab:cTipoMov 	:= '2'
	oColab:cFlag 		:= cFlag
	oColab:cEmpProc 	:= cEmpAnt 
	oColab:cFilProc 	:= cFilAnt 
	oColab:aQueue 	:= aDocs
	oColab:cQueue 	:= aDocs[1]
		
	oColab:buscaDocumentosFilial()
	
	If !Empty(oColab:aNomeArq)
	
		aXMLs := oColab:aNomeArq
				
		For nY := 1 To Len(aXMLs)
			oColab:cNomeArq := aXMLs[nY,1]
			oColab:cFlag := cFlag
			oColab:Consultar() 
			cXmlOri := oColab:cXmlRet
			oColab:cNomeArq := aXMLs[nY,1]
			If 	oColab:cFlag # '0'
				If !Empty(cXMLOri)
					If SubStr(cXMLOri,1,1) != "<"
						nPosPesq := At("<",cXMLOri)
						cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
					EndIf
				EndIf
				cXMLEncod := EncodeUtf8(cXMLOri)
				// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
				If Empty(cXMLEncod)
					cStrXML := cXMLOri
			        cXMLOri := A140IRemASC(cStrXML)
					cXMLEncod := EncodeUtf8(cXMLOri)
				EndIf
				If Empty(cXMLEncod)
					cXMLEncod := cXMLOri
				EndIf
				
				If !Empty(cXMLEncod)
					oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
				EndIf
				//-- Se nao houver Erro na sintaxe do XML adiciona no array
				If Empty(cError)
					If !Empty(oFullXML) .And. ( ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" .Or.; //-- Nota normal, devolucao, beneficiamento, bonificacao
					  								ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O" ) //-- Aviso de Embarque
						
						If ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O"
							If lVldImport
								lAddArq := COLFINSDS(2,Right(AllTrim(oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_ID:Text),44))
							Endif
							
							If lAddArq
								aAdd(aArquivo,{})
								aAdd(aTail(aArquivo),.F.) 																			//-- Nome do arquivo
								aAdd(aTail(aArquivo),aXMLs[nY,1]) 																	//-- Nome do arquivo
								aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_NNF:Text)		//-- Numero do Doc.
								aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_IDE:_SERIE:Text)  //-- Serie Doc.
								aAdd(aTail(aArquivo),oFullXML:_INVOIC_NFE_COMPL:_NFE_SEFAZ:_NFE:_INFNFE:_EMIT:_XNOME:Text)	//-- Razao Social do fornecedor			
								aAdd(aTail(aArquivo),oColab:cEmpProc)
								aAdd(aTail(aArquivo),oColab:cFilProc)
								aAdd(aTail(aArquivo),oColab:cCodErrErp)
								aAdd(aTail(aArquivo),oColab:cMsgErrErp)
								aAdd(aTail(aArquivo),oColab:cCnpjImp)
							Endif
						Else
							If lVldImport
								lAddArq := COLFINSDS(2,Right(AllTrim(oFullXML:_NFEPROC:_NFE:_InfNfe:_Id:Text),44))
							Endif
							
							If lAddArq
								aAdd(aArquivo,{})
								aAdd(aTail(aArquivo),.F.) 													//-- Nome do arquivo
								aAdd(aTail(aArquivo),aXMLs[nY,1]) 											//-- Nome do arquivo
								aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_nNF:Text)	//-- Numero do Doc.
								aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_Serie:Text) //-- Serie Doc.
								aAdd(aTail(aArquivo),oFullXML:_NFeProc:_NFe:_InfNfe:_Emit:_xNome:Text)//-- Razao Social do fornecedor
								aAdd(aTail(aArquivo),oColab:cEmpProc)
								aAdd(aTail(aArquivo),oColab:cFilProc)
								aAdd(aTail(aArquivo),oColab:cCodErrErp)
								aAdd(aTail(aArquivo),oColab:cMsgErrErp)
								aAdd(aTail(aArquivo),oColab:cCnpjImp)
							Endif
						EndIf
						
					ElseIf !Empty(oFullXML) .And. Empty(cError) .And. ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
						If lAddArq .And. lVldImport
							lAddArq := COLFINSDS(2,Right(AllTrim(oFullXML:_CteProc:_CTe:_InfCTe:_Id:Text),44))
						EndIf
						
						If lAddArq
							aAdd(aArquivo,{})
							aAdd(aTail(aArquivo),.F.) 														//-- Nome do arquivo	
							aAdd(aTail(aArquivo),aXMLs[nY,1]) 												//-- Nome do arquivo
							aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Ide:_nCt:Text)  		//-- Numero do Doc.
							aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Ide:_Serie:Text)  	//-- Serie Doc.
							aAdd(aTail(aArquivo),oFullXML:_CteProc:_CTe:_InfCte:_Emit:_xNome:Text) 	//-- Razao Social do fornecedor
							aAdd(aTail(aArquivo),oColab:cEmpProc)
							aAdd(aTail(aArquivo),oColab:cFilProc)
							aAdd(aTail(aArquivo),oColab:cCodErrErp)
							aAdd(aTail(aArquivo),oColab:cMsgErrErp)
							aAdd(aTail(aArquivo),oColab:cCnpjImp)
						EndIf 

					ElseIf !Empty(oFullXML) .And. Empty(cError) .And. ValType(XmlChildEx(oFullXML,"_PROCNEOGRIDNFSE")) == "O" 
						cCGCP	:= oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_NEOGRIDRPS:_RPS:_PRESTADOR:_CNPJPREST:TEXT
						cNum	:= oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_RETNEOGRIDNFSE:_NNFSE:TEXT
						cForn	:= oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_NEOGRIDRPS:_RPS:_PRESTADOR:_RSOCIALPREST:TEXT
			
						If lAddArq .And. lVldImport
							dbSelectArea("SA2")
							dbSetOrder(3)
							If dbSeek(xFilial('SA2')+AllTrim(cCGCP))
								aAreaSDS := SDS->(GetArea())
								SDS->(dbsetorder(1))
								lAddArq := COLFINSDS(1,PADL(cNum,TamSX3("DS_DOC")[1],"0"),PADR(cSerie,TamSX3("DS_SERIE")[1]),SA2->A2_COD,SA2->A2_LOJA)
								RestArea(aAreaSDS)
							EndIf
						EndIf
						
						If lAddArq 
							aAdd(aArquivo,{})
							aAdd(aTail(aArquivo),.F.)
							aAdd(aTail(aArquivo),aXMLs[nY,1])
							aAdd(aTail(aArquivo),cNum)
							aAdd(aTail(aArquivo),"")
							aAdd(aTail(aArquivo),cForn)
							aAdd(aTail(aArquivo),oColab:cEmpProc)
							aAdd(aTail(aArquivo),oColab:cFilProc)
							aAdd(aTail(aArquivo),oColab:cCodErrErp)
							aAdd(aTail(aArquivo),oColab:cMsgErrErp)
							aAdd(aTail(aArquivo),oColab:cCnpjImp)
						EndIf	
					EndIf
				EndIf		
			   	oFullXML := Nil //-- Limpa objeto pra descarregar a memoria
				DelClassIntf()	//-- Limpa memoria
			EndIf
		Next nY
	Endif
Endif

If Len(aArquivo) == 0
	aAdd(aArquivo,{})
	aAdd(aTail(aArquivo),.F.)
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
	aAdd(aTail(aArquivo),"")
Else
	aArquivo := COMXCOLDUP(aArquivo)
	
	If Len(aArquivo) == 0
		aAdd(aArquivo,{})
		aAdd(aTail(aArquivo),.F.)
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
		aAdd(aTail(aArquivo),"")
	Endif
EndIf

oBrowse:SetArray(aArquivo)
If Len(aArquivo) > 0
	oBrowse:nAt := 1
	If CKO->(ColumnPos("CKO_CNPJIM"))>0
		oBrowse:bLine := {|| {If(aArquivo[oBrowse:nAT,1],oOK,oNO),aArquivo[oBrowse:nAt,02],aArquivo[oBrowse:nAt,03],aArquivo[oBrowse:nAt,04],aArquivo[oBrowse:nAt,05],aArquivo[oBrowse:nAt,06],aArquivo[oBrowse:nAt,07],aArquivo[oBrowse:nAt,08],aArquivo[oBrowse:nAt,09],aArquivo[oBrowse:nAt,10]}}
	Else
		oBrowse:bLine := {|| {If(aArquivo[oBrowse:nAT,1],oOK,oNO),aArquivo[oBrowse:nAt,02],aArquivo[oBrowse:nAt,03],aArquivo[oBrowse:nAt,04],aArquivo[oBrowse:nAt,05],aArquivo[oBrowse:nAt,06],aArquivo[oBrowse:nAt,07],aArquivo[oBrowse:nAt,08],aArquivo[oBrowse:nAt,09]}}
	EndIf
	If !Empty(aArquivo[oBrowse:nAt,2])
		oBrowse:bLDblClick := {|| aArquivo[oBrowse:nAt,1] := !aArquivo[oBrowse:nAt,1],;
								  If(cFlag == '2' .And. aArquivo[oBrowse:nAt,1] .And. Alltrim(aArquivo[oBrowse:nAt,8]) == 'COM042',aArquivo[oBrowse:nAt,1] := ColChanFil(@aArquivo,@oBrowse),.T.),;
								  oBrowse:Refresh()}
	Else
		oBrowse:bLDblClick := {||}
	Endif
EndIf
oBrowse:Refresh()
SDS->(RestArea(aArea))
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} COMXCOLDUP
TOTVS COLABORAÇAO 2.0
Função para retirar documento duplicados ao reprocessar

@param		aArquivo, array, Documentos carregados

@author	Rodrigo M Pontes
@since		18/07/16
@version	12.7
/*/
//-------------------------------------------------------------------

Static Function COMXCOLDUP(aArquivo)

Local aArea		:= GetArea()
Local aRet			:= {}
Local aAux			:= {}
Local nI			:= 0
Local nPos			:= 0
Local aCodErroExc	:= {"COM005","COM006","COM019"}

DbSelectArea("CKO")
CKO->(DbSetOrder(1))

//Verifica duplicidade
For nI := 1 To Len(aArquivo)
	nPos := aScan(aRet,{|x| AllTrim(x[3])+AllTrim(x[4])+AllTrim(x[5])+AllTrim(x[6])+AllTrim(x[7]) == AllTrim(aArquivo[nI,3])+AllTrim(aArquivo[nI,4])+AllTrim(aArquivo[nI,5])+AllTrim(aArquivo[nI,6])+AllTrim(aArquivo[nI,7])}) 
	If nPos == 0
		aAdd(aRet,{aArquivo[nI,1],AllTrim(aArquivo[nI,2]),AllTrim(aArquivo[nI,3]),AllTrim(aArquivo[nI,4]),AllTrim(aArquivo[nI,5]),AllTrim(aArquivo[nI,6]),AllTrim(aArquivo[nI,7]),AllTrim(aArquivo[nI,8]),AllTrim(aArquivo[nI,9]),AllTrim(aArquivo[nI,10])})
	Else
		If cPaisLoc == "BRA"
			If CKO->(DbSeek(PadR(aRet[nPos,2],Len(CKO->CKO_ARQUIV))))
				If RecLock("CKO",.F.)
					CKO->CKO_FLAG := "3"
					CKO->(MsUnlock())
				Endif
			Endif
		EndIf	
		
		aRet[nPos,2] := aArquivo[nI,2]
		aRet[nPos,3] := aArquivo[nI,3]
		aRet[nPos,4] := aArquivo[nI,4]
		aRet[nPos,5] := aArquivo[nI,5]
		aRet[nPos,6] := aArquivo[nI,6]
		aRet[nPos,7] := aArquivo[nI,7]
		aRet[nPos,8] := aArquivo[nI,8]
		aRet[nPos,9] := aArquivo[nI,9]		
		aRet[nPos,10] := aArquivo[nI,10]
	Endif
Next nI

//Retira os arquivos com os codigo de erro: COM005 (aCodErroExc)
For nI := 1 To Len(aRet) 
	If aScan(aCodErroExc,AllTrim(aRet[nI,8])) == 0
		aAdd(aAux,{aRet[nI,1],AllTrim(aRet[nI,2]),AllTrim(aRet[nI,3]),AllTrim(aRet[nI,4]),AllTrim(aRet[nI,5]),AllTrim(aRet[nI,6]),AllTrim(aRet[nI,7]),AllTrim(aRet[nI,8]),AllTrim(aRet[nI,9]),AllTrim(aRet[nI,10])})
	Endif
Next nI

//Atualiza aRet
aRet := aClone(aAux)

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ColChanFil
TOTVS COLABORAÇAO 2.0
Função para selecionar a filial de processamento do documento.

@param		aArquivo, array, Documentos carregados. Obrigatório
@param		oBrowse, object, Objeto do browse.      Obrigatório

@author	Geovani.Figueira
@since		05/12/2017
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function ColChanFil(aArquivo,oBrowFile)
	Local aFilDest	:= {}
	Local aHeadCols	:= {}
	Local aSize		:= MsAdvSize()
	Local aSM0      := FwLoadSM0() 
	Local oOK		:= LoadBitmap(GetResources(),'LBOK')
	Local oNO		:= LoadBitmap(GetResources(),'LBNO')
	Local oDlg		:= NIL
	Local oBrowse	:= NIL
	Local lProc		:= .F.
	Local lRet      := .F.
	Local nX		:= 0
	
	aHeadCols := {" ",STR0174,STR0176,STR0175,STR0181} // Filial / Nome / CNPJ / Inscrição Est.
		
	Define MsDialog oDlg Title STR0108 From aSize[1],aSize[2] To aSize[1]+250,aSize[2]+650 Pixel //-- Selecao de filial destinataria
	   	
	oBrowse := TCBrowse():New(01,01,326,105,,aHeadCols,,oDlg,,,,,{|| MarcaFilial(@aFilDest,oBrowse:nAt,@oBrowse),oBrowse:Refresh()},,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
	
	For nX := 1 To Len(aSM0)
		If AllTrim(aSm0[nX,SM0_GRPEMP]) == AllTrim(SM0->M0_CODIGO) .And. (aSM0[nX,SM0_CGC] == aArquivo[oBrowFile:nAt,10] .Or. Empty(aArquivo[oBrowFile:nAt,10]) )
			aAdd(aFilDest,{})				
			aAdd(aTail(aFilDest),(aArquivo[oBrowFile:nAt,7] == aSM0[nX,SM0_CODFIL])) //-- Flag de marcacao				
			aAdd(aTail(aFilDest),aSM0[nX,SM0_CODFIL])                               //-- Codigo filial
			aAdd(aTail(aFilDest),aSM0[nX,SM0_NOMRED])                              //-- Nome filial				
			aAdd(aTail(aFilDest),aSM0[nX,SM0_CGC])                                //-- CNPJ filial
			aAdd(aTail(aFilDest),IIF(Len(aSM0[nX])>21,StrTran(SUBSTR(aSM0[nX,22],At('_',aSM0[nX,22])+1),'_'),"")) //-- Incrição Estadual
		EndIf
	Next nX
	
	If Len(aFilDest) == 0
		AVISO(STR0004,STR0177+chr(13)+chr(10)+STR0178,{STR0077},3) //"Os CNPJs dos arquivos selecionados não pertencem ao grupo de empresas logado."#"Efetue logon no grupo de empresas correto para solucionar os conflitos."
	Else	
		oBrowse:SetArray(aFilDest)
		If Len(aFilDest) > 0
			oBrowse:bLine := {|| {If(aFilDest[oBrowse:nAT,01],oOK,oNO),aFilDest[oBrowse:nAt,02],aFilDest[oBrowse:nAt,03],aFilDest[oBrowse:nAt,04],aFilDest[oBrowse:nAt,05]}}
		EndIf
		oBrowse:Refresh()
	
		If !Empty(aFilDest[1][2])
			Define SButton From aSize[1]+110,aSize[2]+235 Type 1 Action (lProc := .T., oDlg:End()) Enable Of oDlg
		EndIf
		Define SButton From aSize[1]+110,aSize[2]+265 Type 2 Action oDlg:End() Enable Of oDlg
		
		Activate MsDialog oDlg Centered
		
		For nX := 1 To Len(aFilDest)
			If aFilDest[nX][1]
				If lProc
					aArquivo[oBrowFile:nAt,6] := SM0->M0_CODIGO
					aArquivo[oBrowFile:nAt,7] := aFilDest[nX][2]
				EndIf
				Exit
			ElseIf lProc
				aArquivo[oBrowFile:nAt,6] := ""
				aArquivo[oBrowFile:nAt,7] := ""
			EndIf
		Next
		
		lRet := IIf( Empty(aArquivo[oBrowFile:nAt,6]) , .F. , .T. )
		
		If lProc
			oBrowFile:Refresh()
		EndIf	
	EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ColGrvFil
TOTVS COLABORAÇAO 2.0
Função que grava a filial de processamento no documento informado

@param		cNomeArq, string, Nome do arquivo<br><b>Obrigatório
@param		cFlag, string, Flag do arquivo.<br><b>Obrigatório
@param		cFilProc, string, Filial de processamento do arquivo.<br><b>Obrigatório

@author	Flavio Lopes Rasta
@since		10/10/2014
@version	11.8
/*/
//-------------------------------------------------------------------
Function ColGrvFil(cNomeArq,cFlag,cEmpProc,cFilProc,cCnpjImp)
	Local oDlg		:= Nil
	Local oSize    
	Local oColab 
	
	If !Empty(cNomeArq)
		oColab 			:= ColaboracaoDocumentos():New()
		oColab:cModelo := ""
		oColab:cTipoMov := '2'
		oColab:cFlag := cFlag
		oColab:cQueue := SubStr(cNomeArq,1,3)
		oColab:cNomeArq := cNomeArq
	
		If oColab:Consultar()
			oColab:cEmpProc := cEmpProc
			oColab:cFilProc := cFilProc
			oColab:cCnpjImp := cCnpjImp
			oColab:gravaFilialDeProcessamento()
		Endif
	Endif
	oColab := NIL

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PesquiArq ºAutor  ³Rodrigo Toledo      º Data ³  08/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Realiza pesquisa no browse de reprocessamento.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ oBrowse: browse com os arquivos a serem reprocessados.	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Reprocessa                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesquiArq(oBrowse)
Local lProc      := .F.
Local cCpoPesq   := Space(100)
Local cOrdem     := "Arquivo"
Local nSeek      := 0
Local oDlg		 := NIL
Local oCombo	 := NIL
Local oGet		 := NIL
Local nOrdem     := 1

Define MSDialog oDlg Title STR0039 From 00,00 To 100,490 Pixel //-- Pesquisar

If CKO->(ColumnPos("CKO_CNPJIM"))>0
	@05,05 ComboBox oCombo Var cOrdem Items {RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),;
				SerieNfId("SDS",7,"DS_SERIE"),RetTitle("DS_NOMEFOR"),RetTitle("CKO_CNPJIM")} Size 206,36 Pixel Of oDlg On Change (nOrdem := oCombo:nAT)
Else
	@05,05 ComboBox oCombo Var cOrdem Items {RetTitle("DS_ARQUIVO"),RetTitle("DS_DOC"),;
				SerieNfId("SDS",7,"DS_SERIE"),RetTitle("DS_NOMEFOR")} Size 206,36 Pixel Of oDlg On Change (nOrdem := oCombo:nAT)
EndIf
@22,05 MSGet oGet Var cCpoPesq Size 206,10 Pixel Of oDlg
Define SButton From 05,215 Type 1 Of oDlg Enable Action (lProc := .T., oDlg:End())
Define SButton From 20,215 Type 2 Of oDlg Enable Action oDlg:End()

Activate MSDialog oDlg Center

If lProc
	cCpoPesq := Upper(AllTrim(cCpoPesq))
	If nOrdem == 1 //-- Arquivo
		aSort(oBrowse:aArray,,,{|x,y| x[2] < y[2]})
		nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[2])) == cCpoPesq})	
	ElseIf nOrdem == 2 //-- Documento
		aSort(oBrowse:aArray,,,{|x,y| x[3] < y[3]})
		nSeek := aScan(oBrowse:aArray,{|x| Upper(Left(x[3],Len(cCpoPesq))) == cCpoPesq})
	ElseIf nOrdem == 3 //-- Serie	
		aSort(oBrowse:aArray,,,{|x,y| x[4] < y[4]})
		nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[4])) == cCpoPesq})
	ElseIf nOrdem == 4 //-- Razao Social
		aSort(oBrowse:aArray,,,{|x,y| x[5] < y[5]} )
		nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[5])) == cCpoPesq})
	ElseIf nOrdem == 5 //-- CNPJ Importado
		aSort(oBrowse:aArray,,,{|x,y| x[10] < y[10]} )
		nSeek := aScan(oBrowse:aArray,{|x| Upper(AllTrim(x[10])) == cCpoPesq})
	EndIf
	If nSeek > 0
		oBrowse:nAT := nSeek
		oBrowse:Refresh()
		oBrowse:SetFocus()
	Else
		Aviso(STR0004,STR0041,{"OK"}) //-- Atenção # A busca não encontrou resultados.
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Excluir  ºAutor  ³ Andre Anjos		 º Data ³  05/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exclui os documentos marcados.					          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COMXCOLAB                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Excluir()

Local lRet := .F.
Local nPos		:= 0
Local oColab   := ColaboracaoDocumentos():New()

lRet := MsgYesNo(STR0042,STR0004) //-- Confirma a exclusão dos documentos marcados? # Atenção

If lRet
	//Traz documentos marcados
	BeginSQL Alias "SDSTMP"
		SELECT SDS.DS_FILIAL, SDS.DS_DOC, SDS.DS_SERIE, SDS.DS_FORNEC, SDS.DS_LOJA, SDS.DS_ARQUIVO
		FROM %Table:SDS% SDS
		WHERE SDS.DS_OK = %Exp:cMarca% AND SDS.DS_STATUS != 'P' AND SDS.%NotDel%
	EndSQL
	
	SDT->(dbSetOrder(3))
	SDS->(dbSetorder(1))
	
	While !SDSTMP->(EOF())
		//-- Deleta itens do documento
		If SDT->(dbSeek(SDSTMP->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
			While !SDT->(EOF()) .And. SDT->(DT_FILIAL+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) == SDSTMP->(DS_FILIAL+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE) 
			RecLock("SDT",.F.)
			SDT->(dbDelete())
			SDT->(MsUnLock())		
			SDT->(dbSkip())
		End
		EndIf
			
		oColab:cQueue := SubStr(SDSTMP->DS_ARQUIVO,1,3)
		oColab:cModelo := ""
		oColab:cTipoMov := '2'
		oColab:cFlag := '1'
		oColab:cNomeArq := SDSTMP->DS_ARQUIVO
		oColab:Consultar(,,,,,'1')
		oColab:cFlag := '3'
		oColab:FlegaDocumento()
		
		//-- Deleta cabecalho do documento
		If SDS->(dbSeek(SDSTMP->(DS_FILIAL+DS_DOC+DS_SERIE+DS_FORNEC+DS_LOJA)))
			nPos := aScan(aRegMark,SDS->(RECNO()))
			If nPos > 0
				aDel(aRegMark,nPos)
				aSize(aRegMark,Len(aRegMark)-1)
			Endif
			
			RecLock("SDS",.F.)
			SDS->(dbDelete())
			SDS->(MsUnLock())
		EndIf
		
		SDSTMP->(dbSkip())
	End
	
	SDSTMP->(dbCloseArea())
	SDS->(dbGoTop())
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Legenda   ³ Autor ³ Andre Anjos			³ Data ³ 05/06/12  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exibe uma janela contendo a legenda da browse.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ COMXCOLAB												   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Legenda()

Local aCores	:= {}
Local aCoresNew	:= {}

aAdd(aCores,{'BR_VERMELHO',STR0043})	//-- "Documento Gerado"
aAdd(aCores,{'BR_VERDE',STR0044})		//-- "Documento Normal"
aAdd(aCores,{'BR_AZUL',STR0045})		//-- "Docto. de Bonificação"
aAdd(aCores,{'BR_AMARELO',STR0046})		//-- "Docto. de Devolução"
aAdd(aCores,{'BR_CINZA',STR0047})		//-- "Docto. de Beneficiamento"
aAdd(aCores,{'BR_PINK',STR0048})	 	//-- "Docto. de Compl. Preço"
aAdd(aCores,{'BR_LARANJA',STR0049})		//-- "Docto. de Transporte"
aAdd(aCores,{'BR_PRETO',STR0050})		//-- "Documento c/ Ocorrência"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para incluir/alterar opcoes de legenda ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("COMXLEG")
	aCoresNew := ExecBlock("COMXLEG",.F.,.F.,{aCores})
	If ValType(aCoresNew) == "A"
		aCores := aCoresNew
	EndIf
EndIf

BrwLegenda(STR0001,STR0051,aCores) //-- Legenda

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | Documentos ³Autor ³ Rodrigo de Toledo		   |Data ³ 30/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao procura possiveis pedidos de compra relacionados a NF     ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto: codigo do produto posicionado.							³±±
±±³			 ³ lPedDoc: indica se a pequisa e por documento ou item.			³±±
±±³			 ³ oGetDados: objeto com os itens do documento.						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ MontaTela	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/   
Static Function Documentos(cProduto,lPedDoc,nMultPC,aColsAnt,cForn,cLoja,aPedidos,oBrowse)

Local aArea      := GetArea()
Local aCampos    := {}
Local aColsPcDoc := {}
Local aProdutos  := {}
Local cAliasTmp  := "SC7TMP"
Local cSeek      := ""
Local cPedAnt    := ""
Local cQuery     := ""
Local cFilSC7    := xFilial("SC7")
Local nRecSDT    := 0 
Local nX         := 0
Local nY         := 0
Local nPosProd   := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_COD"})
Local lRet       := .F.
Local lRetXPC    := .T.
Local lA140IPed  := ExistBlock("A140IPED")
Local lRemet     := .F.
Local lConsLoja  := (mv_par12==1)	// Considera loja na pesquisa de pedidos
Local lRetPed    := (aPedidos == Nil)
Local lForPCNF   := (SuperGetMV("MV_FORPCNF",,.F.) == .T.)
Local lContinua  := .T.

Default nMultPC  := 0
Default cForn    := SDS->DS_FORNEC
Default cLoja    := SDS->DS_LOJA

If SDS->DS_TIPO == "C"
	Private n := oGetDados:nAt
EndIf

// Verifica se e CT-e e se e remetente da mercadoria (saida), neste caso deve permitir vinculo com pedido
If SDS->DS_TIPO == "T" .And. SDS->DS_TPFRETE == "F"
	lRemet := .T.
EndIf

// Verifica se utiliza funcionalidade de vinculo de multiplos pedidos
lRetXPC := ValidXPC(lRemet,nMultPC,aColsAnt)

If ( SDS->DS_TIPO $ "N" .Or. lRemet ) .And. lRetXPC	//-- NF Normal (Compra) ou CT-e de saida
	
	If lPedDoc
		If nMultPC == 0
			aColsPcDoc := aClone(aCols)
		Else
			aColsPcDoc := aClone(aColsAnt)
		Endif
		
		For nY := 1 To Len(aColsPcDoc)
			If aScan( aProdutos,{|x| x == aColsPcDoc[nY][nPosProd]} ) == 0
				aAdd(aProdutos,aColsPcDoc[nY][nPosProd])
			EndIf
		Next nY
	Endif
	
		cQuery += "SELECT " +If(lPedDoc,"DISTINCT C7_LOJA, ","") +"C7_NUM, C7_EMISSAO, C7_FILIAL"
	
		If !lPedDoc
			cQuery += ", C7_ITEM, C7_QUANT, C7_PRECO, C7_TOTAL, C7_QTDACLA, C7_LOJA, C7_PRODUTO, C7_QUJE"
		EndIf
	
	//Ponto de entrada utilizado para adicionar campos na interface de visualização de pedidos	
		If lA140IPed
			aCampos := ExecBlock("A140IPED",.F.,.F.,{1,{},{}})
			If ValType(aCampos[1]) == "A"
				For nX:=1 to Len(aCampos[1])
					cQuery += " , " + aCampos[1][nX]
				Next nX
			EndIf
		EndIf
	
		cQuery += " FROM " +RetSqlName("SC7") +" SC7"
		cQuery += " WHERE C7_FILENT = '" + cFilSC7 + "' AND D_E_L_E_T_ <> '*'"
		cQuery += " AND C7_FORNECE = '" +cForn + "'"
	
		If lConsLoja
			cQuery += " AND C7_LOJA = '" +cLoja + "'"
		EndIf
	
	If !lPedDoc
			cQuery += " AND C7_PRODUTO = '" +cProduto +"'"
	Else
		If Len(aProdutos) > 0
			cQuery += " AND C7_PRODUTO IN ("
			For nY := 1 To Len(aProdutos)
				cQuery += "'" + aProdutos[nY] + "'"
				If nY <> Len(aProdutos)
					cQuery += ","
				EndIf
			Next nY
			cQuery += ")"
		Endif
	Endif
	
		cQuery += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) > 0"
		cQuery += " AND C7_ENCER = ' ' AND C7_RESIDUO <> 'S'"
	
		If SuperGetMV("MV_RESTNFE") == "S"
			cQuery += " AND C7_CONAPRO <> 'B'"
		EndIf			
	
	cQuery += " ORDER BY C7_NUM"
	
	If !lPedDoc
		cQuery += " , C7_ITEM"
	EndIf
	
		cQuery := ChangeQuery(cQuery)
		
		If !lRetPed .And. Select(cAliasTmp) > 0
			(cAliasTmp)->(dbCloseArea())
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	(cAliasTmp)->(dbGoTop())	
	If (cAliasTmp)->(!EOF()) .Or. lForPCNF
		lRet := Pedidos(cProduto,lPedDoc,cAliasTmp,lConsLoja,nMultPC,aColsAnt,,,@aPedidos,@oBrowse)
	Else
		Aviso(STR0004,(STR0058 +AllTrim(cProduto) +STR0059 +AllTrim(SDS->DS_DOC)+"/"+SerieNfId("SDS",2,"DS_SERIE") +"."),{"OK"}) //-- Atenção # Não há pedidos de compra para o produto # do documento #.
	EndIf
	If Select(cAliasTmp) > 0
	(cAliasTmp)->(dbCloseArea())
	EndIf
Else
	n := oGetDados:nAt
	aCols := oGetDados:aCols
	
	If nMultPC <> 3
		If SDS->DS_TIPO $ "D"
			lRet := F4NFORI(,,"M->DT_NFORI",SDS->DS_FORNEC,SDS->DS_LOJA,cProduto,"A140I",,@nRecSDT) .And. nRecSDT <> 0
		ElseIf SDS->DS_TIPO == "C"
			lRet := F4COMPL(,,,SDS->DS_FORNEC,SDS->DS_LOJA,cProduto,"A140I",@nRecSDT,"M->DT_NFORI") .And. nRecSDT <> 0
		EndIf
		
		If lRet
			// Tratamento para carregar a TES de devolucao automaticamente
			For nX := 1 To Len(oGetDados:aCols)
				If lContinua
					SD2->(DbSetOrder(3))	// D2_FILIAL + D2_DOC + D2_SERIE + D2_D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
					If SD2->(MsSeek(xFilial("SD2")+oGetDados:aCols[nX,GDFieldPos("DT_NFORI")]+oGetDados:aCols[nX,GDFieldPos("DT_SERIORI")]+SDS->DS_FORNEC+SDS->DS_LOJA+oGetDados:aCols[nX,GDFieldPos("DT_COD")]+oGetDados:aCols[nX,GDFieldPos("DT_ITEMORI")]))
						DbSelectArea("SF4")
						DbSetOrder(1)
						If MsSeek(xFilial("SF4")+SD2->D2_TES)
							If !Empty(cTesDev := SF4->F4_TESDV)
								If MsSeek(xFilial("SF4")+cTesDev)
									aCols[nX][GDFieldPos("DT_TES")] := cTesDev
									oGetDados:aCols[nX,GDFieldPos("DT_TES")] := cTesDev
	
									// Atualiza impostos
									lContinua := ColAtuImp(oGetDados:aCols[nX,GDFieldPos("DT_TES")],nX)
	
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					Exit
				EndIf
			Next nX
			oGetDados:aCols := aClone(aCols)
			oGetDados:Refresh()
		Endif
	Else //Desvincular NF Origem
		If Empty(oGetDados:aCols[oGetDados:nAt,GdFieldPos("DT_NFORI")])
			Aviso(STR0137,STR0183, {"Ok"}, 2) //"Não há nota de origem para realizar o desvinculo."
			lRet := .F.
		Else
			oGetDados:aCols[oGetDados:nAt,GdFieldPos("DT_NFORI")]	:= Space(TamSx3("DT_NFORI")[1])
			oGetDados:aCols[oGetDados:nAt,GdFieldPos("DT_SERIORI")]	:= Space(TamSx3("DT_SERIORI")[1])
			oGetDados:aCols[oGetDados:nAt,GdFieldPos("DT_ITEMORI")]	:= Space(TamSx3("DT_ITEMORI")[1])

			aCols		:= aClone(oGetDados:aCols)
			oGetDados:Refresh()
		Endif
	Endif	
EndIf	

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | Pedidos    ³Autor ³ Rodrigo de Toledo		   |Data ³ 30/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao responsavel por criar o browse de selecao para que o      ³±±  
±±³          | usuario escolha os pedidos de compra referentes aos itens na NF  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProduto: codigo do produto posicionado.						    ³±±
±±³			 ³ lPedDoc: indica se a selecao e por documento.					³±±
±±³			 ³ cAliasTmp: alias com o resultado da query dos documentos			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±        
±±³Retorno   ³ lRet: indica a confirmacao da selecao dos pedidos                ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Documentos														³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/ 
Static Function Pedidos(cProduto,lPedDoc,cAliasTmp,lConsLoja,nMultPC,aColsAnt,cForn,cLoja,aPedidos,oBrowse)
Local lRet 		 := .F.
Local oDlg		 := NIL
Local oComboBox := Nil
Local aArea		 := GetArea()
Local aCampos    := {} 
Local oSize
Local nX		 := 0
Local nY		 := 0
Local nP       := 0
Local nPos       := 0
Local nPosQtde	 := aScan(aHeader,{|x| AllTrim(x[2]) == "DT_QUANT"})
Local lContinua	 := .T.
Local lA140IPed  := ExistBlock("A140IPED")
Local aRetPE     := {}
Local nZ         := 0
Local cCampoUsr  := ""
Local cSeek		 := ""
Local nPosCod    := ""
Local cComboFor	 := ''
Local cItem		 := StrZero(1,Len(SDT->DT_ITEM))
Local cLine		:= ''
Local aCampoUsr  := {}
Local aColsNew	 := {}
Local nPosCpo    := 0
Local nSldPed    := 0
Local nCont		 := 1
Local nTamCpos	 := 0
Local nMarcado	 := 0
Local nTotPed	 := 0
Local nTotQtd	 := 0
Local nSaldo   := 0
Local n			 := oGetDados:nAt
Local nPedSel	 := 0
Local nPosCodPc	 := 0
Local cFilSA2	 := xFilial("SA2")
Local cFilSB1	 := xFilial("SB1")
Local cFilSC7	 := xFilial("SC7")
Local cFilBak	 := cFilAnt
Local cSavCadast := cCadastro
Local lZeraCols  := .T.
Local lExit		 := .F.
Local lForPCNF	:= (SuperGetMV("MV_FORPCNF",,.F.) == .T.)
Local lRetPed	:= (aPedidos == Nil)
Local lMsgVinc  := .F.
Local lCOMCOLMS := ExistBlock("COMCOLMS")
Local nBkpN	    := 0
Local nA		:= 0
Local nDif      := 0
Local nPosQtd   := 0 
Local nPosPed	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "DT_PEDIDO"})
Local nPosItPc := aScan(oGetDados:aHeader,{|x| AllTrim(x[2]) == "DT_ITEMPC"})
Local lPCUsado	:= .F.
Local cProdLin  := ''
Local cProdAten := ''
Local nPrds	:= 0
Local nPPrd	:= 0
Local aPrds	:= {}
Local lPrdIgual := .F.
Local nPedIgual	:= 0
Local cPedIgual	:= 0
Local cPrdIgual := ""
Local aProdBkp	:= {}
Local aPedItBkp	:= {}
Local nQtdNF		:= 0
LOCAL lPedOri		:= .T.
Local lOriTemPed	:= .F.

Default nMultPC  := 0
Default cForn		:= SDS->DS_FORNEC
Default cLoja		:= SDS->DS_LOJA
Default aPedidos	:= {}

// Foi necessario criar essas variaveis para que fosse possivel usar a funcao padrao do sistema A120Pedido()
Private INCLUI      := .F.
Private ALTERA      := .F.
Private nTipoPed    := 1
Private l120Auto    := .F.  	                                   
Private oOk		:= LoadBitMap(GetResources(),"LBOK")
Private oNo		:= LoadBitMap(GetResources(),"LBNO")  	                                   

n := oGetDados:nAt

If !lPedDoc
	aCampos := {"",RetTitle("C7_LOJA"),RetTitle("C7_NUM"),RetTitle("C7_ITEM"),RetTitle("C7_PRODUTO"),RetTitle("C7_EMISSAO"),STR0060,RetTitle("C7_PRECO")} //-- Saldo
	bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;								//-- Marca
					aPedidos[oBrowse:nAt,2],;											//-- Loja
					aPedidos[oBrowse:nAt,3],;											//-- Pedido
					aPedidos[oBrowse:nAt,4],;											//-- Item
					aPedidos[oBrowse:nAt,5],;											//-- Produto
					aPedidos[oBrowse:nAt,6],;											//-- Emissao
					Transform(aPedidos[oBrowse:nAt,7],PesqPict("SC7","C7_QUANT")),;//-- Saldo
					Transform(aPedidos[oBrowse:nAt,8],PesqPict("SC7","C7_PRECO"))}} //-- Preço

	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ 	 
	// |  Ponto de entrada utilizado para adicionar campos na interface de visualização de pedidos  |	
   	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	If lA140IPed
		nTamCpos := Len(aCampos)
		aRetPE := ExecBlock("A140IPED",.F.,.F.,{2,aCampos,aCampos})
		If ValType(aRetPE[1]) == "A"
			For nZ:=1 to Len(aRetPe[1])
				Aadd(aCampoUsr,aRetPE[3][1][nZ+nTamCpos])
			Next nZ
		EndIf
	EndIf					

	&(cAliasTmp+"->(dbGoTop())")   
	While &(cAliasTmp+"->(!EOF())")    
		aAdd(aPedidos, {.F.,;															//-- Marca
						&(cAliasTmp+"->C7_LOJA"),;										//-- Loja
						&(cAliasTmp+"->C7_NUM"),;										//-- Pedido
						&(cAliasTmp+"->C7_ITEM"),;										//-- Item
						&(cAliasTmp+"->C7_PRODUTO"),;									//-- Produto
						StoD(&(cAliasTmp+"->C7_EMISSAO")),;								//-- Emissao
						&(cAliasTmp+"->C7_QUANT") - &(cAliasTmp+"->C7_QTDACLA") - &(cAliasTmp+"->C7_QUJE"),;		//-- Saldo
	  					&(cAliasTmp+"->C7_PRECO")})

		If lA140IPed
			If ValType(aRetPE[1]) == "A"
				For nZ:=1 to Len(aRetPe[1])
					cCampoUsr := "CAMPO"+AllTrim(Str(nZ))
					nPosCpo := AScan( aCampoUsr, {|x| AllTrim(x[1]) == cCampoUsr } )
					If nPosCpo > 0
						If nCont==1
							Aadd(aCampos,aCampoUsr[nPosCpo][3])
						EndIf
						If aRetPE[2][1][nZ+nTamCpos][2]=="D"										// Se campo tipo Data
							Aadd(aPedidos[Len(aPedidos)],(StoD(&(cAliasTmp+"->"+aRetPE[1][nZ]))))	// Converte para data
						Else
							Aadd(aPedidos[Len(aPedidos)],((&(cAliasTmp+"->"+aRetPE[1][nZ]))))		// Caso contrário não converte
						EndIf
					Else
						Aadd(aPedidos[Len(aPedidos)],((&(cAliasTmp+"->"+aRetPE[1][nZ]))))
					EndIf
				Next nZ
			EndIf
			nCont++
		EndIf
		
		Aadd(aPedidos[Len(aPedidos)],.F.)
		
        //-- Se o pedido ja esta no aCols, marca como usado
        If !Empty(oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_PEDIDO")]) .And.;
					oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_PEDIDO")] == &(cAliasTmp+"->C7_NUM") .And.;
					oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_ITEMPC")] == &(cAliasTmp+"->C7_ITEM")
			aTail(aPedidos)[1] := .T.
			aTail(aPedidos)[Len(aPedidos[1])] := .T.
		EndIf

		&(cAliasTmp)->(dbSkip())
	EndDo 

	If lA140IPed
		If ValType(aRetPE[1]) == "A"
			cLine := '{|| { If(aPedidos[oBrowse:nAt,1],oOk,oNo),'								//-- Marca
			cLine += '		   aPedidos[oBrowse:nAt,2],'										//-- Loja
			cLine += '   	   aPedidos[oBrowse:nAt,3],'										//-- Pedido
			cLine += '	 	   aPedidos[oBrowse:nAt,4],'										//-- Item
			cLine += '	 	   aPedidos[oBrowse:nAt,5],'										//-- Produto
			cLine += '	 	   aPedidos[oBrowse:nAt,6],'										//-- Emissao
			cLine += '	 	   Transform(aPedidos[oBrowse:nAt,7],PesqPict("SC7","C7_QUANT")),'//-- Saldo
			cLine += '	 	   Transform(aPedidos[oBrowse:nAt,8],PesqPict("SC7","C7_PRECO"))'
								
			For nZ := 1 To Len(aRetPE[1])
				cLine += ' , aPedidos[oBrowse:nAt,' + AllTrim(Str(nZ+nTamCpos)) + ']'
			Next nZ
			
			cLine += ' }}'
			
			bLine := &cLine
		EndIf
	EndIf

Else
	aCampos := {"",RetTitle("C7_LOJA"),RetTitle("C7_NUM"),RetTitle("C7_EMISSAO")}
	bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;	//-- Marca
					aPedidos[oBrowse:nAt,2],;				//-- Loja
					aPedidos[oBrowse:nAt,3],;				//-- Pedido
					aPedidos[oBrowse:nAt,4]	}	}			//-- Emissao

	If nMultPc < 3
		&(cAliasTmp+"->(dbGoTop())")   
		While &(cAliasTmp+"->(!EOF())")    
			aAdd(aPedidos, {.F.,;															//-- Marca
							&(cAliasTmp+"->C7_LOJA"),;										//-- Loja
							&(cAliasTmp+"->C7_NUM"),;										//-- Pedido
							StoD(&(cAliasTmp+"->C7_EMISSAO")),;							//-- Emissao
							.F.	})
		
			//-- Se o pedido ja esta no aCols, marca como usado
	        If !Empty(oGetDados:aCols[n,GDFieldPos("DT_PEDIDO")]) .And.;
						oGetDados:aCols[n,GDFieldPos("DT_PEDIDO")] == &(cAliasTmp+"->C7_NUM")
				aTail(aPedidos)[1] := .T.
				aTail(aPedidos)[Len(aPedidos[1])] := .T.
			EndIf
			//-- Vínculo por múltiplos pedidos
			If nMultPC > 0
				For nX := 1 To Len(oGetDados:aCols)
					If !Empty(oGetDados:aCols[nX,GDFieldPos("DT_PEDIDO")]) .And.;
								oGetDados:aCols[nX,GDFieldPos("DT_PEDIDO")] == &(cAliasTmp+"->C7_NUM")
						aTail(aPedidos)[1] := .T.
						aTail(aPedidos)[Len(aPedidos[1])] := .T.
					EndIf
				Next nX
			EndIf
			&(cAliasTmp)->(dbSkip())
		EndDo
	Else
		aCampos := {"",RetTitle("C7_NUM"),AllTrim(RetTitle("C7_ITEM"))+ " PC",AllTrim(RetTitle("DT_ITEM"))+" NF"}
		bLine := {|| {	If(aPedidos[oBrowse:nAt,1],oOk,oNo),;	//-- Marca
					aPedidos[oBrowse:nAt,2],;				//-- PC
					aPedidos[oBrowse:nAt,3],;				//-- Item PC
					aPedidos[oBrowse:nAt,4]}}				//-- Item NF
					
		For nX := 1 To Len(oGetDados:aCols)
			If !Empty(oGetDados:aCols[nX,GDFieldPos("DT_PEDIDO")]) .And. !Empty(oGetDados:aCols[nX,GDFieldPos("DT_ITEMPC")])
				aAdd(aPedidos, {.F.,;															//-- Marca
									oGetDados:aCols[nX,GDFieldPos("DT_PEDIDO")],;				//-- PC
									oGetDados:aCols[nX,GDFieldPos("DT_ITEMPC")],;
									StrZero(nX,TamSx3("DT_ITEM")[1]),;
									.F.})				//-- Item PC
			EndIf
		Next nX
		
		If Len(aPedidos) == 0
			lRetPed := .F.
			lRet := .T.
		Endif
	Endif 	
EndIf	                                       

If lRetPed
//-- Monta interface para selecao do pedido
	
	Define MsDialog oDlg Title Iif(nMultPC<>3,STR0061,"Desvincular") From 000,000 To 330,480 Pixel //-- Vínculo com Pedido de Compra
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula dimensões                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSize := FwDefSize():New(.F.,,,oDlg)
	oSize:AddObject( "CABECALHO",  100, 15, .T., .T. ) // Totalmente dimensionavel
	oSize:AddObject( "GETDADOS" ,  100, 75, .T., .T. ) // Totalmente dimensionavel 
	oSize:AddObject( "RODAPE"   ,  100, 10, .T., .T. ) // Totalmente dimensionavel
	
	oSize:lProp 	:= .T. // Proporcional             
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 

	oSize:Process() 	   // Dispara os calculos   

//-- Cabecalho
	
If !lPedDoc
		@oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI") Say STR0062 +SDS->DS_DOC +" - " +STR0063 +AllTrim(oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_ITEM")]) +" / " +AllTrim(cProduto) + " - " + Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC") Pixel Of oDlg //-- Doc: # Item:
Else
		@oSize:GetDimension("CABECALHO","LININI"),oSize:GetDimension("CABECALHO","COLINI") Say STR0062 +SDS->DS_DOC +" - " +STR0064 +SDS->DS_FORNEC +"/" +SDS->DS_LOJA +" - " +Posicione("SA2",1,xFilial("SA2")+SDS->(DS_FORNEC+DS_LOJA),"A2_NOME") Pixel Of oDlg //-- Doc: # Fornecedor
EndIf 		

//-- Itens
	If lForPCNF
		@ oSize:GetDimension("CABECALHO","LININI")+12,oSize:GetDimension("CABECALHO","COLINI") SAY OemToAnsi('Fornecedor:') Of oDlg PIXEL SIZE 120 ,9 //"Fornecedor:"
		@ oSize:GetDimension("CABECALHO","LININI")+12,oSize:GetDimension("CABECALHO","COLINI")+34 MSCOMBOBOX oComboBox VAR cComboFor ITEMS MTGetForRl(SDS->DS_FORNEC,SDS->DS_LOJA) SIZE 160,10 OF oDlg PIXEL ON CHANGE LoadItens(cProduto,lPedDoc,nMultPC,aColsAnt,cComboFor,@oBrowse,aCampos,@aPedidos)
		
		//-- Itens
		oBrowse := TCBrowse():New( oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 				oSize:GetDimension("GETDADOS","XSIZE"),oSize:GetDimension("GETDADOS","YSIZE"),;
						 				,aCampos,,oDlg,,,,,{|| MarcaPC(@aPedidos,oBrowse:nAt,lPedDoc,nMultPC,oBrowse),oBrowse:Refresh()},,,,,,,,,.T.)
		oBrowse:SetArray(aPedidos)
		If !Empty(aPedidos)
			oBrowse:bLine := bLine
		Else
			cLine			:= Replicate("'',",Len(aCampos)-1)
			oBrowse:bLine := &( "{ ||{ If(Empty(aPedidos),oNO,oOK)," +Substr(cLine,1,Rat(',',cLine)-1 ) +"} }"  )
		EndIf

//-- Botoes
		TButton():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI"),;
						STR0065,oDlg,{|| MsgRun(STR0066 +AllTrim(aPedidos[oBrowse:nAt,3]) +"...",STR0003, {|| GetC7Recno(aPedidos[oBrowse:nAt,Iif(nMultPc==3,2,3)]), cFilAnt := cFilBak, cCadastro := cSavCadast } )},055,012,,,,.T.) //-- Visualizar pedido # Carregando visualização do pedido  
																													
		Define SButton From oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+150 Type 1 Action Eval({|| If(lRet := ValidPC(cProduto,lPedDoc,aPedidos,oBrowse:nAt,nMultPC,lConsLoja),oDlg:End(),)}) Enable Of oDlg
		Define SButton From oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+180 Type 2 Action oDlg:End() Enable Of oDlg
	
	Else
		//-- Itens
		oBrowse := TCBrowse():New(oSize:GetDimension("GETDADOS","LININI"),oSize:GetDimension("GETDADOS","COLINI"),;
						 				oSize:GetDimension("GETDADOS","XSIZE"),oSize:GetDimension("GETDADOS","YSIZE"),;
						 				,aCampos,,oDlg,,,,,{|| MarcaPC(@aPedidos,oBrowse:nAt,lPedDoc,nMultPC,oBrowse),oBrowse:Refresh()},,,,,,,,,.T.)
		oBrowse:SetArray(aPedidos)
		oBrowse:bLine := bLine
		
		//-- Botoes
		TButton():New(oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI"),;
						STR0065,oDlg,{|| MsgRun(STR0066 +AllTrim(aPedidos[oBrowse:nAt,3]) +"...",STR0003, {|| nBkpN := N, GetC7Recno(aPedidos[oBrowse:nAt,Iif(nMultPc==3,2,3)]), cFilAnt := cFilBak, cCadastro := cSavCadast } )},055,012,,,,.T.) //-- Visualizar pedido # Carregando visualização do pedido  
																													
		Define SButton From oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+180 Type 1 Action Eval({|| If(lRet := ValidPC(cProduto,lPedDoc,aPedidos,oBrowse:nAt,nMultPC,lConsLoja),oDlg:End(),), nPedSel := oBrowse:nAt }) Enable Of oDlg
		Define SButton From oSize:GetDimension("RODAPE","LININI"),oSize:GetDimension("RODAPE","COLINI")+210 Type 2 Action oDlg:End() Enable Of oDlg
	EndIf
 	
Activate Dialog oDlg Centered
Else
 	If nMultPc <> 3
	 	If !Empty(aPedidos)
			oBrowse:bLine := bLine
		Else
			cLine			:= Replicate("'',",Len(aCampos)-1)
			oBrowse:bLine := &( "{ ||{ If(Empty(aPedidos),oNO,oOK)," +Substr(cLine,1,Rat(',',cLine)-1 ) +"} }"  )
		EndIf
	Endif
EndIf

//se pedido foi visualizado, restaura variavel N (Controle de posiçao do aCols)       
If lRet .And. nBkpN > 0
	N 		:= nBkpN
	nBkpN 	:= 0
EndIf 
          
If lRet .And. nMultPC == 1 //Item
	aColsBkp	:= aClone(oGetDados:aCols)
	aCols		:= aClone(oGetDados:aCols)
	cItem		:= StrZero(Len(aColsBkp)+1,TamSx3("DT_ITEM")[1])
	
	//Produto a ser vinculado
	cProdAten	:= oGetDados:aCols[oGetDados:nAt,GdFieldPos("DT_COD")]
	
	//Quantidade do produto
	nProdQtd	:= oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_QUANT")]
	
	//aPedItBkp	- Busca os pedidos ja vinculados 
	For nX := 1 To Len(aColsBkp)
		If !Empty(aColsBkp[nX][GDFieldPos("DT_PEDIDO")])
			If aScan(aPedItBkp,{|x| x[1] == aColsBkp[nX][GDFieldPos("DT_PEDIDO")] .And. x[2] == aColsBkp[nX][GDFieldPos("DT_ITEMPC")]}) == 0
				aAdd(aPedItBkp,{aColsBkp[nX][GDFieldPos("DT_PEDIDO")],aColsBkp[nX][GDFieldPos("DT_ITEMPC")]})
			Endif
		Endif
	Next nX
	
	//Verifica se esta vinculando algum pedido pela 1º vez
	//Verifica saldo do pedido, se pode ou não continuar sendo utilizado.
	For nX := 1 To Len(aPedidos)
		If aPedidos[nX][1] .And. !aPedidos[nX][Len(aPedidos[1])]
			nPosPc := aScan(oGetDados:aCols,{|x| x[GdFieldPos("DT_PEDIDO")] == aPedidos[nX][3] .And. x[GdFieldPos("DT_ITEMPC")] == aPedidos[nX][4]})
			If nPosPC > 0
				nQuant		:= Posicione("SC7",14,xFilial("SC7") + aPedidos[nX][3] + aPedidos[nX][4],"C7_QUANT")
				nQuje		:= Posicione("SC7",14,xFilial("SC7") + aPedidos[nX][3] + aPedidos[nX][4],"C7_QUJE")
				nQtdCla	:= Posicione("SC7",14,xFilial("SC7") + aPedidos[nX][3] + aPedidos[nX][4],"C7_QTDACLA")
					
				//Calcular saldo do pedido
				For nY := 1 To Len(oGetDados:aCols)
					If aPedidos[nX][3]+aPedidos[nX][4] == oGetDados:aCols[nY,GdFieldPos("DT_PEDIDO")]+oGetDados:aCols[nY,GdFieldPos("DT_ITEMPC")]
						nQtdNF += oGetDados:aCols[nY,GdFieldPos("DT_QUANT")]
					Endif
				Next nY
				
				nTotPed := nQuant - nQuje - nQtdCla - nQtdNF
				
				If nTotPed == 0
					Aviso(STR0137,STR0152 + AllTrim(aPedidos[nX][3])+"|"+AllTrim(aPedidos[nX][4]) + STR0153, {"Ok"}, 2) //"Não é possivel vincular o pedido: "#", pois o saldo ja foi atendido"
					lRet := .F.
				Else
					//Retira o pedido do array, para que ainda possa ser utilzado para vinculo
					//pois o pedido ainda possue saldo
					nPosPc := aScan(aPedItBkp,{|x| x[1] == aPedidos[nX][3] .And. x[2] == aPedidos[nX][4]})
					If nPosPc > 0
						aDel(aPedItBkp,nPosPc)
						aSize(aPedItBkp,Len(aPedItBkp)-1)
					Endif
				Endif
			Endif
		Endif
	Next nX
	
	//Processo de vincular pedidos (parcial ou total)
	If lRet
		For nX := 1 To Len(aPedidos)
			If aPedidos[nX][1] .And. !aPedidos[nX][Len(aPedidos[1])]
				If Select("PCMULT") > 0
					PCMULT->(DbCloseArea())
				Endif
				
				cQry := " SELECT C7_FILENT, C7_ITEM, C7_NUM, C7_PRODUTO, C7_QUANT-C7_QUJE-C7_QTDACLA AS QTDDISP, R_E_C_N_O_ AS RECNO"
				cQry += " FROM " + RetSqlName("SC7")
				cQry += " WHERE D_E_L_E_T_ = ''"
				cQry += " AND C7_NUM = '" + aPedidos[nX][3] + "'"
				cQry += " AND C7_FORNECE = '" + SDS->DS_FORNEC + "'"
				
				If lConsLoja
					cQry += " AND C7_LOJA = '" + SDS->DS_LOJA + "'"
				Endif
				
				cQry += " AND C7_FILENT = '"+xFilial("SC7")+"'"
				cQry += " AND C7_RESIDUO = ''"
				cQry += " AND D_E_L_E_T_ = ''"
				
				//Busca produto
				//1 - Pedidos apenas com o item (produto) igual ao item posicionado
				cQry += " AND C7_PRODUTO IN ('" + cProdAten + "')"
				cQry += " AND C7_ITEM = '" + aPedidos[nX][4] + "'"
				
				//Retira item ja vinculado
				For nY := 1 To Len(aPedItBkp)
					If aPedItBkp[nY,1] == aPedidos[nX][3]
						If !("C7_ITEM NOT IN" $ cQry)
							cQry += " AND C7_ITEM NOT IN ('" + aPedItBkp[nY,2] + "'"
						Else
							cQry += " ,'" + aPedItBkp[nY,2] + "'"
						Endif
					Endif
				Next nY
				
				If "C7_ITEM NOT IN" $ cQry
					cQry += ")"
				Endif
				
				cQry := ChangeQuery(cQry)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"PCMULT",.T.,.T.)
				
				DbSelectArea("PCMULT")
				While PCMULT->(!EOF())
					//Saldo disponivel - saldo ja utilizado na NF
					nSldPed := PCMULT->QTDDISP - nQtdNF
					If nSldPed > 0
						
						SC7->(DbGoto(PCMULT->RECNO))
						
						n := oGetDados:nAt
						
						// Calcula quantidade total dos pedidos utilizados.
						nSaldo := nProdQtd
											
						If nSldPed > nSaldo
							nSldPed := nSaldo
						EndIf
					
						If nSldPed == nSaldo // Caso a quantidade da NF seja igual ao do pedido de compra.
							If nSaldo > 0
								oGetDados:aCols[oGetDados:nAt, GDFieldPos("DT_PEDIDO")] := PCMULT->C7_NUM
								oGetDados:aCols[oGetDados:nAt, GDFieldPos("DT_ITEMPC")] := PCMULT->C7_ITEM
								
								aCols[n, GDFieldPos("DT_PEDIDO")] := PCMULT->C7_NUM
								aCols[n, GDFieldPos("DT_ITEMPC")] := PCMULT->C7_ITEM
								
								nProdQtd := 0
							Endif
						ElseIf nSldPed < nSaldo // Caso o saldo do pedido seja menor do que a quantidade restante no item da NF.
							
							If MsgYesNo(STR0154 + AllTrim(PCMULT->C7_NUM)+"|"+AllTrim(PCMULT->C7_ITEM) + STR0155 + StrZero(oGetDados:nAt,TamSX3("DT_ITEM")[1]) + STR0156) //"Quantidade do pedido|item: "#" é inferior ao item da NF: "#". Deseja incluir o saldo em um nova linha?"
								If nSaldo - nSldPed > 0
									// Altera linha atual do aCols para subtrair a quantidade do pedido de compra.
									// Para casos onde o saldo do pedido seja menor do que a quantidade da nota fiscal.
									VincMultPC(aPedidos,nSaldo - nSldPed,aColsBkp,oGetDados:aCols[oGetDados:nAt,GDFieldPos("DT_ITEM")],nMultPC,.T.,n,.F.)
										
									nProdQtd := nSaldo - nSldPed
								EndIf
									
								// Inclui linha nova com o saldo do pedido de compra.
								VincMultPC(aPedidos,nSldPed,aColsBkp,cItem,nMultPC)
							Else
								oGetDados:aCols[oGetDados:nAt, GDFieldPos("DT_PEDIDO")] := PCMULT->C7_NUM
								oGetDados:aCols[oGetDados:nAt, GDFieldPos("DT_ITEMPC")] := PCMULT->C7_ITEM
								
								aCols[n, GDFieldPos("DT_PEDIDO")] := PCMULT->C7_NUM
								aCols[n, GDFieldPos("DT_ITEMPC")] := PCMULT->C7_ITEM
								
								nProdQtd := 0
							Endif
						EndIf
					
						cItem := SomaIt(cItem)
						oGetDados:aCols := aClone(aCols)
					EndIf
					PCMULT->(DbSkip())
				Enddo
				PCMULT->(DbCloseArea())
			Endif
		Next nX
	Endif
Elseif lRet .And. nMultPc == 2 //Pedido
	aColsBkp	:= aClone(oGetDados:aCols)
	aCols		:= aClone(oGetDados:aCols)
	cItem		:= StrZero(Len(aColsBkp)+1,TamSx3("DT_ITEM")[1])

	aProdBkp	:= {}
	aPedItBkp	:= {}
	
	//aProdBkp		- Busca produto que não tem vinculo com pedido
	//aPedItBkp	- Busca os pedidos ja vinculados 
	For nX := 1 To Len(aColsBkp)
		If aScan(aProdBkp,{|x| x[1] == aColsBkp[nX][GDFieldPos("DT_COD")]}) == 0 .And. Empty(aColsBkp[nX][GDFieldPos("DT_PEDIDO")])
			aAdd(aProdBkp,{aColsBkp[nX][GDFieldPos("DT_COD")],aColsBkp[nX][GDFieldPos("DT_QUANT")],aColsBkp[nX][GDFieldPos("DT_ITEM")]})
		Endif
		
		If !Empty(aColsBkp[nX][GDFieldPos("DT_PEDIDO")])
			If aScan(aPedItBkp,{|x| x[1] == aColsBkp[nX][GDFieldPos("DT_PEDIDO")] .And. x[2] == aColsBkp[nX][GDFieldPos("DT_ITEMPC")]}) == 0
				aAdd(aPedItBkp,{aColsBkp[nX][GDFieldPos("DT_PEDIDO")],aColsBkp[nX][GDFieldPos("DT_ITEMPC")]})
			Endif
		Endif
	Next nX
	
	//Busca por itens iguais
	aPrds := COMITIG(SDS->DS_FORNEC,SDS->DS_LOJA,SDS->DS_DOC,SDS->DS_SERIE)
	If Len(aPrds) > 0
		//Busca por itens iguais sem vinculo.
		//Apagado do aProdBkp para não vincular item
		For nX := 1 To Len(aPrds)
			//O mesmo produto em itens diferentes na NF
			For nY := 1 To Len(aProdBkp)
				If nY > Len(aProdBkp)
					Exit
				Endif
						
				If aProdBkp[nY,1] == aPrds[nX]
					aDel(aProdBkp,nY)
					aSize(aProdBkp,Len(aProdBkp)-1)
					lPrdIgual := .T.
					If Empty(cPrdIgual)
						cPrdIgual := STR0187 + AllTrim(aPrds[nX]) //"Os Produto(s): "
					Else
						cPrdIgual += "|" + AllTrim(aPrds[nX])
					Endif
				Endif
			Next nY
		Next nX
	Endif
	
	If lPrdIgual
		Aviso(STR0137,cPrdIgual + STR0157, {"Ok"}, 2) //" são iguais em mais de 1 item, por esse motivo o mesmo deve ser vinculado por ITEM"
	Endif	
	
	//Verifica se esta vinculando algum pedido pela 1º vez
	//Valida que todos os itens ja foram atendidos.
	For nX := 1 To Len(aPedidos)
		If aPedidos[nX][1] .And. !aPedidos[nX][Len(aPedidos[1])] .And. Len(aProdBkp) == 0
			If !lPrdIgual
				Aviso(STR0137,STR0158, {"Ok"}, 2) //"Não é possivel mais vincular pedidos, pois o saldo ja foi atendidos pelos pedidos de compras."
			Endif
			lRet := .F.
		Endif
	Next nX
	
	//Verifica se esta vinculando algum pedido pela 1º vez
	//Valida se o pedido possui o mesmo produto em diferentes itens, 
	//se possuir o pedido sera ignorado e alertado para vincular por ITEM
	If lRet
		For nX := 1 To Len(aPedidos)
			If aPedidos[nX][1] .And. !aPedidos[nX][Len(aPedidos[1])]
				nPedIgual := COMPCPRDUP(aPedidos[nX][3])
				
				If nPedIgual == 1
					If Empty(cPedIgual)
						cPedIgual := STR0188 + AllTrim(aPedidos[nX][3]) //"Pedido(s): "
					Else
						cPedIgual += "|" + AllTrim(aPedidos[nX][3])
					Endif
					
					aPedidos[nX][1] := .F.
				Endif
			Endif
		Next nX
				
		If !Empty(cPedIgual)
			Aviso(STR0137,cPedIgual + STR0159, {"Ok"}, 2) //" não serão utilizados, pois possuem produto iguais em itens diferentes no PEDIDO. O mesmo deve ser utilizado vinculo por ITEM."
		Endif
	Endif	
	
	//Processo de vincular pedidos (parcial ou total)
	If lRet
		For nX := 1 To Len(aPedidos)
			If aPedidos[nX][1] .And. !aPedidos[nX][Len(aPedidos[1])]
				If Select("PCMULT") > 0
					PCMULT->(DbCloseArea())
				Endif
				
				cQry := " SELECT C7_FILENT, C7_ITEM, C7_NUM, C7_PRODUTO, C7_QUANT-C7_QUJE-C7_QTDACLA AS QTDDISP, R_E_C_N_O_ AS RECNO"
				cQry += " FROM " + RetSqlName("SC7")
				cQry += " WHERE D_E_L_E_T_ = ''"
				cQry += " AND C7_NUM = '" + aPedidos[nX][3] + "'"
				cQry += " AND C7_FORNECE = '" + SDS->DS_FORNEC + "'"
				
				If lConsLoja
					cQry += " AND C7_LOJA = '" + SDS->DS_LOJA + "'"
				Endif
				
				cQry += " AND C7_FILENT = '"+xFilial("SC7")+"'"
				cQry += " AND C7_RESIDUO = ''"
				cQry += " AND D_E_L_E_T_ = ''"
				
				//Busca produto

				//2 - Busca pedidos com os itens que não possuem vinculo com pedidos
				For nY := 1 To Len(aProdBkp)
					If nY == 1
						cQry += " AND C7_PRODUTO IN ('" + aProdBkp[nY,1] + "'"
						If nY == Len(aProdBkp)
							cQry += ")"
						Endif
					Else
						cQry += " ,'" + aProdBkp[nY,1] + "'"
						If nY == Len(aProdBkp)
							cQry += ")"
						Endif	
					Endif
				Next nY
			
				//Retira item ja vinculado
				For nY := 1 To Len(aPedItBkp)
					If aPedItBkp[nY,1] == aPedidos[nX][3]
						If !("C7_ITEM NOT IN" $ cQry)
							cQry += " AND C7_ITEM NOT IN ('" + aPedItBkp[nY,2] + "'"
						Else
							cQry += " ,'" + aPedItBkp[nY,2] + "'"
						Endif
					Endif
				Next nY
				
				If "C7_ITEM NOT IN" $ cQry
					cQry += ")"
				Endif
				
				cQry := ChangeQuery(cQry)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"PCMULT",.T.,.T.)
				
				nTotPed := 0
				
				DbSelectArea("PCMULT")
				While PCMULT->(!EOF())
					nSldPed := PCMULT->QTDDISP
					If nSldPed > 0
						
						SC7->(DbGoto(PCMULT->RECNO))
						
						nPPrdBkp := aScan(aProdBkp,{|x| x[1] == PCMULT->C7_PRODUTO})
						
						n				:= Val(aProdBkp[nPPrdBkp,3])
						oGetDados:nAt	:= Val(aProdBkp[nPPrdBkp,3])

						// Calcula quantidade total dos pedidos utilizados.
						nSaldo := aProdBkp[nPPrdBkp,2]
						
						If nPPrdBkp > 0
												
							// Calcula quantidade total dos pedidos utilizados.
							If nSldPed > nSaldo
								nSldPed := nSaldo
							EndIf
						
							If nSldPed == nSaldo // Caso a quantidade da NF seja igual ao do pedido de compra.
								oGetDados:aCols[oGetDados:nAt, GDFieldPos("DT_PEDIDO")] := PCMULT->C7_NUM
								oGetDados:aCols[oGetDados:nAt, GDFieldPos("DT_ITEMPC")] := PCMULT->C7_ITEM
								
								aCols[n, GDFieldPos("DT_PEDIDO")] := PCMULT->C7_NUM
								aCols[n, GDFieldPos("DT_ITEMPC")] := PCMULT->C7_ITEM
								
								aProdBkp[nPPrdBkp,2] := 0

							ElseIf nSldPed < nSaldo // Caso o saldo do pedido seja menor do que a quantidade restante no item da NF.
								
								If nSaldo - nSldPed > 0

									// Altera linha atual do aCols para subtrair a quantidade do pedido de compra.
									// Para casos onde o saldo do pedido seja menor do que a quantidade da nota fiscal.
									VincMultPC(aPedidos,nSaldo - nSldPed,aColsBkp,aProdBkp[nPPrdBkp,3],nMultPC,.T.,n,.F.)
									
									aProdBkp[nPPrdBkp,2] := nSaldo - nSldPed
								EndIf
										
								// Inclui linha nova com o saldo do pedido de compra.
								VincMultPC(aPedidos,nSldPed,aColsBkp,cItem,nMultPC)

							EndIf
						
							cItem := SomaIt(cItem)
							oGetDados:aCols := aClone(aCols)
						Endif
					EndIf
					PCMULT->(DbSkip())
				Enddo
				PCMULT->(DbCloseArea())
			Endif
		Next nX
	Endif
Elseif lRet .And. nMultPc == 3 //Desvincular

	If !lRetPed
		Aviso(STR0137,STR0160, {"Ok"}, 2) //"Não há pedidos para realizar o desvinculo."
		lRet := .F.
	Else
		aCols		:= aClone(oGetDados:aCols)
		aColsBkp	:= aClone(oGetDados:aCols)
		
		For nX := 1 To Len(aPedidos)
			If aPedidos[nX][1]
				nMarcado++
			Endif
		Next nX
		
		IF nMarcado == Len(aPedidos)
			lPedOri := ComXItOri(aColsAnt)
			lOriTemPed := lPedOri
		ENDIF
			
		IF lPedOri // Tem pedido no SDT original ou nMarcado != Len(aPedidos)
			For nX := 1 To Len(aPedidos)
				If aPedidos[nX][1]
					nPosItem := AScan(oGetDados:aCols, {|x| AllTrim(x[GdFieldPos("DT_ITEM")]) == AllTrim(aPedidos[nX,4])})
					
					If nPosItem > 0
						nQtdItem := oGetDados:aCols[nPosItem,GdFieldPos("DT_QUANT")]
						cCodItem := oGetDados:aCols[nPosItem,GdFieldPos("DT_COD")]
						
						//Busca por itens iguais
						aPrds := COMITIG(SDS->DS_FORNEC,SDS->DS_LOJA,SDS->DS_DOC,SDS->DS_SERIE)
						If Len(aPrds) > 0
							nPPrd := aScan(aPrds,{|x| x == cCodItem})
							If nPPrd > 0 
								For nP := 1 To Len(oGetDados:aCols)
									If cCodItem == oGetDados:aCols[nP,GdFieldPos("DT_COD")] .And. Empty(oGetDados:aCols[nP,GdFieldPos("DT_PEDIDO")])
										nCont++
									Endif
								Next nP
							
								If nCont > 1
									lPrdIgual := .T.
								Endif
							Endif
						Endif
						
						//Ser for desvincular um produto que esta em mais de um item da NF
						//Sera apresentada um tela para que o usuario defina em qual item deseja desvincular,
						//Caso contrario sera feito o desvinculo normalmente.
						If lOriTemPed
							nPosCodPc := 0
						ElseIf !lPrdIgual
							nPosCodPc := AScan(oGetDados:aCols, {|x| AllTrim(x[GdFieldPos("DT_COD")]) == AllTrim(cCodItem) .And. Empty(AllTrim(x[GdFieldPos("DT_PEDIDO")]))})
						Else
							nPosCodPc := COMITDESV(cCodItem,nPosItem,oGetDados:aCols[nPosItem,GdFieldPos("DT_PEDIDO")],oGetDados:aCols[nPosItem,GdFieldPos("DT_ITEMPC")])
							If nPosCodPc == nPosItem
								nPosCodPc := 0
							Endif
						Endif
							
						If nPosCodPc > 0
							oGetDados:aCols[nPosCodPc,GdFieldPos("DT_QUANT")] += nQtdItem
							oGetDados:aCols[nPosCodPc,GdFieldPos("DT_TOTAL")] := oGetDados:aCols[nPosCodPc,GdFieldPos("DT_QUANT")]*oGetDados:aCols[nPosCodPc,GdFieldPos("DT_VUNIT")]
						
							aDel(oGetDados:aCols,nPosItem)
							aSize(oGetDados:aCols,Len(oGetDados:aCols)-1)
						Elseif nPosCodPc == 0
							oGetDados:aCols[nPosItem,GdFieldPos("DT_PEDIDO")] := Space(TamSx3("DT_PEDIDO")[1])
							oGetDados:aCols[nPosItem,GdFieldPos("DT_ITEMPC")] := Space(TamSx3("DT_ITEMPC")[1])
						Endif
						
						aCols := aClone(oGetDados:aCols)

					Endif
				Endif
			Next nX
			
			If lPrdIgual 
				//Valor da NF Original
				aCols	:= GDNFORIG({},SDS->DS_FORNEC,SDS->DS_LOJA,SDS->DS_DOC,SDS->DS_SERIE,1)
				nTotNF := 0
				
				For nX := 1 to Len(aCols)
					nTotNF += aCols[nX,GdFieldPos("DT_TOTAL")]
				Next nX
				
				//Valor da NF atualizada
				nTotNFAtu	:= 0
				
				For nX := 1 to Len(oGetDados:aCols)
					nTotNFAtu += oGetDados:aCols[nX,GdFieldPos("DT_TOTAL")]
				Next nX
				
				If nTotNF <> nTotNFAtu
					Aviso(STR0137,STR0161,{"Ok"}) //"Atencao"#"Valor da NF original diferente do valor da NF alterada. Sera desfeito o desvinculo."
					oGetDados:aCols	:= aClone(aColsBkp)
					aCols				:= aClone(aColsBkp)
				Else
					aCols				:= aClone(oGetDados:aCols)
				Endif
			Endif
		Endif
	Endif
Endif

// Atualiza TES e Impostos
If lRet 
	lContinua := .T.
	SC7->(DbSetOrder(14))
	For nX := 1 To Len(oGetDados:aCols)
		If lContinua
			If SC7->(DbSeek(xFilial("SC7")+oGetDados:aCols[nX,GDFieldPos("DT_PEDIDO")]+oGetDados:aCols[nX,GDFieldPos("DT_ITEMPC")]))
				If !Empty(SC7->C7_TES)
					aCols := aClone(oGetDados:aCols)
					oGetDados:aCols[nX,GDFieldPos("DT_TES")] := SC7->C7_TES
					aCols[nX][GDFieldPos("DT_TES")] := SC7->C7_TES // Preenche aCols tambem, pois nas linhas abaixo o objeto sobrescreve o array.

					lContinua := ColAtuImp(oGetDados:aCols[nX,GDFieldPos("DT_TES")],nX)
				EndIf
			EndIf
		Else
			Exit
		EndIf
	Next nX
EndIf

If lRet
	n := Len(aCols)
	//Ajuste numeração do item, e descrição do produto
	For nX := 1 To Len(oGetDados:aCols)
		oGetDados:aCols[nX,GdFieldPos("DT_ITEM")] := StrZero(nX,TamSx3("DT_ITEM")[1])
		
		If Empty(AllTrim(oGetDados:aCols[nX,GdFieldPos("DT_DESC")]))
			oGetDados:aCols[nX,GdFieldPos("DT_DESC")] := Posicione("SB1",1,xFilial("SB1") + PadR(oGetDados:aCols[nX][GdFieldPos("DT_COD")],TamSx3("B1_COD")[1]),"B1_DESC")
		Endif
	Next nX
	
	oGetDados:oBrowse:Refresh()
Endif
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMITDESV
Tela para que o usuario informe em qual item deseja retornar a
quantidade desvinculada.

@author rodrigo m pontes
@since 09/02/17
@version 1.0
@Return lRet
/*/
//-------------------------------------------------------------------

Static Function COMITDESV(cCodItem,nPosItem,cPedDesv,cItPCDesv)

Local nRet		:= 0
Local nX		:= 0
Local nTela	:= 0
Local nItem	:= 0
Local aItDesv	:= {}
Local aCampos	:= {}
Local bLine	:= Nil
Local oOK		:= LoadBitmap(GetResources(),'LBOK')
Local oNO		:= LoadBitmap(GetResources(),'LBNO')
Local aSize	:= MsAdvSize()
Local nlTl1	:= aSize[1]
Local nlTl2	:= aSize[2]-20
Local nlTl3	:= aSize[1]+300
Local nlTl4	:= aSize[2]+480

For nX := 1 To Len(oGetDados:aCols)
	If oGetDados:aCols[nX,GdFieldPos("DT_COD")] == cCodItem .And. Empty(oGetDados:aCols[nX,GdFieldPos("DT_PEDIDO")])
		aAdd(aItDesv,{.F.,cCodItem,oGetDados:aCols[nX,GdFieldPos("DT_ITEM")],.F.})
	Endif
Next nX

nPos := aScan(aItDesv,{|x| x[3] == StrZero(nPosItem,TamSx3("DT_ITEM")[1])})
If nPos == 0
	aAdd(aItDesv,{.F.,cCodItem,StrZero(nPosItem,TamSx3("DT_ITEM")[1]),.F.})
Endif

aCampos := {"",RetTitle("DT_COD"),RetTitle("DT_ITEM")}
bLine := {|| {If(aItDesv[oBrowseIT:nAt,1],oOk,oNo),;
					aItDesv[oBrowseIT:nAt,2],;
					aItDesv[oBrowseIT:nAt,3]}}
					
Define MsDialog oDlgIT Title STR0165 From nlTl1,nlTl2 To nlTl3,nlTl4 Pixel //"Item a ser restituido"
	
	//-- Cabecalho
	@(nlTl1+10),nlTl2 To (nlTl1+22),(nlTl2+240) Pixel Of oDlgIT
	
	@(nlTl1+12),(nlTl2+8) Say STR0162 + AllTrim(cPedDesv) + STR0163 + cItPCDesv  Pixel Of oDlgIT //"Definir em qual item a quantidade deve ser restituido do Pedido: "#" Item PC: "
	
	oBrowseIT := TCBrowse():New(nlTl1+30,nlTl2,nlTl4-245,nlTl3-200,,aCampos,,oDlgIT,,,,,{|| MarcaPC(@aItDesv,oBrowseIT:nAt,,,oBrowseIT),oBrowseIT:Refresh()},,,,,,,,,.T.)
	oBrowseIT:SetArray(aItDesv)
	oBrowseIT:bLine := bLine
	
	//-- Botoes
	TButton():New(nlTl1+134,nlTl2+3,STR0164,oDlgIT,{|| MontaTela(6)},055,012,,,,.T.) //"NF Original"
																													
	Define SButton From nlTl1+134,nlTl2+167 Type 1 Action Iif(ValidIT(aItDesv),(nTela := 1,oDlgIT:End()),) Enable Of oDlgIT
	Define SButton From nlTl1+134,nlTl2+202 Type 2 Action oDlgIT:End() Enable Of oDlgIT
		
Activate Dialog oDlgIT Centered

If nTela == 0
	nRet := -1
Else
	nRet := Val(aItDesv[aScan(aItDesv,{|x| x[1] == .T.}),3])
Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidIT
Valida se foi selecionado apenas 1 item para realizar o desvinculo

@author rodrigo m pontes
@since 09/02/17
@version 1.0
@Return lRet
/*/
//-------------------------------------------------------------------

Static Function ValidIT(aItDesv)

Local nX		:= 0
Local lRet		:= .T.
Local nCount	:= 0

For nX := 1 To Len(aItDesv)
	If aItDesv[nX,1]
		nCount++
	Endif
Next nX

If nCount > 1
	Aviso(STR0137,STR0166,{"Ok"}) //"Atencao"#"Selecione apenas 1 item."
	lRet := .F.
Elseif nCount == 0
	Aviso(STR0137,STR0167,{"Ok"}) //"Atencao"#"Selecionar 1 item para que o desvinculo ocorra."
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMPCPRDUP
Valida se o pedido possui um produto e mais de um item.

@author rodrigo m pontes
@since 09/02/17
@version 1.0
@Return lRet
/*/
//-------------------------------------------------------------------

Static Function COMPCPRDUP(cPedido)

Local nRet		:= 0
Local nCount	:= 0
Local aPrd		:= {}
Local nPrd		:= 0
Local aArea	:= GetArea()

DbSelectArea("SC7")
SC7->(DbSetOrder(14))
If SC7->(DbSeek(xFilial("SC7") + cPedido)) 
	While SC7->(!EOF()) .And. SC7->C7_NUM == cPedido
		nPrd := aScan(aPrd,{|x| x[1] == SC7->C7_PRODUTO})
		If nPrd == 0
			aAdd(aPrd,{SC7->C7_PRODUTO,1})
		Else
			aPrd[nPrd,2] += 1
		Endif
		SC7->(DbSkip())
	Enddo
	
	nPrd := aScan(aPrd,{|x| x[2] > 1})
	If nPrd > 0
		nRet := 1
	Endif 
Endif

RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadItens
Carregamento de Itens de pedido de fornecedores diferentes

@author guilherme.pimentel
@since 01/09/2014
@version 1.0
@Return lRet
/*/
//-------------------------------------------------------------------

Function LoadItens(cProduto,lPedDoc,nMultPC,aColsAnt,cComboFor,oBrowse,aCampos,aPedidos)
Local lRet 		:= .T.
Local cForn		:= ''
Local cLoja		:= ''

aPedidos := {}

cForn := SubStr(cComboFor,1,At('/',cComboFor)-1)
cLoja := SubStr(cComboFor,At('/',cComboFor)+1,At(' - ',cComboFor)-(At('/',cComboFor)+1))	
cForn := Padr(cForn,TamSX3("A2_COD")[1]) 
cLoja := Padr(cLoja,TamSX3("A2_LOJA")[1])

Documentos(cProduto,lPedDoc,nMultPC,aColsAnt,cForn,cLoja,@aPedidos,@oBrowse)

bLine := oBrowse:bLine

oBrowse:SetArray(aPedidos)
oBrowse:bLine := bLine
			
oBrowse:Refresh()

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | ValidPC    ³Autor ³ Rodrigo de Toledo Silva 	   |Data ³ 01/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Validacao dos campos qtde e preco Unit. do pedido de compra com  ³±± 
±±³			 | o documento NFe.						                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros| cCodProd: codigo do produto.										³±±   
±±³          | lPedDoc: indica se a busca e por documento ou item.				³±±
±±³          | aPedidos: array com os pedidos exibidos na tela de vinculo.		³±±
±±³          | nLinha: indica a linha do browse de pedidos que foi marcada.		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±        
±±³Retorno   ³ lRet: pedido valido ou nao valido                                ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Pedidos		                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function ValidPC(cCodProd,lPedDoc,aPedidos,nLinha,nMultPC,lConsLoja)
Local lRet		:= .T.
Local lAchou	:= .F.
Local lMarcado	:= .F.
Local aArea		:= SDT->(GetArea())
Local aAreaSC7	:= SC7->(GetArea())
Local aProds	:= {}
Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_COD"})
Local nPosQtde	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_QUANT"})
Local nX		:= 0
Local nY		:= 0
Local nSldPed	:= 0
Local nTotQtd	:= 0
Local nTotPed	:= 0
Local n			:= oGetDados:nAt
Local cFilSDT	:= xFilial("SDT")
Local nRecPc	:= 0

// Ponto de entrada para validacao do pedido selecionado
If ExistBlock("COMCOLPC")
	lRet := ExecBlock("COMCOLPC",.F.,.F.,{aCols,"TMP"})
ElseIf nMultPC > 0	// Validacao para vinculo de multiplos pedidos
	If nMultPc == 3
		lRet := .T.
	Else
		For nX := 1 To Len(oGetDados:aCols)
			AADD(aProds,AllTrim(aCols[nX][nPosCod]))
			nTotQtd += oGetDados:aCols[nX][nPosQtde]
		Next nX
	
		// Verifica se ha pedidos marcados
		For nX := 1 To Len(aPedidos)
			If aPedidos[nX][1] .And. !aPedidos[nX][Len(aPedidos[1])] 
				lMarcado := .T.
				Exit
			EndIf
		Next nX
	
		If nMultPC == 1			// Vinculo de multiplos pedidos por item
			nTotQtd := aCols[N][nPosQtde]
		EndIf
		
		If lRet
			For nY := 1 To Len(aPedidos)
				If aPedidos[nY][1] .And. !aPedidos[nY][Len(aPedidos[1])] 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Posiciona Pedido de Compra                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSeek := xFilial("SC7")+aPedidos[nY][3]
					DbSelectArea("SC7")
					DbSetOrder(14)
					dbSeek(cSeek)
		
					While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_NUM==cSeek )
						// Verifica se o fornecedor esta correto
						If C7_FORNECE+If(lConsLoja,C7_LOJA,"") == SDS->DS_FORNEC+If(lConsLoja,SDS->DS_LOJA,"")
							If aScan(aProds,{|x| x == AllTrim(SC7->C7_PRODUTO)}) > 0
								lAchou := .T.
							EndIf
							
							nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
							If nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) .And. If(nMultPC == 1,SC7->C7_ITEM==aPedidos[nY][4],.T.)
								nTotPed += nSldPed
							EndIf
						EndIf
						SC7->(dbSkip())             
					EndDo
				EndIf
			Next nY
			If lMarcado
				// Se nenhum produto dos pedidos selecionados corresponde a nenhum dos produtos da nota, nao efetua o vinculo
				If !lAchou
					Aviso(STR0004,STR0091,{STR0077})	// Nenhum produto dos pedidos selecionados confere com o(s) produtos da nota/item nota. Vínculo não será efetuado.
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Endif
EndIf
SC7->(RestArea(aAreaSC7))
SDT->(RestArea(aArea))

Return lRet

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | ValidXPC    ³Autor ³ TOTVS					   |Data ³ 19/05/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Validacao para utilizacao da funcionalidade de vinculo de		³±± 
±±³			 | multiplos pedidos.					                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros| cCodProd: codigo do produto.										³±±   
±±³          | lPedDoc: indica se a busca e por documento ou item.				³±±
±±³          | aPedidos: array com os pedidos exibidos na tela de vinculo.		³±±
±±³          | nLinha: indica a linha do browse de pedidos que foi marcada.		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±        
±±³Retorno   ³ lRet: pedido valido ou nao valido                                ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Documentos	                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function ValidXPC(lRemet,nMultPC,aColsAnt)

Local lRet		:= .T.
Local nX		:= 0
Local nPosValor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_VUNIT"})

If SDS->DS_TIPO $ "N" .Or. lRemet	//-- NF Normal (Compra) ou CT-e de saida
	// Posiciona no primeir item da nota
	DbSelectArea("SDT")
	DbSetOrder(2)
	MsSeek(xFilial("SDT")+SDS->(DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE))

	// Verifica se foi selecionada opcao Vinc Mult PC
	If lRet .And. (nMultPC == 1 .Or. nMultPC == 2)
		If lRet
			If !Empty(AllTrim(oGetDados:aCols[oGetDados:nAt,GdFieldPos("DT_PEDIDO")]))
				Aviso(STR0004,STR0168,{STR0077}) //"Este item ja possui vinculo com pedido, favor utilizar um item que não possua vinculo com nenhum pedido."  
				lRet := .F.
			Endif
		Endif
	EndIf
	
EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | MarcaPC	  ³Autor ³ Rodrigo de Toledo		   |Data ³ 30/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Executada quando o registro e marcado para desmarcar os demais.  ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPedidos: array com os pedidos exibidos em tela.					³±±  
±±³			 ³ nLinha: linha do pedido que foi marcado.							³±±  
±±³			 ³ lPedDoc: indica se e selecao por documento.						³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Pedidos	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function MarcaPC(aPedidos,nLinha,lPedDoc,nMultPC,oBrowse)
Local nDesmarca := 0

If !Empty(aPedidos)
	//-- Desmarca o item que ja estava marcado
	If !aPedidos[nLinha,Len(aPedidos[1])]
		aPedidos[nLinha,1] := !aPedidos[nLinha,1]
	Endif

	oBrowse:Refresh()
EndIf

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | GetC7Recno ³Autor ³ Rodrigo de Toledo		   |Data ³ 30/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Funcao para retornar o recno do pedido.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPedido: numero do pedido de compra                             	³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±        
±±³Retorno   ³ nRet: recno do pedido de compra									³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³Uso       ³ Pedidos														    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/  
Static Function GetC7Recno(cPedido)

SC7->(dbSetOrder(14))
If SC7->(dbSeek(xFilial("SC7")+cPedido))
	If Type("n") <> "N"
		n := oGetDados:nAt
	Endif
	
	A103VisuPC(SC7->(Recno()))
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | NOMEFORIni ³Autor ³ Rodrigo Toledo Silva		   |Data ³ 09/05/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Busca o nome do cliente quando o tipo da nota for devolucao ou   ³±±   
±±³			 | beneficiamento caso contrario busca o nome do fornecedor.   		³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±    
±±³Retorno   ³ Nome do fornecedor/cliente                                       ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Inicializador do campo DS_NOMEFOR (X3_RELACAO e X3_INIBRW)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

Function NOMEFORIni()
Local cNomeFC := ""
Local cFilSA1 := xFilial("SA1")
Local cFilSA2 := xFilial("SA2")
                                          
If SDS->DS_TIPO $ "DB"
	cNomeFC := Posicione("SA1",1,cFilSA1+SDS->(DS_FORNEC+DS_LOJA),"A1_NOME")
Else
	cNomeFC := Posicione("SA2",1,cFilSA2+SDS->(DS_FORNEC+DS_LOJA),"A2_NOME")
EndIf

Return(cNomeFC)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CPNJPict ºAutor  ³ Rodrigo Toledo     º Data ³  20/07/11     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna a picture de acordo com o tipo do fornecedor/cliente.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA140I                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPNJPict()
Local cAlias := If(SDS->DS_TIPO $ "DB","SA1","SA2")
Return PicPes(Posicione(cAlias,1,xFilial(cAlias)+M->(DS_FORNEC+DS_LOJA),Substr(cAlias,2)+"_TIPO"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | NFORIValid ³Autor ³ Rodrigo Toledo Silva		   |Data ³ 02/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao | Valida o preenchimento da NF de Origem quando a nota for Dev/Comp³±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±     
±±³Retorno   ³ lRet                                    							³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ COMXCOL	                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function NFORIValid()
Local lRet 	   	 := .T.
Local cCampo   	 := ReadVar() 
Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())
Local cFilSD1		:= xFilial("SD1")
Local cFilSD2		:= xFilial("SD2")
Local cFilSF1		:= xFilial("SF1")
Local cFilSF2		:= xFilial("SF2")

If SDS->DS_TIPO == "D"
	SF2->(dbSetOrder(1))
	If cCampo == "M->DT_NFORI" .And. !Empty(AllTrim(M->DT_NFORI))
		If !SF2->(dbSeek(cFilSF2+M->DT_NFORI))
			Aviso(STR0004,STR0078,{STR0077})
			lRet := .F.
		Else   
			aCols[n,GdFieldPos("DT_SERIORI")] := CriaVar("DT_SERIORI",.F.)
			aCols[n,GdFieldPos("DT_ITEMORI")] := CriaVar("DT_ITEMORI",.F.)
		EndIf
	ElseIf cCampo == "M->DT_SERIORI"
		If !Empty(AllTrim(M->DT_SERIORI))
			If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				Aviso(STR0004,STR0080,{STR0077})
				lRet := .F.
			ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				If !SF2->(dbSeek(cFilSF2+aCols[n,GdFieldPos("DT_NFORI")]+M->DT_SERIORI))
					Aviso(STR0004,STR0078,{STR0077})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cCampo == "M->DT_ITEMORI"
		If !Empty(AllTrim(M->DT_ITEMORI))
			If Val(M->DT_ITEMORI) > 0
				M->DT_ITEMORI := PADL(Val(M->DT_ITEMORI),2,"0")
			EndIf
			If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				Aviso(STR0004,STR0078,{STR0077})
				lRet := .F.
			ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				DbSelectArea("SF2")
				DbSetOrder(1)
				MsSeek(cFilSF2+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")] )
	
				dbSelectArea("SD2")
				dbSetOrder(3)
				If !MsSeek(cFilSD2+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")]+SF2->F2_CLIENTE+SF2->F2_LOJA+aCols[n,GdFieldPos("DT_COD")]+M->DT_ITEMORI)
					Aviso(STR0004,STR0078,{STR0077})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf SDS->DS_TIPO == "C"
	SF1->(dbSetOrder(1))
	If cCampo == "M->DT_NFORI" .And. !Empty(AllTrim(M->DT_NFORI))
		If !SF1->(dbSeek(cFilSF1+M->DT_NFORI))
			Aviso(STR0004,STR0078,{STR0077})
			lRet := .F.
		Else   
			aCols[n,GdFieldPos("DT_SERIORI")] := CriaVar("DT_SERIORI",.F.)
			aCols[n,GdFieldPos("DT_ITEMORI")] := CriaVar("DT_ITEMORI",.F.)
		EndIf
	ElseIf cCampo == "M->DT_SERIORI"
		If !Empty(AllTrim(M->DT_SERIORI))
			If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				Aviso(STR0004,STR0080,{STR0077})
				lRet := .F.
			ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				If !SF1->(dbSeek(cFilSF1+aCols[n,GdFieldPos("DT_NFORI")]+M->DT_SERIORI))
					Aviso(STR0004,STR0078,{STR0077})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cCampo == "M->DT_ITEMORI"
		If !Empty(AllTrim(M->DT_ITEMORI))
			If Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				Aviso(STR0004,STR0078,{STR0077})
				lRet := .F.
			ElseIf !Empty(AllTrim(aCols[n,GdFieldPos("DT_NFORI")]))
				DbSelectArea("SF1")
				DbSetOrder(1)
				MsSeek(cFilSF1+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")] )
	
				dbSelectArea("SD1")
				dbSetOrder(1)
				If !MsSeek(cFilSD1+aCols[n,GdFieldPos("DT_NFORI")]+aCols[n,GdFieldPos("DT_SERIORI")]+SF1->F1_FORNECE+SF1->F1_LOJA+aCols[n,GdFieldPos("DT_COD")]+M->DT_ITEMORI)
					Aviso(STR0004,STR0078,{STR0077})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaSD2)
RestArea(aAreaSF2)

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DirFilial  ºAutor  ³Flavio Lopes Rasta  º Data ³  08/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função que direciona os documentos do TOTVS Colaboração     º±±
±±º          ³ para sua devida filial de processamento                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 															   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DirFilial(cFile,cCgc,cInscEst,lJob) 
	Local oColab     := NIL
	Local aSM0       := FWLoadSM0()
	Local aFilInsc   := {}
	Local nX         := 1
	Local nY         := 1
	Local nQtdCNPJ	 := 0
	Local lRet       := .F.
	Local lChanFil	 := .F.
	Local lInscDup   := .F.
	Local nFilImp    := 0
	Local cGrpEmpImp := ""
	Local cCodFilImp := ""
	Local aFilEmp	 := {}
	
	oColab          := ColaboracaoDocumentos():New()
	oColab:cModelo	:= ""
	oColab:cTipoMov := '2'
	oColab:cFlag	:= '0'
	oColab:cQueue	:= SubStr(cFile,1,3)
	oColab:cNomeArq := cFile
	
	If oColab:Consultar()
		If AllTrim(oColab:cEmpProc) == AllTrim(cEmpAnt) .And. AllTrim(oColab:cFilProc) == AllTrim(cFilAnt)
			cGrpEmpImp := cEmpAnt
			cCodFilImp := cFilAnt
			lRet       := .T.
		ElseIf !Empty(oColab:cEmpProc) .And. !Empty(oColab:cFilProc)
			cGrpEmpImp        := oColab:cEmpProc
			cCodFilImp        := oColab:cFilProc
			oColab:cCodErrErp := "COM002"
			oColab:gravaErroErp()
		Endif
	Endif
	
	If !lRet .And. Empty(cGrpEmpImp)
		For nX := 1 To Len(aSm0)
			If cCGC $ aSm0[nX][SM0_CGC]
				nQtdCNPJ++
			EndIf
		Next nX
		
		If nQtdCNPJ == 1
			If (nFilImp := (ASCan(aSm0,{|x| x[SM0_CGC] == cCgc }))) > 0
				cGrpEmpImp := AllTrim(aSm0[nFilImp][SM0_GRPEMP])				
				cCodFilImp := AllTrim(aSm0[nFilImp][SM0_CODFIL])	
				If AllTrim(cGrpEmpImp) == AllTrim(cEmpAnt) .And. AllTrim(cCodFilImp) == AllTrim(cFilAnt)
					lRet:= .T.
				Else
					lRet := .F.
					lChanFil := .T.
				Endif
			Endif
		ElseIf nQtdCNPJ > 1
			If !Empty(AllTrim(cInscEst))
		  		//FORCA O CONTEUDO ISENTO
		  		If "ISENT" $ cInscEst
		   			cInscEst := "ISENTO"
		  		EndIf  
		 	Else
		  		cInscEst := "ISENTO" 
		 	EndIf
				
			aFilInsc := InscEstSM0(cCgc,cInscEst,@lInscDup)
			
			If !Empty(aFilInsc)
				cGrpEmpImp := aFilInsc[1]				
				cCodFilImp := aFilInsc[2]	
				If AllTrim(cGrpEmpImp) == AllTrim(cEmpAnt) .And. AllTrim(cCodFilImp) == AllTrim(cFilAnt)
					lRet:= .T.
				Else
					lRet := .F.
					lChanFil := .T. 
				Endif
			Endif
		Endif
		
		If !lRet .And. !lChanFil
			oColab          := ColaboracaoDocumentos():New()
			oColab:cModelo  := ""
			oColab:cTipoMov := '2'
			oColab:cFlag    := '0'
			oColab:cQueue   := SubStr(cFile,1,3)
			oColab:cNomeArq := cFile
		
			If oColab:Consultar()
				If AllTrim(oColab:cEmpProc) == AllTrim(cEmpAnt) .And. AllTrim(oColab:cFilProc) == AllTrim(cFilAnt)
					lRet := .T.
					cGrpEmpImp := cEmpAnt				
					cCodFilImp := cFilAnt
				ElseIf lInscDup
					If ExistBlock("COLFILDUP") 
						aFilEmp := ExecBlock("COLFILDUP",.F.,.F.,{cCgc,cInscEst})
						If ValType(aFilEmp) == "A" .And. Len(aFilEmp) == 2
							cGrpEmpImp := aFilEmp[1]				
							cCodFilImp := aFilEmp[2]
						Endif
					Endif
					
					If Empty(cGrpEmpImp) .And. Empty(cCodFilImp)
						oColab:cCodErrErp := "COM042"
						oColab:gravaErroErp()
					Else
						lRet := .T.
					Endif
				Else
					oColab:cCodErrErp := "COM002"
					oColab:gravaErroErp()
				Endif
			Endif
		Endif
	Endif
	
	ColGrvFil(cFile,"0",cGrpEmpImp,cCodFilImp,cCgc)
	oColab := Nil
Return {lRet,lChanFil,lInscDup}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImportColºAutor  ³ Andre Anjos		 º Data ³  08/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que realiza a importacao de um arquivo XML do TOTVS º±±
±±º          ³ colaboracao.                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cFile: caminho do arquivo que esta sendo importado.		  º±±
±±º			 ³ lJob: indica se o processamento esta sendo fendo em job.	  º±±
±±º			 ³ aProc: array para guardar os arquivos processados (M-Mess).º±±
±±º			 ³ aErros: array para guardar os arquivos com erros (M-Mess). º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet: indica se a importacao foi realizada.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SchedComCol                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ImportCol(cFile,lJob,aProc,aErros,cXMLOri,aErroERP)
Local lRet 	   := .F.
Local cError   := ""
Local cWarning := ""
Local oFullXml := NIL
Local cXMLEncod:= ""
Local nHandle  := 0
Local nLength  := 0
Local nNFeAut  := SuperGetMV("MV_COMCOL1",.F.,0)
Local lIntGfe  := SuperGetMV("MV_INTGFE",.F.,.F.)
Local lCteClas := SuperGetMV("MV_CTECLAS",.F.,.F.)
Local lCte     := .F.

If Type("LTOMA4NFORI") <> "L"
	LTOMA4NFORI := .T.
Endif
If !Empty(cXMLOri)
	If SubStr(cXMLOri,1,1) != "<"
		nPosPesq := At("<",cXMLOri)
		cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
	EndIf
EndIf

cXMLEncod := EncodeUtf8(cXMLOri)

If Empty(cXMLEncod)
	cXMLEncod 	:= cXMLOri
	cXMLOri 	:= A140IRemASC(cXMLEncod)
	cXMLEncod 	:= EncodeUtf8(cXMLOri)
EndIf

If !Empty(cXMLEncod)
	oFullXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
EndIf
If !Empty(cError) //-- Erro na sintaxe do XML
	If lJob
		aAdd(aErros,{cFile,"COM001 - " + STR0073 +cError,STR0074}) //-- Erro de sintaxe no arquivo XML: # Entre em contato com o emissor do documento e comunique a ocorrência.
	Else
		Aviso(STR0070,cError,{"OK"},2,"COMXCOMImp") //-- Erro
	EndIf
	aAdd(aErroErp,{cFile,"COM001"})
	lRet := .F.
Else //-- Direciona processamento conforme tipo de documento
	If ValType(oFullXML)=="O"
		Do Case
			Case ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
				lRet := ImpXML_NFe(cFile,lJob,@aProc,@aErros,.F.,oFullXml:_NFeProc:_NFe,,cXmlOri,@aErroErp)
			Case ValType(XmlChildEx(oFullXML,"_CTE")) == "O" //-- Nota de transporte
				lCte := .T.
				//Verifica se há integração com o Frete Embarcador
				If lIntGfe
					lRet := GFEA118XML(cFile,@aProc,@aErros,oFullXml:_CTe,,oFullXML:_CTeProc:_ProtCte)
				Else
					lRet := ImpXML_CTe(cFile,lJob,@aProc,@aErros,oFullXml:_CTe,@aErroERP,oFullXML:_CTeProc:_ProtCte)
				EndIf		
			Case ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" //-- Nota de transporte
			    lCte := .T.
			    //Verifica se há integração com o Frete Embarcador
				If lIntGfe
					lRet := GFEA118XML(cFile,@aProc,@aErros,oFullXml:_CTeProc:_Cte,,oFullXML:_CTeProc:_ProtCte)
				Else
					lRet := ImpXML_CTe(cFile,lJob,@aProc,@aErros,oFullXml:_CTeProc:_Cte,@aErroErp,oFullXML:_CTeProc:_ProtCte)
				EndIf
			Case FindFunction("ImpXML_Ave") .And. ValType(XmlChildEx(oFullXML,"_INVOIC_NFE_COMPL")) == "O" //-- Nota Fiscal Complementar
				lRet := ImpXML_Ave(cFile,lJob,@aProc,@aErros,oFullXml:_INVOIC_NFE_COMPL,cXMLOri,@aErroErp)
			Case ValType(XmlChildEx(oFullXML,"_TOTVSMESSAGE")) == "O" .And. ValType(XmlChildEx(oFullXML:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT,"_PROCNEOGRIDNFSE")) == "O" // Nota de Servico
				lRet := ImpXML_NFs(cFile,lJob,@aProc,@aErros,oFullXml:_TOTVSMESSAGE:_BUSINESSMESSAGE:_BUSINESSCONTENT,@aErroErp)
			Case ValType(XmlChildEx(oFullXML,"_PROCNEOGRIDNFSE")) == "O" // Nota de Servico
				lRet := ImpXML_NFs(cFile,lJob,@aProc,@aErros,oFullXml,@aErroErp)
			Otherwise
				aAdd(aErros,{cFile,STR0169,""}) //"XML não está de acordo com nenhum tipo de documento"
				lRet:= .F.
		EndCase
	EndIf
	If lRet .And. (nNFeAut == 1 .Or. nNFeAut == 2 .Or. (nNFeAut == 0 .And. Iif(lCte,lCteClas,.F.))) .And. Iif( lCte, !lIntGfe, .T. )
		ProcDocs(SDS->(Recno()),.T.,,lJob)      	
	EndIf
EndIf

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ComXTudoOk ³ Autor ³ TOTVS                ³ Data ³18.09.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao TudOk                                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: .T. -> Linha valida                                   ³±±
±±³          ³       .F. -> Linha invalida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao das        ³±±
±±³          ³linhas da getdados para a rotina de atualizacao do registro  ³±±
±±³          ³importado pelo TOTVS Colaboração                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ComXTudoOk()

Local nPosNfOri	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_NFORI"})
Local nPosSerOri:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_SERIORI"})
Local nPosItOri	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ITEMORI"})
Local nPosCod	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_COD"})
Local nPosQtd	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_QUANT"})
Local nPosVUni	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_VUNIT"})
Local nPosItem	:= aScan(oGetDados:aHeader,{|x| AllTrim(x[2])=="DT_ITEM"})
Local aAreaSF2	:= SF2->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaSD1	:= SD1->(GetArea())
Local lRet		:= .T.
Local nX		:= 0
Local nCont		:= 0
Local cFilSD2	:= xFilial("SD2")
Local cFilSF2	:= xFilial("SF2")

If SDS->DS_TIPO == "D"		// Nota de Devolução
	For nX := 1 To Len(oGetDados:aCols)
		If !Empty(AllTrim(oGetDados:aCols[nX][nPosNfOri]))
			If Empty(AllTrim(oGetDados:aCols[nX][nPosItOri]))
				Aviso(STR0004,STR0063+oGetDados:aCols[nX][nPosItem]+STR0078,{STR0077})
				lRet := .F.
				nCont++
				Exit
			Else
				DbSelectArea("SF2")
				DbSetOrder(1)
				MsSeek(cFilSF2+oGetDados:aCols[nX][nPosNfOri]+oGetDados:aCols[nX][nPosSerOri] )
	
				dbSelectArea("SD2")
				dbSetOrder(3)
				If MsSeek(cFilSD2+oGetDados:aCols[nX][nPosNfOri]+oGetDados:aCols[nX][nPosSerOri]+SF2->F2_CLIENTE+SF2->F2_LOJA+oGetDados:aCols[nX][nPosCod]+oGetDados:aCols[nX][nPosItOri])
					If SD2->D2_QUANT < oGetDados:aCols[nX][nPosQtd]
						Aviso(STR0004,STR0063+oGetDados:aCols[nX][nPosItem]+STR0079,{STR0077})
						lRet := .F.
						nCont++
						Exit
					EndIf
				Else
					Aviso(STR0004,STR0063+oGetDados:aCols[nX][nPosItem]+STR0078,{STR0077})
					lRet := .F.
					nCont++
					Exit
				EndIf
			EndIf
		nCont++
		ElseIf !Empty(AllTrim(oGetDados:aCols[nX][nPosSerOri])) .Or. !Empty(AllTrim(oGetDados:aCols[nX][nPosItOri]))
			Aviso(STR0004,STR0063+oGetDados:aCols[nX][nPosItem]+STR0078,{STR0077})
		EndIf
	Next nX
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF1)
RestArea(aAreaSD2)
RestArea(aAreaSF2)

Return(lRet)

/*/ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VincMultPC ³ Autor ³ TOTVS                ³ Data ³12.05.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de avaliacao TudOk                                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: .T. -> Linha valida                                   ³±±
±±³          ³       .F. -> Linha invalida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a validacao das        ³±±
±±³          ³linhas da getdados para a rotina de atualizacao do registro  ³±±
±±³          ³importado pelo TOTVS Colaboração                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VincMultPC(aPedidos,nSldPed,aColsBkp,cItem,nMultPC,lLastIt,nPosicao,lNewLine)

Local aAreaSDS	:= SDS->(GetArea())
Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_COD"})
Local nPosProdF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_PRODFOR"})
Local nPosDescF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_DESCFOR"})
Local nPosSerie	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_SERIE"})
Local nPosValor	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_VUNIT"})
Local nPosFrete	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_VALFRE"})
Local nPosSegur	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_SEGURO"})
Local nPosDesp	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_DESPESA"})
Local nPosDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_VALDESC"})
Local nPosTot	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_TOTAL"})
Local nPosFCI	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_FCICOD"})
Local nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) == "DT_ITEM"})
Local nTamItem	:= TamSx3("DT_ITEM")[1]
Local nFrete	:= 0
Local nSeguro	:= 0
Local nDespesa	:= 0
Local nDesconto	:= 0
Local nValTotal	:= 0
Local nTotalNf	:= 0
Local nD		:= 0
Local nE		:= 0
Local n			:= oGetDados:nAt
Local nPrdDup	:= 0

Default lLastIt  := .F.
Default nPosicao := 1
Default lNewLine := .T.

//Posiciona corretamente a variavel N de
//acordo com os dados do array aColsBkp.
If lLastIt
	If ValType(nMultPc)=='N' .And. nMultPc==2
		n:= nPosicao
	Elseif ValType(nMultPc)=='N' .And. nMultPc==1
		n := Iif(nMultPc==1,n,Iif(nMultPc==2 .And. n <> Val(cItem),Val(cItem),n))
		
		n := aScan(aColsBkp,{|x| AllTrim(x[nPosCod]) == AllTrim(SC7->C7_PRODUTO) .And. AllTrim(x[nPosItem]) == StrZero(n,nTamItem)})
	EndIf
Else
	For nD := 1 To Len(aColsBkp)
		If AllTrim(aColsBkp[nD,nPosCod]) == AllTrim(SC7->C7_PRODUTO)
			nPrdDup++
		EndIf
	Next nD
	
	If nPrdDup > 1
		n := Iif(nMultPc==1,n,Iif(nMultPc==2 .And. n <> Val(cItem),Val(cItem),n))
		n := aScan(aColsBkp,{|x| AllTrim(x[nPosCod]) == AllTrim(SC7->C7_PRODUTO) .And. AllTrim(x[nPosItem]) == StrZero(n,nTamItem)})
	Else
		n := aScan(aColsBkp,{|x| AllTrim(x[nPosCod]) == AllTrim(SC7->C7_PRODUTO)})
	Endif
EndIf

//Protecao para variavel N
If n <= 0 
   n := oGetDados:nAt
Endif

If lNewLine
	//Cria aCols recebendo a quantidade dos pedidos
	aadd(aCols,Array(Len(aHeader)+1))
	For nD := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nD][2])
		    aCols[Len(aCols)][nD] := 0
		ElseIf IsHeadAlias(aHeader[nD][2])
		    aCols[Len(aCols)][nD] := "SDT"
		ElseIf Trim(aHeader[nD][2]) == "DT_ITEM"
			aCols[Len(aCols)][nD] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(SDT->DT_ITEM)))
		Else
			aCols[Len(aCols)][nD] := CriaVar(aHeader[nD][2], (aHeader[nD][10] <> "V") )
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nD
	
	nItem := Len(aCols)
Else
	nItem := nPosicao
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apura valor das despesas acessorias para ratear entre os itens   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nMultPC == 1		// Vinculo por item, retorna o valor somente do item
	nFrete		:= aColsBkp[N][nPosFrete]
	nSeguro		:= aColsBkp[N][nPosSegur]
	nDespesa	:= aColsBkp[N][nPosDesp]
	nDesconto	:= aColsBkp[N][nPosDesc]
	nTotalNf	:= aColsBkp[N][nPosTot]
ElseIf nMultPC == 2	// Vinculo por documento, retorna o valor total
	For nD := 1 To Len(aColsBkp)
		nFrete		+= aColsBkp[nD][nPosFrete]
		nSeguro	+= aColsBkp[nD][nPosSegur]
		nDespesa	+= aColsBkp[nD][nPosDesp]
		nDesconto	+= aColsBkp[nD][nPosDesc]
	Next nD
	nTotalNf  := SDS->DS_VALMERC
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calculo do valor total							             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTotal := NoRound((aColsBkp[N][nPosValor]*nSldPed),TamSX3("DT_TOTAL")[2])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o acols com base no pedido de compras               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nE := 1 To Len(aHeader)
	Do Case
	Case Trim(aHeader[nE,2]) == "DT_COD"
		aCols[nItem,nE] := If(lLastIt,aColsBkp[n][nPosCod],SC7->C7_PRODUTO)
	Case Trim(aHeader[nE,2]) == "DT_DESC"
		aCols[nItem,nE] := If(lLastIt,Posicione("SB1",1,xFilial("SB1")+aColsBkp[n][nPosCod],"B1_DESC"),SC7->C7_DESCRI)
	Case Trim(aHeader[nE,2]) == "DT_PRODFOR"
		aCols[nItem,nE] := aColsBkp[n][nPosProdF]
	Case Trim(aHeader[nE,2]) == "DT_DESCFOR"
		aCols[nItem,nE] := aColsBkp[n][nPosDescF]
	Case Trim(aHeader[nE,2]) == "DT_SERIE"
		aCols[nItem,nE] := aColsBkp[n][nPosSerie]
	Case Trim(aHeader[nE,2]) == "DT_QUANT"
		aCols[nItem,nE] := nSldPed
	Case Trim(aHeader[nE,2]) == "DT_VUNIT"
		aCols[nItem,nE] := aColsBkp[n][nPosValor]
	Case Trim(aHeader[nE,2]) == "DT_TOTAL"
		aCols[nItem,nE] := nValTotal
	Case Trim(aHeader[nE,2]) == "DT_PEDIDO"
		aCols[nItem,nE] := If(lLastIt,CriaVar("DT_PEDIDO",.F.),SC7->C7_NUM)
	Case Trim(aHeader[nE,2]) == "DT_ITEMPC"
		aCols[nItem,nE] := If(lLastIt,CriaVar("DT_ITEMPC",.F.),SC7->C7_ITEM)
	Case Trim(aHeader[nE,2]) == "DT_VALFRE"
		aCols[nItem,nE] := (nFrete / nTotalNf) * nValTotal
	Case Trim(aHeader[nE,2]) == "DT_SEGURO"
		aCols[nItem,nE] := (nSeguro / nTotalNf) * nValTotal
	Case Trim(aHeader[nE,2]) == "DT_DESPESA"
		aCols[nItem,nE] := (nDespesa / nTotalNf) * nValTotal
	Case Trim(aHeader[nE,2]) == "DT_VALDESC"
		aCols[nItem,nE] := (nDesconto / nTotalNf) * nValTotal
	Case Trim(aHeader[nE,2]) == "DT_FCICOD"
		aCols[nItem,nE] := aColsBkp[n][nPosFCI]
	EndCase
Next nE

oGetDados:aCols := aCols
oGetDados:oBrowse:Refresh()

//Restaura posição Variavel N
n := oGetDados:nAt

RestArea(aAreaSDS)

Return 

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ComXGetAnt³ Autor ³ TOTVS                 ³ Data ³18.09.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo retornare a GetDados ao        ³±±
±±³          ³seu estado anterior ao clicar no botão cancelar no vínculo   ³±±
±±³          ³de documentos                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ComXGetAnt(aColsAnt)

If SDS->DS_TIPO == "D"		// Nota de Devolução
	aCols := aClone(aColsAnt)
EndIf

Return

/*/ 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ComXItOri ³ Autor ³ TOTVS                 ³ Data ³01.04.2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo retornar os itens originais    ³±±
±±³          ³do documento                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ComXItOri(aColsAnt)

Local cQuery := ""
Local cAliasTmp	:= "SDTTMP"
Local aStruSDT := {}
Local aColsOri := {}
Local nX := 0
Local nY := 0
Local nItem := 0

If Len(aHeader) == 0
	aHeader := GetaHeader("SDT",,aNoFields,,,)
Endif

	// Pesquisa pelos itens originais que estejam deletados e marcados com o campo DT_ORIGEM, 
	//  pois podem ter sido substituidos na confirmacao do vinculo por multiplos pedidos
	// Caso a operacao de vinculo por multiplos pedidos nao tenha sido concluida e nao encontre registros deletados,
	//  retorna o aColsAnt
	For nX := 1 To Len(aHeader)
		If SDT->(FieldPos(aHeader[nX,2])) > 0
			If Empty(cQuery)
				cQuery := " SELECT DISTINCT " + AllTrim(aHeader[nX,2])
			Else
				cQuery += " , " + AllTrim(aHeader[nX,2])
			Endif
		Endif
	Next nX
	cQuery += " FROM " +RetSqlName("SDT") +" SDT"
	cQuery += " WHERE DT_FILIAL = '" +xFilial("SDT") + "' "
	cQuery += " AND DT_FORNEC = '" +SDS->DS_FORNEC + "' AND DT_LOJA = '" +SDS->DS_LOJA + "'" 
	cQuery += " AND DT_DOC = '" +SDS->DS_DOC + "' AND DT_SERIE = '" +SDS->DS_SERIE + "'" 
	cQuery += " AND DT_ORIGIN = '1' AND D_E_L_E_T_ = '*' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTmp,.T.,.T.)
	
	// Se nao encontrou itens originais como deletados, retorna array aColsAnt
	(cAliasTmp)->(dbGoTop())	
	If (cAliasTmp)->(Eof())
		
		FOR nX := 1 TO Len(aColsAnt)
			IF !Empty(aColsAnt[nX][GDFieldPos("DT_PEDIDO")])
				(cAliasTmp)->(dbCloseArea())
				RETURN .T.
			ENDIF
		NEXT nX
	    
		aCols := aColsAnt
		oGetDados:aCols := aCols
	Else
		While (cAliasTmp)->(!Eof())
			IF !Empty((cAliasTmp)->DT_PEDIDO)
				(cAliasTmp)->(dbCloseArea())
				RETURN .T.
			ENDIF
			// Cria aColsOri para receber os itens originais
			aadd(aColsOri,Array(Len(aHeader)+1))
			For nX := 1 to Len(aHeader)
				If IsHeadRec(aHeader[nX][2])
				    aColsOri[Len(aColsOri)][nX] := 0
				ElseIf IsHeadAlias(aHeader[nX][2])
				    aColsOri[Len(aColsOri)][nX] := "SDT"
				Else
					aColsOri[Len(aColsOri)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
				EndIf
				aColsOri[Len(aColsOri)][Len(aHeader)+1] := .F.
			Next nX
			nItem := Len(aColsOri)

			// Atualiza aColsOri de acordo com os itens originais retornados
			For nX := 1 To Len(aHeader)
				If IsHeadRec(aHeader[nX][2])
				    aColsOri[nItem][nX] := 0
				ElseIf IsHeadAlias(aHeader[nX][2])
				    aColsOri[nItem][nX] := "SDT"
				Else
					If SDT->(FieldPos(aHeader[nX,2])) > 0
						aColsOri[nItem][nX] := &((cAliasTmp)+"->"+aHeader[nX][2])
					Endif
				EndIf
				aCols[nItem][Len(aHeader)+1] := .F.
			Next nX
			(cAliasTmp)->(dbSkip())
		EndDo
		If Len(aColsOri) > 0
			aCols := aColsOri
			oGetDados:aCols := aColsOri
		EndIf
	EndIf
	(cAliasTmp)->(dbCloseArea())

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvASC()
Função para conversão de caracteres com acento.
@author jose.delmondes	
@since 14/07/2014
@version P11.8
@return cStrXML - Xml com caracteres substituidos
/*/
//-------------------------------------------------------------------
Function ConvASC(cStrXML)

cStrXML := StrTran(cStrXML, CHR(199), CHR(67)) 	//Substitui Ç por C
cStrXML := StrTran(cStrXML, CHR(231), CHR(99))	//Substitui ç por c
cStrXML := StrTran(cStrXML, CHR(195), CHR(65))	//Substitui Ã por A
cStrXML := StrTran(cStrXML, CHR(192), CHR(65))	//Substitui À por A
cStrXML := StrTran(cStrXML, CHR(193), CHR(65))	//Substitui Á por A
cStrXML := StrTran(cStrXML, CHR(227), CHR(97))	//Substitui ã por a
cStrXML := StrTran(cStrXML, CHR(225), CHR(97))	//Substitui á por a
cStrXML := StrTran(cStrXML, CHR(224), CHR(97))  	//Substitui à por a 
cStrXML := StrTran(cStrXML, CHR(201), CHR(69))	//Substitui É por E
cStrXML := StrTran(cStrXML, CHR(233), CHR(101))	//Substitui é por e
cStrXML := StrTran(cStrXML, CHR(205), CHR(73))	//Substitui Í por Í
cStrXML := StrTran(cStrXML, CHR(237), CHR(105))	//Substitui í por í
cStrXML := StrTran(cStrXML, CHR(211), CHR(79))	//Substitui Ó por O
cStrXML := StrTran(cStrXML, CHR(213), CHR(79))	//Substitui Õ por O
cStrXML := StrTran(cStrXML, CHR(245), CHR(111))	//Substitui õ por o
cStrXML := StrTran(cStrXML, CHR(243), CHR(111))	//Substitui ó por o
cStrXML := StrTran(cStrXML, CHR(218), CHR(85))	//Substitui Ú por U
cStrXML := StrTran(cStrXML, CHR(250), CHR(117))	//Substitui ú por u

Return cStrXML

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  | COMXCOLNEO ³Autor ³ Flavio Lopes Rasta		   |Data ³ 08/08/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que estabelece comunicacao com o Client NeoGrid para      ³±±
±±³Descri‡ao ³ realizar a baixa ou remessa de arquivo.							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±    
±±³Parametros³ lExp01: 							   								³±±
±±³			 ³ cExp02: 															³±±
±±³			 ³ cExp03: 															³±±		
±±³			 ³ nExp04:  														³±±
±±³			 ³ cExp05: 															³±±
±±³			 ³ cExp06:															³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±    
±±³Retorno   ³ lOk: indica se a comunicacao foi efetuada.                       ³±±    
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±       
±±³ Uso      ³ Totvs Colaboracao												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±       
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function COMXCOLNEO(cNumDoc,cXML,cIDErp,cQueue)
Local lOk		:= .T.
Local oColab	:= Nil

If !Empty(cXml)  
	oColab := ColaboracaoDocumentos():New()
	
	oColab:cModelo 		:= "EDI"	// Fixo para DI de Compras		
	oColab:cNumero		:= cNumDoc	// Numero do Documento
	oColab:cIdErp 		:= cIdErp	// ID Erp		
	oColab:cXml			:= cXml		// XML
	oColab:cTipoMov		:= '1'		// Tipo de Movimento 1-Saida / 2-Recebimento 
	oColab:cQueue		:= cQueue		// Codigo Queue (170 - Emissão de NF-e)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metodo Consultar                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	//lOk := oTemp:consultar()

	If lOk 											
		If oColab:cCdStatDoc <> "1" 		// 1 - 'Enviado'								
			lOk := oColab:transmitir()
		Else		
			lOk := .F.
			cErro := STR0180+CRLF+CRLF 	//"As notas abaixo foram recusadas, verifique a rotina 'Monitor' para saber os motivos."
		EndIf				
	Else									//Nao tem registro na base, novo registro.								
		lOk := oColab:transmitir()										
	EndIf
EndIf 

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc}InscEstSM0
Valida filial pela inscrição estadual

@author Flavio Lopes Rasta	
@since 24/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function InscEstSM0(cCgc,cInscEst,lInscDup)

	Local aRetEmp	:= {}
	Local aAreaSM0	:= SM0->(GetArea())
	Local nQtdINSC	:= 0
	Default lInscDup := .F.
	
	DbSelectArea('SM0')
	SM0->(DbGoTop())
	While !SM0->(Eof())
		If SM0->M0_CGC == cCgc .And. A140INSC(cInscEst,SM0->M0_INSC)
			aAdd(aRetEmp,SM0->M0_CODIGO)
			aAdd(aRetEmp,SM0->M0_CODFIL)
			nQtdINSC++
		EndIf
		SM0->(DbSkip())
	EndDo
	
	// Caso tenha mais de um registro com mesmo CNPJ e Insc.Estadual nao sera possivel determinar a filial de importacao
	If nQtdINSC > 1
		aRetEmp  := {}
		lInscDup := .T.
	EndIf
	
	RestArea(aAreaSM0)
Return aRetEmp

//-------------------------------------------------------------------
/*/{Protheus.doc}ColCalcImp
Grava os valores dos impostos calculados pela TES

@author Flavio Lopes Rasta	
@since 30/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function ColCalcImp()

Local aAreaSDS  := SDS->(GetArea())
Local aAreaSDT  := SDT->(GetArea())
Local aCabec    := MontaSF1()
Local aItens    := MontaSD1()
Local cCondPg   := ""
Local nPosFor   := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_FORNECE"})
Local nPosLoj   := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_LOJA"})
Local nPosTpNF  := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TIPO"})
Local nPosCPg   := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_COND"})
Local nPosPed   := aScan(aItens[1],{|x| AllTrim(x[1]) == "D1_PEDIDO"})
Local nSaveSX8  := GetSX8Len()
Local nTesAnt   := 0
Local nX        := 1
Local nPosTES   := 0
Local nPosItCur := 0
Local nPosIPI   := 0
Local nPosICMS  := 0
Local nPosISS   := 0    
Local nPosPIS   := 0
Local nPosCOFI  := 0
Local nPosICST  := 0
Local nPosAIPI  := 0
Local nPosAICMS := 0
Local nPosAISS  := 0
Local nPosAPIS  := 0
Local nPosACOFI := 0
Local nPosAICST := 0
Local lGerDupl  := .F.
Local lRet      := .T.

Private aImpVal := {}

// Verifica se todos os itens possuem TES e se existe ao menos uma TES que gera duplicata
SF4->(dbSetOrder(1))
//-- Verifica se existe ao menos uma TES que gera duplicata
For nX := 1 To Len(aItens)
	If (nTesAnt := aScan(aItens[nX],{|x| AllTrim(x[1]) == "D1_TES"})) > 0
		If !Empty(aItens[nX][nTesAnt][2])
			If SF4->(dbSeek(xFilial("SF4")+aItens[nX][nTesAnt][2])) .And. SF4->F4_DUPLIC == "S"
				lGerDupl := .T.
			EndIf
		Else
			lRet := .F.
			Exit
		EndIf
	Else
		lRet := .F.
		Exit
	EndIf
Next nX

//-- Adiciona condicao de pagamento ao cabecalho
If lRet .And. lGerDupl
	If nPosPed > 0
		SC7->(DbSetOrder(14))
		SC7->(DbSeek(xFilial("SC7")+aItens[1][nPosPed][2]))
		If !Empty(SC7->C7_COND)
			cCondPg := SC7->C7_COND
		EndIf
	EndIf
	If Empty(cCondPg)
		If aCabec[nPosTpNF,2] == "B"	// Beneficiamento - Busca condicao de pagamento do cliente
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
				cCondPg := SA1->A1_COND
			EndIf
		ElseIf aCabec[nPosTpNF,2] != "D"	// Busca condicao de pagamento do fornecedor (Devolucao nao tem condicao de pagamento)
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
				cCondPg := SA2->A2_COND
			EndIf
		EndIf
	EndIf

	If ExistBlock("A140ICOND")
		cCondPg := ExecBlock("A140ICOND",.F.,.F.,{aCabec[1][nPosFor],aCabec[1][nPosLoj],cCondPg})
		If ValType(cCondPg) # "C" .Or. !SE4->(dbSeek(xFilial("SE4")+cCondPg))
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If !Empty(cCondPg) .And. nPosCPg > 0
			aCabec[nPosCPg][2] := cCondPg
		ElseIf !Empty(cCondPg)
			aAdd(aCabec,{"F1_COND",cCondPg, NIL})
		ElseIf nPosTpNF > 0 .And. aCabec[nPosTpNF,2] != "D"
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet
	//-- Executa rotina automatica sem gravar, apenas para obter os impostos
	lMsErroAuto    := .F.
	lAutoErrNoFile := .T.
	MSExecAuto({|x,y,z,k| MATA103(x,y,z,,,,,,k)},aCabec,aItens,3,.F.)

	If !lMsErroAuto
		If Len(aImpVal) > 0 
			nPosTES	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_TES"})
			nPosIPI	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_VALIPI"})
			nPosICMS	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_VALICM"})
			nPosISS	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_VALISS"})
			nPosPIS	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_VALIMP6"})
			nPosCOFI	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_VALIMP5"})
			nPosICST	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_ICMSRET"})
			nPosAIPI	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_IPI"})
			nPosAICMS	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_PICM"})
			nPosAISS	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_ALIQISS"})
			nPosAPIS	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_ALQIMP6"})
			nPosACOFI	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_ALQIMP5"})
			nPosAICST	:= aScan(aImpVal[1][2],{|x| x[2] == "D1_ALIQSOL"})

			RestArea(aAreaSDS)
			RestArea(aAreaSDT)
			SDT->(DbSetOrder(1))
			SDT->(DbSeek(xFilial("SDT")+SDS->(DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)))
			While !SDT->(Eof()) .And. SDT->(xFilial("SDT")+DT_CNPJ+DT_FORNEC+DT_LOJA+DT_DOC+DT_SERIE) ==;
									   SDS->(xFilial("SDS")+DS_CNPJ+DS_FORNEC+DS_LOJA+DS_DOC+DS_SERIE)
	
				If (nPosItCur := aScan(aImpVal,{|x| x[1] == AllTrim(SDT->DT_ITEM)})) > 0
					RecLock("SDT",.F.)
					SDT->DT_TES		:= IIF(nPosTES > 0,aImpVal[nPosItCur][2][nPosTES][3],Space(Len(SDT->DT_TES)))
					SDT->DT_TESIPI	:= IIF(nPosIPI > 0,aImpVal[nPosItCur][2][nPosIPI][3],0)
					SDT->DT_TESICM	:= IIF(nPosICMS > 0,aImpVal[nPosItCur][2][nPosICMS][3],0)
					SDT->DT_TESISS	:= IIF(nPosISS > 0,aImpVal[nPosItCur][2][nPosISS][3],0)
					SDT->DT_TESPIS	:= IIF(nPosPIS > 0,aImpVal[nPosItCur][2][nPosPIS][3],0)
					SDT->DT_TESCOF	:= IIF(nPosCOFI > 0,aImpVal[nPosItCur][2][nPosCOFI][3],0)
					SDT->DT_TESICST	:= IIF(nPosICST > 0,aImpVal[nPosItCur][2][nPosICST][3],0)
					SDT->DT_ALIQIPI	:= IIF(nPosAIPI > 0,aImpVal[nPosItCur][2][nPosAIPI][3],0)
					SDT->DT_ALIQICM	:= IIF(nPosAICMS > 0,aImpVal[nPosItCur][2][nPosAICMS][3],0)
					SDT->DT_ALIQISS	:= IIF(nPosAISS > 0,aImpVal[nPosItCur][2][nPosAISS][3],0)
					SDT->DT_ALIQPIS	:= IIF(nPosAPIS > 0,aImpVal[nPosItCur][2][nPosAPIS][3],0)
					SDT->DT_ALIQCOF	:= IIF(nPosACOFI > 0,aImpVal[nPosItCur][2][nPosACOFI][3],0)
					SDT->DT_ALIICST	:= IIF(nPosAICST > 0,aImpVal[nPosItCur][2][nPosAICST][3],0)	
					MsUnlock()
				EndIf
	
				SDT->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf
RollBackSX8()

RestArea(aAreaSDS)
RestArea(aAreaSDT)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}ColAtuImp
Valid do campo DT_TES. 
Atualiza impostos de acordo com a TES

@author Flavio Lopes Rasta	
@since 30/03/2015
@version P12
/*/
//-------------------------------------------------------------------

Function ColAtuImp(cTes,nLine)

Local aAreaSDS   := SDS->(GetArea())
Local aAreaSDT   := SDT->(GetArea())
Local aCabec     := MontaSF1()
Local aItem      := {}
Local cCondPg    := ""
Local nPosFor    := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_FORNECE"})
Local nPosLoj    := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_LOJA"})
Local nPosTpNF   := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_TIPO"})
Local nPosCPg    := aScan(aCabec,{|x| AllTrim(x[1]) == "F1_COND"})
Local nPosAnt    := oGetDados:nAt
Local nSaveSX8   := GetSX8Len()
Local lGerDupl   := .F.
Local lRet       := .T.
Local lDevSemOri := .F.

Default cTes     := ""
Default nLine    := 0

Private aImpVal  := {}

If Empty(cTes)
	cTes := M->DT_TES
EndIf

If nLine > 0
	n := nLine
EndIf

aAdd(aItem,{})
aAdd(aTail(aItem),{"D1_ITEM",   aCols[1][GdFieldPos("DT_ITEM")], 	 NIL})
aAdd(aTail(aItem),{"D1_COD",    aCols[n][GdFieldPos("DT_COD")],	 NIL})
aAdd(aTail(aItem),{"D1_QUANT",  aCols[n][GdFieldPos("DT_QUANT")], 	 NIL})
aAdd(aTail(aItem),{"D1_VUNIT",  aCols[n][GdFieldPos("DT_VUNIT")], 	 NIL})
If SDS->DS_TIPO $ "CT"
	aAdd(aTail(aItem),{"D1_TOTAL",aCols[n][GdFieldPos("DT_VUNIT")],NIL})
Else
	aAdd(aTail(aItem),{"D1_TOTAL",Round(aCols[n][GdFieldPos("DT_VUNIT")] * aCols[n][GdFieldPos("DT_QUANT")],TamSX3("D1_TOTAL")[2]),NIL})
EndIf
aAdd(aTail(aItem),{"D1_VALFRE",	aCols[n][GdFieldPos("DT_VALFRE")],	 NIL})
aAdd(aTail(aItem),{"D1_SEGURO",	aCols[n][GdFieldPos("DT_SEGURO")],	 NIL})
aAdd(aTail(aItem),{"D1_DESPESA",	aCols[n][GdFieldPos("DT_DESPESA")], NIL})
aAdd(aTail(aItem),{"D1_VALDESC", aCols[n][GdFieldPos("DT_VALDESC")], NIL})
aAdd(aTail(aItem),{"D1_TES", cTes,  NIL})

//-- Adiciona condicao de pagamento ao cabecalho
SF4->(dbSetOrder(1))
If SF4->(dbSeek(xFilial("SF4")+cTes)) .And. SF4->F4_DUPLIC == "S"
	lGerDupl := .T.
EndIf

If lGerDupl
	If nPosTpNF > 0
		If aCabec[nPosTpNF,2] == "N" .And. !Empty(aCols[n][GdFieldPos("DT_PEDIDO")]) .And. !Empty(aCols[n][GdFieldPos("DT_ITEMPC")])	// Normal com pedido preenchido - Busca condicao de pagamento do pedido
			SC7->(DbSetOrder(14))
			If SC7->(DbSeek(xFilial("SC7")+aCols[n][GdFieldPos("DT_PEDIDO")]+aCols[n][GdFieldPos("DT_ITEMPC")]))
				cCondPg := SC7->C7_COND
			EndIf
		ElseIf aCabec[nPosTpNF,2] == "B"	// Beneficiamento - Busca condicao de pagamento do cliente
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
				cCondPg := SA1->A1_COND
			EndIf
		ElseIf aCabec[nPosTpNF,2] != "D"	// Busca condicao de pagamento do fornecedor (Devolucao nao tem condicao de pagamento)
			SA2->(dbSetOrder(1))
			If SA2->(dbSeek(xFilial("SA2")+aCabec[nPosFor,2]+aCabec[nPosLoj,2]))
				cCondPg := SA2->A2_COND
			EndIf
		EndIf
	EndIf

	If ExistBlock("A140ICOND")
		cCondPg := ExecBlock("A140ICOND",.F.,.F.,{aCabec[1][nPosFor],aCabec[1][nPosLoj],cCondPg})
		If ValType(cCondPg) # "C" .Or. !SE4->(dbSeek(xFilial("SE4")+cCondPg))
			lRet := .F.
		EndIf
	EndIf

	If lRet   
		If !Empty(cCondPg) .And. nPosCPg > 0
			aCabec[nPosCPg][2] := cCondPg
		ElseIf !Empty(cCondPg)
			aAdd(aCabec,{"F1_COND",cCondPg, NIL})
		ElseIf nPosTpNF > 0 .And. aCabec[nPosTpNF,2] != "D"
			lRet := .F.
		EndIf
	EndIf
EndIf

If lRet
	lMsErroAuto    := .F.
	lAutoErrNoFile := .T.
	MSExecAuto({|x,y,z,k| MATA103(x,y,z,,,,,,k)},aCabec,aItem,3,.F.)

	If !lMsErroAuto
		If nLine > 0
			n := nLine
		EndIf
		If Len(aImpVal) > 0
			oGetDados:aCols[n][GdFieldPos("DT_TESIPI")] 	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2] == "D1_VALIPI"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_TESICM")]  	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2] == "D1_VALICM"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_TESISS")]  	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2] == "D1_VALISS"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_TESPIS")]  	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2] == "D1_VALIMP6"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_TESCOF")]  	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2] == "D1_VALIMP5"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_TESICST")]	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2] == "D1_ICMSRET"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_ALIQIPI")] 	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2]=="D1_IPI"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_ALIQICM")] 	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2]=="D1_PICM"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_ALIQISS")] 	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2]=="D1_ALIQISS"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_ALIQPIS")] 	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2]=="D1_ALQIMP6"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_ALIQCOF")] 	:= aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2]=="D1_ALQIMP5"})][3]
			oGetDados:aCols[n][GdFieldPos("DT_ALIICST")]	:= IIf((oGetDados:aCols[n][GdFieldPos("DT_TESICST")]) > 0,aImpVal[1][2][aScan(aImpVal[1][2],{|x| x[2]=="D1_ALIQSOL"})][3],0)
		EndIf
		oGetDados:oBrowse:Refresh()
		ColImpRefresh()
	Else
		lRet := .F.
	EndIf
Else
	If lDevSemOri
		Aviso(STR0004,STR0078,{STR0077}) //-- Atencao # Nota fiscal original e serie invalida.
	Else
		Aviso(STR0004,STR0140,{STR0077}) //-- Atencao # A TES gera Duplicata e nao foi encontrada condicao de pagamento no cadastro do fornecedor/cliente.
	EndIf
EndIf
RollBackSX8()

n := nPosAnt

RestArea(aAreaSDT)
RestArea(aAreaSDS)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ColVerTes
Verifica se todos os itens possuem TES

@author Flavio Lopes Rasta	
@since 22/04/2015
@version P12
/*/
//-------------------------------------------------------------------

Function ColVerTes(aItens)
Local nPosTes	:= 0
Local nX		:= 1
Local lRet		:= .T. 

For nX:=1 To Len(aItens) 
	nPosTes := aScan(aItens[nX], {|x| x[1]=="D1_TES"})
	If !(nPosTes > 0) .Or. Empty(aItens[nX][nPosTes][2])
		lRet := .F.
		Exit
	Endif
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ColConDHJ
Consulta OP pelo CFOP
@param  cCfop - CFOP para realizar busca
@param  cTypeOper - Tipo de operação Entrada("E" Padrão) ou Saida("S") 
@author Flavio Lopes Rasta	
@since 22/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function ColConDHJ(cCfop,cTypeOper)

Local cOp 		:= ""

Default cTypeOper := "E"

If cPaisLoc == "BRA"
	DHJ->(DbSetOrder(2))
	If DHJ->(DbSeek(xFilial("DHJ")+cCfop))
		If AllTrim(cTypeOper) == "S"
			If DHJ->(ColumnPos( "DHJ_TPOPSA" )) > 0
				cOp := AllTrim(DHJ->DHJ_TPOPSA)
			EndIf	
		Else		
			cOp := AllTrim(DHJ->DHJ_TPOP)
		EndIf	
	EndIf
EndIf

Return cOp

/*/{Protheus.doc}COLFINSDS
Verifica se documento existe na base de dados

@author Rodrigo Machado Pontes	
@since 22/10/2015
@version P11
/*/

Function COLFINSDS(nOrdem,cColabDoc,cColabSer,cColabFor,cColabLoj)

Local lRet		:= .T.
Local cQry		:= ""

If Select("TMPSDS") > 0
	TMPSDS->(DbCloseArea())
Endif

cQry	:= " SELECT DS_DOC"
cQry	+= " FROM " + RetSqlName("SDS")
If nOrdem == 1 //Doc + Serie + Forn + Loja
	cQry	+= " WHERE DS_DOC  = '" + cColabDoc + "'"
	cQry	+= " AND DS_SERIE  = '" + cColabSer + "'"
	cQry	+= " AND DS_FORNEC = '" + cColabFor + "'"
	cQry	+= " AND DS_LOJA   = '" + cColabLoj + "'"
Elseif nOrdem == 2 //Chave NF
	cQry	+= " WHERE DS_CHAVENF = '" + cColabDoc + "'"
Endif
cQry	+= " AND D_E_L_E_T_ = ''"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TMPSDS",.T.,.T.)

DbSelectArea("TMPSDS")
TMPSDS->(dbGoTop())
If !TMPSDS->(Eof())
	lRet := .F.	
EndIf

TMPSDS->(dbCloseArea())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COLLegIt()
Exibe uma janela contendo a legenda da classificação no item do
documento no Totvs Colaboração

@author Flavio Lopes Rasta
@since 20/06/2016
@version 11 
/*/
//-------------------------------------------------------------------
Function COLLegIt()
Local cLeg:= ""
Local aCores     := {}

aAdd(aCores,{"BR_BRANCO","Sem Classificação"})
aAdd(aCores,{"BR_VERDE","Sem Divergência de Impostos"})
aAdd(aCores,{"BR_VERMELHO","Com Divergência de Impostos"})

BrwLegenda("Monitor TOTVS Colaboração","Legenda da Classificação",aCores)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ColAtuLeg()

@author Flavio Lopes Rasta
@since 20/06/2016
@version 11 
/*/
//-------------------------------------------------------------------
Function ColAtuLeg(aHeader,aCols)
Local nItem		:= Len(aCols)
Local nX		:= 1
Local aImpostos	:= {}
Local cLegenda	:= "BR_VERDE"
Local aColsImp	:= {}
Local oOK		:= LoadBitmap(GetResources(),'BR_VERDE')
Local oNO		:= LoadBitmap(GetResources(),'BR_VERMELHO') 
Local nValorTes := 0
Local nAliqTes	:= 0
Local lMVDiviZer:= SuperGetMv("MV_DIVIZER",.F.,.F.)

aAdd(aImpostos,{"IPI"		,"DT_TESIPI"	,"DT_XMLIPI"	,"DT_ALIQIPI"	,"DT_XALQIPI"})
aAdd(aImpostos,{"ICMS"		,"DT_TESICM"	,"DT_XMLICM"	,"DT_ALIQICM"	,"DT_XALQICM"})
aAdd(aImpostos,{"ISS"		,"DT_TESISS"	,"DT_XMLISS"	,"DT_ALIQISS"	,"DT_XALQISS"})
aAdd(aImpostos,{"PIS"		,"DT_TESPIS"	,"DT_XMLPIS" 	,"DT_ALIQPIS"	,"DT_XALQPIS"})
aAdd(aImpostos,{"COFINS"	,"DT_TESCOF"	,"DT_XMLCOF"	,"DT_ALIQCOF"	,"DT_XALQCOF"})
aAdd(aImpostos,{"ICMS ST"	,"DT_TESICST"	,"DT_XMLICST"	,"DT_ALIICST"	,"DT_XALICST"})

If ExistBlock("COLDVIMP")
	For nX:=1 To Len(aImpostos)
		nValorTes := aCols[nItem,GDFieldPos(aImpostos[nX][2])]
		nAliqTes  := If(lMVDiviZer .And. (nValorTes == 0),0,aCols[nItem,GDFieldPos(aImpostos[nX][4])]) 
		
		aAdd(aColsImp,{})
		aAdd(aTail(aColsImp),If(nValorTes == aCols[nItem,GDFieldPos(aImpostos[nX][3])] .And. nAliqTes == aCols[nItem,GDFieldPos(aImpostos[nX][5])],oOK,oNO))
		aAdd(aTail(aColsImp),aImpostos[nX][1])
		aAdd(aTail(aColsImp),nValorTes)
		aAdd(aTail(aColsImp),aCols[nItem,GDFieldPos(aImpostos[nX][3])])
		aAdd(aTail(aColsImp),nAliqTes)
		aAdd(aTail(aColsImp),aCols[nItem,GDFieldPos(aImpostos[nX][5])])
		aAdd(aTail(aColsImp),.F.)
	Next nX
	
	aColsImp := ExecBlock("COLDVIMP",.F.,.F.,{"COMXCOL",aColsImp})
	
	If aScan(aColsImp,{|x| x[1]:cName == "BR_VERMELHO"}) > 0
		cLegenda := "BR_VERMELHO"
	Endif
		
Else
	For nX:=1 To Len(aImpostos)
		nValorTes	:= aCols[nItem,GDFieldPos(aImpostos[nX][2])]
		nAliqTes	:= If(lMVDiviZer .And. (nValorTes == 0),0,aCols[nItem,GDFieldPos(aImpostos[nX][4])])
		If nValorTes <> aCols[nItem,GDFieldPos(aImpostos[nX][3])] .Or. nAliqTes <> aCols[nItem,GDFieldPos(aImpostos[nX][5])]
			cLegenda	:= "BR_VERMELHO"
			Exit
		Endif
	Next nX
Endif

aCols[nItem,GDFieldPos("DT_LEGENDA")] := cLegenda 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaFilial
TOTVS COLABORAÇAO 2.0
Função para marcar somente uma filial de processamento do documento.

@param	aFiliais, array , Filiais carregados.
@param	nLinha  , num   , Linha selecionada.        
@param	oBrowse , object, Objeto do browse.      

@author	Geovani.Figueira
@since		05/12/2017
@version	12.1.17
/*/
//-------------------------------------------------------------------
Static Function MarcaFilial(aFiliais,nLinha,oBrowse)
	Local nX := 0
	
	If !Empty(aFiliais)
		
		For nX := 1 To Len(aFiliais)
			IIF(nX == nLinha,aFiliais[nLinha,1] := !aFiliais[nLinha,1],aFiliais[nX,1] := .F. )			
		Next nX
	
		oBrowse:Refresh()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} COLXCQ
TOTVS COLABORAÇAO 2.0 x Controle CQ
Função para buscar numeração de CQ para o conhecimento de frete 
gerado via totvs colaboração   

@author	Rodrigo M Pontes
@since		05/12/2017
@version	12.1.17
/*/
//-------------------------------------------------------------------     

Function COLXCQ(cDocComp,cSerComp,cForComp,cLojComp,cProd,cItemComp,cDocOri,cSerOri,cItemOri)

Local aArea	:= GetArea()
Local aRet 	:= {.F.,"","","","",0}

DbSelectArea("SDS")
SDS->(DbSetOrder(1))

DbSelectArea("SDT")
SDT->(DbSetOrder(1))

DbSelectArea("SF1")

DbSelectArea("SD1")

//Verifica se é originado pelo totvs colaboração
If SDS->(DbSeek(xFilial("SDS") + cDocComp + cSerComp + cForComp + cLojComp))
	//Busca Chave na NF de origem
	BeginSql alias 'DTIT'
	    SELECT
	        DT.DT_CHVNFO
	    FROM
	        %table:SDT% DT
	    WHERE
	        DT.DT_FILIAL 	= %xfilial:SDT% AND 
	        DT.DT_DOC		= %exp:cDocComp% AND
	        DT.DT_SERIE		= %exp:cSerComp% AND
	        DT.DT_FORNEC	= %exp:cForComp% AND
	        DT.DT_LOJA		= %exp:cLojComp% AND
	        DT.DT_NFORI 	= %exp:cDocOri% AND
	        DT.DT_SERIORI	= %exp:cSerOri% AND
	        DT.DT_ITEMORI	= %exp:cItemOri% AND 
	        DT.%notDel% ORDER BY %Order:SDT%
	EndSql
	
	DbSelectArea("DTIT")
	If DTIT->(!EOF())
		//Posiciona na NF de origem
		SF1->(DbSetOrder(8))
		If SF1->(DbSeek(xFilial("SF1") + DTIT->DT_CHVNFO))
			aRet[6] := SF1->(Recno()) //Recno da NF de origem
			SD1->(DbSetOrder(1))
			If SD1->(DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + cProd + cItemOri))
				//Pega numero CQ
				aRet[2] := SD1->D1_NUMCQ
			Endif
			aRet[1] := .T.
			aRet[3] := ""
			aRet[4] := ""
			aRet[5] := ""
		Endif
	Endif
	
	DTIT->(DbCloseArea())
Endif

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} COMXIMPVLD
Função para validar aliquotas de icms/pis/cofins

@author	Rodrigo M Pontes
@since		05/12/2017
@version	12.1.17
/*/
//-------------------------------------------------------------------     

Function COMXIMPVLD(aVldImp)

Local nI	:= 1
Local cVld	:= ""
Local lRet	:= .F.

For nI := 1 To Len(aVldImp)
	cVld := AllTrim(Str(aVldImp[nI,1])) + aVldImp[nI,2]
	
	lRet := &(cVld)
	
	If lRet
		Exit
	Endif
Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ComxUsrCpo
Função para validar existência de campos de usuário.

@author	Romulo Batista
@since		22/03/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------     
Function ComxUsrCpo(aCpsAlt)

Local nX		:= 0
Local aStru		:= FWFormStruct(3,"SDT")[1]
Local aUsrCpo	:= {}
Local cTipo		:= "X3_PROPRI"
Local cCamUsr	:= ""

Default aCpsAlt	:= {}

For nX := 1 To Len(aStru)
	If GetSx3Cache(aStru[nX][3],cTipo) == "U"
		Aadd(aCpsAlt,aStru[nX][3])
		Aadd(aUsrCpo,aStru[nX][3])
	EndIf
Next nX

Return aUsrCpo