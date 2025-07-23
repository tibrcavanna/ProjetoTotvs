#include "rwmake.ch"

*******************
User Function CAVETIT01()
*******************

SetPrvt("CCOMBO,AITENS,VQETIQ,VCODIGO")
SetPrvt("VDESC")
SetPrvt("VSAIR,_CPORTA")

cCombo  :="LPT1"
aItens  :={"COM1","COM2","LPT1"}

vQetiq      := 0001

vSair       := .f.

vCodigo     := Space(15)
vCodigoAte  := Space(15)

/*/
While vSair == .f.
	'
	@ 3,1 TO 270,460 DIALOG oDlg1 TITLE "Etiqueta Almoxarifado ZEBRA"
	
	@ 05,003 To 30,227
	
	
	@ 14,005 Say "Porta:"
	@ 14,025 ComboBox cCombo Items aItens  SIZE 30,50
	
	@ 37,005 Say "Codigo de  :"
	@ 35,035 Get  VCodigo                  SIZE 50,20 Pict "@!"  F3("SB1") Valid Verif_Prod(vCodigo)
	@ 37,100 Say "Codigo Ate :"
	@ 35,130 Get  VCodigoAte               SIZE 50,20 Pict "@!"  F3("SB1") Valid Verif_Prod(vCodigoAte)
	
	@ 090,003 To 125,227
	
	@ 100,150 BUTTON "_Imprimir"   SIZE 30,20 ACTION Impetiq()
	@ 100,190 BUTTON "_Sair"       SIZE 30,20 ACTION sair()
	
	ACTIVATE DIALOG oDlg1 CENTERED
end
/*/

cPerg := "CAVETI0001"

PutSx1(cPerg,"01","Ped.Compra        ?","","","mv_ch1","C",06,2,0,"G","","SC7","","","mv_par01","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Qtda Produto      ?","","","mv_ch2""N",13,2,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"03","Quantas etiquetas ?","","","mv_ch3","C",03,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"04","Porta             ?","","","mv_ch4","N",1,0,0,"C","","","","","mv_par04","COM1","COM1","COM1","","COM2","COM2","COM2","","LPT1","LPT1","LPT1","","","","","",,,,"")

If !Pergunte(cPerg,.T.)
	Return
EndIf

Private nX
Private cPorta := "LPT1"

If ApMsgYesNo( 'Imprime etiquetas ?', 'Impressora Zebra' )
	
	MSCBPRINTER("ELTRON",cPorta,,,.F.)

	For nx := 1 to Val(mv_par05)
		//		MSCBINFOETI("Etiqueta cavanna","Almoxarifado")
		//		MSCBBEGIN(1,6,25)  

	    dbSelectArea("SC7")
	    dbSetOrder(4)
	    dbSeek(xFilial("SC7")+mv_par02+mv_par01) // PRODUTO + PEDIDO DE COMPRA
		
	    dbSelectArea("SC2")
	    dbSetOrder(6)
	    dbSeek(xFilial("SC2")+Rtrim(mv_par03)+Rtrim(mv_par02)) // OP + PRODUTO
		                                                 
	    dbSelectArea("SD1")
	    dbSetOrder(12)
	    dbSeek(xFilial("SD1")+SC7->C7_NUM+SC7->C7_ITEM+SC7->C7_PRODUTO) 
		
		MSCBBEGIN(1,4,22.5)
	
		MSCBBOX(55,01,55,18,2,)         // Monta BOX - 1
		
		//		MSCBSAY(06,05,"Codigo ","N","2","1,2")
		MSCBSAYBAR(06,2,Rtrim(mv_par02),'N','MB07',05,.F.,.T.,,,2,2)
		//		MSCBSAY(55,05,"Op ","N","2","1,2")
		
		MSCBSAY(39,02,"NF.:","N","1","1,2")
		MSCBSAY(44,02,SD1->D1_DOC,"N","1","1,2")
		
		MSCBSAY(39,06,"Dt.:","N","1","1,2")
		MSCBSAY(44,06,Dtoc(SD1->D1_DTDIGIT),"N","1","1,2")
		
		MSCBSAYBAR(60,2,Rtrim(mv_par03),'N','MB07',05,.F.,.T.,,,2,2)
		MSCBSAY(06,11,Rtrim(GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+mv_par02,1)),"N","1","1,2")
		//		MSCBLineH(06,23,99,23,1,)
		
		MSCBSAY(06,15,"Pedido:","N","1","1,2")
		MSCBSAY(06,18,mv_par01,"N","1","1,2")
		
		MSCBSAY(20,15,"Qtde:","N","1","1,2")
		MSCBSAY(20,18,Str(mv_par04,12,2),"N","1","1,2")

		MSCBSAY(34,15,"Endereco:","N","1","1,2")                             
		
		MSCBSAY(34,18,Rtrim(GetAdvFVal('SB2','B2_LOCALIZ',xFilial('SB2')+mv_par01,1)),"N","1","1,2")		
        
		MSCBSAY(60,15,"Qt.Empenho:","N","1","1,2")
		MSCBSAY(60,18,Str(mv_par09,12,2),"N","1","1,2")
		
		// Final da imagem da etiqueta
		MSCBEND()
		
	Next
	
	MSCBCLOSEPRINTER()
	MS_FLUSH()
	
	MsgStop("Fim da impressão","Impressora Zebra")
	
EndIf

Return