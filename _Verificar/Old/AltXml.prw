#include "rwmake.ch"
#include "Protheus.ch"
#INCLUDE "XMLXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ALTXML    ºAutor  ³Microsiga           º Data ³  12/19/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Altera a estrutura de arquivos xml.                       º±±
±±º          ³  Deve ser crido um diretorio chamado XML detro de Prothe_data
±±º          ³  os arqwuivo de serem criado de tro do mesmo               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


USER FUNCTION ALtxml()
Local aArq:= DIRECTORY( ( "\XML\*.XML" ) , "\" )
Private cPath:="\XML\"
FOR I   := 1 TO LEN( aArq )
	cArq := ALLTRIM( aArq[ I , 1 ] )
	XMLNfe(cArq)
NEXT I
Msgbox("Todos arquivo XML foram alterados!","","INFO")
Return

Static Function XMLNfe(cArq)
Local nHdl
Local nTamArq
Local nTamLin
Local nBytesLidos
Local cLinha
Local cTexto
Local cEOL
Local cError   := ""
Local cWarning := ""
Local oXml     := NIL
Local cVer     :=""

nHdl := FOpen(cPath+cArq,2)
cEOL := Chr(13)+Chr(10)

If nHdl == -1
	MsgAlert("O arquivo de nome " + cArq + " nao pode ser aberto!", "Atencao!")
	Return
EndIf

nTamArq := FSeek(nHdl, 0, 2)                  // Posiciona o ponteiro no final do arquivo.
FSeek(nHdl, 0, 0)                             // Volta o ponteiro para o inicio do arquivo.
nTamLin     := 252+ Len(cEOL)                 // Tamanho da linha = 43 + 2 ref. ao Chr(13)+Chr(10)
cLinha      := Space(nTamLin)                 // Variavel que contera a linha lida.
nBytesLidos := FRead(nHdl, @cLinha, nTamLin)  // Le uma linha.
cTexto      := ""
While nBytesLidos >= nTamLin
	
	FWrite(nHdl,'2.00.xsd" versao="2.00"',252)   // Aqui altera o cabeçalho
	Exit
	nBytesLidos := FRead(nHdl, @cLinha, nTamLin)
End
FClose(nHdl)
// Abertura XML
oXml := XmlParserFile( cPath+cArq, "_", @cError, @cWarning )
oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_VERPROC:TEXT:='2.00'   // Aqui altera a parte do IDE:VERPROC
SAVE oXML XMLFILE cPath+cArq
Return Nil


