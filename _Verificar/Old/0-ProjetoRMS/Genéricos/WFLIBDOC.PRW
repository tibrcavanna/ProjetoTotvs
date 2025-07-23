#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'WFMATA120.ch'

Static aSCR := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados genérico usado para qualquer aprovação de documento
no fluig que utilize a alçada SCR

@author Juliane Venteu
@since 16/02/2017
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruSCR:= FWFormStruct(1,'SCR', {|cCampo| AllTrim(cCampo) $ "CR_FILIAL|CR_NUM|CR_SOLICIT|CR_EMISSAO|CR_TIPO|CR_APROV|CR_USER|CR_USERORI|CR_GRUPO|CR_ITGRP|CR_TOTAL|CR_OBS"})
Local oModel
	
	// -----------------------------------------------------------------------
	// INCLUSÃO DOS CAMPOS COM A CHAVE DOS USUARIOS NO FLUIG
	// -----------------------------------------------------------------------
	If Empty(aSCR)
		aAdd( aSCR,{'CR_CODSOL'	,'C' , 50 , '@!'	,STR0026	,STR0026	,{}, NIL, Nil, Nil, Nil, 0   } ) // 'Solicitante'
		aAdd( aSCR,{'CR_CODAPR'	,'C' , 50 , '@!'	,STR0027	,STR0027	,{}, NIL, Nil, Nil, Nil, 0   } ) // 'Aprovador'
	EndIf
		
	WF120Model(aSCR,"STRUSCR_",oStruSCR)
		
	oModel := MPFormModel():New('WFMATA120', /*bPreValidacao*/, {|oModel| WFVldLibDoc(oModel) }/*bPosValidacao*/, {|oModel|WFLibDoc(oModel)}/*bCommit*/, /*bCancel*/ )
	
	oModel:AddFields( 'SCRMASTER', /*OWNER*/	, oStruSCR)
		
	oModel:GetModel( 'SCRMASTER' ):SetDescription( STR0051 ) // 'Alçada'	
	
	oModel:SetPKIndexOrder(2)
	oModel:SetPrimaryKey( {'CR_TIPO','CR_NUM','CR_USER'} )
	
	//------------------------------------------------------------------
	//	Realiza carga dos campos do mecanismo de atribuição
	//------------------------------------------------------------------
	oModel:SetActivate( { |oModel| WFMecAt( oModel ) } ) 
	
	// -----------------------------------------------------------------------
	// Adiciona a descricao do Modelo de Dados
	// -----------------------------------------------------------------------
	oModel:SetDescription( 'Workflow de Liberação de Documento' )
	
Return oModel

Static Function ViewDef()
Local oModel := ModelDef()
Local oStruSCR:= FWFormStruct(2,'SCR', {|cCampo| AllTrim(cCampo) $ "CR_FILIAL|CR_NUM|CR_SOLICIT|CR_EMISSAO|CR_TIPO|CR_APROV|CR_USER|CR_USERORI|CR_GRUPO|CR_ITGRP|CR_TOTAL|CR_OBS"},,,.T.)
Local oView
	
	WF120View(aSCR,'SCR_',oStruSCR)
	
	// -----------------------------------------------------------------------
	// Monta o modelo da interface do formulario
	// -----------------------------------------------------------------------
	oView := FWFormView():New()
	
	oView:SetModel(oModel)		
		
	oView:AddField('VIEW_SCR', oStruSCR,'SCRMASTER')	
	oView:CreateHorizontalBox( 'SCR' ,01 )
	oView:SetOwnerView('VIEW_SCR','SCR')
			
	oView:EnableTitleView('VIEW_SCR' , STR0051 ) // 'Alçada'

	aSCR := {}
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} WFVldLibDoc
Valida se o usuario possui saldo dentro dos limites configurados para
o aprovador.

@author Juliane Venteu
@since 16/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WFVldLibDoc(oModel)
Local lRet := .T.
Local cNum			:= oModel:GetValue('SCRMASTER','CR_NUM')
Local cUser		:= oModel:GetValue('SCRMASTER','CR_USER')
Local cTipo		:= oModel:GetValue('SCRMASTER','CR_TIPO')
Local cAprov		:= Iif(oModel:GetWKNextState()=='4','1','2')
Local cFluig		:= Alltrim(cValToChar(oModel:GetWKNumProces()))
Local aAreaSCR := SCR->(GetArea())
Local cSCRFil
Local aSaldo
Local nSaldo

	If cTipo $ 'IC|CT|IR|RV'
		cSCRFil := CnFilCtr(cNum)
	Else
		cSCRFil := xFilial("SCR")
	EndIf
	
	DbSelectArea("SCR")
	SCR->(DbSetOrder(2))
	If SCR->(DbSeek(cSCRFil+cTipo+cNum+cUser)) .And. cAprov == '1' //Valida saldo apenas quando é uma aprovação do documento
		While !Eof() .And. cSCRFil+cTipo+cNum+cUser == SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_USER)
			If Alltrim(SCR->CR_FLUIG) == cFluig .And. SCR->CR_STATUS == '02' // Verifica se está em aberto 
				// Posiciona o Aprovador
				dbSelectArea("SAK")
				SAK->(dbSetOrder(2))
				SAK->(dbSeek(xFilial("SAK")+cUser))
				dbSelectArea("SCS")
				SCS->(dbSetOrder(2))
				aSaldo 		:= MaSalAlc(SCR->CR_APROV,dDataBase,.T.)
				nSaldo 		:= aSaldo[1]
									
				If nSaldo < SCR->CR_TOTAL
					Help(,,'WFAPR',,"Saldo insuficiente para aprovar esse documento.", 1, 0)						
					lRet := .F.
					Exit
				EndIf
			EndIf
			
			SCR->(DBSkip())
		EndDo
	EndIf
	
RestArea(aAreaSCR)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WFLibDoc
Função liberar documento
@author rafael.duram
@since 28/08/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function WFLibDoc(oModel)
Local cNum			:= oModel:GetValue('SCRMASTER','CR_NUM')
Local cUser		:= oModel:GetValue('SCRMASTER','CR_USER')
Local cTipo		:= oModel:GetValue('SCRMASTER','CR_TIPO')
Local cParecer	:= oModel:GetValue('WF1MASTER','WF1_PAREC')
Local cAprov		:= Iif(oModel:GetWKNextState()=='4','1','2')
Local cFluig		:= Alltrim(cValToChar(oModel:GetWKNumProces()))
Local lRet			:= .F.

lRet := MTFlgLbDoc(cNum,cUser,cAprov,cTipo,cFluig,cParecer)

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} WFMecAt()
Realiza carga dos campos do mecanismo de atribuição
@author Rafael Duram
@since 24/03/2016
@version 1.0
@return .T.
/*/
//--------------------------------------------------------------------
Static Function WFMecAt(oModel)
Local oFieldSCR 	:= oModel:GetModel("SCRMASTER")
Local cUserSolic	:= MtUsrSolic(oFieldSCR:GetValue("CR_TIPO"),oFieldSCR:GetValue("CR_NUM"))
Local cAprov		:= A097UsuApr(oFieldSCR:GetValue("CR_APROV"))

oFieldSCR:LoadValue("CR_CODSOL"  , FWWFColleagueId(cUserSolic) )
oFieldSCR:LoadValue("CR_CODAPR"  , FWWFColleagueId(cAprov)   	)

Return 
