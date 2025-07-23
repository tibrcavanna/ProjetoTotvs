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

PutSx1(cPerg,"01","Produto de        ?","","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Porta             ?","","","mv_ch2","N",1,0,0,"C","","","","","mv_par02","COM1","COM1","COM1","","COM2","COM2","COM2","","LPT1","LPT1","LPT1","","","","","",,,,"")
PutSx1(cPerg,"03","Ordem de Producao ?","","","mv_ch3","C",13,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"04","Qtda Produto      ?","","","mv_ch4","N",13,2,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"05","Quantas etiquetas ?","","","mv_ch5","C",03,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"06","Endereço          ?","","","mv_ch6","C",02,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"07","Nf                ?","","","mv_ch7","C",02,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"08","Dt.digitacao      ?","","","mv_ch8","D",08,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"09","Qtda Empenho      ?","","","mv_ch9","N",13,2,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",,,,"")

If !Pergunte(cPerg,.T.)
	Return
EndIf

Private nX
Private cPorta := "LPT1"

If ApMsgYesNo( 'Imprime etiquetas ?', 'Impressora Zebra' )
	
	//MSCBPRINTER("TLP 2844",cPorta,,,.F.)
	//MCBPRINTER("ZEBRA",cPorta,,,.F.)
	//MSCBPRINTER("ELTRON",cPorta,,,.F.)
	//MSCBPRINTER("ELTRON",cPorta,,120,.F.,,,,,,.T.)
	
	MSCBPRINTER("ELTRON",cPorta,,,.F.)
	
	//cporta := "COM1:9600,N,8,1"
	//MSCBPRINTER("S500-8",cPorta,40,.F.)
	/*/
	For nx:=1 to 5
		MSCBINFOETI("Exemplo 1","MODELO 1")
		MSCBBEGIN(1,1,45)
		MSCBSay(10,06,"ROMANEIO DE ENTREGA","N","A","15,008")
		MSCBBOX(01,01,32,18,5,"B")         // Monta BOX - 1
		MSCBBOX(36,01,68,18,5,"B")         // Monta BOX - 2
		MSCBLineH(01,05,28,03,5,"B")
		MSCBLineH(02,13,76,03,5,"B")
		MSCBLineH(02,20,76,03,5,"B")
		MSCBLineV(01,05,32,05,5,"B")
		MSCBSAY(03,02,"SeuTexto")
		MSCBSAY(03,02,"SeuTexto","N","2","1,2")
		MSCBSAY(08,06,"CODIGO","N","D","015,008")
		MSCBEND()
	Next
	/*/
	
	//	MSCBINFOETI("Exemplo 1","MODELO 1")
	//	MSCBBEGIN(1,6)
	//	MSCBSay(33,03,"ROMANEIO DE ENTREGA","N","2","1,2")
	//	MSCBSayBAR(28,19,"0000012228",'N','MB07',06,.F.,.T.,,,2,2)
	//MSCBBOX(01,01,32,18,5,"B")         // Monta BOX - 1
	
	For nx := 1 to Val(mv_par05)
		//		MSCBINFOETI("Etiqueta cavanna","Almoxarifado")
		//		MSCBBEGIN(1,6,25)
		MSCBBEGIN(1,4,22.5)
		
		//	MSCBSay(10,06,"ROMANEIO DE ENTREGA","N","A","15,008")
		//	MSCBBOX(01,01,32,18,5,"B")         // Monta BOX - 1
		//	MSCBBOX(36,01,68,18,5,"B")         // Monta BOX - 2
		//	MSCBLineH(01,05,28,03,5,"B")
		//	MSCBLineH(02,13,76,03,5,"B")
		//	MSCBLineH(02,20,76,03,5,"B")
		//	MSCBLineV(01,05,32,05,5,"B")
		//	MSCBSAY(08,03,"Produto: ","N","2","1,2")
		//	MSCBSAY(33,03,Rtrim(mv_par01),"N","2","1,2")
		//	MSCBSAYBAR(28,03,Rtrim(mv_par01),'N','MB07',06,.F.,.T.,,,2,2)
		                                        
	    dbSelectArea("SC2")
	    dbSetOrder(6)
	    dbSeek(xFilial("SC2")+mv_par03+mv_par01) 

	    dbSelectArea("SD1")
	    dbSetOrder(12)
	    dbSeek(xFilial("SD1")+SC7->C7_NUM+SC7->C7_ITEM+SC7->C7_PRODUTO) 

		MSCBBOX(55,01,55,18,2,)         // Monta BOX - 1
		
		//		MSCBSAY(06,05,"Codigo ","N","2","1,2")
		MSCBSAYBAR(06,2,Rtrim(mv_par01),'N','MB07',05,.F.,.T.,,,2,2)
		//		MSCBSAY(55,05,"Op ","N","2","1,2")
		
		MSCBSAY(39,02,"NF.:","N","1","1,2")
		MSCBSAY(44,02,mv_par07,"N","1","1,2")
		
		MSCBSAY(39,06,"Dt.:","N","1","1,2")
		MSCBSAY(44,06,Dtoc(mv_par08),"N","1","1,2")
		
		MSCBSAYBAR(60,2,Rtrim(mv_par03),'N','MB07',05,.F.,.T.,,,2,2)
		MSCBSAY(06,11,Rtrim(GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+mv_par01,1)),"N","1","1,2")
		//		MSCBLineH(06,23,99,23,1,)
		
		MSCBSAY(06,15,"Pedido:","N","1","1,2")
		MSCBSAY(06,18,"000000","N","1","1,2")
		
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

/*/

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
If SB1->(dbSeek(xFilial("SB1")+mv_par01))
	While SB1->(!Eof())
		
		IF SB1->B1_COD > mv_par02
			EXIT
		endif
		
		If   cCombo =="COM1"
			_cPorta := "COM1:9600,e,8,1"
		ElseIf cCombo =="COM2"
			_cPorta := "COM2:9600,e,8,1"
		ElseIf cCombo =="LPT1"
			//	_cPorta := "LPT1:9600,e,7,2"
			_cPorta := "LPT1:9600,N,8,1"
		EndIf
		
		MSCBPRINTER("Z90Xi",_cPorta,Nil,020)
		MSCBCHKStatus(.f.)
		MSCBBEGIN(1,4)
		
		MSCBWRITE("^FO085,040^ADN,080,025^FD"+SB1->B1_COD+"^FS")
		MSCBWRITE("^FO032,115^ADN,016,010^FD"+alltrim(SB1->B1_ESPECIF)+"^FS")
		MSCBWRITE("^XZ")
		MSCBWRITE(" ")
		
		//MSGALERT(SB1->B1_COD)
		
		MSCBEND()
		MSCBCLOSEPRINTER()
		
		SB1->(DbSkip())
	EndDo
EndIf
/*/

Return
