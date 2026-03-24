#Include "Protheus.ch"
#Include "FwMvcDef.ch"

/*/{Protheus.doc}
(TELA DE PRODUÇÃO, APONTAMENTOS)
@type  function
@author Silvio Nogueira
@since 22/09/2025
@version 01
/*/

#define MVC_TITLE "Tabela Apontamento - Engenharia / Produção"
#define MVC_VIEWDEF_NAME "VIEWDEF.FSPCPM04"

User function FSPCPM04()

    Local oBrowse := FWMBrowse():New()
    Local aRotina := Nil
    
    aRotina := MenuDef()

    oBrowse:SetAlias('Z01')

    If !UserApont()
        oBrowse:SetFilterDefault( "Z01->Z01_OPER = '"+Posicione("CB1",2,FWxFilial("CB1") + __cUserID,"CB1_CODOPE")+"'" )
    Endif

    oBrowse:SetDescription('Tabela Apontamento - Engenharia / Produção')

    oBrowse:Activate()

Return

Static Function MenuDef()

    Local aRotina := {}
    If UserApont()
	    ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.FSPCPM04" OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	    ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.FSPCPM04" OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    Endif        
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.FSPCPM04' OPERATION MODEL_OPERATION_VIEW ACCESS 0

Return aRotina

Static Function ModelDef()

    Local oModel    := Nil
    
    // Estrutura para os campos das tabela Z01 - Model
    Local oStruZ01  :=  FWFormStruct(1, 'Z01')

    // Inicia a criação do Model
    oModel := MPFormModel():New('MDCAVA04')

	//Atribuindo formulários para o modelo
	oModel:AddFields("MDCAVA04",/*cOwner*/,oStruZ01)

    // Define a chave primária
    oModel:SetPrimaryKey({'Z01_FILIAL', 'Z01_OPER', 'Z01_PROJ', 'Z01_COPER'})

    // Descrições do Model
    oModel:SetDescription('Apontamento Horas - Engenharia / Produção')

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
	oView:AddField("VIEW_Z01", oStruZ01, "MDCAVA04")

Return oView

// Ponto de Entrada do Browse para ser utilizado caso necessário
User Function MDCAVA04()

    Local lRet := .T.
    Local oModel := PARAMIXB[1]
    Local cIdPonto := PARAMIXB[2]
    Local dDatIni
    Local dDatFim
    Local cOperacao := oModel:GetOperation()
    Local dUlmes    := SuperGetMv("MV_ULMES")
    Local dBloqMov  := SuperGetMv("MV_DBLQMOV")

    If cIdPonto = "MODELPOS"

        If cOperacao = 4 // Operação de Exclusão

            dDatIni := Z01->Z01_DTINI
            dDatFim := Z01->Z01_DTFIM

            if !Empty(Z01->Z01_CODMO)
                FWALERTERROR("Esse apontamento já foi integrado na OP de montagem do Code Allegre.", "Alteração não permitida!")
                lRet := .f.
            endif

            if dDatIni <= dUlmes .Or. dDatFim <= dUlmes
                FWALERTERROR("A Data do apontamento (inicial ou final) se refere ao período do ultimo fechamento de custos.", "Alteração não permitida!")
                lRet := .f.
            endif

            if (dDatIni <= dBloqMov .Or. dDatFim <= dBloqMov) .AND. lRet
                FWALERTERROR("A Data do apontamento (inicial ou final) se refere ao período bloqueado.", "Alteração não permitida!")
                lRet := .f.
            endif

        Endif

        If cOperacao = 5 // Operação de Exclusão

            dDatIni := Z01->Z01_DTINI
            dDatFim := Z01->Z01_DTFIM

            if !Empty(Z01->Z01_CODMO)
                FWALERTERROR("Esse apontamento já foi integrado na OP de montagem do Code Allegre.", "Exclusão não permitida!")
                lRet := .f.
            endif

            if dDatIni <= dUlmes .Or. dDatFim <= dUlmes
                FWALERTERROR("A Data do apontamento (inicial ou final) se refere ao período do ultimo fechamento de custos.", "Exclusão não permitida!")
                lRet := .f.
            endif

            if (dDatIni <= dBloqMov .Or. dDatFim <= dBloqMov) .AND. lRet
                FWALERTERROR("A Data do apontamento (inicial ou final) se refere ao período bloqueado.", "Exclusão não permitida!")
                lRet := .f.
            endif

        Endif

    Endif

Return lRet


// Função para validar o usuário conectado se ele pertence aos operadores master
// Caso sim, libera o campo para mudança, caso não, 
//traz o campo preenchido com o o código do operador respectivo.
Static Function UserApont()
    Local lRet  := .T.
    Local cOpMaster := SuperGetMv("MV_FS_OPER",.F.,"admin")

    If cUserName $ cOpMaster

        lRet := .T.

    Else
    
        lRet := .F.

    Endif

Return lRet
