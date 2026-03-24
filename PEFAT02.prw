#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
 
//Alinhamentos
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2
 
//Cor(es)
Static nCorCinza := RGB(0,0,0)
Static nCorLinha := RGB(150,150,150)



/*/{Protheus.doc} PEFAT02
Função principal do relatório orcamento
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
User Function PEFAT02()
    Local aArea := FWGetArea()
    Private c_Orcamento:= SCJ->CJ_NUM

    Processa({|| fImprime()})

    FWRestArea(aArea)
Return
 

/*/{Protheus.doc} fImprime
Função responsável por imprimir o relatório
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
Static Function fImprime()
    Local aArea        := GetArea()
    Local n_AtuAux      := 0
    Local c_QryAux      := ''
    Local c_Arquivo     := 'Orcamento'+c_Orcamento+"_"+FWTimeStamp() + '.pdf'

    Local n_PrcUn:=0
    Local n_PrcTo:=0
    Local n_Total:=0
    Local n_MoedaTX:= 0
    Local nI:=0
    Local cPasta       := "C:\spool\"
    Local cPastaSC     := ""

    // Local c_Orig:= 'C:\Users\aquintiliano\AppData\Local\Temp\'+c_Arquivo
    Local c_DirDoc:= '\DIRDOC\CO'+FWCodEmp()+'\SHARED\'

    Private n_TotAux     := 0
    Private a_Dados      := {}
    Private oPrintPvt
    Private oBrushLin   := TBrush():New(,nCorLinha)
    Private c_HoraEx     := Time()
    Private n_PagAtu     := 1
    Private c_LogoEmp    := fLogoEmp()

    //Linhas e colunas
    Private n_LinAtu     := 0
    Private n_LinFin     := 580
    Private n_ColIni     := 010
    Private n_ColFin     := 800
    Private n_ColMeio    := (n_ColFin-n_ColIni)/2

    //Colunas dos relatorio
    Private n_ColDad01   := n_ColIni        //ITEM
    Private n_ColDad02   := n_ColIni + 20   //IMAGEM
    Private n_ColDad03   := n_ColIni + 100  //CODIGO
    Private n_ColDad04   := n_ColIni + 170  //DESCRICAO
    Private n_ColDad05   := n_ColIni + 300  //PRAZO
    Private n_ColDad06   := n_ColIni + 360  //PESO
    Private n_ColDad07   := n_ColIni + 420  //NCM
    Private n_ColDad08   := n_ColIni + 480  //QTD
    Private n_ColDad09   := n_ColIni + 510  //UN
    Private n_ColDad10   := n_ColIni + 530  //PRECO UNITARIO
    Private n_ColDad11   := n_ColIni + 590 //DESCONTO
    Private n_ColDad12   := n_ColIni + 620  //PRECO TOTAL
    Private n_ColDad13   := n_ColIni + 670  //IPI
    Private n_ColDad14   := n_ColIni + 720 //TOTAL COM IPI

    Private c_Garantia   := ''
    Private c_Notas      := ''
    Private c_InfAdic    := ''
    Private c_Sigla      := ''

    Private n_Idioma     := 0
    Private n_CabMod     := 0
    Private n_Taxa       := 0
    Private c_ImprImpostos := ''
    Private n_MoedaLg    :=0

    //Declarando as fontes
    Private c_NomeFont  := 'Arial'
    Private oFontDet   := TFont():New(c_NomeFont, 9, -6, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(c_NomeFont, 9, -6, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(c_NomeFont, 8, -9,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(c_NomeFont, 8, -6,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(c_NomeFont, 8, -15, .T., .T., 5, .T., 5, .T., .F.)
    Private n_Lin:=0
    Private c_Moeda:= ""

    If ! ExistDir(cPasta)
       MakeDir(cPasta)
    EndIf

   //Criando o objeto de impressao
   oPrintPvt := FWMSPrinter():New(;
       c_Arquivo,; // cFilePrinter
       IMP_PDF,;  // nDevice
       .F.,;      // lAdjustToLegacy
       cPasta,;   // cPathInServer
       .T.,;      // lDisabeSetup
       ,;         // lTReport
       ,;         // oPrintSetup
       ,;         // cPrinter
       .F.,;      // lServer
       .F.,;      // lParam10
       ,;         // lRaw
       .T.;       // lViewPDF
   )

    //Monta a consulta de dados

    c_QryAux := "select CK_ITEM, CJ_FILIAL, CJ_NUM, CJ_EMISSAO, CJ_VALIDA, CJ_CLIENTE, CJ_LOJA, CJ_MOEDA, CK_PRODUTO, DATEDIFF(dd,CK_DT1VEN, CK_ENTREG) PRAZO, B1_DESC, CK_ENTREG, B1_PESO, B1_PICM, B1_IPI, " + CRLF
    c_QryAux += "B1_POSIPI, CK_QTDVEN, CK_UM, CK_PRCVEN, (CK_DESCONT / 100) CK_DESCONT, CK_VALOR, B1_IPI, CK_VALOR+((CK_PRCVEN*(B1_IPI/100))*CK_QTDVEN) TOTAL , A1_XIDIOMA, CJ_MOEDA, CJ_TPFRETE, " + CRLF
    c_QryAux += "ISNULL(CAST(CAST(CJ_GARANTI AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS Garantia, " + CRLF
    c_QryAux += "ISNULL(CAST(CAST(CJ_NOTAS AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS Notas, " + CRLF
    c_QryAux += "ISNULL(CAST(CAST(CJ_INFCOMP AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS InfComp, " + CRLF
    c_QryAux += "CJ_CONDPAG, E4_DESCRI, CK_TES, CJ_TXMOEDA " + CRLF
    c_QryAux += "from "+ RETSQLNAME("SCK")+ " CK INNER JOIN "+ RETSQLNAME("SCJ")+ " CJ ON CJ_FILIAL=CK_FILIAL AND CJ_NUM=CK_NUM AND CJ.D_E_L_E_T_='' " + CRLF
    c_QryAux += "INNER JOIN "+ RETSQLNAME("SB1")+ " B1 ON B1_FILIAL='"+xFilial('SB1')+"' AND CK_PRODUTO=B1_COD AND B1.D_E_L_E_T_='' " + CRLF
    c_QryAux += "INNER JOIN "+ RETSQLNAME("SA1")+ "  A1 ON CJ_CLIENTE=A1_COD AND CJ_LOJA=A1_LOJA AND A1.D_E_L_E_T_='' " + CRLF
    c_QryAux += "INNER JOIN "+ RETSQLNAME("SE4")+" E4 ON CJ_FILIAL=E4_FILIAL and E4_CODIGO=CJ_CONDPAG AND E4.D_E_L_E_T_='' " + CRLF
    c_QryAux += "WHERE CK.D_E_L_E_T_='' " + CRLF
    c_QryAux += "AND CJ_NUM='"+c_Orcamento+"'  " + CRLF
    c_QryAux += "ORDER BY CK_ITEM, CJ_FILIAL, CJ_NUM, CJ_EMISSAO" + CRLF
    
    
    PLSQuery(c_QryAux, 'QRY_AUX')
  
    //Define o tamanho da rÃ©gua
    DbSelectArea('QRY_AUX')
    QRY_AUX->(DbGoTop())
    Count to n_TotAux
    ProcRegua(n_TotAux)
    QRY_AUX->(DbGoTop())
    
    //Calcula os impostos
    _aImpostos := u_FIMPOSTOS(QRY_AUX->CJ_CLIENTE,QRY_AUX->CJ_LOJA,SA1->A1_TIPO,QRY_AUX->CK_PRODUTO,QRY_AUX->CK_TES,QRY_AUX->CK_QTDVEN,(QRY_AUX->CK_PRCVEN*n_Taxa),((QRY_AUX->CK_QTDVEN)*(QRY_AUX->CK_PRCVEN*n_Taxa)))

    n_Lin:= 0

    //Somente se tiver dados
    If ! QRY_AUX->(EoF())
        //Criando o objeto de impressao
        oPrintPvt := FWMSPrinter():New(c_Arquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetLandScape()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
  
        n_Idioma     := val(QRY_AUX->A1_XIDIOMA)
        n_CabMod     := QRY_AUX->CJ_MOEDA

        c_Garantia   := c_Garantia + Space(10) + AllTrim(QRY_AUX->Garantia)
        c_Notas      := c_Notas + Space(10) + AllTrim(QRY_AUX->Notas)
        c_InfAdic    := c_InfAdic +CRLF+ Space(10) +  AllTrim(QRY_AUX->InfComp)

        //Impostos

        c_ImprImpostos := ''
        
        for nI := 3 to len(_aImpostos)
            c_ImprImpostos += iif(nI > 3 .and. _aImpostos[nI+2] > 0,' / ','') + iif(_aImpostos[nI+2] > 0, _aImpostos[nI] +' - '+ Transform(_aImpostos[nI+2],'@E 99.99'),'')
            nI+=3
        next


        //Imprime os dados
        fImpCab()

        While ! QRY_AUX->(EoF())
            n_AtuAux++
            IncProc('Imprimindo registro ' + cValToChar(n_AtuAux) + ' de ' + cValToChar(n_TotAux) + '...')
  
            //Se atingiu o limite, quebra de pagina
            fQuebra()
  

            c_QRYCon:= "select * from "+ RETSQLNAME("AC9")+" AC9 INNER JOIN  "+ RETSQLNAME("ACB")+" ACB  " + CRLF
            c_QRYCon+= "ON AC9_ENTIDA='SB1' AND AC9_CODOBJ=ACB_CODOBJ AND ACB.D_E_L_E_T_='' " + CRLF
            c_QRYCon+= "where AC9_CODENT='"+ AllTrim(QRY_AUX->CK_PRODUTO)+"' AND AC9.D_E_L_E_T_='' " + CRLF

            PLSQuery(c_QRYCon, 'c_QRYCon')

            cImage:= "\dirdoc\co"+AllTrim(FWCodEmp())+"\shared\" + AllTrim(c_QRYCon->ACB_OBJETO)

            //Executa função taxa

            n_MoedaTX:= fMoedaTX(n_CabMod, dTos(QRY_AUX->CJ_EMISSAO))  // moeda orcamento
            n_MoedaLg:= fMoedaTX(n_Idioma, dTos(QRY_AUX->CJ_EMISSAO))  // moeda para conversao lingua
            
            //Imprime a linha atual
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad01, Alltrim(QRY_AUX->CK_ITEM), oFontDet, 20, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            oPrintPvt:SayBitmap(n_LinAtu,n_ColDad02+10,cImage , 40,40) // imagem do banco do conhecimento
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad03, Transform(QRY_AUX->CK_PRODUTO,''), oFontDet, 100, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad04, Alltrim(QRY_AUX->B1_DESC), oFontDet, 140, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad05, Transform(QRY_AUX->PRAZO,"@E 999,999"), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad06, Transform(QRY_AUX->B1_PESO, Alltrim(GetSX3Cache("B1_PESO","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad07, Transform(QRY_AUX->B1_POSIPI, Alltrim(GetSX3Cache("B1_POSIPI","X3_PICTURE"))), oFontDet, 40, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad08, Transform(QRY_AUX->CK_QTDVEN, Alltrim(GetSX3Cache("CK_QTDVEN","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad09, Alltrim(QRY_AUX->CK_UM), oFontDet, 20, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, Transform(fConvertMoeda(QRY_AUX->CK_PRCVEN, n_MoedaTX, n_MoedaLg, n_CabMod, n_Idioma), Alltrim(GetSX3Cache("CK_PRCVEN","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad11, Transform(QRY_AUX->CK_DESCONT, Alltrim(GetSX3Cache("CK_DESCONT","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, Transform(fConvertMoeda(QRY_AUX->CK_VALOR, n_MoedaTX, n_MoedaLg, n_CabMod, n_Idioma), Alltrim(GetSX3Cache("CK_VALOR","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad13, Transform(QRY_AUX->B1_IPI, Alltrim(GetSX3Cache("B1_IPI","X3_PICTURE"))), oFontDet, 25, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, Transform(fConvertMoeda(QRY_AUX->TOTAL, n_MoedaTX, n_MoedaLg, n_CabMod, n_Idioma), Alltrim(GetSX3Cache("CK_VALOR","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            n_LinAtu += 50
            oPrintPvt:Line(n_LinAtu-3, n_ColIni, n_LinAtu-3, n_ColFin, nCorCinza)
  
            //Se atingiu o limite, quebra de pagina
            fQuebra()

            n_PrcUn:=n_PrcUn + QRY_AUX->CK_PRCVEN
            n_PrcTo:=n_PrcTo + QRY_AUX->CK_VALOR
            n_Total:=n_Total + QRY_AUX->TOTAL

            n_Lin++

            QRY_AUX->(DbSkip())
        EndDo

            oPrintPvt:SayAlign(n_LinAtu, 100, 'Total '+ c_Sigla, oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:Line(n_LinAtu+14, n_ColIni, n_LinAtu+14, n_ColFin, nCorCinza)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, Transform(fConvertMoeda(n_PrcUn, n_MoedaTX, n_MoedaLg, n_CabMod, n_Idioma), GetSX3Cache("CK_VALOR","X3_PICTURE")), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, Transform(fConvertMoeda(n_PrcTo, n_MoedaTX, n_MoedaLg, n_CabMod, n_Idioma), GetSX3Cache("CK_VALOR","X3_PICTURE")), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, Transform(fConvertMoeda(n_Total, n_MoedaTX, n_MoedaLg, n_CabMod, n_Idioma), GetSX3Cache("CK_VALOR","X3_PICTURE")), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        
        n_LinAtu += 20       

        fInfComp()

        fImpRod()
          
        oPrintPvt:Preview()

        //Pega o nome do arquivo .rel
        cArquiRel := oPrintPvt:cFilePrint
        cPastaSC := GetClientDir()


        //Aciona o printer.exe para gerar do .rel para .pdf com senha
        ShellExecute("OPEN", cPastaSC + "printer.exe", cArquiRel + " PDF " , cPasta, 1)

        //Agora, apaga o arquivo .rel, limpa o objeto e abre a pasta com o PDF gerado
        Sleep(5000)
        FErase(cArquiRel)
        FreeObj(oPrintPvt)
       // ShellExecute("open", "explorer.exe", cPasta, "C:\", 1)

        //Salva o PDF na pasta do banco de conhecimento
        SavePdf(cPasta + c_Arquivo)

        RestArea(aArea)
    Else
        MsgStop('Não foi encontrado informações com os parâmetros informados!', 'Atenção')
    EndIf
    QRY_AUX->(DbCloseArea())
      
    RestArea(aArea)
Return

/*/{Protheus.doc} fImpCab
Responsável por imprimir o cabeçalho
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
Static Function fImpCab()
    Local cCodUsr   := ""
    Local cNomUsr   := "" 
    Local cNomeEmpresa := ''

    Private n_LinCab  := 015

    oPrintPvt:StartPage()

    oPrintPvt:SayBitmap(20,20, '\SYSTEM\lgrl0101.bmp',90,25) // imagem do banco do conhecimento

    //Atualizando a linha inicial do relatorio
    n_LinAtu := n_LinCab + 5

    a_Dados:= {}

    /*01*/ aAdd(a_Dados,{'Cotação Nº:' , ' Cotizacion Nº:' , 'Quote Nº:' })
    /*02*/ aAdd(a_Dados,{'Data:' , ' Fecha:' , 'Date:' })
    /*03*/ aAdd(a_Dados,{'Validade:' , ' Validad:' , 'Validity:' })
    /*04*/ aAdd(a_Dados,{'Código Cliente:' , ' Codigo Cliente:' , 'Customer Code:' })
    /*05*/ aAdd(a_Dados,{'R$ ', 'U$ ', ' ', '? '})
    

    // imprime informações do cabeçalho
    oPrintPvt:SayAlign(n_LinAtu, n_ColIni+200, iif(n_Idioma==3,a_Dados[ 1,3],iif(n_Idioma==2,a_Dados[ 1,2],a_Dados[ 1,1])), oFontDetN, 60, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+14, n_ColIni+200, QRY_AUX->CJ_NUM, oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColIni+300, iif(n_Idioma==3,a_Dados[ 2,3],iif(n_Idioma==2,a_Dados[ 2,2],a_Dados[ 2,1])), oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+14, n_ColIni+300, dtoc(QRY_AUX->CJ_EMISSAO), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColIni+400, iif(n_Idioma==3,a_Dados[ 3,3],iif(n_Idioma==2,a_Dados[ 3,2],a_Dados[ 3,1])), oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+14, n_ColIni+400, dtoc(QRY_AUX->CJ_VALIDA), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColIni+500, iif(n_Idioma==3,a_Dados[ 4,3],iif(n_Idioma==2,a_Dados[ 4,2],a_Dados[ 4,1])), oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+14, n_ColIni+500, QRY_AUX->CJ_CLIENTE, oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    n_LinAtu += 30
    oPrintPvt:Line(n_LinAtu-3, n_ColIni, n_LinAtu-3, n_ColFin, nCorCinza)
    n_LinAtu += 5

    c_Sigla:= iif(n_Idioma == 3,AllTrim(a_Dados[ 5,4]),iif(n_Idioma==2,AllTrim(a_Dados[ 5,2]),AllTrim(a_Dados[ 5,1]))) 
    a_Dados:= {}


    /*01*/ aAdd(a_Dados,{'Item' , ' Item' , 'Item' })
    /*02*/ aAdd(a_Dados,{'Imagem' , ' Image' , 'Image' })
    /*03*/ aAdd(a_Dados,{'Código' , ' Codigo' , 'Code' })
    /*04*/ aAdd(a_Dados,{'Descrição' , 'Descripción' , 'Description' })
    /*05*/ aAdd(a_Dados,{'Prazo' , ' Plazo' , 'Delivery' })
    /*06*/ aAdd(a_Dados,{'Peso (KG)' , 'Peso (KG)' , 'Net Weigth (KG)' })
    /*07*/ aAdd(a_Dados,{'NCM' , ' NCM NALADISH' , 'NCM-HS Code' })
    /*08*/ aAdd(a_Dados,{'Qtd.' , ' Cant.' , 'Qty.' })
    /*09*/ aAdd(a_Dados,{'Un.' , 'Un.' , 'Un.' })
    /*10*/ aAdd(a_Dados,{'Preço Unitário '+c_Sigla , 'Precio Unitário '+c_Sigla , 'Unit Price '+c_Sigla})
    /*11*/ aAdd(a_Dados,{'Desc %' , ' Desc %' , 'Desc %' })
    /*12*/ aAdd(a_Dados,{'Preço Total '+c_Sigla, 'Precio Total '+c_Sigla, 'Total Price '+c_Sigla})
    /*13*/ aAdd(a_Dados,{'IPI %' , ' IVA %' , 'IVA %'})
    /*14*/ aAdd(a_Dados,{'Total com IPI '+c_Sigla , 'Total con IVA '+c_Sigla , 'Amonunt Price IVA '+c_Sigla})

    /*15*/ aAdd(a_Dados,{'Tipo Entrada: ' + QRY_AUX->CJ_TPFRETE, 'Tipo de entrada: '  + QRY_AUX->CJ_TPFRETE, 'Entry Type: '  + QRY_AUX->CJ_TPFRETE })
    /*16*/ aAdd(a_Dados,{ 'Pagamento: '+ QRY_AUX->CJ_CONDPAG+' - '+ QRY_AUX->E4_DESCRI, 'Pago: '+ QRY_AUX->CJ_CONDPAG+' - '+ QRY_AUX->E4_DESCRI, 'Payment: '+ QRY_AUX->CJ_CONDPAG+' - '+ QRY_AUX->E4_DESCRI})
    /*17*/ aAdd(a_Dados,{'Impostos Inclusos: ' + c_ImprImpostos, ' Impuestos incluidos: ' + c_ImprImpostos , 'Taxes Included: ' + c_ImprImpostos })

    oPrintPvt:Line(n_LinAtu+10, n_ColIni, n_LinAtu+10, n_ColFin, nCorCinza)

    cCodUsr := RetCodUsr()
    cNomUsr := UsrRetName(cCodUsr)
    cNomeEmpresa := FwFilialName()

    /*18*/ aAdd(a_Dados,{'Assinatura: ' + Space(200)+ AllTrim(cNomeEmpresa), ' Suscripción: ' + Space(200)+AllTrim(cNomeEmpresa) , 'Subscription: ' + Space(200)+AllTrim(cNomeEmpresa) })
    /*19*/ aAdd(a_Dados,{'Contato: ' + Space(200)+ cNomUsr, ' Contacto: ' + Space(200)+ cNomUsr , 'Contact: ' + Space(200)+ cNomUsr })

    /*20*/ aAdd(a_Dados,{'Garantia: ' + CRLF + Space(20) + AllTrim(c_Garantia) , ' Garantía: ' + CRLF + Space(20) + AllTrim(c_Garantia) , 'Warranty: '+ CRLF + Space(20) + AllTrim(c_Garantia)  })
    /*21*/ aAdd(a_Dados,{'Notas: '+ CRLF + Space(20) + AllTrim(c_Notas) , ' Notas: '+ CRLF + Space(20) + AllTrim(c_Notas) , 'Notes: '+ CRLF + Space(20) + AllTrim(c_Notas) })
    /*22*/ aAdd(a_Dados,{'Informação Complementar: ' + CRLF + Space(20) + AllTrim(c_InfAdic), ' Información adicional: '  + CRLF + Space(20) + AllTrim(c_InfAdic) , 'Additional Information: '  + CRLF + Space(20) + AllTrim(c_InfAdic)})

    oPrintPvt:SayAlign(n_LinAtu, n_ColDad01, iif(n_Idioma==3,a_Dados[ 1,3],iif(n_Idioma==2,a_Dados[ 1,2],a_Dados[ 1,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02, iif(n_Idioma==3,a_Dados[ 2,3],iif(n_Idioma==2,a_Dados[ 2,2],a_Dados[ 2,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad03, iif(n_Idioma==3,a_Dados[ 3,3],iif(n_Idioma==2,a_Dados[ 3,2],a_Dados[ 3,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad04, iif(n_Idioma==3,a_Dados[ 4,3],iif(n_Idioma==2,a_Dados[ 4,2],a_Dados[ 4,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad05, iif(n_Idioma==3,a_Dados[ 5,3],iif(n_Idioma==2,a_Dados[ 5,2],a_Dados[ 5,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad06, iif(n_Idioma==3,a_Dados[ 6,3],iif(n_Idioma==2,a_Dados[ 6,2],a_Dados[ 6,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad07, iif(n_Idioma==3,a_Dados[ 7,3],iif(n_Idioma==2,a_Dados[ 7,2],a_Dados[ 7,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad08, iif(n_Idioma==3,a_Dados[ 8,3],iif(n_Idioma==2,a_Dados[ 8,2],a_Dados[ 8,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad09, iif(n_Idioma==3,a_Dados[ 9,3],iif(n_Idioma==2,a_Dados[ 9,2],a_Dados[ 9,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, iif(n_Idioma==3,a_Dados[10,3],iif(n_Idioma==2,a_Dados[10,2],a_Dados[10,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad11, iif(n_Idioma==3,a_Dados[11,3],iif(n_Idioma==2,a_Dados[11,2],a_Dados[11,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, iif(n_Idioma==3,a_Dados[12,3],iif(n_Idioma==2,a_Dados[12,2],a_Dados[12,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad13, iif(n_Idioma==3,a_Dados[13,3],iif(n_Idioma==2,a_Dados[13,2],a_Dados[13,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, iif(n_Idioma==3,a_Dados[14,3],iif(n_Idioma==2,a_Dados[14,2],a_Dados[14,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)


    n_LinAtu += 15
Return

/*/{Protheus.doc} fImpRod
imprime o rodpé
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/

Static Function fImpRod()
    Local n_LinRod:= n_LinFin
    Local cTexto := ''

    //Linha Separatoria
    oPrintPvt:Line(n_LinRod,   n_ColIni, n_LinRod,   n_ColFin)
    n_LinRod += 3

    //Dados da Esquerda
    cTexto := dToC(dDataBase) + '     ' + c_HoraEx + '     ' + FunName() + ' (Orçamento)     ' + UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(n_LinRod, n_ColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
      
    //Direita
    cTexto := 'Pagina '+cValToChar(n_PagAtu)
    oPrintPvt:SayAlign(n_LinRod, n_ColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
      
    //Finalizando a pagina e somando mais um
    oPrintPvt:EndPage()
    n_PagAtu++
Return
 

/*/{Protheus.doc} fQuebra
Responsável por fazer a quebra de linha
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
Static Function fQuebra()
    If n_LinAtu >= n_LinFin-10
        fImpRod()
        fImpCab()
    EndIf
Return

/*/{Protheus.doc} fInfComp
imprime as informações complementares
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
Static Function fInfComp()
    oPrintPvt:SayAlign(n_LinAtu+030, 50, iif(n_Idioma==3,a_Dados[22,3],iif(n_Idioma==2,a_Dados[22,2],a_Dados[22,1])) , oFontMin, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+040, 50, iif(n_Idioma==3,a_Dados[15,3],iif(n_Idioma==2,a_Dados[15,2],a_Dados[15,1])) , oFontMin, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+050, 50, iif(n_Idioma==3,a_Dados[16,3],iif(n_Idioma==2,a_Dados[16,2],a_Dados[16,1])) , oFontMin, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+060, 50, iif(n_Idioma==3,a_Dados[17,3],iif(n_Idioma==2,a_Dados[17,2],a_Dados[17,1])) , oFontMin, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    oPrintPvt:SayAlign(n_LinAtu+075, 50, iif(n_Idioma==3,a_Dados[20,3],iif(n_Idioma==2,a_Dados[20,2],a_Dados[20,1])) , oFontMin, 400, 30, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+100, 50, iif(n_Idioma==3,a_Dados[21,3],iif(n_Idioma==2,a_Dados[21,2],a_Dados[21,1])) , oFontMin, 400, 30, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+125, 50, iif(n_Idioma==3,a_Dados[22,3],iif(n_Idioma==2,a_Dados[22,2],a_Dados[22,1])) , oFontMin, 400, 30, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    oPrintPvt:SayAlign(n_LinAtu+150, 50, iif(n_Idioma==3,a_Dados[18,3],iif(n_Idioma==2,a_Dados[18,2],a_Dados[18,1])) , oFontMin, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+160, 50, iif(n_Idioma==3,a_Dados[19,3],iif(n_Idioma==2,a_Dados[19,2],a_Dados[19,1])) , oFontMin, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
Return

/*/{Protheus.doc} fMoedaTX
Funçao que busca o valor das moedas conforme parametro passado
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
Static Function fMoedaTX(nMoeda, dData)
    Local nTxa := 1
    DbSelectArea('SM2')
    SM2->(DBSetOrder(1))
    SM2->(DbSeek(dData))

        if nMoeda == 3
            nTxa:= SM2->M2_MOEDA4
        elseif nMoeda == 2
            nTxa:= SM2->M2_MOEDA2
        end

    SM2->(DbCloseArea())
Return nTxa


/*/{Protheus.doc} fConvertMoeda
Função faz a converção de moedas levando em consideração o XIDIOMA do cliente e a moeda do orçamento
@type function
@version  1.0
@author Anderson Quintiliano
@since 17/11/2025
/*/
Static Function fConvertMoeda(n_Val, n_VlMoe, n_VlrLg, n_LgMoed,n_Ling)
Local         n_NVal:= n_Val

    if n_LgMoed == 1 .and.  n_Ling == 2 // lingua USA moeda real converte para dolar
        n_NVal := n_Val/n_VlrLg
    elseif n_LgMoed == 2 .and.  n_Ling == 1
        n_NVal := n_Val*n_VlMoe

    elseif n_LgMoed == 1 .and.  n_Ling == 3  // lingua ESP moeda real converte para EURO
        n_NVal := n_Val/n_VlrLg
    elseif n_LgMoed == 3 .and.  n_Ling == 1 // lingua POR moeda EURO converte para REAL
        n_NVal := n_Val*n_VlMoe

    elseif n_LgMoed == 2 .and.  n_Ling == 3
        n_NVal :=  n_NVal * (n_VlMoe - n_VlrLg)
    elseif n_LgMoed == 3 .and.  n_Ling == 2
        n_NVal := n_NVal / (n_VlMoe - n_VlrLg)
    end
return abs(n_NVal)

////Bibliotecas
//#Include "Totvs.ch"
//#Include "TopConn.ch"
//#Include "RPTDef.ch"
//#Include "FWPrintSetup.ch"
// 
////Alinhamentos
//#Define PAD_LEFT    0
//#Define PAD_RIGHT   1
//#Define PAD_CENTER  2
// 
////Cor(es)
//Static nCorCinza := RGB(110, 110, 110)
//Static nCorLinha := RGB(148, 255, 180)
// 
//
///*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ Responsável por imprimir o PDF do orçamento posicionado                             @@@
//@                                                                                     @@@
//@ Autor: Lucas Apolinario                                                             @@@
//@ Since: 13/08/2025                                                                   @@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
//User Function PEFAT02()
//    Local aArea := FWGetArea()
//
//    
//    Processa({|| fImprime()})
//     
//    FWRestArea(aArea)
//Return
// 
//
//
///*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ Responsável por imprimir o PDF                                                      @@@
//@                                                                                     @@@
//@ Autor: Lucas Apolinario                                                             @@@
//@ Since: 13/08/2025                                                                   @@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
//Static Function fImprime()
//    Local aArea        := GetArea()
//    Local cArquiRel    := ''
//    Local c_Arquivo     := 'ORÇAMENTO'+"_"+SCJ->CJ_NUM+'.pdf'
//    Local cPasta       := "C:\spool\"
//    Local cPastaSC     := ""
//    Private oPrintPvt
//    Private oBrushLin  := TBrush():New(,nCorLinha)
//    Private c_HoraEx    := Time()
//    Private n_PagAtu    := 1
//    Private c_LogoEmp   := fLogoEmp()
//    //Linhas e colunas
//    Private n_LinAtu    := 0
//    Private n_LinFin    := 540
//    Private n_ColIni    := 015
//    Private n_ColFin    := 820
//    Private n_ColMeio   := (n_ColFin-n_ColIni)/2
//    Private nColCodPro := n_ColIni
//    Private nColDescri := nColCodPro + 080
//    Private nColTipPro := nColDescri + 300
//    Private nColUniMed := nColTipPro + 080
//    //Colunas dos relatorio
//    Private n_ColDad1    := n_ColIni
//    Private n_ColDad2    := n_ColIni + 50
//    Private n_ColDad3    := n_ColIni + 150
//    Private n_ColDad4    := n_ColIni + 200
//    Private n_ColDad5    := n_ColIni + 300
//    //Declarando as fontes
//    Private c_NomeFont  := 'Arial'
//    Private oFontDet   := TFont():New(c_NomeFont, 9, -11, .T., .F., 5, .T., 5, .T., .F.)
//    Private oFontDetN  := TFont():New(c_NomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
//    Private oFontRod   := TFont():New(c_NomeFont, 9, -8,  .T., .F., 5, .T., 5, .T., .F.)
//    Private oFontMin   := TFont():New(c_NomeFont, 13, -11,  .T., .F., 5, .T., 5, .T., .F.)
//    Private oFontMinB  := TFont():New(c_NomeFont, 13, -10,  .T., .t., 5, .T., 5, .T., .F.)
//    Private oFontTit   := TFont():New(c_NomeFont, 9, -15, .T., .T., 5, .T., 5, .T., .F.)
//
//
//    Private nTotOrc     := 0 //total do orçamento
//    Private nIPIorc     := 0
//    Private nIpi        := 0
//    Private cOrigens    := ''
//    Private cObs        := ''
//    Private cDtEntrega  := ''
//    Private aImps       := {}
//      
//    
//
//    If ! ExistDir(cPasta)
//        MakeDir(cPasta)
//    EndIf
//
//    //Criando o objeto de impressao
//    oPrintPvt := FWMSPrinter():New(;
//        c_Arquivo,; // cFilePrinter
//        IMP_PDF,;  // nDevice
//        .F.,;      // lAdjustToLegacy
//        cPasta,;   // cPathInServer
//        .T.,;      // lDisabeSetup
//        ,;         // lTReport
//        ,;         // oPrintSetup
//        ,;         // cPrinter
//        .F.,;      // lServer
//        .F.,;      // lParam10
//        ,;         // lRaw
//        .T.;       // lViewPDF
//    )
//    oPrintPvt:SetResolution(72)
//    oPrintPvt:SetLandscape()
//    oPrintPvt:SetPaperSize(DMPAPER_A4)
//    oPrintPvt:SetMargin(0, 0, 0, 0)
//
//    //Imprime os dados
//    fImpCab()
//    fImpItens()
//    fImpRod()
//        
//    //Aciona a geração do arquivo .rel
//    oPrintPvt:Preview()
//
//    //Pega o nome do arquivo .rel
//    cArquiRel := oPrintPvt:cFilePrint
//    cPastaSC := GetClientDir()
//
//
//    //Aciona o printer.exe para gerar do .rel para .pdf com senha
//    ShellExecute("OPEN", cPastaSC + "printer.exe", cArquiRel + " PDF " , cPasta, 1)
//
//    //Agora, apaga o arquivo .rel, limpa o objeto e abre a pasta com o PDF gerado
//    Sleep(5000)
//    FErase(cArquiRel)
//    FreeObj(oPrintPvt)
//   // ShellExecute("open", "explorer.exe", cPasta, "C:\", 1)
//
//
//    SavePdf(cPasta + c_Arquivo)
//
//    RestArea(aArea)
//Return
// 
//
//
//
// /*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ Responsável por buscar a logo da empresa no endereço conforme informado no fonte    @@@
//@                                                                                     @@@
//@ Autor: Lucas Apolinario                                                             @@@
//@ Since: 13/08/2025                                                                   @@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
//Static Function fLogoEmp()
//
//    Local cLogo       := ''
//    Local cCamFim     := GetTempPath()
//    Local cStart      := GetSrvProfString('Startpath', '')
// 
//     
//    //Pega a imagem
//    cLogo := cStart + 'CAVANNA' + '.JPG'
//     
//    //Se o arquivo não existir, pega apenas o da empresa, desconsiderando a filial
//    If !File(cLogo)
//        cLogo    := cStart + 'CAVANNA' + '.JPG'
//    EndIf
//     
//    //Copia para a temporária do s.o.
//    CpyS2T(cLogo, cCamFim)
//    cLogo := cCamFim + StrTran(cLogo, cStart, '')
//     
//    //Se o arquivo não existir na temporária, espera meio segundo para terminar a cópia
//    If !File(cLogo)
//        Sleep(500)
//    EndIf
//
//Return cLogo
// 
//
// 
//
//
//
///*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ Responsável por imprimir o cabeçalho do arquivo do PDF                              @@@
//@                                                                                     @@@
//@ Autor: Lucas Apolinario                                                             @@@
//@ Since: 13/08/2025                                                                   @@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
//Static Function fImpCab()
//    Local aArea     := GetArea()
//    Local n_LinCab   := 015
//    Local cData     := DTOC(SCJ->CJ_EMISSAO)
//    Local cPedido   := ''
//    Local cOrdem    := ''
//    Local cCliente  := SCJ->CJ_CLIENTE
//    Local cEndereco := ''
//    Local cNomeCli  := ''
//    Local cEndEntrega := ''
//    Local cCnpj     := ''
//    Local cIE       := ''
//    Local cContato  := ''
//    Local cRef      := ''
//    Local cCddEST   := ''
//
//    DbSelectArea('SA1')
//    SA1->(DbSetOrder(1))
//    IF SA1->(MsSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
//        cEndEntrega := Alltrim(SA1->A1_ENDENT) +"," + Alltrim(SA1->A1_COMPENT) +" "+ Alltrim(SA1->A1_BAIRROE) +" " + Alltrim(SA1->A1_MUNE) +" "+ Alltrim(SA1->A1_ESTE)
//        cEndereco   := Alltrim(SA1->A1_END) + ", " + Alltrim(SA1->A1_COMPLEM) + " "+ Alltrim(A1_BAIRRO) 
//        cCddEST     := Alltrim(SA1->A1_MUN) +"-"+Alltrim(A1_EST)
//        cCnpj       := Alltrim(SA1->A1_CGC)
//        cIE         := Alltrim(SA1->A1_INSCR)
//        cContato    := Alltrim(SA1->A1_CONTATO)
//        cNomeCli    := Alltrim(SA1->A1_NREDUZ)
//    ENDIF
//    SA1->(DbCloseArea())
//
//    DbSelectArea("SCK")
//    SCK->(DbSetOrder(1))
//    IF SCK->(MsSeek(xFilial("SCK") + SCJ->CJ_NUM))
//        while SCK->CK_NUM == SCJ->CJ_NUM
//            cRef      += IIF(Empty(cRef),SCK->CK_COTCLI,IIF(!EMPTY(SCK->CK_COTCLI) .and. !(SCK->CK_COTCLI $ cRef) , "," + SCK->CK_COTCLI,''))
//            cPedido   := SCK->CK_NUM
//            cOrdem    += IIF(Empty(cOrdem),SCK->CK_PEDCLI,IIF(!EMPTY(SCK->CK_PEDCLI) .and. !(SCK->CK_PEDCLI $ cOrdem), "," + SCK->CK_PEDCLI,''))
//            SCK->(DbSkip())
//        ENDDO
//    ENDIF
//    SCK->(DbCloseArea())
//
//      
//    //Iniciando Pagina
//    oPrintPvt:StartPage()
//     
//    //Imprime o logo
//    If File(c_LogoEmp)
//        oPrintPvt:SayBitmap(030, n_ColIni, c_LogoEmp, 230, 50)
//    EndIf
//      
//    If n_PagAtu == 1
//        n_LinAtu += 50
//        oBrush1 := TBrush():New( , CLR_BLUE) //FITA AZUL NA FRENTE DA LOGO
//        oPrintPvt:Fillrect( {028, 375, 035, 800 }, oBrush1, "-2")
//        //Imprimindo os parâmetros
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, 'Confirmação pedido', oFontDetN, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+480, 'Data', oFontDetN, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+580, 'Ordem Cliente', oFontDetN, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+700, 'Cliente', oFontDetN, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu +=15
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, cPedido, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+480, cData, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+580, cOrdem, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+700, cCliente, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//
//        n_LinCab += 75
//        n_LinAtu := n_LinCab + 5
//
//
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Endereço do Cliente:', oFontDetN, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, 'Endereço de Entrega:', oFontDetN, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu += 15
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, cNomeCli, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, cNomeCli, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu += 15
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, cEndereco, oFontMin, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, cEndereco, oFontMin, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu += 15
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, cCddEST, oFontMin, 250, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, cCddEST, oFontMin, 250, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu += 15
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'CNPJ:'+cCnpj+' / IE:'+cIE, oFontMin, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//         oPrintPvt:SayAlign(n_LinAtu, n_ColIni+340, 'CNPJ:'+cCnpj+' / IE:'+cIE, oFontMin, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu += 15
//
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Contato:', oFontMinB, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, cContato, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        n_LinAtu += 15
//
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Referência cliente:', oFontMinB, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//        oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, cRef, oFontMin, 150, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//
//    EndIf
//
//    n_LinAtu += 40
//
//    RestArea(aArea)
//Return
// 
//
//
//
//
//
//
///*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ Responsável por imprimir os Itens do arquivo do PDF                                 @@@
//@                                                                                     @@@
//@ Autor: Lucas Apolinario                                                             @@@
//@ Since: 13/08/2025                                                                   @@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
//Static Function fImpItens()
//    Local aArea     := GetArea()
//    Local nAltura   := 30
//    Local nCol      := n_ColIni
//    Local nLargura  := 30
//    Local nIPIitem  := 0
//    Local nTotIPI   := 0
//    Local cOrigem   := ''
//    Local aLinhas   := {}
//
//
//
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Item', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//    nCol += nLargura
//    nLargura := 80
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Codigo', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//    nCol += nLargura
//    nLargura := 200
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Descrição', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)    
//    nCol += nLargura
//    nLargura := 40
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Peso', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 30
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Qtd.', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 20
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'UN', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 70
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'NCM', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 40
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'IPI (%)', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Preço Unitario', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Desc. (%)', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Preço Total', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'IPI Total', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Preço Total com IPI', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//
//    DbSelectArea("SCK")
//    SCK->(DbSetOrder(1))
//    IF SCK->(MsSeek(xFilial("SCK") + SCJ->CJ_NUM))
//        WHILE( SCK->CK_NUM == SCJ->CJ_NUM)
//            n_LinAtu += nAltura
//            nCol        := n_ColIni
//            nLargura    := 30
//
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, SCK->CK_ITEM, oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//            nCol += nLargura
//            nLargura := 80
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, SCK->CK_PRODUTO, oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//            nCol += nLargura
//            nLargura := 200
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, Alltrim(Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_DESC")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)    
//            nCol += nLargura
//            nLargura := 40
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, cValToChar(Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_PESO")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 30
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, cValToChar(SCK->CK_QTDVEN), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 20
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, SCK->CK_UM, oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 70
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_POSIPI"), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 40
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol, cValToChar(Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_IPI")), oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 60
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(SCK->CK_PRCVEN, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 60
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(SCK->CK_VALDESC, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//            nCol += nLargura
//            nLargura := 60
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(SCK->CK_VALOR, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//            nCol += nLargura
//            nLargura := 60
//            nIPIitem := Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_IPI") * SCK->CK_PRCVEN
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(nIPIitem, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//            nCol += nLargura
//            nLargura := 60
//            nTotIPI  := ((Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_IPI") * SCK->CK_PRCVEN) * SCK->CK_QTDVEN) + SCK->CK_VALOR
//            oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//            oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(nTotIPI, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0)
//
//            nTotOrc     += SCK->CK_VALOR
//            nIPIorc     += nTotIPI
//            nIpi        += nIPIitem
//            cOrigem     := Alltrim(Posicione("SX5",1,xFilial("SX5") + "S0" + Posicione("SB1",1,xFilial("SB1") + SCK->CK_PRODUTO,"B1_ORIGEM"),"X5_DESCRI"))
//            IF EMPTY(cOrigens)
//                cOrigens += cOrigem
//            elseif !EMPTY(cOrigens) .and. !(cOrigem $ cOrigens)
//                cOrigens += "," + cOrigem
//            endif
//                
//            cObs        += IIF(!EMPTY(cObs),"/" + Alltrim(SCK->CK_OBS), Alltrim(SCK->CK_OBS))
//            cDtEntrega  := IIF(SCK->CK_ENTREG > CTOD(cDtEntrega), DTOC(SCK->CK_ENTREG),cDtEntrega)
//
//            AAdd(aLinhas,{SCK->CK_PRODUTO, SCK->CK_QTDVEN, SCK->CK_TES, SCK->CK_PRCVEN, SCK->CK_VALOR})
//
//            fQuebra()
//
//            SCK->(DbSkip())
//        ENDDO
//
//        
//        //aImps := U_IMPTOTAIS(SCJ->CJ_CLIENTE, SCJ->CJ_LOJA, cTipo, aLinhas)
//
//    ENDIF
//    SCK->(DbCloseArea())
//    
//    RestArea(aArea)
//
//Return
//
//
//
//
//
//
///*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@ Responsável por imprimir o rodapé do arquivo do PDF                                 @@@
//@                                                                                     @@@
//@ Autor: Lucas Apolinario                                                             @@@
//@ Since: 13/08/2025                                                                   @@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
//Static Function fImpRod()
//    Local n_LinRod   := n_LinFin
//    Local cTexto    := ''
//    Local nCol      := n_ColIni + 570
//    Local nAltura   := 20
//    Local cCondPag  := SCJ->CJ_CONDPAG + " " + Alltrim(Posicione('SE4',1, xFilial("SE4") + SCJ->CJ_CONDPAG, "E4_DESCRI"))
//    Local nPis      := SuperGetMv('MV_TXPIS')
//    Local nCof      := SuperGetMv('MV_TXCOF')
//    Local nICMS     := SuperGetMv('MV_ICMPAD')
//
//
//    
//    n_LinAtu += 30
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol, 'Total', oFontMinB, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " +Alltrim(Transform(nTotOrc, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(nIpi, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//    nCol += nLargura
//    nLargura := 60
//    oPrintPvt:Box( n_LinAtu, nCol, n_LinAtu+nAltura,   nCol+nLargura, "-4")
//    oPrintPvt:SayAlign(n_LinAtu, nCol,"R$ " + Alltrim(Transform(nIPIorc, "@E 99,999,999,999.99")), oFontMin, nLargura, nAltura, /*nClrText*/, PAD_CENTER, 0) 
//
//
//    n_LinAtu += 50
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Condições de Entrega:', oFontMinB, 1000, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, cObs, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    n_LinAtu += 40
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Condições de Pagamento:', oFontMinB, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, cCondPag, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    n_LinAtu += 15
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Data de Entrega:', oFontMinB, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, cDtEntrega, oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    n_LinAtu += 15
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Origem da Mercadoria:', oFontMinB, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, cOrigens, oFontMin, 150, 00, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    n_LinAtu += 15
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni, 'Impostos Incluídos:', oFontMinB, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, ' * '+cValToChar(nICMS)+"% ICMS", oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    n_LinAtu += 15
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, ' * '+cValToChar(nPIS + nCof)+ "% PIS/COFINS", oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    n_LinAtu +=15
//    oPrintPvt:SayAlign(n_LinAtu, n_ColIni + 100, ' * IPI Excluido ', oFontMin, 150, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
//    
//    
//
//    
//    oPrintPvt:SayAlign(n_LinRod, 160, 'Cavanna Máquinas e Sistemas para Embalagens Ltda', oFontRod, 500, 20, CLR_GRAY, PAD_CENTER, 0) 
//    n_LinRod+=10
//    oPrintPvt:SayAlign(n_LinRod,220, 'Rua Alberto Belesso, 640 Jundiaí, SP - Brasil CEP: 13213-170 Tel: +55 (11) 4431-8700 CNPJ: 06.088.544/0001-33', oFontRod, 1000, 20, CLR_GRAY, PAD_LEFT, 0) 
//    n_LinRod+=10
//     oPrintPvt:SayAlign(n_LinRod, 160, 'E-mail: vendas@cavannagroup.com / www.cavanna.com', oFontRod, 500, 20, CLR_GRAY, PAD_CENTER, 0) 
//    //Direita
//    cTexto := 'Pagina '+cValToChar(n_PagAtu)
//    oPrintPvt:SayAlign(n_LinRod, n_ColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
//      
//    //Finalizando a pagina e somando mais um
//    oPrintPvt:EndPage()
//    n_PagAtu++
//Return
// 
//
///*
//    Realiza a quebra de linha do arquivo
//    since: 11.08.2025
//*/
//Static Function fQuebra()
//    If n_LinAtu >= n_LinFin-10
//        fImpRod()
//        fImpCab()
//    EndIf
//Return
//
//
//
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Responsável por salvar o documento tanto na pasta quanto nas tabelas                @@@
@ envolvidas de banco de conhecimento                                                 @@@
@ Autor: Lucas Apolinario                                                             @@@
@ Since: 04/06/2025                                                                   @@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
Static function SavePdf(cArqOri)
   Local cDirDoc := Alltrim(GetMv("MV_DIRDOC"))
   Local cPath   := ''
   Local cArqNew := '' // Nome do arquivo pdf, mas considerando o registro dele como FILIAL + NUMERO DO ORÇAMENTO, para ser localizado posteriormente
   Local aArq    := {}
   Local nX      := 1
   Local lRet    := .t.

   
   if !empty(Alltrim(cArqOri))
       aArq := StrTokArr(cArqOri, "\")
       cArqAtu:= aArq[len(aArq)]

   
       //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
       If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
           cDirDoc := cDirDoc + "\"
       EndIf
       cPathBco := cDirDoc + 'co'+cEmpAnt+'\shared\'

       //se o diretorio nao existe, cria a pasta dirdoc para evitar erros
       If ! ExistDir(cPathBco)
           if ! ExistDir("\DIRDOC\")
               MakeDir("\DIRDOC\")
               MakeDir("\DIRDOC\co"+cEmpAnt+"")
               MakeDir(cPathBco)
           else
               MakeDir("\DIRDOC\co+"+cEmpAnt+"\")
               MakeDir(cPathBco)
           endif
       endif

       //Faz a cópia da origem, para a pasta do banco de conhecimento
       Copy File &(cArqOri) To &(cPathBco + cArqAtu)

       for nX:=1 to len(aArq)
           IIF(nX <> len(aArq), cPath += aArq[nX] + "\", cArqNew +=  cFilAnt + SCJ->CJ_NUM + SCJ->CJ_XREVISA + ".pdf" ) // coloco novo nome no arquivo
       next nX

       FRename(cPathBco + cArqAtu, cPathBco + cArqNew)

       //Se não conseguiu copiar, mostra um alerta, e volta o laço
       If ! File(cPathBco + cArqNew)
           MsgAlert("Erro ao importar: " + cPathBco + cArqNew, "Atencao!")
           lRet := .f.
       EndIf


       if lRet 
   
           //Pega o próximo registro da ACB
           DbSelectArea("ACB")
           ACB->(DbSetOrder(1))
           ACB->(DbGoBottom())
           cProxObj := StrZero((Val(ACB->ACB_CODOBJ) + 1), 10)
           ACB->(DbSetOrder(2))
           
           //Se não tiver o arquivo na ACB, irá incluir
           If ! ACB->(DbSeek(FWxFilial('ACB') + cArqNew))
               Reclock("ACB", .T.)
                   ACB->ACB_FILIAL := FWxFilial('ACB')
                   ACB->ACB_CODOBJ := cProxObj
                   ACB->ACB_OBJETO := cArqNew
                   ACB->ACB_DESCRI := cArqNew
               ACB->(MsUnlock())
               
               //Se não existir na tabela de vinculos, irá criar
               DbSelectArea("AC9")
               AC9->(DbSetOrder(1))
               If ! AC9->(DbSeek(FWxFilial('AC9') + cProxObj + SCJ->CJ_NUM ))
                   Reclock("AC9", .T.)
                       AC9->AC9_FILIAL := FWxFilial('AC9')
                       AC9->AC9_ENTIDA := 'SCJ'
                       AC9->AC9_CODENT := cFilAnt + SCJ->CJ_NUM 
                       AC9->AC9_FILENT := cFilAnt
                       AC9->AC9_CODOBJ := cProxObj
                   AC9->(MsUnlock())
               EndIf
           EndIf

       ENDIF

   else
       FwAlertWarning("Nenhum arquivo PDF foi selecionado para salvar ao banco de conhecimento!", "Impressão de PDF")
   endif

return
