#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

#define MVC_TITLE "Apontamento de Horas de Engenharia"
#define MVC_VIEWDEF_NAME "VIEWDEF.FSPCPM02"

/*/{Protheus.doc} 
(TELA DE PRODUÇÃO, APONTAMENTOS ENGENHARIA)
@type  function
@author Silvio Nogueira
@since 23/09/2025
@version 01
/*/
User Function FSPCPM02()
    Local a_Area := FwGetArea()
    Local a_Campos  := {}
    Local n_RetView

    //Local aButtons := {}
    Private c_AliasTmp := GetNextAlias()
    Private l_Confirm := .T.

    private oIncluir
    private oEstornar
    private oCancelar

    private n_HRMARCK := 0

    Private _aHoras := {}

    Private c_CalPad  := SuperGetMv("MV_XCALPAD",.F.,'001')

    aAdd(a_Campos, {"TMP_PROJ"  , "C", 10  , 0})
    aAdd(a_Campos, {"TMP_NOMEOP"  , "C", 30  , 0})
    aAdd(a_Campos, {"TMP_OPER"  , "C", 6  , 0})
    aAdd(a_Campos, {"TMP_CODPI" , "C", 15  , 0})
    aAdd(a_Campos, {"TMP_COPER" , "C", 2  , 0})
    aAdd(a_Campos, {"TMP_DESCR"  , "C" ,50 , 0})
    //aAdd(a_Campos, {"TMP_MOTIMP" , "C" ,20 , 0}) // Informação eliminada à pedido do Silva da Cavanna
    aAdd(a_Campos, {"TMP_DTINI"  , "D", 8  , 0})
    aAdd(a_Campos, {"TMP_DTFIM"  , "D", 8  , 0})
    aAdd(a_Campos, {"TMP_HRINI"  , "C", 5  , 0})
    aAdd(a_Campos, {"TMP_HRFIM"  , "C", 5  , 0})
    aAdd(a_Campos, {"TMP_TOTAL"  , "C" ,5  , 0})

    oTempTable := FWTemporaryTable():New(c_AliasTmp)
    oTempTable:SetFields(a_Campos)
    oTempTable:AddIndex("1", {"TMP_PROJ","TMP_OPER","TMP_CODPI","TMP_COPER"} )
    oTempTable:Create()
    
     //Executa a inclusao na tela
    n_RetView := FWExecView('Apontamento de Horas de Engenharia', MVC_VIEWDEF_NAME, MODEL_OPERATION_INSERT, , { || .T. }, {|| MostraResumo()} , 50,) //aButtons)

    If n_RetView = 0

        Incluir()

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
    Local a_GatCab         := {}
    Local a_Gatilhos       := {}
    Local n_Atual          := 0
    //Local nLin            := FWSAVEROWS()

    aAdd(a_Cab, {"TMP_OPER"     ,"Operador"     , "C", 6  , 0, .t.,.F.,.F.,.F.,Nil})
    aAdd(a_Cab, {"TMP_NOMEOP"   ,"Nome Operador" , "C"   ,30 , 0, .t.,.F.,.F.,.F.,Nil})

    aAdd(a_Grid, {"TMP_PROJ"     ,"Projeto", "C"   ,10  , 0, .t.,.F.,.F.,.F.,{|oStrGrid| vldProj(oStrGrid)}})
    aAdd(a_Grid, {"TMP_CODPI"    ,"CodeAllegre", "C"   ,15  , 0, .t.,.F.,.F.,.F.,{|oStrGrid| VldCodPI(oStrGrid)}})
    aAdd(a_Grid, {"TMP_COPER"    ,"Código", "C"   ,2  , 0, .t.,.F.,.F.,.F.,{|oStrGrid| vldOper(oStrGrid)}})
    aAdd(a_Grid, {"TMP_DESCR"    ,"Descrição"        , "C"   ,50 , 0, .t.,.F.,.F.,.F.,Nil})
    //aAdd(a_Grid, {"TMP_MOTIMP"   ,"Motivo Improd"        , "C"   ,20 , 0, .f.,.F.,.F.,.F.,Nil})
    aAdd(a_Grid, {"TMP_DTINI"    ,"Data Inicial" ,"D", 8   , 0, .t.,.F.,.F.,.F.,{|oStrGrid|validDtG(oStrGrid)}})
    aAdd(a_Grid, {"TMP_HRINI"    ,"Hora Inicial" ,"C", 5   , 0, .t.,.F.,.F.,.F.,Nil})
    aAdd(a_Grid, {"TMP_DTFIM"    ,"Data Final" ,"D", 8   , 0, .t.,.F.,.F.,.F.,{|oStrGrid|validDtG(oStrGrid)}})
    aAdd(a_Grid, {"TMP_HRFIM"    ,"Hora Final" ,"C", 5   , 0, .t.,.F.,.F.,.F.,Nil})
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
    oStrGrid:AddTable(c_AliasTmp, {'TMP_PROJ', 'TMP_CODPI','TMP_COPER', 'TMP_DESCR','TMP_DTINI','TMP_HRINI','TMP_DTFIM','TMP_HRFIM','TMP_TOTAL'}, "Temporaria")
    
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
        "U_PCPM02G1()",;                                                           //Regra de Preenchimento
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
        "TMP_DESCR",;                                                               //Campo Destino
        "'HORAS IMPRODUTIVAS'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
    )
*/

    aAdd(a_Gatilhos, FWStruTriggger( ;
        "TMP_PROJ",;                                                                  //Campo Origem
        "TMP_CODPI",;                                                               //Campo Destino
        "'HORAIMPRODUTIVA'",;                                                           //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        "Left(TMP_PROJ,3)=='BHI'",;                                                //Condição para execução do gatilho
        "01");                                                                      //Sequência do gatilho
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
        "TMP_DTINI",;                                                                  //Campo Origem
        "TMP_HRINI",;                                                               //Campo Destino
        "U_InHrIni()",;                                                          //Regra de Preenchimento
        .F.,;                                                                       //Irá Posicionar?
        "",;                                                                        //Alias de Posicionamento
        0,;                                                                         //Índice de Posicionamento
        '',;                                                                        //Chave de Posicionamento
        NIL,;                                                                       //Condição para execução do gatilho
        "02");                                                                      //Sequência do gatilho
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
   
    oModel := MPFormModel():New("MIDMAIN", /*bVldPre*/, /*bVldPos*/ /*{||fConfirm()},, {||l_Confirm := .F.,.t.}*/)
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
    Private c_Operador:=CB1->CB1_CODOPE

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

    aAdd(a_CabField, { "TMP_OPER"    ,"01", "Operador"       , "Operador"       	, Nil, "C", "@!"    , Nil, "CB1"	, UserApont(), Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_CabField, { "TMP_NOMEOP"  ,"02", "Nome Operador"  , "Nome Operador"   , Nil, "C", ""      , Nil, ""		, .F.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})

    aAdd(a_GridField, { "TMP_PROJ"   ,"01", "Projeto" 		, "Projeto"   		, Nil, "C", "@!"	, Nil, "XPROJ"	, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_CODPI"  ,"02", "CodeAllegre"	, "CodeAllegre"   	, Nil, "C", "@!"	, Nil, "XCODPI"	, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
//    aAdd(a_GridField, { "TMP_COPER"  ,"03", "Código" 		, "Código"   		, Nil, "C", "@!"	, Nil, "SVI"	, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
 //CRIAR F3 PARA BUSCA DE OPERAÇÃO SHI
//    aAdd(a_GridField, { "TMP_COPER"  ,"03", "Código" 		, "Código"   		, Nil, "C", "@!"	, Nil, "SVI"	, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_COPER"  ,"03", "Código" 		, "Código"   		, Nil, "C", "@!"	, Nil, "XOPER"	, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil ,.f.})
    aAdd(a_GridField, { "TMP_DESCR"  ,"04", "Descrição" 		, "Descrição"      	, Nil, "C", "@!"	, Nil, Nil		, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f. })
    //aAdd(a_GridField, { "TMP_MOTIMP" ,"05", "Motivo Improd" 	, "Motivo Improd"	, Nil, "C", "@S20"	, Nil, Nil		, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f. })
    aAdd(a_GridField, { "TMP_DTINI"  ,"06", "Data Inicial"   , "Data Inicial"   	, Nil, "D", ""      , Nil, ""		, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_HRINI"  ,"07", "Hora Inicial"   , "Hora Inicial"   	, Nil, "C", "99:99" , Nil, ""		, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_DTFIM"  ,"08", "Data Final"   	, "Data Final"   	, Nil, "D", ""      , Nil, ""		, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_HRFIM"  ,"09", "Hora Final"   	, "Hora Final"   	, Nil, "C", "99:99" , Nil, ""		, .T.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.f.})
    aAdd(a_GridField, { "TMP_TOTAL"  ,"10", "Total Horas"   	, "Total Horas"   	, Nil, "C", ""  	, Nil, ""		, .F.		 , Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil,.T.})
                                            
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
   
    oModel := FWLoadModel("FSPCPM02")
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


/*/{Protheus.doc} PCPM02G1
Função Responsável por gatilhar a informação de descrição da operação
@type function
@author Silvio Nogueira
@since 24/09/2025
@version 01
/*/
user function PCPM02G1()
    Local a_Area     := FwGetArea()
    Local oModelMVC := FWModelActive()
    Local c_Prod     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")
    Local c_Proj     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local c_Codigo   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
    Local c_Desc     := ""
    Local c_ProjImp  := SuperGetMv("MV_XPRJIMP",.F.,'BHI')

    If Left(c_Proj,3) <> Left(c_ProjImp,3)

        c_Operac    := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
    
        c_Desc    := Posicione("SG2",1,FWxFilial("SG2") + c_Prod + c_Operac + c_Codigo , "G2_DESCRI")

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

    c_Alias 	:= MPSysOpenQuery( c_Qry )

    If (Empty(c_Projeto) .Or. (c_Alias)->(Eof())) .And. Left(c_Projeto,3) <> 'BHI'

        FWALERTERROR("O Projeto digitado não está vinculado a nenhum Pedido de Venda.", "Projeto Inválido!")
        l_Ret := .f.

    Endif

    (c_Alias)->(dbCloseArea())


return l_Ret


// Função para validar o campo Código de Operação digitado no grid X projeto
Static function vldOper(oModel)
    Local oModelMVC := FWModelActive()
    Local a_Area     := FwGetArea()
    Local l_Ret      := .t.
    Local cProj     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local c_Prod     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")
    Local c_Codigo   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
    Local c_PI
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
    
        c_Operac    := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
        
        dbSelectArea("SG2")
    
        
        If SG2->(!MsSeek(FWxFilial("SG2") + c_Prod + c_Operac + c_Codigo ))
    
            FWALERTERROR("A Operação digitada não faz parte do roteiro cadastrado para esse produto.", "Operação Inválida!")
            l_Ret := .f.
    
        Else
        
            c_PI := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo,"VI_XPI")
    
            If c_PI == 'I' .And. Left(cProj,3) <> 'BHI' // Valida se operação é improdutiva e verifica projeto digitado.
    
                FWALERTERROR("A Operação se refere a horas improdutivas. Corrigir o projeto digitado.(BHImmaaaa)", "Operação Inválida!")
                l_Ret := .f.
    
            Endif
            If c_PI <> 'I' .And. Left(cProj,3) == 'BHI'  .And. l_Ret // Valida se operação é produtiva e verifica projeto digitado.
    
                FWALERTERROR("A Operação se refere a horas produtivas. Corrigir o projeto digitado.", "Operação Inválida!")
                l_Ret := .f.
    
            Endif
    
        Endif
    
        if (c_Alias)->(Eof())  .And. l_Ret
            FWALERTERROR("A Operação digitada não pertence ao centro custo desse operador.", "Operação Inválida!")
            l_Ret := .f.
        endif

    Endif

    FWRestArea(a_Area)

return l_Ret

Static Function xIncluir()
    Local oModelMVC   := FWModelActive()
    Local n_X

    BEGIN TRANSACTION

    dbSelectArea("Z01")
    Z01->(DbSetOrder(1))

    for n_X:=1 to oModelMVC:GetModel("GRIDID"):Length()

            oModelMVC:GetModel("GRIDID"):GoLine(n_X)
            Reclock("Z01",.t.)
            Z01->Z01_FILIAL := cFilAnt
            Z01->Z01_OPER   := oModelMVC:GetModel("CABID"):GetValue("TMP_OPER")
            Z01->Z01_PROJ   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
            Z01->Z01_CODPI   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")
            Z01->Z01_COPER   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
            Z01->Z01_DESCR   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DESCR")
            Z01->Z01_DTINI   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
            Z01->Z01_DTFIM   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
            Z01->Z01_HRINI   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRINI")
            Z01->Z01_HRFIM   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")
            Z01->Z01_TOTAL   := oModelMVC:GetModel("GRIDID"):GetValue("TMP_TOTAL")
            //Z01->Z01_MTIMPP  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_MOTIMP")

            Z01->(MsUnlock())

    Next
    
    END TRANSACTION 

Return .t.


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


// Função para calcular total de Horas que será mostrada no grid da tela principal em tempo de execução
User Function calctoth()

    Local oModelMVC := FWModelActive()
    Local d_DataIni  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
    Local c_HoraIni  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRINI")
    Local d_DataFim  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")
    Local c_HoraFim  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")
    Local n_TotCalc  := 0

    If !Empty(d_DataIni) .And. !Empty(c_HoraIni) .And. !Empty(d_DataFim) .And. !Empty(c_HoraFim)

        n_TotCalc := SubtHoras(d_DataIni, c_HoraIni, d_DataFim, c_HoraFim, .T.)

    Endif

Return(cValToChar(Round(n_TotCalc,2)))

Static Function Cancelar()

    Local l_Ret

    l_Ret := oModelMVC():CancelData()

Return l_Ret


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
User Function CalcHr(cCodCal,aDias)

    Local n_TotHoras := 0
    Local c_Aloc
    Local n_Dias
    Local a_AlocDia := {}
    Local n_It
    Local n_Diasemana
    Local n_TotHrDia

    c_Aloc    := Left(Posicione("SH7",1,FWxFilial("SH7") + cCodCal,"H7_ALOC"),672)

    // dia 1 representa segunda-feira na alocação
    For n_Dias := 1 to 7

        If n_Dias = 1

            n_TotHrDia := U_CalcHrDia(Substring(c_Aloc,1+(96*6),96))
            //n_TotHrDia := U_CalcHrDia(Substring(c_Aloc,1,96))
            Aadd(a_AlocDia,n_TotHrDia) //Segunda-feira

        Else

            n_TotHrDia := U_CalcHrDia(Substring(c_Aloc,1+(96*(n_Dias-2)),96))
            Aadd(a_AlocDia,n_TotHrDia) //Terça-feira a Domingo

        Endif

    Next

    For n_It := 1 to len(aDias)

        n_Diasemana := Dow(aDias[n_It])
        n_TotHoras += a_AlocDia[n_Diasemana]
    
    Next

Return n_TotHoras


// Função para Calcular Horas Devidas dos dias da semana
User Function CalcHrDia(c_Palavra)

    Local n_Atual
    Local n_Vezes    := 0
    Local c_Caracter := "X"
    Local n_HorasD   := 0

    //Percorre todas as letras da palavra
    For n_Atual := 1 To Len(c_Palavra)
        //Se a posição atual for igual ao caracter procurado, incrementa o valor
        If SubStr(c_Palavra, n_Atual, 1) == c_Caracter
            n_Vezes++
        EndIf
    Next

    n_HorasD := n_Vezes * 0.25

Return n_HorasD

// Função para mostrar o resumo do apontamento antes da confirmação para gravação dos dados
Static Function MostraResumo()

    Local a_Area      := FwGetArea()
    Local oModelMVC := FWModelActive()
    Local n_X
    Local a_Datas := {}
    Local d_Data
    Local n_HorasTrab := 0
    Local nHorasImpr := 0 
    Local n_TotHoras  :=0
    Local c_FontNome   := 'Tahoma'
    Local oFontPadrao := TFont():New(c_FontNome, , -20)
    Local c_Prod
    Local c_Codigo
    Local c_Operac
    Local c_PI
    Local l_Ret := .t.
    Local n_TotReg   := oModelMVC:GetModel("GRIDID"):Length()
    Local l_CalPad   := If(SH7->(MsSeek(FWxFilial("SH7") + c_CalPad )),.T.,.F.)

    If Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")) .And. ;
        Empty(oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")) .And.;
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
                If aScan(a_Datas, d_Data) = 0 .And. !Empty(d_Data)

                    Aadd(a_Datas,d_Data)

                Endif

                d_Data := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")
                If aScan(a_Datas, d_Data) = 0 .And. !Empty(d_Data)

                    Aadd(a_Datas,d_Data)

                Endif

                c_Prod       := oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")
                c_Codigo     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")
                c_Operac     := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
                c_PI         := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo,"VI_XPI")

                If c_PI == 'I'

                    nHorasImpr += Val(oModelMVC:GetModel("GRIDID"):GetValue("TMP_TOTAL"))

                Else

                    n_HorasTrab += Val(oModelMVC:GetModel("GRIDID"):GetValue("TMP_TOTAL"))

                Endif

        Next

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
    oModal:addOkButton({||FWMsgRun(, {|| l_Ret ,oModal:OOWNER:END() }, "Processando", "Realizando Apontamento")}, "Apontar", , ) 

    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    TSay():New(015,005,{|| "Calendário Padrão : (" + If(l_CalPad,c_CalPad,"NÃO CADASTRADO") + ")"},oContainer,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,150,20,,,,,,.T.)

    TSay():New(025,005,{|| "Horas Devidas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(025,120,{|| cValToChar(Round(n_TotHoras,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    TSay():New(045,005,{|| "Horas Trabalhadas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(045,120,{|| cValToChar(Round(n_HorasTrab,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    TSay():New(065,005,{|| "Horas Improdutivas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(065,120,{|| cValToChar(Round(nHorasImpr,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    TSay():New(085,005,{|| "Horas Não Apontadas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    TSay():New(085,120,{|| cValToChar(Round(If(n_TotHoras - n_HorasTrab - nHorasImpr < 0 , 0 ,n_TotHoras - n_HorasTrab - nHorasImpr),2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
 
    oModal:Activate()

    oModal:DeActivate()

    FWRestArea(a_Area)

Return l_Ret

// Ponto de Entrada do Browse para ser utilizado caso necessário
User Function MIDMAIN()

    Local l_Ret := .T.
    //Local oModel := PARAMIXB[1]
    Local c_IdPonto := PARAMIXB[2]
    //Local c_Prod
    //Local c_Codigo
    //Local c_PI
    //Local c_MotImp
    //Local c_Operac

    /*
    If c_IdPonto == "FORMLINEPOS"

        c_Prod     := oModel:GetValue("TMP_CODPI")
        c_Codigo   := oModel:GetValue("TMP_COPER")
        c_MotImp   := oModel:GetValue("TMP_MOTIMP")

        c_Operac   := Posicione("SB1",1,FWxFilial("SB1") + c_Prod,"B1_OPERPAD")
    
        c_PI         := Posicione("SVI",1,FWxFilial("SVI") + c_Codigo,"VI_XPI")

        If c_PI == 'I' .And. Empty(c_MotImp)

            FWALERTERROR("A Operação digitada é Improdutiva e deve ter o motivo digitado.", "Motivo não Preenchido!")
            l_Ret := .F.

        Endif
    */
    If c_IdPonto == "BUTTONBAR"

        //l_Ret := {{"Apontamentos do dia", "Apontamentos do dia", {||u_FSPCPM05(CB1->CB1_CODOPE)}}}
        l_Ret := {{"Apontamentos do dia", "Apontamentos do dia", {||u_FSPCPM07()}}}
 
    Endif
 
Return l_Ret

User Function F3Proj()
        Local oModelMVC := FWModelActive()
    Local oListBox
    Local l_Ok      := .F.
    Local oQryC
    Local c_Alias
    Local oDlg
    Local oPanel
    Local a_Campos   := {}
    Local b_BlocoOk     := {|| l_Ok := .T., c_Codigo := (c_AliasT)->PROJETO, oDlg:End()}
    Local b_BlocoCan    := {|| l_Ok := .F., oDlg:End()}
    Local b_BlocoIni    := {|| EnchoiceBar(oDlg, b_BlocoOk, b_BlocoCan, , )}
    Local d_Dia01
    Local a_SeekTmp := {;	
                        {"Projeto"		  	,{{"",;
                                               FwGetSx3Cache('C5_XPROJET','X3_TIPO'),; 
                                               FwGetSx3Cache('C5_XPROJET','X3_TAMANHO'),;
                                               0,; 
                                               "C5_XPROJET"		,; 
                                               FwGetSx3Cache('C5_XPROJET','X3_PICTURE');	
                                               },;
                                               {"",;
                                               FwGetSx3Cache('A1_NREDUZ','X3_TIPO'),; 
                                               FwGetSx3Cache('A1_NREDUZ','X3_TAMANHO'),;
                                               0,; 
                                               "A1_NREDUZ"		,; 
                                               FwGetSx3Cache('A1_NREDUZ','X3_PICTURE');	
                                               };
                                            };
                            };
                    }

    Private c_Codigo
    Private c_AliasT   := GetNextAlias()

    If oQryC == Nil

        c_Qry := "SELECT C5_XPROJET,A1_NREDUZ FROM ? SC5 "
        c_Qry += "INNER JOIN ? SA1 ON A1_FILIAL = '?' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = '' "
        c_Qry += "WHERE C5_FILIAL = '?' AND C5_XPROJET <> '' AND SC5.D_E_L_E_T_ = '' "
        c_Qry += "GROUP BY C5_XPROJET, A1_NREDUZ "
        c_Qry += "ORDER BY C5_XPROJET "

        c_Qry := ChangeQuery(c_Qry)
        oQryC := FWPreparedStatement():New(c_Qry)

    EndIf

    oQryC:SetUnsafe(1, RetSqlName( "SC5" ))
    oQryC:SetUnsafe(2, RetSqlName( "SA1" ))
    oQryC:SetUnsafe(3, xFilial("SA1"))
    oQryC:SetUnsafe(4, xFilial("SC5"))

    c_Qry 	:= oQryC:GetFixQuery()

    c_Alias 	:= MPSysOpenQuery( c_Qry )


    //Adiciona as colunas que serão criadas na temporária
    aAdd(a_Campos, { 'PROJETO'   , 'C', 10, 0}) 
    aAdd(a_Campos, { 'DESCRICAO', 'C', 20, 0})

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(c_AliasT)
    oTempTable:SetFields( a_Campos )
    oTempTable:AddIndex("1", {"PROJETO"} )
    oTempTable:AddIndex("2", {"DESCRICAO"} )
    oTempTable:Create()  
 
    //Popula a tabela temporária

    (c_Alias)->(dbGotop())

    While !(c_Alias)->(Eof())

        RecLock(c_AliasT,.T.)
        (c_AliasT)->PROJETO    := (c_Alias)->C5_XPROJET
        (c_AliasT)->DESCRICAO  := (c_Alias)->A1_NREDUZ

        (c_Alias)->(dbSkip())

    Enddo

    RecLock(c_AliasT,.T.)
    (c_AliasT)->PROJETO    := 'BHI'+StrZero(month(dDatabase),2)+Str(Year(dDatabase),4)
    (c_AliasT)->DESCRICAO  := 'HORAS IMPRODUTIVAS DE "+StrZero(month(dDatabase),2)+"/"+Str(Year(dDatabase),4)

    d_Dia01 := Ctod("01/"+StrZero(month(dDatabase),2)+"/"+Str(Year(dDatabase),4))-1

    RecLock(c_AliasT,.T.)
    (c_AliasT)->PROJETO    := 'BHI'+StrZero(month(d_Dia01),2)+Str(Year(d_Dia01),4)
    (c_AliasT)->DESCRICAO  := 'HORAS IMPRODUTIVAS DE "+StrZero(month(d_Dia01),2)+"/"+Str(Year(d_Dia01),4)

    //Adiciona as colunas
    a_Colunas := fCriaCols()

    DEFINE MSDIALOG oDlg FROM 00,00 TO 290,490 PIXEL TITLE OemToAnsi("Pesquisa"/*STR0320*/) //"Pesquisa"

    oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    oListBox := FWBrowse():New()
    oListBox:SetSeek(,a_SeekTmp)
    oListBox:SetAlias(c_AliasT)
    oListBox:SetColumns(a_Colunas)
    oListBox:SetDataTable()    
    oListBox:SetOwner(oPanel)
    oListBox:DisableConfig()
    oListBox:DisableReport()
    oListBox:SetDoubleClick(b_BlocoOk)

    oListBox:Activate()

    oDlg:Activate(, , , .T., , , b_BlocoIni)

    If l_Ok

        oModelMVC:SetValue('GRIDID','TMP_PROJ',c_Codigo)
        M->TMP_PROJ := c_Codigo

    EndIf

Return l_Ok


Static function fCriaCols()
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

    aAdd(a_Estrut, { 'PROJETO','Projeto'    ,'C', 15, 0,'',.F.}) 
    aAdd(a_Estrut, { 'DESCRICAO','Descrição'  ,'C', 20, 0,'',.F.})

    for n_X:=1 to len(a_Estrut)
        //Cria as colunas
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + c_AliasT + '->' + a_Estrut[n_X][1] +'}')) 
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


Static Function Incluir()

    BEGIN TRANSACTION

    dbSelectArea("Z01")
    Z01->(DbSetOrder(1))

    (c_AliasTmp)->(dbGotop())

    While !(c_AliasTmp)->(Eof())

            Reclock("Z01",.t.)
            Z01->Z01_FILIAL := cFilAnt
            Z01->Z01_OPER   := (c_AliasTmp)->TMP_OPER
            Z01->Z01_PROJ   := (c_AliasTmp)->TMP_PROJ
            Z01->Z01_CODPI   := (c_AliasTmp)->TMP_CODPI
            Z01->Z01_COPER   := (c_AliasTmp)->TMP_COPER
            Z01->Z01_DESCR   := (c_AliasTmp)->TMP_DESCR
            Z01->Z01_DTINI   := (c_AliasTmp)->TMP_DTINI
            Z01->Z01_DTFIM   := (c_AliasTmp)->TMP_DTINI
            Z01->Z01_HRINI   := (c_AliasTmp)->TMP_HRINI
            Z01->Z01_HRFIM   := (c_AliasTmp)->TMP_HRFIM
            Z01->Z01_TOTAL   := Val((c_AliasTmp)->TMP_TOTAL)
            //Z01->Z01_MTIMPP  := (c_AliasTmp)->TMP_MOTIMP
            Z01->Z01_DTAPON  := dDatabase

            Z01->(MsUnlock())

            (c_AliasTmp)->(dbSkip())

    Enddo

    END TRANSACTION 
    
Return .t.



Static function vldCodPI(oModel)
    Local oModelMVC := FWModelActive()
    Local a_Area     := FwGetArea()
    Local l_Ret      := .t.
    Local c_CodPI    := oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")
    Local c_Projeto  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local oQryC

    SB1->(dbSetOrder(1))
    If SB1->(!MsSeek(FWxFilial("SB1") + c_CodPI ))

        l_Ret := .F.

    Endif

    If Left(c_Projeto,3) == 'BHI'

       l_Ret := .t.
       Return l_Ret

    Endif

    If Left(c_Projeto,3) <> 'BHI' .And. l_Ret

        // Select no SC6 para todos os itens dos PVs relacionados ao projeto digitado (C5_XPROJET)
        // Select no SG1 para todos os itens encontrados no PV

        If oQryC == Nil

            c_Qry := "SELECT G1_COMP FROM ? SG1 WHERE G1_FILIAL = '?' AND G1_COD IN "
            c_Qry += "(SELECT C6_PRODUTO FROM ? SC6 "
            c_Qry += "INNER JOIN ? SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM  AND C5_XPROJET = ? AND SC5.D_E_L_E_T_ = ''"
            c_Qry += "WHERE SC6.D_E_L_E_T_ = ' ') "
            //c_Qry += "AND SG1.D_E_L_E_T_ = '' AND G1_COMP = ?"
            c_Qry += "AND SG1.D_E_L_E_T_ = '' "

            c_Qry := ChangeQuery(c_Qry)
            oQryC := FWPreparedStatement():New(c_Qry)

        EndIf

        oQryC:SetUnsafe(1, RetSqlName("SG1"))
        oQryC:SetUnsafe(2, xFilial("SG1"))
        oQryC:SetUnsafe(3, RetSqlName("SC6"))
        oQryC:SetUnsafe(4, RetSqlName("SC5"))
        oQryC:SetString(5, c_Projeto)
        //oQryC:SetString(6, c_CodPI)

        c_Qry 	:= oQryC:GetFixQuery()

        c_Alias 	:= MPSysOpenQuery( c_Qry )

        If (c_Alias)->(Eof())

            FWALERTERROR("Código digitado não pertence à nenhuma estrutura de produto referente ao projeto/pedido venda respectivo.", "CodeAllegre Inválido!")
            l_Ret := .f.

        EndIf

        (c_Alias)->(dbCloseArea())

    Endif

    FWRestArea(a_Area)

Return l_Ret

// Função para validar o usuário conectado se ele pertence aos operadores master
// Caso sim, libera o campo para mudança, caso não, 
//traz o campo preenchido com o o código do operador respectivo.
Static Function UserApont()
    Local l_Ret  := .T.
    Local c_OpMaster := SuperGetMv("MV_FS_OPER",.F.,"admin")

    If cUserName $ c_OpMaster

        l_Ret := .T.

    Else
    
        l_Ret := .F.

    Endif

Return l_Ret

Static Function ListaApont()

    Local a_Area      := FwGetArea()
    Local c_Qry
    Local o_QryC
    Local c_Alias
    Local d_Data
    Local o_ModelMVC := FWModelActive()
    Local c_Oper
    Local c_NomeOP
    Local n_Lin
    Local o_Modal
    Local o_Container
    Local l_Ret

    c_Oper  :=  o_ModelMVC:GetModel("CABID"):GetValue("TMP_OPER")
    d_Data  :=  o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")

    If o_QryC == Nil
        c_Qry := "SELECT Z01_PROJ,Z01_COPER,Z01_DESCR,Z01_DTINI,Z01_DTFIM,Z01_HRINI,Z01_HRFIM,Z01_TOTAL,Z01_DTAPON FROM ? Z01 "
        c_Qry += "WHERE D_E_L_E_T_ = '' "
        c_Qry += "AND (Z01_DTINI = ? OR Z01_DTFIM = ?) "
        c_Qry += "AND Z01_OPER = ? "
        c_Qry += "ORDER BY Z01_DTINI,Z01_HRINI"
        c_Qry := ChangeQuery(c_Qry)
        o_QryC := FWPreparedStatement():New(c_Qry)
    EndIf

    o_QryC:SetUnsafe(1, RetSqlName("Z01"))
    o_QryC:SetString(2, Dtos(d_Data) )
    o_QryC:SetString(3, Dtos(d_Data) )
    o_QryC:SetString(4, c_Oper )

    c_Qry 	:= o_QryC:GetFixQuery()
    c_Alias := MPSysOpenQuery( c_Qry )

    c_NomeOP := Posicione("CB1",1,FWxFilial("CB1") + c_Oper,"CB1_NOME")

    o_Modal  := FWDialogModal():New()      
    o_Modal:SetEscClose(.T.)
    o_Modal:setTitle("Histórico de Apontamento do dia : " + Dtoc(d_Data) + " do Operador " + c_NomeOP)
      
    //Seta a altura e largura da janela em pixel
    o_Modal:setSize(270, 500)
 
    o_Modal:createDialog()

    o_Modal:addCloseButton({|| l_Ret := .F.,o_Modal:OOWNER:END()}, "Fechar")
    //o_Modal:addOkButton({||FWMsgRun(, {|| Incluir(o_Modal) }, "Processando", "Realizando Apontamento")}, "Apontar", , ) 
    //o_Modal:addOkButton({||FWMsgRun(, {|| l_Ret ,o_Modal:OOWNER:END() }, "Processando", "Realizando Apontamento")}, "Apontar", , ) 

    o_Container := TPanel():New( ,,, o_Modal:getPanelMain() )
    o_Container :Align := CONTROL_ALIGN_ALLCLIENT

    n_Lin := 025

    TSay():New(n_Lin,005,{|| "Projeto Operação Descr Operação             Data Inicial  Hora Inicial  Data Final  Hora Final  Total  Data Apont"},o_Container,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,300,100,,,,,,.T.)

    n_Lin += 10

    (c_Alias)->(dbGotop())


    
    //Do While !(c_Alias)->(Eof())

        TSay():New(n_Lin,005,{|| (c_Alias)->Z01_PROJ},o_Container,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,300,100,,,,,,.T.)

        //TSay():New(n_Lin,005,{|| (c_Alias)->Z01_PROJ + "  " +(c_Alias)->Z01_COPER + "  " + (c_Alias)->Z01_DESCR + "  " + Dtoc(Stod((c_Alias)->Z01_DTINI)) + "  " + (c_Alias)->Z01_HRINI  + "  " + Dtoc(Stod((c_Alias)->Z01_DTFIM)) + "  " + (c_Alias)->Z01_HRFIM + "  " + Str((c_Alias)->Z01_TOTAL,6,2) + "  " + Dtoc(Stod((c_Alias)->Z01_DTAPON))},o_Container,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,300,100,,,,,,.T.)
    //    TSay():New(n_Lin,005,{|| (c_Alias)->Z01_PROJ },o_Container,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,300,100,,,,,,.T.)

        n_Lin += 10

        (c_Alias)->(dbSkip())

        TSay():New(n_Lin,005,{|| (c_Alias)->Z01_PROJ},o_Container,/*c_PIcture*/,/*oFontPadrao*/,,,,.T.,,,300,100,,,,,,.T.)


    //Enddo

    //TSay():New(025,005,{|| "Horas Devidas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    //TSay():New(025,120,{|| cValToChar(Round(n_TotHoras,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    //TSay():New(045,005,{|| "Horas Trabalhadas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    //TSay():New(045,120,{|| cValToChar(Round(n_HorasTrab,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    //TSay():New(065,005,{|| "Horas Improdutivas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    //TSay():New(065,120,{|| cValToChar(Round(nHorasImpr,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)

    //TSay():New(085,005,{|| "Horas Não Apontadas"},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
    //TSay():New(085,120,{|| cValToChar(Round(n_TotHoras - n_HorasTrab - nHorasImpr,2))},oContainer,/*c_PIcture*/,oFontPadrao,,,,.T.,,,100,20,,,,,,.T.)
 
    o_Modal:Activate()

    o_Modal:DeActivate()

    (c_Alias)->(dbCloseArea())

    FWRestArea(a_Area)

Return l_Ret


User Function F3CodPI()
    Local oModelMVC := FWModelActive()
    Local c_Projeto     := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local oListBox
    Local l_Ok      := .F.
    Local oQryC
    Local c_Alias
    Local oDlg
    Local oPanel
    Local a_Campos   := {}
    Local b_BlocoOk     := {|| l_Ok := .T., c_Codigo := (c_AliasT)->CODIGO, oDlg:End()}
    Local b_BlocoCan    := {|| l_Ok := .F., oDlg:End()}
    Local b_BlocoIni    := {|| EnchoiceBar(oDlg, b_BlocoOk, b_BlocoCan, , )}
    Local a_SeekTmp := {;	
                        {"Code Allegre"		  	,{{"",;
                                               FwGetSx3Cache('B1_COD','X3_TIPO'),; 
                                               FwGetSx3Cache('B1_COD','X3_TAMANHO'),;
                                               0,; 
                                               "CODIGO"		,; 
                                               FwGetSx3Cache('B1_COD','X3_PICTURE');	
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

    Private c_Codigo
    Private c_AliasT   := GetNextAlias()

       If oQryC == Nil
        c_Qry := "SELECT B1_COD [CODIGO],B1_DESC [DESC],B1_TIPO [TIPO] FROM ? SB1 "
        c_Qry += "INNER JOIN ("
        c_Qry += "SELECT G1_COMP FROM ? SG1 WHERE G1_FILIAL = '?' AND G1_COD IN "
        c_Qry += "(SELECT C6_PRODUTO FROM ? SC6 "
        c_Qry += "INNER JOIN ? SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM  AND C5_XPROJET = ? AND SC5.D_E_L_E_T_ = ''"
        c_Qry += "WHERE SC6.D_E_L_E_T_ = ' ') "
        c_Qry += "AND SG1.D_E_L_E_T_ = '' ) TMP ON SB1.B1_FILIAL = '?' AND TMP.G1_COMP = SB1.B1_COD "
        c_Qry += " WHERE SB1.D_E_L_E_T_ = '' "
        c_Qry += "ORDER BY B1_COD "
        c_Qry := ChangeQuery(c_Qry)
        oQryC := FWPreparedStatement():New(c_Qry)
    EndIf

    oQryC:SetUnsafe(1, RetSqlName("SB1"))
    oQryC:SetUnsafe(2, RetSqlName("SG1"))
    oQryC:SetUnsafe(3, xFilial("SG1"))
    oQryC:SetUnsafe(4, RetSqlName("SC6"))
    oQryC:SetUnsafe(5, RetSqlName("SC5"))
    oQryC:SetString(6, c_Projeto)
    oQryC:SetUnsafe(7, xFilial("SB1"))

    c_Qry 	:= oQryC:GetFixQuery()

    c_Alias 	:= MPSysOpenQuery( c_Qry )

    //Adiciona as colunas que serão criadas na temporária
    aAdd(a_Campos, { 'CODIGO'   , 'C', FwGetSx3Cache('B1_COD','X3_TAMANHO'), 0}) 
    aAdd(a_Campos, { 'DESCRICAO', 'C', FwGetSx3Cache('B1_DESC','X3_TAMANHO'), 0})
    aAdd(a_Campos, { 'TIPO', 'C', FwGetSx3Cache('B1_TIPO','X3_TAMANHO'), 0})

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(c_AliasT)
    oTempTable:SetFields( a_Campos )
    oTempTable:AddIndex("1", {"CODIGO"} )
    oTempTable:AddIndex("2", {"DESCRICAO"} )
    oTempTable:Create()  
 
    //Popula a tabela temporária
    (c_Alias)->(dbGotop())

    While !(c_Alias)->(Eof())

        RecLock(c_AliasT,.T.)
        (c_AliasT)->CODIGO    := (c_Alias)->CODIGO
        (c_AliasT)->DESCRICAO  := (c_Alias)->DESC
        (c_AliasT)->TIPO       := (c_Alias)->TIPO

        (c_Alias)->(dbSkip())

    Enddo

    //Adiciona as colunas
    a_Colunas := fCriaCols3()

    DEFINE MSDIALOG oDlg FROM 00,00 TO 290,490 PIXEL TITLE OemToAnsi("Pesquisa"/*STR0320*/) //"Pesquisa"

    oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    oListBox := FWBrowse():New()
    oListBox:SetSeek(,a_SeekTmp)
    oListBox:SetAlias(c_AliasT)
    oListBox:SetColumns(a_Colunas)
    oListBox:SetDataTable()    
    oListBox:SetOwner(oPanel)
    oListBox:DisableConfig()
    oListBox:DisableReport()
    oListBox:SetDoubleClick(b_BlocoOk)

    oListBox:Activate()

    oDlg:Activate(, , , .T., , , b_BlocoIni)

    If l_Ok

        oModelMVC:SetValue('GRIDID','TMP_CODPI',c_Codigo)
        M->TMP_CODPI := c_Codigo

    EndIf


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

    aAdd(a_Estrut, { 'CODIGO','Code Allegre'    ,'C', FwGetSx3Cache('B1_COD','X3_TAMANHO'), 0,'',.F.}) 
    aAdd(a_Estrut, { 'DESCRICAO','Descrição'  ,'C', FwGetSx3Cache('B1_DESC','X3_TAMANHO'), 0,'',.F.})
    aAdd(a_Estrut, { 'TIPO','Tipo'  ,'C', FwGetSx3Cache('B1_TIPO','X3_TAMANHO'), 0,'',.F.})

    for n_X:=1 to len(a_Estrut)
        //Cria as colunas
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + c_AliasT + '->' + a_Estrut[n_X][1] +'}')) 
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



Static function fCriaColsOper3()
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

    //Adiciona as colunas que serão criadas na temporária
    aAdd(a_Estrut, { 'CODIGO'    ,'Código', 'C', FwGetSx3Cache('G2_CODIGO','X3_TAMANHO'), 0,'',.F.}) 
    aAdd(a_Estrut, { 'PRODUTO'   ,'Cod. Produto', 'C', FwGetSx3Cache('G2_PRODUTO','X3_TAMANHO'), 0,'',.F.})
    aAdd(a_Estrut, { 'DESCRICAO' ,'Descrição', 'C', FwGetSx3Cache('G2_DESCRI','X3_TAMANHO'), 0,'',.F.})
    aAdd(a_Estrut, { 'OPERACAO'  ,'Operação', 'C', FwGetSx3Cache('G2_OPERAC','X3_TAMANHO'), 0,'',.F.})

    for n_X:=1 to len(a_Estrut)
        //Cria as colunas
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + c_AliasT + '->' + a_Estrut[n_X][1] +'}')) 
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


User Function InHrIni()
    Local oModelMVC := FWModelActive()
    Local oQryC

    Local c_HrIni
    Local l_Ret := .T.
    Local n_TotReg  := oModelMVC:GetModel("GRIDID"):Length()
    Local d_DtDig   := DTOS(oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI"))
    Local a_Area     := FwGetArea()
    Local c_Alias
    Local n_Line      := FWSaveRows()
    Local d_DataIni  :=  ''
    Local c_PROJ  := ''
    Local c_COPER  := ''
    Local n_It


    If n_Line[1][2] > 1
        l_Ret := .T.
    Endif


    If l_Ret

        /*
        ------------------------------------------------------------------
        Localiza no Grid a maior hora final da data digitada
        ------------------------------------------------------------------
        */

        For n_It := 1 to n_TotReg

    	    oModelMVC:GetModel("GRIDID"):GoLine(n_It)

            If oModelMVC:GetModel("GRIDID"):IsDeleted()
                Loop
            Endif
            
            If dtos(oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTFIM")) == d_DtDig .And. oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM") > c_Hrini
                c_Hrini := oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")
                l_Ret:= .f.
            Endif

        Next

        FWRestArea(a_Area)

        if l_Ret
            /*
            ------------------------------------------------------------------
            Localiza na tabela Z01 a maior hora final da data digitada
            ------------------------------------------------------------------
            */

            c_Alias := GetNextAlias()

            d_DataIni  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
            c_PROJ  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
            c_COPER  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_COPER")

            If oQryC == Nil

                c_Qry:= " SELECT Z01_OPER,Z01_PROJ,Z01_COPER,Z01_DTINI,MAX(Z01_HRFIM) Z01_HRFIM FROM ?  " + CRLF
                c_Qry+= " WHERE  " 
                c_Qry+= "      Z01_FILIAL='?' AND " + CRLF
                c_Qry+= "      Z01_PROJ  ='?' AND " + CRLF
                c_Qry+= "      Z01_COPER ='?' AND " + CRLF
                c_Qry+= "      Z01_DTINI ='?' " + CRLF
                c_Qry+= " GROUP BY Z01_OPER,Z01_PROJ,Z01_COPER,Z01_DTINI "

            EndIf

            c_Qry := ChangeQuery(c_Qry)
            
            oQryC := FWPreparedStatement():New( c_Qry )
            oQryC:SetUnsafe(1, RetSqlName("Z01"))
            oQryC:SetUnsafe(2, cFilAnt) 
            oQryC:SetUnsafe(3, c_PROJ) 
            oQryC:SetUnsafe(4, c_COPER) 
            oQryC:SetUnsafe(5, dtos(d_DataIni)) 

            c_Qry 	:= oQryC:GetFixQuery()
            c_Alias := MPSysOpenQuery( c_Qry )

            If (c_Alias)->(!Eof())

                c_HrIni := (c_Alias)->Z01_HRFIM

            Endif

            (c_Alias)->(dbCloseArea())
            oQryC:= Nil

            /*
            ------------------------------------------------------------------
            Localiza na tabela SH6 a maior hora final da data digitada
            ------------------------------------------------------------------
            */

            c_Alias := GetNextAlias()
        
            If oQryC == Nil

                c_Qry := "SELECT MAX(H6_HORAFIN) H6_HORAFIN FROM ? SH6 "
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

            If (c_Alias)->(!Eof()) .AND. !Empty((c_Alias)->H6_HORAFIN)

                c_HrIni := (c_Alias)->H6_HORAFIN

            Endif

            (c_Alias)->(dbCloseArea())

        Endif
    ENDIF

//    c_HrIni := If(Substring(c_HrIni,4,2) == '59',StrZero(Val(Left(c_HrIni,2))+1,2) +':'+'00', Left(c_HrIni,2) + ':' + Strzero(Val(Substring(c_HrIni,4,2))+1,2))
    c_HrIni := SubStr(IncTime(c_HrIni,0,1,0),1,5)

Return c_HrIni

User Function F3Oper()
    Local oModelMVC := FWModelActive()
    Local c_Projeto  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_PROJ")
    Local oListBox
    Local l_Ok      := .F.
    Local oQryC
    Local c_Alias
    Local oDlg
    Local oPanel
    Local c_Prod
    Local a_Campos   := {}
    Local b_BlocoOk     := {|| l_Ok := .T., c_Codigo := (c_AliasT)->OPERACAO, oDlg:End()}
    Local b_BlocoCan    := {|| l_Ok := .F., oDlg:End()}
    Local b_BlocoIni    := {|| EnchoiceBar(oDlg, b_BlocoOk, b_BlocoCan, , )}
    Local a_SeekTmp := {;	
                        {"Operação"	,{{"",;
                                               FwGetSx3Cache('G2_OPERAC','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_OPERAC','X3_TAMANHO'),;
                                               0,; 
                                               "Operação"		,; 
                                               FwGetSx3Cache('G2_OPERAC','X3_PICTURE');	
                                        },;
                                        {"",;
                                               FwGetSx3Cache('G2_CODIGO','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_CODIGO','X3_TAMANHO'),;
                                               0,; 
                                               "Código"		,; 
                                               FwGetSx3Cache('G2_CODIGO','X3_PICTURE');	
                                        },;
                                        {"",;
                                               FwGetSx3Cache('G2_PRODUTO','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_PRODUTO','X3_TAMANHO'),;
                                               0,; 
                                               "Produto"		,; 
                                               FwGetSx3Cache('G2_PRODUTO','X3_PICTURE');	
                                        },;
                                        {"",;
                                               FwGetSx3Cache('G2_DESCRI','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_DESCRI','X3_TAMANHO'),;
                                               0,; 
                                               "Descrição"		,; 
                                               FwGetSx3Cache('G2_DESCRI','X3_PICTURE');	
                                        };
                                    };
                        },;
                        {"Produto"	,{{"",;
                                               FwGetSx3Cache('G2_PRODUTO','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_PRODUTO','X3_TAMANHO'),;
                                               0,; 
                                               "Produto"		,; 
                                               FwGetSx3Cache('G2_PRODUTO','X3_PICTURE');	
                                        },;
                                        {"",;
                                               FwGetSx3Cache('G2_CODIGO','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_CODIGO','X3_TAMANHO'),;
                                               0,; 
                                               "Código"		,; 
                                               FwGetSx3Cache('G2_CODIGO','X3_PICTURE');	
                                        },;
                                        {"",;
                                               FwGetSx3Cache('G2_DESCRI','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_DESCRI','X3_TAMANHO'),;
                                               0,; 
                                               "Descrição"		,; 
                                               FwGetSx3Cache('G2_DESCRI','X3_PICTURE');	
                                        },;
                                        {"",;
                                               FwGetSx3Cache('G2_OPERAC','X3_TIPO'),; 
                                               FwGetSx3Cache('G2_OPERAC','X3_TAMANHO'),;
                                               0,; 
                                               "Operação"		,; 
                                               FwGetSx3Cache('G2_OPERAC','X3_PICTURE');	
                                        };
                                    };
                        };
                    }

    Private c_Codigo
    Private c_AliasT   := GetNextAlias()

    If fwisincallstack("U_FSPCPM02") 
        c_Prod  := oModelMVC:GetModel("GRIDID"):GetValue("TMP_CODPI")
    Else
        c_OP    := oModelMVC:GetModel("GRIDID"):GetValue("TMP_OP")
        c_Prod  := Posicione("SC2",1,FWxFilial("SC2") + c_OP,"C2_PRODUTO")
    Endif

    If Left(c_Projeto,3) <> 'BHI'

        If oQryC == Nil

            c_Qry := "select G2_CODIGO, G2_PRODUTO, G2_DESCRI, G2_OPERAC from ? SG2  " + CRLF
            c_Qry += "INNER JOIN ? SB1 ON G2_FILIAL=B1_FILIAL AND G2_PRODUTO=B1_COD AND G2_CODIGO=B1_OPERPAD AND SB1.D_E_L_E_T_='' " + CRLF
            c_Qry += "INNER JOIN ? SH1 ON G2_FILIAL=H1_FILIAL AND G2_RECURSO=H1_CODIGO AND SH1.D_E_L_E_T_='' " + CRLF
            c_Qry += "INNER JOIN ? CB1 ON CB1_CODOPE='?' AND CB1.D_E_L_E_T_='' " + CRLF
            c_Qry += "LEFT OUTER JOIN SYS_USR_VINCFUNC USR ON CB1_FILIAL= USR_FILIAL AND CB1_CODUSR=USR_ID AND USR.D_E_L_E_T_='' " + CRLF
            c_Qry += "LEFT OUTER JOIN ? SRA ON RA_FILIAL= USR_FILIAL AND RA_MAT=USR_CODFUNC AND SRA.D_E_L_E_T_='' " + CRLF
            c_Qry += "WHERE SG2.G2_FILIAL = '?' AND SG2.D_E_L_E_T_='' AND H1_CCUSTO = ISNULL(RA_CC,CB1.CB1_XCC) AND G2_PRODUTO = '?' " + CRLF

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

    Else

        If oQryC == Nil

            c_Qry := "select '01' G2_CODIGO, '' G2_PRODUTO, VI_DESCRI G2_DESCRI, VI_CODIGO G2_OPERAC from ? SVI  " + CRLF
            c_Qry += "WHERE SVI.VI_FILIAL = '?' AND SVI.VI_XPI = 'I' AND SVI.D_E_L_E_T_='' " + CRLF

            c_Qry := ChangeQuery(c_Qry)
            oQryC := FWPreparedStatement():New(c_Qry)

        EndIf

        oQryC:SetUnsafe(1, RetSqlName( "SVI" ))
        oQryC:SetUnsafe(2, xFilial("SVI"))

    Endif

    c_Qry 	:= oQryC:GetFixQuery()

    c_Alias 	:= MPSysOpenQuery( c_Qry )


    //Adiciona as colunas que serão criadas na temporária
    aAdd(a_Campos, { 'CODIGO'   , 'C', 8, 0}) 
    aAdd(a_Campos, { 'PRODUTO', 'C', 20, 0})
    aAdd(a_Campos, { 'DESCRICAO', 'C', 20, 0})
    aAdd(a_Campos, { 'OPERACAO', 'C', 8, 0})


    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(c_AliasT)
    oTempTable:SetFields( a_Campos )
    oTempTable:AddIndex("1", {"CODIGO"} )
    oTempTable:AddIndex("2", {"PRODUTO"} )
    oTempTable:AddIndex("3", {"DESCRICAO"} )
    oTempTable:AddIndex("4", {"OPERACAO"} )
    oTempTable:Create()  
 
    //Popula a tabela temporária

    (c_Alias)->(dbGotop())

    While !(c_Alias)->(Eof())

        RecLock(c_AliasT,.T.)
        (c_AliasT)->CODIGO    := (c_Alias)->G2_CODIGO
        (c_AliasT)->PRODUTO   := (c_Alias)->G2_PRODUTO
        (c_AliasT)->DESCRICAO := (c_Alias)->G2_DESCRI
        (c_AliasT)->OPERACAO  := (c_Alias)->G2_OPERAC

        (c_Alias)->(dbSkip())

    Enddo

    //Adiciona as colunas
    a_Colunas := fCriaColsOper3()

    DEFINE MSDIALOG oDlg FROM 00,00 TO 290,490 PIXEL TITLE OemToAnsi("Pesquisa"/*STR0320*/) //"Pesquisa"

    oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    
    oListBox := FWBrowse():New()
    oListBox:SetSeek(,a_SeekTmp)
    oListBox:SetAlias(c_AliasT)
    oListBox:SetColumns(a_Colunas)
    oListBox:SetDataTable()    
    oListBox:SetOwner(oPanel)
    oListBox:DisableConfig()
    oListBox:DisableReport()
    oListBox:SetDoubleClick(b_BlocoOk)

    oListBox:Activate()

    oDlg:Activate(, , , .T., , , b_BlocoIni)

    If l_Ok

        oModelMVC:SetValue('GRIDID','TMP_COPER',c_Codigo)
        M->TMP_COPER := c_Codigo
    EndIf

Return l_Ok
