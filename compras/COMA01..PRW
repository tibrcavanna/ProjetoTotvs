#Include 'rwmake.ch'
#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"

User Function COMA01(cFornec,cLoja,cProduto,cProdFor,cNcm)

    Local aArea     := GetArea()
    Local aAreaSA5  := SA5->(GetArea())
    Local aAreaSA2  := SA2->(GetArea())
    Local aAreaSB1  := SB1->(GetArea())
    Local cNomeFor  := ""
    Local cNomeProd := ""
    
    Default cFornec   := ""
    Default cLoja     := ""
    Default cProduto  := ""
    Default cProdFor  := ""
    Default cNcm      := ""
    
    PRIVATE lMsErroAuto := .F.
    
    //------------------------//| Abertura do ambiente |//------------------------
    
    // PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST" TABLES "SA5"ConOut(Repl("-",80))
    
    ConOut(PadC("Amarracao Produto x Fornecedor",80))
    ConOut("Inicio: "+Time())
    
    DbSelectArea("SB1")
    SB1->(dbSetOrder(1))

    DbSelectArea("SA5")
    SA5->(dbSetOrder(1))

    DbSelectArea("SA2")
    SA2->(dbSetOrder(1))

    If ! Empty(cFornec) .AND. !Empty(cProdFor)

        If SB1->(dbSeek(xfilial('SB1') + cProduto ))

            cNomeProd := Alltrim(SB1->B1_DESC)
            If SA2->(dbSeek(xfilial('SA2') + cFornec + cLoja ))
                cNomeFor  := ALltrim(SA2->A2_NOME)
            EndIf
            If ! SA5->(dbSeek(xfilial('SA5')+cFornec+cLoja+cProduto ))

                Begin Transaction       
                
                    oModel := FWLoadModel('MATA061')

                    oModel:SetOperation(3) // Inclui
                    oModel:Activate()

                    //Cabeçalho
                    oModel:SetValue('MdFieldSA5','A5_PRODUTO',cProduto)
                    oModel:SetValue('MdFieldSA5','A5_NOMPROD',cNomeProd)

                    //Grid
                    oModel:SetValue('MdGridSA5','A5_FORNECE',cFornec )
                    oModel:SetValue('MdGridSA5','A5_LOJA'   ,cLoja   )
                    oModel:SetValue('MdGridSA5','A5_NOMEFOR',cNomeFor)
                    oModel:SetValue('MdGridSA5','A5_CODPRF' ,cProdFor)
                    oModel:SetValue('MdGridSA5','A5_NCMPRF' ,cNcm)

                    If oModel:VldData()
                        oModel:CommitData()
                    Endif

                    oModel:DeActivate()

                    oModel:Destroy()   
                    
                    If !lMsErroAuto            
                        ConOut("Incluido com sucesso! "+cFornec)                
                    Else 
                        Mostraerro()            
                        ConOut("Erro na inclusao!")        
                    EndIf                        
                
                End Transaction
            Else
                /*
                Begin Transaction       
                
                    oModel := FWLoadModel('MATA061')

                    oModel:SetOperation(4) // Altero
                    oModel:Activate()

                    //Cabeçalho
                    //oModel:SetValue('MdFieldSA5','A5_PRODUTO',cProduto)
                    //oModel:SetValue('MdFieldSA5','A5_NOMPROD',cNomeProd)

                    //Grid
                    //oModel:SetValue('MdGridSA5','A5_FORNECE',cFornec )
                    //oModel:SetValue('MdGridSA5','A5_LOJA'   ,cLoja   )
                    //oModel:SetValue('MdGridSA5','A5_NOMEFOR',cNomeFor)
                    oModel:SetValue('MdGridSA5','A5_CODPRF' ,cProdFor)
                    oModel:SetValue('MdGridSA5','A5_NCMPRF' ,cNcm    )

                    If oModel:VldData()
                        oModel:CommitData()
                    Endif

                    oModel:DeActivate()

                    oModel:Destroy()   
                    
                    If !lMsErroAuto            
                        ConOut("Alterado com sucesso! "+cFornec)                
                    Else 
                        Mostraerro()            
                        ConOut("Erro na alteração!")        
                    EndIf                        
                
                End Transaction     
                */
                Reclock("SA5",.F.)
                    SA5->A5_CODPRF := cProdFor
                    SA5->A5_NCMPRF := cNcm
                SA5 ->(MsUnlock())
                 
                 ConOut("Produto encontrado e foi atualizado: " + cProduto )
            
            EndIf
        Else
            ConOut("Produto não encontrado: " + cProduto )
        EndIf
    Else
        ConOut("Falha no Fornecedor: " + cFornec )
    EndIf
    
    ConOut("Fim  : "+Time())
    
    RestArea(aAreaSA2)
    RestArea(aAreaSB1)
    RestArea(aAreaSA5)
    RestArea(aArea)

Return Nil
