#Include 'Totvs.ch'

/*/{Protheus.doc} FSCTBX01
Função de fórmula de rateio off-line por funcionários ativos de CC
@type function
@version  12.2410
@author Gabriel Souza
@since 10/02/2026
@return numerical , valor de porcentagem entre quant. funcionários CC por quant. total funcionários CC superior
/*/
User function FSCTBX01()
    Local c_Qry     := ''
    Local n_TotCC   := 0
    Local n_TotGer  := 0
    Local n_Perc    := if(empty(CTQ->CTQ_PERCEN), 0, CTQ->CTQ_PERCEN)
    Local c_CC      := if(empty(CTQ->CTQ_CCCPAR), '', CTQ->CTQ_CCCPAR)
    Local c_DtRef   := ''
    Local oExec as object

    if type("MV_PAR03") <> 'D'
        return n_Perc
    endif

    if empty(c_CC)
        fwAlertWarning('Não foi possível calcular o rateio, pois o CC de partida não foi encontrado!','Cálculo de rateio por funcionário')
        return n_Perc
    endif

    c_DtRef := DTOS(MV_PAR03)

    // BUSCA FUNCIONÁRIOS DE CC PARTIDA
    c_Qry := " SELECT COUNT(*) CNT FROM ? SRA "
    c_Qry += " WHERE SRA.D_E_L_E_T_ = ' ' AND SRA.RA_CC = ? AND SRA.RA_SITFOLH IN ('', 'F')"
    c_Qry += " AND SRA.RA_ADMISSA <= ? AND (SRA.RA_DEMISSA > ? OR SRA.RA_DEMISSA = ' ') "

    oExec := FwExecStatement():New(c_Qry) 
    oExec:setUnsafe(1,retSqlName('SRA'))
    oExec:SetString(2,c_CC)
    oExec:SetString(3,c_DtRef)
    oExec:SetString(4,c_DtRef)
    
    n_TotCC := oExec:ExecScalar('CNT')

    // BUSCA FUNCIONÁRIOS DE CC SUPERIOR
    c_Qry := " SELECT COUNT(*) CNTGER FROM ? SRA "
    c_Qry += " WHERE SRA.D_E_L_E_T_ = ' '  AND SRA.RA_SITFOLH IN ('', 'F')"
    c_Qry += " AND SRA.RA_ADMISSA <= ? AND (SRA.RA_DEMISSA > ? OR SRA.RA_DEMISSA = ' ') "
    c_Qry += " AND SRA.RA_CC IN ( "
    c_Qry += "      SELECT CTT.CTT_CUSTO FROM ? CTT "
    c_Qry += "      INNER JOIN (SELECT SUP.CTT_CCSUP FROM ? SUP WHERE SUP.D_E_L_E_T_ = '' AND SUP.CTT_CUSTO = ?) AS CCSUP ON CCSUP.CTT_CCSUP = CTT.CTT_CCSUP) "

    oExec := FwExecStatement():New(c_Qry) 
    oExec:setUnsafe(1,retSqlName('SRA')) 
    oExec:SetString(2,c_DtRef)
    oExec:SetString(3,c_DtRef)
    oExec:setUnsafe(4,retSqlName('CTT')) 
    oExec:setUnsafe(5,retSqlName('CTT')) 
    oExec:SetString(6,c_CC)

    n_TotGer := oExec:ExecScalar('CNTGER')

    n_Perc := noRound(n_TotCC/n_TotGer,2) * 100

return n_TotCC
