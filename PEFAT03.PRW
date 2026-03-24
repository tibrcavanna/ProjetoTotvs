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
/*/{Protheus.doc} PEFAT03
Função principal do relatório pedido de venda
@type function
@version  1.0  
@author Anderson Quintiliano
@since 17/11/2025
@param c_Ped, character, param_description
@return variant, return_description
/*/
User Function PEFAT03(c_Ped)
    Local aArea := FWGetArea()
    Private c_Pedido:= c_Ped

    Processa({|| fImprime()})

    FWRestArea(aArea)
Return
 
/*/{Protheus.doc} fImprime
Função responsável por imprimir o relatório
@type function
@version  1.0  
@author Anderson Quintiliano
@since 17/11/2025
@return variant, return_description
/*/
Static Function fImprime()
    Local aArea        := GetArea()
    Local n_AtuAux      := 0
    Local c_Arquivo     := 'Pedido'+ c_Pedido +"_"+ FWTimeStamp(2, Date(),Time())+ '.pdf'

    Local n_PrcUn:=0
    Local n_PrcTo:=0
    Local n_Total:=0
    Local n_STotal:=0
    Local n_Ni:=0

    Private n_TotAux      := 0
    Private a_Dados := {}
    Private oPrintPvt
    Private oBrushLin  := TBrush():New(,nCorLinha)
    Private c_HoraEx    := Time()
    Private n_PagAtu    := 1
    Private c_LogoEmp   := fLogoEmp()
    //Linhas e colunas
    Private n_LinAtu    := 0
    Private n_LinFin    := 580
    Private n_ColIni    := 010
    Private n_ColFin    := 800
    Private n_ColMeio   := (n_ColFin-n_ColIni)/2
    Private c_Sigla     := ''
    Private n_CabMod    := 0

    //Colunas dos relatorio
    Private n_ColDad01 := n_ColIni        //ITEM
    Private n_ColDad02 := n_ColIni + 20   //IMAGEM
    Private n_ColDad03 := n_ColIni + 100  //CODIGO
    Private n_ColDad04 := n_ColIni + 180  //DESCRICAO
    Private n_ColDad05 := n_ColIni + 280  //PRAZO
    Private n_ColDad06 := n_ColIni + 310  //PESO
    Private n_ColDad07 := n_ColIni + 380  //NCM
    Private n_ColDad08 := n_ColIni + 430  //QTD
    Private n_ColDad09 := n_ColIni + 500  //UN
    Private n_ColDad10 := n_ColIni + 530  //PRECO UNITARIO
    Private n_ColDad11 := n_ColIni + 590 //DESCONTO
    Private n_ColDad12 := n_ColIni + 630  //PRECO TOTAL
    Private n_ColDad13 := n_ColIni + 690  //IPI
    Private n_ColDad14 := n_ColIni + 730 //TOTAL COM IPI

    Private c_Garantia   := ''
    Private c_Notas      := ''
    Private c_InfAdic    := ''

    Private n_Idioma     := ''
    Private c_ImprImpostos := ''
    Private _aImpostos   := {}

    //Declarando as fontes
    Private c_NomeFont  := 'Arial'
    Private oFontDet   := TFont():New(c_NomeFont, 7, -6, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(c_NomeFont, 7, -6, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(c_NomeFont, 7, -9,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(c_NomeFont, 4, -4,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(c_NomeFont, 7, -15, .T., .T., 5, .T., 5, .T., .F.)
    Private n_Lin:=0

    //Monta a consulta de dados

    c_QryAux:= "select B1_DESC,B1_IPI,B1_PESO,B1_POSIPI,C5_CLIENTE,C5_CONDPAG,C5_EMISSAO,C5_MOEDA,C5_TXMOEDA,C6_CLI,C6_DESCONT,C6_ENTREG,C6_ITEM,C6_LOJA,C6_PRCVEN,C6_PRODUTO,C6_QTDENT,C6_QTDVEN,C6_TES,C6_UM,C6_VALOR,E4_DESCRI, C6_NUMPCOM, C5_FECENT " + CRLF
    c_QryAux+= "FROM " + RETSQLNAME('SC5') + " C5 INNER JOIN " + RETSQLNAME('SC6') +" C6 " + CRLF
    c_QryAux+= "ON C5_FILIAL=C6_FILIAL AND C6_NUM=C5_NUM AND C6.D_E_L_E_T_='' " + CRLF
    c_QryAux+= "INNER JOIN " + RETSQLNAME('SB1') + " B1 ON B1_FILIAL='"+xFilial('SB1')+"' AND C6_PRODUTO=B1_COD AND B1.D_E_L_E_T_='' " + CRLF
    c_QryAux+= "INNER JOIN " + RETSQLNAME('SE4') + " E4 ON E4_FILIAL='"+xFilial('SE4')+"' AND E4_CODIGO=C5_CONDPAG AND E4.D_E_L_E_T_='' " + CRLF
    c_QryAux+= "WHERE C5_NUM='" + c_Pedido + "' AND C5.D_E_L_E_T_='' " + CRLF
    c_QryAux+= "ORDER BY C5_NUM, C6_ITEM " + CRLF

    PLSQuery(c_QryAux, 'QRY_AUX')

    DbSelectArea('QRY_AUX')
    QRY_AUX->(DbGoTop())
    Count to n_TotAux
    ProcRegua(n_TotAux)
    QRY_AUX->(DbGoTop())


    c_QryCli:= "SELECT * FROM ( " + CRLF
    c_QryCli+= "SELECT A1_COD, A1_LOJA, A1_NOME, A1_END, A1_NREDUZ, A1_BAIRRO, A1_TIPO, A1_EST, A1_COD_MUN, A1_ESTADO, A1_CEP, A1_MUN, A1_DDD, A1_TEL, A1_CONTATO, A1_FILIAL, A1_PESSOA, A1_XIDIOMA, A1_CGC, A1_INSCR, A1_ENDENT, A1_COMPENT, A1_BAIRROE, A1_ESTE FROM  " + RETSQLNAME('SA1') + " A1 WHERE D_E_L_E_T_='' " + CRLF
    c_QryCli+= "UNION ALL " + CRLF
    c_QryCli+= "SELECT A2_COD, A2_LOJA, A2_NOME, A2_END, A2_NREDUZ, A2_BAIRRO, A2_TIPO, A2_EST, A2_COD_MUN, A2_ESTADO, A2_CEP, A2_MUN, A2_DDD, A2_TEL, A2_CONTATO, A2_FILIAL, '' A2_PESSOA, '' A2_XIDIOMA, '', '', '', '', '', '' FROM  " + RETSQLNAME('SA2') + " A2 WHERE D_E_L_E_T_='' " + CRLF
    c_QryCli+= ")TMP " + CRLF
    c_QryCli+= "Where A1_COD='" + QRY_AUX->C5_CLIENTE + "' " + CRLF

    PLSQuery(c_QryCli, 'QRYCli') // junta SA1 e SA2 para pegar o cliente

    //Calcula os impostos
    _aImpostos := u_FIMPOSTOS(QRY_AUX->C6_CLI,QRY_AUX->C6_LOJA,QRYCli->A1_TIPO,QRY_AUX->C6_PRODUTO,QRY_AUX->C6_TES,QRY_AUX->C6_QTDVEN,(QRY_AUX->C6_PRCVEN*QRY_AUX->C5_TXMOEDA),((QRY_AUX->C6_QTDVEN-QRY_AUX->C6_QTDENT)*(QRY_AUX->C6_PRCVEN*QRY_AUX->C5_TXMOEDA)))


    //Pega a taxa da moeda na data do pedido
    n_CabMod:= QRY_AUX->C5_MOEDA
    n_Idioma:= val(QRYCli->A1_XIDIOMA)

    n_MoedaTX:= fMoedaTX(n_CabMod, dTos(QRY_AUX->C5_EMISSAO))  // moeda pedido
    n_MoedaLg:= fMoedaTX(n_Idioma, dTos(QRY_AUX->C5_EMISSAO))  // moeda para conversao lingua

    n_Lin:= 0

    //Somente se tiver dados
    If !QRY_AUX->(EoF())
        //Criando o objeto de impressao
        oPrintPvt := FWMSPrinter():New(c_Arquivo, IMP_PDF, .F., ,   .T., ,    @oPrintPvt, ,   ,    , ,.T.)
        oPrintPvt:cPathPDF := GetTempPath()
        oPrintPvt:SetResolution(72)
        oPrintPvt:SetLandScape()
        oPrintPvt:SetPaperSize(DMPAPER_A4)
        oPrintPvt:SetMargin(0, 0, 0, 0)
   
        DbSelectArea('SCJ')
        SCJ->(DbSetOrder(1))
        SCJ->(DbSeek(xFilial('SCJ')+c_Pedido+QRY_AUX->C5_CLIENTE+QRY_AUX->C6_LOJA)) //CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA

        c_Garantia   := c_Garantia + Space(10) + AllTrim(SCJ->CJ_GARANTI)
        c_Notas      := c_Notas + Space(10) + AllTrim(SCJ->CJ_NOTAS)
        c_InfAdic    := c_InfAdic + Space(10) +  AllTrim(SCJ->CJ_INFCOMP)
        SCJ->(DbCloseArea()) //Fecha area SCK

        c_ImprImpostos := ''
        
        for n_NI := 3 to len(_aImpostos)
            c_ImprImpostos += iif(n_NI > 3 .and. _aImpostos[n_NI+2] > 0,' / ','') + iif(_aImpostos[n_NI+2] > 0, _aImpostos[n_NI] +' - '+ Transform(_aImpostos[n_NI+2],'@E 99.99'),'')
            n_NI+=3
        next

        //Imprime os dados
        fImpCab()

        oPrintPvt:Line(n_LinAtu-3, n_ColIni,n_LinAtu-3, n_ColFin, nCorCinza)

        //Percorre os registros
  
        While !QRY_AUX->(EoF())
            n_AtuAux++
            IncProc('Imprimindo registro ' + cValToChar(n_AtuAux) + ' de ' + cValToChar(n_TotAux) + '...')
  
            //Se atingiu o limite, quebra de pagina
            fQuebra()
              
            c_QRYCon:= "select * from "+ RETSQLNAME("AC9")+" AC9 INNER JOIN  "+ RETSQLNAME("ACB")+" ACB " + CRLF
            c_QRYCon+= "ON AC9_ENTIDA='SB1' AND AC9_CODOBJ=ACB_CODOBJ  AND ACB.D_E_L_E_T_='' " + CRLF
            c_QRYCon+= "where AC9_CODENT='"+ AllTrim(QRY_AUX->C6_PRODUTO)+"'  AND AC9.D_E_L_E_T_='' " + CRLF

            PLSQuery(c_QRYCon, 'c_QRYCon')

            c_Image:= "\dirdoc\co"+AllTrim(FWCodEmp())+"\shared\" + AllTrim(c_QRYCon->ACB_OBJETO)

            //Imprime a linha atual

            //oPrintPvt:SayAlign(30, 700, ': '+ Transform(n_MoedaTX,"@E 999.9999") + CRLF + ': '+ Transform(n_MoedaLg,"@E 999.9999") , oFontMin, 100, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            oPrintPvt:SayAlign(n_LinAtu, n_ColDad01, Alltrim(QRY_AUX->C6_ITEM), oFontDet, 20, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            oPrintPvt:SayBitmap(n_LinAtu,n_ColDad02+10,c_Image , 40,40) // imagem do banco do conhecimento

            //  nRow|   nCol| cText| oFont  | nWdt|     nHgt| nClrText| nAlignHorz| nAlignVert
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad03, Transform(QRY_AUX->C6_PRODUTO,''), oFontDet, 80, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad04, Alltrim(QRY_AUX->B1_DESC), oFontDet, 100, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad05, AllTrim(Transform(DateDiffDay(QRY_AUX->C5_EMISSAO, QRY_AUX->C6_ENTREG),"@E 999,999,999")), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad06, AllTrim(Transform(QRY_AUX->B1_PESO,GetSX3Cache("B1_PESO","X3_PICTURE"))), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad07, AllTrim(Transform(QRY_AUX->B1_POSIPI,GetSX3Cache("B1_POSIPI","X3_PICTURE"))), oFontDet, 40, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad08, AllTrim(Transform(QRY_AUX->C6_QTDVEN,GetSX3Cache("C6_QTDVEN","X3_PICTURE"))), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad09, Alltrim(QRY_AUX->C6_UM), oFontDet, 15, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, Transform(fConvertMoeda(QRY_AUX->C6_PRCVEN, n_MoedaTX, n_MoedaLg, n_CabMod,n_Idioma),GetSX3Cache("C6_VALOR","X3_PICTURE")), oFontDet, 40, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad11, Transform(QRY_AUX->C6_DESCONT,"@E 999.99"), oFontDet, 25, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, Transform(fConvertMoeda(QRY_AUX->C6_VALOR, n_MoedaTX, n_MoedaLg, n_CabMod,n_Idioma),GetSX3Cache("C6_VALOR","X3_PICTURE")), oFontDet, 50, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad13, Transform(QRY_AUX->B1_IPI,GetSX3Cache("B1_IPI","X3_PICTURE")), oFontDet, 15, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            n_STotal:= QRY_AUX->C6_VALOR+((QRY_AUX->C6_PRCVEN *(QRY_AUX->B1_IPI/100)) * QRY_AUX->C6_QTDVEN)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, Transform(fConvertMoeda(n_STotal, n_MoedaTX, n_MoedaLg, n_CabMod,n_Idioma),GetSX3Cache("C6_VALOR","X3_PICTURE")), oFontDet, 35,50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

           n_LinAtu += 50
            oPrintPvt:Line(n_LinAtu-3, n_ColIni,n_LinAtu-3, n_ColFin, nCorCinza)
  
            //Se atingiu o limite, quebra de pagina
            fQuebra()

            n_PrcUn:=n_PrcUn + QRY_AUX->C6_PRCVEN
            n_PrcTo:=n_PrcTo + QRY_AUX->C6_VALOR
            n_Total:=n_Total + n_STotal

            n_lin++

            QRY_AUX->(DbSkip())
        EndDo

        oPrintPvt:SayAlign(n_LinAtu, 100, 'Total ' + c_Sigla, oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:Line(n_LinAtu+14, n_ColIni,n_LinAtu+14, n_ColFin, nCorCinza)

        oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, Transform(fConvertMoeda(n_PrcUn, n_MoedaTX, n_MoedaLg, n_CabMod,n_Idioma),GetSX3Cache("C6_VALOR","X3_PICTURE")), oFontDet, 35, 10, /*nClrText*/, PAD_RIGHT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, Transform(fConvertMoeda(n_PrcTo, n_MoedaTX, n_MoedaLg, n_CabMod,n_Idioma),GetSX3Cache("C6_VALOR","X3_PICTURE")), oFontDet, 35, 10, /*nClrText*/, PAD_RIGHT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, Transform(fConvertMoeda(n_Total, n_MoedaTX, n_MoedaLg, n_CabMod,n_Idioma),GetSX3Cache("C6_VALOR","X3_PICTURE")), oFontDet, 35, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

        fInfComp()
        
        fImpRod()
          
        oPrintPvt:Preview()
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
@return variant, return_description
/*/
 Static Function fImpCab()
    Local cCodUsr   := ""
    Local cNomUsr   := "" 
    Local cNomeEmpresa := ''
    Private n_LinCab  := 015

    //Iniciando Pagina
    oPrintPvt:StartPage()

    
    oPrintPvt:SayBitmap(20,20, '\SYSTEM\lgrl0101.bmp',90,25) // imagem do banco do conhecimento

    n_LinAtu := n_LinCab + 5

    a_Dados:= {}

    /*01*/ aAdd(a_Dados,{'Pedido de Venda Nº:' , 'Orden de Venta Nº:' , 'Sales Order Nº:' })
    /*02*/ aAdd(a_Dados,{'Data:' , ' Fecha:' , 'Date:' })
    /*03*/ aAdd(a_Dados,{'Ordem Cliente:' ,'Pedido del cliente:' , 'Customer Order:' })
    /*04*/ aAdd(a_Dados,{'Código Cliente:' , ' Codigo Cliente:' , 'Customer Code:' })
    /*05*/ aAdd(a_Dados,{'Endereço do  Cliente:' , 'Dirección del cliente:' , 'Customer Address:' })
    /*06*/ aAdd(a_Dados,{'Endereço de Entrega:' , 'Dirección de entrega:' , 'Delivery Address:' })
    /*07*/ aAdd(a_Dados,{'Contato: ','Contacto: ', 'Contact: '})
    /*08*/ aAdd(a_Dados,{'Referência Cliente: ','Referencia del cliente: ', 'Customer Reference: '})
    /*09*/ aAdd(a_Dados,{'R$ ', 'U$ ', '€ '})


        // imprime informações do cabeçalho
        oPrintPvt:Line(n_LinAtu-3, n_ColIni, n_LinAtu-3, n_ColFin, nCorCinza)
        
        oPrintPvt:SayAlign(n_LinAtu+5, n_ColIni+300, iif(n_Idioma==3,a_Dados[ 1,3],iif(n_Idioma==2,a_Dados[ 1,2],a_Dados[ 1,1])), oFontDetN, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+5, n_ColIni+400, iif(n_Idioma==3,a_Dados[ 2,3],iif(n_Idioma==2,a_Dados[ 2,2],a_Dados[ 2,1])), oFontDetN, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+5, n_ColIni+500, iif(n_Idioma==3,a_Dados[ 3,3],iif(n_Idioma==2,a_Dados[ 3,2],a_Dados[ 3,1])), oFontDetN, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+5, n_ColIni+600, iif(n_Idioma==3,a_Dados[ 4,3],iif(n_Idioma==2,a_Dados[ 4,2],a_Dados[ 4,1])), oFontDetN, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)


        oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+300, c_Pedido, oFontDet, 30, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+400, dtoc(SC5->C5_EMISSAO), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+500, dtoc(QRY_AUX->C5_FECENT), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+600, SC5->C5_CLIENTE, oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        n_LinAtu+=30
        oPrintPvt:Line(n_LinAtu, n_ColIni, n_LinAtu, n_ColFin, nCorCinza)

        // imprime informações do cliente
        oPrintPvt:SayAlign(n_LinAtu+10, n_ColIni+30, iif(n_Idioma==3,a_Dados[ 5,3],iif(n_Idioma==2,a_Dados[ 5,2],a_Dados[ 5,1])), oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+20, n_ColIni+30, QRYCli->A1_NOME, oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+30, n_ColIni+30, QRYCli->A1_END+' '+QRYCli->A1_BAIRRO+' '+QRYCli->A1_MUN+'-'+QRYCli->A1_CEP, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+40, n_ColIni+30, 'Fone: ' + Alltrim(QRYCli->A1_TEL), oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    
        IF !Empty(QRYCli->A1_CGC) .OR. !Empty(QRYCli->A1_INSCR)   
            oPrintPvt:SayAlign(n_LinAtu+50, n_ColIni+30, AllTrim(QRYCli->A1_CGC)+'/ '+AllTrim(QRYCli->A1_INSCR), oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        ENDIF
    
        oPrintPvt:SayAlign(n_LinAtu+70, n_ColIni+30,iif(n_Idioma==3,a_Dados[ 7,3],iif(n_Idioma==2,a_Dados[ 7,2],a_Dados[ 7,1]))+ QRYCli->A1_CONTATO, oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        // oPrintPvt:SayAlign(n_LinAtu+80, n_ColIni+30,iif(n_Idioma==3,a_Dados[ 8,3],iif(n_Idioma==2,a_Dados[ 8,2],a_Dados[ 8,1]))+ QRYCli->A1_CONTATO, oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

        // imprime informações do local de entrega
        oPrintPvt:SayAlign(n_LinAtu+10, n_ColIni+300, iif(n_Idioma==3,a_Dados[ 6,3],iif(n_Idioma==2,a_Dados[ 6,2],a_Dados[ 6,1])), oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+20, n_ColIni+300, AllTrim(QRYCli->A1_NOME), oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+30, n_ColIni+300, AllTrim(QRYCli->A1_ENDENT)+' '+AllTrim(QRYCli->A1_COMPENT)+''+AllTrim(QRYCli->A1_BAIRROE)+' '+AllTrim(QRYCli->A1_ESTE), oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

        IF !Empty(QRYCli->A1_CGC) .OR. !Empty(QRYCli->A1_INSCR)   
            oPrintPvt:SayAlign(n_LinAtu+50, n_ColIni+300, AllTrim(QRYCli->A1_CGC)+'/ '+AllTrim(QRYCli->A1_INSCR), oFontDet, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        ENDIF

        n_CabMod:= QRY_AUX->C5_MOEDA
        n_Idioma:= val(QRYCli->A1_XIDIOMA)

        c_Sigla:= iif(n_Idioma == 3, AllTrim(a_Dados[9,3]), iif(n_Idioma == 2, AllTrim(a_Dados[9,2]), AllTrim(a_Dados[9,1]))) 

        a_Dados:= {}

        n_LinAtu += 100
        oPrintPvt:Line(n_LinAtu-3, n_ColIni, n_LinAtu-3, n_ColFin, nCorCinza)
        n_LinAtu += 5


    /*01*/ aAdd(a_Dados,{'Item' , ' Item' , 'Item' })
    /*02*/ aAdd(a_Dados,{'Imagem' , ' Image' , 'Image' })
    /*03*/ aAdd(a_Dados,{'Código' , ' Codigo' , 'Code' })
    /*04*/ aAdd(a_Dados,{'Descrição' , ' Descripción' , 'Description' })
    /*05*/ aAdd(a_Dados,{'Prazo' , ' Plazo' , 'Delivery' })
    /*06*/ aAdd(a_Dados,{'Peso (KG)' , ' Peso (KG)' , 'Net Weigth (KG)' })
    /*07*/ aAdd(a_Dados,{'NCM' , ' NCM NALADISH' , 'NCM-HS Code' })
    /*08*/ aAdd(a_Dados,{'Qtd.' , ' Cant.' , 'Qty.' })
    /*09*/ aAdd(a_Dados,{'Un.' , ' Un.' , 'Un.' })
    /*10*/ aAdd(a_Dados,{'Preço Unitário '+c_Sigla , 'Precio Unitário '+c_Sigla , 'Unit Price '+c_Sigla})
    /*11*/ aAdd(a_Dados,{'Desc %' , ' Desc %' , 'Desc %' })
    /*12*/ aAdd(a_Dados,{'Preço Total '+c_Sigla, 'Precio Total '+c_Sigla, 'Total Price '+c_Sigla})
    /*13*/ aAdd(a_Dados,{'IPI %' , ' IVA %' , 'IVA %' })
    /*14*/ aAdd(a_Dados,{'Total com IPI '+c_Sigla , 'Total con IVA '+c_Sigla , 'Amonunt Price IVA '+c_Sigla})
    /*15*/ aAdd(a_Dados,{'Tipo Entrada: ' , ' Tipo de entrada: ' , 'Entry Type: ' })
    /*16*/ aAdd(a_Dados,{ 'Pagamento: '+ SC5->C5_CONDPAG+' - '+ QRY_AUX->E4_DESCRI, 'Pago: '+ SC5->C5_CONDPAG+' - '+ QRY_AUX->E4_DESCRI, 'Payment: '+ SC5->C5_CONDPAG+' - '+ QRY_AUX->E4_DESCRI})
    /*17*/ aAdd(a_Dados,{'Impostos Inclusos: ' + Space(20) + c_ImprImpostos , 'Impuestos incluidos: '+  Space(20) + c_ImprImpostos, 'Taxes Included: '+ Space(20) + c_ImprImpostos })

    cCodUsr := RetCodUsr()
    cNomUsr := UsrRetName(cCodUsr)
    cNomeEmpresa := FwFilialName()

    /*18*/ aAdd(a_Dados,{'Assinatura: ' + Space(200)+ AllTrim(cNomeEmpresa), ' Suscripción: ' + Space(200)+AllTrim(cNomeEmpresa) , 'Subscription: ' + Space(200)+AllTrim(cNomeEmpresa) })
   
    /*19*/ aAdd(a_Dados,{'Garantia: ' + CRLF + Space(20) + AllTrim(c_Garantia) , ' Garantía: ' + CRLF + Space(20) + AllTrim(c_Garantia) , 'Warranty: '+ CRLF + Space(20) + AllTrim(c_Garantia)  })
    /*20*/ aAdd(a_Dados,{'Notas: '+ CRLF + Space(20) + AllTrim(c_Notas) , ' Notas: '+ CRLF + Space(20) + AllTrim(c_Notas) , 'Notes: '+ CRLF + Space(20) + AllTrim(c_Notas) })
    /*21*/ aAdd(a_Dados,{'Informação Complementar: ' + CRLF +Space(20) + AllTrim(c_InfAdic), ' Información adicional: ' + CRLF +Space(20) + AllTrim(c_InfAdic) , 'Additional Information: '  +  CRLF + Space(20) + AllTrim(c_InfAdic)})

    oPrintPvt:SayAlign(n_LinAtu, n_ColDad01, iif(n_Idioma==3,a_Dados[ 1,3],iif(n_Idioma==2,a_Dados[ 1,2],a_Dados[ 1,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02, iif(n_Idioma==3,a_Dados[ 2,3],iif(n_Idioma==2,a_Dados[ 2,2],a_Dados[ 2,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad03, iif(n_Idioma==3,a_Dados[ 3,3],iif(n_Idioma==2,a_Dados[ 3,2],a_Dados[ 3,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad04, iif(n_Idioma==3,a_Dados[ 4,3],iif(n_Idioma==2,a_Dados[ 4,2],a_Dados[ 4,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad05, iif(n_Idioma==3,a_Dados[ 5,3],iif(n_Idioma==2,a_Dados[ 5,2],a_Dados[ 5,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad06, iif(n_Idioma==3,a_Dados[ 6,3],iif(n_Idioma==2,a_Dados[ 6,2],a_Dados[ 6,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad07, iif(n_Idioma==3,a_Dados[ 7,3],iif(n_Idioma==2,a_Dados[ 7,2],a_Dados[ 7,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad08, iif(n_Idioma==3,a_Dados[ 8,3],iif(n_Idioma==2,a_Dados[ 8,2],a_Dados[ 8,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad09, iif(n_Idioma==3,a_Dados[ 9,3],iif(n_Idioma==2,a_Dados[ 9,2],a_Dados[ 9,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, iif(n_Idioma==3,a_Dados[10,3],iif(n_Idioma==2,a_Dados[10,2],a_Dados[10,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad11, iif(n_Idioma==3,a_Dados[11,3],iif(n_Idioma==2,a_Dados[11,2],a_Dados[11,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, iif(n_Idioma==3,a_Dados[12,3],iif(n_Idioma==2,a_Dados[12,2],a_Dados[12,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad13, iif(n_Idioma==3,a_Dados[13,3],iif(n_Idioma==2,a_Dados[13,2],a_Dados[13,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, iif(n_Idioma==3,a_Dados[14,3],iif(n_Idioma==2,a_Dados[14,2],a_Dados[14,1])) , oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    n_LinAtu += 15
Return
 
/*/{Protheus.doc} fImpRod
imprime o rodpé
@type function
@version  1.0  
@author Anderson Quintiliano
@since 17/11/2025
@return variant, return_description
/*/
Static Function fImpRod()
    Local n_linRod:= n_LinFin
    Local cTexto := ''

     //Linha Separatoria
    oPrintPvt:Line(n_linRod,   n_ColIni, n_linRod,   n_ColFin)
    n_linRod += 3

    //Dados da Esquerda
    cTexto := dToC(dDataBase) + '     ' + c_HoraEx + '     ' + FunName() + ' (Orçamento)     ' + UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(n_linRod, n_ColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )

    cTexto:= ""

    //Direita
    cTexto := 'Pagina '+cValToChar(n_PagAtu)
    oPrintPvt:SayAlign(n_linRod, n_ColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
      
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
@return variant, return_description
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
@return variant, return_description
/*/
Static Function fInfComp()
    oPrintPvt:SayAlign(n_LinAtu+030, 50, iif(n_Idioma==3,a_Dados[21,3],iif(n_Idioma==2,a_Dados[21,2],a_Dados[21,1])) , oFontDetN, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+040, 50, iif(n_Idioma==3,a_Dados[15,3],iif(n_Idioma==2,a_Dados[15,2],a_Dados[15,1])) , oFontDetN, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+050, 50, iif(n_Idioma==3,a_Dados[16,3],iif(n_Idioma==2,a_Dados[16,2],a_Dados[16,1])) , oFontDetN, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+060, 50, iif(n_Idioma==3,a_Dados[17,3],iif(n_Idioma==2,a_Dados[17,2],a_Dados[17,1])) , oFontDetN, 400, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    oPrintPvt:SayAlign(n_LinAtu+075, 50, iif(n_Idioma==3,a_Dados[20,3],iif(n_Idioma==2,a_Dados[20,2],a_Dados[20,1])) , oFontDetN, 400, 30, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+100, 50, iif(n_Idioma==3,a_Dados[21,3],iif(n_Idioma==2,a_Dados[21,2],a_Dados[21,1])) , oFontDetN, 400, 30, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
 //   oPrintPvt:SayAlign(n_LinAtu+140, 50, iif(n_Idioma==3,a_Dados[22,3],iif(n_Idioma==2,a_Dados[22,2],a_Dados[22,1])) , oFontMin, 400, 30, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    oPrintPvt:SayAlign(n_LinAtu+120, 50, iif(n_Idioma==3,a_Dados[19,3],iif(n_Idioma==2,a_Dados[19,2],a_Dados[19,1])) , oFontDetN, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+150, 50, iif(n_Idioma==3,a_Dados[18,3],iif(n_Idioma==2,a_Dados[18,2],a_Dados[18,1])) , oFontDetN, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
Return

/*/{Protheus.doc} fMoedaTX
funcção para busca da taxa de moeda na data informada
@type function
@version  1.0  
@author Anderson Quintiliano
@since 17/11/2025
@param nMoeda, numeric, param_description
@param dData, date, param_description
@return variant, return_description
*/

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
Função faz a converção de moedas levando em consideração o idioma do cliente e a moeda do orçamento
@type function
@version  1.0  
@author Anderson Quintiliano
@since 17/11/2025
@param n_Val, numeric, param_description
@param n_VlMoe, numeric, param_description
@param n_VlrLg, numeric, param_description
@param n_LgMoed, numeric, param_description
@param n_Ling, numeric, param_description
@return variant, return_description
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
