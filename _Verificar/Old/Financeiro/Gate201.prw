#include "rwmake.ch"

User Function Gate201()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa - Funcao SetPrvt     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CVAR1,_CVAR2,_CVAR3,_CVAR4,_CVAR5,_CVAR6")
SetPrvt("_CVAR7,_CVAR8,_LDIGITA,_CLDIGITA")

// PARA QUE ESTE EXECBLOCK RODE CORRETAMENTE FAVOR SEGUIR AS INSTRUCOES ABAIXO:
// CRIAR O CAMPO E2_LDIGITA C/ 47 CARACTER, COLOCAR NO GATILHO SX7010.DBF 
// DISPARANDO PARA ELE MESMO COM A REGRA U_GATE201()
// VERIFICAR SE NO SX3_TRIGGER=S
// E NO CNAB COLOCAR O CAMPO SE2->E2_CODBAR+SE2->E2_LDIGITA.... USAR O E2_CODBAR
// SE EXISTIR A CANETA PARA LEITURA OTICA....

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GATE201  º Autor ³ RONALDO FERNANDES  º Data ³ 12/08/2002  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Entrada de dados da linha Digitavel                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Quando nao apresentar o codigo de barras                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

_cVar1 := Substr(M->E2_LDIGITA,1,5)
_cVar2 := Substr(M->E2_LDIGITA,6,5)
_cVar3 := Substr(M->E2_LDIGITA,11,5)
_cVar4 := Substr(M->E2_LDIGITA,16,6)
_cVar5 := Substr(M->E2_LDIGITA,22,5)
_cVar6 := Substr(M->E2_LDIGITA,27,6)
_cVar7 := Substr(M->E2_LDIGITA,33,1)
_cVar8 := Substr(M->E2_LDIGITA,34,14)          

//_cVar1 := " "
//_cVar2 := " "
//_cVar3 := " "
//_cVar4 := " "
//_cVar5 := " "
//_cVar6 := " "
//_cVar7 := " "
//_cVar8 := " "


@ 200, 001 TO 400, 450 DIALOG oDlg1 TITLE "Linha Digitavel"
@ 005, 008 TO 090, 220

@ 030, 010 Say "Nro. Boleto : "
@ 030, 040 GET _cVar1 PICTURE "@R 99999"
@ 030, 060 GET _cVar2 PICTURE "@R 99999"
@ 030, 080 GET _cVar3 PICTURE "@R 99999"
@ 030, 100 GET _cVar4 PICTURE "@R 999999"
@ 030, 125 GET _cVar5 PICTURE "@R 99999"
@ 030, 145 GET _cVar6 PICTURE "@R 999999"
@ 030, 170 GET _cVar7 PICTURE "@R 9"
@ 030, 175 GET _cVar8 PICTURE "@R 99999999999999"

@ 070, 140 BMPBUTTON TYPE 01 ACTION OK()

ACTIVATE DIALOG oDlg1 CENTERED

M->E2_LDIGITA:=_cldigita
Return(_cldigita)


Static Function OK()
 _cldigita := SUBSTR(_cVar1,1,4)+_cVar7+strtran(_cVar8," ","0")+SUBSTR(_cVar1,5,5)+SUBSTR(_cVar2,1,4) + _cVar3+SUBSTR(_cVar4,1,5)+_cVar5+SUBSTR(_cVar6,1,5)
 Close(Odlg1)
Return

