#include "protheus.ch"


User Function BACA001()
Local _lOk := .t.
Local _nQtd := 0

dbSelectArea("SZ2")
dbSetOrder(1)

dbGotop()


While ! SZ2->(eof())
	
	IF SZ2->Z2_STATUS == "N"
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		if ! dbSeek(xfilial("SB1")+SZ2->Z2_COD)
			
			_nQtd += 1
			
			if _lok
				msgAlert("Produto de SZ2 nao encontrado em SB1 "+SZ2->Z2_COD)
				_lok := .f.
			Endif
			
		Endif
		
	Endif
	
	SZ2->(dbSkip())
End

MsgAlert("Existem "+alltrim(str(_nQtd))+" produtos em SZ2 que não estao em SB1")

Return
