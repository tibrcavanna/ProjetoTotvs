#include "rwmake.ch" 
#include "TBICONN.CH"
#define CRLF Chr(13)+Chr(10)

User Function ChmTI01()

Private _lAdmin  := .t.
Private _cFiltro
Private _cDirChm := "\Chamados\"
Private _cVersao := "V1.0"
aCores := {}

AADD(aCores,{"ZZ_STATUS=='A'","BR_AMARELO"})
AADD(aCores,{"ZZ_STATUS=='B'","BR_VERDE"})
AADD(aCores,{"ZZ_STATUS=='C'","BR_PRETO"})
AADD(aCores,{"ZZ_STATUS=='D'","BR_VERMELHO"})
AADD(aCores,{"ZZ_STATUS=='E'","BR_AZUL"})

cCadastro := "Chamados TI "+_cVersao

If !File( _cDirChm+"*.*" )
    MakeDir(Trim(_cDirChm))
Endif

DbSelectArea("PZZ") 
DbSetOrder(1)
dbgotop()
_aGrps := UsrRetGrp() 

For _i:=1 to len(_aGrps)
	If "000000" == ALLTRIM(_aGrps[_i])
		_lAdmin := .T.
	EndIf
Next

If !_lAdmin
	aRotina   := { {"Pesquisar"  ,"AxPesqui"  ,0,1},;
	{"Visualizar"     ,"AXVISUAL"  ,0,2},;
	{"Incluir"        ,"U_CHM01INC()",0,3},;
	{"Cancelar"       ,"U_Chm01Hist(5)",0,3},;
	{"Adic.Historico" ,"U_Chm01Hist(2)",0,3},;
	{"Imprimir"       ,"U_Chm01Print(.t.)",0,4},;  
	{"Relatorio"      ,"U_Chm01Rel()",0,4},;		
	{"Legenda"        ,"U_LegChm01()",0,4}}

	_cFiltro := "PZZ->ZZ_IDUSER==RetCodUsr() "
	SET FILTER TO &_cFiltro
Else
	aRotina   := { {"Pesquisar"  ,"AxPesqui"  ,0,1},;
	{"Visualizar"    ,"AXVISUAL"  ,0,2},;
	{"Incluir"       ,"U_CHM01INC()",0,3},;
	{"Encerrar"      ,"U_Chm01Hist(1)",0,3},;
	{"Adic.Historico","U_Chm01Hist(2)",0,3},;
	{"Atender"       ,"U_Chm01Hist(3)",0,3},;	
	{"Reabrir"       ,"U_Chm01Hist(4)",0,3},;		
	{"Imprimir"      ,"U_Chm01Print(.t.)",0,4},;
	{"Relatorio"     ,"U_Chm01Rel()",0,4},;	
	{"Legenda"       ,"U_LegChm01()",0,4},;
	{"Em aprovação"  ,"U_Chm01Hist(6)",0,3},;
	{"Classificar"   ,"U_Classif()",0,3}}
	_cFiltro := " Alltrim(PZZ->ZZ_ANALIST) == Alltrim(cUserName) .OR. Empty(PZZ->ZZ_ANALIST)  "
	SET FILTER TO &_cFiltro
EndIf	

mBrowse(6,01,22,75,"PZZ",,,,,,aCores)

dbSelectArea("PZZ") 
dbSetOrder(1)
dbClearFilter()
dbgotop()


Return                              


User Function Chm01Hist(_nOpc)
Private cHist := Space(100)
cCombo := ""
aCombo := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _nOpc==1
	If PZZ->ZZ_STATUS $ "CD"
		MsgInfo("Chamado já encerrado")
		Return
	EndIf
	@ 124,76 To 432,480 Dialog OdlHist Title OemToAnsi("Encerramento de Chamado")
ElseIf	 _nOpc == 2
	If PZZ->ZZ_STATUS $ "CD"
		MsgInfo("Chamado já encerrado")
		Return
	EndIf
	@ 124,76 To 432,480 Dialog OdlHist Title OemToAnsi("Histórico do Chamado")
ElseIf	 _nOpc == 3
	If PZZ->ZZ_STATUS $ "CD"
		MsgInfo("Chamado já encerrado")
		Return
	EndIf
	@ 124,76 To 432,480 Dialog OdlHist Title OemToAnsi("Atendimento do Chamado")
ElseIf	 _nOpc == 4
	@ 124,76 To 432,480 Dialog OdlHist Title OemToAnsi("Reabertura de Chamado")
ElseIf	 _nOpc == 5
	If PZZ->ZZ_STATUS $ "CD"
		MsgInfo("Chamado já encerrado")
		Return
	ElseIf PZZ->ZZ_STATUS $ "B"
		MsgInfo("Chamado em andamento não pode ser cancelado pelo usuário")
		Return
	EndIf
	@ 124,76 To 432,480 Dialog OdlHist Title OemToAnsi("Cancelamento de Chamado")
ElseIf	 _nOpc == 6
	If !PZZ->ZZ_STATUS $ "B"
		MsgInfo("Chamado deve estar com o Status de 'Em Andamento'")
		Return
	EndIf
	@ 124,76 To 432,480 Dialog OdlHist Title OemToAnsi("Em Aprovação")
ElseIf	 _nOpc == 7
	If PZZ->ZZ_STATUS $ "CD"
		MsgInfo("Chamado já encerrado")
		Return
	EndIf
	Classif()
EndIf

@ 10,10 Say OemToAnsi("Histórico") Size 78,8

@ 17,10 Get cHist MEMO Size 180,100
If _nOpc==1
	@ 130,10  Button OemToAnsi("_Encerrar Chamado") Size 50,16 Action Encerrar()
ElseIf _nOpc == 2	
	@ 130,10   Button OemToAnsi("_Adiciona Histórico") Size 50,16 Action  AddHist()
ElseIf _nOpc == 3	
	@ 130,10   Button OemToAnsi("_Atender") Size 50,16 Action  Atender()
ElseIf _nOpc == 4
	@ 130,10   Button OemToAnsi("_Reabrir") Size 50,16 Action  Reabrir()
ElseIf _nOpc == 5
	@ 130,10   Button OemToAnsi("_Cancelar") Size 50,16 Action  Cancelar()
ElseIf _nOpc == 6
	@ 130,10   Button OemToAnsi("_Em Aprovação") Size 50,16 Action Aprov()		
EndIf	

@ 130,140 Button OemToAnsi("_Cancela Alteração") Size 50,16 Action Close(OdlHist)

Activate Dialog OdlHist Centered


Return


User Function RetDepto()

Local _aDepto := {}
Local _cDepto := ""
PswOrder(2)
If PswSeek(Substr(cUsuario,7,15))
	_aDepto := PswRet(1)
    _cDepto:= _aDepto[1][12]
EndIf

Return(_cDepto)

User Function RetMail()
Local _aMail := {}
Local _cMail := ""
PswOrder(2)
If PswSeek(Substr(cUsuario,7,15))
	_aMail := PswRet(1)
    _cMail:= _aMail[1][14]
EndIf

Return(_cMail)

User Function RetName()
Local _aName := {}
Local _cName := ""
PswOrder(2)
If PswSeek(Substr(cUsuario,7,15))
	_aName := PswRet(1)
    _cName:= _aName[1][4]
EndIf

Return(_cName)


Static Function AddHist()
Local _cMsg := ""
Local _cQry := ""

_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Historico Adicionado: "+Chr(13)+Chr(10) + cHist +Chr(13)+Chr(10)
_cMsg += Replic("=",55)

_cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg

_cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
_cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
TCSQLEXEC(_cQry)
Close(OdlHist)


Return               


Static Function Atender()
Local _cMsg := ""
Local _cQry := ""

_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Chamado Direcionado "+Chr(13)+Chr(10) + Alltrim(cHist) +Chr(13)+Chr(10)
_cMsg += Replic("=",55)

If MsgYesNo("Confirma o atendimento do chamado?")
	If Empty(cHist)
		Alert("Historico é obrigatorio")
	Else
		RecLock("PZZ",.F.)
		PZZ->ZZ_ANALIST := cUserName
		PZZ->ZZ_STATUS  := "B"
		MsUnlock()
		_cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg
		_cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
		_cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
		TCSQLEXEC(_cQry)
	EndIf	
	Close(OdlHist)
Else
	Alert("Opção Cancelada")	
	Close(OdlHist)
EndIf

dbSelectArea("PZZ")
SET FILTER TO &_cFiltro


Return


Static Function Reabrir()
Local _cMsg := ""
Local _cQry := ""

_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Chamado Reaberto "+Chr(13)+Chr(10) + cHist +Chr(13)+Chr(10)
_cMsg += Replic("=",55)

If MsgYesNo("Confirma reabertura do chamado?")
	If Empty(cHist)
		Alert("Historico é obrigatorio")
	Else
		RecLock("PZZ",.F.)
		PZZ->ZZ_ANALIST := cUserName
		PZZ->ZZ_STATUS  := "A"
		PZZ->ZZ_DTENCER := CTOD("  /  /  ")
		PZZ->ZZ_HRENCER := Space(8)
		MsUnlock()
		_cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg
		_cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
		_cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
		TCSQLEXEC(_cQry)
	EndIf	
	Close(OdlHist)
Else
	Alert("Opção Cancelada")	
	Close(OdlHist)
EndIf


Return


Static Function Encerrar()
Local _cMsg := ""
Local _cQry := ""

_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Chamado Encerrado "+Chr(13)+Chr(10) + cHist +Chr(13)+Chr(10)
_cMsg += Replic("=",55)

If MsgYesNo("Confirma encerramento do chamado?")
	If Empty(cHist)
		Alert("Historico é obrigatorio")
	Else
		RecLock("PZZ",.F.)
		PZZ->ZZ_ANALIST := cUserName
		PZZ->ZZ_STATUS  := "D"
		PZZ->ZZ_DTENCER := Date()
		PZZ->ZZ_HRENCER := Time()
		
		MsUnlock()
		_cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg
		_cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
		_cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
		TCSQLEXEC(_cQry)
	EndIf	
	Close(OdlHist)
Else
	Alert("Opção Cancelada")	
	Close(OdlHist)
EndIf


Return

Static Function Cancelar()
Local _cMsg := ""
Local _cQry := ""
_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Chamado Cancelado "+Chr(13)+Chr(10) + cHist +Chr(13)+Chr(10)
_cMsg += Replic("=",55) 

If MsgYesNo("Confirma cancelamento do chamado?")
	If Empty(cHist)
		Alert("Historico é obrigatorio")
	Else
		RecLock("PZZ",.F.)
		PZZ->ZZ_ANALIST := Space(20)
		PZZ->ZZ_STATUS  := "C"
		PZZ->ZZ_DTENCER := Date()
		PZZ->ZZ_HRENCER := Time()
		MsUnlock()
		_cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg
		_cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
		_cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
		TCSQLEXEC(_cQry)
	EndIf	
	Close(OdlHist)
Else
	Alert("Opção Cancelada")	
	Close(OdlHist)
EndIf


Return


Static Function Aprov()
Local _cMsg := ""
Local _cQry := ""
_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Chamado Em Aprovação "+Chr(13)+Chr(10) + cHist +Chr(13)+Chr(10)
_cMsg += Replic("=",55) 

If MsgYesNo("Confirma esta alteração no chamado?")
   RecLock("PZZ",.F.)
   PZZ->ZZ_STATUS  := "E"
   MsUnlock()
   _cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg
   _cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
   _cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
   TCSQLEXEC(_cQry)
   Close(OdlHist)
Else
	Alert("Opção Cancelada")	
	Close(OdlHist)
EndIf


Return

User Function Classif()
Local _cMsg := ""
Local _cQry := ""
                                          
_nOpcoes := 1
_aOpcoes := {"Estabilização do Sistema","Melhorias","Suporte"}   // opcoes para escolha

@ 151,138 To 266,353 Dialog oGDlg Title OemToAnsi("Opcões de Classificação")
@ 010,017 Radio _aOpcoes Var _nOpcoes 
@ 037,035 BmpButton Type 1 Action Close(oGDlg)

Activate Dialog oGDlg

RecLock("PZZ",.F.)
If _nOpcoes = 1
	PZZ->ZZ_CLASSIF := "ES"
Elseif _nOpcoes = 2
	PZZ->ZZ_CLASSIF := "ME" 
Elseif _nOpcoes = 3
	PZZ->ZZ_CLASSIF := "SP"
Endif	 	
MsUnlock()

_cMsg += Alltrim(cUserName) + " - " + dtoc(Date())  + " - " + Time() +Chr(13)+Chr(10)
_cMsg += "Chamado Classificado - "+ PZZ->ZZ_CLASSIF + Chr(13)+Chr(10) + Chr(13)+Chr(10)
_cMsg += Replic("=",55)
 
_cHist := Alltrim(PZZ->ZZ_HISTOR) + Chr(13)+Chr(10) + _cMsg  
_cQry += "UPDATE " + RetSqlName("PZZ") + " SET ZZ_HISTOR = '" +_cHist+ "' "
_cQry += "WHERE ZZ_CHAMADO = '"+PZZ->ZZ_CHAMADO+"' "
TCSQLEXEC(_cQry)


Return


User Function LegChm01()
_aLegenda := {}
AADD(_aLegenda,{"BR_AMARELO","Em aberto"})
AADD(_aLegenda,{"BR_VERDE","Em Andamento"})
AADD(_aLegenda,{"BR_PRETO","Cancelado"})
AADD(_aLegenda,{"BR_VERMELHO","Encerrado"})
AADD(_aLegenda,{"BR_AZUL","Em Validacao do Usuario"})

BrwLegenda(cCadastro,'Legenda',_aLegenda)

Return

User Function CHM01PRINT(lPrint)

Private oFont04	 := TFont():New("Arial",04,04,,.F.,,,,.T.,.F.)
Private oFont08	 := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
Private oFont08B := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
Private oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFont15B := TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)
Private oFont20B := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)
Private oPrint	 := TMSPrinter():New( "Chamado" )

oPrint:Line(100,100,100,2200)
oPrint:Line(300,100,300,2200)
oPrint:Line(100,1800,300,1800)

oPrint:SetPortrait()
// Título do chamado
oPrint:SayBitmap(105,100,AjuBarPath(GetSrvProfString("Startpath",""))+"lgrl"+cEmpAnt+".bmp",400,190)
oPrint:Say(160,600,SM0->M0_NOME,oFont20B)
oPrint:Say(120,1850,"CHAMADO",oFont20B)
oPrint:Say(190,1900,PZZ->ZZ_CHAMADO,oFont20B)
//----------------------------------------------------------------------------------------------------
oPrint:Say(350,100,"Usuário:",oFont08B)
oPrint:Say(350,250,PZZ->ZZ_NOME,oFont08)

oPrint:Say(400,100,"Nome:",oFont08B)
oPrint:Say(400,250,PZZ->ZZ_NNOME,oFont08)

oPrint:Say(450,100,"Depto:",oFont08B)
oPrint:Say(450,250,PZZ->ZZ_DEPTO,oFont08)

oPrint:Say(500,100,"Telefone:",oFont08B)
oPrint:Say(500,250,PZZ->ZZ_TEL,oFont08)

oPrint:Say(550,100,"E-Mail:",oFont08B)
oPrint:Say(550,250,PZZ->ZZ_EMAIL,oFont08)

oPrint:Say(350,800,"Abertura:",oFont08B)
oPrint:Say(350,950,DTOC(PZZ->ZZ_DTCHAM) + " " + PZZ->ZZ_HRCHAM ,oFont08)

oPrint:Say(400,800,"Encerram.:",oFont08B)
oPrint:Say(400,950,DTOC(PZZ->ZZ_DTENCER) + " " + PZZ->ZZ_HRENCER ,oFont08)

_cStatus := ""
If(PZZ->ZZ_STATUS=="A")
	_cStatus := "Em aberto"
ElseIf(PZZ->ZZ_STATUS=="B")	
	_cStatus := "Em andamento"	
ElseIf(PZZ->ZZ_STATUS=="C")	
	_cStatus := "Cancelado"		
ElseIf(PZZ->ZZ_STATUS=="D")	
	_cStatus := "Encerrado"		
ElseIf(PZZ->ZZ_STATUS=="E")	
	_cStatus := "Em Aprovação"		
EndIf		

oPrint:Say(450,800,"Dt.Atual:",oFont08B)
oPrint:Say(450,950,DTOC(Date()) + " - " + Time() ,oFont08)

If Empty(PZZ->ZZ_DTENCER)
	_nDias:= Date() - PZZ->ZZ_DTCHAM
	_cTempo := IIf(_nDias==0,ELAPTIME(PZZ->ZZ_HRCHAM,Time()),Alltrim(Str(_nDias))+" Dia(s)")
Else
	_nDias:= PZZ->ZZ_DTENCER - PZZ->ZZ_DTCHAM               
	_cTempo := IIf(_nDias==0,ELAPTIME(PZZ->ZZ_HRCHAM,PZZ->ZZ_HRENCER),Alltrim(Str(_nDias))+" Dia(s)")	
EndIf

oPrint:Say(500,800,"Tempo:",oFont08B)
oPrint:Say(500,950,_cTempo ,oFont08)

oPrint:Say(550,800,"Situacao:",oFont08B)
oPrint:Say(550,950,_cStatus ,oFont08)

_cPrior := ""
If PZZ->ZZ_PRIORID == "1"
	_cPrior := "Alta"
ElseIf PZZ->ZZ_PRIORID == "2"	
	_cPrior := "Media"
ElseIf PZZ->ZZ_PRIORID == "3"	
	_cPrior := "Baixa"
EndIf	
_Classif := ""
If AllTrim(PZZ->ZZ_CLASSIF) = "ES"
   _Classif := "Estabilização do Sistema"
 Elseif AllTrim(PZZ->ZZ_CLASSIF) = "ME"
   _Classif := "Melhoria"
Endif       


oPrint:Say(350,1500,"Problema:",oFont08B)
oPrint:Say(350,1700,TABELA("ZG",PZZ->ZZ_PROBLEM),oFont08)
oPrint:Say(400,1500,"Analista  :",oFont08B)
oPrint:Say(400,1700,PZZ->ZZ_ANALIST,oFont08)
oPrint:Say(450,1500,"Prioridade:",oFont08B)
oPrint:Say(450,1700,_cPrior,oFont08)
oPrint:Say(500,1500,"Classific.:",oFont08B)
oPrint:Say(500,1700,_Classif,oFont08)

oPrint:Line(600,100,600,2200)
oPrint:Say(630,100,PZZ->ZZ_TITULO,oFont15B)
oPrint:Line(700,100,700,2200)
oPrint:Say(730,100,"Detalhes:",oFont15B)
_nLin := 800


For _ni := 1 to MLCOUNT(PZZ->ZZ_DESCRI)
	oPrint:Say(_nLin,100,MEMOLINE(PZZ->ZZ_DESCRI,,_ni),oFont10)	
	_nLin+=50
Next	

_nLin += 100 
oPrint:Line(_nLin,100,_nLin,2200)

oPrint:Say(_nLin,100,"Histórico:",oFont15B)

_nLin += 100
For _ni := 1 to MLCOUNT(PZZ->ZZ_HISTOR) 
	If _nLin == 3000
		oPrint:EndPage()
		_nLin := 100		
		oPrint:Say(_nLin,100,"Chamado:"+PZZ->ZZ_CHAMADO,oFont15B)
		_nLin := 200		
		oPrint:Say(_nLin,100,"Continuação:",oFont15B)
		_nLin := 300
	EndIf	
	oPrint:Say(_nLin,100,MEMOLINE(PZZ->ZZ_HISTOR,,_ni),oFont10)	
	_nLin+=50	
Next	

//oPrint:SaveAllAsJpeg(_cDirChm+'Chm_'+PZZ->ZZ_CHAMADO,870,840,140)

If lPrint
 oPrint:Preview()
EndIf
oPrint:End()

//u_EnvEmail(PZZ->ZZ_CHAMADO)


Return

User Function Chm01Rel()
ALERT("Em Desenvolvimento")
Return

User Function PrintFull()
DbSelectArea("PZZ")
DbGotop()
While !Eof()
	If UPPER(ALLTRIM(PZZ->ZZ_ANALIST))=="SMUTA"
		U_CHM01PRINT()
	EndIf	
	DbSkip()	
End
Return

User Function CHM01FIL()
Set Filter To
DbGotop()
Return

User Function CHM01INC()
AxInclui("PZZ", Recno(), 3,,,,"U_CHM01VLD()")
//U_CHM01PRINT(.F.)
u_EnvEmail(PZZ->ZZ_CHAMADO) 
Return .T.                  

User Function CHM01VLD()

//Local _aArea := GetArea()
//Set Filter To
//DbSetOrder(2)
//_cChamado := M->ZZ_CHAMADO
//While DbSeek(xFilial()+_cChamado)
// _cChamado := SOMA1(_cChamado)
//End
//M->ZZ_CHAMADO := _cChamado	
//RestArea(_aArea)


Return(.T.)

//ROTINA PARA ENVIO DE EMAIL
User Function EnvEmail(xChamado)

Local cMailConta  := NIL
Local cMailServer := NIL
Local cMailSenha  := NIL  
Local cMailCtaAut := NIL
Local cBackMens   := ""                     
Local cError      := ""
Local lAutOk      := .F. 
Local lOk         := .F. 
Local lSmtpAuth   := GetMv("MV_RELAUTH",,.F.)
Local cFrom		  := Alltrim(UsrRetMail(RetCodUsr()))
Local cTo         := "srcompain@terra.com.br"
Local cSubject    := "Chamados TI "+_cVersao 
Local cAttach     := _cDirChm+xChamado+'_pag1.jpg'
Local cMensagem   := Mensagem(xChamado)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Obtem dados necessarios a conexao                                                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMailConta  := If(cMailConta == NIL,GETMV("MV_RELFROM"),cMailConta)
cMailServer := If(cMailServer== NIL,GETMV("MV_RELSERV"),cMailServer)
cMailSenha  := If(cMailSenha == NIL,GETMV("MV_RELPSW") ,cMailSenha)
cMailCtaAut := If(cMailCtaAut== NIL,GETMV("MV_RELACNT"),cMailCtaAut)

If Empty(cFrom)
   cFrom := cMailConta
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia e-mail com os dados necessarios                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha) .And. !Empty(cMailCtaAut) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Conecta uma vez com o servidor de e-mails                                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailCtaAut PASSWORD cMailSenha RESULT lOk

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se configurado, efetua a autenticacao                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lAutOk 
		If ( lSmtpAuth ) 
			lAutOk := MailAuth(cMailCtaAut,cMailSenha)
		Else
			lAutOk := .T.
		EndIf 
	EndIf 			
	
	If lOk .And. lAutOk 
	
		//SEND MAIL FROM cFrom to cTo SUBJECT cSubject BODY cMensagem FORMAT TEXT RESULT lSendOk

		SEND MAIL FROM cFrom;
					TO cTo;
					SUBJECT cSubject;
					BODY cMensagem ;  
					RESULT lSendOk 

		//			ATTACHMENT cAttach;					

		If !lSendOk
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Erro no Envio do e-mail                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			GET MAIL ERROR cError
			MsgInfo(cError,OemToAnsi("Erro no envio de e-Mail"))
         Else
            DISCONNECT SMTP SERVER RESULT lDisConectou
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Erro na conexao com o SMTP Server ou na autenticacao da conta          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GET MAIL ERROR cError
		MsgInfo(cError,OemToAnsi("Erro na conexao com o SMTP"))  
	EndIf

EndIf

Return

Static Function Mensagem(cChamado)

Local cAux  := ""
Local aInfo := {}
Local nPos  := 0

cAux += Replicate( '-', 128 ) + CRLF
cAux += Replicate( ' ', 128 ) + CRLF
cAux += 'ABERTURA DE CHAMADOS TI '+_cVersao + CRLF
cAux += Replicate( ' ', 128 ) + CRLF
cAux += Replicate( '-', 128 )  + CRLF
cAux += CRLF
cAux += ' Dados Ambiente'        + CRLF
cAux += ' ---------------------' + CRLF
cAux += ' Chamado............: ' + cChamado  + CRLF
cAux += ' Empresa / Filial...: ' + cEmpAnt + '/' + cFilAnt  + CRLF
cAux += ' Nome Empresa.......: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_NOMECOM', cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
cAux += ' Nome Filial........: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
cAux += ' DataBase...........: ' + DtoC( dDataBase )  + CRLF
cAux += ' Data / Hora........: ' + DtoC( Date() ) + ' / ' + Time()  + CRLF
cAux += ' Environment........: ' + GetEnvServer()  + CRLF
cAux += ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' )  + CRLF
cAux += ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' )  + CRLF
cAux += ' Versao.............: ' + GetVersao(.T.)  + CRLF
cAux += ' Modulo.............: ' + GetModuleFileName()  + CRLF
cAux += ' Usuario Microsiga..: ' + __cUserId + ' ' +  cUserName + CRLF
cAux += ' Computer Name......: ' + GetComputerName()  + CRLF

aInfo   := GetUserInfo()
If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
	cAux += ' '  + CRLF
	cAux += ' Dados Thread'  + CRLF
	cAux += ' --------------------'  + CRLF
	cAux += ' Usuario da Rede....: ' + aInfo[nPos][1] + CRLF
	cAux += ' Estacao............: ' + aInfo[nPos][2] + CRLF
	cAux += ' Programa Inicial...: ' + aInfo[nPos][5] + CRLF
	cAux += ' Environment........: ' + aInfo[nPos][6] + CRLF
	cAux += ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) )  + CRLF
EndIf
cAux += Replicate( '-', 128 ) + CRLF
cAux += CRLF

Return(cAux)

User Function VerNum()

Local cChamado  := ""
Local cQuery    := ""

BeginSql Alias "TMP"

  SELECT MAX(ZZ_CHAMADO) CHAMADO
  FROM %Table:PZZ% PZZ
  WHERE PZZ.%NotDel%

EndSql

cChamado := soma1(TMP->CHAMADO,6)

dbSelectarea("TMP")
dbCloseArea()


Return(cChamado)

/*/
#DEFINE _OPC_cGETFILE ( GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_OVERWRITEPROMPT )
cPath     := cGetFile( "Selecione o Diretorio | " , OemToAnsi( "Selecione Diretorio" ) , NIL , 'C:\Relato' , .F. , _OPC_cGETFILE )
//salva relatorio como jpg
oPrint:SaveAllAsJpeg(_cDirChm+'\impgraf.jpg',2480,3508)
_catch:= cPath+'\impgraf.jpg_pag1.jpg'
cEmailDest := "workflow@jmbzeppelin.com.br"

oPr:Preview()
<objeto>:SaveAllAsJpeg("Teste.jpg",2480,3508)
oPr:End()
MV_IMAGE
cAttach2:= cNomeDir + "EXECUTE.EXE"
cAttach3:= cNomeDir + "LEAIME.TXT"
/*/