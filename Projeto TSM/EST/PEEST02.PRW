#include "totvs.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} PEEST02
Função adaptada da opção "Roteiro Similar" do menu (Cópia) - PCPA124
@type user function
@version 1.0
@author Gabriel Souza
@since 05/12/2025
/*/
User Function PEEST02()
	Local o_StruSG2
	Local o_StruSH3R
	Local o_StruSH3F
	Local o_StruSGR
	Local o_StruSHJ
	Local a_StrSG2    := {}
	Local a_StrSH3    := {}
	Local a_StrSGR    := {}
	Local a_StrSHJ    := {}
	Local n_I           := 1
	Local n_SH3R        := 1
	Local n_SH3F        := 1
	Local n_SGR          := 1
	Local n_SHJ          := 1
	Local n_CampoTam     := 0
	Local l_MvChkOpr    := SuperGetMV("MV_CHKOPER",.F.,.F.)
	Local l_UniLin		:= SuperGetMv("MV_UNILIN",.F.,.F.)
	Local n_Ret

	o_Model        := FwLoadModel("PCPA124")

	o_StruCab 	:= o_Model:Getmodel("PCPA124_CAB")
	o_StruSG2 	:= o_Model:Getmodel("PCPA124_SG2")
	o_StruSH3R	:= o_Model:GetModel("PCPA124_SH3_R")
	o_StruSH3F	:= o_Model:GetModel("PCPA124_SH3_F")
	o_StruSGR	:= o_Model:GetModel("PCPA124_SGR")
	o_StruSHJ	:= o_Model:GetModel("PCPA124_SHJ")

	o_Model:SetOperation(MODEL_OPERATION_INSERT)
	o_Model:Activate()

	cProdAux := SG2->G2_PRODUTO
	cCodAux  := SG2->G2_CODIGO

	o_Model:LoadValue("PCPA124_CAB","G2_CODIGO","01")
	o_Model:LoadValue("PCPA124_CAB","G2_PRODUTO",SB1->B1_COD)
	o_Model:LoadValue("PCPA124_CAB","CDESCPROD",SB1->B1_DESC)
    o_StruCab:GetStruct():SetProperty('G2_CODIGO',MODEL_FIELD_WHEN,{ || .F.})
    o_StruCab:GetStruct():SetProperty('G2_PRODUTO',MODEL_FIELD_WHEN,{ || .F.})

	//Pega estrutura da tabela Filho
	a_StrSG2 := SG2->(dbStruct())
	a_StrSH3 := SH3->(dbStruct())
	a_StrSGR := SGR->(dbStruct())
	a_StrSHJ := o_StruSHJ:AHEADER //SHJ->(dbStruct())

	//Faz a consulta na tabela filho
	dbSelectArea( "SG2" )

	if MatGrdPrrf(cProdAux) //Verifica se o produto é referência grade
		SG2->( DbSetOrder(7) )
		n_CampoTam := GetSx3Cache("G2_REFGRD","X3_TAMANHO")
	else
		SG2->( DbSetOrder(1) )
		n_CampoTam := GetSx3Cache("G2_PRODUTO","X3_TAMANHO")
	EndIf

	If SG2->( dbSeek( xFilial( "SG2" )+PadR(cProdAux,n_CampoTam)+cCodAux))

		//Carrega SH3 - recursos e ferramentas alternativos
		dbSelectArea( "SH3" )
		SH3->( DbSetOrder(1) )

		//Enquanto houver registros filhos, vai adicionando no grid
		While SG2->(!Eof()) .and. xFilial("SG2") == SG2->G2_FILIAL .and. (cProdAux == SG2->G2_PRODUTO .Or. PadR(cProdAux,n_CampoTam) == SG2->G2_REFGRD) .and. cCodAux == SG2->G2_CODIGO
			//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
			If !Empty(o_StruSG2:GetValue('G2_OPERAC')) .OR. o_StruSG2:IsDeleted()
				o_StruSG2:AddLine()
			EndIf

			//Adiciona o valor pra cada campo do grid
			For n_I:= 1 To Len(a_StrSG2)
				If !( a_StrSG2[n_I][1] $ "|G2_FILIAL|G2_PRODUTO|G2_CODIGO|G2_REVIPRD|" ) .And. o_StruSG2:HasField(a_StrSG2[n_I][1])
					o_StruSG2:LoadValue(a_StrSG2[n_I][1],SG2->&(a_StrSG2[n_I][1]))
				EndIf
			Next

			If !o_StruSG2:VldLineData()
				MsgStop('Não foi possível incluir a operação. Motivo: '+o_Model:GetErrorMessage()[6],'') //'Não foi possível incluir a operação. Motivo: '
				Exit
			EndIf

			n_SH3R := 1
			n_SH3F := 1

			If SH3->( dbSeek( xFilial( "SH3" )+cProdAux+cCodAux+SG2->G2_OPERAC))
				//Enquanto houver registros filhos, vai adicionando no grid
				While SH3->(!Eof()) .and. xFilial("SH3") == SH3->H3_FILIAL .and. cProdAux == SH3->H3_PRODUTO .and. cCodAux == SH3->H3_CODIGO .and. SG2->G2_OPERAC == SH3->H3_OPERAC
					If Empty(SH3->H3_FERRAM)
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If n_SH3R != 1
							o_StruSH3R:AddLine()
						EndIf

						//Adiciona o valor pra cada campo do grid
						For n_I:= 1 To Len(a_StrSH3)
							If !( a_StrSH3[n_I][1] $ "|H3_FILIAL|H3_PRODUTO|H3_CODIGO|H3_OPERAC|H3_FERRAM|H3_DESCFER|H3_RECPRIN|" )
								o_StruSH3R:LoadValue(a_StrSH3[n_I][1],SH3->&(a_StrSH3[n_I][1]))
							EndIf
						Next

						//Carrega descrição do recurso
						o_StruSH3R:SetValue("H3_DESC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("H3_RECALTE"),"H1_DESCRI"),GetSx3Cache("H3_DESC","X3_TAMANHO")))
						n_SH3R++
					Else
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If n_SH3F != 1
							o_StruSH3F:AddLine()
						EndIf

						//Adiciona o valor pra cada campo do grid
						For n_I:= 1 To Len(a_StrSH3)
							If !( a_StrSH3[n_I][1] $ "|H3_FILIAL|H3_PRODUTO|H3_CODIGO|H3_OPERAC|H3_RECPRIN|H3_RECALTE|H3_TIPO|H3_EFICIEN|H3_DESC|")
								o_StruSH3F:LoadValue(a_StrSH3[n_I][1],SH3->&(a_StrSH3[n_I][1]))
							EndIf
						Next

						//Carrega descrição da ferramenta
						o_StruSH3F:SetValue("H3_DESCFER",PadR(Posicione("SH4",1,xFilial("SH4")+FwFldGet("H3_FERRAM"),"H4_DESCRI"),GetSx3Cache("H3_DESCFER","X3_TAMANHO")))
						n_SH3F++
					endif
					//Pula pro próximo registro filho
					SH3->(DbSkip())
				EndDo
			EndIf

			//Carrega SGR - Checklist das operações
			If l_MvChkOpr
				SGR->( DbSetOrder(1) )

				n_SGR := 1

				If SGR->( dbSeek( xFilial( "SGR" )+cProdAux+cCodAux+SG2->G2_OPERAC))
					//Enquanto houver registros filhos, vai adicionando no grid
					While SGR->(!Eof()) .and. xFilial("SGR") == SGR->GR_FILIAL .and. cProdAux == SGR->GR_PRODUTO .and. cCodAux == SGR->GR_ROTEIRO .and. SG2->G2_OPERAC == SGR->GR_OPERAC
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If n_SGR != 1
							o_StruSGR:AddLine()
						EndIf
						//Adiciona o valor pra cada campo do grid
						For n_I:= 1 To Len(a_StrSGR)
							If !( a_StrSGR[n_I][1] $ "|GR_FILIAL|GR_ROTEIRO|GR_PRODUTO|GR_OPERAC|GR_DESCOP|" )
								o_StruSGR:LoadValue(a_StrSGR[n_I][1],SGR->&(a_StrSGR[n_I][1]))
							EndIf
						Next
						n_SGR++
						//Pula pro próximo registro filho
						SGR->(DbSkip())
					EndDo
				EndIf
			EndIf

			//Carrega SHJ - Integração com o Drummer
			If TipoAps(.F.,"DRUMMER")
				SHJ->( DbSetOrder(1) )

				n_SHJ := 1

				If SHJ->( dbSeek( xFilial( "SHJ" )+cCodAux+cProdAux+SG2->G2_OPERAC))
					//Enquanto houver registros filhos, vai adicionando no grid
					While SHJ->(!Eof()) .and. xFilial("SHJ") == SHJ->HJ_FILIAL .and. cProdAux == SHJ->HJ_PRODUTO .and. cCodAux == SHJ->HJ_ROTEIRO .and. SG2->G2_OPERAC == SHJ->HJ_OPERAC
						//Verifica se precisa gerar mais um linha(se for a primeira não precisa)
						If n_SHJ != 1
							o_StruSHJ:AddLine()
						EndIf
						//Adiciona o valor pra cada campo do grid
						For n_I:= 1 To Len(a_StrSHJ)
							If ( a_StrSHJ[n_I][2] $ "|HJ_FILIAL|HJ_PRODUTO|HJ_OPERAC|HJ_CTRAB|HJ_RECURSO|" )
								o_StruSHJ:LoadValue(a_StrSHJ[n_I][2],SHJ->&(a_StrSHJ[n_I][2]))
							EndIf
						Next
						o_StruSHJ:SetValue("HJ_DESCREC",PadR(Posicione("SH1",1,xFilial("SH1")+FwFldGet("HJ_RECURSO"),"H1_DESCRI"),TamSX3("HJ_DESCREC")[1]))
						n_SHJ++
						//Pula pro próximo registro filho
						SHJ->(DbSkip())
					EndDo
				EndIf
			EndIf

			//Pula pro próximo registro filho
			SG2->(DbSkip())
		EndDo
		If l_UniLin
			o_Model:GetModel("PCPA124_CAB"):LoadValue("G2_LINHAPR",o_Model:GetModel("PCPA124_SG2"):GetValue("G2_LINHAPR",1))
			o_Model:GetModel("PCPA124_CAB"):LoadValue("G2_TPLINHA",o_Model:GetModel("PCPA124_SG2"):GetValue("G2_TPLINHA",1))
		EndIf
	EndIf

	o_StruSG2:GoLine(1)
	o_StruSHJ:GoLine(1)

    n_Ret := FWExecView('STR0013', "PCPA124", OP_INCLUIR, /*oDlg*/, {|| .T. }, /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, o_Model)
Return 
