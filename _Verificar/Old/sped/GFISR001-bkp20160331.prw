#include "protheus.ch"
#include "Rwmake.ch"
#include "gfisr001.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGFISR001  บAutor  ณRMA Tecnologia      บ Data ณ  25/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Demonstrativo Status Nf de saida                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP        		                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function GFISR001()
Local cDesc1        := STR0001
Local cDesc2        := STR0002
Local cDesc3        := ""
Local cPict         := ""
Local titulo       	:= STR0003
Local nLin          := 80
Local Cabec1		:= STR0006
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd        	:= {}
Private lEnd       	:= .F.
Private lAbortPrint	:= .F.
Private CbTxt      	:= ""
Private limite     	:= 80
Private tamanho    	:= "G"
Private nomeprog   	:= "GFISR001"
Private nTipo      	:= 18
Private aReturn   	:= { STR0004, 1, STR0005, 2, 2, 1, "", 1}
Private nLastKey   	:= 0
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= nomeprog
Private cPerg      	:= "GFIR01"
Private cString    	:= "SF3"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta perguntas do relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AjustaSX1(cPerg)

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ RMA Tecnologia    บ Data ณ  25/04/12    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local cFilDe 	:= MV_PAR03
Local cFilAte	:= MV_PAR04
Local cAliasSF3	:= ""
Local cIdEnt 	:= ""
Local cNomCli   := ""
Local cDtEmiss  := ""
Local cDtCanc   := ""
Local cEst      := ""
Local cTitulo  	:= STR0003
Local aListBox  := {}
Local aParam    := {}
Local aCabec    := {}
Local aItens    := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta arquivo temporarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
MontTrab()


AADD(aCabec,"Filial")
AADD(aCabec,"Num Nf")
AADD(aCabec,"Serie")
AADD(aCabec,"Dt Emissao")
AADD(aCabec,"Dt Cancelamento")
AADD(aCabec,"Cliente")
AADD(aCabec,"Loja")
AADD(aCabec,"Nome")
AADD(aCabec,"UF")
AADD(aCabec,"Chave Nfe")
AADD(aCabec,"Status")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica como as filiais serao processadas:ณ
//ณ- apenas a filial                          ณ
//ณ- filial de/ate                            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (Empty(MV_PAR03) .And. Empty(MV_PAR04))
	cFilDe	:=	cFilAte	:=	cFilAnt
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณProcesso as Filiaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea ("SM0")
SM0->(DbSeek (cEmpAnt+cFilDe,.T.))

Do While !SM0->(Eof ()) .And. (SM0->M0_CODIGO==cEmpAnt) .And. (SM0->M0_CODFIL<=cFilAte)
	cFilAnt	:= SM0->M0_CODFIL
	
	DbSelectArea("SF3")
	SF3->(DbSetOrder (1))
	
	If mv_par09 == 1
		cWhere := "%( (SubString(SF3.F3_CFO,1,1) >= '5'  AND SF3.F3_DTCANC = Space(8)) )%"
	elseIf mv_par09 == 2
		cWhere := "%( (SubString(SF3.F3_CFO,1,1) >= '5'  AND SF3.F3_DTCANC <> Space(8)) )%"
	else
		cWhere := "%( (SubString(SF3.F3_CFO,1,1) >= '5') )%"
	EndIf
	
	cAliasSF3	:=	GetNextAlias()
	BeginSql Alias cAliasSF3
		SELECT DISTINCT SF3.F3_FILIAL, SF3.F3_NFISCAL, SF3.F3_SERIE, SF3.F3_CLIEFOR, SF3.F3_LOJA, SF3.F3_EMISSAO, SF3.F3_DTCANC, SF3.F3_TIPO, SFT.FT_CHVNFE
		FROM
		%Table:SF3% SF3
		JOIN %table:SFT% SFT ON SFT.FT_FILIAL = %xFilial:SFT%
		AND SFT.FT_TIPOMOV = 'S'
		AND SFT.FT_CLIEFOR = SF3.F3_CLIEFOR
		AND SFT.FT_LOJA = SF3.F3_LOJA
		AND SFT.FT_SERIE = SF3.F3_SERIE
		AND SFT.FT_NFISCAL = SF3.F3_NFISCAL
		AND SFT.FT_IDENTF3 = SF3.F3_IDENTFT
		AND SFT.%NotDel%
		WHERE
		SF3.F3_FILIAL  =  %xFilial:SF3% AND
		SF3.F3_EMISSAO >= %Exp:DToS (MV_PAR01)% AND
		SF3.F3_EMISSAO <= %Exp:DToS (MV_PAR02)% AND
		SF3.F3_NFISCAL >= %Exp:mv_par05% 	AND
		SF3.F3_NFISCAL <= %Exp:mv_par06% 	AND
		SF3.F3_SERIE   >= %Exp:mv_par07% 	AND
		SF3.F3_SERIE   <= %Exp:mv_par08% 	AND
		%Exp:cWhere% AND
		SF3.%NotDel%
		ORDER BY F3_FILIAL, F3_NFISCAL, F3_SERIE, F3_EMISSAO
	EndSql
	
	DbSelectArea (cAliasSF3)
	(cAliasSF3)->(DbGoTop ())
	ProcRegua ((cAliasSF3)->(RecCount ()))
	
	While !(cAliasSF3)->(Eof())
		
		cIdEnt 	:= GetIdEnt()
		aParam 	:= {(cAliasSF3)->F3_SERIE, (cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_NFISCAL}
		
		If ! Empty(cIdEnt)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณBusca recomendacoes exibidas no monitorณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aListBox := {}
			aListBox := WsNFeMnt(cIdEnt,1,aParam)
			
			cDtEmiss := Substr((cAliasSF3)->F3_EMISSAO,7,2)+"/"+Substr((cAliasSF3)->F3_EMISSAO,5,2)+"/"+Substr((cAliasSF3)->F3_EMISSAO,1,4)
			cDtCanc  := Substr((cAliasSF3)->F3_DTCANC,7,2)+"/"+Substr((cAliasSF3)->F3_DTCANC,5,2)+"/"+Substr((cAliasSF3)->F3_DTCANC,1,4)
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณVerifica Cliente/ Fornecedorณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If((cAliasSF3)->F3_TIPO$"BD")
				dbSelectArea("SA2")
				SA2->(dbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cNomCli:= SA2->A2_NREDUZ
					cEst   := SA2->A2_EST
				EndIf
			else
				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					cNomCli:= SA1->A1_NREDUZ
					cEst   := SA1->A1_EST
				EndIf
			EndIf
			
			If len(aListBox) > 0
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณPopula tabela temporariaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				DbSelectArea("TRB2")
				Reclock("TRB2",.T.)
				TRB2->FILIAL  := (cAliasSF3)->F3_FILIAL
				TRB2->NF      := (cAliasSF3)->F3_NFISCAL
				TRB2->SERIE   := (cAliasSF3)->F3_SERIE
				TRB2->EMISSAO := cDtEmiss
				TRB2->CANCELA := cDtCanc
				TRB2->CLIENTE := (cAliasSF3)->F3_CLIEFOR
				TRB2->LOJA    := (cAliasSF3)->F3_LOJA
				TRB2->UF      := cEst
				TRB2->NOME    := SubStr(cNomCli,1,30)
				TRB2->RECOM   := SubStr(aListBox[len(aListBox)][4],1,80)
				TRB2->CHAVE   := (cAliasSF3)->FT_CHVNFE
				TRB2->(MsUnLock())
				
				If mv_par10 == 1
					AADD(aItens, {TRB2->FILIAL, TRB2->NF, TRB2->SERIE, TRB2->EMISSAO, TRB2->CANCELA, TRB2->CLIENTE, TRB2->LOJA, TRB2->NOME, TRB2->UF, TRB2->CHAVE, TRB2->RECOM})
				EndIf
				
			EndIf
		EndIf
		(cAliasSF3)->(DbSkip())
	EndDo
	
	SM0->(DbSkip())
EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSeleciona tabela temporariaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TRB2->(DbSelectArea("TRB2"))
TRB2->(dbGoTop())
ProcRegua(TRB2->(RecCount()))
TRB2->(DbGotop())
If TRB2->(EOF())
	MsgBox(STR0007)
	TRB2->(DbCloseArea())
	Return()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณImprime Relatorioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
TRB2->(DbGotop())
While !TRB2->(Eof())
	
	IncProc()
	If lAbortPrint
		@nLin,00 PSAY STR0008
		Exit
	Endif
	
	If nLin > 60 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	@ nLin, 000			Psay TRB2->FILIAL
	@ nLin, PCOL() + 5 	PSay TRB2->NF
	@ nLin, PCOL() + 1 	PSay TRB2->SERIE
	@ nLin, PCOL() + 3	PSay TRB2->EMISSAO
	@ nLin, PCOL() + 2 	PSay TRB2->CANCELA
	@ nLin, PCOL() + 6 	PSay TRB2->CLIENTE
	@ nLin, PCOL() + 2 	PSay TRB2->LOJA
	@ nLin, PCOL() + 3 	PSay TRB2->NOME
	@ nLin, PCOL() + 1 	PSay TRB2->UF
	@ nLin, PCOL() + 1 	PSay TRB2->CHAVE
	@ nLin, PCOL() + 1 	PSay TRB2->RECOM
	nLin ++
	TRB2->(DbSkip())
EndDo

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

TRB2->(DbSelectArea("TRB2"))
TRB2->(DbCloseArea())

If mv_par10 == 1
	Processa( { || GeraExcel(cTitulo,aCabec,aItens,"Demons_Nf_Saida" + DTOS(Date())) }, 'Gerando Excel' )
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontTrab  บAutor  ณRMA Tecnologia      บ Data ณ  25/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta tabela temporaria 					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontTrab()
Local aDbf := {}
Local nTamNf := TamSx3("F2_DOC")[1]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta tabela temporariaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd( aDbf, { "FILIAL" 	,"C"  	,02,0 } )
aAdd( aDbf, { "NF" 		,"C"  	,nTamNf,0 } )
aAdd( aDbf, { "SERIE"	,"C"  	,03,0 } )
aAdd( aDbf, { "EMISSAO"	,"C"  	,10,0 } )
aAdd( aDbf, { "CANCELA"	,"C"  	,10,0 } )
aAdd( aDbf, { "CLIENTE"	,"C"  	,06,0 } )
aAdd( aDbf, { "LOJA"  	,"C"  	,02,0 } )
aAdd( aDbf, { "NOME" 	,"C"  	,30,0 } )
aAdd( aDbf, { "UF" 	    ,"C"  	,02,0 } )
aAdd( aDbf, { "RECOM"	,"C"  	,80,0 } )
aAdd( aDbf, { "CHAVE"	,"C"  	,44,0 } )

TRB2 := CriaTrab( aDbf, .t. )
dbUseArea(.T.,,TRB2,"TRB2",.F.,.F.)
dbSelectArea('TRB2')
cKey   := "FILIAL+NF+SERIE"
cCond  := ""
cIndex := CriaTrab(NIL,.F.)
IndRegua( "TRB2" ,cIndex ,cKey ,,cCond ,"Indexando Arq.Temporario")
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณGetIdEnt  ณ Autor ณRMA Tecnologia         ณ Data ณ20.07.2012ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณObtem o codigo da entidade apos enviar o post para o Totvs  ณฑฑ
ฑฑณ          ณService                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpC1: Codigo da entidade no Totvs Services                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function GetIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObtem o codigo da entidade                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oWS := WsSPEDAdm():New()
oWS:cUSERTOKEN := "TOTVS"

oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
oWS:oWSEMPRESA:cCEP_CP     := Nil
oWS:oWSEMPRESA:cCP         := Nil
oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
oWS:oWSEMPRESA:cINDSITESP  := ""
oWS:oWSEMPRESA:cID_MATRIZ  := ""
oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
If oWs:ADMEMPRESAS()
	cIdEnt  := oWs:cADMEMPRESASRESULT
EndIf
RestArea(aArea)
Return(cIdEnt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWsNFeMnt  บAutor  ณRMA Tecnologia      บ Data ณ  25/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca recomendacoes exibidas no monitor                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function WsNFeMnt(cIdEnt,nModelo,aParam)
Local aListBox := {}
Local nX       := 0
Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk      := .T.
Local oOk      := LoadBitMap(GetResources(), "ENABLE")
Local oNo      := LoadBitMap(GetResources(), "DISABLE")
Local oWS
Local oRetorno

Private oXml

oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN    := "TOTVS"
oWS:cID_ENT       := cIdEnt
oWS:_URL          := AllTrim(cURL)+"/NFeSBRA.apw"

oWS:cIdInicial    := aParam[01]+aParam[02]
oWS:cIdFinal      := aParam[01]+aParam[03]
lOk := oWS:MONITORFAIXA()
oRetorno := oWS:oWsMonitorFaixaResult

If lOk
	dbSelectArea("SF3")
	dbSetOrder(5)
	For nX := 1 To Len(oRetorno:oWSMONITORNFE)
		aMsg := {}
		oXml := oRetorno:oWSMONITORNFE[nX]
		aadd(aListBox,{ IIf(Empty(oXml:cPROTOCOLO),oNo,oOk),;
		oXml:cID,;
		oXml:cPROTOCOLO,;
		PadR(oXml:cRECOMENDACAO,250)})
	Next nX
EndIf
Return(aListBox)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraExcel บAutor  ณRMA - Tecnologia     บ Data ณ  25/04/12  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera Excel                                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraExcel(cTitulo,aHeader,aDados,cArquivoXX,cDir,lMsg,lEspaco)
local cDiretorio:= "c:\Temp"
local aTestDir  := {}
local cFileName	:= cDiretorio + "\REL_GER_"+DTOS(DATE())+".xls"
Local nHdl
Local cNomeArq  := cArquivoXX
local lxEsp     := lEspaco

If ValType(cDir) == "C"
	If !Empty(cDir)
		cDiretorio := cDir
	EndIf
endIf

aTestDir  := Directory(cDiretorio+"\*.*")

If Len(aTestDir) <= 0
	If !MontaDir(cDiretorio)
		MsgBox("Erro para montar o diretorio: " + cDiretorio)
	EndIf
EndIf

If ValType(cNomeArq) == "C"
	If !Empty(cNomeArq)
		cFileName     := cDiretorio + "\" + cNomeArq + ".xls"
	EndIf
EndIf

nHdl := FCreate(cFILENAME,0)

If ( nHdl < 0 )
	MsgStop("Diret๓rio invแlido","Aten็ใo") //"Diret๓rio invแlido." # "Aten็ใo"
	Return()
EndIf

cTexto := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cTexto += '<html xmlns="http://www.w3.org/1999/xhtml">'
cTexto += '<head>'
cTexto += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
cTexto += '<title>'+ cTitulo +'</title>'
cTexto += '</head>'
cTexto += '<body>'
cTexto += '<table style="border: 1px solid #000; border-collapse:collapse; width:99%; font:10px Verdana;">'
cTexto += '	<caption style="padding:0 0 5px 0;">'+cTitulo+'</caption>'
cTexto += '	<thead style="background:#006; color:#FFF; font-weight:bold">'
cTexto += '	  <tr>'
For i:=1  To Len(aHeader)
	cTexto += '	    <th scope="col" style="border: 1px solid #000;">'+aHeader[i]+'</th>'
Next i
cTexto += '	  </tr>'
cTexto += '	</thead>'
cTexto += '	<tbody style="background:#FFFFFF;">'

fWrite(nHdl,cTexto,Len(cTexto))
cTexto := ""

ProcRegua(len(aDados))

For i:=1 to len(aDados)
	IncProc()
	cTexto += '	  <tr>'
	For j:= 1 To Len(aHeader)
		If Valtype(aDados[i][j]) == 'D'
			cConteudo := DTOC(aDados[i][j])
		ElseIf Valtype(aDados[i][j]) == 'N'
			cConteudo := Transform(aDados[i][j],'@E 999,999,999.99')
		Else
			If ValType(lxEsp) == "L"
				If lxEsp
					cConteudo := "&nbsp;" + aDados[i][j]
				Else
					cConteudo := aDados[i][j]
				EndIf
			Else
				cConteudo := "&nbsp;" + aDados[i][j]
			EndIf
		EndIF
		cTexto += '	    <td style="border: 1px solid #000;">'+cConteudo+'</td>'
	Next j
	cTexto += '	  </tr>'
	
	fWrite(nHdl,cTexto,Len(cTexto))
	cTexto := ""
Next i

cTexto += '	</tbody>'
cTexto += '</table>'
cTexto += '</body>'
cTexto += '</html>'

fWrite(nHdl,cTexto,Len(cTexto))
cTexto := ""

fClose(nHdl)
MsgAlert("Relatorio gerado com sucesso em: " + cFILENAME)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณRMA Tecnologia      บ Data ณ  25/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ajusta as perguntas do relatorio                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

//Data Inicial
Aadd( aHelpPor, 'Informe a data inicial para ')
Aadd( aHelpPor, 'processamento do relatorio')
Aadd( aHelpSpa, 'Informe a data inicial para ')
Aadd( aHelpSpa, 'processamento do relatorio')
Aadd( aHelpEng, 'Informe a data inicial para ')
Aadd( aHelpEng, 'processamento do relatorio')
PutSx1(cPerg,"01","Data Inicial ","Data Inicial ","Data Inicial ","mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Data Final
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a data final para ')
Aadd( aHelpPor, 'processamento do relatorio')
Aadd( aHelpSpa, 'Informe a data final para ')
Aadd( aHelpSpa, 'processamento do relatorio')
Aadd( aHelpEng, 'Informe a data final para ')
Aadd( aHelpEng, 'processamento do relatorio')
PutSx1(cPerg,"02","Data Final ","Data Final ","Data Final ","mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De Filial
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a filial inicial para ')
Aadd( aHelpPor, 'processamento do relatorio')
Aadd( aHelpSpa, 'Informe a filial inicial para ')
Aadd( aHelpSpa, 'processamento do relatorio')
Aadd( aHelpEng, 'Informe a filial inicial para ')
Aadd( aHelpEng, 'processamento do relatorio')
PutSx1(cPerg,"03","De Filial ","De Filial ","De Filial ","mv_ch3","C",02,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate Filial
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a filial final para ')
Aadd( aHelpPor, 'processamento do relatorio')
Aadd( aHelpSpa, 'Informe a filial final para ')
Aadd( aHelpSpa, 'processamento do relatorio')
Aadd( aHelpEng, 'Informe a filial final para ')
Aadd( aHelpEng, 'processamento do relatorio')
PutSx1(cPerg,"04","Ate Filial ","Ate Filial ","Ate Filial ","mv_ch4","C",02,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De Nota
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a nota inicial para ')
Aadd( aHelpPor, 'processamento no relatorio')
Aadd( aHelpSpa, 'Informe a nota inicial para ')
Aadd( aHelpSpa, 'processamento no relatorio')
Aadd( aHelpEng, 'Informe a nota inicial para ')
Aadd( aHelpEng, 'processamento no relatorio')
PutSx1(cPerg,"05","De NF ","De NF ","De NF ","mv_ch5","C",TamSx3("F2_DOC")[1],0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate Nota
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a nota final para ')
Aadd( aHelpPor, 'processamento no relatorio')
Aadd( aHelpSpa, 'Informe a nota final para ')
Aadd( aHelpSpa, 'processamento no relatorio')
Aadd( aHelpEng, 'Informe a nota final para ')
Aadd( aHelpEng, 'processamento no relatorio')
PutSx1(cPerg,"06","Ate NF ","Ate NF ","Ate NF ","mv_ch6","C",TamSx3("F2_DOC")[1],0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//De Serie
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a serie inicial para ')
Aadd( aHelpPor, 'processamento no relatorio')
Aadd( aHelpSpa, 'Informe a serie inicial para ')
Aadd( aHelpSpa, 'processamento no relatorio')
Aadd( aHelpEng, 'Informe a serie inicial para ')
Aadd( aHelpEng, 'processamento no relatorio')
PutSx1(cPerg,"07","De Serie ","De Serie ","De Serie ","mv_ch7","C",TamSx3("F2_SERIE")[1],0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Ate Serie
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe a serie final para ')
Aadd( aHelpPor, 'processamento no relatorio')
Aadd( aHelpSpa, 'Informe a serie final para ')
Aadd( aHelpSpa, 'processamento no relatorio')
Aadd( aHelpEng, 'Informe a serie final para ')
Aadd( aHelpEng, 'processamento no relatorio')
PutSx1(cPerg,"08","Ate Serie ","Ate Serie ","Ate Serie ","mv_ch8","C",TamSx3("F2_SERIE")[1],0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Status
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe o status para ')
Aadd( aHelpPor, 'processamento no relatorio')
Aadd( aHelpSpa, 'Informe o status para ')
Aadd( aHelpSpa, 'processamento no relatorio')
Aadd( aHelpEng, 'Informe o status para ')
Aadd( aHelpEng, 'processamento no relatorio')
PutSx1(cPerg,"09","Status ","Status ","Status ","mv_ch9","N",01,0,1,"C","","","","","mv_par09","Ativas","Ativas","Ativas","Canceladas","Canceladas","Canceladas","Ambas","Ambas","Ambas","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//Gera Excel
aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}
Aadd( aHelpPor, 'Informe se devera ser ')
Aadd( aHelpPor, 'gerado planilha excel')
Aadd( aHelpSpa, 'Informe se devera ser ')
Aadd( aHelpSpa, 'gerado planilha excel')
Aadd( aHelpEng, 'Informe se devera ser ')
Aadd( aHelpEng, 'gerado planilha excel')
PutSx1(cPerg,"10","Gera Excel ","Gera Excel ","Gera Excel ","mv_chA","N",01,0,2,"C","","","","","mv_par10","Sim","Sim","Sim","Nao","Nao","Nao","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
Return()