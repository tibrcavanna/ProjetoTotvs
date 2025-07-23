#Include 'rwmake.ch'
#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"
//_____________________________

User Function GERASZ3()

LOCAL aSAY    := {}
LOCAL aBUTTON := {}
LOCAL nOPC    := 0
LOCAL cTITULO := "Geração da Tabela SZ3 "
LOCAL cDESC1  := "Este programa tem como objetivo - Gerar a Tabela SZ3 "
LOCAL cDESC2  := " - Intermediária de exportação de dados SD1 "

AADD( aSAY, cDESC1 )
AADD( aSAY, cDESC2 )

AADD( aBUTTON, { 1, .T., {|| nOPC := 1, FECHABATCH() }} )
AADD( aBUTTON, { 2, .T., {|| nOPC := 0, FECHABATCH() }} )

FORMBATCH( cTITULO, aSAY, aBUTTON )

IF nOPC == 1
	PROCESSA( {|| U_PROCSZ3()}, "Aguarde...","Executando rotina.....", .T. )
ENDIF

Return

//______________________________________________
User Function PROCSZ3()


 TCSQLExec("Delete From SZ3010")
 
	////////////////////////////////////////////////////////
	dbSelectArea("SD1")
	_cSD1 := "SD1TMP"
	Iif(Select("SD1TMP")>0,SD1TMP->(DbCloseArea()),)
	
	_cQuery := "SELECT * "
	_cQuery += " FROM "+RetSqlName("SD1") +" SD1TMP "
	_cQuery += " WHERE   D1_FILIAL = '"+xfilial("SD1")+"' "
//	_cQuery += " AND D1_PEDLN <> 0  "
	_cQuery += " AND D_E_L_E_T_<>'*' "

	_cQuery := ChangeQuery(_cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),_cSD1,.T.,.T.)
	                                                
	

	///////////////////////////////////////////////////
	
	dbSelectArea(_cSD1)
	PROCREGUA(LastRec())
	
	SD1TMP->(dbGotop())
	While ! SD1TMP->(eof())

		IncProc()

		RecLock("SZ3",.T.)

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SZ3")
		While ! SX3->(eof()) .and. X3_ARQUIVO == "SZ3"

			_cCampo := "SD1TMP->D1_"+substr(X3_CAMPO,4,7)
			_cCampo := alltrim(_cCampo)

			if SZ3->( FieldPos(SX3->X3_CAMPO) ) > 0			
				SZ3->( FieldPut( SZ3->(FieldPos(SX3->X3_CAMPO)),&_cCampo) )
			Endif    

			SX3->(dbSkip())

		End

		SZ3->(dbCommit())
		SZ3->(MsUnLock())

		SD1TMP->(dbSkip())

	End

Return

