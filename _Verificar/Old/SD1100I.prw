#Include "Rwmake.Ch"                    

// Objetivo :  Este Ponto de entrada é executado durante a inclusão do Documento de Entrada, após a inclusão do item na tabela SD1. 
//             O registro no SD1 já se encontra travado (Lock). Será executado uma vez para cada item do Documento de Entrada 
//             que está sendo incluída.
//             
//             Ponto de entrada utilizado para replicar os dados da tabela SD1 na tabela SZ3 de mesma estrutura atraves da chamada ao programa
//             U_CAEST002()
//			   	

User Function SD1100I() //PONTO DE ENTRADA NA INCLUSAO DA NFE POR ITEM

  Local aAreaSD1	:=	SD1->(GetArea())
  Local aAreaSB1	:=	SB1->(GetArea())
  Local aAreaSA5	:=	SA5->(GetArea())
  Local aAreaSA2	:=	SA2->(GetArea())
  Local aAreaATU	:=	GetArea()

  If SD1->D1_TIPO <> "D"
    
    dbSelectArea("SB1")
    SB1->(dbSetOrder(1))
    If SB1->(dbseek(xfilial("SB1")+SD1->D1_COD))
      Reclock("SB1",.F.)
        
        //SB1->B1_PROC    := SD1->D1_FORNECE   
        //SB1->B1_LOJPROC := SD1->D1_LOJA   
        
        //If EMPTY(SB1->B1_ORIGEM)
            SB1->B1_ORIGEM  := left(SD1->D1_CLASFIS,1)
        //ElseIf left(SD1->D1_CLASFIS,1) $ "1/2"
        //    SB1->B1_ORIGEM  := "2"
        //Endif
        If Empty(SB1->B1_POSIPI)
          SB1->B1_POSIPI := SD1->D1_POSIPI
        EndIf
        //If !LEFT(SD1->D1_COD,1) $ "9/7"
        //  SB1->B1_IPI := SD1->D1_IPI
        //Endif
        
        //If SD1->D1_PICM <> 18 .AND. SF1->F1_EST = "SP"
        //  SB1->B1_PICM := SD1->D1_PICM     
        //Endif
        
      MsUnlock()
    
    EndIf 
    
    DbSelectArea("SA5")
    SA5->(dbSetOrder(1))
    If SA5->(dbSeek(xFilial("SA5")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD))
      //If Empty(SA5->A5_XTESPAD)
        Reclock("SA5",.F.)
        
          SA5->A5_XTESPAD := SD1->D1_TES

        MsUnlock() 
      //EndIf   
    EndIf

    DbSelectArea("SA2")
    SA2->(dbSetOrder(1))
    If SA2->(dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
      If Empty(SA2->A2_COND)
        Reclock("SA2",.F.)
        
          SA2->A2_COND    := SF1->F1_COND

        MsUnlock() 
      EndIf 
    EndIf  

  EndIf

  U_CAEST002()  //PROGRAMA UTILIZADO PARA REPLICAR SD1 EM SZ3 - INTEGRAÇÃO COM SISTEMA LN

  RestArea(aAreaSA2)
  RestArea(aAreaSA5)
  RestArea(aAreaSD1)
  RestArea(aAreaSB1)
  RestArea(aAreaATU)

Return
