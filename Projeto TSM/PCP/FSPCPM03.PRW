#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

#define MVC_TITLE "Apontamento de Horas de Produção"
#define MVC_VIEWDEF_NAME "VIEWDEF.FSPCPM03"

/*/{Protheus.doc} 
(TELA DE PRODUÇÃO, APONTAMENTOS PRODUÇÃO)
@type  function
@author Silvio Nogueira
@since 23/09/2025
@version 01
/*/
User Function FSPCPM03()
    Local a_Area := FwGetArea()
    Local a_Campos  := {}
    Local n_RetView
    
    Private l_MsErroAuto := .F.
    Private l_RetInclui := .F.
    Private c_AliasTmp := GetNextAlias()
    Private l_Confirm := .T.

    private oIncluir
    private oEstornar
    private oCancelar

    private n_HRMARCK := 0

    Private _aHoras := {}

    Private c_CalPad  := SuperGetMv("MV_XCALPAD",.F.,'001')

    Private c_OPF3

    aAdd(a_Campos, {"TMP_OPER"   , "C", 6  , 0})
    aAdd(a_Campos, {"TMP_NOMEOP" , "C", 30 , 0})
    aAdd(a_Campos, {"TMP_PROJ"  , "C", 10  , 0})
    aAdd(a_Campos, {"TMP_OP"     , "C", 14 , 0})
    aAdd(a_Campos, {"TMP_PRODUT", "C", 15 , 0})
    aAdd(a_Campos, {"TMP_DESCPR", "C", 50 , 0})
    aAdd(a_Campos, {"TMP_COPER"  , "C", 2  , 0})
    aAdd(a_Campos, {"TMP_DESCR"  , "C" ,50 , 0})
    //aAdd(a_Campos, {"TMP_MOTIMP" , "C" ,20 , 0})
    aAdd(a_Campos, {"TMP_DTINI"  , "D", 8  , 0})
    aAdd(a_Campos, {"TMP_DTFIM"  , "D", 8  , 0})
    aAdd(a_Campos, {"TMP_HRINI"  , "C", 5  , 0})
    aAdd(a_Campos, {"TMP_HRFIM"  , "C", 5  , 0})
    aAdd(a_Campos, {"TMP_TOTAL"  , "C" ,5  , 0})
    aAdd(a_Campos, {"TMP_VERDUP"  , "C" ,1  , 0})
    aAdd(a_Campos, {"TMP_RATEIO"  , "N" ,6  , 2})

    oTempTable := FWTemporaryTable():New(c_AliasTmp)
    oTempTable:SetFields(a_Campos)
    oTempTable:AddIndex("1", {"TMP_PROJ","TMP_OPER","TMP_OP","TMP_COPER"} )
    oTempTable:Create()

    

    n_RetView := FWExecView('Apontamento de Horas de Produção', MVC_VIEWDEF_NAME, MODEL_OPERATION_INSERT, , { || .T. }, {|| MostraResumo()} , 50,) //aButtons)

    If n_RetView = 0

        If !Incluir()

            FWALERTERROR("Ocorreu erro durante a inclusão dos apontamentos. Necessário analisar o erro e refazer o apontamento.", "Erro de Inclusão!")

        Endif


    Else

        l_RetInclui := .T.

    Endif

    oTempTable:Delete()
    
    FWRestArea(a_Area)

Return 


/*------------------------------------------------------------------------------
@type    static function
@name    ModelDef
@desc    Responsável por definir o modelo de dados (campos, grids, triggers) utilizado
         na tela de configuração de produto e cliente. Monta as estruturas de campos
         do cabeçalho e grid, além de configurar os gatilhos de preenchimento automático.
@since   23/09/2025
@author  Silvio Nogueira
@return  Object Modelo configurado para a tela
@see     viewDef, onActivate 
------------------------------------------------------------------------------*/
static function ModelDef()
    local oModel          as object
    local oStrField       as object
    local oStrGrid        as object
    Local n_X              := 0
    Local a_Grid           := {}
    Local a_Cab            := {}
    Local a_Gatilhos       := {}
    Local a_GatCab         := {}
    Local n_Atual          := 0

    aAdd(a_Cab, {"TMP_OPER"  ,"Operador"     , "C", 6  , 0, .t.,.F.,.F.,.F.,Nil})
    aAdd(a_Cab, {"TMP_NOMEOP"   ,"Nome Operador" , "C"   ,30 , 0, .t.,.F.,.F.,.F.,Nil})

    aAdd(a_Grid, {"TMP_PROJ"     ,"Projeto", "C"   ,10  , 0, .t.,.F.,.F.,.F.,{|oStrGrid| vldProj(oStrGrid)}})
    aAdd(a_Grid, {"TMP_OP"       ,"Ordem de Produção", "C"   ,14  , 0, .t.,.F.,.F.,.F.,{|oStrGrid| vldOp(oStrGrid)}})
    aAdd(a_Grid, {"TMP_PRODUT"  ,"Produto OP", "C"   ,15  , 0, .t.,.F.,.F.,.F.,Nil})
    aAdd(a_Grid, {"TMP_DESCPR"  ,"Descr Prod OP", "C"   ,50  , 0, .t.,.F.,.F.,.F.,Nil})
    aAdd(a_Grid, {"TMP_COPER"    ,"Código", "C"   ,2  , 0, .t.,.F.,.F.,.F.,{|oStrGrid| vldOper(oStrGrid)}})
    aAdd(a_Grid, {"TMP_DESCR"    ,"Descrição"        , "C"   ,50 , 0, .t.,.F.,.F.,.F.,Nil})
    //aAdd(a_Grid, {"TMP_MOTIMP"   ,"Motivo Improd"        , "C"   ,20 , 0, .f.,.F.,.F.,.F.,Nil})
    aAdd(a_Grid, {"TMP_DTINI"    ,"Data Inicial" ,"D", 8   , 0, .t.,.F.,.F.,.F.,{|oStrGrid|validDtG(oStrGrid)}})
    aAdd(a_Grid, {"TMP_HRINI"    ,"Hora Inicial" ,"C", 5   , 0, .t.,.F.,.F.,.F.,{|oStrGrid|validHr(oStrGrid)}}) //{|oStrGrid|RateioHr(oStrGrid)}})
    aAdd(a_Grid, {"TMP_DTFIM"    ,"Data Final" ,"D", 8   , 0, .t.,.F.,.F.,.F.,{|oStrGrid|validDtG(oStrGrid)}})
    aAdd(a_Grid, {"TMP_HRFIM"    ,"Hora Final" ,"C", 5   , 0, .t.,.F.,.F.,.F.,{|oStrGrid|validHr(oStrGrid)}}) //{|oStrGrid|RateioHr(oStrGrid)}})
    aAdd(a_Grid, {"TMP_TOTAL"    ,"Total Horas" ,"C", 5   , 0, .t.,.F.,.F.,.F.,Nil})

    oStrField := FWFormModelStruct():New()
    oStrField:addTable(c_AliasTmp, {"TMP_OPER"}, "Informações", {|| ""})
    
    for n_X:= 1 to len(a_Cab)
        oStrField:AddField(;
            a_Cab[n_X][2],;                                                                                       // [01]  C   Titulo do campo
            a_Cab[n_X][2],;                                                                                       // [02]  C   ToolTip do campo
            a_Cab[n_X][1],;                                                                                       // [03]  C   Id do Field
            a_Cab[n_X][3],;                                                                                       // [04]  C   Tipo do campo
            a_Cab[n_X][4],;                                                                                       // [05]  N   Tamanho do campo
            Nil,;                                                                                               // [06]  N   Decimal do campo
            a_Cab[n_X][10],;                                                                                      // [07]  B   Code-block de validação do campo
            Nil,;                                                                                               // [08]  B   Code-block de validação When do campo
            {},;                                                                                                // [09]  A   Lista de valores permitido do campo
            a_Cab[n_X][6],;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, c_AliasTmp+"->"+a_Cab[n_X][1]),;                                // [11]  B   Code-block de inicializacao do campo
            a_Cab[n_X][7],;                                                                                       // [12]  L   Indica se trata-se de um campo chave
            a_Cab[n_X][8],;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            a_Cab[n_X][9];
            )
    Next

    //Estrutura de Gri
    oStrGrid := FWFormModelStruct():New() 
    oStrGrid:AddTable(c_AliasTmp, {'TMP_PROJ', 'TMP_OP','TMP_PRODUT','TMP_DESCPR','TMP_COPER','TMP_DESCR','TMP_DTINI','TMP_HRINI','TMP_DTFIM','TMP_HRFIM','TMP_TOTAL'}, "Temporaria")
    
    for n_X := 1 to len(a_Grid)
    // Adicionando os campos na estrutura de Grid
        oStrGrid:AddField(;
            a_Grid[n_X][2],;                                                                                                // [01]  C   Titulo do campo
            a_Grid[n_X][2],;                                                                                                // [02]  C   ToolTip do campo
            a_Grid[n_X][1],;                                                                                                // [03]  C   Id do Field
            a_Grid[n_X][3],;                                                                                                // [04]  C   Tipo do campo
            a_Grid[n_X][4],;                                                                                                // [05]  N   Tamanho do campo
            a_Grid[n_X][5],;                                                                                                // [06]  N   Decimal do campo
            a_Grid[n_X][10],;                                                                                               // [07]  B   Code-block de validação do campo
            Nil,;                                                                                                         // [08]  B   Code-block de validação When do campo
            {},;                                                                                                          // [09]  A   Lista de valores permitido do campo
            a_Grid[n_X][6],;                                                                                                // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, c_AliasTmp+"->"+a_Grid[n_X][1] ),;                                        // [11]  B   Code-block de inicializacao do campo
            a_Grid[n_X][7],;                                                                                                // [12]  L   Indica se trata-se de um campo chave
            a_Grid[n_X][8],;                                                                                                // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            a_Grid[n_X][9])  
    Next

    a_Gatilhos := {}
    
    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_COPER",;                                                                  //Campo Origem
        "TMP_DESCR",;                                                               //Campo Destino
        "U_PCPM03G1()",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_OP",;                                                                  //Campo Origem
        "TMP_COPER",;                                                               //Campo Destino
        "  ",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_COPER",;                                                               //Campo Destino
        "'HI'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "02");                                                                      //Sequência do gatilho
    )


    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_OP",;                                                               //Campo Destino
        "'HORAIMPRODUTIV'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(M->TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_PRODUT",;                                                               //Campo Destino
        "'HORAIMPRODUTIVA'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(M->TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "02");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_DESCR",;                                                               //Campo Destino
        "'HORAS IMPRODUTIVAS'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(M->TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_DESCPR",;                                                               //Campo Destino
        "'HORAS IMPRODUTIVAS'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(M->TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "02");                                                                      //Sequência do gatilho
    )


    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_OP",;                                                                  //Campo Origem
        "TMP_PRODUT",;                                                               //Campo Destino
        "Posicione('SC2',1,FWxFilial('SC2') + M->TMP_OP,'C2_PRODUTO')",;                  //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "02");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_OP",;                                                                  //Campo Origem
        "TMP_DESCPR",;                                                               //Campo Destino
        "Posicione('SB1',1,FWxFilial('SB1') + SC2->C2_PRODUTO,'B1_DESC')",;          //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "03");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_DTINI",;                                                                  //Campo Origem
        "TMP_TOTAL",;                                                               //Campo Destino
        "u_calctoth()",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )
    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_HRINI",;                                                                  //Campo Origem
        "TMP_TOTAL",;                                                               //Campo Destino
        "u_calctoth()",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )
    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_DTFIM",;                                                                  //Campo Origem
        "TMP_TOTAL",;                                                               //Campo Destino
        "u_calctoth()",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )
    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_HRFIM",;                                                                  //Campo Origem
        "TMP_TOTAL",;                                                               //Campo Destino
        "u_calctoth()",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_DTINI",;                                                                  //Campo Origem
        "TMP_DTFIM",;                                                               //Campo Destino
        "M->TMP_DTINI",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_COPER",;                                                               //Campo Destino
        "  ",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )

    /*
    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_DTINI",;                                                                  //Campo Origem
        "TMP_HRINI",;                                                               //Campo Destino
        "U_Inic_HrIni()",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "02");                                                                      //Sequência do gatilho
    )
    */

    aAdd(a_GatCab, FWStruTriggger( ;
        "TMP_OPER",;                                                                  //Campo Origem
        "TMP_NOMEOP",;                                                               //Campo Destino
        "CB1->CB1_NOME",;                                                           //Regra de Preenchimento
        .T.,;                                                                       //Irá Posicionar?
        "CB1",;                                                                        //Alias de Posicionamento
        1,;                                                                         //Índice de Posicionamento
        'xFilial("CB1")+M->TMP_OPER',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )


    For n_Atual := 1 To Len(a_GatCab)
        oStrField:AddTrigger( ;
            a_GatCab[n_Atual][01],; //Campo Origem
            a_GatCab[n_Atual][02],; //Campo Destino
            a_GatCab[n_Atual][03],; //Bloco de código na validação da execução do gatilho
            a_GatCab[n_Atual][04];  //Bloco de código de execução do gatilho
        )
    Next

    For n_Atual := 1 To Len(a_Gatilhos)
        oStrGrid:AddTrigger( ;
            a_Gatilhos[n_Atual][01],; //Campo Origem
            a_Gatilhos[n_Atual][02],; //Campo Destino
            a_Gatilhos[n_Atual][03],; //Bloco de código na validação da execução do gatilho
            a_Gatilhos[n_Atual][04];  //Bloco de código de execução do gatilho
        )
    Next

    oModel := MPFormModel():New("MIDMAIN2", /*bVldPre*/, /*bVldPos*/ /*{||fConfirm()},, {||l_Confirm := .F.,.t.}*/)
    oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oModel| fCarrGrid(oModel)})
    oModel:addGrid("GRIDID", "CABID", oStrGrid, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oModel| fCarrGrid(oModel)})
    oModel:GetModel("GRIDID"):SetOptional(.T.)
    oModel:setDescription(MVC_TITLE)
    
    // É necessário que haja alguma alteração na estrutura Field
    oModel:setActivate({ |oModel| onActivate(oModel)})
    
return oModel

/*------------------------------------------------------------------------------
@type    static function
@name    onActivate
@desc    Função de ativação do modelo. Pode ser utilizada para executar ações ao ativar
         a view/model, como carregar dados adicionais ou inicializar variáveis.
@since   09/06/2025
@author  Lucas Apolinario
@param   oModel - objeto do modelo ativo
@return  nil
@see     ModelDef
------------------------------------------------------------------------------*/
static function onActivate(oModel)

    oModel:GetModel("CABID"):SetValue('TMP_OPER',If(UserApont(),Space(len(CB1->CB1_CODOPE)),Posicione("CB1",2,FWxFilial("CB1") + __cUserID,"CB1_CODOPE")))

return

/*------------------------------------------------------------------------------
@type    static function
@name    viewDef
@desc    Responsável por definir a estrutura visual da tela (View), criando os campos
         do cabeçalho e grid, associando-os ao modelo, e configurando a disposição dos
         elementos na interface.
@since   24/09/2025
@author  Silvio Nogueira
@return  Object View configurada para a tela
@see     ModelDef
------------------------------------------------------------------------------*/
static function viewDef()
    local oView as object
    local oModel as object
    local oStrCab as object
    local oStrGrid as object

    local n_X         := 0 as numeric
    Local a_CabField  := {} as array
    Local a_GridField := {} as array

    aAdd(a_CabField, { "TMP_OPER"    , "01", "Operador"       , "Operador"       , Nil, "C", "@!"     , Nil, "CB1", UserApont(), Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_CabField, { "TMP_NOMEOP"  , "02", "Nome Operador"   , "Nome Operador"   , Nil, "C", ""       , Nil, "", .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})

//ORIGINAL
//    aAdd(a_GridField, { "TMP_OP"     ,"01", "Ordem de Produção" , "Ordem de Produção"   , Nil, "C", "@!", Nil, "SC2", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_PROJ"   ,"01", "Projeto" 		, "Projeto"   		, Nil, "C", "@!"	, Nil, "XPROJ"	, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_OP"     ,"02", "Ordem de Produção" , "Ordem de Produção"   , Nil, "C", "@!", Nil, "XOPRD", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    //aAdd(a_GridField, { "TMP_OP"     ,"02", "Ordem de Produção" , "Ordem de Produção"   , Nil, "C", "@!", Nil, "SC2", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})

    aAdd(a_GridField, { "TMP_PRODUT","03", "Produto da OP" , "Produto da OP"   , Nil, "C", "@!", Nil, "", .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_DESCPR","04", "Descr.Prod OP" , "Descr.Prod OP"   , Nil, "C", "@!", Nil, "", .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_COPER"  ,"05", "Código" , "Código"   , Nil, "C", "@!", Nil, "XOPER", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_DESCR"  ,"06", "Descrição" , "Descrição" , Nil, "C", "@!", Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f. })
    //aAdd(a_GridField, { "TMP_MOTIMP" ,"06", "Motivo Improd" , "Motivo Improd" , Nil, "C", "@S20", Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f. })
    aAdd(a_GridField, { "TMP_DTINI"  ,"07", "Data Inicial" , "Data Inicial" , Nil, "D", ""       , Nil, "", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_HRINI"  ,"08", "Hora Inicial" , "Hora Inicial" , Nil, "C", "99:99"  , Nil, "", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_DTFIM"  ,"09", "Data Final" , "Data Final" , Nil, "D", ""       , Nil, "", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_HRFIM"  ,"10", "Hora Final" , "Hora Final" , Nil, "C", "99:99"  , Nil, "", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_TOTAL"  ,"11", "Total Horas" , "Total Horas" , Nil, "C", ""  , Nil, "", .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
   
    // Estrutura cabeçalho
    oStrCab := FWFormViewStruct():New()
    
    For n_X := 1 To Len(a_CabField)
        oStrCab:AddField( ;
            a_CabField[n_X][1], ; // Nome do Campo
            a_CabField[n_X][2], ; // Ordem
            a_CabField[n_X][3], ; // Titulo do campo
            a_CabField[n_X][4], ; // Descricao do campo
            a_CabField[n_X][5], ; // Array com Help
            a_CabField[n_X][6], ; // Tipo do campo
            a_CabField[n_X][7], ; // Picture
            a_CabField[n_X][8], ; // Bloco de PictTre Var
            a_CabField[n_X][9], ; // Consulta F3
            a_CabField[n_X][10],; // Indica se o campo é alteravel
            a_CabField[n_X][11],; // Pasta do campo
            a_CabField[n_X][12],; // Agrupamento do campo
            a_CabField[n_X][13],; // Lista de valores permitido do campo (Combo)
            a_CabField[n_X][14],; // Tamanho maximo da maior opção do combo
            a_CabField[n_X][15],; // Inicializador de Browse
            a_CabField[n_X][16],; // Indica se o campo é virtual
            a_CabField[n_X][17],; // Picture Variavel
            a_CabField[n_X][18])  // Indica pulo de linha após o campo
    Next

    //Estrutura de Grid
    oStrGrid := FWFormViewStruct():New()

    For n_X := 1 To Len(a_GridField)
        oStrGrid:AddField( ;
            a_GridField[n_X][1], ;  // Nome do Campo
            a_GridField[n_X][2], ;  // Ordem
            a_GridField[n_X][3], ;  // Titulo do campo
            a_GridField[n_X][4], ;  // Descricao do campo
            a_GridField[n_X][5], ;  // Array com Help
            a_GridField[n_X][6], ;  // Tipo do campo
            a_GridField[n_X][7], ;  // Picture
            a_GridField[n_X][8], ;  // Bloco de PictTre Var
            a_GridField[n_X][9], ;  // Consulta F3
            a_GridField[n_X][10],;  // Indica se o campo é alteravel
            a_GridField[n_X][11],;  // Pasta do campo
            a_GridField[n_X][12],;  // Agrupamento do campo
            a_GridField[n_X][13],;  // Lista de valores permitido do campo (Combo)
            a_GridField[n_X][14],;  // Tamanho maximo da maior opção do combo
            a_GridField[n_X][15],;  // Inicializador de Browse
            a_GridField[n_X][16],;  // Indica se o campo é virtual
            a_GridField[n_X][17],;  // Picture Variavel
            a_GridField[n_X][18])  // Indica pulo de linha após o campo
    Next
   
    oModel := FWLoadModel("FSPCPM03")
    oView := FwFormView():New()
    
    oView:setModel(oModel)
    oView:addField("CAB", oStrCab, "CABID")
    oView:addGrid("GRID", oStrGrid, "GRIDID")

    oView:createHorizontalBox("TOCAB", 30 )
    oView:createHorizontalBox("TOGRID", 60 )

    oView:setOwnerView("CAB", "TOCAB" )
    oView:setOwnerView("GRID", "TOGRID")
    
    oView:setDescription( MVC_TITLE )
 
return oView

/*------------------------------------------------------------------------------
@type    function
@name    fCarrGrid
@desc    Carrega os dados do grid a partir da tabela temporária ou de campos do modelo,
         dependendo do contexto de chamada (GRIDID ou outro).
@since   09/06/2025
@author  Lucas Apolinario
Array de registros para o grid
@see     ModelDef
------------------------------------------------------------------------------*/
Static Function fCarrGrid(oSubModel)
    Local a_Reg  := {}
     
    a_Reg := FWLoadByAlias(oSubModel,oTempTable:GetAlias(),oTempTable:GetRealName())

Return a_Reg


/*/{Protheus.doc} fAction
Função responsável pela montagem dos botoes de acoes da tela
@type function
@author Silvio Nogueira
@since 24/09/2025
/*/
static function fAction(oButton)
    Local c_FontNome   := 'Tahoma'
    Local oFontPadrao := TFont():New(c_FontNome, , -12)
    Local n_Linha      := 000
    Local oApontar
    Local oCancel

    oApontar    := TButton():New(n_Linha,140, "Confirmar", oButton,{|| MostraResumo()}, /*Largura*/ 30, /*altura*/15, , oFontPadrao, , .t.)
    oCancel     := TButton():New(n_Linha,260, "Cancelar", oButton,/*acao*/, /*Largura*/ 30, /*altura*/15, , oFontPadrao, , .t.)

Return


/*/{Protheus.doc} PCPM03G1
Função Responsável por gatilhar a informação de descrição da operação
@type function
@author Silvio Nogueira
@since 24/09/2025
@version 01
/*/
user function PCPM03G1()
    Local a_Area     := FwGetArea()
    Local oModelMVC := FWModelActive()
    Local c_Codigo   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
    Local c_Desc     := ""
    Local c_OP       := oModelMVC:GetModel("GRIDID"):GetValue("TMP_OP")
    Local c_Proj     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local c_ProjImp  := SuperGetMv("MV_XPRJIMP",.F.,'BHI')

    If Left(c_Proj,3) <> Left(c_ProjImp,3)


        c_Prod      := Posicione("SC2",1,FWxFilial("SC2") + c_OP,"C2_PRODUTO")
        c_OPerac    := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")

        c_Desc    := Posicione("SG2",1,FWxFilial("SG2") + c_Prod + c_OPerac + c_Codigo , "G2_DESCRI")

    Else

        c_Desc    := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo , "VI_DESCRI")

    Endif

    FWRestArea(a_Area)

Return c_Desc


// Função utilizada para validar o projeto digitado no Grid
Static function vldProj(oModel)
    Local oModelMVC := FWModelActive()
    Local c_Qry
    Local l_Ret      := .t.
    Local c_Projeto  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local oQryC

    If oQryC == Nil

        c_Qry := "SELECT C5_XPROJET FROM ? SC5 WHERE C5_XPROJET = ? AND D_E_L_E_T_ = ''"
        c_Qry := ChangeQuery(c_Qry)
        oQryC := FWPreparedStatement():New(c_Qry)

    EndIf

    oQryC:SetUnsafe(1, RetSqlName( "SC5" ))
    oQryC:SetString(2, c_Projeto)

    c_Qry 	:= oQryC:GetFixQuery()

    c_AliasPrj 	:= MPSysOpenQuery( c_Qry )

    If (Empty(c_Projeto) .Or. (c_AliasPrj)->(Eof())) .And. Left(c_Projeto,3) <> 'BHI'

        FWALERTERROR("O Projeto digitado não está vinculado a nenhum Pedido de Venda.", "Projeto Inválido!")
        l_Ret := .f.

    Endif

    (c_AliasPrj)->(dbCloseArea())

return l_Ret


// Função para validar o campo Código de Operação digitado no grid X projeto
// Implentada validação de sequência de apontamento e quantidade apontada
Static function vldOper(oModel)
    Local oModelMVC := FWModelActive()
    Local a_Area    := FwGetArea()
    Local l_Ret     := .t.
    Local c_OP      := oModelMVC:GetModel("GRIDID"):GetValue("TMP_OP")
    Local c_Prod
    Local c_Codigo  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
    Local cProj     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local c_PI
    Local a_SaveLines := FWSaveRows()
    Local oQryC
    Local c_OperEnc     := SuperGetMv("MV_XOPEREN",.F.,'99')    

    If c_Codigo == c_OperEnc

       FWALERTERROR("Código de Operação não permite apontamento.", "Operação Inválida!")
       l_Ret := .f.

    Endif

    If Left(cProj,3) == 'BHI' .And. l_Ret

       l_Ret := .t.
       Return l_Ret

    Endif

    c_Prod       := Posicione("SC2",1,FWxFilial("SC2") + c_OP,"C2_PRODUTO")

    If l_Ret

        If oQryC == Nil

            c_Qry := "select G2_CODIGO, G2_PRODUTO, G2_DESCRI, G2_OPERAC from ? SG2  " + CRLF
            c_Qry += "INNER JOIN ? SB1 ON G2_FILIAL=B1_FILIAL AND G2_PRODUTO=B1_COD AND G2_CODIGO=B1_OPERPAD AND SB1.D_E_L_E_T_='' " + CRLF
            c_Qry += "INNER JOIN ? SH1 ON G2_FILIAL=H1_FILIAL AND G2_RECURSO=H1_CODIGO AND SH1.D_E_L_E_T_='' " + CRLF
            c_Qry += "INNER JOIN ? CB1 ON CB1_CODOPE='?' AND CB1.D_E_L_E_T_='' " + CRLF
            c_Qry += "LEFT OUTER JOIN SYS_USR_VINCFUNC USR ON CB1_FILIAL= USR_FILIAL AND CB1_CODUSR=USR_ID AND USR.D_E_L_E_T_='' " + CRLF
            c_Qry += "LEFT OUTER JOIN ? SRA ON RA_FILIAL= USR_FILIAL AND RA_MAT=USR_CODFUNC AND SRA.D_E_L_E_T_='' " + CRLF
            c_Qry += "WHERE SG2.G2_FILIAL = '?' AND SG2.D_E_L_E_T_='' AND H1_CCUSTO = ISNULL(RA_CC,CB1.CB1_XCC) AND G2_PRODUTO = '?' AND G2_OPERAC = '?' " + CRLF

            c_Qry := ChangeQuery(c_Qry)
            oQryC := FWPreparedStatement():New(c_Qry)

        EndIf

        oQryC:SetUnsafe(1, RetSqlName( "SG2" ))
        oQryC:SetUnsafe(2, RetSqlName( "SB1" ))
        oQryC:SetUnsafe(3, RetSqlName( "SH1" ))
        oQryC:SetUnsafe(4, RetSqlName( "CB1" ))
        oQryC:SetUnsafe(5, CB1->CB1_CODOPE)
        oQryC:SetUnsafe(6, RetSqlName( "SRA" ))
        oQryC:SetUnsafe(7, xFilial("SG2"))
        oQryC:SetUnsafe(8, c_Prod)
        oQryC:SetUnsafe(9, c_Codigo)


        c_Qry 	:= oQryC:GetFixQuery()

        c_Alias 	:= MPSysOpenQuery( c_Qry )

        c_OPerac     := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")

        dbSelectArea("SG2")

        If SG2->(!MsSeek(FWxFilial("SG2") + c_Prod + c_OPerac + c_Codigo ))

            FWALERTERROR("A Operação digitada não faz parte do roteiro cadastrado para esse produto.", "Operação Inválida!")
            l_Ret := .f.

        Else

            c_PI := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo,"VI_XPI")

        Endif

        if (c_Alias)->(Eof()) .And. l_Ret
            FWALERTERROR("A Operação digitada não pertence ao centro custo desse operador.", "Operação Inválida!")
            l_Ret := .f.
        endif

    Endif

    FWRestArea(a_Area)

    FWRestRows( a_SaveLines )


return l_Ret

// Função utilizar para validar os campos de Data Inicial e Final no Grid
static function validDtG(oModel)
    Local l_Ret      := .t.
    Local d_Ulmes    := SuperGetMv("MV_ULMES")
    Local d_BloqMov  := SuperGetMv("MV_DBLQMOV")
    Local d_Digitado := oModel:GetValue("TMP_DTINI")
    //Local d_DataVld
 
    //Busca a data válida
    /*
    d_DataVld := DataValida(d_Digitado)
    if d_Digitado != d_DataVld
        FWALERTERROR("Data informada deve ser útil!", "Data inválida!")
        l_Ret := .f.
    endif
    */


    if d_Ulmes > d_Digitado 
        FWALERTERROR("A Data digitada não pode ser menor que a do ultimo fechamento de custos.", "Data Inválida!")
        l_Ret := .f.
    endif

    if d_BloqMov > d_Digitado .AND. l_Ret
        FWALERTERROR("A Data digitada não pode ser menor que a do ultimo fechamento de custos.", "Data Inválida!")
        l_Ret := .f.
    endif

return l_Ret

// Função para mostrar o resumo do apontamento antes da confirmação para gravação dos dados
Static Function MostraResumo()

    Local a_Area      := FwGetArea()
    Local oModelMVC := FWModelActive()
    Local n_X
    Local a_Datas := {}
    Local a_Opera := {}
    Local a_OpsEnc:= {}
    Local d_Data
    Local n_HorasTrab := 0
    Local n_HorasImpr := 0
    Local n_TotHoras  :=0
    Local c_FontNome   := 'Tahoma'
    Local oFontPadrao := TFont():New(c_FontNome, , -20)
    Local c_Prod
    Local c_Codigo
    Local c_OPerac
    Local c_PI
    Local l_Ret := .t.
    Local n_ColOP
    Local c_OPsEnc := ''
    Local n_TotReg   := oModelMVC:GetModel("GRIDID"):Length()
    Local l_CalPad   := If(SH7->(MsSeek(FWxFilial("SH7") + c_CalPad )),.T.,.F.)
    Local a_Sobrepoe := {}
    Local l_Sobrepos
    Local d_DataIni
    Local d_DataFim
    Local c_HoraIni
    Local c_HoraFim

    If  Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_OP")) .And.;
        Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")) .And.;
        Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")) .And.;
        Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")) .And.;
        Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRINI")) .And.;
        Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM"))

        FWALERTERROR("Linha do apontamento com todos os registros em branco.", "Linha Vazia!")

        n_TotReg := 0

    Endif

    If n_TotReg > 0

        for n_X:=1 to n_TotReg

                oModelMVC:GetModel("GRIDID"):GoLine(n_X)

                If oModelMVC:GetModel("GRIDID"):IsDeleted()

                    Loop

                Endif

                d_Data := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
                If aScan(a_Datas, d_Data) = 0

                    Aadd(a_Datas,d_Data)

                Endif

                d_Data := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")
                If aScan(a_Datas, d_Data) = 0

                    Aadd(a_Datas,d_Data)

                Endif

                c_OP         := oModelMVC:GetModel("GRIDID"):GetValue("TMP_OP")
                c_Prod       := Posicione("SC2",1,FWxFilial("SC2") + c_OP,"C2_PRODUTO")
                c_Codigo     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
                c_OPerac     := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
                c_PI         := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo,"VI_XPI")

                // Verifica se o registro em análise já foi considerado por sobreposição de data e hora / inicial e final
                // Se sim, não soma novamente
                d_DataIni    := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
                d_DataFim    := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")
                c_HoraIni    := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRINI")
                c_HoraFim    := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")

                l_Sobrepos   := If(AScan(a_Sobrepoe,;
                                {|x|   x[1] == d_DataIni .And.;
                                       x[2] == d_DataFim .And.;
                                       x[3] == c_HoraIni .And.;
                                       x[4] == c_HoraFim;
                                }) > 0 , .T., .F.;
                                )

                If !l_Sobrepos
              
                    If c_PI == 'I'

                           n_HorasImpr += Val(oModelMVC:GetModel("GRIDID"):GetValue("TMP_TOTAL"))

                    Else

                        n_HorasTrab += Val(oModelMVC:GetModel("GRIDID"):GetValue("TMP_TOTAL"))

                    Endif

                    Aadd(a_Sobrepoe,{d_DataIni,d_DataFim,c_HoraIni,c_HoraFim})

                Endif

                // Verificação das OPs que serão encerradas após a confirmação
                // Cria Array aOps com a sequência do roteiro de operações
                While !Eof() .And. SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) = FWxFilial("SG2") + c_Prod + c_OPerac 
                
                    Aadd(a_Opera,SG2->G2_OPERAC)

                    SG2->(dbSkip())

                End
            
                If len(a_Opera) > 0 .And. a_Opera[len(a_Opera)] = c_Codigo
    
                    Aadd(a_OpsEnc,c_OP)
                    c_OPsEnc += Alltrim(c_OP) + ' / '            

                Endif

        Next

        // Sumariza horas já gravadas nas tabelas de apontamentos

        n_HorasTrab  += 0 //SomaHoras("P",a_Datas,oModelMVC:GetModel("CABID"):GetValue("TMP_OPER"))
        n_HorasImpr  += 0 //SomaHoras("I",a_Datas,oModelMVC:GetModel("CABID"):GetValue("TMP_OPER"))
        
        If !Empty(a_Datas)

            n_TotHoras := u_CalcHr(c_CalPad,a_Datas)
            
        Endif
    
    Else
    
        l_Ret := .F.
    
    Endif

    oModal  := FWDialogModal():New()      
    oModal:SetEscClose(.T.)
    oModal:setTitle("Resumo Apontamento : ")
      
    //Seta a altura e largura da janela em pixel
    oModal:setSize(200, 200)
 
    oModal:createDialog()

    oModal:addCloseButton({|| l_Ret := .F.,oModal:OOWNER:END()}, "Voltar")
    oModal:addOkButton({||FWMsgRun(, {|| oModal:OOWNER:END() }, "Processando", "Realizando Apontamento")}, "Apontar", , ) 

    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    TSay():New(015,005,{|| "Calendário Padrão : (" + If(l_CalPad,c_CalPad,"NÃO CADASTRADO") + ")"},oContainer,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,150,20,,,,,,.T.)

    TSay():New(025,005,{|| "Horas Devidas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(025,120,{|| cValToChar(Round(n_TotHoras,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    TSay():New(045,005,{|| "Horas Trabalhadas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(045,120,{|| cValToChar(Round(n_HorasTrab,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    TSay():New(065,005,{|| "Horas Improdutivas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(065,120,{|| cValToChar(Round(n_HorasImpr,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    TSay():New(085,005,{|| "Horas Não Apontadas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(085,120,{|| cValToChar(Round(If(n_TotHoras - n_HorasTrab - n_HorasImpr < 0, 0,n_TotHoras - n_HorasTrab - n_HorasImpr),2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
 
    TSay():New(105,005,{|| "OPs encerradas : "},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    n_ColOP := 005

    TSay():New(120,n_ColOP,{|| c_OPsEnc},oContainer,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,100,20,,,,,,.T.)
 
    oModal:Activate()

    FWRestArea(a_Area)

Return l_Ret

// Ponto de Entrada do Browse para ser utilizado caso necessário
User Function MIDMAIN2()

    Local oModelMVC := FWModelActive()
    Local c_OPer
    Local a_Area     := FwGetArea()
    Local l_Ret := .T.
    Local oModel := PARAMIXB[1]
    Local c_IdPonto := PARAMIXB[2]
    Local c_Prod
    Local c_Codigo
    Local c_PI
    //Local c_MotImp
    Local c_OPerac
    Local n_It

    Local d_DtIni
    Local c_HrIni
    Local d_DtFim
    Local cHrFim

    Local d_DataIni1
    Local c_HoraIni1
    Local d_DataFim1
    Local c_HoraFim1
    Local d_DataIni2
    Local c_HoraIni2
    Local d_DataFim2
    Local c_HoraFim2

    Local l_Sobrepoe

    Local n_LinAtu

    Local n_OpsDig

    Local c_Qry
    Local oQryC
    Local c_Alias

    
    If c_IdPonto = "FORMLINEPOS"

        c_OPer := oModelMVC:GetModel("CABID"):GetValue("TMP_OPER")

        c_OP       := oModel:GetValue("TMP_OP")
        c_Codigo   := oModel:GetValue("TMP_COPER")
        //c_MotImp   := oModel:GetValue("TMP_MOTIMP")
        
        c_Prod     := Posicione("SC2",1,FWxFilial("SC2") + c_OP,"C2_PRODUTO")
        c_OPerac   := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
    
        c_PI := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo,"VI_XPI")

        /*
        If c_PI =='I' .And. Empty(c_MotImp)

            FWALERTERROR("A Operação digitada é Improdutiva e deve ter o motivo digitado.", "Motivo não Preenchido!")
            l_Ret := .F.

        Endif
        */

        /*
        ------------------------------------------------------------------
        Verifica se dois eventos possuem sobreposição de tempo (conflito)
        ------------------------------------------------------------------
        Valida inicialmente na tabela para verificar se a digitação atual 
        sobrepõe algum registro já apontado na Z01
        */
        If l_Ret

            c_Alias := GetNextAlias()

            d_DtIni  := oModel:GetValue("TMP_DTINI")
            c_HrIni  := oModel:GetValue("TMP_HRINI")
            d_DtFim  := oModel:GetValue("TMP_DTFIM")
            cHrFim  := oModel:GetValue("TMP_HRFIM")

            n_LinAtu := oModel:nLine // Linha atual do grid

            // Verifica sobreposição com registros da tabela Z01
            If oQryC == Nil

                c_Qry := "SELECT Z01_OP,Z01_DTINI,Z01_DTFIM,Z01_HRINI,Z01_HRFIM FROM ? Z01 "
                c_Qry += "WHERE D_E_L_E_T_ = '' AND Z01_OP <> ''"
                c_Qry += "AND ? < Z01_DTFIM+LEFT(Z01_HRFIM,2)+SUBSTRING(Z01_HRFIM,4,2) AND ? > Z01_DTINI+LEFT(Z01_HRINI,2)+SUBSTRING(Z01_HRINI,4,2)"
                c_Qry += "AND Z01_OPER = ?"
                c_Qry := ChangeQuery(c_Qry)
                oQryC := FWPreparedStatement():New(c_Qry)

            EndIf

            oQryC:SetUnsafe(1, RetSqlName( "Z01" ))
            oQryC:SetString(2, fwtimestamp(1,d_DtIni,c_HrIni) )
            oQryC:SetString(3, fwtimestamp(1,d_DtFim,cHrFim) )
            oQryC:SetString(4, c_OPer )

            c_Qry 	:= oQryC:GetFixQuery()

            c_Alias 	:= MPSysOpenQuery( c_Qry )

            If (c_Alias)->(!Eof())

                FWALERTERROR("Há sobreposição de tempo entre os apontamentos! (" + (c_Alias)->Z01_OP + " / Data e Hora Inicial : " + (c_Alias)->Z01_DTINI + " - " + (c_Alias)->Z01_HRINI + " / Data e Hora Final : " + (c_Alias)->Z01_DTFIM + " - " + (c_Alias)->Z01_HRFIM + ")", "Atenção")
                l_Ret := .F.

            Endif

            (c_Alias)->(dbCloseArea())

        Endif

        /*
        ------------------------------------------------------------------
        Verifica se dois eventos possuem sobreposição de tempo (conflito)
        ------------------------------------------------------------------
        Valida inicialmente na tabela para verificar se a digitação atual 
        sobrepõe algum registro já apontado na SH6
        */
        If l_Ret

            c_Alias := GetNextAlias()

            d_DtIni  := oModel:GetValue("TMP_DTINI")
            c_HrIni  := oModel:GetValue("TMP_HRINI")
            d_DtFim  := oModel:GetValue("TMP_DTFIM")
            cHrFim  := oModel:GetValue("TMP_HRFIM")

            n_LinAtu := oModel:nLine // Linha atual do grid

            c_Qry := "SELECT H6_OP,H6_DATAINI,H6_DATAFIN,H6_HORAINI,H6_HORAFIN FROM ? SH6 "
            c_Qry += "WHERE D_E_L_E_T_ = '' AND H6_OP <> ''"
            c_Qry += "AND ? < H6_DATAFIN+LEFT(H6_HORAFIN,2)+SUBSTRING(H6_HORAFIN,4,2) AND ? > H6_DATAINI+LEFT(H6_HORAINI,2)+SUBSTRING(H6_HORAINI,4,2)"
            c_Qry += "AND H6_RECURSO = ?"
            c_Qry := ChangeQuery(c_Qry)
            oQryC := FWPreparedStatement():New(c_Qry)

            oQryC:SetUnsafe(1, RetSqlName( "SH6" ))
            oQryC:SetString(2, fwtimestamp(1,d_DtIni,c_HrIni) )
            oQryC:SetString(3, fwtimestamp(1,d_DtFim,cHrFim) )
            oQryC:SetString(4, c_OPer )

            c_Qry 	:= oQryC:GetFixQuery()

            c_Alias 	:= MPSysOpenQuery( c_Qry )

            If (c_Alias)->(!Eof())

                FWALERTERROR("Há sobreposição de tempo entre os apontamentos! (" + (c_Alias)->H6_OP + " / " + (c_Alias)->H6_DATAINI + " - " + (c_Alias)->H6_HORAINI + ")", "Atenção")
                l_Ret := .F.

            Endif

            (c_Alias)->(dbCloseArea())

        Endif

        /*
        Validar apontamento com sobreposição parcial
        ------------------------------------------------------------------
        Verifica se dois eventos possuem sobreposição de tempo (conflito)
        Dados de entrada :
        d_DataIni1, c_HoraIni1, d_DataFim1, c_HoraFim1
        d_DataIni2, c_HoraIni2, d_DataFim2, c_HoraFim2
        ------------------------------------------------------------------
        */
        // Valida o registro digitado no GRID contra os demais registros já existentes
        If l_Ret

            n_OpsDig := oModel:Length()

            For n_It := 1 to n_OpsDig

                oModel:GoLine(n_It)

                If oModel:IsDeleted()

                    Loop

                Endif

                If n_It <> n_LinAtu

                    d_DataIni1 := d_DtIni
                    c_HoraIni1 := c_HrIni
                    d_DataFim1 := d_DtFim
                    c_HoraFim1 := cHrFim

                    d_DataIni2  := oModel:GetValue("TMP_DTINI")
                    c_HoraIni2  := oModel:GetValue("TMP_HRINI")
                    d_DataFim2  := oModel:GetValue("TMP_DTFIM")
                    c_HoraFim2  := oModel:GetValue("TMP_HRFIM")

                    l_Sobrepoe := If(fTemSobrepos(d_DataIni1, c_HoraIni1, d_DataFim1, c_HoraFim1, ;
                                              d_DataIni2, c_HoraIni2, d_DataFim2, c_HoraFim2)='S',.T.,.F.)

                    If l_Sobrepoe

                        FWALERTERROR("Há sobreposição de tempo entre os apontamentos! (" + Dtoc(d_DataIni2) + " - " + c_HoraIni2 + " Linha->" + Alltrim(Str(n_It,3))+")", "Atenção")
                        l_Ret := .f.
                        Exit

                    EndIf

                Endif

            Next

        Endif

    ElseIf c_IdPonto == "BUTTONBAR"

        l_Ret := {{"Apontamentos do dia", "Apontamentos do dia", {||u_FSPCPM08()}}}
 
    Endif

    FwRestArea(a_Area)

Return l_Ret


/*/{Protheus.doc} validOrdem
Função responsável por validar o conteudo digitado no campo de Ordem
@type  function
@author Lucas Apolinário
@since 19/08/2025
@version 01
*/

Static function vldOP(oModel)
    Local a_Area    := FwGetArea()
    Local l_Ret     := .t.
    Local c_OP      := oModel:GetValue("TMP_OP")
    Local c_Proj    := oModel:GetValue("TMP_PROJ")
    //Local c_DescPrd

    If Left(c_Proj,3) == 'BHI'

       l_Ret := .t.
       Return l_Ret

    Endif

    dbSelectArea("SC2")
    SC2->(DbSetOrder(1))
    If SC2->(!MsSeek(FWxFilial("SC2") + c_OP ))
        FWALERTERROR("Numero da Ordem de Produção não encontrada!", "Atenção")
        l_Ret := .f.

    Else

        If SC2->(!RegistroOk())

            l_Ret := .f.

        Endif

        If SC2->C2_TPOP <> 'F'

            FWALERTERROR("Ordem de Produção não é firme!", "Atenção")
            l_Ret := .f.

        Endif

        If !Empty(SC2->C2_DATRF)

            FWALERTERROR("Ordem de Produção já foi encerrada!", "Atenção")
            l_Ret := .f.

        Endif

    endif

    /*
    If l_Ret

        c_DescPrd       := Posicione('SB1',1,FWxFilial('SB1') + SC2->C2_PRODUTO,'B1_DESC')

        oModel:SetValue("TMP_PRODUT")   := SC2->C2_PRODUTO
        oModel:SetValue("TMP_DESCPR")   := c_DescPrd

    Endif
    */

    FwRestArea(a_Area)

return l_Ret


static function validHr(oModel)
    Local oModelMVC  := FWModelActive()
    Local l_Ret      := .t.
    Local c_HoraIni  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRINI")
    Local c_HoraFim  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")
    Local c_Hora
    Local c_Min
 
    c_HoraIni := If(Empty(c_HoraIni),'00:00',c_HoraIni)
    c_HoraFim := If(Empty(c_HoraFim),'23:59',c_HoraFim)

    // Hora Inicial Invalida
    c_Hora     := SubStr(c_HoraIni,1,2)
    c_Min      := SubStr(c_HoraIni,4,2)
    If Len(AllTrim(c_HoraIni)) < 5 .Or. ;
        ((Val(c_Hora) < 0) .or. (Val(c_Hora) > 23)) .Or. ;
        (Val(c_Min) < 0) .or. (Val(c_Min) > 59)

        l_Ret := .F.

    EndIf

    // Hora Final Invalida
    c_Hora     := SubStr(c_HoraFim,1,2)
    c_Min      := SubStr(c_HoraFim,4,2)
    If Len(AllTrim(c_HoraFim)) < 5 .Or. ;
        ((Val(c_Hora) < 0) .or. (Val(c_Hora) > 23)) .Or. ;
        (Val(c_Min) < 0) .or. (Val(c_Min) > 59)

        l_Ret := .F.

    EndIf

    //Verifica se hora inicial é maior que hora final
    if c_HoraIni > c_HoraFim

        FWALERTERROR("Hora Inicial maior que hora final!", "Hora inválida!")
        l_Ret := .f.

    endif

return l_Ret


Static Function Incluir(oModal)
    Local c_OPer
    Local c_Prod
    Local c_Local
    Local c_QtdProd
    Local c_Recurso
    Local c_DtIni
    Local c_ProjImp
    Local a_Opera := {}
    Local c_ParcTot := 'P'
    Local n_RecAtu
    Local d_DataIni1
    Local c_HoraIni1
    Local d_DataFim1
    Local c_HoraFim1
    Local n_Igual  := 0
    Local n_TotHr  := 0
    Local d_DataIni2
    Local c_HoraIni2
    Local d_DataFim2
    Local c_HoraFim2
    Local l_Igual

    l_RetInclui := .T.

    BEGIN TRANSACTION

    // Identificar apontamentos com data/hora inicial/final iguais
    (c_AliasTmp)->(dbGotop())
    While !(c_AliasTmp)->(Eof())

        n_RecAtu := (c_AliasTmp)->(Recno())

        d_DataIni1 := (c_AliasTmp)->TMP_DTINI
        c_HoraIni1 := (c_AliasTmp)->TMP_HRINI
        d_DataFim1 := (c_AliasTmp)->TMP_DTFIM
        c_HoraFim1 := (c_AliasTmp)->TMP_HRFIM

        If Empty((c_AliasTmp)->TMP_VERDUP)

            n_Igual  := 0
            n_TotHr  := 0

            (c_AliasTmp)->(dbGotop())
            While !(c_AliasTmp)->(Eof())

                If n_RecAtu <> (c_AliasTmp)->(Recno())

                    d_DataIni2 := (c_AliasTmp)->TMP_DTINI
                    c_HoraIni2 := (c_AliasTmp)->TMP_HRINI
                    d_DataFim2 := (c_AliasTmp)->TMP_DTFIM
                    c_HoraFim2 := (c_AliasTmp)->TMP_HRFIM
                    n_TotHr    := Val((c_AliasTmp)->TMP_TOTAL)

                    l_Igual    := If(fTemSobrepos(d_DataIni1, c_HoraIni1, d_DataFim1, c_HoraFim1, ;
                                      d_DataIni2, c_HoraIni2, d_DataFim2, c_HoraFim2)='I',.T.,.F.)      
                    If l_Igual

                        (c_AliasTmp)->TMP_VERDUP := 'S'
                        n_Igual++

                    Endif

                Endif

                (c_AliasTmp)->(dbSkip())

            Enddo
        
            (c_AliasTmp)->(dbGoto(n_RecAtu))
            (c_AliasTmp)->TMP_VERDUP := If(n_Igual>0,'S','N')

            If n_Igual > 0

                (c_AliasTmp)->(dbGotop())
                While !(c_AliasTmp)->(Eof())

                    If (c_AliasTmp)->TMP_VERDUP == 'S' .And. Empty((c_AliasTmp)->TMP_RATEIO)

                        (c_AliasTmp)->TMP_RATEIO := n_TotHr / (n_Igual+1)

                    Endif

                    (c_AliasTmp)->(dbSkip())

                Enddo

            Endif

        Endif

        (c_AliasTmp)->(dbSkip())

    Enddo

    //==============================================================================
    // Inicia processo de gravação dos apontamentos improdutivos Z01 e produtivo SH6
    //==============================================================================
    dbSelectArea("Z01")
    Z01->(DbSetOrder(1))

    (c_AliasTmp)->(dbGotop())

    While !(c_AliasTmp)->(Eof())

            c_DtIni    := (c_AliasTmp)->TMP_DTINI
            //c_ProjImp := 'BHI'+StrZero(month(c_DtIni),2)+Str(Year(c_DtIni),4)
            c_ProjImp := (c_AliasTmp)->TMP_PROJ

            c_OP     := (c_AliasTmp)->TMP_OP
            c_OPer   := (c_AliasTmp)->TMP_COPER
            c_Operado:= (c_AliasTmp)->TMP_OPER

            SC2->(DbSetOrder(1))
            SC2->(MsSeek(FWxFilial("SC2") + c_OP))

            c_Prod       := SC2->C2_PRODUTO
            c_Local      := SC2->C2_LOCAL
            c_QtdProd    := SC2->C2_QUANT
            c_Recurso    := SC2->C2_RECURSO

            c_OPerac     := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
            c_PI         := Posicione("SVI",1,FWxFilial("SVI") + c_OPer,"VI_XPI")

            // Verificação das OPs que serão encerradas após a confirmação
            // Cria Array aOps com a sequência do roteiro de operações
            While !Eof() .And. SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) = FWxFilial("SG2") + c_Prod + c_OPer

                Aadd(a_Opera,SG2->G2_OPERAC)

                SG2->(dbSkip())

            End
            If len(a_Opera) > 0 .And. a_Opera[len(a_Opera)] == c_OPer

                c_ParcTot := 'T'

            Endif

            // Grava somente os apontamentos improdutivos na tabela Z01
            If c_PI == 'I'
                Reclock("Z01",.t.)
                Z01->Z01_FILIAL  := cFilAnt
                Z01->Z01_OPER    := (c_AliasTmp)->TMP_OPER     // Operador
                Z01->Z01_PROJ   := (c_AliasTmp)->TMP_PROJ
                Z01->Z01_OP      := (c_AliasTmp)->TMP_OP      // Ordem de Produção
                Z01->Z01_COPER   := (c_AliasTmp)->TMP_COPER   // Código da Operação
                Z01->Z01_DESCR   := (c_AliasTmp)->TMP_DESCR  // Descrição da Operação
                Z01->Z01_DTINI   := (c_AliasTmp)->TMP_DTINI  // Data Inicial
                Z01->Z01_DTFIM   := (c_AliasTmp)->TMP_DTINI  // Data Final
                Z01->Z01_HRINI   := (c_AliasTmp)->TMP_HRINI  // Hora Inicial
                Z01->Z01_HRFIM   := (c_AliasTmp)->TMP_HRFIM  // Hora Final
                Z01->Z01_TOTAL   := If((c_AliasTmp)->TMP_VERDUP == 'S',(c_AliasTmp)->TMP_RATEIO,Val((c_AliasTmp)->TMP_TOTAL))  // Tempo Total
                Z01->Z01_DTAPON  := dDatabase                                            // Data do apontamento
                //Z01->Z01_MTIMPP  := (c_AliasTmp)->TMP_MOTIMP  // Motivo Horas Improdutivas
                Z01->Z01_PROJ    := If(c_PI == 'I',c_ProjImp,'')
                Z01->(MsUnlock())
            Endif


            // Grava somente os apontamentos produtivos na tabela SH6
            If c_PI <> 'I'

                // Inicia processo de gravação da tabela SH6 de apontamento
                DbSelectArea("SH6")
                SH6->(DbSetOrder(1))

                cRateio := Strzero(Int((c_AliasTmp)->TMP_RATEIO) + Round(((c_AliasTmp)->TMP_RATEIO - Int((c_AliasTmp)->TMP_RATEIO))*60/100,2),6,2)
                cRateio := StrTran(cRateio, ".", ":")

                If (c_AliasTmp)->TMP_VERDUP == 'S'

                    aVetor := {;
                        {"H6_FILIAL"    , xFilial("SH6")  ,Nil},;
                     {"H6_OP"        , c_OP             ,Nil},;
                     {"H6_PRODUTO"   , c_Prod           ,Nil},;
                     {"H6_OPERAC"    , c_OPer        ,Nil},;
                     {"H6_RECURSO"   , c_Recurso            ,Nil},;
                     {"H6_OPERADO"   , c_Operado            ,Nil},;
                     {"H6_DATAINI"   , (c_AliasTmp)->TMP_DTINI        ,Nil},;
                     {"H6_HORAINI"   , (c_AliasTmp)->TMP_HRINI        ,Nil},;
                     {"H6_DATAFIN"   , (c_AliasTmp)->TMP_DTFIM         ,Nil},;
                     {"H6_HORAFIN"   , (c_AliasTmp)->TMP_HRFIM         ,Nil},;
                     {"H6_PT"        , c_ParcTot             ,Nil},;
                     {"H6_LOCAL"     , c_Local          ,Nil},;
                     {"H6_QTDPROD"   , c_QtdProd        ,Nil},;
                     {"H6_TEMPO"     , cRateio         ,Nil};
                     }

                Else

                    aVetor := {;
                        {"H6_FILIAL"    , xFilial("SH6")  ,Nil},;
                     {"H6_OP"        , c_OP             ,Nil},;
                     {"H6_PRODUTO"   , c_Prod           ,Nil},;
                     {"H6_OPERAC"    , c_OPer        ,Nil},;
                     {"H6_RECURSO"   , c_Recurso            ,Nil},;
                     {"H6_OPERADO"   , c_Operado            ,Nil},;
                     {"H6_DATAINI"   , (c_AliasTmp)->TMP_DTINI        ,Nil},;
                     {"H6_HORAINI"   , (c_AliasTmp)->TMP_HRINI        ,Nil},;
                     {"H6_DATAFIN"   , (c_AliasTmp)->TMP_DTFIM         ,Nil},;
                     {"H6_HORAFIN"   , (c_AliasTmp)->TMP_HRFIM         ,Nil},;
                     {"H6_PT"        , c_ParcTot             ,Nil},;
                     {"H6_LOCAL"     , c_Local          ,Nil},;
                     {"H6_QTDPROD"   , c_QtdProd        ,Nil};
                     }

                Endif

                MSExecAuto({|x| mata681(x)},aVetor, 3)

                If l_MsErroAuto

                    Mostraerro()
                    DisarmTransaction()
                    l_RetInclui := .F.
                    BREAK

                EndIf

            EndIf

            (c_AliasTmp)->(dbSkip())

    Enddo

    END TRANSACTION 
   
Return l_RetInclui


/*/
Função interna para checar sobreposição ou igualdade
Critério de sobreposição:
Os períodos se sobrepõem se o início de um for menor ou igual que o fim do outro
e o fim de um for maior ou igual que o início do outro
@return c_SobreIgual - S=Sobreposição / I=Igualdade    
/*/
Static Function fTemSobrepos(d_DataIni1, c_HoraIni1, d_DataFim1, c_HoraFim1, ;
                             d_DataIni2, c_HoraIni2, d_DataFim2, c_HoraFim2)

    Local c_SobreIgual

    cTempIni1 := fwtimestamp(1,d_DataIni1,c_HoraIni1)    
    cTempFim1 := fwtimestamp(1,d_DataFim1,c_HoraFim1)    
    cTempIni2 := fwtimestamp(1,d_DataIni2,c_HoraIni2)    
    cTempFim2 := fwtimestamp(1,d_DataFim2,c_HoraFim2)

    //Sobreposição Parcial
    c_SobreIgual := If(cTempIni1 <= cTempFim2 .And. cTempFim1 >= cTempIni2,'S','') 
    // Sobreposição Total - Igualdade
    c_SobreIgual := If(cTempIni1 = cTempIni2 .And. cTempFim1 = cTempFim2,'I',c_SobreIgual)

Return (c_SobreIgual)

/*------------------------------------------------------------------------------
@type    static function
@name    ModelDef
@desc    Responsável por calcular a carga horária dos dias passados no parâmetro.
@since   24/09/2025
@author  Silvio Nogueira
@param   cCodCal - código do calendário
@param   aDias - Array com dias a serem calculados
@return  Total Horas
------------------------------------------------------------------------------*/
Static Function SomaHoras(c_ApontPI,a_Dias,c_Oper)

    Local n_TotHoras := 0
    Local n_It
    Local c_Filial
    Local c_Dias    := ''
    Local c_Qry
    Local oQryC
    Local c_Alias

    c_Dias  := '('
    For n_It := 1 to len(a_Dias)
        c_Dias += "'"+Dtos(a_Dias[n_It])+"',"
    Next
    c_Dias  += "'')"

    c_Filial    := cFilAnt
    c_Alias := GetNextAlias()
    c_Qry := "SELECT Z01_DTINI,Z01_DTFIM,SUM(Z01_TOTAL) Z01_TOTAL FROM ? Z01 "
    c_Qry += "INNER JOIN ? SVI ON SVI.VI_FILIAL = '?' AND SVI.VI_CODIGO = Z01.Z01_c_OPER AND SVI.D_E_L_E_T_ = '' AND "
    If c_ApontPI=='P'
        c_Qry += "SVI.VI_XPI IN ('P',' ') "
    Else
        c_Qry += "SVI.VI_XPI IN ('I') "
    Endif
    c_Qry += "WHERE Z01.Z01_FILIAL = '?' AND Z01.D_E_L_E_T_ = '' AND Z01_OPER = ? "
    c_Qry += "GROUP BY Z01_DTINI,Z01_DTFIM "
    
    c_Qry := ChangeQuery(c_Qry)
    oQryC := FWPreparedStatement():New(c_Qry)
    oQryC:SetUnsafe(1, RetSqlName( "Z01" ))
    oQryC:SetUnsafe(2, RetSqlName( "SVI" ))
    oQryC:SetUnsafe(3, xFilial("SVI"))
    oQryC:SetUnsafe(5, xFilial("Z01"))
    oQryC:SetString(6, c_Oper )

    c_Qry 	:= oQryC:GetFixQuery()
    c_Alias 	:= MPSysOpenQuery( c_Qry )
    
    (c_Alias)->(!dbGotop())
    While (c_Alias)->(!Eof())
        If Ascan(a_Dias,{|x| Stod((c_Alias)->Z01_DTINI) == x[1] .Or. Stod((c_Alias)->Z01_DTFIM) == x[1] }) > 1
            If aScan(aUF,{|x| x[1] ==  AllTrim(cEst) }) != 0
                n_TotHoras += (c_Alias)->Z01_TOTAL
            Endif
        Endif
        (c_Alias)->(dbSkip())
    Enddo
    (c_Alias)->(dbCloseArea())

    c_Alias := GetNextAlias()
    c_Qry := "SELECT  SUM(CONVERT(INTEGER,SUBSTRING(H6_TEMPO,1,CHARINDEX(':',H6_TEMPO)-1))) HORA, "
    c_Qry := "        SUM(CONVERT(FLOAT,SUBSTRING(H6_TEMPO,CHARINDEX(':',H6_TEMPO)+1,2))/60) MINUTO "
    c_Qry := "FROM ? SH6 "
    c_Qry := "INNER JOIN ? SVI ON SVI.VI_FILIAL = '?' AND SVI.D_E_L_E_T_ = '' AND SVI.VI_XPI = '?' "
    c_Qry := "WHERE SH6.H6_FILIAL = '?' AND SH6.D_E_L_E_T_ = '' AND H6_RECURSO = ? "
    c_Qry := "    AND (H6_DATAINI IN (?) OR H6_DATAFIN IN (?))"
    c_Qry := ChangeQuery(c_Qry)
    oQryC := FWPreparedStatement():New(c_Qry)
    oQryC:SetUnsafe(1, RetSqlName( "SH6" ))
    oQryC:SetUnsafe(2, RetSqlName( "SVI" ))
    oQryC:SetUnsafe(3, xFilial("SVI"))
    oQryC:SetUnsafe(4, xFilial("SH6"))
    oQryC:SetString(5, c_ApontPI)
    oQryC:SetString(6, c_Oper )
    oQryC:SetString(7, c_Dias) 
    oQryC:SetString(8, c_Dias) 
    c_Qry 	:= oQryC:GetFixQuery()
    c_Alias 	:= MPSysOpenQuery( c_Qry )
    
    If (c_Alias)->(!Eof())
        n_TotHoras += (c_Alias)->HORA + Int((c_Alias)->MINUTO) + ((c_Alias)->MINUTO - Int((c_Alias)->MINUTO))
    Endif
    (c_Alias)->(dbCloseArea())

Return n_TotHoras

// Função para validar o usuário conectado se ele pertence aos operadores master
// Caso sim, libera o campo para mudança, caso não, 
//traz o campo preenchido com o o código do operador respectivo.
Static Function UserApont()
    Local l_Ret  := .T.
    Local c_OPMaster := SuperGetMv("MV_FS_OPER",.F.,"admin")

    If cUserName $ c_OPMaster

        l_Ret := .T.

    Else
    
        l_Ret := .F.

    Endif

Return l_Ret

User Function Inic_HrIni()
    Local o_ModelMVC  := FWModelActive()
    Local c_HrIni
    Local l_Ret := .T.
    Local n_TotReg  := o_ModelMVC:GetModel("GRIDID"):Length()
    Local d_DtDig   := o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
    Local a_Area     := FwGetArea()
    Local c_Alias
    Local n_It
    Local oQryC

    If Empty(n_TotReg)

        l_Ret := .F.

    Endif


    If l_Ret
    

        /*
        ------------------------------------------------------------------
        Localiza no Grid a maior hora final da data digitada
        ------------------------------------------------------------------
        */

        For n_It := 1 to n_TotReg

            o_ModelMVC:GetModel("GRIDID"):GoLine(n_It)

            If o_ModelMVC:GetModel("GRIDID"):IsDeleted()

                Loop

            Endif
            
            If o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM") == d_DtDig .And. o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM") > c_Hrini

                c_Hrini := o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")

            Endif

        Next

        FWRestArea(a_Area)


        /*
        ------------------------------------------------------------------
        Localiza na tabela Z01 a maior hora final da data digitada
        ------------------------------------------------------------------
        */

        c_Alias := GetNextAlias()

        d_DtFim  := o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")
        cHrFim  := o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")

        If oQryC == Nil

            c_Qry := "SELECT MAX(Z01_HRFIM) FROM ? Z01 "
            c_Qry += "WHERE D_E_L_E_T_ = '' "
            c_Qry += "AND Z01_DTFIM = ? AND Z01_HRFIM > ? "
            c_Qry := ChangeQuery(c_Qry)
            oQryC := FWPreparedStatement():New(c_Qry)

        EndIf

        oQryC:SetUnsafe(1, RetSqlName( "Z01" ))
        oQryC:SetString(2, Dtos(d_DtDig ))
        oQryC:SetString(3, c_HrIni )

        c_Qry 	:= oQryC:GetFixQuery()

        c_Alias 	:= MPSysOpenQuery( c_Qry )

        If (c_Alias)->(!Eof())

            c_HrIni := (c_Alias)->Z01_HRFIM

        Endif

        (c_Alias)->(dbCloseArea())

        /*
        ------------------------------------------------------------------
        Localiza na tabela SH6 a maior hora final da data digitada
        ------------------------------------------------------------------
        */

        c_Alias := GetNextAlias()
     
        If oQryC == Nil

            c_Qry := "SELECT MAX(H6_HORAFIN) FROM ? SH6 "
            c_Qry += "WHERE D_E_L_E_T_ = '' "
            c_Qry += "AND H6_DATAFIN = ? AND H6_HORAFIN > ? "
            c_Qry := ChangeQuery(c_Qry)
            oQryC := FWPreparedStatement():New(c_Qry)

        EndIf

        oQryC:SetUnsafe(1, RetSqlName( "SH6" ))
        oQryC:SetString(2, d_DtDig )
        oQryC:SetString(3, c_HrIni )

        c_Qry 	:= oQryC:GetFixQuery()

        c_Alias 	:= MPSysOpenQuery( c_Qry )

        If (c_Alias)->(!Eof())

            c_HrIni := (c_Alias)->H6_HORAFIN

        Endif

        (c_Alias)->(dbCloseArea())

    Endif

    c_HrIni := If(Substring(c_HrIni,4,2) == '59',StrZero(Val(Left(c_HrIni,2))+1,2) +':'+'00', Left(c_HrIni,2) + ':' + Strzero(Val(Substring(c_HrIni,4,2))+1,2))

Return c_HrIni


User Function F3OPrd()
    Local oModelMVC := FWModelActive()
    Local c_Projeto     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local oListBox
    Local l_Ok      := .F.
    Local oQryC
    Local c_Alias
    Local oDlg
    Local oPanel
    Local a_Campos   := {}
    Local b_BlocoOk     := {|| l_Ok := .T., c_OPF3 := (c_AliasOP)->OP, oDlg:End()}
    Local b_BlocoCan    := {|| l_Ok := .F., oDlg:End()}
    Local b_BlocoIni    := {|| EnchoiceBar(oDlg, b_BlocoOk, b_BlocoCan, , )}
    Local a_Area        := FwGetArea()
    Local a_SeekTmp := {;	
                        {"Ordem de Produção"		  	,{{"",;
                                               FwGetSx3Cache('C2_PRODUTO','X3_TIPO'),; 
                                               FwGetSx3Cache('C2_PRODUTO','X3_TAMANHO'),;
                                               0,; 
                                               "OP"		,; 
                                               FwGetSx3Cache('C2_PRODUTO','X3_PICTURE');	
                                               },;
                                               {"",;
                                               FwGetSx3Cache('B1_DESC','X3_TIPO'),; 
                                               FwGetSx3Cache('B1_DESC','X3_TAMANHO'),;
                                               0,; 
                                               "DESC"		,; 
                                               FwGetSx3Cache('B1_DESC','X3_PICTURE');	
                                               };
                                            };
                            };
                    }

    //Private c_Codigo
    Private c_AliasOP   := GetNextAlias()

    If oQryC == Nil
        c_Qry := "SELECT C2_NUM+C2_ITEM+C2_SEQUEN [OP],C2_PRODUTO [PRODUTO],B1_DESC [DESCRICAO],C2_ITEMCTA [PROJETO] FROM ? SC2 "
        c_Qry += "INNER JOIN ( "
        c_Qry += "SELECT G1_COMP FROM ? SG1 WHERE G1_FILIAL = '?' AND G1_COD IN "
        c_Qry += "(SELECT C6_PRODUTO FROM ? SC6 "
        c_Qry += "INNER JOIN ? SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM  AND C5_XPROJET = ? AND SC5.D_E_L_E_T_ = '' "
        c_Qry += "WHERE SC6.D_E_L_E_T_ = ' ') "
        c_Qry += "AND SG1.D_E_L_E_T_ = '' ) TMP ON TMP.G1_COMP = SC2.C2_PRODUTO "
        c_Qry += "INNER JOIN ? SB1 ON B1_FILIAL = '?' AND B1_COD = C2_PRODUTO "
        c_Qry += " WHERE SC2.C2_FILIAL = '?' AND SC2.D_E_L_E_T_ = ''"
        c_Qry += "ORDER BY SC2.C2_PRODUTO "
        c_Qry := ChangeQuery(c_Qry)
        oQryC := FWPreparedStatement():New(c_Qry)
    EndIf

    oQryC:SetUnsafe(1, RetSqlName("SC2"))
    oQryC:SetUnsafe(2, RetSqlName("SG1"))
    oQryC:SetUnsafe(3, xFilial("SG1"))
    oQryC:SetUnsafe(4, RetSqlName("SC6"))
    oQryC:SetUnsafe(5, RetSqlName("SC5"))
    oQryC:SetString(6, c_Projeto)
    oQryC:SetUnsafe(7, RetSqlName("SB1"))
    oQryC:SetUnsafe(8, xFilial("SB1"))
    oQryC:SetUnsafe(9, xFilial("SC2"))

    c_Qry 	:= oQryC:GetFixQuery()

    c_Alias 	:= MPSysOpenQuery( c_Qry )

    //Adiciona as colunas que serão criadas na temporária
    aAdd(a_Campos, { 'OP'   , 'C', FwGetSx3Cache('D3_OP','X3_TAMANHO'), 0}) 
    aAdd(a_Campos, { 'PRODUTO'   , 'C', FwGetSx3Cache('C2_PRODUTO','X3_TAMANHO'), 0}) 
    aAdd(a_Campos, { 'DESCRICAO', 'C', FwGetSx3Cache('B1_DESC','X3_TAMANHO'), 0})
    aAdd(a_Campos, { 'PROJETO', 'C', FwGetSx3Cache('C2_ITEMCTA','X3_TAMANHO'), 0})

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(C_ALIASOP)
    oTempTable:SetFields( a_Campos )
    oTempTable:AddIndex("1", {"OP"} )
    oTempTable:AddIndex("2", {"PRODUTO"} )
    oTempTable:Create()  
 
    //Popula a tabela temporária
    (c_Alias)->(dbGotop())

    While !(c_Alias)->(Eof())

        RecLock(C_ALIASOP,.T.)
        (C_ALIASOP)->OP          := (c_Alias)->OP
        (C_ALIASOP)->PRODUTO     := (c_Alias)->PRODUTO
        (C_ALIASOP)->DESCRICAO   := (c_Alias)->DESCRICAO
        (C_ALIASOP)->PROJETO     := (c_Alias)->PROJETO

        (c_Alias)->(dbSkip())

    Enddo

    //Adiciona as colunas
    a_Colunas := fCriaCols3()

    DEFINE MSDIALOG oDlg FROM 00,00 TO 390,890 PIXEL TITLE OemToAnsi("Pesquisa"/*STR0320*/) //"Pesquisa"

    oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    oListBox := FWBrowse():New()
    oListBox:SetSeek(,a_SeekTmp)
    oListBox:SetAlias(C_ALIASOP)
    oListBox:SetColumns(a_Colunas)
    oListBox:SetDataTable()    
    oListBox:SetOwner(oPanel)
    oListBox:DisableConfig()
    oListBox:DisableReport()
    oListBox:SetDoubleClick(b_BlocoOk)

    oListBox:Activate()

    oDlg:Activate(, , , .T., , , b_BlocoIni)

    FwRestArea(a_Area)

Return l_Ok

Static function fCriaCols3()
    Local a_Colunas := {}
    Local n_X       := 0 
    Local a_Estrut  := {} 
    Local oColumn

    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    //[7] - Editável? .T. = sim, .F. = não
    //[8] - Alinhamento sendo 0=Centralizado (só com textos);1=Esquerda; 2=Direita

    aAdd(a_Estrut, { 'OP','Ordem de Produção'    ,'C', FwGetSx3Cache('D3_OP','X3_TAMANHO'), 0,'',.F.,1}) 
    aAdd(a_Estrut, { 'PRODUTO','Produto'  ,'C', FwGetSx3Cache('C2_PRODUTO','X3_TAMANHO'), 0,'',.F.,1})
    aAdd(a_Estrut, { 'DESCRICAO','Descrição'  ,'C', FwGetSx3Cache('B1_DESC','X3_TAMANHO'), 0,'',.F.,1})
    aAdd(a_Estrut, { 'PROJETO','Projeto'  ,'C', FwGetSx3Cache('C2_ITEMCTA','X3_TAMANHO'), 0,'',.F.,1})

    for n_X:=1 to len(a_Estrut)
        //Cria as colunas
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + c_AliasOP + '->' + a_Estrut[n_X][1] +'}')) 
        oColumn:SetTitle(a_Estrut[n_X][2])
        oColumn:SetType(a_Estrut[n_X][3])
        oColumn:SetSize(a_Estrut[n_X][4])
        oColumn:SetDecimal(a_Estrut[n_X][5])
        oColumn:SetPicture(a_Estrut[n_X][6])

        If a_Estrut[n_X][7]
            oColumn:SetEdit(.F.)
            oColumn:SetReadVar(a_Estrut[n_X][1])
        EndIf
       
        aAdd(a_Colunas, oColumn)

    next n_X

return a_Colunas
