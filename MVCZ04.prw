#include "protheus.ch"
#include "fwmvcdef.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MVCZ04
Cadastro de Grupos para Integração Solid Works

@since 27/10/2024
/*/
//-------------------------------------------------------------------
User Function MVCZ04()
Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('Z04')
	oBrowse:SetDescription('Cadstro de Grupos para Integração Solid Works')
	oBrowse:Activate()
		
Return

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.MVCZ04' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.MVCZ04' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.MVCZ04' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.MVCZ04' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.MVCZ04' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.MVCZ04' OPERATION 9 ACCESS 0

Return aRotina

Static Function ModelDef()
Local oModel
Local oStruZ04 := FWFormStruct(1,"Z04")

	oModel := MPFormModel():New("MD_MASTERZ04")
	oModel:SetDescription("Cadstro de Grupos para Integração Solid Works")
	
	oModel:addFields('MASTERZ04',,oStruZ04)
	oModel:getModel('MASTERZ04'):SetDescription('Dados dos grupos')

	oModel:SetPrimaryKey({'Z04_FILIAL','Z04_GRPCAV'})
 

Return oModel

Static Function ViewDef()
Local oModel := ModelDef()
Local oView
Local oStrZ04:= FWFormStruct(2, 'Z04')
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('FORM_GRUPOS' , oStrZ04,'MASTERZ04' ) 
	oView:CreateHorizontalBox( 'BOX_FORM_GRUPOS', 100)
	oView:SetOwnerView('FORM_GRUPOS','BOX_FORM_GRUPOS')	
	
Return oView
