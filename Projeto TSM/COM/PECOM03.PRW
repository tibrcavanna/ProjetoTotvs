#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

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
/*/
//-------------------------------------------------------------------------------------------------------------
User Function PECOM03()

	ChkNCM()

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkNCM
  Função para comparar NCM do XML contrao o NCM do Cadastro de protheus (SB1), durante a classificação da NFE.
  Em caso de divergencia exibe uma msg ao ususario.
 

  @type function
  @author Silvio Mota
  @since 13/08/2025
  @history 	13/08/2025, Silvio Mota, Versão Inicial
  @param  Nil, undefined, Esta funcao nao possui parametros.
  @return Nil, undefined, Esta funcao nao tem retorno
  @modified Silvio Nogueira Silva, 10/10/2025, Criação de tabela Z06 (Complemento SD1) - 
  @modified SD1 atingiu limite máximo de campos
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ChkNCM()
	Local n_Ind
	Local n_PosIt    := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_ITEM"  } )
	Local n_PosCod   := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_COD"   } )
	//Local n_PosNCM   := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_XNCMF" } )
	Local n_PosNCM   := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_POSIPI" } )

	Local n_PosDoc   := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_DOC" } )
	Local n_PosSeri := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_SERIE" } )
	Local n_PosForn := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_FORNECE" } )
	Local n_PosLoja := aScan( aHeader, { |x| AllTrim(x[2]) == "D1_LOJA" } )
  Local c_Doc
  Local c_Serie
  Local c_Fornece
  Local c_Loja
  Local c_Cod
  Local c_Item
  Local c_NCM

	Local c_Msg      := ""
	Local a_ItensNFE := {}

	For n_Ind := 1 to len(aCols)

    c_Doc        := aCols[ n_ind, n_PosDoc ]
    c_Serie      := aCols[ n_ind, n_PosSeri ]
    c_Fornece    := aCols[ n_ind, n_PosForn ]
    c_Loja       := aCols[ n_ind, n_PosLoja ]
    c_Cod        := aCols[ n_ind, n_PosCod ]
    c_Item       := aCols[ n_ind, n_PosIt ]

    //Posiciona tabela Z06 - Complementar SD1]
    //c_NCM := Posicione("Z06",1,FWxFilial("Z06") + c_Doc + c_Serie + c_Fornece + c_Loja + c_Cod + c_Item,"Z06_NCMF")     //D1_FILIAL + D1_DOC + D1_SERIE +D1_FORNECE + D1_LOJA + D1_COD + D1_ITEM
    Z06->(dbSetOrder(1))

    If Z06->(MsSeek(FWxFilial("Z06") + c_Doc + c_Serie + c_Fornece + c_Loja + c_Cod + c_Item))

  		c_NCM := Z06->Z06_NCMF

    Else

      c_NCM := aCols[ n_ind, n_PosNCM ]

    Endif

	  aAdd( a_ItensNFE , {  aCols[ n_ind, n_PosIt ],   aCols[ n_ind, n_PosCod ],  c_NCM  } )

		c_Msg := U_CompNCM( a_ItensNFE )

	Next

	If ! empty( c_Msg )
		FWAlertWarning( c_Msg , "NCM Fornecedor diverergente com o cadastro de produto" )
	EndIf

Return(Nil)


// Compara o NCM dos items das NF com cadastro de produto.
// Chamada pelos seguintes PE: MT100GRV e COLSTTS
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChkNCM
  Função para comparar NCM do XML contrao o NCM do Cadastro de protheus (SB1). Em caso de divergencia retorna uma msg.
  Função chamada neste PE (MT100GRV) e também na no importador XML (COLSTTS).
 
  @type function
  @author Silvio Mota
  @since 13/08/2025
  @history 	13/08/2025, Silvio Mota, Versão Inicial
  @param  Nil, undefined, Esta funcao nao possui parametros.
  @return Nil, undefined, Esta funcao nao tem retorno
  @modified Silvio Nogueira Silva, 10/10/2025, Criação de tabela Z06 (Complemento SD1) - 
  @modified SD1 atingiu limite máximo de campos
/*/
//-------------------------------------------------------------------------------------------------------------

User Function CompNCM( a_Itens )
	Local c_Ret := ""
	Local n_Ind
	Local c_NCM
	Local c_Item
	Local c_Cod

	For n_Ind := 1 to len(a_Itens)
		c_Item := a_Itens[n_Ind, 1]
		c_Cod  := a_Itens[n_Ind, 2]
		c_NCM  := a_Itens[n_Ind, 3]

		SB1->(dbSetOrder(1))
		If SB1->(dbSeek( xFilial('SB1') + c_Cod ))
			If SB1->B1_POSIPI <> c_NCM
				c_Ret := c_Ret + " - O NCM (" + AllTrim(c_NCM) + ") do item " + c_Item + " da NF é diferente do NCM (" + SB1->B1_POSIPI + ") no cadastro do produto " + AllTrim(SB1->B1_COD) + " !" + chr(13)
			EndIf
		EndIf
	Next

Return(c_Ret)
