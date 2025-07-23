#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'
 
User Function COMA04()

Local cDirIni   := "\xml"
Local cTipArq   := "Arquivos XML (*.xml)"

Local cError    := ""
Local cWarning  := ""
Local cXmlFile  := ""
Local oXml      := NIL
Local oDet      := NIL
Local dDataBase := date()
Local aCabec    := {}
Local cNumNota  := ""
Local cSerieNota:= ""
Local cDataEmiss:= ""
Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
Local aRet     := NIL
Local aPergs   := {}
Local cArquivo := Space(70)
Local cFornece := Space(TamSX3('F1_FORNECE')[01])
Local cLoja    := Space(TamSX3('F1_LOJA')[01])
Local cEspecie := Space(TamSX3('F1_ESPECIE')[01])

Private aLinha := {}
 
aAdd(aPergs, {1,    "Fornecedor", cFornece,  "", ".T.","FOR", ".T.",  Val(cFornece), .T.})
aAdd(aPergs, {1,  "Loja Fornece",    cLoja,  "", ".T.",     , ".T.",     Val(cLoja), .F.})
aAdd(aPergs, {1,  "Espec.Docum.", cEspecie,  "", ".T.", "42", ".T.",  Val(cEspecie), .T.})
aAdd(aPergs, {6,"Buscar arquivo", cArquivo,  "",    "",   "",    70,            .T., cTipArq, cDirIni})

If !ParamBox(aPergs, "Informe os parâmetros", @aRet, , , , , , , , .F., .F.)
  Return
ElseIf !vldFornec(aRet[1],aRet[2])
  Return U_COMA04()
EndIf

cXmlFile := aRet[4] //MV_PAR04
oXml := XmlParserFile(cXmlFile, "_", @cError, @cWarning )
If (oXml == NIL )
  MsgStop("Falha ao gerar Objeto XML : "+@cError+" / "+@cWarning)
  Return
Endif

oNF   := oXml:_NFE:_INFNFE:_IDE
oDet  := oXml:_NFE:_INFNFE:_DET

If !vldProduto(oDet)
  MsgInfo("Importação Cancelada!", "Import XML")
  Return
EndIf

If Len(aLinha) > 0
  cSerieNota := "1"
  cDataEmiss := StoD(SubStr(oNF:_DHEMI:TEXT,1,4)+SubStr(oNF:_DHEMI:TEXT,6,2)+SubStr(oNF:_DHEMI:TEXT,9,2))
  cNumNota   := NxtSX5Nota(cSerieNota, NIL, cTipoNf)

  //Cabeçalho Nota
  aAdd(aCabec,{'F1_TIPO'    ,'N'         ,NIL})
  aAdd(aCabec,{'F1_FORMUL'  ,'S'         ,NIL})
  aAdd(aCabec,{'F1_DOC'     ,cNumNota    ,NIL})
  aAdd(aCabec,{"F1_SERIE"   ,cSerieNota  ,NIL})
  aAdd(aCabec,{"F1_EMISSAO" ,cDataEmiss  ,NIL})
  aadd(aCabec,{"F1_DTDIGIT" ,dDataBase   ,NIL})
  aAdd(aCabec,{'F1_FORNECE' ,aRet[1]     ,NIL})
  aAdd(aCabec,{'F1_LOJA'    ,aRet[2]     ,NIL})
  aAdd(aCabec,{"F1_ESPECIE" ,aRet[3]     ,NIL})
  aAdd(aCabec,{"F1_STATUS"  , ''         ,NIL})

  eMata140(aCabec, aLinha)
else
  MsgInfo("Importação Cancelada!", "Import XML")
EndIf

Return

/*/===================================================/*/

Static Function eMata140(aCabec, aLinha)
 
Local nOpc := 3
Private lMsErroAuto := .F.

Default aCabec      := {}
Default aItens      := {}
Default aLinha      := {}

MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)}, aCabec, aLinha, nOpc,,)
    
If lMsErroAuto
  mostraerro()
Else
  MsgInfo("Execauto MATA140 executado com sucesso!")
EndIf

Return

/*/===================================================/*/

Static Function vldFornec(cCodigo, cLoja)

Local lRet     := .F.
Local cParCodF := SuperGetMV("MV_CODFXML",.F.,.F.)
Local cText    := "Fornecedor selecionado não está no parâmetro!"
Local cTitle   := "MV_CODFXML"

Default cCodigo := ""
Default cLoja   := ""

If cCodigo $ cParCodF
  lRet := .T.
else
  MsgStop(cText, cTitle)
  lRet := .F.
EndIf

Return lRet

/*/===================================================/*/

Static Function vldProduto(oDet)

Local x      := 0
Local aItens := {}
Local cTitle := "Produto não localizado!"
Local lRet   := .F.
Local nOperation := MODEL_OPERATION_INSERT
Local cProgram   := 'MATA010'
Local nICMS00vBC, nICMS00p, nICMS00v := ""
Local nIPIvBC, nIPIp, nIPIv, nIIvII
Local nCOFvBC, nCOFp, nCOFv
Local cCodProd, cQtdProd, cVlrUnit, cVlrTotal
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}

If ValType(oDet) == "O"
  //Produto
  cCodProd  := oDet:_PROD:_CPROD:TEXT
  cNomeProd := oDet:_PROD:_XPROD:TEXT
  cQtdProd  := oDet:_PROD:_QCOM:TEXT
  cVlrUnit  := oDet:_PROD:_VUNCOM:TEXT
  cVlrTotal := oDet:_PROD:_VPROD:TEXT
  cPOSIPI   := oDet:_PROD:_NCM:TEXT
  //Inicio Impostos
  oICMS := oDet:_IMPOSTO:_ICMS
  If AttIsMemberOf(oICMS, "_ICMS00")
    nICMS00vBC := oICMS:_ICMS00:_VBC:TEXT
    nICMS00p   := oICMS:_ICMS00:_PICMS:TEXT
    nICMS00v   := oICMS:_ICMS00:_VICMS:TEXT
  EndIf
  nIPIvBC := oDet:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT
  nIPIp   := oDet:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT
  nIPIv   := oDet:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT
  nIIvII  := oDet:_IMPOSTO:_II:_VBC:TEXT
  nPISvBC := oDet:_IMPOSTO:_PIS:_PISOUTR:_VBC:TEXT
  nPISp   := oDet:_IMPOSTO:_PIS:_PISOUTR:_PPIS:TEXT
  nPISv   := oDet:_IMPOSTO:_PIS:_PISOUTR:_VPIS:TEXT
  nCOFvBC := oDet:_IMPOSTO:_COFINS:_COFINSOUTR:_VBC:TEXT
  nCOFp   := oDet:_IMPOSTO:_COFINS:_COFINSOUTR:_PCOFINS:TEXT
  nCOFv   := oDet:_IMPOSTO:_COFINS:_COFINSOUTR:_VCOFINS:TEXT
  //Fim Impostos

  MsgInfo("Existe somente 1 item na NF", "INFO")
  DbSelectArea("SB1")
  If !DbSeek(xFilial('SB1')+cCodProd)
    If MsgYesNo("Produto "+cCodProd+" - Item NF: 1 não cadastrado! Deseja cadastrar agora?", cTitle)
      oModelSB1 := FWLoadModel( cProgram )
      oModelSB1:SetOperation(MODEL_OPERATION_INSERT)
      lRet := (FWExecView("Inclusão", cProgram, nOperation,/*oDlg*/, ,/*bOk*/,/*nPercReducao*/, aButtons, , , , oModelSB1))
      If lRet == 0
        aAdd(aItens,{'D1_COD'   ,cCodProd      ,NIL})
        aAdd(aItens,{"D1_QUANT" ,Val(cQtdProd) ,Nil})
        aAdd(aItens,{"D1_VUNIT" ,Val(cVlrUnit) ,Nil})
        aAdd(aItens,{"D1_TOTAL" ,Val(cVlrTotal),Nil})
        aAdd(aItens,{"D1_TES"   ,''            ,NIL})
        aAdd(aItens,{"D1_POSIPI",cPOSIPI       ,NIL})
        If Len(nICMS00vBC) > 0
          aAdd(aItens,{"D1_BASEICM",Val(nICMS00vBC) ,NIL})
          aAdd(aItens,{"D1_PICM"   ,Val(nICMS00p)   ,NIL})
          aAdd(aItens,{"D1_VALICM" ,Val(nICMS00v)   ,NIL})
        EndIf
        aAdd(aItens,{"D1_BASEIPI",Val(nIPIvBC) ,NIL})
        aAdd(aItens,{"D1_IPI"    ,Val(nIPIp)   ,NIL})
        aAdd(aItens,{"D1_VALIPI" ,Val(nIPIv)   ,NIL})
        aAdd(aItens,{"D1_II"     ,Val(nIIvII)  ,NIL})
        aAdd(aItens,{"D1_BASIMP6",Val(nPISvBC) ,NIL})
        aAdd(aItens,{"D1_ALQIMP6",Val(nPISp)   ,NIL})
        aAdd(aItens,{"D1_VALIMP6",Val(nPISv)   ,NIL})
        aAdd(aItens,{"D1_BASIMP5",Val(nCOFvBC) ,NIL})
        aAdd(aItens,{"D1_ALQIMP5",Val(nCOFp)   ,NIL})
        aAdd(aItens,{"D1_VALIMP5",Val(nCOFv)   ,NIL})
        aAdd(aLinha,aItens)
        lRet := .T.
      else
        lRet := .F.
      EndIf
    EndIf
  Else
    aAdd(aItens,{'D1_COD'     ,cCodProd       ,NIL})
    aAdd(aItens,{"D1_QUANT"   ,Val(cQtdProd)  ,Nil})
    aAdd(aItens,{"D1_VUNIT"   ,Val(cVlrUnit)  ,Nil})
    aAdd(aItens,{"D1_TOTAL"   ,Val(cVlrTotal) ,Nil})
    aAdd(aItens,{"D1_TES"     ,''             ,NIL})
    aAdd(aItens,{"D1_POSIPI",cPOSIPI       ,NIL})
    If Len(nICMS00vBC) > 0
      aAdd(aItens,{"D1_BASEICM",Val(nICMS00vBC) ,NIL})
      aAdd(aItens,{"D1_PICM"   ,Val(nICMS00p)   ,NIL})
      aAdd(aItens,{"D1_VALICM" ,Val(nICMS00v)   ,NIL})
    EndIf
    aAdd(aItens,{"D1_BASEIPI",Val(nIPIvBC) ,NIL})
    aAdd(aItens,{"D1_IPI"    ,Val(nIPIp)   ,NIL})
    aAdd(aItens,{"D1_VALIPI" ,Val(nIPIv)   ,NIL})
    aAdd(aItens,{"D1_II"     ,Val(nIIvII)  ,NIL})
    aAdd(aItens,{"D1_BASIMP6",Val(nPISvBC) ,NIL})
    aAdd(aItens,{"D1_ALQIMP6",Val(nPISp)   ,NIL})
    aAdd(aItens,{"D1_VALIMP6",Val(nPISv)   ,NIL})
    aAdd(aItens,{"D1_BASIMP5",Val(nCOFvBC) ,NIL})
    aAdd(aItens,{"D1_ALQIMP5",Val(nCOFp)   ,NIL})
    aAdd(aItens,{"D1_VALIMP5",Val(nCOFv)   ,NIL})
    aAdd(aLinha,aItens)
    lRet := .T.
  EndIf
  
else
  MsgInfo("Existem "+cValtoChar(Len(oDet))+" itens na NF", "INFO")
  DbSelectArea("SB1")
  For x := 1 to Len(oDet)
    //Produto
    cCodProd  := oDet[x]:_PROD:_CPROD:TEXT
    cNomeProd := oDet[x]:_PROD:_XPROD:TEXT
    cQtdProd  := oDet[x]:_PROD:_QCOM:TEXT
    cVlrUnit  := oDet[x]:_PROD:_VUNCOM:TEXT
    cVlrTotal := oDet[x]:_PROD:_VPROD:TEXT
    cPOSIPI   := oDet[x]:_PROD:_NCM:TEXT
    //Inicio Impostos
    oICMS := oDet[x]:_IMPOSTO:_ICMS
    If AttIsMemberOf(oICMS, "_ICMS00")
      nICMS00vBC := oICMS:_ICMS00:_VBC:TEXT
      nICMS00p   := oICMS:_ICMS00:_PICMS:TEXT
      nICMS00v   := oICMS:_ICMS00:_VICMS:TEXT
    EndIf
    nIPIvBC := oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT
    nIPIp   := oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT
    nIPIv   := oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT
    nIIvII  := oDet[x]:_IMPOSTO:_II:_VBC:TEXT
    nPISvBC := oDet[x]:_IMPOSTO:_PIS:_PISOUTR:_VBC:TEXT
    nPISp   := oDet[x]:_IMPOSTO:_PIS:_PISOUTR:_PPIS:TEXT
    nPISv   := oDet[x]:_IMPOSTO:_PIS:_PISOUTR:_VPIS:TEXT
    nCOFvBC := oDet[x]:_IMPOSTO:_COFINS:_COFINSOUTR:_VBC:TEXT
    nCOFp   := oDet[x]:_IMPOSTO:_COFINS:_COFINSOUTR:_PCOFINS:TEXT
    nCOFv   := oDet[x]:_IMPOSTO:_COFINS:_COFINSOUTR:_VCOFINS:TEXT
    //Fim Impostos

    If !DbSeek(xFilial('SB1')+cCodProd)
      If MsgYesNo("Produto: "+cCodProd+" - Item NF: "+CValToChar(x)+" não cadastrado! Deseja cadastrar agora?", cTitle)
        oModelSB1 := FWLoadModel( cProgram )
        oModelSB1:SetOperation(MODEL_OPERATION_INSERT)
        lRet := (FWExecView("Inclusão", cProgram, nOperation,/*oDlg*/, ,/*bOk*/,/*nPercReducao*/, aButtons, , , , oModelSB1))
        If lRet == 0
          aAdd(aItens,{'D1_COD'     ,cCodProd       ,NIL})
          aAdd(aItens,{"D1_QUANT"   ,Val(cQtdProd)  ,Nil})
          aAdd(aItens,{"D1_VUNIT"   ,Val(cVlrUnit)  ,Nil})
          aAdd(aItens,{"D1_TOTAL"   ,Val(cVlrTotal) ,Nil})
          aAdd(aItens,{"D1_TES"     ,''             ,NIL})
          aAdd(aItens,{"D1_POSIPI"  ,cPOSIPI        ,NIL})
          If Len(nICMS00vBC) > 0
            aAdd(aItens,{"D1_BASEICM",Val(nICMS00vBC) ,NIL})
            aAdd(aItens,{"D1_PICM"   ,Val(nICMS00p)   ,NIL})
            aAdd(aItens,{"D1_VALICM" ,Val(nICMS00v)   ,NIL})
          EndIf
          aAdd(aItens,{"D1_BASEIPI",Val(nIPIvBC) ,NIL})
          aAdd(aItens,{"D1_IPI"    ,Val(nIPIp)   ,NIL})
          aAdd(aItens,{"D1_VALIPI" ,Val(nIPIv)   ,NIL})
          aAdd(aItens,{"D1_II"     ,Val(nIIvII)  ,NIL})
          aAdd(aItens,{"D1_BASIMP6",Val(nPISvBC) ,NIL})
          aAdd(aItens,{"D1_ALQIMP6",Val(nPISp)   ,NIL})
          aAdd(aItens,{"D1_VALIMP6",Val(nPISv)   ,NIL})
          aAdd(aItens,{"D1_BASIMP5",Val(nCOFvBC) ,NIL})
          aAdd(aItens,{"D1_ALQIMP5",Val(nCOFp)   ,NIL})
          aAdd(aItens,{"D1_VALIMP5",Val(nCOFv)   ,NIL})
          aAdd(aLinha,aItens)
        EndIf
      EndIf
    Else
      aAdd(aItens,{'D1_COD'     ,cCodProd       ,NIL})
      aAdd(aItens,{"D1_QUANT"   ,Val(cQtdProd)  ,Nil})
      aAdd(aItens,{"D1_VUNIT"   ,Val(cVlrUnit)  ,Nil})
      aAdd(aItens,{"D1_TOTAL"   ,Val(cVlrTotal) ,Nil})
      aAdd(aItens,{"D1_TES"     ,''             ,NIL})
      aAdd(aItens,{"D1_POSIPI"  ,cPOSIPI        ,NIL})
      If Len(nICMS00vBC) > 0
        aAdd(aItens,{"D1_BASEICM",Val(nICMS00vBC) ,NIL})
        aAdd(aItens,{"D1_PICM"   ,Val(nICMS00p)   ,NIL})
        aAdd(aItens,{"D1_VALICM" ,Val(nICMS00v)   ,NIL})
      EndIf
      aAdd(aItens,{"D1_BASEIPI",Val(nIPIvBC) ,NIL})
      aAdd(aItens,{"D1_IPI"    ,Val(nIPIp)   ,NIL})
      aAdd(aItens,{"D1_VALIPI" ,Val(nIPIv)   ,NIL})
      aAdd(aItens,{"D1_II"     ,Val(nIIvII)  ,NIL})
      aAdd(aItens,{"D1_BASIMP6",Val(nPISvBC) ,NIL})
      aAdd(aItens,{"D1_ALQIMP6",Val(nPISp)   ,NIL})
      aAdd(aItens,{"D1_VALIMP6",Val(nPISv)   ,NIL})
      aAdd(aItens,{"D1_BASIMP5",Val(nCOFvBC) ,NIL})
      aAdd(aItens,{"D1_ALQIMP5",Val(nCOFp)   ,NIL})
      aAdd(aItens,{"D1_VALIMP5",Val(nCOFv)   ,NIL})
      aAdd(aLinha,aItens)
    EndIf
    aItens := {}
  Next x
  lRet := .T.
EndIf

Return lRet
