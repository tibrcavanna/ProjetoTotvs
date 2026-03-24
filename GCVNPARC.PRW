#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} GCVNPARC
Tela de Lançamento de Parcelas Z03
@type function
@version 12.1.2410 
@author Gildeir Pereira - gildeir.pereira@totvs.com.br
@since 18/11/2025
/*/
User Function GCVNPARC()
    Local aArea := GetArea()
    
    // Objetos da Janela
    Private oDlgZ03
    Private oMsGetZ03
    Private aHeadZ03 := {}
    Private aColsZ03 := {}
    Private oBtnSalv
    Private oBtnFech
    
    // Tamanho da Janela
    Private nJanLarg    := 800
    Private nJanAltu    := 500
    
    // Fontes
    Private cFontUti    := "Tahoma"
    Private oFontAno    := TFont():New(cFontUti,,-38)
    Private oFontSub    := TFont():New(cFontUti,,-20)
    Private oFontSubN   := TFont():New(cFontUti,,-20,,.T.)
    Private oFontBtn    := TFont():New(cFontUti,,-14)
    Private cNPedZ03    := M->C5_NUM
    Private cNameUser   := UsrRetName(RetCodUsr())
    Public __XaParcPed  := {}
    Public __XSParPed   := .T.

    // -------------------------------------------------------------------------
    // Criando o cabeçalho da Grid (aHeadZ03)
    // Estrutura: {Título, Campo, Máscara, Tamanho, Decimal, Valid, Usado, Tipo, F3, Combo}
    // -------------------------------------------------------------------------
       
    aAdd(aHeadZ03, {"Parcela",    "Z03_PARC",   "@!",             01, 0, ".T.", ".T.", "C", "", ""})// 1. Parcela (Campo Chave)   
    aAdd(aHeadZ03, {"% Perc.",    "Z03_PERC",   "@E 999.99",      06, 2, ".T.", ".T.", "N", "", ""}) // 2. Percentual      
    aAdd(aHeadZ03, {"Valor",      "Z03_VALOR",  "@E 9,999,999.99",12, 2, ".T.", ".T.", "N", "", ""}) // 3. Valor    
    aAdd(aHeadZ03, {"Vencimento", "Z03_VENCTO", "@D",             08, 0, ".T.", ".T.", "D", "", ""}) // 4. Vencimento    
    aAdd(aHeadZ03, {"Observação", "Z03_OBS",    "@!",             50, 0, ".T.", ".T.", "C", "", ""})  // 5. Observação
    
    // Carrega os dados existentes na Z03
    Processa({|| fCarAcols()}, "Carregando Parcelas...")

    // Criação da tela
    DEFINE MSDIALOG oDlgZ03 TITLE "Parcelas do Pedido" FROM 000, 000 TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
        // Labels gerais
        @ 004, 003 SAY "Lançamento de Parcelas do Pedido: " + cNPedZ03 SIZE 200, 030 FONT oFontSub  OF oDlgZ03 COLORS RGB(031,073,125) PIXEL
        
        // Botões (Centralizados na parte inferior)
        @ nJanAltu/2 - 30, (nJanLarg/2 - 120) BUTTON oBtnFech PROMPT "Fechar"    SIZE 050, 018 OF oDlgZ03 ACTION (fSalvar(.F.) /*oDlgZ03:End()*/) FONT oFontBtn PIXEL
        @ nJanAltu/2 - 30, (nJanLarg/2 - 60) BUTTON oBtnSalv PROMPT "Confirmar" SIZE 050, 018 OF oDlgZ03 ACTION (fSalvar(.T.))   FONT oFontBtn PIXEL
        
        // Grid das Parcelas
        oMsGetZ03 := MsNewGetDados():New(;
            030,;                           // nTop
            003,;                           // nLeft
            (nJanAltu/2)-40,;               // nBottom
            (nJanLarg/2)-3,;                // nRight
            GD_INSERT + GD_UPDATE + GD_DELETE,; // nStyle
            "AllwaysTrue()",;               // cLinhaOk
            ,;                              // cTudoOk
            "+++Z03_PARC",;                   // cIniCpos
            {"Z03_PERC", "Z03_VALOR", "Z03_VENCTO", "Z03_OBS"},; // aAlter (Campos Editáveis)
            0,;                             // nFreeze
            99,;                            // nMax
            ,;                              // cFieldOK
            ,;                              // cSuperDel
            ,;                              // cDelOk
            oDlgZ03,;                       // oWnd
            aHeadZ03,;                      // aHeader
            aColsZ03)                       // aCols
        
    ACTIVATE MSDIALOG oDlgZ03 CENTERED
    
    RestArea(aArea)
Return

/*/{Protheus.doc} fCarAcols
Função que carrega o aCols com dados
@type function
@version 12.1.2410 
@author Gildeir Pereira - gildeir.pereira@totvs.com.br
@since 19/11/2025
/*/
Static Function fCarAcols()
    
    // Limpa o array de dados
    aColsZ03 := {}
    
    DbSelectArea("Z03")
    Z03->(DbSetOrder(1)) 
    
    // Busca os registros do Pedido Atual
    If Z03->(MsSeek(xFilial("SC5")+cNPedZ03))
        
        While !Z03->(EoF()) .And. Z03->Z03_FILIAL == xFilial("SC5") .And. Z03->Z03_NUM == cNPedZ03
            
            // Adiciona o item no aCols na ordem exata do aHeadZ03
            aAdd(aColsZ03, {;
                Z03->Z03_PARC,;     // 1. Parcela
                Z03->Z03_PERC,;     // 2. Perc
                Z03->Z03_VALOR,;    // 3. Valor
                Z03->Z03_VENCTO,;   // 4. Vencto
                Z03->Z03_OBS,;      // 5. Obs
                .F.;                // 7. Flag Delete (Obrigatório na última posição)
            })
            
            Z03->(DbSkip())
        EndDo
        
    EndIf

Return

/*/{Protheus.doc} fCarAcols
Percorre a grid e salva no array __XaParcPed
@type function
@version 12.1.2410 
@author Gildeir Pereira - gildeir.pereira@totvs.com.br
@since 19/11/2025
/*/
Static Function fSalvar(lSalva)
    Local aColsAux := oMsGetZ03:aCols
    Local nLinha   := 0
    Local nValPed  := RTotalPed()
    Local nValParc := 0
    
    // Mapeando as posições baseadas no Header
    Local nPosParc := aScan(aHeadZ03, {|x| Alltrim(x[2]) == "Z03_PARC"})
    Local nPosPerc := aScan(aHeadZ03, {|x| Alltrim(x[2]) == "Z03_PERC"})
    Local nPosVal  := aScan(aHeadZ03, {|x| Alltrim(x[2]) == "Z03_VALOR"})
    Local nPosVenc := aScan(aHeadZ03, {|x| Alltrim(x[2]) == "Z03_VENCTO"})
    Local nPosObs  := aScan(aHeadZ03, {|x| Alltrim(x[2]) == "Z03_OBS"})
    Local nPosDel  := Len(aHeadZ03) + 1 // Coluna de Delete é sempre Header + 1

    // Limpa o array global de integração
    If Type("__XaParcPed") == "A"
        __XaParcPed := {}
    EndIf

    __XSParPed := lSalva //Salva opção "Confirma" ou "Fechar"
    
    // Percorrendo todas as linhas da Grid
    For nLinha := 1 To Len(aColsAux)
    
        // Se a linha NÃO estiver marcada para exclusão
        If !aColsAux[nLinha][nPosDel]
            
            // Validação simples: Deve ter Parcela preenchida ou Valor > 0
            If !Empty(aColsAux[nLinha][nPosParc]) .Or. aColsAux[nLinha][nPosVal] > 0
                
                // Adiciona ao Array Global (__XaParcPed)
                // Estrutura que o M410STTS espera
                aAdd(__XaParcPed, {;
                    xFilial("SC5"),;                 // 1. Filial
                    cNPedZ03,;                       // 2. Pedido
                    aColsAux[nLinha][nPosParc],;     // 3. Parcela
                    aColsAux[nLinha][nPosPerc],;     // 4. Percentual
                    aColsAux[nLinha][nPosVal],;      // 5. Valor
                    aColsAux[nLinha][nPosVenc],;     // 6. Vencimento
                    aColsAux[nLinha][nPosObs],;      // 7. Observação
                    cNameUser;                       // 8. Usuário
                })

                nValParc += aColsAux[nLinha][nPosVal]
                
            EndIf
            
        EndIf
        
    Next

    if nValParc <> nValPed .and. __XSParPed <> .F. //compara valor das parcelas preenchidas com valor total de pedido
        MsgAlert("O Valor das Parcelas não corresponde ao valor do Pedido, realize a alteração das parcelas para prosseguir!";
        + CRLF + CRLF +"Pedido: R$" + Alltrim(Transform(nValPed,PesqPict("SC6","C6_VALOR"))) ;
        + CRLF + "Parcelas: R$" + Alltrim(Transform(nValParc,PesqPict("SC6","C6_VALOR"))))
    else
        oDlgZ03:End() // Fecha a janela após confirmar
    endif
Return


/*/{Protheus.doc} RTotalPed
Retorna valor total do pedido
@type function
@version 12.1.2410
@author Gildeir Pereira - gildeir.pereira@totvs.com.br
@since 19/11/2025
/*/
Static Function RTotalPed()
    Local nValNF := 0
    Local i

	// -------------------------------------------------------------------
	// Realiza os calculos necessários
	// -------------------------------------------------------------------

	MaFisIni(M->C5_CLIENTE,;						// 01- Codigo Cliente/Fornecedor
	M->C5_LOJACLI,;								    // 02- Loja do Cliente/Fornecedor
	"C",;											// 03- C: Cliente / F: Fornecedor
	M->C5_TIPO,;									// 04- Tipo da NF
	M->C5_TIPOCLI,;									// 05- Tipo do Cliente/Fornecedor
	MaFisRelImp("MTR700",{"SC5","SC6"}),;			// 06- Relacao de Impostos que suportados no arquivo
	,;												// 07- Tipo de complemento
	,;												// 08- Permite incluir impostos no rodape (.T./.F.)
	"SB1",;										    // 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
	"MTR700")										// 10- Nome da rotina que esta utilizando a funcao

    For i:=1 To Len(aCols)

        MaFisAdd(;
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_PRODUTO"})],; // 01 - Codigo do Produto                    ( Obrigatorio )
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_TES"})],;     // 02 - Codigo do TES                        ( Opcional )
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_QTDVEN"})],;  // 03 - Quantidade                           ( Obrigatorio )
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_PRCVEN"})],;  // 04 - Preco Unitario                       ( Obrigatorio )
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_VALDESC"})],; // 05 - Desconto
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_NFORI"})],;   // 06 - Numero da NF Original                ( Devolucao/Benef )
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_SERIORI"})],; // 07 - Serie da NF Original                 ( Devolucao/Benef )
        0,;                                                             // 08 - RecNo da NF Original no arq SD1/SD2
        0,;                                                             // 09 - Valor do Frete do Item               ( Opcional )
        0,;                                                             // 10 - Valor da Despesa do item             ( Opcional )
        0,;                                                             // 11 - Valor do Seguro do item              ( Opcional )
        0,;                                                             // 12 - Valor do Frete Autonomo              ( Opcional )
        aCols[i][aScan(aHeader, {|x| Alltrim(x[2]) == "C6_VALOR"})],;   // 13 - Valor da Mercadoria                  ( Obrigatorio )
        0,;                                                             // 14 - Valor da Embalagem                   ( Opcional )
        SB1->(RecNo()),;                                                // 15 - RecNo do SB1
        0;                                                              // 16 - RecNo do SF4
        )
    Next

	nValNF += MaFisRet(,"NF_TOTAL")	//Aliquota do ICMS
    nValNF += MaFisRet(,'NF_FRETE')
    nValNF += MaFisRet(,'NF_SEGURO')
    nValNF += MaFisRet(,'NF_DESPESA')
    
	MaFisEnd()

return nValNF
