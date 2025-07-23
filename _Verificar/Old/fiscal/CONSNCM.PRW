#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#include "rwmake.ch" 
#include "Ap5Mail.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o   ³ ConsNCM  ³ Autor ³                       ³ Data ³ 27/10/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o| Envia e-mail para o cliente aprovado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico CAVANNA    -                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function ConsNCM()
Local cProc := ''
Local _cQry := '' 
Local _cMens := ''  
Local _cenv := .f.    
Local _ncont := 0
Local _cMail := SUPERGETMV("MV_NCMMAIL")
Private cEol        := CHR(13)+CHR(10)


cProc := " BEGIN TRAN TRAN_NCM " + cEol
cProc += " UPDATE "+RETSQLNAME("SFT")+" " + cEol
cProc += " SET FT_POSIPI = B1_POSIPI " + cEol
cProc += " FROM "+RETSQLNAME("SFT")+ " SFT , "+RETSQLNAME("SB1")+" SB1 " + cEol
cProc += " WHERE B1_COD = FT_PRODUTO AND SB1.D_E_L_E_T_ <> '*' AND SFT.D_E_L_E_T_ <> '*' AND FT_POSIPI = '' AND FT_ENTRADA > '"+DTOS(DATE()-90)+"' " + cEol
cProc += " COMMIT TRAN TRAN_NCM" + cEol
TCSQLEXEC(cProc) 

              
_cQry := "SELECT DISTINCT FT_PRODUTO, B1_DESC FROM "+RETSQLNAME("SFT") +" SFT , "+RETSQLNAME("SB1")+" SB1 "+ cEol  
_cQry += "WHERE B1_COD = FT_PRODUTO AND SB1.D_E_L_E_T_ <> '*' AND " + cEol 
_cQry += "SFT.D_E_L_E_T_ <> '*' AND FT_POSIPI = '' AND FT_ENTRADA > '"+DTOS(DATE()-90)+"'"

If Select("NCM") > 0
   DbSelectArea("NCM")               
   DbCloseArea() 
Endif  

TCQUERY _cQry NEW ALIAS "NCM"
dbSelectArea("NCM")
//SetRegua(RecCount())

dbGoTop()

While NCM->(!EOF())
	_cMens += " PRODUTO : " + ALLTRIM(NCM->FT_PRODUTO) +" - " + ALLTRIM(NCM->B1_DESC) + cEol    
	_cenv := .t.   
	_ncont ++
	dbSelectArea("NCM")
	NCM->(dbSkip())
EndDo 
If _cenv  
	EmailApro(_cMail,_cMens,_ncont)
Endif 
DbSelectArea("NCM")               
DbCloseArea() 
//MSGBOX("Fim do Processamento!!!","Atualizando dados...","INFO")
RETURN()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o   ³ EmailApro³ Autor ³                       ³ Data ³ 27/10/20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o| Envia e-mail para o cliente aprovado                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico CAVANNA    -                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function EmailApro(_cMail,_cMens,_ncont)

Local cServer   := GetMV('MV_RELSERV')
Local cAccount  := GetMV('MV_RELACNT')
Local cEnvia    := GetMV('MV_RELFROM')
Local cPassword := GetMV('MV_RELPSW')

Local cRecebe   := ""
Local cCopia    := ""
Local cAssunto  := ""
Local cMensagem := ""
Local lDisplay  := .F.

Private cEol        := CHR(13)+CHR(10)	                            // FIM DE LINHA

cAssunto  := "ITENS SEM NCM"

cRecebe   := _cMail

cMensagem := " Foram encontrados os seguintes itens sem NCM ("+ALLTRIM(STR(_ncont))+ ")" + cEol + cEol
cMensagem += _cMens + cEol+ cEol

                                                                                          
cMensagem += "Favor verificar. " + cEol

cCopia    := ""

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou

If lConectou
	MAILAUTH(cAccount,cPassword)
   If lDisplay
	   Alert("Conectado com servidor - " + cServer)
   Endif
Else
	cError := ""
	GET MAIL ERROR cError
	Alert(cError)
Endif
//
SEND MAIL FROM cEnvia;
     TO cRecebe;
     CC cCopia ;
     SUBJECT cAssunto ;
     BODY cMensagem;
     RESULT lEnviado
//                                       

If lEnviado
   //	Alert("Enviado e-mail para "+cRecebe)
Else
	cMensagem := ""
	GET MAIL ERROR cMensagem 
	Alert(cMensagem)
Endif
//   
DISCONNECT SMTP SERVER Result lDisConectou
//
If lDisConectou
   If lDisplay
	   Alert("Desconectado do servidor - " + cServer)
   Endif                                                                                         '
Endif
//
Return
