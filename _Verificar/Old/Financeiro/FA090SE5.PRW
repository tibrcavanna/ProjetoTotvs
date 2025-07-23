#include 'protheus.ch'
#include 'parmtype.ch'

User function FA090SE5()

Local cNumero  := SE2->E2_NUM
Local cPrefixo := SE2->E2_PREFIXO
Local cParcela := SE2->E2_PARCELA
Local cFornece := SE2->E2_FORNECE
Local cLoja    := SE2->E2_LOJA
Local cNRed    := SE2->E2_NOMFOR
Local _CMOTBX  := CMOTBX //Motivo de Baixa
Local _cRotina := FUNNAME()

Local cHistor := ""

IF _cRotina $ "FINA090"
    cHistor := "PGTO NF:" + ALLTRIM(cNumero) +" "+ ALLTRIM(cNRed)
END

Return(cHistor)