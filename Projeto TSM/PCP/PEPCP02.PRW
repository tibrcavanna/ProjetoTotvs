#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} P712SQL
  Ponto de Entrada, localizado na execução da rotina "MRP Memória" no momento da seleção dos documentos
  que serão considerados para o processamento do MRP.
Observações : 
- Caso a OP seja marcada como "Não" para o campo MRP(S/N) (C2_XMRP), porém suas SCs/OPs filhas já foram firmadas, 
o MRP não irá excluir/cancelar as SCs/OPs já firmadas
- Deve se criar uma governança/processo para que esse campo seja utilizado de forma sequencial, 
semelhante ao que existe para OP prevista e firme, pois uma vez a OP firmada, não se consegue retornar 
essa OP para prevista
- Em atualização de release ou outra, deve se testar essa rotina para certificar se as tratativas abaixo continuam
funcionando normalmente

  https://tdn.totvs.com/pages/releaseview.action?pageId=654300935

  @type function
  @author Silvio Nogueira Silva
  @since 06/09/2025
/*/
//-------------------------------------------------------------------------------------------------------------

User Function PEPCP02()


    Local lBeginSql2 := .F.
    Local lBeginSql3 := .F.
    Local lBeginSql4 := .F.
    Local lAlterou   := .T.
 
    //Tratamento BeginSQL
    If Right(cFields, 1) == '%'
        cFields    := StrTran(cFields, "%", "")
        lBeginSql2 := .T.
    EndIf
    If Right(cQueryCon, 1) == '%'
        cQueryCon  := StrTran(cQueryCon, "%", "")
        lBeginSql3 := .T.
    EndIf
    If Right(cOrder, 1) == '%'
        cOrder     := StrTran(cOrder, "%", "")
        lBeginSql4 := .T.
    EndIf
 
    Conout("Query de carga da tabela " + cTabela + ":")
    Conout("SELECT " + cFields + " FROM " + cQueryCon + " ORDER BY " + cOrder)
 
    Do Case
        //Só consideraremos OPs com campo SC2.C2_XMRP <> 'N'
        Case cTabela == 'T4Q'

             cQueryCon += " AND EXISTS ( SELECT 1 FROM SC2" + cEmpAnt + "0 SC2 WHERE SC2.C2_FILIAL = T4Q_FILIAL AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN = T4Q.T4Q_OP AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_XMRP <> 'N')"

        //Só consideraremos Empenhos com campo SC2.C2_XMRP <> 'N'
        Case cTabela == 'T4S'

	        cQueryCon += " INNER JOIN SC2" + cEmpAnt + "0 SC2 ON SC2.C2_FILIAL = T4S_FILIAL AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN = T4S_OP AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_XMRP <> 'N'"

        //Só consideraremos SCs com campo SC2.C2_XMRP <> 'N'
        Case cTabela == 'T4T'

	        //cQueryCon += " INNER JOIN SC2" + cEmpAnt + "0 SC2 ON SC2.C2_FILIAL = T4T_FILIAL AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN = T4T_OP AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_XMRP <> 'N'"
            cQueryCon += " AND EXISTS ( SELECT 1 FROM SC2" + cEmpAnt + "0 SC2 WHERE SC2.C2_FILIAL = T4T_FILIAL AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN = T4T_OP AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_XMRP <> 'N')"

        //Só consideraremos PCs com campo SC2.C2_XMRP <> 'N'
        Case cTabela == 'T4U'

	        //cQueryCon += " INNER JOIN SC2" + cEmpAnt + "0 SC2 ON SC2.C2_FILIAL = T4U_FILIAL AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN = T4U_OP AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_XMRP <> 'N'"
             cQueryCon += " AND EXISTS ( SELECT 1 FROM SC2" + cEmpAnt + "0 SC2 WHERE SC2.C2_FILIAL = T4U_FILIAL AND SC2.C2_NUM+C2_ITEM+C2_SEQUEN = T4U_OP AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_XMRP <> 'N')"

/* 
        //Só consideraremos Pedidos de Compras com quantidade maior que 10
        Case cTabela == 'T4U'
            cQueryCon += " AND T4U_QTD > 10 "
 
        //Só consideraremos OPs com quantidade maior que 100
        Case cTabela == 'T4Q'
            cQueryCon += " AND T4Q_SALDO > 100 "
 
        //Trocaremos o armazém da demanda pelo armazém do produto
        Case cTabela == 'T4J'
            cFields := StrTran(cFields, " T4J.T4J_LOCAL", " HWA.HWA_LOCPAD As T4J_LOCAL")
*/ 
        Otherwise
            lAlterou := .F.
    EndCase
 
    //Só precisa retornar o array aRetorno se realmente a query foi alterada
    If lAlterou
        Conout("A carga da tabela " + cTabela + " utilizara a query especifica:")
        Conout("SELECT " + cFields + " FROM " + cQueryCon + " ORDER BY " + cOrder)
 
        //Tratamento BeginSQL
        If lBeginSql2
            cFields := "% " + cFields + "%"
        EndIf
        If lBeginSql3
            cQueryCon := "% " + cQueryCon + "%"
        EndIf
        If lBeginSql4
            cOrder := "% " + cOrder + "%"
        EndIf
 
        aAdd(aRetorno, cFields)
        aAdd(aRetorno, cQueryCon)
        aAdd(aRetorno, cOrder)
    Else
        Conout("A carga da tabela " + cTabela + " utilizara a query padrao do MRP.")
    EndIf

Return
