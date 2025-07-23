#include "rwmake.ch"  

User function LP530DEB

_cCta    := ""
           
If     alltrim(SE2->E2_TIPO) == "RES" .and. alltrim(SE2->E2_PREFIXO) == "GPE"
       _cCta := "21106001"
ElseIf alltrim(SE2->E2_TIPO) == "ADI" .and. alltrim(SE2->E2_PREFIXO) == "GPE"
	    _cCta := "11204001"
ElseIf alltrim(SE2->E2_TIPO) == "FOL" .and. alltrim(SE2->E2_PREFIXO) == "GPE"
	    _cCta := "21106001"
ElseIf alltrim(SE2->E2_TIPO) == "FER" .and. alltrim(SE2->E2_PREFIXO) == "GPE"
	    _cCta := "11204005"
ElseIf alltrim(SE2->E2_TIPO) == "131" .and. alltrim(SE2->E2_PREFIXO) == "GPE"
	    _cCta := "11204006"
ElseIf alltrim(SE2->E2_TIPO) == "132" .and. alltrim(SE2->E2_PREFIXO) == "GPE"
	    _cCta := "21108005"

ElseIf SA2->A2_CONTA
       _cCta :=SA2->A2_CONTA
EndIf           	
	
Return(_cCta)