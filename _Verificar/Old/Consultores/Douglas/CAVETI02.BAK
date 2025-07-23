#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVETI02  บAutor  ณMicrosiga           บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressใo de etiquetas ZEBRA x Pedido de compra             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CAVETIT2()

Private L120AUTO := .f.
Private NTIPOPED := 1
Private nFuncao := 1

PRIVATE cCadastro := IIf(nFuncao==2,OemtoAnsi(OemToAnsi("Autorizacao de Entrega")),IIf(cPaisLoc == "VEN",OemtoAnsi("Requisicoes de Compra"),OemtoAnsi("Pedidos de Compra")))	//"Autorizacao de Entrega"###"Requisicoes de Compra"(Ven)###"Pedidos de Compra"
//IVATE l120Auto  := ( ValType(xAutoCab)=="A" .And. ValType(xAutoItens) == "A" )

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","A120Pedido"	,0,2} ,;
{"Etiqueta","u_CAVETI2a()",0,3}} // ,;
//{"Alterar","AxAltera",0,4}}

//aAdd(aRotina, { OemToAnsi(STR0007),"A120Pedido"	, 0 , 2})	//"Visualizar"

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SC7"

dbSelectArea("SC7")
dbSetOrder(1)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa a funcao MBROWSE. Sintaxe:                                  ณ
//ณ                                                                     ณ
//ณ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ณ
//ณ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ณ
//ณ                        exibido. Para seguir o padrao da AXCADASTRO  ณ
//ณ                        use sempre 6,1,22,75 (o que nao impede de    ณ
//ณ                        criar o browse no lugar desejado da tela).   ณ
//ณ                        Obs.: Na versao Windows, o browse sera exibi-ณ
//ณ                        do sempre na janela ativa. Caso nenhuma este-ณ
//ณ                        ja ativa no momento, o browse sera exibido naณ
//ณ                        janela do proprio SIGAADV.                   ณ
//ณ Alias                - Alias do arquivo a ser "Browseado".          ณ
//ณ aCampos              - Array multidimensional com os campos a serem ณ
//ณ                        exibidos no browse. Se nao informado, os cam-ณ
//ณ                        pos serao obtidos do dicionario de dados.    ณ
//ณ                        E util para o uso com arquivos de trabalho.  ณ
//ณ                        Segue o padrao:                              ณ
//ณ                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ณ
//ณ                                     {<CAMPO>,<DESCRICAO>},;         ณ
//ณ                                     . . .                           ณ
//ณ                                     {<CAMPO>,<DESCRICAO>} }         ณ
//ณ                        Como por exemplo:                            ณ
//ณ                        aCampos := { {"TRB_DATA","Data  "},;         ณ
//ณ                                     {"TRB_COD" ,"Codigo"} }         ณ
//ณ cCampo               - Nome de um campo (entre aspas) que sera usadoณ
//ณ                        como "flag". Se o campo estiver vazio, o re- ณ
//ณ                        gistro ficara de uma cor no browse, senao fi-ณ
//ณ                        cara de outra cor.                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVETI2a  บAutor  ณMicrosiga           บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para Cavanna                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CAVETI2a()

Local aCpos := {{ "OK"     	,"C",  2, 0 },;
{ "PEDIDO"	,"C", 006, 0 },;
{ "DESC"	,"C", 040, 0 },;
{ "ITEM"	,"C", 004, 0 },;
{ "CODIGO"	,"C", 015, 0 },;
{ "UM"      ,"C", 003, 0 },;
{ "QUANT"	,"N", 015, 6 },;
{ "ENDERECO","C", 015, 4 },;
{ "QTEMP"   ,"N", 015, 6 },;
{ "OP"   	,"C", 013, 0 },;
{ "NF"   	,"C", 009, 0 },;
{ "DTNF"   	,"D", 008, 0 }}

Local aCampos := {{ "OK"     	,,  "Sel" },;
{ "PEDIDO"	,,  "Pedido"},;
{ "DESC"	,,  "Descri็ใo"},;
{ "ITEM"	,,  "Item"},;
{ "CODIGO"	,,  "Codigo"},;
{ "UM"	    ,,  "Unidade"},;
{ "QUANT"	,,  "Quantidade",'@E 999,999,999.999999'},;
{ "ENDERECO",,  "Endere็o"},;
{ "QTEMP"	,,  "Qt.Empenho",'@E 999,999,999.999999'},;
{ "OP"   	,,  "Ord.producao"},;
{ "NF"   	,,  "Nota fiscal"},;
{ "DTNF"   	,,  "Dt.Nf.Digit."}}

Local oMark
Local obs
Local cNomtrb  := CriaTrab(aCpos)
dbUseArea( .T.,,cNomTrb,"TRBMARK",.F. )

Private cCadastro := "Impressใo de etiquetas x pedido de compra"
Private aRotina	  := { { "Imprime", 'u_EDI_LA00', 3, } }
Private lInverte := .f.
Private cMarca    := GetMark()
Private avMarca   := GetMark()
Private CEOL    := "CHR(13)+CHR(10)"
Private cArqTXT
Private _cArquivo
Private _aFiles := " "

_cNum := SC7->C7_NUM
dbSelectArea("SC7")
dbGotop()
dbSeek(xFilial("SC7")+_cNum)

While !Eof() .And. SC7->C7_NUM == _cNum
	
	_aAreaSC7 := GetArea()
	
	dbSelectArea("TRBMARK")
	RecLock("TRBMARK",.T.)
	TRBMARK->PEDIDO  := SC7->C7_NUM
	TRBMARK->DESC    := SC7->C7_DESCRI
	TRBMARK->ITEM    := SC7->C7_ITEM
	TRBMARK->CODIGO  := SC7->C7_PRODUTO
	TRBMARK->UM      := SC7->C7_UM
	TRBMARK->QUANT   := SC7->C7_QUANT
	TRBMARK->ENDERECO:= GetAdvFVal('SB2','B2_LOCALIZ',xFilial('SB2')+SC7->C7_PRODUTO,1)
	TRBMARK->QTEMP   := GetAdvFVal('SD4','D4_QUANT',xFilial('SD4')+SC7->(C7_PRODUTO+C7_OP),1)
	TRBMARK->OP      := SC7->C7_OP
	TRBMARK->NF      := GetAdvFVal('SD1','D1_DOC',xFilial('SD1')+SC7->(C7_NUM+C7_ITEM+C7_PRODUTO),12)
	TRBMARK->DTNF    := GetAdvFVal('SD1','D1_DTDIGIT',xFilial('SD1')+SC7->(C7_NUM+C7_ITEM+C7_PRODUTO),12)
	MsUnlock()
	
	RestArea(_aAreaSC7)
	SC7->(dbSkip())
	
EndDo

RestArea(_aAreaSC7)

dbSelectArea("TRBMARK")
dbGotop()
MarkBrow("TRBMARK", "OK",, aCampos,, cMarca,"Processa({|| U_EDIAMKTRB() })",,,,"U_EDIMK()", )
dbSelectArea("TRBMARK")
dbCloseArea()
fErase(cNomtrb + GetDBExtension())
fErase(cNomtrb + OrdBagExt())


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNO    ณ EDI_LA00  บ AUTOR ณ AP5 IDE            บ DATA ณ  02/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESCRIO ณ FUNCAO AUXILIAR CHAMADA PELA PROCESSA.  A FUNCAO PROCESSA  บฑฑ
ฑฑบ          ณ MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ PROGRAMA PRINCIPAL                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EDI_LA00()

Local _lOk := .F.
Local contm := 0
Local _aArqPath := {}
Local _aArq := {}

dbSelectArea("TRBMARK")
dbGotop()
While !Eof()
	If IsMark('OK',cMarca)
		contm++
		_lOk :=.T.
	EndIf
	DbSkip()
EndDo
If(contm = 0)
	APMsgStop("Nenhum arquivo foi Selecionado","AVISO")
	Return
EndIf

If !_lOk
	APMsgStop("Nao existem registros marcados para impressใo","AVISO")
	Return
EndIf

Processa({||u_CAVETI2b()})

ApMsgInfo("Processamento Terminado!!!","INFO")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVETIT2  บAutor  ณMicrosiga           บ Data ณ  08/19/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CAVETI2b()

SetPrvt("CCOMBO,AITENS,VQETIQ,VCODIGO")
SetPrvt("VDESC")
SetPrvt("VSAIR,_CPORTA")

cCombo  :="LPT1"
aItens  :={"COM1","COM2","LPT1"}

cPerg := "CAVETI0001"

PutSx1(cPerg,"01","Qtde.Total       ?","","","mv_ch1","N",01,0,0,"C","","","","","mv_par01","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Qtde P/Impressใo ?","","","mv_ch2","N",13,4,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"03","Quantas etiquetas?","","","mv_ch3","C",03,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"04","Porta            ?","","","mv_ch4","N",01,0,0,"C","","","","","mv_par04","COM1","COM1","COM1","","COM2","COM2","COM2","","LPT1","LPT1","LPT1","","","","","",,,,"")

If !Pergunte(cPerg,.T.)
	Return
EndIf

Private nX
Private cPorta := "LPT1"
_nEtiq := 0

If ApMsgYesNo( 'Imprime etiquetas ?', 'Impressora Zebra' )
	
	MSCBPRINTER("ELTRON",cPorta,,,.F.)
	
	dbSelectArea("TRBMARK")
	TRBMARK->(dbGoTop())
	While !Eof()
		_aAreaTRB := GetArea()
		If IsMark('OK',cMarca)
			
			dbSelectArea("SC7")
			dbSetOrder(1)
			dbSeek(xFilial("SC7")+TRBMARK->(TRBMARK->PEDIDO+ITEM))
			
			dbSelectArea("SD1")
			dbSetOrder(12)
			dbSeek(xFilial("SD1")+TRBMARK->(PEDIDO+ITEM+CODIGO))
			
			dbSelectArea("SD4")
			dbSetOrder(1)
			dbSeek(xFilial("SD4")+TRBMARK->(CODIGO+OP))
			
			If mv_par01 == 1 // Imprime apenas 1 etiqueta
				_nEtiq := 1
			Else
				_nEtiq := Val(mv_par03)
			EndIf
			
			For i:=1 to _nEtiq
				
				MSCBBEGIN(1,4,22.6899)
				
				MSCBBOX(55,01,55,18,2,)         // Monta BOX - 1
				
				//		MSCBSAY(06,05,"Codigo ","N","2","1,2")
				MSCBSAYBAR(06,2,Rtrim(SC7->C7_PRODUTO),'N','MB07',05,.F.,.T.,,,2,2)      // Codigo do produto
				//		MSCBSAY(55,05,"Op ","N","2","1,2")
				
				MSCBSAY(35,02,"NF.:","N","1","1,2")
				MSCBSAY(40,02,SD1->D1_DOC,"N","1","1,2")
				
				MSCBSAY(35,06,"Dt.:","N","1","1,2")
				MSCBSAY(40,06,Dtoc(SD1->D1_DTDIGIT),"N","1","1,2")
				
				MSCBSAYBAR(60,2,Rtrim(SC7->C7_OP),'N','MB07',05,.F.,.T.,,,2,2)
				MSCBSAY(06,11,LEFT(Rtrim(GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+TRBMARK->CODIGO,1)),26),"N","1","1,2")
				//		MSCBLineH(06,23,99,23,1,)
				
				MSCBSAY(06,15,"Pedido:","N","1","1,2")
				MSCBSAY(06,18,SC7->C7_NUM,"N","1","1,2")
				
				If mv_par01 == 1 // Imprime quantidade total
					
					MSCBSAY(20,15,"Qtde:","N","1","1,2")
					MSCBSAY(20,18,Str(SC7->C7_QUANT,12,6),"N","1","1,2")
				Else
					
					MSCBSAY(20,15,"Qtde:","N","1","1,2")
					MSCBSAY(20,18,Str(mv_par02,12,4),"N","1","1,2")
				EndIf
				
				MSCBSAY(34,15,"Endereco:","N","1","1,2")
				MSCBSAY(34,18,Rtrim(GetAdvFVal('SB2','B2_LOCALIZ',xFilial('SB2')+TRBMARK->CODIGO,1)),"N","1","1,2")
				
				MSCBSAY(60,15,"Qt.Empenho:","N","1","1,2")
				MSCBSAY(60,18,Str(SD4->D4_QUANT,12,6),"N","1","1,2")
				
				// Final da imagem da etiqueta
				
				MSCBEND()
				
			Next
			
		EndIf
		RestArea(_aAreaTRB)
		TRBMARK->(dbSkip())
		
	EndDo
	
	MSCBCLOSEPRINTER()
	MS_FLUSH()
	
	MsgStop("Fim da impressใo","Impressora Zebra")
	
	MSCBCLOSEPRINTER()
	MS_FLUSH()
	
	
EndIf

If Select("TRBMARK") > 0
	dbCloseArea()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEDIALLTRBบAutor  ณMicrosiga           บ Data ณ  02/06/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava marca em todos os registros validos                    ฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico para Cavanna                                     ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EDIAMKTRB()

Local lMarcar := .f.
nTotal := 0

Begin Sequence

ProcRegua(LastRec()*0.25)

DbGoTop()
While !EoF()
	If !IsMark("OK", cMarca)
		lMarcar := .t.
		Exit
	EndIf
	DbSkip()
EndDo

DbGoTop()
While !EoF()
	IncProc()
	RecLock("TRBMARK",.F.)
	If lMarcar
		If !IsMark("OK", cMarca)
			nTotal++
		EndIf
	Else
		If IsMark("OK", cMarca)
			nTotal--
		EndIf
	EndIf
	
	TRBMARK->OK := If(lMarcar,cMarca,Space(2))
	MsUnlock()
	DbSkip()
EndDo
DbGoTop()
End Sequence

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEDIMK  บAutor  ณMicrosiga              บ Data ณ  02/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava marca no campo                                        ฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico para Cavanna                                     ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EDIMK()

nTotal := 0

Begin Sequence
RecLock("TRBMARK",.F.)
If IsMark("OK", cMarca)
	TRBMARK->OK := Space(2)
	nTotal--
Else
	TRBMARK->OK := cMarca
	nTotal++
EndIf
MsUnLock()
End Sequence

Return

