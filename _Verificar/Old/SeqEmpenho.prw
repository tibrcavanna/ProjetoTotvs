#include "prothesp.ch"
#INCLUDE "rwmake.ch"

//Rotina para verificar nas requisicoes as sequencias dos empenhos

User Function SeqEmpenho(cProduto,cOP)

LOCAL nX
LOCAL cCad  := OemToAnsi("Sequencia de Empenhos") 
LOCAL cAlias:= Alias()
LOCAL oOk := LoadBitmap( GetResources(), "LBOK" )
LOCAL oNo := LoadBitmap( GetResources(), "LBNO" )
LOCAL oQual
LOCAL cVar := "  "
LOCAL nOpca
LOCAL oDlgt
LOCAL aSeqBack:={}
LOCAL aSeq:={}
Local lRunDblClick := .T.
Local nReg := 0
Local bAcao
Local cSeq :=""

If empty(cProduto) .or. Empty(cOP)
  If Select("TEMP") > 0
   TEMP->(dbCloseArea())
  End
  DeleteObject(oOk)
  DeleteObject(oNo)
  dbSelectArea(cAlias)
  Return(cSeq)
EndIf

If Select("TEMP") > 0
  TEMP->(dbCloseArea())
End

BeginSql Alias 'TEMP'
	SELECT R_E_C_N_O_ RECNO, D4_COD COMP,D4_QUANT QTD,D4_TRT SEQ
	FROM %Table:SD4% SD4
      WHERE D4_COD = %Exp:cProduto%
        AND D4_OP = %Exp:cOp%
        AND D4_QUANT <> 0
        AND SD4.%notdel%  
    ORDER BY 4
EndSql

dbSelectArea("TEMP")
dbGotop()
bAcao:= {|| nReg ++ }
dbEval(bAcao,,{||!Eof()},,,.T.)
dbSelectArea("TEMP")
dbGotop()

If nReg = 0
  If Select("TEMP") > 0
   TEMP->(dbCloseArea())
  End
  DeleteObject(oOk)
  DeleteObject(oNo)
  dbSelectArea(cAlias)
  Return(cSeq)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a tabela                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While !eof()
   Aadd(aSeq,{.f.,TEMP->COMP,TRANSFORM(TEMP->QTD,"@E 999,999.99"),TEMP->SEQ})
   dbSelectArea("TEMP")  
   dbSkip( )
End

aSeqBack := aClone(aSeq)
aSeq :={}
nOpca := 0

DEFINE MSDIALOG oDlgt FROM 9, 0 TO 405, 400 PIXEL TITLE OemToAnsi(cCad)  

//@0.5, 0.3 TO 13.6, 20.0 LABEL "" OF oDlgt
@2.3,3 Say OemToAnsi("Sequencias Encontradas :")+ transform(nReg, "@E 9,999") 
@1.0,.7 LISTBOX oQual VAR cVar Fields HEADER "",OemToAnsi( "Componente"),OemToAnsi( "Quantidade"),OemToAnsi( "Sequencia")  SIZE 150,170 ON DBLCLICK (aSeqBack:=FA060Troca(oQual:nAt,aSeqBack),oQual:Refresh()) NOSCROLL 
oQual:SetArray(aSeqBack)
oQual:bLine := { || {if(aSeqBack[oQual:nAt,1],oOk,oNo),aSeqBack[oQual:nAt,2],aSeqBack[oQual:nAt,3],aSeqBack[oQual:nAt,4]}}
//oQual:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, aEval(aTipoBack, {|e| e[1] := !e[1]}),Nil), lRunDblClick := !lRunDblClick, oQual:Refresh()}


DEFINE SBUTTON FROM 10  ,166  TYPE 1 ACTION (nOpca := 1, oDlgt:End()) ENABLE OF oDlgt
DEFINE SBUTTON FROM 22.5,166  TYPE 2 ACTION oDlgt:End() ENABLE OF oDlgt

ACTIVATE MSDIALOG oDlgt centered

IF nOpca == 1
  aSeq := Aclone(aSeqBack)
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a string de tipos para filtrar o arquivo               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeq :=""
For nX := 1 To Len(aSeq)
	If aSeq[nX,1]
		cSeq := aSeq[nX,4]
	End
Next nX

DeleteObject(oOk)
DeleteObject(oNo)

dbSelectArea(cAlias)

Return(cSeq)