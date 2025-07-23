#include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ESTRUXL3 บAutor  ณ Microsiga          บ Data ณ  04/04/2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ        Gera a estrutura do produto com seus                บฑฑ
ฑฑบ          ณ respectiva nota de compra e seus impostos para excel  3 ๚ltimas notas fiscais     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Cavanna                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ESTRUXL3()

Local cPerg := 'ESTXL3    '
Local aRegs := {}

Aadd( aRegs, { cPerg,"01","Local de Gravacao ?","","","mv_ch1","C",40,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"02","Nome do Arquivo   ?","","","mv_ch2","C",20,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"03","Produto           ?","","","mv_ch3","C",15,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","" })
Aadd( aRegs, { cPerg,"04","Quantidade        ?","","","mv_ch4","N", 2,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"05","Qtd Notas Fiscais ?","","","mv_ch5","N", 2,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"06","Data limite       ?","","","mv_ch6","D", 8,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })

lValidPerg( aRegs ) 

If Pergunte( cPerg, .T. )
	MsgRun( 'Gerando Planilha da Estrutura', 'Aguarde...', {|| ESTRUXLS3() } )
EndIf

Return                                 

Static Function ESTRUXLS3()

Local aEstru   := {}
Local cProduto := mv_par03
Local nQtd     := mv_par04
Local aCampos  := {}
Local cNomArq  := ""
Local lNota    := .f.

Private nEstru := 0
Private aRecno := {}
Private nNotas := iif(mv_par05<=0,1,mv_par05)

If !ExistCpo("SB1",cProduto)
   Alert("Produto nao cadastrado !!!")
   Return()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria array para gerar arquivo de trabalho                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


AADD(aCampos,{ "PRODUTO"   ,"C",15,0} )
AADD(aCampos,{ "TIPO"      ,"C",02,0} )
AADD(aCampos,{ "DESCRICAO" ,"C",50,0} )
AADD(aCampos,{ "QTD"       ,"N",12,6} )
AADD(aCampos,{ "NIVEL"     ,"N",04,0} )


For xx := 1 to nNotas

 AADD(aCampos,{ "NOTA"+strzero(xx,2)     ,"C",10,0} )
 AADD(aCampos,{ "FORNEC"+strzero(xx,2)   ,"C",40,0} )
 AADD(aCampos,{ "EMISSAO"+strzero(xx,2)  ,"D",08,0} )
 AADD(aCampos,{ "QTD"+strzero(xx,2)      ,"N",12,6} )
 AADD(aCampos,{ "PRUNIT"+strzero(xx,2)   ,"N",14,3} )
 AADD(aCampos,{ "PICMS"+strzero(xx,2)    ,"N",05,2} )
 AADD(aCampos,{ "ICMS"+strzero(xx,2)     ,"N",14,2} )
 AADD(aCampos,{ "PIPI"+strzero(xx,2)     ,"N",05,2} )
 AADD(aCampos,{ "IPI"+strzero(xx,2)      ,"N",14,2} )
 AADD(aCampos,{ "PPIS"+strzero(xx,2)     ,"N",05,2} )
 AADD(aCampos,{ "PIS"+strzero(xx,2)      ,"N",14,2} )
 AADD(aCampos,{ "PCOFINS"+strzero(xx,2)  ,"N",05,2} )
 AADD(aCampos,{ "COFINS"+strzero(xx,2)   ,"N",14,2} )
 AADD(aCampos,{ "PISS"+strzero(xx,2)     ,"N",05,2} )
 AADD(aCampos,{ "ISS"+strzero(xx,2)      ,"N",14,2} )

Next xx

AADD(aCampos,{ "CTUNIT"    ,"N",12,4} )
AADD(aCampos,{ "CTOTAL"     ,"N",12,4} )

cNomArq 	:= CriaTrab(aCampos,.T.)
dbUseArea( .T.,, cNomArq,"EXL", .T. , .F. )

aEstru := Estrut(cProduto) 

For i := 1 To Len(aEstru)

  lNota := .f.
  lNota :=  fVerNotas(aEstru[i,3])

  dbSelectArea("EXL") 
  Reclock("EXL",.T.) 
    EXL->PRODUTO    := aEstru[i,3]
    EXL->TIPO       := posicione("SB1",1,xFilial("SB1")+aEstru[i,3],"B1_TIPO")
    EXL->DESCRICAO  := AllTrim(posicione("SB1",1,xFilial("SB1")+aEstru[i,3],"B1_DESC")) 
    EXL->QTD        := round(nQtd*aEstru[i,4],6)
    EXL->NIVEL      := aEstru[i,1]

    EXL->CTUNIT     := posicione("SB2",1,xFilial("SB2")+aEstru[i,3]+"01","B2_CM1")
    If EXL->CTUNIT <> 0 
      EXL->CTOTAL  := round(EXL->QTD*EXL->CTUNIT,4)
    EndIf

    If lNota
         For xy := 1 to len(aRecno)       
            If xy <= nNotas
               dbSelectArea("SD1") 
               dbGoto(aRecno[xy,1])
  
		        &("EXL->NOTA"+strzero(xy,2))    := SD1->D1_DOC+"/"+SD1->D1_SERIE
        		&("EXL->FORNEC"+strzero(xy,2))  := SD1->D1_FORNECE+"-"+SD1->D1_LOJA+" "+left(alltrim(posicione("SA2",1,xfilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")),30)
		        &("EXL->EMISSAO"+strzero(xy,2)) := SD1->D1_EMISSAO
		        &("EXL->QTD"+strzero(xy,2))     := SD1->D1_QUANT
		        &("EXL->PRUNIT"+strzero(xy,2))  := SD1->D1_VUNIT
        		&("EXL->PICMS"+strzero(xy,2))   := SD1->D1_PICM
		        &("EXL->ICMS"+strzero(xy,2))    := Round(EXL->QTD * (SD1->D1_VALICM/SD1->D1_QUANT),2)
        		&("EXL->PIPI"+strzero(xy,2))    := SD1->D1_IPI
		        &("EXL->IPI"+strzero(xy,2))     := Round(EXL->QTD * (SD1->D1_VALIPI/SD1->D1_QUANT),2)
		        &("EXL->PPIS"+strzero(xy,2))    := SD1->D1_ALQIMP6
    		    &("EXL->PIS"+strzero(xy,2))     := Round(EXL->QTD * (SD1->D1_VALIMP6/SD1->D1_QUANT),2)
		        &("EXL->PCOFINS"+strzero(xy,2)) := SD1->D1_ALQIMP5
		        &("EXL->COFINS"+strzero(xy,2))  := Round(EXL->QTD * (SD1->D1_VALIMP5/SD1->D1_QUANT),2)
		        &("EXL->PISS"+strzero(xy,2))    := SD1->D1_ALIQISS
       			&("EXL->ISS"+strzero(xy,2))     := Round(EXL->QTD * (SD1->D1_VALISS/SD1->D1_QUANT),2)

           EndIf
        
         Next xy

     EndIf

  MsUnlock()

Next

ProcExcel("EXL")

dbSelectArea( "EXL")
dbCloseArea()

Return

Static Function ProcExcel(cAlias)

Local cArqTmp		:= CriaTrab( Nil,.F.)
Local cNomArqDes 	:= ""

dbSelectArea( cAlias )

cArqTemp := "\TEMP\"+AllTrim(mv_par02)
cArqDest := AllTrim(mv_par01)+AllTrim(mv_par02)

Copy To &(cArqTemp)

__CopyFile(cArqTemp+".DBF",cArqDest+".XLS")

If Aviso("Planilha","Foi gerado a planilha "+cArqDest+".XLS com sucesso !!!"+chr(13)+chr(10)+;
          "Deseja abrir a planilha gerada ?",{"Sim","Nใo"}) == 1
   WinExec ("C:\WINDOWS\EXPLORER.EXE "+cArqDest+".XLS")
EndIf

Return

Static Function  fVerNotas(xProduto)

Local lOk    := .f.
aRecno := {}

dbSelectArea("SD1")
dbSetOrder(7)
If dbSeek(xFilial("SD1")+xProduto+"01")
   While !eof() .and. SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_LOCAL == xFilial("SD1")+xProduto+"01"
      If SD1->D1_TIPO == "N"
         If posicione("SF4",1,XFILIAL("SF4")+SD1->D1_TES,"F4_ESTOQUE")  = "S"
           If SD1->D1_DTDIGIT >= MV_PAR06 
		    	aAdd( aRecno, {SD1->(recno())} )
           EndIf
         Endif
      EndIf
      dbSkip()
   End
   If !empty(aRecno)
     ASORT(aRecno,,, { |x,y| x[1] > y[1] })
     lOk := .t.
    Else
     lOk := .f.
   EndIf
Else
   lOk := .f.
EndIf

Return(lOk)
