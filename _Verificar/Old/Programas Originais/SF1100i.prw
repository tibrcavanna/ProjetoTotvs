#include "rwmake.ch"        

User Function SF1100i() 

_cCavEst := SF1->F1_EST

If Alltrim(_cCavEst) = "EX"
	
	_nPesoLiq    :=  0
	_nPesoBru    :=  0
	_cTransp     := Space(6)
    _nQtd        := 0
    _cEspecie    := space(10)
    _cFrete      := space(1)  //"C"
    	
	@ 96,42 TO 323,505 DIALOG oDlg TITLE "Nota Fiscal de Importação "
	@ 012,004 SAY "Quant.    : "
	@ 027,004 SAY "Especie   : "
	@ 042,004 SAY "P.Liquido : "
	@ 057,004 SAY "P.Bruto   : "
	@ 072,004 SAY "Transp.   : "
	@ 087,004 SAY "Frete     : "
	@ 012,062 Get _nQtd       Picture "99999" size 50,70
	@ 027,062 Get _cEspecie   Picture "@!"           size 80,70
	@ 042,062 Get _nPesoLiq   Picture "999,999.9999" size 50,70
	@ 057,062 Get _nPesoBru   Picture "999,999.9999"  size 50,70
	@ 072,062 Get _cTransp    Picture "@!" F3 "SA4"  size 50,70
	@ 087,062 Get _cFrete     Picture "@!" valid _cFrete $"C/F"  size 10,70
	
	@ 91,165 BMPBUTTON TYPE 1 ACTION Procp1()                                                                              
	@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg)
	
	ACTIVATE DIALOG oDlg CENTERED

Endif

Return nil

Static function procp1()
processa({|| procp1a(),"Atualizando Arquivo"})
return nil

Static Function PROCP1a()

dbSelectArea("SF1")
//dbSetOrder(1)
//dbgotop()
ProcRegua(LastRec())

RecLock("SF1",.F.)
 SF1->F1_CAVLIQ   := _nPesoLiq
 SF1->F1_CAVBRU   := _nPesoBru
 SF1->F1_CAVTRA   := _cTransp  
 SF1->F1_CAVFRE   := _cFrete
 SF1->F1_CAVESP   := _cEspecie
 SF1->F1_CAVQTD   := _nQtd
MsUnLock("SF1")

Close(oDlg)
Return