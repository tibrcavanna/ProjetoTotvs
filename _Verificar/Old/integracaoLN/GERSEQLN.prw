#INCLUDE "PROTHEUS.CH"


User Function GERSEQLN()

LOCAL aSAY    := {}
LOCAL aBUTTON := {}
LOCAL nOPC    := 0
LOCAL cTITULO := "Geração do numero sequencial LN inicial na Tabela SD1 "
LOCAL cDESC1  := "Este programa tem como objetivo - Gerar a numeração LN "
LOCAL cDESC2  := " sequencial inicial  na tabela SD1"

AADD( aSAY, cDESC1 )
AADD( aSAY, cDESC2 )

AADD( aBUTTON, { 1, .T., {|| nOPC := 1, FECHABATCH() }} )
AADD( aBUTTON, { 2, .T., {|| nOPC := 0, FECHABATCH() }} )

FORMBATCH( cTITULO, aSAY, aBUTTON )

IF nOPC == 1
	PROCESSA( {|| U_GERSQSD1()}, "Aguarde...","Executando rotina.....", .T. )
ENDIF

Return

//______________________________________________
User Function GERSQSD1()

	dbSelectArea("SD1")
	PROCREGUA(LastRec())
	
	SD1->(dbGotop())
	While ! SD1->(eof())
                      
		incproc("Processando ... "+SD1->D1_DOC+"  -  "+DTOC(SD1->D1_EMISSAO) )                          
                      
		Reclock("SD1",.F.)
		SD1->D1_SEQLN := getsxenum("SD1","D1_SEQLN")
		SD1->(MsUnlock())  
		ConfirmSX8(.f.)
		
    	SD1->(dbSkip())

	End

Return

