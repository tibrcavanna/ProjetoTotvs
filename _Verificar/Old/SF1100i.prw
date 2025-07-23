#Include "rwmake.ch"                      
#Include "colors.ch"                      

/*
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³    SF1100I   ³ Autor ³MicroSiga          ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ponto de Entrada apos gravar SF1                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Rotina    ³ MATA100                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Tare                                                       ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function SF1100I()

Local _aArea := GetArea()
            
If SF1->F1_FORMUL == "S" .Or. SF1->F1_TIPO $ 'B/D'
	
	_cDi        := SF1->F1_XDI
	_dDtDI      := SF1->F1_XDTDI
	_cLocDes    := SF1->F1_XLOCDES
	_cUfDes     := SF1->F1_XUFDES
	_dDes       := SF1->F1_XDTDES
	_cExport    := Space(12) 
	_cFabrican  := Space(12)                                      
	_cMens      := Space(90) 
	_cmoeda     := Space(2)                                  
		                                  
	@ 65,0 To 400,597 Dialog oMensNF Title "Mensagens para NF de Entrada"
	@ 7,3 To 142,260 

	@ 010,010 Say OemToAnsi("Numero DI    :")
	@ 025,010 Say OemToAnsi("Data DI      :")
	@ 040,010 Say OemToAnsi("Local Desemb.:")
	@ 055,010 Say OemToAnsi("Uf Loc.Desemb:")
	@ 070,010 Say OemToAnsi("Data Desemb  :")
	@ 085,010 Say OemToAnsi("Exportador   :")
	@ 100,010 Say OemToAnsi("Fabricante   :") 
	@ 115,010 Say OemToAnsi("Moeda        :")
	@ 130,010 Say OemToAnsi("Mensagem") Size 37,08 Color CLR_HBLUE 
	
	
	@ 010,052 Get _cDi Size 76,10  when .T.
	@ 025,052 Get _dDtDi Size 76,10 when .T.
	@ 040,052 Get _cLocDes Size 76,10 when .T.
	@ 055,052 Get _cUfDes Size 76,10 when .T.
	@ 070,052 Get _dDes Size 76,10 when .T.
	@ 085,052 Get _cExport Size 76,10 when .T.
	@ 100,052 Get _cFabrican Size 76,10 when .T.    
	@ 115,052 Get _cmoeda F3 "CTO" Size 05,10 when .T.      
    @ 130,052 Get _cMens  Size 165,60
                                          
	@ 145,190 BMPBUTTON TYPE 1 ACTION ProcGrv()
	@ 145,222 BMPBUTTON TYPE 2 ACTION Close(oMensNF)	
	
	ACTIVATE DIALOG oMensNF CENTERED
	
	
EndIf

RestArea(_aArea)

Return (.T.)

Static Function ProcGrv()
Local dDatCTB := M->dDataBase
RecLock("SF1",.F.)
SF1->F1_XDI     := _cDi
SF1->F1_XDTDI   := _dDtDI
SF1->F1_XLOCDES := _cLocDes
SF1->F1_XUFDES  := _cUfDes
SF1->F1_XDTDES  := _dDes
SF1->F1_XEXP    := _cExport
SF1->F1_XFAB    := _cFabrican
SF1->F1_MENS    := _cMens
SF1->F1_MOEF    := _cmoeda
SF1->(MsUnlock())
Close(oMensNF)

dbselectarea("SE2")
reclock("SE2",.f.)
SE2->E2_MOEF    := _cmoeda
SE2->(MsUnlock())

//// ALTERACAO MOEDA
If(!Empty(_cmoeda))
	//
	xCTP_FILIAL := xFilial("CTP")
	xCTP_DATA   := dDatCTB
	xCTP_MOEDA  := Strzero(val(_cmoeda), 2)
	xCTP_TAXA   := SF1->F1_TXMOEDA
	xCTP_BLOQ   := "2"        // Bloqueado (1=Sim ,2=Nao)
	//
	CTO->(DbSeek(xFilial("CTO") + xCTP_MOEDA, .F.))
	//
	If CTO->(Found()) .And.;
		CTO->CTO_BLOQ # "1"    // Bloequeado (1=Sim, 2=Nao)
		//
		CTP->(DbSeek(xFilial("CTP") + Dtos(xCTP_DATA) + xCTP_MOEDA, .F.))
		//
		If CTP->(Found())
			lGravarCTP := .F.   // Alteracao
		Else
			lGravarCTP := .T.   // Inclusao
		Endif
		//
		DbSelectArea("CTP")
		If CTP->(RecLock("CTP", lGravarCTP))
			//
			If lGravarCTP
				//
				CTP->CTP_FILIAL := xFilial("CTP")
				CTP->CTP_DATA   := xCTP_DATA
				CTP->CTP_MOEDA  := xCTP_MOEDA
				//
			Endif
			//
			CTP->CTP_BLOQ := xCTP_BLOQ
			CTP->CTP_TAXA := xCTP_TAXA
			//
			CTP->(MsUnLock())
			//
		Endif
	//
	Endif
Endif
//// FIM ALTERACAO MOEDA
Return(.T.)

