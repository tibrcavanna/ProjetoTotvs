#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function CRIASXE
    Ajusta lacunas na numeração automatica do LSV - Especifico Cavanna
    Sequencia de 12 digitos para preenchimento do D1_SEQLN.
    Este PE pode ser utilizado para manter outras tabelas e sua numeração sequencial em ordem
    @type User Function
    @author Celso Rondinelli
    @since 04/12/2020
    @version 1
    @return cNum
/*/

User Function CRIASXE()
Local cNum := NIL
Local cAlias    := paramixb[1]  //Retorna o alias da inclusão no momento antes de criar a nova numeração
Local cCpoSx8   := paramixb[2]  //Campo de controle da numeração
Local cAliasSx8 := paramixb[3]  //Alias  "\DATA\<cAlias>"
Local nOrdSX8   := paramixb[4]  //Valor do indice de controle

If cAlias $ "SD1" .And. !(Empty(cAlias) .And. Empty(cCpoSx8) .And. Empty(cAliasSx8))    // Trata a numeração de cliente
    qout(cAlias + "-" + cCpoSx8 + "-" + cAliasSx8 + "-" + str(nOrdSX8))	
    cSql := "SELECT MAX("+cCpoSx8+") AS CODIGO FROM "+RetSqlName("SD1")+" WHERE D1_FILIAL = '"+xFilial("SD1")+"' AND D_E_L_E_T_ = ''"
    dbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),'TSD1',.T.,.T.)
    If !Empty(TSD1->CODIGO)
        cNum = Soma1(TSD1->CODIGO)
    Else
        cNum = '000000000001' 
    EndIf    
EndIf    
Return cNum
