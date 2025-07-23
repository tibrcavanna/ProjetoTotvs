User Function SIGAFAT()

Local _aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verificando a data do ultimo envio do e-mail 						³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_dUltEnv := Getmv("MV_XMAILSB1") // Criar parametro com a Data do ultimo envio de e-mail

If _dUltEnv < Date()
	
	U_ConsNCM()                    

	DbSelectArea("SX6")
	DbSetOrder (1)
	If DbSeek( xFilial("SX6") + "MV_XMAILSB1" ) 
		SX6->(RecLock("SX6",.F.))
		    SX6->X6_CONTEUD := Dtoc(Date())  // Verificar se precisa transformar a data em Caratectere
		SX6->(MsUnlock())
	EndIf
EndIf

RestArea(_aArea)

Return()
