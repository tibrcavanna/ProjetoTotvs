#include "rwmake.ch"      

User Function IMPSB2()   

@ 0,0 TO 150,400 DIALOG oDlg TITLE "Importacao de custo de produtos"
@ 10,5 TO 50,195
@ 20,15 SAY "Esta rotina importa os registros de custo do SB2 p/ SB2010"
@ 30,15 SAY ""
@ 060,130 BMPBUTTON TYPE 1 ACTION OkProc()
@ 060,160 BMPBUTTON TYPE 2 ACTION Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED
Return

Static Function OkProc()
Close(oDlg)

Processa( {|| GERASB2() } )

Alert("Importacao gerada com sucesso !!!")

Return

Static Function GERASB2()

DbUseArea(.T.,,"\IMPTAB\SB2.DBF","TRB",.T.,.T.)

PROCREGUA(RecCount())
dbGoTop()
dbSelectArea("TRB") 
While !Eof()

  INCPROC("Importando arquivo " + "\IMPTAB\SB2.DBF" )

  dbselectarea("SB2")  
  dbsetorder(1)
  If dbseek(xfilial("SB2")+alltrim(trb->B2_COD)+alltrim(trb->B2_LOCAL))   

    Reclock("SB2",.F.) 
      SB2->B2_CM1 := trb->B2_CM1
    Msunlock()

   EndIf    

   dbSelectArea("TRB") 
   dbSkip()


EndDo

dbSelectArea("TRB") 
dbCloseArea()

Return
