#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} MT461VCT
O ponto de entrada MT461VCT permite alterar o valor e o vencimento do título gerado no momento de geração da nota fiscal.
@type function
@version 12.1.2410  
@author Gildeir Pereira - gildeir.pereira@totvs.com.br
@since 06/11/2025
/*/
User Function MT461VCT()
	Local aParc  := PARAMIXB[1]
	Local aAux := {}
	Local cCondPag := GetMv("MV_XCNDPAG") // Condição de pagamento parametrizada
	Local aArea   := GetArea()
	Local cNumPed := SC5->C5_NUM

	If SC5->C5_CONDPAG = cCondPag // Só executa se for a condição definida

		// 2. Criar títulos de acordo com tabela Z03
		DbSelectArea("Z03")
		Z03->(DbSetOrder(1))

		If Z03->(DbSeek(xFilial("Z03")+cNumPed))
			While !Z03->(Eof()) .And. Z03->Z03_NUM == cNumPed

				aAdd(aAux,{;
					Z03->Z03_VENCTO,;
					Z03->Z03_VALOR;
					})

				Z03->(DbSkip())
			Enddo

			aParc := aAux
		EndIf

	EndIf

	RestArea(aArea)

return aParc

