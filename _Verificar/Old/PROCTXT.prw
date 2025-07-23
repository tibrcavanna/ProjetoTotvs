#include "rwmake.ch" 
#include "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#include "TBICONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PROCTXT  ³ Autor ³ Sergio Compain        ³ Data ³  2009    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o arquivo txt para geracao de Produtos e Estruturas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ PROCTXT                                                     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CAVANNA                                                     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PROCTXT(lAuto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos dados de Entrada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSave:= getarea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc	:=	0
Local oDlg	:=	""
Local cTitulo	:=	""
Local cText1	:=	""
Local cText2	:=	""
Local cText3	:=	""
Local aSays	:=	{}
Local aButtons	:=	{}
Local cCadastro	:=	"Processa Arqs. TXT de Estruturas"
Local cDirLog   := "\LogsImp\"
Local cArqLog   := "Log_Imp_Geral_"+dtos(ddatabase)+"_"+left(time(),2)+substr(time(),4,2)+substr(time(),7,2)+".txt"
Local cLog      := ""

Local lEnd	:=	.F.
Local lAbortPrint := .F.
Local nHandle := 0
Local aLog    := {}
Local aProduto := {}
Local aDif     := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Janela Principal                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo	:=	"Processa Arqs. TXT gerados pelo Pesq. e Cadastro Cavanna"
cText1	:=	"Esta rotina vai processar os arquivos TXT , e atualizar o arquivo de"
cText2	:=	"Produtos (SB1), Complementos (SB5) e Estruturas (SG1)"
cText3	:=	"Especifico Cavanna "

If !lAuto

 While .T.
	AADD(aSays,OemToAnsi( ctext1 ) )
	AADD(aSays,OemToAnsi( cText2 ) )
	AADD(aSays,OemToAnsi( cText3 ) )
	AADD(aButtons, { 1,.T.,{|o| nOpc:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	FormBatch( cCadastro, aSays, aButtons )

	Do Case
	Case nOpc==1
         OkProc(lAuto)
	Case nOpc==2
		Loop
	EndCase
	Exit
 End
Else
  OkProc(lAuto)
EndIf

//EnvEmail(lAuto) 

For ny := 1 to len(aLog)
  cLog += aLog[ny,2]+chr(13)+chr(10)
Next ny

If !Empty(clog)
  memowrit(cDirLog+cArqLog,clog)
  commit
EndIf

MsgInfo(OemToAnsi("Importacao Efeutada !!!","Aviso"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
restarea(aSave)

Return



***********************************************************
Static Function OkProc(lAuto)
***********************************************************

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cAlias    := Alias()
Local oOk       := LoadBitmap( GetResources(), "LBTIK" )
Local oNo       := LoadBitmap( GetResources(), "LBNO" )

Private cArq      := ""
Private cDir      := "\Importacao\"
Private cSufixo   := "*.txt"
aArquivos := Directory(cDir+cSufixo)
aFiles    := {}

If empty(aArquivos)
  If !lAuto
    Alert("Nao existem arquivos a serem processados !!!")
    aAdd(alog,{.T.,"Nao existem arquivos a serem processados !!!"+time()} )
  EndIf
  DeleteObject(oOk)
  DeleteObject(oNo)
  Return
EndIf

For nI:=1 to Len(aArquivos)
  Aadd(aFiles,{.T.,aArquivos[nI][1]})
Next nI

If !lAuto
  DEFINE MSDIALOG oDlgFil FROM	153,5 TO 328,361 TITLE;
	OemToAnsi("Arquivos a serem processados...") OF oMainWnd PIXEL

	@ 6, 5 LISTBOX oUso FIELDS HEADER "","" SIZE 130,75 ON DBLCLICK;
	(aFiles[oUso:nAt,1] := !aFiles[oUso:nAt,1],oUso:Refresh(.f.)) OF oDlgFil PIXEL

	oUso:SetArray(aFiles)
	oUso:bLine := { || {if(aFiles[oUso:nAt,1],oOk,oNo),aFiles[oUso:nAt,2] }}

	DEFINE SBUTTON FROM 10, 145 TYPE 1 ENABLE OF oDlgFil;
		ACTION ( nOpca := 1, oDlgFil:End() , MsAguarde( { || ProcArqs(lAuto) }, "Processa Arq. TXT ", "Iniciando processamento...", @lEnd ))
	DEFINE SBUTTON FROM 23, 145 TYPE 2 ENABLE OF oDlgFil;
		ACTION ( nOpca := 2, aFiles:={},oDlgFil:End() )

  ACTIVATE MSDIALOG oDlgFil CENTERED

  DeleteObject(oOk)
  DeleteObject(oNo)

  aFiles := {}

 Else
  ProcArqs(lAuto)
  aFiles := {}
EndIf

Return

Static Function ProcArqs(lAuto)

Local cBuffer   := ""
Local cProduto := ""
Local cCompo   := ""
Local nQtd     := 0
Local cSeq     := ""
Local dDtaFim  := ctod("")
Local cUM      := ""
Local cDesc    := ""
Local cTipo    := ""
Local nPeso    := 0
Local nCompr   := 0
Local nExpes   := 0
Local nLarg    := 0
Local clinha   := "00000"
Local aCabSG1  := {}
Local aItemSG1 := {}
Local aSB1     := {}
Local aSB5     := {}
Local aGets    := {}
Local cArqRem  := ""
Local nCab     := 0
Local aItem    := {}
Local cArqOrig := ""
Local cOperacao:= ""
Local aAltSG1  := {}
Local cFornec  := "" 
Local cLoja    := ""
  
For nA:=1 to Len(aFiles)

 If aFiles[nA,1]  // esta selecionada para executar
 
  cArq := cDir+aFiles[nA,2]
  cBuffer := ""

  If !lAuto
    MsProcTxt( "Lendo Arq. - "+aFiles[nA,2])
  EndIf

  aAdd(alog,{.F.,"Processando o arquivo : "+cArq } )

  If nHandle >= 0
	FClose(nHandle)
  EndIf
 
  If File( cArq )

    Ft_fuse( cArq ) // Abre o arquivo

    nlin := 1
  
    While ! ft_feof() // Enquanto nao for final do arquivo

     cBuffer := ft_freadln()

     If nLin > 4

    
      clinha   := Substr(cBuffer,001,005)
      cOperacao:= Substr(cBuffer,007,003)
      cProduto := UPPER(Substr(cBuffer,011,015))
      cCompo   := UPPER(Substr(cBuffer,027,015))
      nQtd     := val(Substr(cBuffer,043,011))
      cSeq     := Substr(cBuffer,055,003)
      dDtaFim  := stod(Substr(cBuffer,059,008))
      cUM      := Substr(cBuffer,068,002)
      cDesc    := Alltrim(Upper(Substr(cBuffer,071,065)))
      cTipo    := Substr(cBuffer,137,002)
      nPeso    := val(Substr(cBuffer,140,010))
      nCompr   := val(Substr(cBuffer,151,008))
      nExpes   := val(Substr(cBuffer,160,008))
      nLarg    := val(Substr(cBuffer,169,008))
      cFornec  := Substr(cBuffer,178,006)
      cLoja    := Substr(cBuffer,185,002)
      cArqOrig := Substr(aFiles[nA,2],1,at(".",aFiles[nA,2])-1)   

      If !Empty(cDesc) .and. Ascan(aSB1,{|x| x[1][2] == cCompo}) = 0

        AAdd(aSB1,{{"B1_COD"    ,cCompo     ,Nil},;
                   {"B1_DESC"    ,cDesc      ,Nil},; 
		           {"B1_TIPO"    ,cTipo  	  ,Nil},; 
		           {"B1_UM"      ,cUM   	  ,Nil},; 
		           {"B1_PESO"    ,nPeso  	  ,Nil},; 
		           {"B1_PROC"    ,cFornec  	  ,Nil},; 
		           {"B1_LJPROC"  ,cLoja  	  ,Nil},; 
		           {"B1_ORIGIMP" ,cArqOrig+cLinha ,Nil},; 
		           {"B1_LOCPAD"  ,"01"   	  ,Nil}})


        AAdd(aSB5,{{"B5_COD"    ,cCompo     ,Nil},;
                   {"B5_CEME"    ,cDesc      ,Nil},; 
		           {"B5_COMPR"   ,nCompr 	  ,Nil},; 
		           {"B5_ESPESS"  ,nExpes	  ,Nil},; 
		           {"B5_LARG"    ,nLarg  	  ,Nil}})

      EndIf

      If cOperacao = "001" .and. cProduto = cCompo
	     AAdd(aCabSG1,{{"G1_COD"		,cCompo  	,NIL},;
				       {"G1_QUANT"	    ,1		 	,NIL},;
				       {"NIVALT"		,"N"	    ,NIL}}) //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
         If !Empty(aItem)
	       aadd(aItemSg1,{aItem})
           aItem := {}
         EndIf
      EndIf

      If !Empty(cProduto) .and. cOperacao = "001" .and. cProduto <> cCompo
	     aGets := {}
	     aadd(aGets,	{"G1_COD"		,cProduto			,NIL})
	     aadd(aGets,	{"G1_COMP"		,cCompo 			,NIL})
	     aadd(aGets,	{"G1_TRT"		,cSeq    			,NIL})
	     aadd(aGets,	{"G1_QUANT"		,nQtd				,NIL})
	     aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	     aadd(aGets,	{"G1_INI"		,dDatabase      	,NIL})
         aadd(aGets,    {"G1_ORIGIMP"   ,cArqOrig+cLinha   ,Nil})
	     aadd(aGets,	{"G1_FIM"		,dDtaFim        	,NIL})
	     aadd(aItem,aGets)
      EndIf

      If !Empty(cProduto) .and. cOperacao = "002"
         aadd(aAltSG1,{cProduto,cCompo,cSeq,nQtd,0,dDatabase,cArqOrig+cLinha,dDtaFim})
      EndIf

     EndIf 
      
     ft_fskip()
     nLin ++

    EndDo
  
    ft_fuse()

   Else
    If !lAuto
      msgbox('Erro na abertura do arquivo texto ('+cArq+')')
    EndIf
    aAdd(alog,{.T.,'Erro na abertura do arquivo texto ('+cArq+')'} )
  EndIf

 EndIf

Next nA

If !Empty(aItem)
   aadd(aItemSg1,{aItem})
   aItem := {}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo texto                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nHandle >= 0
	FClose(nHandle)
EndIf

If !empty(aSB1)
   CadProdutos(aSB1,aSB5)
EndIf

If !empty(aCabSG1)
   CadEstru(aCabSG1,aItemSG1)
EndIf

//If !empty(aAltSG1)
//   AltEstru(aAltSG1)
//EndIf


//Renomeia os arquivos que foram processados
For nA:=1 to Len(aFiles)
   If aFiles[nA,1]  // esta selecionada para executar
     cArqRem := (Substr(aFiles[nA,2],1,at(".",aFiles[nA,2]))+"PRC")   
     If File(cDir+aFiles[nA,2])
	   If File(cDir+cArqRem)
		 Delete File (cDir+cArqRem)
		 Rename (cDir+aFiles[nA,2]) to (cDir+cArqRem)
	    Else
		 Rename (cDir+aFiles[nA,2]) to (cDir+cArqRem)
	   EndIf
     EndIf
   EndIf
Next nA

Return


//Funcoes especiais
*******************************************************

Static Function CadProdutos(aSB1,aSB5)

xOpcao  := 3 //inclusao
cDirLog := "\LogsImp"
cArqLog := "Log_Prod_"
cLogSB1 := ""
cLogSB5 := ""

Private lMsErroAuto := .f.

//makeDir(cDirLog)

//atualiza produtos

For ny := 1 to len(aSB1)

  xOpcao := 3 //inclusao

  cLogSB1:= cArqLog+Alltrim(aSB1[ny,1,2])+"_SB1.txt"

  //ver se produto existe
  If SB1->(dbSeek(xFilial("SB1")+aSB1[ny,1,2]))
    xOpcao := 4 //alteracao
  EndIf

  Begin Transaction 

   //faz a inclusao ou alteracao do cadastro de produtos
    MSExecAuto({|x,y| Mata010(x,y)},aSB1[ny],xOpcao)
   
    If lMsErroAuto
      If file(cDirLog+cLogSB1)
       fErase(cDirLog+cLogSB1)
      Endif   
      aAdd(alog,{.T.,MostraErro(cDirLog,cLogSB1)} )
      //MostraErro(cDirLog,cLobSB1)
      DisarmTransaction()
    EndIf

  End Transaction 

Next ny


//atualiza complementros de produtos
For ny := 1 to len(aSB5)

  xOpcao := 3 //inclusao
  cLogSB5:= cArqLog+Alltrim(aSB5[ny,1,2])+"_SB5.txt"

  //ver se produto existe
  If SB5->(dbSeek(xFilial("SB5")+aSB5[ny,1,2]))
    xOpcao := 4 //alteracao
  EndIf

  Begin Transaction 

   //faz a inclusao ou alteracao do cadastro de produtos
    MSExecAuto({|x,y| Mata180(x,y)},aSB5[ny],xOpcao)
   
    If lMsErroAuto
      If file(cDirLog+cLogSB5)
       fErase(cDirLog+cLogSB5)
      Endif   
      aAdd(alog,{.T.,MostraErro(cDirLog,cLogSB5)} )
      //MostraErro(cDirLog,cLobSB5)
      DisarmTransaction()
    EndIf

  End Transaction 


Next ny

Return

Static Function CadEstru(aCabSG1,aItemSG1)

Local xOpcao  := 3 //inclusao
Local cDirLog := "\LogsImp"
Local cArqLog := "Log_Estru_"
Local cLogSG1 := ""
Local aCab    := {}
Local aItem   := {} 


Private lMsErroAuto := .f.

//makeDir(cDirLog)

For ny := 1 to len(aCabSG1)

  xOpcao := 3 //inclusao
  cLogSG1:= cArqLog+Alltrim(aCabSG1[ny,1,2])+"_SG1.txt"

  aCab  := aCabSg1[ny]
  aItem := aItemSg1[ny][1]

  Begin Transaction 

	MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,aItem,xOpcao) 
   
    If lMsErroAuto
      If file(cDirLog+cLogSG1)
       fErase(cDirLog+cLogSG1)
      Endif   
      aAdd(alog,{.T.,MostraErro(cDirLog,cLogSG1)} )
      //MostraErro(cDirLog,cLogSG1)
      DisarmTransaction()
    EndIf

  End Transaction 


Next ny

Return

Static Function AltEstru(aAltSG1)

Local cDirLog := "\LogsImp"
Local cArqLog := "Log_Alt_Estru_"
Local cLogSG1 := ""
Local lIncAlt := .f.

makeDir(cDirLog)

For ny := 1 to len(aAltSG1)

  cLogSG1:= cArqLog+Alltrim(aAltSG1[ny,1])+"_SG1.txt"

  dbSelectArea("SG1")
  dbSetorder(1)
  If dbSeek(xFilial("SG1")+aAltSG1[ny,1]+aAltSG1[ny,2]+aAltSG1[ny,3])
    Begin Transaction 
      Reclock("SG1",.F.)
        SG1->G1_QUANT   := aAltSG1[ny,4]
        SG1->G1_PERDA   := aAltSG1[ny,5]
        SG1->G1_INI     := aAltSG1[ny,6]
        SG1->G1_ORIGIMP := aAltSG1[ny,7]
        SG1->G1_FIM     := aAltSG1[ny,8]
      Msunlock()
   End Transaction 
  Else
   Begin Transaction 
     Reclock("SG1",.t.)
        SG1->G1_FILIAL  := XFILIAL("SG1")
        SG1->G1_COD     := aAltSG1[ny,1]
        SG1->G1_COMP    := aAltSG1[ny,2]
        SG1->G1_TRT     := aAltSG1[ny,3]
        SG1->G1_QUANT   := aAltSG1[ny,4]
        SG1->G1_PERDA   := aAltSG1[ny,5]
        SG1->G1_INI     := aAltSG1[ny,6]
        SG1->G1_ORIGIMP := aAltSG1[ny,7]
        SG1->G1_FIM     := aAltSG1[ny,8]
        SG1->G1_FIXVAR  := "V"
        SG1->G1_REVFIM  := "ZZZ"
        SG1->G1_NIV     := "01"
        SG1->G1_NIVINV  := "99"
        SG1->G1_VLCOMPE := "N" 
     Msunlock()
   End Transaction 
  EndIf

Next ny

Return

/*/
User Function MyMATA200(nOpc)
Local aCab  :={}
Local aItem := {}
Local aGets	:= {}
Local lOK	:= .T.
Local cString
Private lMsErroAuto := .F.
Default nOpc := 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente                                         |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "PCP" TABLES "SB1","SG1","SG5"
ConOut(Repl("-",80))
ConOut(PadC("Teste de rotina automatica para estrutura de produtos",80))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificacao do ambiente para teste                           |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
	lOk := .F.
	ConOut("Cadastrar produto acabado: PA001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI001"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PI001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI002"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PI002")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"PI003"))
	lOk := .F.
	ConOut("Cadastrar produto intermediario: PA003")
EndIf


If !SB1->(MsSeek(xFilial("SB1")+"MP001"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP001")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP002"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP002")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP003"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP003")
EndIf

If !SB1->(MsSeek(xFilial("SB1")+"MP004"))
	lOk := .F.
	ConOut("Cadastrar produto materia prima: MP004")
EndIf
If nOpc==3
	aCab := {	{"G1_COD"		,"PA001"			,NIL},;
				{"G1_QUANT"		,1		     		,NIL},;
				{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI001" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI001" 			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI002" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP002"			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI002"	   		,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP001"			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"PI003" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PA001"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP004" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)

	aGets := {}
	aadd(aGets,	{"G1_COD"		,"PI003"			,NIL})
	aadd(aGets,	{"G1_COMP"		,"MP003" 			,NIL})
	aadd(aGets,	{"G1_TRT"		,Space(3)			,NIL})
	aadd(aGets,	{"G1_QUANT"		,1					,NIL})
	aadd(aGets,	{"G1_PERDA"		,0					,NIL})
	aadd(aGets,	{"G1_INI"		,CTOD("01/01/01")	,NIL})
	aadd(aGets,	{"G1_FIM"		,CTOD("31/12/49")	,NIL})
	aadd(aItem,aGets)
	If lOk
		ConOut("Teste de Inclusao")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,aItem,3) //Inclusao
		ConOut("Fim: "+Time())
	EndIf
Else
	//--------------- Exemplo de Exclusao ------------------------------------
	If lOk
		aCab := {	{"G1_COD"		,"PA001"			,NIL},;
		            {"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PA001")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI001"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI001")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI002"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI002")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		lOk := !lMsErroAuto
		ConOut("Fim: "+Time())
	EndIf
	If lOk
		aCab := {	{"G1_COD"		,"PI003"			,NIL},;
					{"NIVALT"		,"S"				,NIL}} //A variavel NIVALT eh utilizada pra recalcular ou nao a estrutura
		ConOut("Teste de Exclusao do codigo PI003")
		ConOut("Inicio: "+Time())
		MSExecAuto({|x,y,z| mata200(x,y,z)},aCab,NIL,5) //Exclusao
		ConOut("Fim: "+Time())
	EndIf
EndIf
If lMsErroAuto
	If IsBlind()
		If IsTelnet()
			VTDispFile(NomeAutoLog(),.t.)
		Else
			cString := MemoRead(NomeAutoLog())
			Aviso("Aviso de Erro:",cString)
		EndIf
	Else
		MostraErro()
	EndIf
Else
	If lOk
		Aviso("Aviso","Incluido com sucesso",{"Ok"})
	Else
		Aviso("Aviso","Fazer os devidos cadastros",{"Ok"})
	EndIf
Endif

Return
/*/

Static Function EnvEmail(lAuto)

Local cMailConta  := NIL
Local cMailServer := NIL
Local cMailSenha  := NIL  
Local cMailCtaAut := NIL
Local cBackMens   := ""                     
Local cError      := ""
Local lAutOk      := .F. 
Local lOk         := .F. 
Local lSmtpAuth   := GetMv("MV_RELAUTH",,.F.)
Local cFrom		  := ""
Local cTo         := "srcompain@terra.com.br"
Local cMensagem   := OemToAnsi("E-Mail automatico enviado pelo modulo SIGA ESTOQUE  ") 
Local cSubject    := "Importacao dos arquivos TXT para a Estruturas"
Local lEnvia      := .f.

For ny := 1 to len(aLog)
  If aLog[ny,1]
     cMensagem += chr(13)+chr(10)+aLog[ny,2]
     lEnvia := .t.
  EndIf
Next ny

If !lEnvia
  Return
EndIf

aAdd(alog,{.f.,"Envio de e-mail para "+cTo+" referente a importacao de estruturas "+time()} )

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
	
		SEND MAIL FROM cFrom to cTo SUBJECT cSubject BODY cMensagem FORMAT TEXT RESULT lSendOk

		If !lSendOk
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Erro no Envio do e-mail                                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			GET MAIL ERROR cError
            If !lAuto
			  MsgInfo(cError,OemToAnsi("Erro no envio de e-Mail"))
            EndIf
            aAdd(alog,{.t.,"Nao foi possivel enviar o e-mail para "+cTo+" referente a importacao de estruturas "+time()} )
         Else
            DISCONNECT SMTP SERVER RESULT lDisConectou
            If !lAuto
			  MsgInfo(OemToAnsi("Envio de e-Mail com sucesso !!!","Aviso"))
            EndIf
            aAdd(alog,{.f.,"E-mail enviado com sucesso para "+cTo+" referente a importacao de estruturas "+time()} )
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Erro na conexao com o SMTP Server ou na autenticacao da conta          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GET MAIL ERROR cError
        If !lAuto
		 MsgInfo(cError,OemToAnsi("Erro na conexao com o SMTP"))  
        EndIf
        aAdd(alog,{.t.,"Nao foi possivel se conectar com o sevidor SMTP "+cMailServer} )
	EndIf

EndIf

Return