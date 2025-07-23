#include "rwmake.ch"      

User Function IMPSA1()   

@ 0,0 TO 150,400 DIALOG oDlg TITLE "Importacao da Clasf. do Cliente"
@ 10,5 TO 50,195
@ 20,15 SAY "Esta rotina importa os registros do SA1 para SA1010"
@ 30,15 SAY ""
@ 060,130 BMPBUTTON TYPE 1 ACTION OkProc()
@ 060,160 BMPBUTTON TYPE 2 ACTION Close(oDlg)
ACTIVATE DIALOG oDlg CENTERED
Return

Static Function OkProc()
Close(oDlg)

Processa( {|| GeraSA1() } )

Alert("Importacao gerada com sucesso !!!")

Return

Static Function GeraSA1()

DbUseArea(.T.,,"\IMPORT\SA1.DBF","TRB",.T.,.T.)

PROCREGUA(RecCount())
dbGoTop()
dbSelectArea("TRB") 
While !Eof()

  INCPROC("Importando arquivo " + "\IMPORT\SA1.DBF" )

  dbselectarea("SA1")  
  dbsetorder(1)
  If dbseek(xfilial("SA1")+alltrim(trb->a1_cod)+"  "+trb->a1_loja)   

    Reclock("SA1",.F.) 
      sa1->a1_clasven := trb->a1_clasven
    Msunlock()

   EndIf    

   dbSelectArea("TRB") 
   dbSkip()


EndDo

dbSelectArea("TRB") 
dbCloseArea()

Return
