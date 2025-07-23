#INCLUDE "rwmake.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GRFINA04 บAutor  ณSilvio Cazela       บ Data ณ  02/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Reimpressao de Cheques                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User function GRFINA04

Local 	cPerg 		:= "GFIA04"
Local 	aSays		:= {}
Local 	aButtons	:= {}
Local 	nOpca		:= 0
Private	cCadastro	:= "Reimpressao de Cheques"

ValidPerg(cPerg)
Pergunte(cPerg,.f.)

AADD(aSays,"Esta rotina ira desmarcar o flag de impressao de cheques, permitindo assim")
AADD(aSays,"a reimpressao do mesmo.")

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}})
AADD(aButtons, { 2,.T.,{|o|            o:oWnd:End()}})
AADD(aButtons, { 5,.T.,{|o|     Pergunte(cPerg,.T. )}})
FormBatch( cCadastro, aSays,aButtons )

If nOpcA == 1
	Processa({||A04Proc()},"Processando...")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ A04Proc    บAutor  ณSilvio Cazela       บ Data ณ  02/01/02   บฑฑ
ฑฑศออออออออออฯออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A04Proc

Local nCnt := 0,nP:=1

DbSelectArea("SEF")
DbSetOrder(1)
DbSeek(xFilial("SEF")+mv_par01+mv_par02+mv_par03+mv_par04,.t.)

ProcRegua(RecCount())
_lProcessou:=.f.
While !Eof() .and. EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM <= mv_par01+mv_par02+mv_par03+mv_par05
    _lProcessou:=.t.
	IncProc("Processando arquivo...")
	
    if (sef->ef_impress$"AC")==.f.
        if SEF->EF_IMPRESS == "S"
           RecLock("SEF")
           SEF->EF_IMPRESS := " "
           MsUnLock()
           nCnt := nCnt + 1
        Elseif nP == 1
           nP := Aviso("Atencao","O cheque numero ["+alltrim(sef->ef_num)+"] ainda nao foi impresso, deseja continuar o processamento ?",{"Continua","Cancela"})
           If nP == 2
              Exit
           Endif
        Endif
	endif
	DbSkip()
End
if !_lProcessou
   msgbox("Nao foi encontrado nenhum cheque para este banco/agencia/conta neste intervalo numerico")
elseif nCnt==0
   msgbox("Nenhum cheque foi marcado para reimpressao")
elseIf nP==2   
    Aviso("Processamento interrompdio","Foram processados "+alltrim(str(nCnt,12))+" registros.",{"OK"})
elseIf nP<>2
	Aviso("Concluido","Foram processados "+alltrim(str(nCnt,12))+" registros.",{"OK"})
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunฦo    ณ VALIDPERGณ Autor ณ                        ณ Data ณ   /  /   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function ValidPerg(cPerg)
Local _cSavAlias := Alias()
Local aRegs      := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,6)

Aadd(aRegs,{cPerg,"01","Banco              ?", "" , "" ,"mv_ch1","C",3  ,0,0,"G","","mv_par01",""   , ""   , ""    , "","",""   , ""   , ""   , "","", "" , "" , "","", "" , "" , "","", "" , "" , "","","","","SA6"   , "" } )
Aadd(aRegs,{cPerg,"02","Agencia            ?", "" , "" ,"mv_ch2","C",5  ,0,0,"G","","mv_par02",""   , ""   , ""    , "","",""   , ""   , ""   , "","", "" , "" , "","", "" , "" , "","", "" , "" , "","","","",""   , "" } )
Aadd(aRegs,{cPerg,"03","Conta              ?", "" , "" ,"mv_ch3","C",10 ,0,0,"G","","mv_par03",""   , ""   , ""    , "","",""   , ""   , ""   , "","", "" , "" , "","", "" , "" , "","", "" , "" , "","","","",""   , "" } )
Aadd(aRegs,{cPerg,"04","Cheque Inicial     ?", "" , "" ,"mv_ch4","C",15 ,0,0,"G","","mv_par04",""   , ""   , ""    , "","",""   , ""   , ""   , "","", "" , "" , "","", "" , "" , "","", "" , "" , "","","","",""   , "" } )
Aadd(aRegs,{cPerg,"08","Cheque Final       ?", "" , "" ,"mv_ch8","C",15 ,0,0,"G","","mv_par08",""   , ""   , ""    , "","",""   , ""   , ""   , "","", "" , "" , "","", "" , "" , "","", "" , "" , "","","","",""   , "" } )

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_cSavAlias)

Return

