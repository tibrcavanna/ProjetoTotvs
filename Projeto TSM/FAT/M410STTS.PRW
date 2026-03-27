#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} M410STTS
Manipula parcelas na Z03 de acordo com condição de pagamento
@type function
@version 12.1.2410 
@author Gildeir Pereira - gildeir.pereira@totvs.com.br
@since 13/11/2025
/*/
User Function M410STTS()
	Local nOper := PARAMIXB[1]
	Local aArea := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local aParc := __XaParcPed
	Local i
	Local cCondPag := GetMv("MV_XCNDPAG")

	If nOper == 3 .OR. nOper == 4 .OR. nOper == 6

		//Caso .T. Deleta parcelas e grava novamente, .F. não realiza operação porque foi clicado em fechar, então manter registros.
		//if __XSParPed 
		If !Empty(aParc)
			dbSelectArea("Z03")
			Z03->(dbSetOrder(1))
			Z03->(dbGoTop())      
			if(Z03->(msSeek(cFilAnt+C5_NUM))) //Localiza parcelas do pedido e deleta
				while !Z03->(EOF()) .And. Z03->(Z03_FILIAL+Z03_NUM) == cFilAnt+C5_NUM
					recLock("Z03", .F.)
					Z03->(dbDelete())
					Z03->(msUnlock())
					Z03->(DbSkip())
				Enddo
			endif

			if SC5->C5_CONDPAG == cCondPag //Caso a condição de pagamento esteja no parâmetro, realiza a inclusão das parcelas na Z03
				For i:= 1 To Len(aParc)
					recLock("Z03", .T.)
					Z03->Z03_FILIAL := aParc[i][1]
					Z03->Z03_NUM	:= aParc[i][2]
					Z03->Z03_PARC	:= aParc[i][3]
					Z03->Z03_PERC	:= aParc[i][4]
					Z03->Z03_VALOR	:= aParc[i][5]
					Z03->Z03_VENCTO	:= aParc[i][6]
					Z03->Z03_OBS    := aParc[i][7]
					Z03->Z03_USER   := aParc[i][8]
					Z03->(msUnlock())
				Next
			endif
		endif

		Z03->(DBCloseArea())
	EndIf

	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aArea)

Return Nil
