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

/*
{Protheus.doc} PEFAT04
Gera relatório de Invoice em PDF com informações formatadas, incluindo cabeçalho, tabela de itens e visualização do documento, utilizando recursos gráficos do Protheus.
@type function
@version 1.0
@author ANDERSON REZENDE
@since 12/11/2025
*/

User Function PEFAT04(c_Inv)

    Local aArea := FWGetArea()
    Private c_Invoice:= c_Inv

    Processa({|| fImprime()})

    FWRestArea(aArea)
Return


/*/{Protheus.doc} fImprime
Função de impressão 
@type function
@version  1.0
@author ANDERSON REZENDE
@since 17/11/2025
@return variant, return_description
/*/

Static Function fImprime()
    Local aArea        := GetArea()
    Local n_AtuAux      := 0
    Local c_QryAux      := ''
    Local c_Arquivo     := 'Invoice'+c_Invoice+"_" + FWTimeStamp(2, Date(), Time())+ '.pdf'

    Local n_PrcUn:=0
    Local n_PrcTo:=0
    Local n_Total:=0
    Local n_ContImg:=0

    Private n_TotAux     := 0
    Private aDados      := {}
    Private oPrintPvt
    Private oBrushLin   := TBrush():New(,nCorLinha)
    Private c_HoraEx     := Time()
    Private n_PagAtu     := 1
    Private c_LogoEmp    := fLogoEmp()
    //Linhas e colunas
    Private n_LinAtu     := 0
    Private n_LinFin     := 570
    Private n_ColIni     := 010
    Private n_ColFin     := 800
    Private n_ColMeio    := (n_ColFin-n_ColIni)/2

    //Colunas dos relatorio
    Private n_ColDad01   := n_ColIni + 30  //ITEM
    Private n_ColDad02   := n_ColIni + 70  //CODIGO
    Private n_ColDad03   := n_ColIni + 120  //DESCRICAO
    Private n_ColDad04   := n_ColIni + 340  //PESO             
    Private n_ColDad05   := n_ColIni + 400  //QTD
    Private n_ColDad06   := n_ColIni + 440  //NCM 
    Private n_ColDad07   := n_ColIni + 490  //und
    Private n_ColDad08   := n_ColIni + 540  //PRECO UNIT
    Private n_ColDad09   := n_ColIni + 600 //PRECO total
    Private n_ColDad10   := n_ColIni + 660 //IPI
    Private n_ColDad11   := n_ColIni + 700 //TOTALIZADOR

    Private n_ColDad12   := n_ColIni + 540 //TOTALIZADOR
    Private n_ColDad13   := n_ColIni + 600 //TOTALIZADOR
    Private n_ColDad14   := n_ColIni + 700 //TOTALIZADOR

    Private c_ConEnt     := ''
    Private c_ConPag     := ''
    Private c_DadBco     := ''
    Private c_Embala     := ''

    Private c_Sigla      := ''
    Private n_Idioma     := 0
    Private n_CabMod     := 0

    Private c_Cliente     := ''
    Private c_Loja        := ''
    Private c_NumPed      := ''
    Private n_LinBK       := 0


    //Declarando as fontes
    Private c_NomeFont  := 'Arial'
    Private oFontDet   := TFont():New(c_NomeFont, 9, -6, .T., .F., 5, .T., 5, .T., .F.)
    Private oFontDetN  := TFont():New(c_NomeFont, 9, -6, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRod   := TFont():New(c_NomeFont, 8, -9,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontMin   := TFont():New(c_NomeFont, 8, -6,  .T., .F., 5, .T., 5, .T., .F.)
    Private oFontTit   := TFont():New(c_NomeFont, 16, -16, .T., .T., 5, .T., 5, .T., .F.)
    Private oFontRodEmp:= TFont():New(c_NomeFont, , -5, .T., .T., 5, .T., 5, .T., .F.)
    Private n_Lin:=0
    Private cMoeda:= ""

    //Monta a consulta de dados


    c_QryAux:="select A1_BAIRRO,A1_CEP,A1_END,A1_EST,A1_XIDIOMA,A1_MUN,A1_NOME,B1_DESC,B1_PICM,B1_IPI,B1_PESO,B1_POSIPI,C5_CLIENTE,C5_CONDPAG,C5_EMISSAO,C5_FILIAL,C5_LOJACLI,C5_MOEDA,C5_NOTA,C5_NUM,C5_SERIE,C6_ITEM,C6_PRCVEN,C6_PRODUTO,C6_QTDVEN,C6_UM,E4_DESCRI,F2_DOC, C5_XTERMOS " +CRLF
    c_QryAux+="from "+RETSQLNAME("SC6")+" C6 " +CRLF
    c_QryAux+="	INNER JOIN "+RETSQLNAME("SC5")+" C5 on C5_FILIAL=C6_FILIAL AND C5_NUM=C6_NUM AND C5.D_E_L_E_T_='' "+CRLF
    c_QryAux+="	INNER JOIN "+RETSQLNAME("SE4")+" E4 on C5_CONDPAG=E4_CODIGO AND E4.D_E_L_E_T_='' "+CRLF
    c_QryAux+="	INNER JOIN "+RETSQLNAME("SB1")+" B1 on B1_FILIAL='"+xFILIAL('SB1')+"' AND B1_COD=C6_PRODUTO AND B1.D_E_L_E_T_='' "+CRLF
    c_QryAux+="	INNER JOIN "+RETSQLNAME("SA1")+" A1 ON A1_COD=C5_CLIENTE AND A1_LOJA=C5_LOJACLI AND A1.D_E_L_E_T_='' "+CRLF
    c_QryAux+="	INNER JOIN "+RETSQLNAME("SF2")+" F2 ON F2_FILIAL=C5_FILIAL AND F2_DOC=C6_NOTA AND  F2_SERIE=C6_SERIE AND F2_CLIENTE=C5_CLIENTE AND F2_LOJA=C5_LOJACLI AND F2.D_E_L_E_T_=''  "+CRLF
    c_QryAux+="	WHERE C6_NUM='" + c_Invoice + "' AND C6_NOTA<>'' AND C5_TIPO='N' AND C6.D_E_L_E_T_='' "
    c_QryAux+="	ORDER BY C6_ITEM, C6_PRODUTO "

    PLSQuery(c_QryAux, 'QRY_AUX')
  
    //Define o tamanho da régua
    DbSelectArea('QRY_AUX')
    QRY_AUX->(DbGoTop())
    Count to n_TotAux
    ProcRegua(n_TotAux)
    QRY_AUX->(DbGoTop())

    c_Cliente   := QRY_AUX->C5_CLIENTE
    c_Loja      := QRY_AUX->C5_LOJACLI
    c_NumPed    := QRY_AUX->C5_NUM
    c_Termos    := QRY_AUX->C5_XTERMOS
    c_CondPag   := QRY_AUX->C5_CONDPAG +' - '+ QRY_AUX->E4_DESCRI
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
        n_CabMod     := QRY_AUX->C5_MOEDA

        //Imprime os dados
        fImpCab()

        While ! QRY_AUX->(EoF())
            n_AtuAux++
            IncProc('Imprimindo registro ' + cValToChar(n_AtuAux) + ' de ' + cValToChar(n_TotAux) + '...')
  
            //Se atingiu o limite, quebra de pagina
            fQuebra()
  
            //Imprime a linha atual
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad01, Alltrim(QRY_AUX->C6_ITEM), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad02, Transform(QRY_AUX->C6_PRODUTO,''), oFontDet, 100, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad03, Alltrim(QRY_AUX->B1_DESC), oFontDet, 200, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad04, Alltrim(Transform(QRY_AUX->B1_PESO,GetSX3Cache("B1_PESO","X3_PICTURE"))), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad05, Alltrim(Transform(QRY_AUX->C6_QTDVEN,GetSX3Cache("C6_QTDVEN","X3_PICTURE"))), oFontDet, 30, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad06, Alltrim(Transform(QRY_AUX->B1_POSIPI,GetSX3Cache("B1_POSIPI","X3_PICTURE"))), oFontDet, 40, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad07, Alltrim(QRY_AUX->C6_UM), oFontDet, 20, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad08, Alltrim(Transform(QRY_AUX->C6_PRCVEN,GetSX3Cache("C6_VALOR","X3_PICTURE"))), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad09, Alltrim(Transform(QRY_AUX->C6_PRCVEN*QRY_AUX->C6_QTDVEN,GetSX3Cache("C6_VALOR","X3_PICTURE"))), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, Alltrim(Transform(QRY_AUX->B1_IPI,GetSX3Cache("B1_IPI","X3_PICTURE"))), oFontDet, 25, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
            oPrintPvt:SayAlign(n_LinAtu, n_ColDad11, Alltrim(Transform((((QRY_AUX->C6_QTDVEN*QRY_AUX->C6_PRCVEN)*(QRY_AUX->B1_IPI/100))+(QRY_AUX->C6_QTDVEN*QRY_AUX->C6_PRCVEN)),GetSX3Cache("C6_VALOR","X3_PICTURE"))), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            n_LinAtu += 13
            oPrintPvt:Line(n_LinAtu-3, n_ColIni, n_LinAtu-3, n_ColFin, nCorCinza)
  
            //Se atingiu o limite, quebra de pagina
            fQuebra()

            n_PrcUn:=n_PrcUn + QRY_AUX->C6_PRCVEN
            n_PrcTo:=n_PrcTo + QRY_AUX->C6_PRCVEN*QRY_AUX->C6_QTDVEN
            n_Total:=n_Total + (((QRY_AUX->C6_QTDVEN*QRY_AUX->C6_PRCVEN)*(QRY_AUX->B1_IPI/100))+(QRY_AUX->C6_QTDVEN*QRY_AUX->C6_PRCVEN))

            n_Lin++

            QRY_AUX->(DbSkip())
        EndDo

        oPrintPvt:SayAlign(n_LinAtu, 100, 'Total '+ c_Sigla, oFontDetN, 200, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:Line(n_LinAtu+14, n_ColIni, n_LinAtu+14, n_ColFin, nCorCinza)

        oPrintPvt:SayAlign(n_LinAtu, n_ColDad12, Transform(n_PrcUn,"@E 9,999,999,999.99"), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu, n_ColDad13, Transform(n_PrcTo,"@E 9,999,999,999.99"), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu, n_ColDad14, Transform(n_Total,"@E 9,999,999,999.99"), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

        n_LinAtu+=30

        oPrintPvt:SayAlign(n_LinAtu   , n_ColDad01,  iif(n_Idioma==3,'Condiciones de entrega: ' + c_Termos ,iif(n_Idioma==2, 'Delivery Condition: ' + c_Termos,'Condição de Entrega: ' + c_Termos))   , oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+10   , n_ColDad01,  iif(n_Idioma==3,'Condiciones de pago: '+ c_CondPag,iif(n_Idioma==2, 'Payment Condition: ' + c_CondPag,'Condição de Pagamento: ' + c_CondPag))   , oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
        oPrintPvt:SayAlign(n_LinAtu+20, n_ColDad01, iif(n_Idioma==3,'Detalles bancarios:',iif(n_Idioma==2, 'Bank Details:','Dados Bancários:')) , oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

        n_LinAtu+=25

        if ExisteSX2("Z05")
            DbSelectArea('Z05')
            Z05->(DBSetOrder(2))
            if Z05->(DbSeek(xFILIAL('Z05')+c_Cliente+c_Loja)) 
                n_LinBK:= 0

                While Z05->(!EoF()) .AND. Z05->Z05_CLIENT == c_Cliente .AND. Z05->Z05_LOJA  == c_Loja .and. Z05->Z05_STATUS == '1'
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Correspondent Bank: ' + Z05->Z05_CORBAN, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Swift (BIC CODE): '   + Z05->Z05_CODBIC, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Clearing Code: '      + Z05->Z05_CODCOM, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Account Number: '     + Z05->Z05_CONTA, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'IBAN: '               + Z05->Z05_IBAN, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Beneficiary Bank: '   + Z05->Z05_BBENEF, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Swift (BIC CODE): '   + Z05->Z05_SWBENE, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Beneficiary Name: '   + Z05->Z05_NOMBE, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02,  'Account number: '     + Z05->Z05_CONTBC, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02, 'Federal ID: '         + Z05->Z05_DOCUME, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
                    n_LinAtu+=10
                    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02, 'Branch: '             + Z05->Z05_AGENCI, oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

                    Z05->(DbSkip())
                    n_LinAtu+=15
                
                EndDo

                Z05->(DbCloseArea())
            endif
        end

        n_LinAtu+=10

        oPrintPvt:SayAlign(n_LinAtu+n_LinBK , n_ColDad02, 'Embalaje: ', oFontDet, 500, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

            c_QRYCon:= "select * from "+ RETSQLNAME("AC9")+" AC9 INNER JOIN  "+ RETSQLNAME("ACB")+" ACB  " + CRLF
            c_QRYCon+= "ON AC9_ENTIDA='SC5' AND AC9_CODOBJ=ACB_CODOBJ AND ACB.D_E_L_E_T_='' " + CRLF
            c_QRYCon+= "where AC9_CODENT='"+ AllTrim(c_NumPed)+"' AND AC9.D_E_L_E_T_='' " + CRLF

            PLSQuery(c_QRYCon, 'c_QRYCon')

            n_LinBK:= 0

            n_ContImg:=1

            while c_QRYCon->(!EoF())
                n_LinBK+=55
                cImage:= "\dirdoc\co"+AllTrim(FWCodEmp())+"\shared\" + AllTrim(c_QRYCon->ACB_OBJETO)
                oPrintPvt:SayBitmap(n_LinAtu,n_ColDad02 + n_LinBK, cImage , 50,50) // imagem do banco do conhecimento

                c_QRYCon->(DbSkip())

                if n_ContImg % 6 == 0 
                    n_LinAtu+= 50
                    n_LinBK:= 0
                end

                n_ContImg+=1

            end    

        fImpRod()
          
        oPrintPvt:Preview()
    Else
        MsgStop('Não foi encontrado informações com os parâmetros informados!', 'Atenção')
    EndIf
    QRY_AUX->(DbCloseArea())
      
    RestArea(aArea)
Return
 
/*/{Protheus.doc} fImpCab
Função serve para fazer impressão do cabeçalho do relatório
@type function
@version  1.0
@author ANDERSON REZENDE
@since 17/11/2025
@return variant, return_description
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

    aDados:= {}

    /*01*/ aAdd(aDados,{'Fatura Nº:' , 'Factura Nº:' , 'Invoice Nº:' })
    /*02*/ aAdd(aDados,{'Data:' , ' Fecha Factura:' , 'Date:' })
    /*03*/ aAdd(aDados,{'Pedido de Venda:' , 'Pedido Venta:' , 'Sales Order:' })
    /*04*/ aAdd(aDados,{'Ordem de compra:' , 'Orden de compra:' , 'Purchse Order:' })
    /*05*/ aAdd(aDados,{'Código Cliente:' , 'Código Cliente:' , 'Customer Code:' })
    /*06*/ aAdd(aDados,{'FATURA / LISTA DE EMBALAGEM:' , 'FACTURA / PACKING LIST' , 'INVOICE / PACKING LIST:' })
    /*07*/ aAdd(aDados,{'R$ ', 'U$ ', '€ '})

    /*08*/ aAdd(aDados,{'Endereço da Empresa ', 'Company Address','Dirección de la empresa '})
    /*09*/ aAdd(aDados,{'Endereço de Entrega ', 'Delivery Address ','Dirección de entrega '})

    // imprime informações do cabeçalho
 
    // Endereço empresa
    oPrintPvt:SayAlign(n_LinAtu+55, n_ColIni,iif(n_Idioma==3,aDados[ 6,3],iif(n_Idioma==2,aDados[ 6,2],aDados[ 6,1])), oFontTit, 600, 60, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+75, n_ColIni+40, iif(n_Idioma==3,aDados[ 8,3],iif(n_Idioma==2,aDados[ 8,2],aDados[ 8,1])), oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+83, n_ColIni+40, SM0->M0_NOME   , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+91, n_ColIni+40, SM0->M0_ENDENT , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+99, n_ColIni+40, SM0->M0_COMPENT , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+108, n_ColIni+40, SM0->M0_BAIRENT , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+116, n_ColIni+40, SM0->M0_CIDENT +' - '+SM0->M0_ESTENT , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

// Endereço entrega
    oPrintPvt:SayAlign(n_LinAtu+75, n_ColIni+340, iif(n_Idioma==3,aDados[ 9,3],iif(n_Idioma==2,aDados[ 9,2],aDados[ 9,1])), oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+83, n_ColIni+340, QRY_AUX->A1_NOME   , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+91, n_ColIni+340, QRY_AUX->A1_END , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+99, n_ColIni+340, QRY_AUX->A1_BAIRRO , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+108, n_ColIni+340, QRY_AUX->A1_MUN , oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+116, n_ColIni+340, QRY_AUX->A1_EST +' - '+QRY_AUX->A1_CEP, oFontDetN, 300, 50, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    n_LinAtu+=20

    oPrintPvt:SayAlign(n_LinAtu+05, n_ColIni+200, iif(n_Idioma==3,aDados[ 1,3],iif(n_Idioma==2,aDados[ 1,2],aDados[ 1,1])), oFontDetN, 60, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+200, QRY_AUX->C5_NUM, oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+05, n_ColIni+300, iif(n_Idioma==3,aDados[ 2,3],iif(n_Idioma==2,aDados[ 2,2],aDados[ 2,1])), oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+300, dtoc(QRY_AUX->C5_EMISSAO), oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+05, n_ColIni+400, iif(n_Idioma==3,aDados[ 3,3],iif(n_Idioma==2,aDados[ 3,2],aDados[ 3,1])), oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+400, QRY_AUX->F2_DOC , oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+05, n_ColIni+500, iif(n_Idioma==3,aDados[ 4,3],iif(n_Idioma==2,aDados[ 4,2],aDados[ 4,1])), oFontDetN, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu+15, n_ColIni+500, QRY_AUX->C5_CLIENTE+ '-' +QRY_AUX->C5_LOJACLI, oFontDet, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    n_LinAtu += 120
    oPrintPvt:Line(n_LinAtu-3, n_ColIni, n_LinAtu-3, n_ColFin, nCorCinza)
    n_LinAtu += 5

    c_Sigla:= iif(n_CabMod==4,AllTrim(aDados[ 7,3]),iif(n_CabMod==2,AllTrim(aDados[ 7,2]),AllTrim(aDados[ 7,1]))) 
    aDados:= {}


    /*01*/ aAdd(aDados,{'Item' , ' Item' , 'Item' })
    /*02*/ aAdd(aDados,{'Código' , ' Codigo' , 'Code' })
    /*03*/ aAdd(aDados,{'Descrição' , 'Descripción' , 'Description' })
    /*04*/ aAdd(aDados,{'Peso (KG)' , 'Peso (KG)' , 'Net Weigth (KG)' })
    /*05*/ aAdd(aDados,{'Qtd.' , ' Cant.' , 'Qty.' })
    /*06*/ aAdd(aDados,{'NCM' , ' NCM NALADISH' , 'NCM-HS Code' })
    /*07*/ aAdd(aDados,{'Un.' , 'Un.' , 'Un.' })
    /*08*/ aAdd(aDados,{'Preço Unitário '+c_Sigla , 'Precio Unitário '+c_Sigla , 'Unit Price '+c_Sigla})
    /*09*/ aAdd(aDados,{'Preço Total '+c_Sigla, 'Precio Total '+c_Sigla, 'Total Price '+c_Sigla})
    /*10*/ aAdd(aDados,{'IPI %' , ' IVA %' , 'IVA %'})
    /*11*/ aAdd(aDados,{'Total com IPI '+c_Sigla , 'Total con IVA '+c_Sigla , 'Amonunt Price IVA '+c_Sigla})

    cCodUsr := RetCodUsr()
    cNomUsr := UsrRetName(cCodUsr)
    cNomeEmpresa := FwFilialName()

    oPrintPvt:SayAlign(n_LinAtu, n_ColDad01, iif(n_Idioma==3,aDados[ 1,3],iif(n_Idioma==2,aDados[ 1,2],aDados[ 1,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad02, iif(n_Idioma==3,aDados[ 2,3],iif(n_Idioma==2,aDados[ 2,2],aDados[ 2,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad03, iif(n_Idioma==3,aDados[ 3,3],iif(n_Idioma==2,aDados[ 3,2],aDados[ 3,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad04, iif(n_Idioma==3,aDados[ 4,3],iif(n_Idioma==2,aDados[ 4,2],aDados[ 4,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad05, iif(n_Idioma==3,aDados[ 5,3],iif(n_Idioma==2,aDados[ 5,2],aDados[ 5,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad06, iif(n_Idioma==3,aDados[ 6,3],iif(n_Idioma==2,aDados[ 6,2],aDados[ 6,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad07, iif(n_Idioma==3,aDados[ 7,3],iif(n_Idioma==2,aDados[ 7,2],aDados[ 7,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad08, iif(n_Idioma==3,aDados[ 8,3],iif(n_Idioma==2,aDados[ 8,2],aDados[ 8,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad09, iif(n_Idioma==3,aDados[ 9,3],iif(n_Idioma==2,aDados[ 9,2],aDados[ 9,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad10, iif(n_Idioma==3,aDados[10,3],iif(n_Idioma==2,aDados[10,2],aDados[10,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinAtu, n_ColDad11, iif(n_Idioma==3,aDados[11,3],iif(n_Idioma==2,aDados[11,2],aDados[11,1])) , oFontMin, 50, 10, /*nClrText*/, PAD_LEFT, /*nAlignVert*/)

    n_LinAtu += 15
Return
 
/*/{Protheus.doc} fImpRod
Função de impressão do rodapé do relatório
@type function
@version  1.0
@author ANDERSON REZENDE
@since 17/11/2025
@return variant, return_description
/*/

Static Function fImpRod()
    Local n_LinRod:= n_LinFin
    Local cTexto := ''

    //Linha Separatoria
    oPrintPvt:Line(n_LinRod,   n_ColIni, n_LinRod,   n_ColFin)
    n_LinRod += 3


    oPrintPvt:SayAlign(n_LinRod, n_ColIni+50,'CAVANNA Máquinas e Sistemas para Embalagens Ltda', oFontRodEmp,800,100,/*nClrText*/, PAD_CENTER, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinRod+6, n_ColIni+50,'Rua Alberto Belesso, 640 - Parque Industrial II – Jundiaí - 13213-170 - SP – BRASIL – Phone: (5511) 4431-8700', oFontRodEmp,800,100,/*nClrText*/, PAD_CENTER, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinRod+12, n_ColIni+50,'E-mail: vendas@cavannagroup.com / www.cavanna.com', oFontRodEmp,800,100,/*nClrText*/, PAD_CENTER, /*nAlignVert*/)
    oPrintPvt:SayAlign(n_LinRod+18, n_ColIni+50,'CNPJ: 06.088.544/0001-33', oFontRodEmp,800,100,/*nClrText*/, PAD_CENTER, /*nAlignVert*/)


    //Dados da Esquerda
    cTexto := dToC(dDataBase) + '     ' + c_HoraEx + '     ' + 'U_PEFAT4'+ ' (Invoice)     ' + UsrRetName(RetCodUsr())
    oPrintPvt:SayAlign(n_LinRod, n_ColIni, cTexto, oFontRod, 500, 10, , PAD_LEFT, )
      
    //Direita
    cTexto := 'Pagina '+cValToChar(n_PagAtu)
    oPrintPvt:SayAlign(n_LinRod, n_ColFin-40, cTexto, oFontRod, 040, 10, , PAD_RIGHT, )
      
    //Finalizando a pagina e somando mais um
    oPrintPvt:EndPage()
    n_PagAtu++
Return
 
/*/{Protheus.doc} fQuebra
Função de server para fazer a quebra de página
@type function
@version  1.0
@author ANDERSON REZENDE
@since 17/11/2025
@return variant, return_description
/*/
Static Function fQuebra()
    If n_LinAtu >= n_LinFin-10
        fImpRod()
        fImpCab()
    EndIf
Return

