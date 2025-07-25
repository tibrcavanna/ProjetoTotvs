#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
������������������������������������������������'�������������������������ͻ��
���Programa  �CAVETI05  �Autor  �Microsiga           � Data �  08/19/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Impress�o de etiquetas ZEBRA x Ordens de producao           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CAVETIT5()

Private L120AUTO := .f.
Private NTIPOPED := 1
Private nFuncao := 1

PRIVATE cCadastro := "Produtos"
//IVATE l120Auto  := ( ValType(xAutoCab)=="A" .And. ValType(xAutoItens) == "A" )

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","A120Pedido"	,0,2} ,;
{"Etiqueta","u_CAVETI5a()",0,3}} // ,;
//{"Alterar","AxAltera",0,4}}

//aAdd(aRotina, { OemToAnsi(STR0007),"A120Pedido"	, 0 , 2})	//"Visualizar"

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private cString := "SB1"

dbSelectArea("SB1")
dbSetOrder(1)

//���������������������������������������������������������������������Ŀ
//� Executa a funcao MBROWSE. Sintaxe:                                  �
//�                                                                     �
//� mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              �
//� Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   �
//�                        exibido. Para seguir o padrao da AXCADASTRO  �
//�                        use sempre 6,1,22,75 (o que nao impede de    �
//�                        criar o browse no lugar desejado da tela).   �
//�                        Obs.: Na versao Windows, o browse sera exibi-�
//�                        do sempre na janela ativa. Caso nenhuma este-�
//�                        ja ativa no momento, o browse sera exibido na�
//�                        janela do proprio SIGAADV.                   �
//� Alias                - Alias do arquivo a ser "Browseado".          �
//� aCampos              - Array multidimensional com os campos a serem �
//�                        exibidos no browse. Se nao informado, os cam-�
//�                        pos serao obtidos do dicionario de dados.    �
//�                        E util para o uso com arquivos de trabalho.  �
//�                        Segue o padrao:                              �
//�                        aCampos := { {<CAMPO>,<DESCRICAO>},;         �
//�                                     {<CAMPO>,<DESCRICAO>},;         �
//�                                     . . .                           �
//�                                     {<CAMPO>,<DESCRICAO>} }         �
//�                        Como por exemplo:                            �
//�                        aCampos := { {"TRB_DATA","Data  "},;         �
//�                                     {"TRB_COD" ,"Codigo"} }         �
//� cCampo               - Nome de um campo (entre aspas) que sera usado�
//�                        como "flag". Se o campo estiver vazio, o re- �
//�                        gistro ficara de uma cor no browse, senao fi-�
//�                        cara de outra cor.                           �
//�����������������������������������������������������������������������

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVETI4a  �Autor  �Microsiga           � Data �  08/19/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Especifico para Cavanna                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CAVETI5a()

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
{ "DESC"	,,  "Descri��o"},;
{ "ITEM"	,,  "Item"},;
{ "CODIGO"	,,  "Codigo"},;
{ "UM"	    ,,  "Unidade"},;     
{ "QUANT"	,,  "Quantidade",'@E 999,999,999.999999'},;     
{ "ENDERECO",,  "Endere�o"},;     
{ "QTEMP"	,,  "Qt.Empenho",'@E 999,999,999.999999'},;     
{ "OP"   	,,  "Ord.producao"},;
{ "NF"   	,,  "Nota fiscal"},;
{ "DTNF"   	,,  "Dt.Nf.Digit."}}

Local oMark
Local obs
Local cNomtrb  := CriaTrab(aCpos)
dbUseArea( .T.,,cNomTrb,"TRBMARK",.F. )

Private cCadastro := "Impress�o de etiquetas x ordens de produ��o"
Private aRotina	  := { { "Imprime", 'u_EDI_L2', 3, } }
Private lInverte := .f.
Private cMarca    := GetMark()
Private avMarca   := GetMark()
Private CEOL    := "CHR(13)+CHR(10)"
Private cArqTXT
Private _cArquivo
Private _aFiles := " "

_aAreaSB1 := GetArea()

_cNum := SB1->B1_NUM
dbSelectArea("SB1")
dbGotop()
dbSeek(xFilial("SB1")+_cNum)

While !Eof() .And. SB1->B1_NUM == _cNum
	
	dbSelectArea("TRBMARK")                                         
	RecLock("TRBMARK",.T.)
	TRBMARK->PEDIDO  := SB1->B1_NUM
//	TRBMARK->DESC    := SB1->B1_DESCRI
//	TRBMARK->ITEM    := SB1->B1_ITEM
	TRBMARK->CODIGO  := SB1->B1_PRODUTO
	TRBMARK->UM      := SB1->B1_UM
	TRBMARK->QUANT   := SB1->B1_QTDVEN
	TRBMARK->ENDERECO:= GetAdvFVal('SB2','B2_LOCALIZ',xFilial('SB2')+SB1->B1_PRODUTO,1)   
//	TRBMARK->QTEMP   := GetAdvFVal('SD4','D4_QUANT',xFilial('SD4')+SB1->(B1_PRODUTO+B1_OP),1) 
//	TRBMARK->OP      := SB1->B1_OP
//	TRBMARK->NF      := GetAdvFVal('SD1','D1_DOC',xFilial('SD1')+SB1->(B1_NUM+B1_ITEM+B1_PRODUTO),12) 
//	TRBMARK->DTNF    := GetAdvFVal('SD1','D1_DTDIGIT',xFilial('SD1')+SB1->(B1_NUM+B1_ITEM+B1_PRODUTO),12)
	MsUnlock()
	
	SB1->(dbSkip())
	
EndDo

dbSelectArea("TRBMARK")
dbGotop()
MarkBrow("TRBMARK", "OK",, aCampos,, cMarca,"Processa({|| U_EDI_L() })",,,,"U_EDI_M2()", )
dbSelectArea("TRBMARK")
dbCloseArea()
fErase(cNomtrb + GetDBExtension())
fErase(cNomtrb + OrdBagExt())

RestArea(_aAreaSB1)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���FUN��O    � EDI_L2  � AUTOR � AP5 IDE            � DATA �  02/09/04   ���
�������������������������������������������������������������������������͹��
���DESCRI��O � FUNCAO AUXILIAR CHAMADA PELA PROCESSA.  A FUNCAO PROCESSA  ���
���          � MONTA A JANELA COM A REGUA DE PROCESSAMENTO.               ���
�������������������������������������������������������������������������͹��
���USO       � PROGRAMA PRINCIPAL                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function EDI_L2()

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
	APMsgStop("Nao existem registros marcados para impress�o","AVISO")
	Return
EndIf

Processa({||u_CAVETI2b()})

ApMsgInfo("Processamento Terminado!!!","INFO")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVETI5b  �Autor  �Microsiga           � Data �  08/19/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CAVETI5b()

SetPrvt("CCOMBO,AITENS,VQETIQ,VCODIGO")
SetPrvt("VDESC")
SetPrvt("VSAIR,_CPORTA")

cCombo  :="LPT1"
aItens  :={"COM1","COM2","LPT1"}

cPerg := "CAVETI0001"

PutSx1(cPerg,"01","Qtde.Total       ?","","","mv_ch1","N",01,0,0,"C","","","","","mv_par01","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Qtde P/Impress�o ?","","","mv_ch2","N",13,4,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",,,,"")
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

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+TRBMARK->(TRBMARK->PEDIDO+ITEM))

			dbSelectArea("SD1")
			dbOrderNickName("PEDITSD1")
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
				
				MSCBBEGIN(1,4,22.5)
				
				MSCBBOX(55,01,55,18,2,)         // Monta BOX - 1
				
				//		MSCBSAY(06,05,"Codigo ","N","2","1,2")
				MSCBSAYBAR(06,2,Rtrim(SB1->B1_PRODUTO),'N','MB07',05,.F.,.T.,,,2,2)      // Codigo do produto
				//		MSCBSAY(55,05,"Op ","N","2","1,2")
				
				MSCBSAY(35,02,"NF.:","N","1","1,2")
				MSCBSAY(40,02,SD1->D1_DOC,"N","1","1,2")
				
				MSCBSAY(35,06,"Dt.:","N","1","1,2")
				MSCBSAY(40,06,Dtoc(SD1->D1_DTDIGIT),"N","1","1,2")
				
				MSCBSAYBAR(60,2,Rtrim(SB1->B1_OP),'N','MB07',05,.F.,.T.,,,2,2)
				MSCBSAY(06,11,LEFT(Rtrim(GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+TRBMARK->CODIGO,1)),26),"N","1","1,2")
				//		MSCBLineH(06,23,99,23,1,)
				
				MSCBSAY(06,15,"Pedido:","N","1","1,2")
				MSCBSAY(06,18,SB1->B1_NUM,"N","1","1,2")
				
				If mv_par01 == 1 // Imprime quantidade total
					
					MSCBSAY(20,15,"Qtde:","N","1","1,2")
					MSCBSAY(20,18,Str(SB1->B1_QTDVEN,12,6),"N","1","1,2")
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
	
	MsgStop("Fim da impress�o","Impressora Zebra")
	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIAM1    �Autor  �Microsiga           � Data � 02/06/09    ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava marca em todos os registros validos                  ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico para Cavanna                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EDIAM2()

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EDIM2     �Autor  �Microsiga           � Data �  02/06/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Grava marca no campo                                        �
�������������������������������������������������������������������������͹��
���Uso       � Especifico para Cavanna                                     ��
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EDI_M2()

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

