#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
//
// Autor e Data		: Carlos N. Puerta - 05/03/2019
// Ponto-de-Entrada	: MT340D3
// Localiaçao		: Function MA340Process - Função responsável pelo processamento do acerto do inventário.
// Em que Ponto		: O ponto se encontra logo após a geração de movimento no SD3 para acerto do inventário. A tabela SD3 ainda está com Lock de registro.
// TDN				: http://tdn.totvs.com/display/public/PROT/MT340D3
//
User Function MT340D3()
_aArea := GetArea()

If AllTrim(Substr(SB7->B7_DOC,1,1)) == "K"
    Replace D3_DOC  With  "K"+Dtos(dDataBase)
EndIf

RestArea(_aArea)
Return