#include "rwmake.ch"
#include "protheus.ch"
#include "tbicode.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCAVPED01  บAutor  ณMicrosiga           บ Data ณ  07/25/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava pedido de venda conforme parametrizacao e acesso      บฑฑ
ฑฑบ          ณao arquivo SC7-Fornecedores                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณEspecifico para CAVANNA                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CAVPED01()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local 	cArea	:= ""
Local 	cCodatu	:= SC7->C7_PRODUTO

WfprepEnv("01","01")

Private aStrSC5,aStrSC6
Private  nOpc       := 3
Private aReg	    := {}
Private _cCliLoj 	:= ""
Private _cCodMun  	:= ""
Private _cCodItSv 	:= ""
Private _cCodItSv 	:= ""
Private _cTpPessoa 	:= ""
Private _cRecIss  	:= ""
Private	_cTpIss		:= ""
Private	cQRY		:= ""
Private _cFornIss   := ""
Private	bExcISS     := .F.
Private	cCod1Pr     := ""
Private aPedIte     := {}
Private aPedIts     := {}
Private aPedCab     := {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.
Private _lPrivez    := .T.
Private _lGravaPed  := .F.
Private aItemFaz    := {}
Private aCabFaz     := {}
Private _n          := 0
Private _cItem   	:= "00"

cArea := Getarea()

aRegs := {}
cPerg := "CAVPED0001"
aAdd(aRegs,{cPerg,"01","Ped.Compra         ?","","","mv_ch1","C"   ,06    ,00      ,0   ,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC7",""})
aAdd(aRegs,{cPerg,"02","TES                ?","","","mv_ch2","C"   ,03    ,00      ,0   ,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SF4",""})
aAdd(aRegs,{cPerg,"03","Cond.Pagto         ?","","","mv_ch3","C"   ,03    ,00      ,0   ,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SE4",""})
aAdd(aRegs,{cPerg,"04","Mensagem Padrใo    ?","","","mv_ch4","C"   ,03    ,00      ,0   ,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SM4",""})
aAdd(aRegs,{cPerg,"05","Dt. Entrega        ?","","","mv_ch5","D"   ,08    ,00      ,0   ,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Mens.p/Nota        ?","","","mv_ch6","C"   ,60    ,00      ,0   ,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Peso liquido       ?","","","mv_ch7","N"   ,11    ,04      ,0   ,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Peso bruto         ?","","","mv_ch8","N"   ,11    ,04      ,0   ,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Transportadora     ?","","","mv_ch9","C"   ,03    ,00      ,0   ,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA4",""})

VALIDPERG(cPerg,aRegs)

If !Pergunte(cPerg,.t.)
	Return()
EndIf

_mv_par01 := mv_par01
_mv_par02 := mv_par02
_mv_par03 := mv_par03
_mv_par04 := mv_par04
_mv_par05 := mv_par05
_mv_par06 := mv_par06               
_mv_par07 := mv_par07               
_mv_par08 := mv_par08               

dbSelectArea("SC7")
SC7->(dbSetOrder(1))
If dbseek(xfilial("SC7")+_mv_par01)
	cCodCli 	:= 	SC7->C7_FORNECE
	cLojaCli	:=	SC7->C7_LOJA
EndIf

cTes   := _mv_par02

If Empty(cTes)
	MsgAlert("TES de saํda invalido")
	Return
EndIf

dbSelectArea("SA2")
dbSetOrder(1)
dbseek(xfilial("SA2")+cCodCli+cLojaCli)
If SA2->A2_MSBLQL == '1'
	MsgAlert("Fornecedor bloqueado - Favor verificar campo no cadastro")
	Return
EndIf
cCodCli 	:= 	SA2->A2_COD
cLojaCli	:=	SA2->A2_LOJA

_lPrivez := .T.

cCodPed := _mv_par01

dbSelectArea("SC7")
dbSetOrder(1)
dbseek(xfilial("SC7")+cCodPed)

ProcRegua(SC7->(RecCount()))

_nPrcVen := 0
_nQtdVen := 0
_nTotal  := 0
_nCodOrc := ""
_nIteOrc := ""

While !SC7->(EOF())  .and. SC7->C7_NUM == cCodPed
	
	IncProc('Gerando pedido de vendas' + cCodPed + " ...")
	
	If _lPrivez
		
		_cCliLoj   := cCodCli + cLojaCli
		_cCodMun   := Posicione("SA2",1,xFilial("SA2") + _cCliLoj,"A2_COD_MUN")
		_cCodItSv  := AllTrim(Posicione("SB1",1,xFilial("SB1") + SC7->C7_PRODUTO, "B1_CODISS"))
		_cCodItSv  := PADR(_cCodItSv,8)
		_cTpPessoa := Posicione("SA2",1,xFilial("SA2") + _cCliLoj, "A2_TIPO")
		_cRecIss   := Posicione("SA2",1,xFilial("SA2") + _cCliLoj, "A2_RECISS")

		_n++
		aPedCab := {}
		//SC5->C5_NUM:= GetSXENum("SC5")
		//_cNumPed := GetSxeNum("SC5","C5_NUM")
		aAdd(aPedCab,{'C5_FILIAL'  , xFilial("SC5")           , Nil}) //Filial
		aAdd(aPedCab,{'C5_TIPO' ,"B", Nil}) // Tipo de cliente    
		aAdd(aPedCab,{'C5_CLIENTE' , cCodCli                  , Nil}) //Codigo do Cliente
		aAdd(aPedCab,{'C5_LOJACLI' , cLojaCli                 , Nil}) //Loja do Cliente
		aAdd(aPedCab,{'C5_LOJAENT' , cLojaCli                 , Nil}) //Loja do Cliente
		aAdd(aPedCab,{'C5_EMISSAO' , dDatabase, Nil})
		aAdd(aPedCab,{'C5_TIPOCLI' , "F", Nil}) // Tipo de cliente    
		aAdd(aPedCab,{'C5_CONDPAG' , _mv_par03  , Nil})              //Condicao de pagamento da amarracao.
		aAdd(aPedCab,{'C5_DESC1'   , 0    , Nil}) //
		aAdd(aPedCab,{'C5_INCISS'  , "S"  , Nil}) //
		aAdd(aPedCab,{'C5_MENPAD'  ,_mv_par04   , Nil}) //
		aAdd(aPedCab,{'C5_MENNOTA' ,_mv_par06  , Nil}) //
		aAdd(aPedCab,{'C5_TIPLIB'  , "1"  , Nil}) //
		aAdd(aPedCab,{'C5_MOEDA'   , 1    , Nil}) //
		aAdd(aPedCab,{'C5_TPFRETE' , "F"  , Nil}) //
		aAdd(aPedCab,{'C5_TXMOEDA' , 1    , Nil}) //
		aAdd(aPedCab,{'C5_TPCARGA' , "2"  , Nil}) //
		aAdd(aPedCab,{'C5_FORNISS' , ""   , Nil}) //
		aAdd(aPedCab,{'C5_RECISS'  , "2"  , Nil}) //      
		aAdd(aPedCab,{'C5_PESOL'   ,_mv_par07, Nil}) //      
		aAdd(aPedCab,{'C5_PBRUTO'  ,_mv_par08, Nil}) //      
		//		aAdd(aPedCab,{'C5_NATUREZ' , _MV_PAR02                 , Nil}) //Loja do Cliente
		//		aAdd(aPedCab,{'C5_DESCNAT' , Posicione("SED",1,xFilial("SED")+_MV_PAR02,"ED_DESCRIC")	, Nil})
		//		aAdd(aPedCab,{'C5_TABELA'  , SZT->ZT_CODTABP  , Nil})                               // Tabela de Pre็os do Cadastro de Cliente
		_lPrivez := .F.
	EndIf

	CodProd  := SC7->C7_PRODUTO
	_nPrcVen := SC7->C7_PRECO
	
	_nQtdVen := SC7->C7_QUANT
	_nTotal  := (_nPrcVen*_nQtdVen)
	_nIteOrc := SC7->C7_ITEM
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SC7->C7_PRODUTO)
	
	_cSitTrib := Posicione("SB1",1,xFilial("SB1")+CodProd,"B1_ORIGEM")+Posicione("SF4",1,xFilial("SF4")+_mv_par03,"F4_SITTRIB")
	_cItem    := Soma1(_cItem)
	
	aAdd(aPedIte,{'SEQ'          , _n              , Nil})
	aAdd(aPedIte,{'C6_FILIAL'    , xFilial("SC6")  , Nil})
	aAdd(aPedIte,{'C6_ITEM'      , _cItem          , Nil})
	aAdd(aPedIte,{'C6_PRODUTO'   , CodProd , Nil})
	aAdd(aPedIte,{'C6_DESCRI'    , Posicione("SB1",1,xFilial("SB1")+CodProd,"B1_DESC") , Nil})  // Descricao do Produto
	aAdd(aPedIte,{'C6_PRCVEN'    , _nPrcVen	           , Nil})                                  // Pre็o de Venda Unitแrio
	aAdd(aPedIte,{'C6_QTDVEN'    , _nQtdVen                 , Nil})                                  // quant do Item
	aAdd(aPedIte,{'C6_UM'        , Posicione("SB1",1,xFilial("SB1")+CodProd,"B1_UM")  , Nil})   // Unidade conforme Produto
	aAdd(aPedIte,{'C6_TES'       , _mv_par02 , Nil})
	aAdd(aPedIte,{'C6_LOCAL'     , Posicione("SB1",1,xFilial("SB1")+CodProd,"B1_LOCPAD") , Nil})  // Colocar o Local Padrao dos Produtos
	aAdd(aPedIte,{'C6_DESCONT'   , 0 , Nil})
	aAdd(aPedIte,{'C6_COMIS1'    , 0 , Nil})
	aAdd(aPedIte,{'C6_LOJA'      , clojacli        , Nil}) // Loja
	aAdd(aPedIte,{'C6_CLI'       , CCodcli         , Nil}) // Cliente
	aAdd(aPedIte,{'C6_ENTREG'    , _MV_PAR05       , Nil})
	aAdd(aPedIte,{'C6_CLASFIS'   , '1'             , Nil}) // Situacao Tributaria (Origem do Produto + ClassIficao Fiscal da TES)
	aAdd(aPedIte,{'C6_TPOP'      , "F"             , Nil}) //Tipo de Ordem de Producao:= F-Firme ou P-Prevista
	aAdd(aPedIte,{'C6_ABATISS'   , 0               , Nil})
	aAdd(aPedIte,{'C6_QTDLIB'    , 0               , Nil}) // Quantidade Liberada
	//aAdd(aPedIte,{'C6_NUM'     , _cNumPed        , Nil})
	//aAdd(aPedIte,{'C6_VALOR'     , noRound(_nTotal,2) , Nil})					            // Valor Total do Item
	//aAdd(aPedIte,{'C6_CC'        , _MV_PAR01       , Nil}) // Centro de custo
	//aAdd(aPedIte,{'C6_CODPROP'   , SZT->ZT_CODPROP , Nil}) // C๓digo da Proposta
	aAdd(aPedIts, aPedIte)
	aPedIte := {}
	
	dbSelectArea("SC7")
	SC7->(dbSkip())
	
EndDo

If Len(aPedIts) >  0  .And. Len(aPedCab) > 0
	//AAdd(aCabFaz,aPedCab)
	//AAdd(aItemFaz,aPedIts)
	MSExecAuto({|x,y,z|Mata410(x,y,z)}, aPedCab, aPedIts, 3) //Op็ใo para Inclusใo
	
	If lMsErroAuto
		
		Rollbacksx8()
		Mostraerro()
		
	Else
		
		ApMsgInfo("Foi gerado o pedido de vendas No. " + SC5->C5_NUM, " Favor verificar ! ")
		aPedIte := {}
		aPedIts := {}
		aPedCab := {}
		//Confirmsx8()
		
		/*/
		dbselectarea("SZT")
		dbsetorder(1)
		dbgotop()
		dbseek(xfilial("SZT")+cCodOrc)
		
		RecLock("SZT",.F.)
		SZT->ZT_OK := '2'
		SZT->ZT_NUMPVFK := SC5->C5_NUM
		SZT->ZT_NUMSAFK := "SEM SA"
		MsUnlock()
		/*/
		
		MsgInfo("Processamento finalizado")
		
	EndIf
	
EndIf

RestArea(cArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณMicrosiga           บ Data ณ  07/25/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg(cPerg,aRegs)

Local aArea := GetArea()
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return()
