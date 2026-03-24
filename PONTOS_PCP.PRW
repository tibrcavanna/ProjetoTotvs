#include "PROTHEUS.CH"
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

/*
User Function P712SQL()

    Private aRetorno   := {}
    Private cTabela    := Trim(PARAMIXB[1])
    Private cFields    := Trim(PARAMIXB[2])
    Private cQueryCon  := Trim(PARAMIXB[3])
    Private cOrder     := Trim(PARAMIXB[4])

    U_PEPCP02() // Chamada da rotina para tratar filtro no processamento do MRP
 
Return aRetorno
*/


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} P200GRAV
  Ponto de Entrada chamado Após a gravação da EP, porém antes do final da transação de inclusão/alteração/exclusão da estrutura.
  implementado aqui para chamar função que compara revisao atual com anterior, identificar mudandas e notifica usuario.

  https://tdn.totvs.com/pages/releaseview.action?pageId=663066668

  @type function
  @author Silvio Mota
  @since 01/08/2025
/*/
//-------------------------------------------------------------------------------------------------------------
User Function P200GRAV()
	Local a_Area     := FWGetArea()
	Local aRecnos    := PARAMIXB[2]

	// Verificar se houve alterações da EP para notivicar engenharia.
	If len(aRecnos) >= 1
		U_PEPCP01( aRecnos )
		U_PEPCP03( aRecnos )
	EndIf

	FwRestArea(a_Area)
Return Nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT381VLD
  Ponto de Entrada, localizado na validação de Ajuste Empenho Mod. 2 (MATA381), utilizado para confirmar a gravação do Ajuste Empenho Modelo 2.
  Chamado pela função A381TudoOk(Validações gerais do Empenho Mod.2), no início das validações, após a confirmação da tela.
  Aqui é usado para troca o empenho de um codigo fantasma pelo empenho de seus componentes.

  https://tdn.totvs.com/pages/releaseview.action?pageId=6087881

  @type function
  @author Silvio Mota
  @since 13/08/2025
/*/
//-------------------------------------------------------------------------------------------------------------

User Function MT381VLD()
    Local l_Ret := .T.
    Private l_Inclui := PARAMIXB[1]
    Private l_Altera := PARAMIXB[2]

    l_Ret := U_PEPCP04()

Return( l_Ret )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A250ENOK
  Ponto de Entrada, localizado no final da função A250TudoOk() na rotina de Apontamento de Produção (Produção Simples).
  Será utilizado nos casos de apontamento de produção de CodeAllegre para verificar se existem apontamentos de mão de obra
  de Engenharia referentes ao CodeAllegre e efetuar a requisição dessa mão de obra para a OP de montagem do Code Allegre.
  Chamado pela função A381TudoOk(Validações gerais do Empenho Mod.2), no início das validações, após a confirmação da tela.
  Aqui é usado para troca o empenho de um codigo fantasma pelo empenho de seus componentes.
  @type function
  @author Silvio Nogueira
  @since 27/01/2026
/*/
//-------------------------------------------------------------------------------------------------------------

//User Function MT250TOK()
//User Function A250ENOK()
User Function MT680AIN()
    Local c_Grupo
    Local l_Ret   := .T.
    Local c_GrpCA := SuperGetMv("FS_GRPCA",.F.,"2998") // Grupo de Materiais reservados para os produtos denominados "Code Allegre"
	  Private lMsErroAuto := .F.
	  Private lMsHelpAuto := .F.
    Private d_DtFech  := M->D3_EMISSAO

    c_Grupo := Posicione("SB1", 1, xFilial("SB1") + M->D3_COD, "B1_GRUPO" )

    If c_Grupo == c_GrpCA

      MsgRun("Processando apontamentos de Engenharia - Parte 1","Aguarde..." , {|| l_Ret := U_PEEST03(M->D3_OP) } )
      
      If l_Ret

          MsgRun("Processando apontamentos de Engenharia - Parte 2","Aguarde..." , {|| l_Ret := U_PEEST04(M->D3_OP) } )

      Endif

    Endif

Return


/*/{Protheus.doc} pa145ger
description 
O ponto de entrada PA145GER é executado ao finalizar a geração de todos os documentos do MRP (PCPA712, PCPA144 ou Resultados MRP).
Localização:	
Classe ProcessaDocumentos, método processar() - Responsável por realizar a geração dos documentos
Eventos:	
Ao finalizar a geração dos documentos é aberta uma nova thread exclusiva para a execução do ponto de entrada.
Programa Fonte:	PCPA145.PRW
Sintaxe:
PA145GER( [ cTicket ] ) --> Nil
Observações:	
Não é permitida a utilização de qualquer componente de interface gráfica nesse ponto de entrada, visto que a função será executada em background.
A rotina principal não aguardará o término da execução do ponto de entrada.

Ponto de Entrada será utilizado para gravar o Item Contábil / Projeto nas OPs e SCs geradas pelo MRP

@type function
@version  1.0
@author Silvio Nogueira - TOTVSTSM
@since 20/01/2026
@return nil, return_description
/*/
User Function pa145ger()

  U_PEPCP06()

  U_PEPCP05()

Return()
