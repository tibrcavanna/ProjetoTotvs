#include "rwmake.ch"
#include "tbicode.ch"
#include "tbiconn.ch"
#include "topconn.ch"

User Function ACEXOP()

WfPrepenv("01","01")

/*/
SELECT D1_OP,D1_ITEMCTA,D1_DOC,D1_FORNECE,D1_LOJA,D1_PEDIDO,E2_NUM,E2_FORNECE,E2_LOJA FROM SD1010 SD1 (NOLOCK)
INNER JOIN SE2010 SE2 ON (SE2.D_E_L_E_T_ = ' ' AND E2_NUM+E2_FORNECE+E2_LOJA = D1_DOC+D1_FORNECE+D1_LOJA)
WHERE D1_ITEMCTA LIKE '%VB079%'
AND SD1.D_E_L_E_T_ = ' '
/*/

//MB
//GB

//


_cQuery := " SELECT DISTINCT LEFT(C2_NUM,2) C2_NUM FROM SC2010 SC2 (NOLOCK) "
_cQuery += " WHERE D_E_L_E_T_ = ' ' "
_cQuery += " AND C2_ITEM = '01' AND C2_SEQUEN = '001' "
_cQuery += " ORDER BY  LEFT(C2_NUM,2) "

If Select("QUESC2") > 0 
   dbCloseArea()
EndIf   

TCQUERY _cQuery NEW ALIAS "QUESC2"

While !Eof()
	
	For i := 87 to 88
		
		_cVB := LEFT(QUESC2->C2_NUM,2)+StrZero(i,3)
		
		_cQuery := " UPDATE SE2010 SET E2_XOP = '"+_cVb+" 01001' "
		_cQuery += " FROM SD1010 SD1 (NOLOCK) "
		_cQuery += " INNER JOIN SE2010 SE2 ON (SE2.D_E_L_E_T_ = ' ' AND E2_NUM+E2_FORNECE+E2_LOJA = D1_DOC+D1_FORNECE+D1_LOJA) "
		_cQuery += " WHERE LEFT(D1_OP,5) = '"+_cVB+"' "
		_cQuery += " AND SD1.D_E_L_E_T_ = ' ' "
		
		TCSQLEXEC(_cQuery)
		
	Next
	
	QUESC2->(dbSkip())
	
EndDo    


cteste := " "

Return