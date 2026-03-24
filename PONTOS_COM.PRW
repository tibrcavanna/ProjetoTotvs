#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

/*/{Protheus.doc}
(TELA DE PEDIDO DE COMPRA, OPÇÃO SCs)
@type  function
@author Silvio Nogueira
@since 01/10/2025
@version 01
@description Ponto de Entrada na tela de Inclusão de PC
@           que abre uma tela markbrowse para seleção de SCs
/*/

User Function MT120BRW()

    aadd(aRotina,{'TSM SCs',{|| U_PECOM01()},0,4}) 
    //aAdd(aRotina,{"* XX","U_XXX()",0,4} )
    
Return


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} COLSTTS
  Ponto de entrada, apos execauto de gravação do SF1, na rotina de Importação do XML.
  TDN :  https://tdn.totvs.com/pages/releaseview.action?pageId=233760407

  Neste fonte, o PE é utilizado para preencher o campos customizado D1_XNCMF (NCM na NF fiscal), usado posteriormente 
  para comparar com o NCM do cadastro de produto e notificar o usaurio em caso de divergencias. 
 
  @type function
  @author Silvio Mota
  @since 11/08/2025
  @history	28/09/2025, Silvio Mota, Inclusão do tatrativa do campo Lote. Parte do principio que o Lote do XML não é confiavel.
  @param 
  @return Nil, undefined, Esta funcao nao tem retorno
/*/
//-------------------------------------------------------------------------------------------------------------

User Function COLSTTS()

	PRIVATE _aProdutos := {}

    U_PECOM02()
    
Return( Nil )


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT100GRV
  Ponto de entrada localizado na função a103Grava responsável pela gravação da Nota Fiscal. 
  Executado antes de iniciar o processo de gravação / exclusão de Nota de Entrada.

  TDN :  https://tdn.totvs.com/pages/releaseview.action?pageId=6085394
  
  Neste fonte, o PE é utilizado para comparar o campo customizado D1_XNCMF (NCM na NF fiscal), com o NCM do cadastro de produto 
  e notificar o usuraio em caso de divergencias.
 
  @type function
  @author Silvio Mota
  @since 11/08/2025
  @param 
  @return Nil, undefined, Esta funcao nao tem retorno
  @modified Silvio Nogueira Silva, 10/10/2025, Criação de tabela Z06 (Complemento SD1) - 
  @modified SD1 atingiu limite máximo de campos
  */
//-------------------------------------------------------------------------------------------------------------
User Function MT100GRV()
	Local l_Ret := .T.

  U_PECOM03()

Return( l_Ret )


/*/{Protheus.doc} MT100CLA
Ponto de entrada ao selecionar classificção doc. entrada
Utilizado para atualizar o campo D1_CLVL
@type function
@version 1.0
@author Anderson Quintiliano
@since 20/01/2026
/*/
User Function MT100CLA()
    
    U_PECOM04()

Return

/*/{Protheus.doc} MT103FIM
Ponto de entrada ao finalizar inclusão de doc. entrada
Utilizado para atualizar o campo E2_CLVL
@type function
@version 1.0
@author Anderson Quintiliano
@since 20/01/2026
/*/
User Function MT103FIM()
    
    U_PECOM05()

Return
