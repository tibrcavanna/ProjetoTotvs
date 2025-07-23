#INCLUDE "rwmake.ch"


// nova estrutura de plano de contas



User Function AtuPlano() 

Local cdesc := space(40) 
Local cCont	:= space(20)
Local ccNew  := CT1NEW

//dbUseArea( .T. ,, cArqDBF , "TMP",.F.,.F. )
dbUseArea(.T.,,cNEW,"NEW",.T.,.F.)

Use CT1NEW()

DBGOTOP()

WHILE ! EOF()

	cdesc := NEW->CT1_DESC
	cCNew := NEW->CT1_CONTA
	
	DBSelectArea("CT1")
	DBSetOrder(6)
	DBseek(xFilial("CT1")+cDesc)
	
	if CT1->(!eof())
		RecLock( "CT1", .F. )		      
        CT1->CT1_CONTA := cCNew       
        MSUnlock()             
    endif
    
    NEW->(DBSKIP())
    
    IF NEW->(EOF())
    	EXIT
    ENDIF
    
ENDDO

RETURN .T.
                
    			

Return                                 

