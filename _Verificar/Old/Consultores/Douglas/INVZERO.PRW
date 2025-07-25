#INCLUDE "rwmake.ch" 
#INCLUDE "topconn.ch" 


User Function INVZERO //gera os itens no arquivo SB7 dos produtos nao inventariados

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Salva a Integridade dos dados de Entrada                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local aSave:= getarea()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define variaveis                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Local 	nOpc	:=	0
Local 	oDlg	:=	""
Local 	cTitulo	:=	""
Local 	cText1	:=	""
Local	cText2	:=	""
Local	cText3	:=	""
Local 	aSays	:=	{}
Local aButtons	:=	{}
Local cCadastro	:=	"Gera arquivo de Invetario"

Private lEnd	:=	.F.


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Janela Principal                                             �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cTitulo	:=	"Gera SB7 (Inventario)"
cText1	:=	"Esta rotina vai gerar os registros de inventario"
cText2	:=	"dos produtos nao inventariados"
While .T.
	AADD(aSays,OemToAnsi( ctext1 ) )
	AADD(aSays,OemToAnsi( cText2 ) )
	AADD(aButtons, { 1,.T.,{|o| nOpc:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons )
	
	Do Case
		Case nOpc==1
			MsAguarde( { || OkProc() }, "Gerando arquivo de inventario", "Iniciando processamento...", @lEnd )
		Case nOpc==3
			Loop
	EndCase
	Exit
End


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura area                                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
restarea(aSave)

Return



***********************************************************
Static Function OkProc()
***********************************************************

dbSelectArea("SB2")
dbSetOrder(1)        
dbgotop()

CRIATRB1()

_cQuery := " SELECT * FROM "+RetSqlName("SB2")+" SB2 "
_cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON (SB1.D_E_L_E_T_ = ' ' AND B1_COD = B2_COD) "
_cQuery += " WHERE SB2.D_E_L_E_T_ = ' ' AND SB1.B1_MSBLQL <> '1' " 
//_cQuery += "AND B2_COD = 'MOD1102' "     
_cQuery += " AND B1_COD NOT IN ('34177B1157','HMC55SX001') "
_cQuery += " ORDER BY B2_COD,B2_LOCAL "       
 
If Select("QUESB2") > 0 
   dbCloseArea()
EndIf                             

TCQUERY _cQuery NEW ALIAS "QUESB2"

_cMsg := ""  
_nreg := 0                         

While !eof() 
	
	_aAreaSB2 := GetArea()
		
	dbselectarea("SB1")
	dbsetorder(1)
	dbSeek(xFilial("SB1")+QUESB2->B2_COD)
                  
    dbSelectArea("SB7")
    dbSetOrder(1) //DATA+PRODUTO+LOCAL
    If !dbSeek(xFilial("SB7")+"20111231"+QUESB2->B2_COD+QUESB2->B2_LOCAL)
                                        
			_nReg++

/*/
			dbSelectArea("TRB2")
			RecLock("TRB2",.T.)
			TRB2->CODIGO := QUESB2->B2_COD
			TRB2->DESCRI := SB1->B1_DESC
			TRB2->LOCPAD  := QUESB2->B2_LOCAL
			TRB2->QTATUAL  := QUESB2->B2_QATU
			MsUnLock()
/*/   
									
			RecLock("SB7",.T.)
			sb7->b7_filial  := xfilial("SB7")
			sb7->b7_cod     := QUESB2->B2_COD
			sb7->b7_quant   := 0
			sb7->b7_tipo    := SB1->B1_TIPO
			sb7->b7_local   := QUESB2->B2_LOCAL
			sb7->b7_doc     := "CAV3112X"
			sb7->b7_data    := Ctod("31/12/11")
			sb7->b7_dtvalid := Ctod("31/12/11")
			sb7->b7_xendcav := QUESB2->B2_LOCALIZ
			MsUnlock()
			
			MsProcTxt( "Gerando Inventario  - "+QUESB2->B2_COD)
   
	EndIf

	RestArea(_aAreaSB2)
	dbSkip()

EndDo

dbSelectArea("TRB2") 
COPY TO DOUGLAS.DBF 
dbCloseArea()
             
dbSelectArea("QUESB2")
dbCloseArea()

Alert("Termino")  

//Memowrite("douglas.txt",_cMsg)

Return                             

                                    
Static Function CRIATRB1()
               
aStru := {}

aAdd(aStru,{ "CODIGO" ,"C",  20, 00} )  //Vlr. total aberto Mes.
aAdd(aStru,{ "DESCRI" ,"C",  60, 00} )  //Vlr. total aberto Mes.
aAdd(aStru,{ "LOCPAD"  ,"C",  02, 00} )  //Vlr. total aberto Mes.
aAdd(aStru,{ "QTATUAL","N",  18, 06} )  //Vlr. total aberto Mes.

_cArqTRB := Criatrab(aStru,.T.)
dbUseArea(.T.,,_cArqTRB,"TRB2",.F.,.F.)

IndRegua("TRB2",_cArqTRB,"CODIGO+LOCPAD",,,"Criando Indice ...")

Return
