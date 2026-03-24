#include 'protheus.ch'
#include 'TopConn.ch'

//Static lDescCar := (SRC->(FieldPos('R7_DESCCAR')>0))

user function xpocCav()
	Local lOpened := Type("oMainWnd") == "O"
	SET DELE ON
//chamada direto do programa inicial, fora do Menu
	cMyFil:='02'
	If !lOpened// fwIsInCallStack('SIGAIXB')
		RpcSetType( 3 )
		OpenSM0()
		RpcSetEnv(M0_CODIGO, M0_CODFIL,,,,,,,,.T.) //funciona
	EndIf

	U_rotolare('ImportItems')
	//U_rotolare('ExportLists')
	//U_rotolare('ImportLists')

return
