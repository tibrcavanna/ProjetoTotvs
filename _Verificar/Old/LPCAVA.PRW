
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LPCAVA   ºAutor  ³Josinalvo Melo       º Data ³  08/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a Conta Contabil para determinado Lancamento Padrao º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico - Cavanna Group                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function LPCAVA()

Local cConta := Space(20)

If CT5->CT5_LANPAD == "A01" //Salários
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A02" //Pagamento Férias
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020400"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010500"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A04" //Horas Extras
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020101"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010101"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A03" //13 SALARIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020500"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010600"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A07" // Aviso Prévio
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020200"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010300"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A12" // AJUDA DE CUSTO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020800"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010900"
	EndIf	
EndIf                      

/*
If CT5->CT5_LANPAD == "A13" // PLR
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101030050"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102020050"
	EndIf	
EndIf                      
  */
  
If CT5->CT5_LANPAD == "A14" // INDENIZAÇÕES
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020900"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011000"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A15" // GRATIFICAÇÃO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020300"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010400"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A16" // PROVENTO DE VALE TRANSPORTE
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101030100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102020100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "A17" // AUXILIO SEGURO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020301"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010401"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "B04" //DESCONTO DE FALTAS E ATRASOS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "B07" //DESCONTO DE VALE TRANSPORTE 
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101030100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102020100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "B13" //DESCONTO DE FALTAS 
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "B14" //DESCONTO DE FÉRIAS PAGAS MÊS ANT
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020400"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010500"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "B16" // DESC HE PG MAIOR
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020101"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010101"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "B19" // DESC AV. PREVIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020200"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010300"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C01" //PROVISAO DE FÉRIAS 
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021300"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011400"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C02" //PROVISAO DE 13 Salário
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021500"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011600"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C03" //PROVISAO DE INSS FERIAS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021400"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011500"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C04" //PROVISAO DE FGTS FERIAS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021401"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011501"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C05" //PROVISAO DE INSS 13 SALARIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021600"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011700"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C06" //PROVISAO DE FGTS 13 SALARIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021601"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011701"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C07" //BAIXA PROVISAO DE ERIAS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101020400"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102010500"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C08" //BAIXA INSS FERIAS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021000"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C09" //BAIXA FGTS FERIAS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011200"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C10" //BAIXA PROVISAO 13 SALARIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021500"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011600"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C11" //BAIXA INSS 13 SALARIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021000"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C12" //BAIXA FGTS 13 SALARIO
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011200"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C13" //INSS EMPRESA + SAT + TERCEIROS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021000"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011100"
	EndIf	
EndIf                      

If CT5->CT5_LANPAD == "C14" //FGTS
	If Subs(SRZ->RZ_CC,1,1) == "1" // Produção
		cConta := "3101021100"
	ElseIf Subs(SRZ->RZ_CC,1,1) $ "2-3" // Comercial e Administração
		cConta := "3102011300"
	EndIf	
EndIf                      


Return (cConta )                           

