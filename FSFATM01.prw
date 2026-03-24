#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Dados Bancários"
 
/*/{Protheus.doc} FSFATM01
Função para cadastro de Grupo de Produtos (Z05), exemplo de Modelo 1 em MVC
@author Anderson Rezende
@since 17/11/2025
@version 1.0
@return Nil, Função não tem retorno
@example
@obs Não se pode executar função MVC dentro do fórmulas
/*/
 
User Function FSFATM01()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("Z05")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Legendas
    oBrowse:AddLegend( "Z05_STATUS == '1'", "GREEN",   "Liberado" )
    oBrowse:AddLegend( "Z05_STATUS == '2'", "RED",    "Bloqueado" )
     
    //Ativa a Browse
    oBrowse:Activate()
     
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Anderson Quintiliano                                               |
 | Data:  17/11/2025                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.FSFATM01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'fLegenda'         OPERATION 6                      ACCESS 0 //OPERATION 6
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.FSFATM01' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.FSFATM01' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.FSFATM01' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Anderson Quintiliano                                               |
 | Data:  17/11/2025                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
    //Criação do objeto do modelo de dados
    Local oModel := Nil
     
    //Criação da estrutura de dados utilizada na interface
    Local oStZ05 := FWFormStruct(1, "Z05")
     
    //Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
    oModel := MPFormModel():New("FAT001") 
     
    //Atribuindo formulários para o modelo
    oModel:AddFields("Z05_MASTER",/*cOwner*/,  oStZ05)

    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({'Z05_FILIAL','Z05_CORBAN','Z05_CLIENT','Z05_LOJA'})
     
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro")
     
Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Anderson Quintiliano                                               |
 | Data:  17/11/2025                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    //Criando oView como nulo
    Local oView := Nil

    //Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := ModelDef()
     
    //Criação da estrutura de dados utilizada na interface do cadastro de Autor
    Local oStZ05 := FWFormStruct(2, "Z05")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'Z05_NOME|Z05_DTAFAL|'}
     
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_Z05", oStZ05, "Z05_MASTER")
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_Z05', 'Dados Bancários' )  
     
    //Força o fechamento da janela na confirmação
    //oView:SetCloseOnOk({||.T.})
     
    //O formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_Z05","TELA")
Return oView
 
/*/{Protheus.doc} FSFATM01
Função para mostrar a legenda das rotinas MVC com grupo de produtos
@author Anderson Quintiliano
@since 17/11/2025
@version 1.0
    @example
    u_FSFATM01()
/*/
 
Static Function fLegenda()
    Local aLegenda := {}
     
    //Monta as cores
    AADD(aLegenda,{"BR_VERDE",        "Não bloqueado"  })
    AADD(aLegenda,{"BR_VERMELHO",    "Bloqueado"})
     
    BrwLegenda("Dados Bancários", "Bloqueio", aLegenda)
Return
