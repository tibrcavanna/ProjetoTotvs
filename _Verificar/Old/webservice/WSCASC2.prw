#Include 'Protheus.ch'
#Include "TBICONN.CH"
#INCLUDE 'APWEBSRV.CH'



WSSERVICE WSCASC2

WSDATA Chave            as String
WSDATA Ret              as String

WSDATA Produto          as String
WSDATA Armazem          as String
WSDATA Quant            as String
WSDATA Data_Ini         as String
WSDATA Data_Fim         as String

WSMETHOD GravaDados

ENDWSSERVICE

WSMETHOD GravaDados WSRECEIVE Chave, Produto, Armazem, Quant, Data_ini, Data_Fim WSSEND Ret WSSERVICE WSCASC2



Local _cCod
Local _cChave     := ALLTRIM(::Chave)

Local _lErro      := .F.
Local _cDescErro:= ""
Local _cLinha     := ""
Local TAB_SC2    := {}

Local _cProduto               := ::Produto
Local _cLocal   := ::Armazem
Local _nQuant   := val(::Quant)
Local _dDtIni   := ctod(::Data_Ini)
Local _dDtFim   := ctod(::Data_Fim)
Local _lConout := .t.
Local aOpenTable      := {"SC2","SB1","SB2","SG1","SC6","SC5","SE1","SHD","SHE","SC3"}
      

if _lConout
	conout("Produto " + _cProduto)
	conout("Local " + _cLocal )
	conout("Quant " + str(_nQuant ) )
	conout("Data Ini " + dtoc(_dDtIni)  )
	conout("Data Fim "+  dtoc(_dDtFim)  )
Endif

RpcClearEnv()
RPCSetType(3)
RPCSetEnv("01","01","","","","",aOpenTable) // Abre todas as tabelas.


::Ret := ""

//If Empty(_cChave) .Or. (! Alltrim(_cChave) $ Alltrim(GetNewPar("MV_XFCHAVE",""))  )
//	_cDescErro  += "$Chave de Acesso Inv�lida"
//	_lErro            := .T.
//Endif


If _lErro         // Em caso de Erro...
	
	if _lConout
		ConOut("Date: " + Dtos(dDatabase) + " - Time: " + Time() + " - FIM INCLUSAO")
		ConOut(_cDescErro)
	Endif
	
	SetSoapFault("", _cDescErro)
	::Ret := _cDescErro
	
	//            U_GRVWSERR(_cChave,_cCodigo+" - "+_cNome+" - "+_cNomeFant,_cDescErro)
	Return .F.
Endif


Aadd( TAB_SC2, { "C2_PRODUTO"          ,  _cProduto       , })
Aadd( TAB_SC2, { "C2_LOCAL"                 , "01"                                    , })
Aadd( TAB_SC2, { "C2_QUANT"               , _nQuant                           , })
Aadd( TAB_SC2, { "C2_DATPRI"    , _dDtIni       , })
Aadd( TAB_SC2, { "C2_DATPRJ"    , _dDtIni       , })
Aadd( TAB_SC2, { "C2_DATPRF"    , _dDtFim       , })

Begin Transaction

if _lConout
	ConOut( Repl( "-", 80 ) )
	ConOut( PadC( "Importacao para a tabela Ordem de Produ��o (SC2) ", 80 ) )
	ConOut( "Inicio: " + Time() )
Endif

lMsErroAuto:= .f.

MSExecAuto({|x,y| MATA650(x,y)},TAB_SC2,3)

If lMsErroAuto
	
	_cErro := ""
	_cErro := "Erro na inclus�o da Ordem de Produ��o  via MSEXECAUTO "+MostraErro()
	
	if _lConout
		ConOut(_cErro)
	Endif
	
	::Ret := _cErro
	
	//            U_GRVWSERR(_cChave,_cCodigo+" - "+_cNome+" - "+_cNomeFant,_cErro)
	
Else
	::Ret := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
	
	if _lConout
		conout(::Ret)
	Endif
Endif

End Transaction

if _lConout
	ConOut("Date: " + Dtos(dDatabase) + " - Time: " + Time() + " - FIM INCLUSAO ORDEM DE PRODU��O "+::Ret)
Endif

RpcClearEnv() // Limpa o environment

Return .T.
                                 


//CLIENT

/* ===============================================================================
WSDL Location    http://localhost:81/ws/WSCASC2.apw?WSDL
Gerado em        04/29/14 01:40:54
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _PRAWPBK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSCASC2
------------------------------------------------------------------------------- */

WSCLIENT WSWSCASC2

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GRAVADADOS

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCHAVE                    AS string
	WSDATA   cPRODUTO                  AS string
	WSDATA   cARMAZEM                  AS string
	WSDATA   cQUANT                    AS string
	WSDATA   cDATA_INI                 AS string
	WSDATA   cDATA_FIM                 AS string
	WSDATA   cGRAVADADOSRESULT         AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSCASC2
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.121227P-20131011] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSCASC2
Return

WSMETHOD RESET WSCLIENT WSWSCASC2
	::cCHAVE             := NIL 
	::cPRODUTO           := NIL 
	::cARMAZEM           := NIL 
	::cQUANT             := NIL 
	::cDATA_INI          := NIL 
	::cDATA_FIM          := NIL 
	::cGRAVADADOSRESULT  := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSCASC2
Local oClone := WSWSCASC2():New()
	oClone:_URL          := ::_URL 
	oClone:cCHAVE        := ::cCHAVE
	oClone:cPRODUTO      := ::cPRODUTO
	oClone:cARMAZEM      := ::cARMAZEM
	oClone:cQUANT        := ::cQUANT
	oClone:cDATA_INI     := ::cDATA_INI
	oClone:cDATA_FIM     := ::cDATA_FIM
	oClone:cGRAVADADOSRESULT := ::cGRAVADADOSRESULT
Return oClone

// WSDL Method GRAVADADOS of Service WSWSCASC2

WSMETHOD GRAVADADOS WSSEND cCHAVE,cPRODUTO,cARMAZEM,cQUANT,cDATA_INI,cDATA_FIM WSRECEIVE cGRAVADADOSRESULT WSCLIENT WSWSCASC2
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GRAVADADOS xmlns="http://localhost:81/">'
cSoap += WSSoapValue("CHAVE", ::cCHAVE, cCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, cPRODUTO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ARMAZEM", ::cARMAZEM, cARMAZEM , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("QUANT", ::cQUANT, cQUANT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATA_INI", ::cDATA_INI, cDATA_INI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DATA_FIM", ::cDATA_FIM, cDATA_FIM , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GRAVADADOS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/GRAVADADOS",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/WSCASC2.apw")

::Init()
::cGRAVADADOSRESULT  :=  WSAdvValue( oXmlRet,"_GRAVADADOSRESPONSE:_GRAVADADOSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


//_________________________________________CONSUMO DO CLIENT

User Function TesteWs()

Local oWs := NIL
Local _lConout := .t.

oWs := WSWSCASC2():New()

oWs:cChave := "CAVANAPCP"

oWs:cProduto := "0101000001"
oWS:cArmazem := "01"
oWS:cQuant := "1"
oWS:cData_Ini := "29/04/14"
oWS:cData_Fim := "29/04/14"

                      
If oWs:GravaDados()

	if _lConout
		conout('RETORNO - Pedido : '+ oWs:cGravaDadosResult)
   	Endif
	
Else
	
	alert('Erro de Execu��o : '+GetWSCError())
	
Endif
                                     
FreeObj(oWs)               
oWs := nil
  
Return
                              



