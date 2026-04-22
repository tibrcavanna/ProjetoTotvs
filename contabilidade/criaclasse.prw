#Include "RwMake.ch"
#Include "TopConn.ch"
/*
+----------+--------+-----------+------------------------------+-----+-----------+
| Programa |CRIAITEM|Programador| Daniel Lourenço dos santos   |Data | 26/04/2022|
+----------+--------+-----------+------------------------------+-----+-----------+
| Rotina   | Criar item contábil a partir do cadastro de clientes e fornecedores.|
|          |                                                                     |
+----------+---------------------------------------------------------------------+
|                           Modificacoes desde a construcao Inicial              |
+---------------+--------------+-------------------------------------------------+
| Programador   | Data         | Motivo                                          |
+---------------+--------------+-------------------------------------------------+
|               |              |                                                 |
+---------------+--------------+-------------------------------------------------+
*/
User Function CRIAITEM()

Processa( {|| FPrcCtb("F")} ,OemToAnsi("Atualização do Item Contábil - Fornecedores"),OemToAnsi("Processando..."))	
Processa( {|| FPrcCtb("C")} ,OemToAnsi("Atualização do Item Contábil - Clientes"),OemToAnsi("Processando..."))


Return


Static Function FPrcCtb(cTipo)
*****************************************************************************************************
* Criacao do Item Contabil (C)lientes - (F)ornecedores (P)essoal - Funcionários.
****
Local cItemCont := ""
Local nRegs:=0

If cTipo == "F" // Fornecedor
   dbSelectArea("SA2")
   dbGoTop()
   DbEval({|| nRegs++})
   ProcRegua(nRegs)
   dbGoTop()
   While ! Eof()
   	   IncProc(OemToAnsi("Atualizando Item de Fornecedor " + SA2->A2_COD + "/" + SA2->A2_LOJA))
     		dbSelectArea("CTH")
   		  dbSetOrder(1)
   		  If ! dbSeek(xFilial("CTH")+"F"+SA2->A2_COD+"-"+SA2->A2_LOJA)	
       			cItemCont := "F"+SA2->A2_COD+"-"+SA2->A2_LOJA
   			    If RecLock("CTH",.T.)
   			       Replace CTH_FILIAL With xFilial("CTH"),;
                  			CTH_CLVL   With cItemcont,;
                  			CTH_DESC01 With Alltrim(SA2->A2_NOME),;
                   		    CTH_CLASSE With "2",;
                  			CTH_NORMAL With "0",;
                  			CTH_DTEXIS With CTOD("01/01/1980"),;
                  			CTH_BLOQ   With '2'		
          			MsUnlock()
         	EndIf
   	   EndIf
       dbSelectArea("SA2")
       dbSkip()
   End   
ElseIf cTipo == "C" //Cliente
   dbSelectArea("SA1")
   dbGoTop()
   DbEval({|| nRegs++})
   ProcRegua(nRegs)
   dbGoTop()
   While ! Eof()
   	   IncProc(OemToAnsi("Atualizando Item de Cliente " + SA1->A1_COD + "/" + SA1->A1_LOJA))
     		dbSelectArea("CTH")
   		  dbSetOrder(1)
   		  If ! dbSeek(xFilial("CTH")+"C"+SA1->A1_COD+"-"+SA1->A1_LOJA)	
       			cItemCont := "C"+SA1->A1_COD+"-"+SA1->A1_LOJA
   			    If RecLock("CTH",.T.)
   			       Replace CTH_FILIAL With xFilial("CTH"),;
                  			CTH_CLVL   With cItemcont,;
                  			CTH_DESC01 With Alltrim(SA1->A1_NOME),;
                   		    CTH_CLASSE With "2",;
                  			CTH_NORMAL With "0",;
                  			CTH_DTEXIS With CTOD("01/01/1980"),;
                  			CTH_BLOQ   With '2'		
          			MsUnlock()
         	EndIf
   	   EndIf
       dbSelectArea("SA1")
       dbSkip()
   End      
   
EndIf

Return
