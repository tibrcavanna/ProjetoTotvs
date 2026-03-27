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

User function FSPCPM07()

    Local oBrowse := FWMBrowse():New()
    Local aRotina := Nil

    Private lMsErroAuto := .F.
    
    aRotina := MenuDef()

    oBrowse:SetAlias('Z01')
    oBrowse:SetDescription('Tabela Apontamento - Engenharia')

    oBrowse:Activate()

Return

Static Function MenuDef()

    Local aRotina := {}

Return aRotina
