#include 'rwmake.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ESTRUXL3 ºAutor  ³ Microsiga          º Data ³  04/04/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³        Gera a estrutura do produto com seus                º±±
±±º          ³ respectiva nota de compra e seus impostos para excel  3 últimas notas fiscais     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cavanna                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ESTRUXL3()

Local cPerg := 'ESTXLS'
Local aRegs := {}

Aadd( aRegs, { cPerg,"01","Local de Gravacao ?","","","mv_ch1","C",40,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"02","Nome do Arquivo   ?","","","mv_ch2","C",20,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd( aRegs, { cPerg,"03","Produto           ?","","","mv_ch3","C",15,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","","","" })
Aadd( aRegs, { cPerg,"04","Quantidade        ?","","","mv_ch4","N", 2,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })

lValidPerg( aRegs ) 

If Pergunte( cPerg, .T. )
	MsgRun( 'Gerando Planilha da Estrutura', 'Aguarde...', {|| ESTRUXLS3() } )
EndIf

Aviso("Atencao","Planilha gerada com sucesso !!!",{"OK"})

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
AADD(aCampos,{ "PRUNIT1"    ,"N",14,3} )
AADD(aCampos,{ "PRUNIT2"    ,"N",14,3} )
AADD(aCampos,{ "PRUNIT3"    ,"N",14,3} )
//AADD(aCampos,{ "CUSTO1"    ,"N",14,2} )
//AADD(aCampos,{ "CUSTO2"    ,"N",14,2} )
//AADD(aCampos,{ "CUSTO3"    ,"N",14,2} )
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



AADD(aCampos,{ "NOTA2"      ,"C",10,0} )
AADD(aCampos,{ "FORNEC2","C",40,0} )
AADD(aCampos,{ "EMISSAO2"   ,"D",08,0} )
AADD(aCampos,{ "PICMS2"     ,"N",05,2} )
AADD(aCampos,{ "ICMS2"      ,"N",14,2} )
AADD(aCampos,{ "PIPI2"      ,"N",05,2} )
AADD(aCampos,{ "IPI2"       ,"N",14,2} )
AADD(aCampos,{ "PPIS2"      ,"N",05,2} )
AADD(aCampos,{ "PIS2"       ,"N",14,2} )
AADD(aCampos,{ "PCOFINS2"   ,"N",05,2} )
AADD(aCampos,{ "COFINS2"    ,"N",14,2} )
AADD(aCampos,{ "PISS2"      ,"N",05,2} )
AADD(aCampos,{ "ISS2"       ,"N",14,2} )


AADD(aCampos,{ "NOTA3"      ,"C",10,0} )
AADD(aCampos,{ "FORNEC3","C",40,0} )
AADD(aCampos,{ "EMISSAO3"   ,"D",08,0} )
AADD(aCampos,{ "PICMS3"     ,"N",05,2} )
AADD(aCampos,{ "ICMS3"      ,"N",14,2} )
AADD(aCampos,{ "PIPI3"      ,"N",05,2} )
AADD(aCampos,{ "IPI3"       ,"N",14,2} )
AADD(aCampos,{ "PPIS3"      ,"N",05,2} )
AADD(aCampos,{ "PIS3"       ,"N",14,2} )
AADD(aCampos,{ "PCOFINS3"   ,"N",05,2} )
AADD(aCampos,{ "COFINS3"    ,"N",14,2} )
AADD(aCampos,{ "PISS3"      ,"N",05,2} )
AADD(aCampos,{ "ISS3"       ,"N",14,2} )


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
      If len(aRecno) >= 1
        dbSelectArea("SD1") 
        dbGoto(aRecno[1,1])
        
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
        EXL->PRUNIT1  := SD1->D1_VUNIT
        //EXL->CUSTO1  := SD1->D1_CUSTO
      
      EndIf
      If len(aRecno) >= 2
        dbSelectArea("SD1") 
        dbGoto(aRecno[2,1])
        
        EXL->NOTA2       := SD1->D1_DOC+"/"+SD1->D1_SERIE
        EXL->FORNEC2     := SD1->D1_FORNECE+"-"+SD1->D1_LOJA+" "+left(alltrim(posicione("SA2",1,xfilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")),30)
        EXL->EMISSAO2    := SD1->D1_EMISSAO
        EXL->PICMS2      := SD1->D1_PICM
        EXL->ICMS2       := Round(EXL->QTD * (SD1->D1_VALICM/SD1->D1_QUANT),2)
        EXL->PIPI2       := SD1->D1_IPI
        EXL->IPI2        := Round(EXL->QTD * (SD1->D1_VALIPI/SD1->D1_QUANT),2)
        EXL->PPIS2       := SD1->D1_ALQIMP6
        EXL->PIS2        := Round(EXL->QTD * (SD1->D1_VALIMP6/SD1->D1_QUANT),2)
        EXL->PCOFINS2    := SD1->D1_ALQIMP5
        EXL->COFINS2     := Round(EXL->QTD * (SD1->D1_VALIMP5/SD1->D1_QUANT),2)
        EXL->PISS2       := SD1->D1_ALIQISS
        EXL->ISS2        := Round(EXL->QTD * (SD1->D1_VALISS/SD1->D1_QUANT),2)
        EXL->PRUNIT2   := SD1->D1_VUNIT
        //EXL->CUSTO2   := SD1->D1_CUSTO
      
      EndIf

      If len(aRecno) >= 3
        dbSelectArea("SD1") 
        dbGoto(aRecno[3,1])
        
        EXL->NOTA3       := SD1->D1_DOC+"/"+SD1->D1_SERIE
        EXL->FORNEC3     := SD1->D1_FORNECE+"-"+SD1->D1_LOJA+" "+left(alltrim(posicione("SA2",1,xfilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")),30)
        EXL->EMISSAO3    := SD1->D1_EMISSAO
        EXL->PICMS3      := SD1->D1_PICM
        EXL->ICMS3       := Round(EXL->QTD * (SD1->D1_VALICM/SD1->D1_QUANT),2)
        EXL->PIPI3       := SD1->D1_IPI
        EXL->IPI3        := Round(EXL->QTD * (SD1->D1_VALIPI/SD1->D1_QUANT),2)
        EXL->PPIS3       := SD1->D1_ALQIMP6
        EXL->PIS3        := Round(EXL->QTD * (SD1->D1_VALIMP6/SD1->D1_QUANT),2)
        EXL->PCOFINS3    := SD1->D1_ALQIMP5
        EXL->COFINS3     := Round(EXL->QTD * (SD1->D1_VALIMP5/SD1->D1_QUANT),2)
        EXL->PISS3       := SD1->D1_ALIQISS
        EXL->ISS3        := Round(EXL->QTD * (SD1->D1_VALISS/SD1->D1_QUANT),2)
        EXL->PRUNIT3    := SD1->D1_VUNIT
        //EXL->CUSTO3  := SD1->D1_CUSTO
      
      EndIf

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
      EXL->PRUNIT1   := 0      
      //EXL->CUSTO1   := 0      

      EXL->NOTA2       := ""
      EXL->FORNEC2     := ""
      EXL->EMISSAO2    := ctod("")
      EXL->PICMS2      := 0
      EXL->ICMS2       := 0
      EXL->PIPI2       := 0
      EXL->IPI2        := 0
      EXL->PPIS2       := 0
      EXL->PIS2        := 0
      EXL->PCOFINS2    := 0
      EXL->COFINS2     := 0
      EXL->PISS2       := 0
      EXL->ISS2        := 0
      EXL->PRUNIT2    := 0
      //EXL->CUSTO2   := 0 
      
      EXL->NOTA3       := ""
      EXL->FORNEC3     := ""
      EXL->EMISSAO3    := ctod("")
      EXL->PICMS3      := 0
      EXL->ICMS3       := 0
      EXL->PIPI3       := 0
      EXL->IPI3        := 0
      EXL->PPIS3       := 0
      EXL->PIS3        := 0
      EXL->PCOFINS3    := 0
      EXL->COFINS3     := 0
      EXL->PISS3       := 0
      EXL->ISS3        := 0
      EXL->PRUNIT3    := 0
      //EXL->CUSTO3   := 0    
   
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
aRecno := {}

dbSelectArea("SD1")
dbSetOrder(7)
If dbSeek(xFilial("SD1")+xProduto+"01")
   While !eof() .and. SD1->D1_FILIAL+SD1->D1_COD+SD1->D1_LOCAL == xFilial("SD1")+xProduto+"01"
      If SD1->D1_TIPO == "N"
         If SD1->D1_VALICM <> 0 .or. SD1->D1_VALISS <> 0
			aAdd( aRecno, {SD1->(recno())} )
         EndIf
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
