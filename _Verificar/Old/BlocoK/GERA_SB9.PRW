#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
//
//
User Function GERA_SB9()
Private _cCadastro := "Gera Saldo Inicial - SB9"

@ 000,000 TO 140,460 DIALOG oDlg2 TITLE _cCadastro
@ 012,012 SAY " Gera dados de Saldo Inicial - SB9"
@ 024,012 SAY "    "
@ 036,012 SAY " Sera gerado a partir do SZ9"
@ 026,200 BMPBUTTON TYPE 1 ACTION _GeraSB9()
@ 040,200 BMPBUTTON TYPE 2 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2 CENTERED
Return

Static Function _GeraSB9()
Processa( {|| OkSZ9Proc() } , "Gerando A Partir do SZ9010 dados de Saldos Iniciais - SB9..." )
Processa( {|| OkSB2Proc() } , "Gerando A Partir do SB2010 dados de Saldos Iniciais - SB9..." )
Close(oDlg2)
Return

Static Function OkSZ9Proc()
Local PARAMIXB1     := {}
Local PARAMIXB2     := 3
Private lMsErroAuto := .F.
Private _cProduto   := Space(15)
Private _cLocal     := Space(02)
Private _dData      := Ctod("")
Private _nQtdIni    := 0.00
Private _nCont      := 0
Private _nSemSB1    := 0
Private _nMSBLQL    := 0

dbSelectArea("SZ9")
dbSetOrder(2)                  // Z9_FILIAL+DTOS(Z9_DATA)+Z9_COD
dbSeek(xFilial("SZ9")+Dtos(dDataBase),.T.)
ProcRegua(LastRec())

Do While !Eof() .And. SZ9->Z9_DATA == dDataBase

    _cProduto := Substr(SZ9->Z9_COD,1,15)
	IncProc("Gerando Saldo Inicial para o Produto: "+_cProduto)

	dbSelectArea("SB1")
	dbSetOrder(1)
	If !(dbSeek(xFilial("SB1")+_cProduto))
		Alert("GERA_SB9 - SZ9 - Produto: "+_cProduto+" Nao Encontrado no SB1...")
		_nSemSB1++
		dbSelectArea("SZ9")
		dbSkip()
		Loop
	Else
	    If SB1->B1_MSBLQL == "1"
		    Alert("GERA_SB9 - SZ9 - Produto: "+_cProduto+" Bloqueado no SB1...")
	        _nMSBLQL++
		    dbSelectArea("SZ9")
		    dbSkip()
		    Loop
	    EndIf
	    _cLocal   := SB1->B1_LOCPAD
	    _dData    := Ctod("")
	EndIf

	dbSelectArea("SB2")
	dbSetOrder(1)                    // B2_FILIAL+B2_COD+B2_LOCAL
	If dbSeek(xFilial("SB2")+_cProduto+_cLocal)
        dbSelectArea("SB9")
        dbSetOrder(1)                 // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
        If dbSeek(xFilial("SB9")+_cProduto+_cLocal+Dtos(_dData))
            dbSelectArea("SZ9")
            dbSkip()
            Loop
        Else
            RecLock("SB9",.T.)
            SB9->B9_FILIAL  := "01"
            SB9->B9_COD     := _cProduto
            SB9->B9_LOCAL   := _cLocal
            SB9->B9_QINI    := 0.00
            MsUnlock()
            _nCont++
        EndIf
    Else
        dbSelectArea("SB9")
        dbSetOrder(1)                 // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
        If dbSeek(xFilial("SB9")+_cProduto+_cLocal+Dtos(_dData))
            dbSelectArea("SZ9")
            dbSkip()
            Loop
        EndIf

        Begin Transaction
        PARAMIXB1 := {}
        aadd(PARAMIXB1,{"B9_FILIAL" , "01",})
        aadd(PARAMIXB1,{"B9_COD"    , _cProduto,})
        aadd(PARAMIXB1,{"B9_LOCAL"  , _cLocal,})
        aadd(PARAMIXB1,{"B9_QINI"   , _nQtdIni,})

        MSExecAuto({|x,y| MATA220(x,y)},PARAMIXB1,PARAMIXB2)

        If !lMsErroAuto
            _nCont := _nCont + 1               // ConOut("Incluido com sucesso! "+cProd)
        Else
            Alert("Erro na inclusao! - Produto "+_cProduto+" Local "+_cLocal+"  Qtd. "+Str(_nQtdIni)+"    ")
            MostraErro()
        EndIf
        End Transaction
    EndIf

    dbSelectArea("SZ9")
    dbSkip()
EndDo

MsGBox("Saldo Inicial (SB9) Gerados a partir do SZ9010, com sucesso! Total de Registros: "+Str(_nCont),"Fim","INFO")
If _nSemSB1 > 0
     MsGBox("SZ9 - Saldo Inicial (SB9) Não foi Gerado por Falta de SB1! Total de Registros: "+Str(_nSemSB1),"Fim","INFO")
EndIf
If _nMSBLQL > 0
     MsGBox("SZ9 - Saldo Inicial (SB9) Não foi Gerado por SB1 Bloqueado! Total de Registros: "+Str(_nMSBLQL),"Fim","INFO")
EndIf
Return
//
//
//
Static Function OkSB2Proc()
Local PARAMIXB1 := {}
Local PARAMIXB2 := 3

lMsErroAuto := .F.
_cProduto   := Space(15)
_cLocal     := Space(02)
_dData      := Ctod("")
_nQtdIni    := 0.00
_nCont      := 0
_nSemSB1    := 0
_nMSBLQL    := 0

dbSelectArea("SB2")
dbGoTop()
ProcRegua(LastRec())

Do While !Eof()

    _cProduto := SB2->B2_COD
    _cLocal   := SB2->B2_LOCAL
    _dData    := Ctod("")

	IncProc("Gerando Saldo Inicial para o Produto: "+_cProduto)

    dbSelectArea("SB9")
    dbSetOrder(1)                 // B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
    If dbSeek(xFilial("SB9")+_cProduto+_cLocal+Dtos(_dData))
        dbSelectArea("SB2")
        dbSkip()
        Loop
	EndIf

	_aSaldos  := {}
    _aSaldos  := CalcEst(_cProduto,_cLocal, dDataBase+1)
    _nQuant   := _aSaldos[1]

	dbSelectArea("SB1")
	dbSetOrder(1)
	If !(dbSeek(xFilial("SB1")+_cProduto))
        RecLock("SB2",.F.)
        dbDelete()
        MsUnlock()
//		Alert("GERA_SB9 - SB2 - Produto: "+_cProduto+" Nao Encontrado no SB1...")
//		_nSemSB1++
		dbSelectArea("SB2")
		dbSkip()
		Loop
	Else
	    If SB1->B1_MSBLQL == "1"
            If _nQuant == 0.000000
                dbSelectArea("SB2")
                dbSkip()
                Loop
            Else
		        Alert("GERA_SB9 - SB2 - Produto: "+_cProduto+" Bloqueado no SB1...")
		        _nMSBLQL++
		        dbSelectArea("SB2")
		        dbSkip()
		        Loop
		    EndIf
        EndIf
	EndIf

    dbSelectArea("SB9")
    Begin Transaction
    RecLock("SB9",.T.)
    SB9->B9_FILIAL  := "01"
    SB9->B9_COD     := _cProduto
    SB9->B9_LOCAL   := _cLocal
    SB9->B9_QINI    := 0.00
    MsUnlock()
    End Transaction
    _nCont++

    dbSelectArea("SB2")
    dbSkip()
EndDo

MsGBox("Saldo Inicial (SB9) Gerados a partir do SB2010, com sucesso! Total de Registros: "+Str(_nCont),"Fim","INFO")
If _nSemSB1 > 0
     MsGBox("SB2 - Saldo Inicial (SB9) Não foi Gerado por Falta de SB1! Total de Registros: "+Str(_nSemSB1),"Fim","INFO")
EndIf
If _nMSBLQL > 0
     MsGBox("SB2 - Saldo Inicial (SB9) Não foi Gerado por SB1 Bloqueado! Total de Registros: "+Str(_nMSBLQL),"Fim","INFO")
EndIf
Return