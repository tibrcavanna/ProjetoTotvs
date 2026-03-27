#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A105BUT
  @description: Monta array com botões nas rotinas de inclusão
  @type function
  @author Silvio Nogueira Silva
  @since 12/09/2025
  @param a_Botao Array com opção a incluir na tela de Solicitação ao Almoxarifado (MATA105).
  @return nil
/*/
//-------------------------------------------------------------------------------------------------------------

User Function A105BUT()

    Local	aOpcao := PARAMIXB[2]

    aAdd( aOpcao, { 'ORDEMPRD', { || U_PEEST01() }, 'Ordem','TSM Carrega OP'} )
 
Return(aOpcao)

/*/{Protheus.doc} MT010INC
Ponto de entrada após cadastro de produto
@type function
@version 1.0
@author Gabriel Souza
@since 04/12/2025
/*/
User Function MT010INC()
    a_Area := GetArea()
    c_Roteiro := SUPERGETMV('FS_CODRTPD',.F.,'01')
    c_Produto := SUPERGETMV('FS_PRDRTPD',.F.,'')

    //verifica se é PA ou PI
    if !(SB1->B1_TIPO $ 'PA.PI')
        Return
    endif

    dbSelectArea('SG2')
    SG2->(dbSetOrder(1))
    if SG2->(dbSeek(xFilial('SG2')+AvKey(c_Produto, "G2_PRODUTO")+c_Roteiro))
        U_PEEST02()
    else
        FWALERTERROR("Não foi possível gerar o roteiro para o produto criado", "Roteiro padrão não encontrado")
    endif
    
    RestArea(a_Area)
Return


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA330OK
  @description: Ponto de Entrada na rotina de recalculo do custo médio de estoque.
  Rotina para agrupar os movimentos da tabela de apontamento Z01 e gera movimento na tabela SC2/SD3
  @type function
  @author Silvio Nogueira Silva
  @since 22/12/2025
  @param 
  @return lRet - parâmetro indicando que a rotina foi processada corretamente e que pode seguir o fluxo normal
  do processamento de recalculo do custo médio
/*/
//-------------------------------------------------------------------------------------------------------------

User Function MA330OK()

    Local	l_Ret := .T.
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.
    Private d_DtFech  := A330PARAMZX[1]

    If MsgYesNo( "Deseja também executar o processamento de Mão de Obra das OPs de Engenharia ?")

        MsgRun("Processando apontamentos de Engenharia - Parte 1","Aguarde..." , {|| l_Ret := U_PEEST03() } )
        If l_Ret

            MsgRun("Processando apontamentos de Engenharia - Parte 2","Aguarde..." , {|| l_Ret := U_PEEST04() } )

        Endif

    Endif
 
Return(l_Ret)


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT650PISC
  @description: Ponto de Entrada para não exibir a pergunta :
  "TOTVS A OP informada nao teve os empenhos e as OPs intermediarias criadas. Deseja mesmo produzi-la?"
  no apontamento de produção das OPs de mão de Obra da Engenhaira.
  Só funciona quando o parâmetro MV_APTEMP estiver como .T.
  @type function
  @author Silvio Nogueira Silva
  @since 22/12/2025
  @param 
  @return lRet - parâmetro retornando .T. or .F.
/*/
//-------------------------------------------------------------------------------------------------------------
User Function MT650PISC()
    Local l_Ret := .T.
    Local c_GrpMO   := SuperGetMv("FS_GRPMO",.F.,"2999")

    SB1->(dbSetOrder(1))
    SB1->(MsSeek(FWxFilial("SB1") + SC2->C2_PRODUTO ))

    If SB1->B1_GRUPO == c_GrpMO

        l_Ret   := .F.

    Endif

Return l_Ret


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SD3VESR
  @description: Ponto de Entrada para não exibir a pergunta :
  "
ATENCAO
O produto digitado nao faz parte da
Estrutura do Produto 34381B1512     
da OP - 00000201001   
Confirma movimentacao ?"
  na requisição do produto CodeallegreMO para a OP de montagem do Code Allegre.
  @type function
  @author Silvio Nogueira Silva
  @since 26/12/2025
  @param 
  @return lRet - parâmetro retornando .T. or .F.
/*/
//-------------------------------------------------------------------------------------------------------------

User Function SD3VESR
    Local l_Ret := .T. 
    Local c_GrpMO   := SuperGetMv("FS_GRPMO",.F.,"2999")
    Local n_Grupo	:= AScan(aHeader,{|x| AllTrim(x[2]) == 'D3_GRUPO'}) // retorna o conteudo do campo D1_XDESCPR
    Local c_Grupo	:= aCols[n][n_Grupo]

    If c_Grupo == c_GrpMO

        l_Ret   := .F. //Nao faz validação da estrutura

    Endif

Return l_Ret
