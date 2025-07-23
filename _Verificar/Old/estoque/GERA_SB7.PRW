#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
//
//
User Function GERA_SB7()
Private _cCadastro := "Gera Inventario - SB7"

@ 000,000 TO 140,460 DIALOG oDlg2 TITLE _cCadastro
@ 012,012 SAY " Gera dados de Inventario Para Produtos - SB7"
@ 024,012 SAY " Gera a paritr do arquivo SZ9010 alimentado com dados do LN."
@ 036,012 SAY " Importante: Será utilizada a Data Base como Data do fechamento."
@ 026,200 BMPBUTTON TYPE 1 ACTION _GeraSB7()
@ 040,200 BMPBUTTON TYPE 2 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2 CENTERED
Return

Static Function _GeraSB7()
Processa( {|| OkZ9Proc() } , "Gerando A Partir do SZ9010 dados de Inventario - SB7..." )
Processa( {|| OkB2Proc() } , "Gerando A Partir do SB2010 dados de Inventario - SB7..." )
Close(oDlg2)
Return

Static Function OkZ9Proc()
Local   _aVetor     := {}
Private lMsErroAuto := .F.
Private _cProduto   := Space(15)
Private _cLocal     := Space(02)
Private _dData      := Ctod("")
Private _nCont      := 0
Private _nSemSB1    := 0
Private _nSemSB2    := 0
Private _nSemNNR    := 0
Private _nMSBLQL    := 0

//
conout("INICIO GERA_SB7 - SZ9 - Data: "+Dtoc(dDataBase))
//  Atualiza o SB7 a partir das informações do SZ9 ( SZ9010 ).
dbSelectArea("SZ9")
dbSetOrder(2)                  // Z9_FILIAL+DTOS(Z9_DATA)+Z9_COD
dbSeek(xFilial("SZ9")+Dtos(dDataBase),.T.)
ProcRegua(LastRec())

Do While !Eof() .And. SZ9->Z9_DATA == dDataBase

	_cProduto := SZ9->Z9_COD
	IncProc("Gerando Inventario para o Produto: "+_cProduto)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	If !(dbSeek(xFilial("SB1")+_cProduto))
		conout("GERA_SB7 - Produto: "+_cProduto+" Nao Encontrado no SB1...")
		_nSemSB1++
		dbSelectArea("SZ9")
		dbSkip()
		Loop
	Else
	    If SB1->B1_MSBLQL == "1"
		    conout("GERA_SB7 - Produto: "+_cProduto+" Bloqueado no SB1...")
		    _nMSBLQL++
		    dbSelectArea("SZ9")
		    dbSkip()
		    Loop
	    EndIf
	    _cLocal   := SB1->B1_LOCPAD
	    _dData    := dDataBase
	EndIf
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	If !(dbSeek(xFilial("SB2")+_cProduto+_cLocal))
		conout("GERA_SB7 - Produto: "+_cProduto+" Local: "+_cLocal+" Nao Encontrado no SB2...")
	    _nSemSB2++
		dbSelectArea("SZ9")
		dbSkip()
		Loop
	EndIf

	dbSelectArea("NNR")
	dbSetOrder(1)
	If !(dbSeek(xFilial("NNR")+_cLocal))
		conout("GERA_SB7 - Local: "+_cLocal+" Nao Encontrado no NNR...")
		_nSemNNR++
		dbSelectArea("SZ9")
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SB7")
	dbSetOrder(1)                      // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
    If dbSeek(xFilial("SB7")+DTOS(dDataBase)+_cProduto+_cLocal,.T.)
		RecLock("SB7",.F.)
		SB7->B7_QUANT := SB7->B7_QUANT + SZ9->Z9_QUANT
		MsUnlock()
		dbSelectArea("SZ9")
		dbSkip()
		Loop
	EndIf

	_aVetor := {}

	_aVetor := {;
	{"B7_FILIAL" ,    "01"                ,Nil},;
	{"B7_COD"    ,    _cProduto           ,Nil},; // Deve ter o tamanho exato do campo B7_COD, pois faz parte da chave do indice 1 da SB7
	{"B7_DOC"    ,    "K"+Dtos(dDataBase) ,Nil},;
	{"B7_QUANT"  ,    SZ9->Z9_QUANT       ,Nil},;
	{"B7_LOCAL"  ,    _cLocal             ,Nil},; // Deve ter o tamanho exato do campo B7_LOCAL, pois faz parte da chave do indice 1 da SB7
	{"B7_DATA"   ,    dDataBase           ,Nil} } // Deve ter o tamanho exato do campo B7_DATA, pois faz parte da chave do indice 1 da SB7

	MSExecAuto({|x,y,z| MATA270(x,y,z)},_aVetor,.T.,3)

	If lMsErroAuto
		MostraErro()
		ConOut(OemToAnsi("Erro GERASB7! "+_cProduto+_cLocal))
	Else
		_nCont := _nCont + 1
	EndIf

	dbSelectArea("SZ9")
	dbSkip()
EndDo
//
conout("TERMINO GERA_SB7 - SZ9 - Data: "+Dtoc(dDataBase))
//
MsGBox("Inventario (SB7) Gerado a partir do SZ9010, com sucesso! - Foram gerados: "+Str(_nCont)+" registros.","Fim","INFO")
If _nSemSB1 > 0
     MsGBox("SZ9 - Inventário (SB7) Não foi Gerado por Falta de SB1! Total de Registros: "+Str(_nSemSB1),"Fim","INFO")
EndIf
If _nMSBLQL > 0
     MsGBox("SZ9 - Inventário (SB7) Não foi Gerado por SB1 Bloqueado! Total de Registros: "+Str(_nMSBLQL),"Fim","INFO")
EndIf
If _nSemSB2
     MsGBox("SZ9 - Inventário (SB7) Não foi Gerado por Falta de SB2! Total de Registros: "+Str(_nSemSB2),"Fim","INFO")
EndIf
If _nSemNNR
     MsGBox("SZ9 - Inventário (SB7) Não foi Gerado por Falta de NNR! Total de Registros: "+Str(_nSemNNR),"Fim","INFO")
EndIf
Return
//
//
Static Function OkB2Proc()
Local _aVetor  := {}
Local _aSaldos := {}
Local _nQuant  := 0.000000

lMsErroAuto := .F.
_cProduto   := Space(15)
_cLocal     := Space(02)
_dData      := Ctod("")
_nCont      := 0
_nSemSB1    := 0
_nSemNNR    := 0
_nMSBLQL    := 0
//
conout("INICIO GERA_SB7 - SB2 - Data: "+Dtoc(dDataBase))
//
dbSelectArea("SB2")
dbGoTop()
ProcRegua(LastRec())

Do While !Eof()

	_cProduto := SB2->B2_COD
    _cLocal   := SB2->B2_LOCAL
    _dData    := dDataBase
	IncProc("Gerando Inventario para o Produto: "+_cProduto)

	_aSaldos  := {}
    _aSaldos  := CalcEst(_cProduto,_cLocal, dDataBase+1)
    _nQuant   := _aSaldos[1]

    If _nQuant == 0.000000
        dbSelectArea("SB2")
        dbSkip()
        Loop
    EndIf

	dbSelectArea("SB7")
	dbSetOrder(1)                      // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
    If dbSeek(xFilial("SB7")+DTOS(dDataBase)+_cProduto+_cLocal,.T.)
        dbSelectArea("SB2")
        dbSkip()
        Loop
	EndIf

	dbSelectArea("SZ9")
	dbSetOrder(1)                      // Z9_FILIAL+Z9_COD+DTOS(Z9_DATA)
    If dbSeek(xFilial("SZ9")+_cProduto+DTOS(dDataBase))
        dbSelectArea("SB2")
        dbSkip()
        Loop
	EndIf

	dbSelectArea("SB1")
	dbSetOrder(1)
	If !(dbSeek(xFilial("SB1")+_cProduto))
		conout("GERA_SB7 - Produto: "+_cProduto+" Nao Encontrado no SB1...")
		_nSemSB1++
		dbSelectArea("SB2")
		dbSkip()
		Loop
    Else
	    If SB1->B1_MSBLQL == "1"
		    conout("GERA_SB7 - Produto: "+_cProduto+" Bloqueado no SB1...")
		    _nMSBLQL++
		    dbSelectArea("SB2")
		    dbSkip()
		    Loop
	    EndIf
	EndIf

	dbSelectArea("NNR")
	dbSetOrder(1)
	If !(dbSeek(xFilial("NNR")+_cLocal))
		conout("GERA_SB7 - Local: "+_cLocal+" Nao Encontrado no NNR...")
		_nSemNNR++
		dbSelectArea("SB2")
		dbSkip()
		Loop
	EndIf

	_aVetor := {}

	_aVetor := {;
	{"B7_FILIAL" ,    "01"                ,Nil},;
	{"B7_COD"    ,    _cProduto           ,Nil},; // Deve ter o tamanho exato do campo B7_COD, pois faz parte da chave do indice 1 da SB7
	{"B7_DOC"    ,    "K"+Dtos(dDataBase) ,Nil},;
	{"B7_QUANT"  ,    0.00                ,Nil},;
	{"B7_LOCAL"  ,    _cLocal             ,Nil},; // Deve ter o tamanho exato do campo B7_LOCAL, pois faz parte da chave do indice 1 da SB7
	{"B7_DATA"   ,    dDataBase           ,Nil} } // Deve ter o tamanho exato do campo B7_DATA, pois faz parte da chave do indice 1 da SB7

	MSExecAuto({|x,y,z| MATA270(x,y,z)},_aVetor,.T.,3)

	If lMsErroAuto
		MostraErro()
		ConOut(OemToAnsi("Erro GERASB7! "+_cProduto+_cLocal))
	Else
		_nCont := _nCont + 1
	EndIf

	dbSelectArea("SB2")
	dbSkip()
EndDo
//
conout("TERMINO GERA_SB7 - SB2 - Data: "+Dtoc(dDataBase))
//
MsGBox("Inventario (SB7) Gerado a partir do SB2010, com sucesso! - Foram gerados: "+Str(_nCont)+" registros.","Fim","INFO")
If _nSemSB1 > 0
     MsGBox("SB2 - Inventário (SB7) Não foi Gerado por Falta de SB1! Total de Registros: "+Str(_nSemSB1),"Fim","INFO")
EndIf
If _nMSBLQL > 0
     MsGBox("SB2 - Inventário (SB7) Não foi Gerado por SB1 Bloqueado! Total de Registros: "+Str(_nMSBLQL),"Fim","INFO")
EndIf
If _nSemNNR
     MsGBox("SB2 - Inventário (SB7) Não foi Gerado por Falta de NNR! Total de Registros: "+Str(_nSemNNR),"Fim","INFO")
EndIf
Return