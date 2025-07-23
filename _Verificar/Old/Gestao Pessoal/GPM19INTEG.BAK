#Include 'Protheus.ch'

User Function GPM19INTEG()

Local aAreaRGB := RGB->( GetArea("RGB") )
Local cPd := ""
Local nValor := 0
Local cPerFol := aRotMark[1,3] // Periodo
Local cSemFol := aRotMark[1,5] // Semana
Local cProc := aRotMark[1,1] // Processo
Local cRoteiro := aRotMark[1,2] // Roteiro
Local cRGBSeek := ""
Local nIndice := RetOrder( "RGB", "RGB_FILIAL+RGB_MAT+RGB_PD+RGB_PERIOD+RGB_SEMANA+RGB_SEQ" )

DbSelectArea("SRC")
SRC->( DbSetOrder(1) )

While SRC->( !Eof() )

DbSelectArea("RGB")
RGB->( DbSetOrder( nIndice ) )
If !( SRC->( DbSeek( xFilial("RGB") + SRC->RC_MAT + SRC->RC_PD + cPerFol + "01", .F. ) ) )
RGB->( RecLock( "RGB" , .T. ) )
RGB->RGB_FILIAL := xFilial("RGB")
RGB->RGB_MAT := SRC->RC_MAT
RGB->RGB_CC := SRC->RC_CC
RGB->RGB_PD := SRC->RC_PD
RGB->RGB_HORAS := 0
RGB->RGB_VALOR := SRC->RC_VALOR
RGB->RGB_PARCEL := 0
RGB->RGB_PROCES := cProc
RGB->RGB_PERIOD := cPerFol
RGB->RGB_ROTEIR := cRoteiro
RGB->RGB_SEMANA := "01"
RGB->RGB_ROTORI := cRoteiro
RGB->( MsUnlock() )
EndIf


SRC->( DbSkip() )
EndDo

RGB->( DbCloseArea() )
SRC->( DbCloseArea() )

RestArea( aAreaRGB )
Return(.T.)

