#include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ESTRUXLS ºAutor  ³ Microsiga          º Data ³  04/04/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³        Gera a estrutura do produto com seus                º±±
±±º          ³ respectiva nota de compra e seus impostos para excel 1 nota fiscal      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cavanna                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ESTRUXLS()

Local cPerg := 'ESTXL1    '
Local aRegs := {}

Aadd( aRegs, { cPerg,"01","Local de Gravacao ?","","","mv_ch1","C",40,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"02","Nome do Arquivo   ?","","","mv_ch2","C",20,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"03","Produto           ?","","","mv_ch3","C",15,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","" })
Aadd( aRegs, { cPerg,"04","Quantidade        ?","","","mv_ch4","N", 2,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"05","Data limite       ?","","","mv_ch5","D", 8,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })

lValidPerg( aRegs ) 

If Pergunte( cPerg, .T. )
	MsgRun( 'Gerando Planilha da Estrutura', 'Aguarde...', {|| ESTRUXLS2() } )
EndIf

Aviso("Atencao","Planilha gerada com sucesso !!!",{"OK"})

Return                                 

Static Function ESTRUXLS2()

Local aEstru   := {}
Local cProduto := mv_par03
Local nQtd     := mv_par04
Local aCampos  := {}
Local cNomArq  := ""
Local lNota    := .f.

Private nEstru := 0

If !ExistCpo("SB1",cProduto)
   Alert("Produto nao cadastrado !!!")
   Return()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria array para gerar arquivo de trabalho                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aCampos,{ "PRODUTO"   ,"C",15,0} )
AADD(aCampos,{ "TIPO"      ,"C",02,0} )
AADD(aCampos,{ "DESCRICAO" ,"C",50,0} )
AADD(aCampos,{ "QTD"       ,"N",12,6} )
AADD(aCampos,{ "NOTA"      ,"C",10,0} )
AADD(aCampos,{ "FORNECEDOR","C",40,0} )
AADD(aCampos,{ "EMISSAO"   ,"D",08,0} )
AADD(aCampos,{ "PICMS"     ,"N",05,2} )
AADD(aCampos,{ "ICMS"      ,"N",14,2} )
AADD(aCampos,{ "PIPI"      ,"N",05,2} )
AADD(aCampos,{ "IPI"       ,"N",14,2} )
AADD(aCampos,{ "PPIS"      ,"N",05,2} )
AADD(aCampos,{ "PIS"       ,"N",14,2} )
AADD(aCampos,{ "PCOFINS"   ,"N",05,2} )
AADD(aCampos,{ "COFINS"    ,"N",14,2} )
AADD(aCampos,{ "PISS"      ,"N",05,2} )
AADD(aCampos,{ "ISS"       ,"N",14,2} )
AADD(aCampos,{ "CTUNIT"    ,"N",12,4} )
AADD(aCampos,{ "CUSTO"     ,"N",12,4} )

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
    EXL->CTUNIT     := posicione("SB2",1,xFilial("SB2")+aEstru[i,3]+"01","B2_CM1")
    If EXL->CTUNIT <> 0 
      EXL->CUSTO := round(nQtd*EXL->CTUNIT,4)
    EndIf
    If lNota
      EXL->NOTA       := SD1->D1_DOC+"/"+SD1->D1_SERIE
      EXL->FORNECEDOR := SD1->D1_FORNECE+"-"+SD1->D1_LOJA+" "+left(alltrim(posicione("SA2",1,xfilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")),30)
      EXL->EMISSAO    := SD1->D1_EMISSAO
      EXL->PICMS      := SD1->D1_PICM
      EXL->ICMS       := Round(EXL->QTD * (SD1->D1_VALICM/SD1->D1_QUANT),2)
      EXL->PIPI       := SD1->D1_IPI
      EXL->IPI        := Round(EXL->QTD * (SD1->D1_VALIPI/SD1->D1_QUANT),2)
      EXL->PPIS       := SD1->D1_ALQIMP6
      EXL->PIS        := Round(EXL->QTD * (SD1->D1_VALIMP6/SD1->D1_QUANT),2)
      EXL->PCOFINS    := SD1->D1_ALQIMP5
      EXL->COFINS     := Round(EXL->QTD * (SD1->D1_VALIMP5/SD1->D1_QUANT),2)
      EXL->PISS       := SD1->D1_ALIQISS
      EXL->ISS        := Round(EXL->QTD * (SD1->D1_VALISS/SD1->D1_QUANT),2)
    Else
      EXL->NOTA       := ""
      EXL->FORNECEDOR := ""
      EXL->EMISSAO    := ctod("")
      EXL->PICMS      := 0
      EXL->ICMS       := 0
      EXL->PIPI       := 0
      EXL->IPI        := 0
      EXL->PPIS       := 0
      EXL->PIS        := 0
      EXL->PCOFINS    := 0
      EXL->COFINS     := 0
      EXL->PISS       := 0
      EXL->ISS        := 0
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

Return

Static Function  fVerNotas(xProduto)

Local lOk    := .f.
Local nRecno := 0

dbSelectArea("SD1")
dbSetOrder(7)
If dbSeek(xFilial("SD1")+xProduto+"01")
   While !eof() .and. SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_LOCAL == xFilial("SD1")+xProduto+"01"
      If SD1->D1_TIPO == "N"
         If posicione("SF4",1,XFILIAL("SF4")+SD1->D1_TES,"F4_ESTOQUE")  = "S"
           If SD1->D1_DTDIGIT >= MV_PAR05 
             //If SD1->D1_VALICM <> 0 .or. SD1->D1_VALISS <> 0
             nRecno := SD1->(recno()) 
            //EndIf
           Endif 
         EndIf
      EndIf
      dbSkip()
   End
   If nRecno <> 0
     dbSelectArea("SD1")
     dbgoto(nRecno)
     lOk := .t.
    Else
     lOk := .f.
   EndIf
Else
   lOk := .f.
EndIf

Return(lOk)