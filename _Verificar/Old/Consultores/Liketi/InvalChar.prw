#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �InvalChar �Autor  �M�rcio Lins         � Data �  06/05/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Invalida caracteres restritos da SEFAZ (NFE 2.0)           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cavanna                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
// cod: '  - 39
// cod: "  - 34
// cod: &  - 38
// cod: <  - 60
// cod: >  - 62
	
User Function InvalChar(cContent)
	
	Local aInvalChars   := {}
	Local aInvalAscii   := {}
	Local aContentChr	:= {}
	Local cMvInvChars   := AllTrim(getMv("MV_XBLKLST"))
	Local bRet			:= .T.
	
	cContent := Iif(empty(cContent), "Produto Cobriato de endroxol", cContent)
	
	// tratamento dos parametros, caracteres identificados com n�o v�lidos
	aInvalChars := StrTokArr(Iif(empty(cMvInvChars),'";&;<;>;'+"'",cMvInvChars), ";")
	
	nCntY := Len(aInvalChars)
	
	For nY := 1 To nCntY
	
		nRetTemp := At(aInvalChars[nY], cContent)
		
		If nRetTemp > 0
		
		     bRet := .F.
		     
		EndIf
	
	Next nY
	
	If !bRet
	
		Alert("Aten��o: Caracteres invalidos foram encontrados, por favor retire todos os caracteres especiais como acentos e sinais de pontua��o")
		
	EndIf	
	 
Return bRet