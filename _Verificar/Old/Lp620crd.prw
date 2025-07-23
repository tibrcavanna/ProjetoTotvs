#include "rwmake.ch"  

User function LP620CRD

_cCta    := ""
           
If     Subst(SB1->B1_CONTA,1,5) == "11301"
       _cCta := "11301003"
ElseIf Subst(SB1->B1_CONTA,1,5) == "11302"
	    _cCta := "11302005"
ElseIf Subst(SB1->B1_CONTA,1,5) == "11303"
	    _cCta := "11303004"
ElseIf Subst(SB1->B1_CONTA,1,5) == "11305"
	    _cCta := "11305003"

ElseIf SB1->B1_CONTA
       _cCta :=SB1->B1_CONTA
EndIf           	
	
Return(_cCta)