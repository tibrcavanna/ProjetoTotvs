#include "prothesp.ch"

User Function A1Contatos()

Local oLbx										//Listbox com os nomes dos contatos
Local aCont    := {}							//Array com os contatos
Local cDFuncao := CRIAVAR("U5_FUNCAO",.F.)		//Funcao do contato na empresa	
Local cCliente := ""							//Codigo do cliente
Local cLoja    := ""							//Loja do cliente
Local cDesc    := ""							//Decricao do cliente
Local cEntidade:= "SA1"                        	//Alias da entidade
Local nOpcao   := 0								//Opcao 
Local nContato := 0								//Posicao do contato dentro do array na selecao
Local oDlg										//Tela
Local lRet	   := .F.							//Retorno da tela
		
cCliente := M->CJ_CLIENTE
cLoja    := M->CJ_LOJA
cDesc    := M->CJ_NOMCLI

If Empty(cCliente)
	Help(" ",1,"SEM CLIENT")
	Return(lRet)
Endif

DbSelectArea("AC8")
DbSetorder(2)		//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
If DbSeek(xFilial("AC8") + cEntidade + xFilial(cEntidade) + cCliente + cLoja) 

	While (!Eof()) .AND.;
		  (AC8->AC8_FILIAL == xFilial("AC8")) .AND.;
		  (AC8->AC8_ENTIDA == cEntidade) .AND.;
		  (AC8->AC8_FILENT == xFilial(cEntidade)) .AND.;
		  (ALLTRIM(AC8->AC8_CODENT) == ALLTRIM(cCliente + cLoja))
		
		DbSelectArea("SU5")
		DbSetorder(1)
		If DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
			cDFuncao := Posicione("SUM",1,xFilial("SUM")+SU5->U5_FUNCAO,"UM_DESC")

			Aadd(aCont, {	SU5->U5_CODCONT,;		//C¢digo
							SU5->U5_CONTAT,;		//Nome 
							cDFuncao,;				//Fun‡„o
							SU5->U5_FONE,;			//Telefone
							SU5->U5_OBS;			//Observacao
							} )
		Else
			Aadd(aCont,{"","","","",""})
		Endif
		DbSelectArea("AC8")
		DbSkip()
	End
Else
	If A1IncCt(@oLbx,@aCont,.T.,cEntidade,cCliente,cLoja,cDesc) == 3 // Cancelou a Inclusao
		Return(lRet)
	Else 
		lRet := .T.	
		Return(lRet)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados dos Contatos 								     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM  48,171 TO 230,800 TITLE "Cadastro de Contatos" + " - " + cDesc PIXEL // 
	
	@  3,2 TO  73, 310 LABEL "Cadastro de Contatos :" OF oDlg  PIXEL 
	@ 10,5	LISTBOX oLbx FIELDS ;
			HEADER ;
			"Codigo",; 
			"Nome",; 
			"Funcao",; 
			"Telefone",;
			"Observacao";
			SIZE 303,60  NOSCROLL OF oDlg PIXEL ;
			ON DBLCLICK( nOpcao:= 1,nContato := oLbx:nAt,oDlg:End() )
	
			oLbx:SetArray(aCont)
			oLbx:bLine:={ || {	aCont[oLbx:nAt,1],;	//C¢digo
								aCont[oLbx:nAt,2],;	//Nome 
								aCont[oLbx:nAt,3],;	//Fun‡„o
								aCont[oLbx:nAt,4],;	//Telefone
								aCont[oLbx:nAt,5];		//Observacao
								}}
					
	DEFINE SBUTTON FROM 74,162 TYPE 4	ENABLE OF oDlg ACTION A1IncCt(@oLbx,@aCont,.F.,cEntidade,cCliente,cLoja,cDesc)
	DEFINE SBUTTON FROM 74,192 TYPE 11	ENABLE OF oDlg ACTION A1AltCt(@oLbx,1,@aCont,cCliente,cLoja)
	DEFINE SBUTTON FROM 74,222 TYPE 15	ENABLE OF oDlg ACTION A1VisCt(oLbx,1,@aCont,cCliente,cLoja)
	
	DEFINE SBUTTON FROM 74,252 TYPE 1	ENABLE OF oDlg ACTION (nOpcao:= 1,nContato:= oLbx:nAt,oDlg:End())
	DEFINE SBUTTON FROM 74,282 TYPE 2	ENABLE OF oDlg ACTION (nOpcao:= 0,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no registro correto para ser atualizado o campo de codigo do contato.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SU5")
DbSetorder(1)
If (nOpcao == 1)
	lRet := .T.
	DbSeek(xFilial("SU5") + aCont[nContato,1])
Endif

Return(lRet)


Static Function A1IncCt(oLbx,aCont,lNovo,cEntidade,cCliente,cLoja,cDesc)

Local aArea   		:= GetArea()							// Salva a area atual
Local nOpca     	:= 0									// Opcao de OK ou CANCELA
Local cDFuncao  	:= CRIAVAR("U5_FUNCAO",.F.)				// Cargo da funcao do contato
Local cAlias    	:= "SA1"                                // Alias 
Private cCadastro 	:= "Inclusao de Contatos" 			 	//"Inclus„o de Contatos"

DbSelectArea("SU5")
nOpcA := AxInclui("SU5",0,3,)

If (nOpca == 1)
	DbSelectArea("AC8")
	RecLock("AC8",.T.)
	Replace AC8_FILIAL With xFilial("AC8")
	Replace AC8_FILENT With xFilial(cEntidade)
	Replace AC8_ENTIDA With cEntidade
	Replace AC8_CODENT With cCliente + cLoja
	Replace AC8_CODCON With SU5->U5_CODCONT
	MsUnLock()
	DbCommit()
Endif

// Se houve inclusao do registro atualizo o listbox de contatos
If nOpcA == 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se esse ‚ o primeiro contato a ser cadastrado fecho a ³
	//³tela e abro novamente para a cria‡„o do objeto listbox³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lNovo
		u_a1Contatos()
		Return(nOpcA)
	Endif
	
	aCont := {}
	
	DbSelectArea("AC8")
	DbSetorder(2)
	If DbSeek(xFilial("AC8") + cAlias + xFilial(cAlias) + cCliente + cLoja,.T.)

		While (!Eof()) 								.AND. ;
			  (AC8->AC8_FILIAL == xFilial("AC8")) 	.AND.;
			  (AC8->AC8_ENTIDA == cAlias) 			.AND.;
			  (AC8->AC8_FILENT == xFilial(cAlias)) 	.AND. ;
			  (ALLTRIM(AC8->AC8_CODENT) == (cCliente + cLoja))
		
			DbSelectArea("SU5")
			DbSetorder(1)
			If DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
				cDFuncao := Posicione("SUM",1,xFilial("SUM")+SU5->U5_FUNCAO,"UM_DESC")

				Aadd(aCont,{SU5->U5_CODCONT,;		//C¢digo
							SU5->U5_CONTAT,;		//Nome 
							cDFuncao,;				//Fun‡„o
							SU5->U5_FONE,;			//Telefone
							SU5->U5_OBS} )			//Observacao
			Else
				Aadd(aCont,{"","","","",""})
			Endif
		
			DbSelectArea("AC8")
			DbSkip()
		End
	Endif	
		
	oLbx:SetArray(aCont)
	oLbx:nAt:= Len(aCont)
	oLbx:bLine:={||{aCont[oLbx:nAt,1],;  //C¢digo
					aCont[oLbx:nAt,2],;  //Nome 
					aCont[oLbx:nAt,3],;	 //Fun‡„o
					aCont[oLbx:nAt,4],;	 //Telefone
					aCont[oLbx:nAt,5] }} //Observacao
	oLbx:Refresh()
Endif

RestArea(aArea)

Return(nOpcA)


Static Function A1AltCt(oLbx,nPos,aCont,cCliente,cLoja)

Local aArea		  := GetArea()						// Salva a area atual
Local cCod	      := ""								// Codigo do contato	
Local cDFuncao    := ""								// Cargo do contato
Local cAlias	  := "SA1"		                    // Alias 
Local nOpcA       := 0								// Opcao de retorno OK ou CANCELA
Local aRots       := aClone(aRotina)                // Copia do array aRotina 
Local lRet		  := .T.							// Retorno da funcao
	
Private cCadastro := "Alteracao de Contatos"	    // "Altera‡„o de Contatos" 	//Private para compatibilizacao com a funcao AXaltera
Private lRefresh  := .T.

cCod := Eval(oLbx:bLine)[nPos]

DbSelectArea("SU5")
DbSetorder(1)
If DbSeek(xFilial("SU5")+ cCod)

	BEGIN TRANSACTION

		If lRet
			nOpcA:=AxAltera("SU5",RECNO(),4)
		Endif

		aRotina:= aClone(aRots)	

	END TRANSACTION
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se houve altera‡ao do registro atualizo o listbox de contatos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcA == 1
		lRet  := .T.
		aCont := {}
		DbSelectArea("AC8")
		DbSetorder(2)
		If DbSeek(xFilial("AC8") + cAlias + xFilial(cAlias) + cCliente + cLoja,.T.)
			While (!Eof()) 							  	.AND.;
				  (AC8->AC8_FILIAL == xFilial("AC8")) 	.AND.;
				  (AC8->AC8_ENTIDA == cAlias) 		  	.AND.;
				  (AC8->AC8_FILENT == xFilial(cAlias))	.AND.;
				  (ALLTRIM(AC8->AC8_CODENT) == (cCliente + cLoja))
		
				DbSelectArea("SU5")
				DbSetorder(1)
				If DbSeek(xFilial("SU5") + AC8->AC8_CODCON)
					cDFuncao := Posicione("SUM",1,xFilial("SUM")+SU5->U5_FUNCAO,"UM_DESC")
					Aadd(aCont,{SU5->U5_CODCONT,;		//C¢digo
								SU5->U5_CONTAT,;		//Nome 
								cDFuncao,;				//Fun‡„o
								SU5->U5_FONE,;			//Telefone
								SU5->U5_OBS} )			//Observacao
				Else
					Aadd(aCont,{"","","","",""})
				Endif
		
				DbSelectArea("AC8")
				DbSkip()
			End
		Endif	
		
		oLbx:SetArray(aCont)
		oLbx:bLine:={||{aCont[oLbx:nAt,1],;  //C¢digo
						aCont[oLbx:nAt,2],;  //Nome 
						aCont[oLbx:nAt,3],;	 //Fun‡„o
						aCont[oLbx:nAt,4],;	 //Telefone
						aCont[oLbx:nAt,5] }} //Observacao
		oLbx:Refresh()

	Endif
Endif

RestArea(aArea)

Return(lRet)


Static Function A1VisCt(oLbx,nPos,aCont,cCliente,cLoja)

Local cAliasOld   := Alias()
Local cCod		  := ""
Private cCadastro := "Visualizacao de Contatos" 

cCod := Eval(oLbx:bLine)[nPos]

DbSelectarea("SU5")
DbSetorder(1)

If DbSeek(xFilial("SU5")+ cCod)
	AxVisual("SU5",RECNO(), 2)
Endif

DbSelectarea(cAliasOld)

Return(.T.)      




//**********************************************************


User Function AtuPlano() 

Local cdesc := space(40) 
Local cCont	:= space(20)
Local cNew  := "CT1NEW"

//dbUseArea( .T. ,, cArqDBF , "TMP",.F.,.F. )   

dbUseArea(.T.,,cNEW,"NEW",.T.,.F.)

//Use CT1NEW

DBGOTOP()

WHILE ! EOF()

	cdesc := NEW->CT1_DESC01
	cCNew := NEW->CT1_CONTA   
	
	
	if !(Subs(cCNew,1,1) $ "12")
		 NEW->(DBSKIP())
		 loop
	endif	    	
	
	DBSelectArea("CT1")
	DBSetOrder(6)
	DBseek(xFilial("CT1")+cDesc)
	
	 IF SUBS(CCNEW,1,1) <> SUBS(CT1->CT1_CONTA,1,1)
 	    CT1->(DBSKIP())
 	 ENDIF
	
	if CT1->(!eof()) .AND. cDesc == CT1->CT1_DESC01
		RecLock( "CT1", .F. )		      
        CT1->CT1_CNOVA  := cCNew 
        CT1->CT1_DESC02 := "OK"
              
        MSUnlock()             
    endif
    
    NEW->(DBSKIP())
    
    IF NEW->(EOF())
    	EXIT
    ENDIF
    
ENDDO

RETURN .T.
                
                                
