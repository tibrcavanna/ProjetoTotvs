#include 'protheus.ch'
#include "topconn.ch"

/*/{Protheus.doc} User Function CAVE5HIS
Cart description)
    @type  Function
    @author Rodrigo
    @since 21/04/2020
    @version 1.0
    @param carteira: R=Receber / P=Pagar
    @return Texto com hist�rico da Baixa utilizado no campo E5_HISTOR.
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CAVE5HIS()

Local _aArea   := GetArea()
Local _cRotina := FUNNAME()
Local _cCliFor := ""
Local _cText   := ""

IF _cRotina $ "FINA740/FINA070" // Baixa Manual CR e Funcao CR
    _cCliFor := POSICIONE("SA1",1,xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA),"A1_NREDUZ") 
    _cText   := "REC NF:" + ALLTRIM(SE1->E1_NUM) + " " + ALLTRIM(_cCliFor)
elseif _cRotina $ "FINA750/FINA080"   // Baixa Manual CP e Funcao CP
    _cCliFor := POSICIONE("SA2",1,xFilial("SA2") + SE2->(E2_FORNECE+E2_LOJA),"A2_NREDUZ") 
    _cText := "PGTO NF:" + ALLTRIM(SE2->E2_NUM) + " " + ALLTRIM(_cCliFor)      
//elseif _cRotina $ "FINA090"  // Baixa Automatica CP
//    _cCliFor := POSICIONE("SA2",1,xFilial("SA2") + SE5->(E5_CLIFOR+E5_LOJA),"A2_NREDUZ")    
//    _cText := "PGTO NF:" + ALLTRIM(SE5->E5_NUMERO) + " " + ALLTRIM(_cCliFor)

ENDIF    

RestArea(_aArea)

Return _cText