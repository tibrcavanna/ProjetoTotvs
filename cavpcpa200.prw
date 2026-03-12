#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "dbtree.ch"
#INCLUDE "TBICONN.CH"

USER FUNCTION ADFG()

	If Select("SX6") == 0
		RpcSetType(3)
		RpcSetEnv("01",'0101')
	Endif


	U_CAVPCPA200('','\temp\estru1.csv')

RETURN
/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³   AMBESTRUB  ³ Autor ³ FERNANDO          ³ Data ³ 09/2003  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³  													      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³  				                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
User function CAVPCPA200()
	Private nLin	   := 2
	Private cCadastro  := "Importador de estrutura de produto"
	Private Pg   	   := PADR("CAVPCPA200",LEN(SX1->X1_GRUPO))
	PRIVATE lAuto      := .F.
	PRIVATE aErro      := {}
	PRIVATE oSelf
	PRIVATE bProcesso  := {|oSelf| AMESTRUB(oSelf,MV_PAR01)}
	PRIVATE aInfoCustom:= {}
	Private cDescricao := " Este programa tem como objetivo cadastrar a Bill Of Material de um produto "
//	Private Arq        := '\temp\estru1.csv'
//	ValidPerg(Pg)
	tNewProcess():New( "AMBESTRUB" , cCadastro , bProcesso , cDescricao ,Pg,,,,,.T.,.F. )
return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³   AMBESTRUB  ³ Autor ³ FERNANDO          ³ Data ³ 09/2003  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³  													      ³±±
	±±³          ³                                                            ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³  				                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function AMESTRUB(oSelf,arq)
	Local _cArq	   		:= UPPER(Arq)
	Local nHandle 		:= FT_FUSE(_cArq)
	Local aHeader		:= {}
	Local _aDados  		:= {}
	Local _aProd		:= {}
	Local aAutoCab		:= {}
	Local aAutoItem		:= {}
	Local _aSG1			:= {}
	Local _cLinha		:= ""
	Local _cCodPA		:= ""
	Local _cPaiEstr 	:= ""

	Local wConta		:= 0
	Local lSB1    		:= .F.
	Local lSG1    		:= .F.
	Local lOk			:= .F.
	Local lContinua		:= .F.
	Local _cTipo		:= 'Arquivo Texto (*.CSV) |*.CSV|'

	Local nAux          := 0
	Local cLogTxt       := ""

	Private cFile       := "\temp\"+"CreateSB1_"+dtos(DATE())+"_"+STRTRAN(time(),':','')+".txt" //MV_PAR02
	Private _cCodSB1   := ''
	Private _nB1XEMP   :=  0
	Private _nB1FABRIC :=  0
	Private _nB1BASE3  :=  0
	Private _nB1XGRUPO :=  0
	Private _nB1XCODOBR:=  0
	Private _nB1XCOD:=  0
	Private _nB1DESC   :=  0
	Private _nB1TIPO   :=  0
	Private _nB1GRUPO  :=  0
	Private _nB1UM	   :=  0
	Private _nB1POSIPI :=  0
	Private _nB1QB     :=  0
	Private _nG1COMP   :=  0
	Private _nG1QUANT  :=  0
	Private _nG1FIM    :=  0
	Private _nG1ZZTAG  :=  0
	Private _nG1TRT    :=  0
	Private nLin 	   :=  1
	Private i		   :=  0
	Private aAutoCab   := {}
	Private aAutoItem  := {}


	Private lMsHelpAuto    := .T.
	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.



	Public Inclui	   :=.T.
	Public Altera      :=.T.
	default lSche	   :=.F.
	If !File(_cArq)
		MsgStop("O arquivo " +_cArq + " não foi encontrado. A importação será abortada!","[AMBEST01] - ATENÇÃO")
		Return
	EndIf

	IF lSche
		oSelf:SaveLog("arquivo: "+_cArq)
	ENDIF
	_cLinha := FT_FREADLN()
	aHeader  := split(_cLinha,";")
	lContinua:= xHeaders(aHeader)

	IF lContinua

		nTotal := FT_FLastRec()

		FT_FGOTOP()
		FT_FSKIP()

		While !FT_FEOF()
			IF !lSche
				oSelf:SetRegua1( nTotal )
				oSelf:SetRegua2( nTotal )
			ENDIF
			_cLinha := FT_FREADLN()
			AADD(_aDados,split(_cLinha,";"))
			FT_FSKIP()
		EndDo

		dbselectarea('SG1')
		DBSETORDER(2)

		For i:=1 to Len(_aDados)
			nLin++
			IF !lSche
				oSelf:IncRegua1("G1_COD: " +ALLTRIM(_aDados[i,1]) )
				oSelf:IncRegua2("G1_COMP " +ALLTRIM(_aDados[i,2]) )

				If oSelf:lEnd
					Break
				EndIf
			ENDIF
			dbselectarea('SB1')
			DBSETORDER(1)
			lOk := .T.
			_cCodSB1:= PADR(_aDados[i,_nB1XCOD],TAMSX3('G1_COD')[1])
			lSB1    := IF (SB1->(dbSeek(xFilial("SB1")+_cCodSB1)),.T.,.F.)
			// Verificar se existe estrutura para o produto, não carregar novamente.
			DbSelectArea("SG1")
			DbSetOrder(1)
			if !SG1->(dbSeek(xFilial("SG1")+_cCodSB1)) .and. SB1->B1_MSBLQL != "1"
				IF lSB1
					_nQtdBase := 1
					_cCodSB1  := SB1->B1_COD

					dbselectarea('SB1')
					DBSETORDER(1)
					_cCodSG1:= PADR(_aDados[i,_nG1COMP],TAMSX3('B1_COD')[1])
					lSB1    := IF (SB1->(dbSeek(xFilial("SB1")+_cCodSG1)),.T.,.F.)
					_nQuant := 0

					IF lSB1 .and. AllTrim(_cCodSG1) != AllTrim(_cCodSB1) .and. SB1->B1_MSBLQL != "1"

						_cCodSG1:= SB1->B1_COD
						DbSelectArea("SG1")
						DbSetOrder(2)

						IF !SG1->(dbSeek(xFilial("SG1")+_cCodSG1+_cCodSB1))  // Incluir somente novas estruturas
//						IF !SG1->(dbSeek(xFilial("SG1")+_cCodSG1))
							_aSG1:={}
							AADD(_aSG1,{"G1_COD"    ,_cCodSB1        ,NIL} )
							AADD(_aSG1,{"G1_INI"    ,DATE()          ,NIL} )
							AADD(_aSG1,{"G1_NIV"	,"01"            ,NIL} )
							AADD(_aSG1,{"G1_NIVINV" ,"99"            ,NIL} )
//						AADD(_aSG1,{"G1_FIM"	,CTOD("31/12/49"),NIL} )
							AADD(_aSG1,{"G1_FIM"	,stod(_aDados[i,_nG1FIM]),NIL} )
							IF _nG1COMP>0
								AADD(_aSG1,{"G1_COMP",_cCodSG1,NIL} )
							endif
							IF _nG1TRT>0
								AADD(_aSG1,{"G1_TRT",PADR(_aDados[I,_nG1TRT],TAMSX3('G1_TRT')[1]),NIL} )
							endif
							IF _nG1QUANT>0
								AADD(_aSG1,{"G1_QUANT",VAL(StrTran(_aDados[I,_nG1QUANT],",",".")),NIL} )
								_nQuant := VAL(StrTran(_aDados[I,_nG1QUANT],",","."))
							endif
							if _nQuant != 0
								AADD(aAutoItem,aClone(_aSG1))
							endif

						else
							Gravalog(cFile,'[JACADASTRADO] Linha '+cvaltochar(nLin)+ ' - Componente '+ _cCodSG1 + 'já cadastrado na estrutura do produto '+ _cCodSB1 )
						endif
					elseif SB1->B1_MSBLQL == "1"
						Gravalog(cFile,'[COMP_BLOQUEADO] Linha '+cvaltochar(nLin)+ ' -  Componente bloqueado no cadastro de produto (B1_COD): '+_cCodSG1)
					elseif !lSB1
						Gravalog(cFile,'[NAOENCONTRADO] Linha '+cvaltochar(nLin)+ ' -  Componente não encontrado no cadastro de produto (B1_COD): '+_cCodSG1)
					endif
				endif

				IF Len(_aDados) == i .or. _aDados[i,_nB1XCOD] != _aDados[i+1,_nB1XCOD]

					aAutoCab := {	{"G1_COD"	,alltrim(_cCodSB1)	,NIL},;
						{"G1_QUANT"	,_nQtdBase	        ,NIL},;
						{"NIVALT"	,"N"		        ,NIL}}

					MSExecAuto({|x,y,z| pcpa200(x,y,z)},aAutoCab,aAutoItem,3)

					If lMsErroAuto

						//Pegando log do ExecAuto
						aLogAuto := GetAutoGRLog()
						cLogTxt       := ""

						//Percorrendo o Log e incrementando o texto (para usar o CRLF você deve usar a include "Protheus.ch")
						For nAux := 1 To Len(aLogAuto)
							cLogTxt += aLogAuto[nAux] + CRLF
						Next

						//Mostraerro()
						Gravalog(cFile,'[NAOCADASTRADO] Linha '+cvaltochar(nLin)+ ' - Componente não cadastrado: '+_aDados[I,_nG1COMP])
						Gravalog(cFile,cLogTxt)
					Else
						Gravalog(cFile,'[CADASTRADO_OK] Linha '+cvaltochar(nLin)+ ' - Componente cadastrado com Sucesso: '+_aDados[I,_nG1COMP])
						lOK:=.T.
					EndIf

					lMsHelpAuto := .T.
					lMsErroAuto := .F.
					aAutoCab :={}
					aAutoItem:={}
				endif
			elseif SB1->B1_MSBLQL == "1"
				Gravalog(cFile,'[PROD_BLOQUEADO] Linha '+cvaltochar(nLin)+ ' -  Produto bloqueado no cadastro de produto (B1_COD): '+_cCodSG1)
				
				// Se já existe estrutura gravar o componente
			else
				dbselectarea('SB1')
				DBSETORDER(1)
				_cCodSG1:= PADR(_aDados[i,_nG1COMP],TAMSX3('B1_COD')[1])
				lSB1    := IF (SB1->(dbSeek(xFilial("SB1")+_cCodSG1)),.T.,.F.)
				_nQuant := 0

				IF lSB1 .and. AllTrim(_cCodSG1) != AllTrim(_cCodSB1) .and. SB1->B1_MSBLQL != "1"
					
					_nQuant := VAL(StrTran(_aDados[I,_nG1QUANT],",","."))
					_cCodSG1:= SB1->B1_COD
					DbSelectArea("SG1")
					DbSetOrder(2)

					IF !SG1->(dbSeek(xFilial("SG1")+_cCodSG1+_cCodSB1)) .and. _nQuant != 0 // Incluir somente novas estruturas
						RecLock("SG1",.T.)
						SG1->G1_FILIAL  := xFilial("SG1")
						SG1->G1_COD     := _cCodSB1 
						SG1->G1_COMP    := _cCodSG1
						SG1->G1_QUANT   := _nQuant
						SG1->G1_INI     := dDataBase
						SG1->G1_FIM     := stod(_aDados[i,_nG1FIM])
						SG1->G1_FIXVAR  := "V"
						SG1->G1_NIV     := "01"
						SG1->G1_NIVINV  := "99"
						MsUnLock()
					endif
				endif


			endif

		Next i

		FT_FUSE()

		oSelf:SaveLog("Termino normal do arquivo: "+_cArq)
/*
	RecLock("ZHS", .T.)
		ZHS->ZHS_FILIAL		:=	FWCodFil()
		ZHS->ZHS_PROG		:=	"Importa BOM"
		ZHS->ZHS_DATA		:=	DATE()
		ZHS->ZHS_HORA		:=	TIME()
		ZHS->ZHS_USER		:=	UsrFullName()
	ZHS->(MsUnlock())*/
else
	Aviso("Erro","Arquivo inválido. Verifique o Cabeçalho",{"Fechar"})      
ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xHeaders  ºAutor  ³FERNANDO BARRETO    º Data ³  24/08/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION xHeaders(aHeader)
	Local lContinua:=.F.

	_nB1XCOD   := ASCAN(aHeader,{|x| UPPER(alltrim(x))==UPPER("G1_COD")})
	_nG1COMP   := ASCAN(aHeader,{|x| UPPER(alltrim(x))==UPPER("G1_COMP")})
	_nG1QUANT  := ASCAN(aHeader,{|x| UPPER(alltrim(x))==UPPER("G1_QUANT")})
	_nG1REVFIM := ASCAN(aHeader,{|x| UPPER(alltrim(x))==UPPER("G1_REVFIM")})
	_nG1FIM    := ASCAN(aHeader,{|x| UPPER(alltrim(x))==UPPER("G1_FIM")})

	lContinua:=.T.

RETURN lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³split     ºAutor  ³FERNANDO BARRETO    º Data ³  24/08/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function split( cString, cDiv )
	Local aRet := {}
	Local nPos := 1
	Local nDiv := len( cDiv )

	While nPos != 0
		nPos := AT( cDiv, cString )
		If nPos > 0
			aadd( aRet, substr( cString, 1, nPos-1 ))
			cString := Substr( cString, nPos+nDiv )
		Else
			aadd( aRet, cString )
		Endif
	EndDo

Return aRet


//gravalog das informacoes//

static function Gravalog(cFile,cText)

	local nHandle

	cText += chr(13) + chr(10)

	if !file(cFile)
		if (nHandle := fCreate(cFile, 1)) = -1
			Conout("Arquivo nao foi criado: ("+cFile+")")
		else
			fWrite(nHandle, cText)
			fClose(nHandle)
		endif
	else

		nHandle := fOpen(cFile, 2)
		nLength := fSeek(nHandle, 0, 2)

		if nLength+len(cText)>=1048580

			fClose(nHandle)

			IF fRename(cFile, cFile+"."+dtos(date())+"-"+alltrim(str(seconds()))) = -1
				Conout("Arquivo nao foi renomeado: ("+cFile+")")
			endif

			gravalog(cFile,cText)

		endif

		if fError() != 0
			Conout("Arquivo nao foi aberto: ("+cFile+")")
		else
			cText := fReadStr(nHandle,nLength) + cText
			fWrite(nHandle, cText)
			fClose(nHandle)
		endif
	endif

return

