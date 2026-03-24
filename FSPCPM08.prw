#Include "Protheus.ch"
#Include "FwMvcDef.ch"

#define MVC_TITLE "Tabela Apontamento - Produção"
#define MVC_VIEWDEF_NAME "VIEWDEF.FSPCPM05"

/*/{Protheus.doc}
(TELA DE PRODUÇÃO, APONTAMENTOS)
@type  function
@author Silvio Nogueira
@since 22/09/2025
@version 01
/*/

User function FSPCPM08()

    Local oBrowse := FWMBrowse():New()
    Local aRotina := Nil

    Private lMsErroAuto := .F.
    
    aRotina := MenuDef()

    oBrowse:SetAlias('SH6')
    oBrowse:SetDescription('Tabela Apontamento - Produção')

    oBrowse:Activate()

Return

Static Function MenuDef()

    Local aRotina := {}

Return aRotina

/*
Static Function ModelDef()

    Local oModel    := Nil
    
    // Estrutura para os campos das tabela Z01 - Model
    Local oStruZ01  :=  FWFormStruct(1, 'Z01')

    // Inicia a criação do Model
    oModel := MPFormModel():New('MDCAVA05')

	//Atribuindo formulários para o modelo
	oModel:AddFields("MDCAVA05",,oStruZ01)

    // Define a chave primária
    oModel:SetPrimaryKey({'Z01_FILIAL', 'Z01_OPER', 'Z01_OP', 'Z01_COPER'})

    // Descrições do Model
    oModel:SetDescription('Apontamento Horas - Produção')

Return oModel


Static Function ViewDef()

	Local oView  As Object

    // Recebe o Model para atribuir a View
    Local oModel    := ModelDef()

    // Estrutura para os campos das tabela Z01 - View
    Local oStruZ01  := FWFormStruct(2, 'Z01')

    // Inicia a criação do Model
    oView := FWFormView():New()

    // Define o model que será utilizado na View
    oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_Z01", oStruZ01, "MDCAVA05")

Return oView

// Ponto de Entrada do Browse para ser utilizado caso necessário
User Function MDCAVA05()

    Local lRet := .T.
    Local oModel := PARAMIXB[1]
    Local cIdPonto := PARAMIXB[2]
    Local cOperacao := oModel:GetOperation()

    Local cOP   := Z01->Z01_OP
    SC2->(MsSeek(FWxFilial("SC2") + cOP))
    Local cProd := SC2->C2_PRODUTO
    Local dDatRF := SC2->C2_DATRF
    Local cOper := Z01->Z01_COPER

    If cIdPonto = "MODELPOS"

        If cOperacao = 5 .And. Empty(dDatRF) // Operação de Exclusão

            BEGIN TRANSACTION

            // Inicia processo de estorno na tabela SH6 de apontamento

            DbSelectArea("SH6")
            SH6->(DbSetOrder(3))
            If SH6->(MsSeek(FWxFilial("SH6") + cProd + cOP + cOper))

                aVetor := {;
                    {"H6_OP"     , SH6->H6_OP      ,Nil},;
                    {"H6_PRODUTO", SH6->H6_PRODUTO , NIL},;
                    {"H6_OPERAC", SH6->H6_OPERAC , NIL},;
                    {"H6_RECURSO", SH6->H6_RECURSO , NIL},;
                    {"H6_DTAPONT", SH6->H6_DTAPONT , NIL},;
                    {"H6_DATAINI", SH6->H6_DATAINI , NIL},;
                    {"H6_HORAINI", SH6->H6_HORAINI , NIL},;
                    {"H6_DATAFIN", SH6->H6_DATAFIN , NIL},;
                    {"H6_HORAFIN", SH6->H6_HORAFIN , NIL},;
                    {"H6_PT", SH6->H6_PT   , NIL},;
                    {"H6_LOCAL", SH6->H6_LOCAL   , NIL},;
                    {"H6_LOTECTL", SH6->H6_LOTECTL , NIL},;
                    {"H6_QTDPROD", SH6->H6_QTDPROD , NIL},;
                    {"AUTRECNO", SH6->(Recno()) , Nil}}

                MSExecAuto({|x,y| mata681(x,y)},aVetor, 5)

                If lMsErroAuto

                    Mostraerro()
                    DisarmTransaction()
                    lRet := .F.
                    BREAK

                EndIf

            EndIf

            END TRANSACTION 

            SH6->(DBCLOSEAREA())

        Else

            If cOperacao = 5 .And. !Empty(dDatRf) 

                FWALERTERROR("Ordem de Produção referente ao apontamento está encerrada!", "Exclusão não Permitida!")
                lRet := .f.

            Endif 

        Endif

    Endif

Return lRet
*/
