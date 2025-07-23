#INCLUDE "rwmake.ch"

User Function PlanPc 

Local cPerg := 'PLANPC    '  

Private cArqTRB := ""
Private cIndTRB := ""

ValidPerg(cPerg)

If Pergunte( cPerg, .T. )
	MsgRun( 'Gerando Planilha de Compras', 'Aguarde...', {|| PRCPLAN() } )
EndIf


Return                                 


Static Function PrcPlan()

Local aNotas := {}


CriaArqTrb() 

dbSelectArea("SC7") 
dbSetOrder(5)
dbseek(xFilial("SC7")+dtos(mv_par03),.t.)

While !eof() .and. dtos(C7_EMISSAO  )>= dtos(mv_par03) .and. dtos(C7_EMISSAO  )<= dtos(mv_par04)


  If  C7_PRODUTO>= mv_par05 .and. C7_PRODUTO<=mv_par06 .And. ;
      C7_USER>=mv_par07 .and. C7_USER<=mv_par08 ;
      .and. C7_TIPO = 1 .And. C7_QUJE <> 0 


   aNotas := VerNotas(SC7->C7_NUM,SC7->C7_ITEM,SC7->C7_PRODUTO)

   dbSelectArea("TRB") 
   Reclock("TRB",.t.) 
    TRB->PEDIDO    := SC7->C7_NUM
    TRB->EMISSAO   := SC7->C7_EMISSAO
    TRB->PRODUTO   := SC7->C7_PRODUTO
    TRB->TIPO      := POSICIONE("SB1",1,XFILIAL("SB1")+SC7->C7_PRODUTO,"B1_TIPO")
    TRB->DESCRICAO := SC7->C7_DESCRI
    TRB->QTD       := SC7->C7_QUANT
    TRB->VLRUNI    := SC7->C7_PRECO
    TRB->VLRTOT    := SC7->C7_TOTAL
    TRB->ENTREGA   := SC7->C7_DATPRF
    TRB->COMPRADOR := UsrRetName(SC7->C7_USER)
    TRB->RESIDUO   := IIF(!EMPTY(SC7->C7_RESIDUO),"SIM","NAO")
    TRB->NOTA      := aNotas[1]
    TRB->EMISSNF   := aNotas[2]
    TRB->QTDNF     := aNotas[3]
    TRB->VLRUNF    := aNotas[4]
    TRB->VLRTNF    := aNotas[5]
    TRB->ENTRADA   := aNotas[6]
    TRB->DIAS      := iif(!empty(TRB->ENTRADA),TRB->ENTRADA-TRB->ENTREGA,ddatabase-TRB->ENTREGA)
  MsUnlock()

 EndIf

 dbSelectArea("SC7")  
 dbSkip()


End

dbSelectArea("SC7") 
dbSetOrder(1)


dbSelectArea("SD1") 
dbSetOrder(1)


ProcExcel("TRB")  


Return


Static Function ProcExcel(cAlias)

Local cArqTmp	  := CriaTrab( Nil,.F.)
Local cPatch      := Upper(Alltrim(iif(empty(mv_par01),"C:\CAVANNA\",mv_par01)))
Local cArquivo    := Upper(Alltrim(iif(empty(mv_par02),"PLANPC",mv_par02)))
Local cArqDest    := ""
Local cDirDocs    := MsDocPath()

cPatch    += If(Right(cPatch,1) <> "\","\","")
cArqDest  := Upper(AllTrim(cPatch)+AllTrim(cArquivo))

dbSelectArea(cAlias) 
dbclosearea(cAlias)

If !File( cPatch+"*.*" )
	If Aviso( "Diretório inválido", "O diretório "+cPatch+" de destino não existe !!"+chr(13)+chr(10)+;
	          "Deseja criar o diretorio agora ?", {"Sim","Não"} ) == 1
      MakeDir(Trim(cPatch))
    Else
	   Return nil
   EndIf
Endif

__CopyFile(cDirDocs + "\" + cArqTRB + ".DBF",cArqDest+".XLS") 

Ferase( cDirDocs + "\" + cArqTRB + ".DBF" )

If Aviso("Planilha","Foi gerado a planilha "+cArqDest+".XLS com sucesso !!!"+chr(13)+chr(10)+;
          "Deseja abrir a planilha gerada ?",{"Sim","Não"}) == 1

   If !ApOleClient( 'MsExcel' ) 
     	MsgStop( 'MS-Excel nao instalado' )
	    Ferase( cDirDocs + "\" + cArqTRB + ".DBF" )
	    Return( Nil )
   EndIf

   oExcelApp := MsExcel():New()
   oExcelApp:WorkBooks:Open( cArqDest+".XLS" ) 
   oExcelApp:SetVisible(.T.)

EndIf

Return


Static Function VerNotas(cPedido,cItem,cProduto)

Local aRetorno := {"",ctod(""),0,0,0,ctod("")}
Local aArea    := getarea()
Local cNota    := ""
Local dEmissao := ctod("")
Local nQtd     := 0
Local nTotal   := 0
Local dEntrega := ctod("")

dbSelectArea("SD1")
dbSetorder(11)
If dbseek(xfilial("SD1")+cPedido+cItem+cProduto)

   While !eof() .and. xfilial("SD1")+cPedido+cItem+cProduto = SD1->D1_FILIAL+SD1->D1_PEDIDO+SD1->D1_ITEMPC+SD1->D1_COD

      cNota    := SD1->D1_DOC
      dEmissao := SD1->D1_EMISSAO
      nQtd     += SD1->D1_QUANT
      nTotal   += SD1->D1_TOTAL
      dEntrega := SD1->D1_DTDIGIT

      dbSelectArea("SD1")
      dbSkip()

   End

EndIf

aRetorno[1] := cNota
aRetorno[2] := dEmissao
aRetorno[3] := nQtd
aRetorno[4] := Round(nTotal/nQtd,2)
aRetorno[5] := nTotal
aRetorno[6] := dEntrega


RestArea(aArea)

Return(aRetorno)


Static Function CriaArqTrb()

Local aCampos    := {}
Local cChave     := ""
Local cDirDocs   := MsDocPath()


AADD(aCampos,{ "PEDIDO"    ,"C",06,0} )
AADD(aCampos,{ "EMISSAO"   ,"D",08,0} )
AADD(aCampos,{ "PRODUTO"   ,"C",15,0} )
AADD(aCampos,{ "TIPO"      ,"C",02,0} )
AADD(aCampos,{ "DESCRICAO" ,"C",50,0} )
AADD(aCampos,{ "QTD"       ,"N",12,6} )
AADD(aCampos,{ "VLRUNI"    ,"N",14,2} )
AADD(aCampos,{ "VLRTOT"    ,"N",14,2} )
AADD(aCampos,{ "ENTREGA"   ,"D",08,0} )
AADD(aCampos,{ "COMPRADOR" ,"C",15,0} )
AADD(aCampos,{ "NOTA"      ,"C",09,0} )
AADD(aCampos,{ "EMISSNF"   ,"D",08,0} )
AADD(aCampos,{ "QTDNF"     ,"N",12,6} )
AADD(aCampos,{ "VLRUNF"    ,"N",14,2} )
AADD(aCampos,{ "VLRTNF"    ,"N",14,2} )
AADD(aCampos,{ "ENTRADA"   ,"D",08,0} )
AADD(aCampos,{ "DIAS"      ,"N",05,0} )
AADD(aCampos,{ "RESIDUO"   ,"C",03,0} )


cChave  := "PEDIDO+DTOS(EMISSAO)+PRODUTO"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria e Abre o Arquivo de Trabalho.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cArqTRB := CriaTrab(nil, .f.)
dbCreate( cDirDocs + "\" + cArqTRB , aCampos, "DBFCDXADS")
dbUseArea( .T.,"DBFCDXADS", cDirDocs + "\" + cArqTRB, "TRB", .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Temporario do Arquivo de Trabalho.               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIndTRB := CriaTrab(Nil, .F.)

IndRegua("TRB",cIndTRB,cChave,,,"Criando Indice...")                 


Return


Static Function ValidPerg(cPerg)

_sAlias := Alias()
aRegs := {}
i := j := 0

dbSelectArea("SX1")
dbSetOrder(1)
//cPerg := PADR(cPerg,6)

//GRUPO,ORDEM,PERGUNTA              ,PERGUNTA,PERGUNTA,VARIAVEL,TIPO,TAMANHO,DECIMAL,PRESEL,GSC,VALID,VAR01,DEF01,DEFSPA01,DEFING01,CNT01,VAR02,DEF02,DEFSPA02,DEFING02,CNT02,VAR03,DEF03,DEFSPA03,DEFING03,CNT03,VAR04,DEF04,DEFSPA04,DEFING04,CNT04,VAR05,DEF05,DEFSPA05,DEFING05,CNT05,F3,GRPSXG
Aadd(aRegs,{cPerg,"01","Local de Gravacao ?","","","mv_ch1","C",40,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
Aadd(aRegs,{cPerg,"02","Nome do Arquivo   ?","","","mv_ch2","C",20,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","" })
aAdd(aRegs,{cPerg,"03","Emissao  de         ","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Emissao  Ate        ","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Produto  de         ","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"06","Produto  Ate        ","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"07","Usuario  de         ","","","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","USR"})
aAdd(aRegs,{cPerg,"08","Usuario  Ate        ","","","mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","USR"})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(_sAlias)

Return