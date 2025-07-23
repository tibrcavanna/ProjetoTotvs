#INCLUDE "rwmake.ch"

User Function PROCINV //gera os itens no arquivo SB7 dos produtos nao inventariados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos dados de Entrada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSave:= getarea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela Principal                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
restarea(aSave)

Return



***********************************************************
Static Function OkProc()
***********************************************************

dbSelectArea("SB2")
dbSetOrder(1)
dbgotop()

While !eof() .and. SB2->B2_FILIAL = XFILIAL("SB2")


      dbselectarea("SB1")  
      dbsetorder(1)
      dbSeek(xFilial("SB1")+SB2->B2_COD)


      If SB1->B1_TIPO = "MO"
         dbSelectArea("SB2")
         dbSkip()
         loop
      Endif


      dbselectarea("SB7") 
      dbsetorder(1)
      If !dbseek(xfilial("SB7")+dtos(ddatabase)+SB2->B2_COD+SB2->B2_LOCAL)

        RecLock("SB7",.T.)
         sb7->b7_filial := xfilial("SB7") 
         sb7->b7_cod    := SB2->B2_COD
         sb7->b7_quant  := 0
         sb7->b7_tipo   := SB1->B1_TIPO
         sb7->b7_local  := SB2->B2_LOCAL
         sb7->b7_doc    := "INV07X"
         sb7->b7_data   := ddatabase
         sb7->b7_dtvalid:= ddatabase
	    MsUnlock()

        MsProcTxt( "Gerando Inventario  - "+SB2->B2_COD)


      EndIf

      dbSelectArea("SB2")
      dbSkip()


End


Return