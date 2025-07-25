#INCLUDE 'PROTHEUS.CH'
#INCLUDE "XMLXFUN.CH"


//____________________________________________//
User Function SELXML()

Local _cMarca 	:= Getmark()
Local _lInverte := .f.
Local _aStruTRBZ2 := {}
Local _oMark
Local _aCpo
Local _cExtension := "*.xml"
Local _aFiles := {}
Local _nx
Local _aCpoBrow := {}
Private _aErros := {}


Private _cPerg := "SELXML"
Private cCadastro  :="Sele��o de Arquivos .XML para Nota Fiscal de Entrada"
Private _nOpca    := 0
Private _cAlias
Private _cPath
Private _cPathTo
Private _lNFE := .t.
Private _lCTENFE := .f.
Private _lICMS := .f.

//VARIAVEIS PARA COMPATIBILIZA��O COM O PONTO DE ENTRADA U_SF1100I e CUSTOMIZA��O QUE TRATA DOS DADOS DO CONTAINER
Private _cCnt := ""
Private _cNCnt := ""

_lFrete := .T.			// Por Josinei L Sobreira (Leste System)


CriaSx1(_cPerg)
Pergunte(_cPerg,.t.)

//formata parametros de diretorio
MV_PAR07 := alltrim(MV_PAR07)
if substr(MV_PAR07,len(MV_PAR07),1) <> "\"
	MV_PAR07 += "\"
Endif
_cPath := MV_PAR07

MV_PAR08 := alltrim(MV_PAR08)
if substr(MV_PAR08,len(MV_PAR08),1) <> "\"
	MV_PAR08 += "\"
Endif
_cPathTo := MV_PAR08
//_________________________________//

ADir(_cPath+_cExtension, _aFiles)

Aadd(_aStruTRBZ2,{"Z2_OK"      	,"C", 2,0})
Aadd(_aStruTRBZ2,{"Z2_FILE"      	,"C", 100,0})

aAdd(_aCpoBrow,{"Z2_OK",,"" ,"@!"})
aAdd(_aCpoBrow,{"Z2_FILE",,"Arquivo XML" ,"@!"})



//CRIA ARQUIVO TEMPORARIO FILTRADO
If Select("TRBZ2") > 0
	TRBZ2->(DbCloseArea())
Endif

_cArqEmp := CriaTrab(_aStruTRBZ2)
dbUseArea(.T.,__LocalDriver,_cArqEmp,"TRBZ2",.F.,.f.)
For _nx := 1 to len(_aFiles)
	
	RecLock("TRBZ2",.T.)
	TRBZ2->Z2_OK := _cMarca
	TRBZ2->Z2_FILE := _aFiles[_nx]
	TRBZ2->(MsUnlock())
	
Next

dbSelectArea("TRBZ2")
DbGoTop()

Define MsDialog _oDlg Title "Sele��o de arquivos XML para Nota de Entrada" From 0,0 To 30,130 Of oMainWnd
_oDlg:lMaximized := .t.
_oDlg:lCentered  := .T.
_oMark := MsSelect():New("TRBZ2"		,"Z2_OK"	,	,_aCpoBrow	,.f.,@_cMarca,{20,1,243,715},,,_oDlg)
_oMark:oBrowse:lhasMark    := .t.
_oMark:oBrowse:lCanAllmark := .t.
_oMark:oBrowse:bAllMark := {|| AInverte(_cMarca,.t.,@_oMark)}
Activate MsDialog _oDlg On Init EnchoiceBar(_oDlg, {||_nOpca:=1, _oDlg:End() }, {||_nOpca:=0,_oDlg:End()}) Centered

If  _nOpca == 1
	
	TRBZ2->(dbGoTop())
	While ! TRBZ2->(eof())
		
		if TRBZ2->Z2_OK == _cMarca
			
			
			if ImpXml(_cPath+TRBZ2->Z2_FILE	)
				
				TransFile()
				
			Endif
			
		Endif
		
		TRBZ2->(dbSkip())
		
	End
	
	//SE HOUVE NOTA NAO IMPORTADA IMPRIME LOG DE ERRO
	if len(_aErros) > 0
		LogErros()
	Endif
	
Endif

Return

//___________________________________//
Static Function AInverte(_cMarca,_lTodos,_oMark)
Local _nReg := TRBZ2->(Recno())
Local _nValor := 0

Default _lTodos  := .T.

DbSelectArea("TRBZ2")
If _lTodos
	DbGoTop()
Endif

While !_lTodos .Or. !Eof()
	
	IF TRBZ2->Z2_OK == _cMarca
		RecLock("TRBZ2",.F.)
		TRBZ2->Z2_OK := Space(02)
		TRBZ2->(MsUnlock())
	Else
		RecLock("TRBZ2",.F.)
		TRBZ2->Z2_OK := _cMarca
		TRBZ2->(MsUnlock())
	EndIf
	
	If _lTodos
		TRBZ2->(dbSkip())
	Else
		Exit
	Endif
	
EndDo


DbGoTo(_nReg)

if _oMark <> NIL
	_oMark:oBrowse:refresh()
Endif

Return

//__________________________________________________//
Static Function ImpXml(_cArquivo)
Private _lRet := .t.

Processa({|_lRet| GetObjXml(_cArquivo) },"Processando...")


//_lRet := GetObjXml(_cArquivo)


Return _lRet


//______________________________________________//
Static Function getObjXML(_cArquivo)
Local cError   := ""
Local cWarning := ""
Local oXml := NIL
Local _aNf := {}
Local _aItens := {}
Local _aNotas := {}

Local _nPosProd , _cXProd, _nx

Local _aSB1_BLQ := {}
Local _aSA2_BLQ := {}

Local cVersao := ""
Local _cSerieNF := GetNewPar('MV_XSERXML',"55")
Local _aEOF_SA5 := {}

Local _lstrzero := GetNewPar('MV_XSELXML1',.t.)

Private _cNumdoc , _cSerie , _dEmissao

ProcRegua(50)

Pergunte(_cPerg,.f.)

cVersao := GetVersion(_cArquivo)

//Gera o Objeto XML
oXml := XmlParser( GeraXML(_cArquivo), "_", @cError, @cWarning )
If (oXml == NIL )
	
	AADD(_aErros, { _cArquivo + " Falha ao gerar Objeto XML "+cError+" / "+cWarning } )
	_lRet := .f.
	
	Return
Endif

// Mostrando a informa��o do Node
if _lNFE
	
	AADD(_aNf , {"EMIT_CNPJ", oXml:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:Text } )
	AADD(_aNf , {"DEST_CNPJ", oXml:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:Text } )
	AADD(_aNf , {"NNF"		, oXml:_nfeProc:_NFe:_infNFe:_Ide:_NNF:Text } )
	AADD(_aNf , {"SERIE"	   , oXml:_nfeProc:_NFe:_infNFe:_Ide:_SERIE:Text } )
	AADD(_aNf , {"DEMI"		, oXml:_nfeProc:_NFe:_infNFe:_Ide:_DHEMI:Text } )
	
	AADD(_aNf , {"XNOME"	, oXml:_nfeProc:_NFe:_infNFe:_dest:_XNOME:Text } )
	AADD(_aNf , {"CHNFE"	, oXml:_nfeProc:_protNFE:_infProt:_chNfe:Text } )
	
	_cCNPJ_MAT := oXml:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:Text
	
Else //CTR
	
	AADD(_aNf , {"EMIT_CNPJ", oXml:_cteProc:_CTe:_infCTe:_emit:_CNPJ:Text } )
	AADD(_aNf , {"DEST_CNPJ", oXml:_cteProc:_CTe:_infCTe:_dest:_CNPJ:Text } )
	AADD(_aNf , {"NNF"		, oXml:_cteProc:_CTe:_infCTe:_Ide:_NCT:Text } )
	AADD(_aNf , {"SERIE"	, oXml:_cteProc:_CTe:_infCTe:_Ide:_SERIE:Text } )
	AADD(_aNf , {"DEMI"		, substr(oXml:_cteProc:_CTe:_infCTe:_Ide:_DHEMI:Text,1,10) } )
	
	AADD(_aNf , {"XNOME"   , oXml:_cteProc:_CTe:_infCTe:_emit:_XNOME:Text } )
	AADD(_aNf , {"REM_CNPJ", oXml:_cteProc:_CTe:_infCTe:_rem:_CNPJ:Text } )
	
	_cCNPJ_MAT := oXml:_cteProc:_CTe:_infCTe:_rem:_CNPJ:Text
	
Endif


_nP := ascan(_aNf, {|x|  x[1] == "NNF"} )

if _lStrZero
	_cNumDoc := strzero( val(_aNf[_nP][2]) ,TamSx3("F1_DOC")[1] )
Else
	_cNumDoc := padr(_aNf[_nP][2] ,TamSx3("F1_DOC")[1] )
Endif


_nP := ascan(_aNf, {|x|  x[1] == "SERIE"} )

if _lStrZero
	_cSerie := strzero(val(_aNf[_nP][2]) , TamSx3("F1_SERIE")[1] )
Else
	_cSerie := padr(_aNf[_nP][2] , TamSx3("F1_SERIE")[1] )
Endif


_nP := ascan(_aNf, {|x|  x[1] == "DEMI"} )
_dEmissao := stod(substr(_aNf[_nP][2],1,4)+substr(_aNf[_nP][2],6,2)+substr(_aNf[_nP][2],9,2) )


//VALIDA EMPRESA DE ENTRADA DA NOTA
//dbSelectArea("SM0")
//locate for SM0->M0_CODIGO == cEmpAnt .and.SM0->M0_CODFIL == cFilAnt

if alltrim(SM0->M0_CGC)  <> alltrim(  _cCNPJ_MAT  )
	
	if ! _lNFE
		
		if alltrim(SM0->M0_CGC)  <> alltrim(  _aNF[2][2]  )
			
			AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  NAO DESTINADA A EMPRESA FILIAL CORRENTE " } )
			
		Endif
		
	Else
		
		AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  NAO DESTINADA A EMPRESA FILIAL CORRENTE " } )
		
	Endif
	
Endif

if len(_aErros) > 0
	_lRet := .f.
	Return
Endif

//-----------------------//
if _lNFE
	
	if valtype(oXml:_nfeProc:_NFe:_infNFe:_det) <> "A"
		
		AADD( _aItens, { {"CPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_cProd:Text, "" },;
		{ "CEAN"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_cEan:Text },;
		{ "XPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_xProd:Text },;
		{ "NCM"		, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_NCM:Text },;
		{ "CFOP"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_CFOP:Text },;
		{ "UCOM"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_uCom:Text },;
		{ "QCOM"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_qCom:Text },;
		{ "VUNCOM"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_vUnCom:Text },;
		{ "VPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_vProd:Text },;
		{ "CEANTRIB", oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_cEanTrib:Text },;
		{ "UTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_uTrib:Text },;
		{ "QTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_qTrib:Text },;
		{ "VUNTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_vUnTrib:Text },;		// { "VFRETE"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_vFrete:Text },;
		{ "INDTOT"	, oXml:_nfeProc:_NFe:_infNFe:_det:_prod:_IndTot:Text }} )
		
		if _lICMS
			
			_nPIcm := TxtGetIcms(oXml, ,'oXml:_nfeProc:_NFe:_infNFe:_det:_IMPOSTO:_ICMS:_ICMSXX:_PICMS:Text')
			
			aadd( _aItens[len(_aItens)] , { "PICMS"	, _nPIcm } )
			
		Endif
		
	Elseif valtype(oXml:_nfeProc:_NFe:_infNFe:_det) == "A"
		
		_nProds := len(oXml:_nfeProc:_NFe:_infNFe:_det)
		
		For _nx := 1 to _nProds
			
			// Alterado por Josinei L Sobreira (Leste System) em 11/05/2017
			// Verifica se a TAG _Frete existe no xml
			If(XmlChildEx(oXml,"_vFrete") = Nil)
				_lFrete := .F.
				AADD( _aItens,{ {"CPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cProd:Text, "" },;
				{"CEAN"    , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cEan:Text },;
				{"XPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_xProd:Text },;
				{"NCM"		, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_NCM:Text },;
				{"CFOP"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_CFOP:Text },;
				{"UCOM"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_uCom:Text },;
				{"QCOM"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_qCom:Text },;
				{"VUNCOM"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vUnCom:Text },;
				{"VPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vProd:Text },;
				{"CEANTRIB", oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cEanTrib:Text },;
				{"UTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_uTrib:Text },;
				{"QTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_qTrib:Text },;
				{"VUNTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vUnTrib:Text },;
				{"INDTOT"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_IndTot:Text } })
			Else
				AADD( _aItens,{ {"CPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cProd:Text, "" },;
				{"CEAN"    , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cEan:Text },;
				{"XPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_xProd:Text },;
				{"NCM"		, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_NCM:Text },;
				{"CFOP"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_CFOP:Text },;
				{"UCOM"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_uCom:Text },;
				{"QCOM"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_qCom:Text },;
				{"VUNCOM"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vUnCom:Text },;
				{"VPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vProd:Text },;
				{"CEANTRIB", oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cEanTrib:Text },;
				{"UTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_uTrib:Text },;
				{"QTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_qTrib:Text },;
				{"VUNTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vUnTrib:Text },;//										 {"VFRETE"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vFrete:Text },;
				{"INDTOT"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_IndTot:Text } })
			EndIf
			
			
			/*
			AADD( _aItens,{ {"CPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cProd:Text, "" },;
			{"CEAN"    , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cEan:Text },;
			{"XPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_xProd:Text },;
			{"NCM"		, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_NCM:Text },;
			{"CFOP"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_CFOP:Text },;
			{"UCOM"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_uCom:Text },;
			{"QCOM"	   , oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_qCom:Text },;
			{"VUNCOM"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vUnCom:Text },;
			{"VPROD"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vProd:Text },;
			{"CEANTRIB", oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_cEanTrib:Text },;
			{"UTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_uTrib:Text },;
			{"QTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_qTrib:Text },;
			{"VUNTRIB"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vUnTrib:Text },;
			{"VFRETE"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_vFrete:Text },;
			{"INDTOT"	, oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_prod:_IndTot:Text } })
			*/
			// EOF altera��o feita Josinei L Sobreira (Leste System)
			
			if _lICMS
				
				_nPIcm := TxtGetIcms(oXml, _nx, 'oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_IMPOSTO:_ICMS:_ICMSXX:_PICMS:Text')
				
				AADD(_aItens[len(_aItens)], { "PICMS"	, _nPIcm } )
				
			Endif
			
			IncProc("Processando itens da Nota de Entrada "+_cNumDoc)
			
		Next
		
	Endif
	
Else
	
	_cProd := RetSB1(MV_PAR02)
	
	_vTPrest :=  oXml:_cteProc:_CTe:_infCTe:_vPrest:_vTPrest:Text
	
	if _lICMS
		_nPIcm := TxtGetIcms(oXml, ,'oXml:_cteProc:_CTe:_infCTe:_Imp:_Icms:_IcmsXX:_pIcms:Text')
		
		_pICMS	 :=  _nPIcm
	Endif
	
	AADD( _aItens, { {"CPROD"	, _cProd , "" },;
	{ "XPROD"	, _cProd },;
	{ "QCOM"	, "1" },;
	{ "VUNCOM"	, _vTPrest },;
	{ "VPROD"	, _vTPrest } })
	
	if _lICMS
		aadd(_aItens[len(_aItens)],{ "PICMS"	, _pICMS } )
	Endif
	
	//_________________________ DADOS DAS NFS RELACIONADAS
	
	
	//_______ ESPECIFICO TOZAN - RETORNA SERIE 55 -SP  OU 56 CAMPINAS
	// SM0 JA ESTA POSICIONADO
	
	/*	if alltrim(SM0->M0_CODFIL) == "01"
	_cSerieNF := "55"
	elseif alltrim(SM0->M0_CODFIL) == "02"
	_cSerieNF := "56"
	Endif
	*/
	//______________________________
	
	if _lCTENFE   //Conhecimento de Transporte com chave da nota fiscal eletronica
		// 23,3  substring para serie
		// 26,9  substring para nf
		
		if cVersao == "1.04"
			
			if valtype(oXml:_cteProc:_CTe:_infCTe:_rem:_infNFe) <> "A"
				
				
				_cChave :=  oXml:_cteProc:_CTe:_infCTe:_rem:_infNFe:_chave:text
				
				//_cSerieNF := substr( _cChave, 23,3)
				
				AADD( _aNotas, { substr( _cChave , 26,9) , _cSerieNF  } )
				
			Else
				
				_nNotas := len(oXml:_cteProc:_CTe:_infCTe:_rem:_infNFe)
				
				For _nx := 1 to _nNotas
					
					_cChave :=  oXml:_cteProc:_CTe:_infCTe:_rem:_infNFe[_nx]:_chave:text
					
					//_cSerieNF := substr( _cChave, 23,3)
					// CASO N�O SEJA TOZAN
					//_cSerieNF := oXml:_cteProc:_CTe:_infCTe:_rem:_infNFe[_nx]:_serie
					
					AADD( _aNotas, { substr( _cChave , 26,9) , _cSerieNF } )
					
					IncProc("Processando itens do Conhecimento de Transporte "+_cNumDoc)
					
				Next
				
			Endif
			
		Elseif cVersao == "2.00"
			
			if valtype(oXml:_cteProc:_CTe:_infCTe:_infCTeNorm:_infDoc:_infNFe) <> "A"
				
				
				_cChave := oXml:_cteProc:_CTe:_infCTe:_infCTeNorm:_infDoc:_infNFe:_chave:text
				
				//_cSerieNF := substr( _cChave, 23,3)
				
				AADD( _aNotas, { substr( _cChave , 26,9) , _cSerieNF  } )
				
			Else
				
				_nNotas := len(oXml:_cteProc:_CTe:_infCTe:_infCTeNorm:_infDoc:_infNFe)
				
				For _nx := 1 to _nNotas
					
					_cChave :=  oXml:_cteProc:_CTe:_infCTe:_infCTeNorm:_infDoc:_infNFe[_nx]:_chave:text
					
					//_cSerieNF := substr( _cChave, 23,3)
					// CASO N�O SEJA TOZAN
					_cSerieNF := oXml:_cteProc:_CTe:_infCTe:_rem:_infNFe[_nx]:_serie
					
					AADD( _aNotas, { substr( _cChave , 26,9) , _cSerieNF } )
					
					IncProc("Processando itens do Conhecimento de Transporte "+_cNumDoc)
					
				Next
				
				
			Endif
			
		Endif
		
	Else // Conhecimento de Transportte com detalhes da nota fiscal - sem chave da nfe
		
		if valtype(oXml:_cteProc:_CTe:_infCTe:_InfCteComp) <> "A"
			
			//  CASO NAO SEJA TOZAN
			_cSerieNF := oXml:_cteProc:_CTe:_infCTe:_rem:_infNF:_serie
			
			_cChave := substr(oXml:_cteProc:_CTe:_infCTe:_InfCteComp:_Chave:Text,35,1)
			AADD( _aNotas, {_cChave , _cSerieNF  } )
			
		Elseif	valtype(oXml:_cteProc:_CTe:_infCTe:_InfCteComp) == "A"
			
			_nNotas := len(oXml:_cteProc:_CTe:_infCTe:_InfCteComp)
			
			For _nx := 1 to _nNotas
				
				// CASO N�O SEJA TOZAN
				_cSerieNF := oXml:_cteProc:_CTe:_infCTe:_rem:_infNF[_nx]:_serie
				
				_cChave := substr(oXml:_cteProc:_CTe:_infCTe:_InfCteComp[_nx]:_Chave:Text,35,1)
				AADD( _aNotas, {_cChave , _cSerieNF } )
				
				IncProc("Processando itens do conhecimento de Transporte "+_cNumDoc)
				
			Next
			
		Endif
		
	Endif
	
	//__________________________________
	
Endif

// VALIDA FORNCEDOR E PRODUTO
dbSelectArea("SA2")
dbSetOrder(3)
if dbSeek(xfilial("SA2")+ _aNF[1][2] )
	
	if SA2->A2_MSBLQL == "1"
		
		//SE FORNECEDOR ESTIVER BLOQUEADO, ARMAZENA NO VETOR PARA DESBLOQUEAR ANTES DA INCLUSAO DA NOTA
		IF MV_PAR05 == 1  //Desbloqueia produto / fornecedor
			AADD(_aSA2_BLQ, SA2->A2_COD)
		Else
			AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  FORNECEDOR : "+SA2->A2_COD+" - "+SA2->A2_NREDUZ + " BLOQUEADO " } )
			_lRet := .f.
		Endif
		
	Else
		
		_lRet := .t.
		For _nx := 1 to len(_aItens)
			
			_nPosProd := ascan(_aItens[_nx], {|x|  x[1] == "CPROD"} )
			_cCPROD := _aItens[_nx][_nPosProd][2]
			
			_nP := ascan(_aItens[_nx], {|x|  x[1] == "XPROD"} )
			_cXPROD := _aItens[_nx][_nP][2]
			
			
			//NORMALIZA VETOR COM CODIGO DO PRODUTO PROTHEUS NA 3A. POSICAO DO VETOR PRODUTO
			//SE MV_PAR01 == CODIGO INTERNO ( 1)  CODIGO DO PRODUTO = XML
			//SE MV_PAR01 == CODIGO EXTERNO ( 2)  BUSCA CODIGO DE SA5 ( PRODUTO X FORNECEDOR )
			
			if MV_PAR01 == 1
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xfilial("SB1")+ _cCPROD )
				if ! SB1->(eof())
					_aItens[_nx][_nPosProd][3] := _cCPROD
				Else
					_lRet := .f.
					
					AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  PRODUTO : "+_cCPROD+" - "+_cXPROD + " NAO ENCONTRADO EM SB1 " } )
					
				Endif
			Else
				
				_cCPROD := ExecQry( SA2->A2_COD , SA2->A2_LOJA , _cCPROD )
				if ! empty(_cCPROD)
					
					_aItens[_nx][_nPosProd][3] := _cCPROD
					
					//________________________VERIFICA PRODUTO EM SB1
					dbSelectArea("SB1")
					dbSetOrder(1)
					if ! dbSeek(xfilial("SB1")+ _cCPROD )
						
						AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  PRODUTO : "+_cCPROD+" - "+_cXPROD + " ENCONTRADO NA TABELA PRODUTO X FORNECEDOR E NAO ENCONTRADO NA TABELA DE PRODUTOS" } )
						
						_lRet := .f.
					Endif
					//___________________________________________________
					
				Else
					_cCPROD := _aItens[_nx][_nPosProd][2]
					if MV_PAR10 == 1
						AADD(_aEOF_SA5, {_cCPROD, _cXPROD  } )
					Else
						AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  PRODUTO : "+_cCPROD+" - "+_cXPROD + " NAO ENCONTRADO EM SA5 " } )
						_lRet := .f.
					Endif
					
				Endif
				
				
			Endif
			
			if _lRet
				//SE PRODUTO ESTIVER BLOQUEADO, ARMAZENA NO VETOR PARA DESBLOQUEAR ANTES DA INCLUSAO DA NOTA
				if SB1->B1_MSBLQL == "1"
					IF MV_PAR05 == 1  //Desbloqueia produto / fornecedor
						AADD(_aSB1_BLQ, SB1->B1_COD)
					Else
						
						AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  PRODUTO : "+_cCPROD+" - "+_cXPROD + " BLOQUEADO " } )
						
						_lRet := .f.
					Endif
				Endif
			Endif
			
		Next
		
	Endif
	
	//VALIDA SE NOTA + SERIE JA EXISTE PARA O FORNECEDOR
	dbSelectArea("SF1")
	dbSetOrder(1)
	if dbSeek(xfilial("SF1")+_cNumDoc+_cSerie+SA2->A2_COD+SA2->A2_LOJA)
		TransFile()
		
		AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+" - NOTA JA CADASTRADA " } )
		
		_lRet := .f.
	Endif
	
	if _lRet
		
		//Verifica se tem produtos nao encontrados em SA5 e MV_PAR10 == 1 (Habilita tela PRODUTO X FORNECEDOR )
		if MV_PAR10 == 1
			
			if len(_aEOF_SA5) > 0
				
				_lRet :=  TelaSA5(_aEOF_SA5,_aItens)
				
				if ! _lRet
					
					For _nx := 1 to len(_aEOF_SA5)
						AADD(_aErros, { iif(_lNFE,"NF ","CTR ")+_cNumDoc+"  SERIE : "+_cSerie+"  PRODUTO : "+_aEOF_SA5[_nx][1]+" - "+_aEOF_SA5[_nx][2] + " NAO ENCONTRADO EM SA5 " } )
					Next
					
				Endif
				
			Endif
			
		Endif
		//______________________________________________________________________________________________
		
		
		_lRet := GeraSF1(_aNF, _aItens , _aSB1_BLQ, _aSA2_BLQ, _aNotas)
	Endif
	
Else
	
	AADD(_aErros, { "Fornecedor NOME - CNPJ "+_aNF[6][2]+" - "+ _aNF[1][2]+" - N�O CADASTRADO NESTA FILIAL  " } )
	
	_lRet := .f.
	
	
Endif

Return


//_______________________________________________//

// fun��o para gerar uma string contendo um xml
Static Function GeraXML(_cArquivo)
Local _cScript := ""
Local _nx := 0
if "CTE"$upper(_cArquivo)
	_lNFE := .F.
Endif

If File(_cArquivo)      

	   nHdlArq := FOPEN(_cArquivo,0)
	   FT_FUSE(_cArquivo)
	   FT_FGOTOP()
	   While (!FT_FEof())
	   	  _cScript += FT_FREADLN()
	   	  FT_FSKIP()
	   EndDo
	   FT_FUSE()
	   FCLOSE(nHdlArq)
 
Endif


if  ! _lNFE .AND. "<INFNFE><CHAVE>"$ Upper(_cScript)
	_lCteNFe := .T.
Endif

For _nx := 0 to 60
	
	_cnIcm := strzero(_nx,2)
	_cIcm := "<ICMS"+_cNicm+">"
	if _cIcm $ UPPER(_cScript)
		_lICMS := .t.
		Exit
	Endif
	
Next


Return _cScript




//_____________________________________________//
Static Function GeraSF1(_aNf, _aItens, _aSB1_BLQ , _aSA2_BLQ, _aNotas)
Local _aItensD1 := {}
Local _aIt := {}
Local _aCab := {}
Local _nP := 0
Local _lret := .t.
Local _dDtBase := ctod("")
Local _nx

//	LJ720NOTA(@cSerie, @cNumDoc) // pega numero da NF de entrada.

pergunte(_cPerg,.f.)


_aCab := {{ "F1_DOC" , _cNumDoc       	, Nil },;
{ "F1_SERIE" 	, _cSerie        	, Nil },;
{ "F1_FORNECE"	, SA2->A2_COD   	, Nil },;
{ "F1_LOJA"   	, SA2->A2_LOJA		, Nil },;
{ "F1_COND"   	, MV_PAR04         	, Nil },;
{ "F1_EMISSAO"	, _dEmissao      	, Nil },;
{ "F1_EST"    	, SA2->A2_EST      	, Nil },;
{ "F1_TIPO"   	, "N"            	, Nil },;
{ "F1_FORMUL" 	, "N"            	, Nil },;
{ "F1_ESPECIE"	, alltrim(MV_PAR11)	, Nil },;
{ "F1_CHVNFE"	, _aNf[7,2]			, Nil },;
{ "E2_NATUREZ"	, MV_PAR03   		, Nil }}


For _nx := 1 to len(_aItens)
	
	_nP := ascan(_aItens[_nx], {|x|  x[1] == "CPROD"} )
	_cD1_COD := _aItens[_nx][_nP][3]
	
	_nP := ascan(_aItens[_nx], {|x|  x[1] == "QCOM"} )
	_nD1_QUANT := val(_aItens[_nx][_nP][2])
	
	_nP := ascan(_aItens[_nx], {|x|  x[1] == "VUNCOM"} )
	_nD1_VUNIT := val(_aItens[_nx][_nP][2])
	
	_nP := ascan(_aItens[_nx], {|x|  x[1] == "VPROD"} )
	_nD1_TOTAL := val(_aItens[_nx][_nP][2])
	
	_nP := ascan(_aItens[_nx], {|x|  x[1] == "VFRETE"} )
	//		Alterado por Josinei L Sobreira (Leste System) em 11/05/2017
	//		Para caso n�o tenha TAG _VFRETE
	//		_nD1_VALFRE := val(_aItens[_nx][_nP][2])
	If _lFrete
	 //	_nD1_VALFRE := val(_aItens[_nx][_nP][2])
	Else
		//_nD1_VALFRE := 0
	EndIf
	//		EOF altera��o
	
	if _lICMS
		_nP := ascan(_aItens[_nx], {|x|  x[1] == "PICMS"} )
		_nD1_PICMS := val(_aItens[_nx][_nP][2])
		AAdd( _aItensD1, { "D1_PICM"    , _nD1_PICMS   	, Nil})
	Endif
	
	AAdd( _aItensD1, { "D1_DOC"    	, _cNumDoc	   	, Nil})
	AAdd( _aItensD1, { "D1_ITEM"    , strzero(_nx,4), Nil})
	AAdd( _aItensD1, { "D1_COD"     , _cD1_COD   	, Nil})
	AAdd( _aItensD1, { "D1_QUANT"   , _nD1_QUANT 	, Nil})
	AAdd( _aItensD1, { "D1_VUNIT"   , _nD1_VUNIT 	, Nil})
//	AAdd( _aItensD1, { "D1_VALFRE"   , _nD1_VALFRE 	, Nil})
	AAdd( _aItensD1, { "D1_TOTAL"   , _nD1_TOTAL 	, Nil})
	AAdd( _aItensD1, { "D1_TES"     , 	MV_PAR02    , Nil})
	AAdd( _aItensD1, { "D1_TIPO"    , "N"           , Nil})
	
	_aItensD1 :=SlVetSX3(_aItensD1,"SD1")
	
	AAdd(_aIt,_aItensD1)
	_aItensD1 := {}
	
Next



//DESBLOQUEIA PRODUTOS
Bloqueia(_aSB1_BLQ, _aSA2_BLQ ,.F.)

Begin Transaction
lMsErroAuto := .F.

//_dDtBase := dDataBase
//dDataBase := _dEmissao

//Condi��o temporaria utilizada para importar ctrc de Maio com fechamento de estoque em 30/06
/*if month(_dEmissao) == 5 .and. year(_dEmissao) = 2014
_dUlMes := GETMV("MV_ULMES")
PUTMV("MV_ULMES",_dUlMes-30)
_aCab[6][2] := ctod("02/06/2014")
dDataBase := _aCab[6][2]
Endif
*/
if _lNfe
	
	if MV_PAR09 == 1
		MsExecAuto({|x,y,z,w|Mata103(x,y,z,w)},_aCab, _aIt,3, MV_PAR06 == 1  )
	Elseif MV_PAR09 == 2
		MsExecAuto({|x,y,z,w|Mata140(x,y,z,w)},_aCab, _aIt,3  )
	Endif
	
eNDIF

//dDataBase := _dDtBase

//_______________________________________________
if month(_dEmissao) == 5 .and. year(_dEmissao) = 2014
	PUTMV("MV_ULMES",_dUlMes)
Endif



//BLOQUEIA PRODUTOS
Bloqueia(_aSB1_BLQ, _aSA2_BLQ ,.t.)

If lMsErroAuto
	
	MostraErro(_cPath + alltrim(_cNumdoc) + alltrim(_cSerie) + ".ERR")
	//MostraErro()
	
	AADD(_aErros, { iif(_lNFE,"NF : ","CTR : ")+_cNumDoc+"  SERIE : "+_cSerie+" ERRO MSEXECAUTO "+alltrim(_cPath)+alltrim(_cNumdoc)+alltrim(_cSerie)+".ERR" } )
	
	_lret := .f.
	
Else
	
	if ! _lNFE
		
		If ExistBlock("XVINCNFS")
			Execblock("XVINCNFS",.F.,.F.,{SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_FILIAL, SF1->F1_VALBRUT, _aNotas })
		Endif
		
	Endif
	
Endif

End Transaction


Return(_lRet)


//______________________________________//
Static Function LogErros()

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "LOG DE ERROS IMPORTACAO XML PARA SD1"
Local cPict          := ""
Local titulo       := "LOG DE ERROS IMPORTACAO XML PARA SD1"
Local nLin         := 80

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "NOME" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

//_________________________________________//
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem
Local _nx

SetRegua(len(_aErros))

For _nx := 1 to len(_aErros)
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	
	@nLin,00 PSAY _aErros[_nx][1]
	
	nLin := nLin + 1 // Avanca a linha de impressao
	
Next

If aReturn[5]==1
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



//_________________________________________________//

Static Function CriaSX1(_cPerg)

Local _aArea := GetArea()
Local aRegs := {}
Local _i

_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)

_cPerg := padr(_cPerg,len(SX1->X1_GRUPO))

Aadd(aRegs,{_cPerg,"01" ,"Codigo (I)nterno / (E)xterno" 	,"mv_ch1" ,"N" ,01, 0, "C","mv_par01","","Interno","Externo",""})
Aadd(aRegs,{_cPerg,"02" ,"TES"  		       				,"mv_ch2" ,"C" ,03, 0, "G","mv_par02","SF4","","",""})
Aadd(aRegs,{_cPerg,"03" ,"NATUREZA"      					,"mv_ch3" ,"C" ,10, 0, "G","mv_par03","SED","","",""})
Aadd(aRegs,{_cPerg,"04" ,"COND. PAGAMENTO" 					,"mv_ch4" ,"C" ,03, 0, "G","mv_par04","SE4","","",""})
Aadd(aRegs,{_cPerg,"05" ,"Desbloqueia produto / Fornecedor"	,"mv_ch5" ,"N" ,01, 0, "C","mv_par05","","Sim","Nao",""})
Aadd(aRegs,{_cPerg,"06" ,"Visualiza Nota ? "				,"mv_ch6" ,"N" ,01, 0, "C","mv_par06","","Sim","Nao",""})
Aadd(aRegs,{_cPerg,"07" ,"Diretorio Origem xml "			,"mv_ch7" ,"C" ,99, 0, "G","mv_par07","","","",""})
Aadd(aRegs,{_cPerg,"08" ,"Diretorio Destino xml "			,"mv_ch8" ,"C" ,99, 0, "G","mv_par08","","","",""})
Aadd(aRegs,{_cPerg,"09" ,"Documento de Entrada / Pr�-Nota"	,"mv_ch9" ,"N" ,01, 0, "C","mv_par09","","Documento de Entrada","Pre-Nota",""})
Aadd(aRegs,{_cPerg,"10" ,"Habilita Produto X Fornecedor"	,"mv_chA" ,"N" ,01, 0, "C","mv_par10","","Sim","Nao",""})
Aadd(aRegs,{_cPerg,"11" ,"Especie do Documento"				,"mv_chB" ,"C" ,04, 0, "G","mv_par11","","","",""})


DbSelectArea("SX1")
DbSetOrder(1)

For _i := 1 To Len(aRegs)
	If  !DbSeek(aRegs[_i,1]+aRegs[_i,2])
		RecLock("SX1",.T.)
		Replace X1_GRUPO   with aRegs[_i,01]
		Replace X1_ORDEM   with aRegs[_i,02]
		Replace X1_PERGUNT with aRegs[_i,03]
		Replace X1_VARIAVL with aRegs[_i,04]
		Replace X1_TIPO	   with aRegs[_i,05]
		Replace X1_TAMANHO with aRegs[_i,06]
		Replace X1_PRESEL  with aRegs[_i,07]
		Replace X1_GSC	   with aRegs[_i,08]
		Replace X1_VAR01   with aRegs[_i,09]
		Replace X1_F3	   with aRegs[_i,10]
		Replace X1_DEF01   with aRegs[_i,11]
		Replace X1_DEF02   with aRegs[_i,12]
		Replace X1_DEF03   with aRegs[_i,13]
		MsUnlock()
	EndIF
Next _i

RestArea(_aArea)

Return


//______________________________________________//
Static Function Bloqueia(_aSB1_BLQ, _aSA2_BLQ,_lBloqueia)
Local _aArea := GetArea()
Local _nx

For _nx := 1 to len(_aSB1_BLQ)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	if dbSeek(xfilial("SB1")+_aSB1_BLQ[_nx])
		
		Reclock("SB1",.F.)
		SB1->B1_MSBLQL := IIF(_lBloqueia, "1" , "2" )
		SB1->(MsUnlock())
	Endif
Next


For _nx := 1 to len(_aSA2_BLQ)
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	if dbSeek(xfilial("SA2")+_aSA2_BLQ[_nx])
		
		Reclock("SA2",.F.)
		SA2->A2_MSBLQL := IIF(_lBloqueia, "1" , "2" )
		SA2->(MsUnlock())
	Endif
Next


RestArea(_aArea)
Return


//_________________________________________//
Static Function TransFile( )

COPY FILE &(_cPath + TRBZ2->Z2_FILE) TO  &(_cPathTo + TRBZ2->Z2_FILE)
FERASE( _cPath + TRBZ2->Z2_FILE )

Return


//_________________________________________//
Static Function RetSB1(_cTE)
Local _cB1_COD := ""

Iif(Select("SB1TMP")>0,SB1TMP->(DbCloseArea()),)

cQuery := " SELECT B1_COD "
cQuery += " FROM "+RetSqlName("SB1")+" "
cQuery += " WHERE B1_FILIAL='"+xfilial("SB1")+"' AND "
cQuery += " B1_TE = '"+_cTE+"' AND "
cQuery += " D_E_L_E_T_<>'*' "
cQuery += " ORDER BY B1_COD "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SB1TMP",.T.,.T.)

SB1TMP->(dbGoTop())
_cB1_COD := SB1TMP->B1_COD
SB1TMP->(dbCloseArea())

Return(_cB1_COD)



// Funcao para ordenar vetor do execauto de acordo com SX3
Static  Function SLVetSX3(_aVetor,_cAlias)
Local _aTmpExec := {}

//ORDENA VETOR QUE SERA UTILIZADO POR MSEXECAUTO
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(_cAlias)
While !Eof().And.(x3_arquivo==_cAlias)
	
	_nPos := aScan(_aVetor,{|x| alltrim(x[1]) == alltrim(X3_CAMPO)})
	
	If _nPos > 0
		
		AADD(_aTmpExec,{_aVetor[_nPos][1], _aVetor[_nPos][2],_aVetor[_nPos][3]   })
		
	Endif
	
	SX3->(dbSkip())
	
End

_aVetor := {}
_aVetor := _aTmpExec

Return(_aVetor)




Static Function GetVersion(_cArquivo)
Local _cVersao := ""
Local _cScript
Local _cWord

If File(_cArquivo)
	nHdlArq := FOPEN(_cArquivo,0)
	FT_FUSE(_cArquivo)
	FT_FGOTOP()
	While (!FT_FEof())
		_cScript := FT_FREADLN()
		
		_cWord := 'versao="'
		_nPos := at(_cWord,_cScript)
		_nPos += ( len(_cWord)-1 )
		
		if _nPos > 0
			
			_cVersao := substr(_cScript,_nPos+1,4)
			exit
			
		Endif
		
		FT_FSKIP()
	EndDo
	FT_FUSE()
	FCLOSE(nHdlArq)
Endif

Return(_cVersao)



/*/{Protheus.doc} ExecQry
(long_description)
@type function
@author Administrador
@since 14/12/2015
@version 1.0
@param _cFornece, ${param_type}, (Descri��o do par�metro)
@param _cLoja, ${param_type}, (Descri��o do par�metro)
@param _cCodPrf, ${param_type}, (Descri��o do par�metro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ExecQry(_cFornece, _cLoja, _cCodPrf)
Local _cProduto := ''
Local _cAlias := GetNextAlias()

BeginSql Alias _cAlias
	
	SELECT A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO
	FROM %Table:SA5% (Nolock)
	WHERE %NotDel%
	AND A5_FILIAL 	= %xfilial:SA5%
	AND A5_FORNECE 	= %Exp:_cFornece%
	AND A5_LOJA 	= %Exp:_cLoja%
	AND A5_CODPRF 	= %Exp:_cCodPrf%
	
EndSql

(_cAlias)->(dbGoTop())
if ! (_cAlias)->(eof())
	
	_cProduto := (_cAlias)->A5_PRODUTO
	
Endif

(_cAlias)->(dbCloseArea())

Return(_cProduto)





/*/{Protheus.doc} TelaSA5
//Tela para amarra��o produto fornecedor
@author Administrador
@since 29/02/2016
@version 6
@param _aEOF_SA5, , descricao
@type function
/*/
Static Function TelaSA5(_aEOF_SA5,_aItens)
Local _lRet := .t.

Local nOpc := GD_INSERT+GD_DELETE+GD_UPDATE
Local _aArea := GetArea()


Private aCoBrw1 := {}
Private aHoBrw1 := {}
Private noBrw1  := 0

Private oDlg1,oSay1,oGet1,oBrw1

//______________________ CALCULOS DE COORDENADAS DOS OBJETOS
aSizeAut := MsAdvSize()

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

aObjects := {}

AAdd( aObjects, { 100, 50, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t. } )

aPosObj := MsObjSize( aInfo, aObjects )
//_______________________ FIM DAS ROTINAS DE CALCULO DE COORDENADAS DOS OBJETOS




oDlg1      := MSDialog():New( aSizeAut[7],0 , aSizeAut[6],aSizeAut[5],"Amarra��o Produto X Fornecedor",,,.F.,,,,,,.T.,,,.T. )

oSay1      := TSay():New( aPosObj[1,1]+000,aPosObj[1,2]+000,{||"Fornecedor"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( aPosObj[1,1]+012,aPosObj[1,2]+000,{||"Loja"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( aPosObj[1,1]+024,aPosObj[1,2]+000,{||"Raz�o Social"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,036,008)
oSay4      := TSay():New( aPosObj[1,1]+000,aPosObj[1,2]+040,{||SA2->A2_COD},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay5      := TSay():New( aPosObj[1,1]+012,aPosObj[1,2]+040,{||SA2->A2_LOJA},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,033,008)
oSay6      := TSay():New( aPosObj[1,1]+024,aPosObj[1,2]+040,{||SA2->A2_NOME},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

MHoBrw1()
MCoBrw1(_aEOF_SA5)

oBrw1      := MsNewGetDados():New(aPosObj[2,1],	aPosObj[2,2], aPosObj[2,3], aPosObj[2,4],nOpc,'AllwaysTrue()','AllwaysTrue()','', ,0,99,'AllwaysTrue()','','AllwaysTrue()',oDlg1,aHoBrw1,aCoBrw1 )

oDlg1:Activate(,,,.T.,,,EnchoiceBar(oDlg1, {|| _lRet := .t., TelaSA5a(_aItens), oDlg1:End() } , {|| _lRet := .f.,  oDlg1:End()},,/*_aButtons*/) )

RestArea(_aArea)

Return(_lRet)


/*/{Protheus.doc} TelaSA5a
//Grava GetDados de TElaSA5()
@author Administrador
@since 29/02/2016
@version 6

@type function
/*/
Static Function TelaSA5a(_aItens)
Local nI
Local _nPPRODUTO	:= ascan(aHoBrw1,{|x| alltrim(x[2]) == 'A5_PRODUTO'  	})
Local _nPCODPRF		:= ascan(aHoBrw1,{|x| alltrim(x[2]) == 'A5_CODPRF'   	})
Local _nx

For nI := 1 to len(oBrw1:aCols)
	
	
	
	
	if !empty(oBrw1:aCols[nI,_nPProduto])
		
		For _nx := 1 to len(_aItens)
			_nPos := ascan( _aItens[_nx] , {|x|  alltrim(x[2]) == alltrim( oBrw1:aCols[nI,_nPCodPrf] )   } )
			if _nPos > 0
				Exit
			Endif
		Next
		
		_cProduto 	:= oBrw1:aCols[nI,_nPProduto]
		_cCodPrf	:= oBrw1:aCols[nI,_nPCodPrf]
		
		_aItens[_nx][_nPos][3] := _cProduto
		
		SA5->(dbSetOrder(1))
		if ! SA5->(dbSeek(xfilial('SA5')+SA2->A2_COD+SA2->A2_LOJA+_cProduto ))
			
			Reclock("SA5",.T.)
			SA5->A5_FILIAL 	:= xfilial('SA5')
			SA5->A5_FORNECE := SA2->A2_COD
			SA5->A5_LOJA 	:= SA2->A2_LOJA
			SA5->A5_PRODUTO	:= _cProduto
			SA5->A5_CODPRF	:= _cCodPrf
			SA5->(MsUnlock())
			
		Else
			
			Reclock("SA5",.F.)
			SA5->A5_CODPRF	:= _cCodPrf
			SA5->(MsUnlock())
			
		Endif
		
	Endif
	
	
	
	
	
	
Next


Return


/*/{Protheus.doc} MHoBrw1
//Function  � MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias:
@author Administrator
@since 29/12/2015
@version undefined

@type function
/*/
Static Function MHoBrw1()
Local _aCampos := {'A5_PRODUTO','B1_DESC','A5_CODPRF'}
Local _aEditavel := {'A5_PRODUTO'}
Local _nx

For _nX := 1 to len(_aCampos)
	DbSelectArea("SX3")
	DbSetOrder(2)
	
	if DbSeek(_aCampos[_nx])
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
			
			noBrw1++
			Aadd(aHoBrw1,{Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"",;
			"",;
			SX3->X3_TIPO,;
			"",;
			"",;
			"",;
			"",;
			,;
			IIF(ascan(_aEditavel,alltrim(SX3->X3_CAMPO))>0,'A','V' )    } )
			
		Endif
	EndIf
Next


Return


/*/{Protheus.doc} MCoBrw1
//Function  � MCoBrw1() - Monta aCols da MsNewGetDados para o Alias:
@author Administrator
@since 29/12/2015
@version undefined
@param _nTipo, , descricao
@type function
/*/
Static Function MCoBrw1(_aEOF_SA5)

Local aAux := {}
Local nI
Local _nPPRODUTO	:= ascan(aHoBrw1,{|x| alltrim(x[2]) == 'A5_PRODUTO'  	})
Local _nPDESC		:= ascan(aHoBrw1,{|x| alltrim(x[2]) == 'B1_DESC'	  	})
Local _nPCODPRF		:= ascan(aHoBrw1,{|x| alltrim(x[2]) == 'A5_CODPRF'   	})
Local noBrw1		:= len(aHoBrw1)

aCoBrw1 := {}
For nI = 1 to len(_aEOF_SA5)
	
	Aadd(aCoBrw1,Array(noBrw1+1))
	_nLin := len(aCoBrw1)
	
	aCoBrw1[_nLin][_nPPRODUTO] 		:= space(TamSx3('A5_PRODUTO')[1])
	aCoBrw1[_nLin][_nPDESC] 		:= _aEOF_SA5[nI,2]
	aCoBrw1[_nLin][_nPCODPRF] 		:= _aEOF_SA5[nI,1]
	aCoBrw1[_nLin][noBrw1+1]			:= .f.
	
Next

Return



/*/{Protheus.doc} TxtGetIcms
//TODO Descri��o auto-gerada.
@author ricardo.cavalini
@since 26/09/2016
@version undefined
@param _cTxt, , descricao
@type function
/*/
Static Function TxtGetIcms(oXml, _nx, _cTxt)
Local _nPerIcms := 0
Local _cnIcm
Local _cTag := ''
Local _cImposto := ''
Local oICMS
Local _ny

Default _nx := 0

//'oXml:_nfeProc:_NFe:_infNFe:_det[_nx]:_IMPOSTO:_ICMS:_ICMSXX:_PICMS:Text'
//'oXml:_nfeProc:_NFe:_infNFe:_det:_IMPOSTO:_ICMS:_ICMSXX:_PICMS:Text'

_cImposto := substr(_cTxt, 1, at('_IMPOSTO', _cTxt )+ len('_IMPOSTO')-1   )

oICMS := XmlChildEx(&_cImposto, "_ICMS")

_cIcms := varinfo("Array", oICMS)

For _ny := 0 to 60
	
	_cnIcm := strzero(_ny,2)
	IF _ny = 40  //incluido erro ARMI
	else		//incluido erro ARMI
		_cTag := "_ICMS"+_cnIcm
		if _cTag $ UPPER(_cIcms)
			Exit
		Endif
	Endif		//incluido erro ARMI
Next

_cTxt := strtran(_cTxt,'_ICMSXX',_cTag)
if _cTag = '_ICMS60' //incluido erro ARMI
	_nPerIcms := 18
Else				//incluido erro ARMI
	_nPerIcms := &_cTxt
Endif				//incluido erro ARMI
Return(_nPerIcms)
