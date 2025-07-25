#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
//
// Autor e Data		: Carlos N. Puerta - 05/03/2019
// Ponto-de-Entrada	: MT340D3
// Localia�ao		: Function MA340Process - Fun��o respons�vel pelo processamento do acerto do invent�rio.
// Em que Ponto		: O ponto se encontra logo ap�s a gera��o de movimento no SD3 para acerto do invent�rio. A tabela SD3 ainda est� com Lock de registro.
// TDN				: http://tdn.totvs.com/display/public/PROT/MT340D3
//
User Function MT340D3()
_aArea := GetArea()

If AllTrim(Substr(SB7->B7_DOC,1,1)) == "K"
    Replace D3_DOC  With  "K"+Dtos(dDataBase)
EndIf

RestArea(_aArea)
Return