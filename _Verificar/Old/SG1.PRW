#include "rwmake.ch" 
#DEFINE SAY PSAY
 
User Function sg1dbf()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define Variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Local	nOpc	   :=	0
Local	cText1	:=	"Esta rotina Gerar Arq Estrutura de Produtos"
Local cText2   :=	"Conforme parametros selecionados"
Local aSays	   :=	{}
Local aButtons :=	{}
Local cCadastro:=	"De SG1010.dbf => \ap_data\SPOOL\SG1.XLS"

While .T.
	AADD(aSays,OemToAnsi( ctext1 ) )
	AADD(aSays,OemToAnsi( cText2 ) )
	AADD(aButtons, { 1,.T.,{|o| nOpc:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons )

	Do Case
	Case nOpc==1
         Processa( {|| RunProc() } )
	Case nOpc==2
		Loop
	EndCase
	Exit
End
Return

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica as perguntas selecionadas                           �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para parametros �
//� mv_par01		 // Da Nota Fiscal	  �
//� mv_par02		 // Ate Nota Fiscal 	  �
//� mv_par03		 // Cliente            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Processa({|| RunProc()},"Aguarde...")

Return

Static Function RunProc()

Local _aCampos := {}
Local _cArqTmp := "\SPOOL\SG1.XLS" 


Pergunte("GERSG1",.T.)

_aCampos:= {{"COD     ","C",15,0},;  
		   	{"COMP           ","C",15,0},;
		   	{"DESCRICAO  ","C",65,0},;
		   	{"QTD               ","N",12,4}}
		   
DbCreate(_cArqTmp,_aCampos,"DBFCDX")  

dbUseArea(.T.,"DBFCDX",_cArqTmp,"TMP", .T., .F. ) 

dbSelectArea("SG1")
dbSetOrder(1)
dbSeek(xFilial("SG1")+(mv_par01),.T.)
ProcRegua(RecCount())

Do While !Eof()// .and. (sg1->g1_cod) == (mv_par01)
      
   IncProc("Gerando Arquivo de Estrutura")                                                                             
    
   If (sg1->g1_cod) < (mv_par01) .or. (sg1->g1_cod) > (mv_par02)  
   dbSelectArea("SG1")
   dbSkip()
   loop 
 
   End      
      
       reclock("TMP",.T.)
       tmp->cod         := sg1->g1_cod
       tmp->comp        := sg1->g1_comp
       tmp->descricao   := posicione("SB1",1,xFilial("SB1")+SG1->G1_COMP,"B1_DESC")
       tmp->qtd         := sg1->g1_quant
      
     Msunlock()

    dbSelectArea("SG1")
    dbSkip()
 
Enddo                                      

dbSelectArea("TMP") 
dbCloseArea()

Return
