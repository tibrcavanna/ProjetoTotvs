#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 

User Function Fecham()

// Disponibilizacao de alteracao dos Parametros
// MV_DATAFIN = Financeiro
// MV_DATAFIS = FIscal/Compras
// MV_DBLQMOV = FIscal/Compras
// Pelo Usuario Contabil

Private dDataFin  := dDataFinAnt:=GETMV("MV_DATAFIN")
Private dDataFis  := dDataFisAnt:=GETMV("MV_DATAFIS")
Private dDataEst  := dDataEstAnt:=GETMV("MV_DBLQMOV")
Private dDtFchEst := GETMV("MV_ULMES")
Private cHorasNfe := GETMV("MV_SPEDEXEC")

Private oDlgFecha
SET CENTURY ON
@ 230,215 To 410,635 Dialog oDlgFecha Title OemToAnsi("Fechamento Contabil")
@ 9,5 Say OemToAnsi("Esta Rotina tem por objetivo permitir o fechamento dos modulos Financeiro/Compras/Faturamento/Estoque,") Size 214,18
@ 23,4 Say OemToAnsi("nao permitindo alteracoes com data inferior ao determinado.") Size 214,14
@ 37,20 Say OemToAnsi("Data Limite Financeiro") Size 78,8
@ 48,20 Say OemToAnsi("Data Limite Compras") Size 78,8
@ 59,20 Say OemToAnsi("Data Limite Estoque") Size 78,8
@ 70,20 Say OemToAnsi("Data Fech. Estoque") Size 78,8
@ 90,20 Say OemToAnsi("Horas Cancelamento NFE") Size 78,8
@ 37,98 Get dDataFin Size 76,10
@ 48,98 Get dDataFis Size 76,10
@ 59,98 Get dDataEst Size 76,10
@ 70,98 Get dDtFchEst Size 76,10
@ 90,98 Get cHorasNfe Size 76,10
@ 80,96  BMPBUTTON TYPE 1 ACTION GRVFEC()         OBJECT oButtOK
@ 80,138 BMPBUTTON TYPE 2 ACTION FECHADLG()       OBJECT oButtCc

ACTIVATE DIALOG oDlgFecha CENTERED

Return Nil

Static Function GRVFEC()            

dbSelectArea("SX6")
dbSetOrder(1)

PutMV ("MV_DATAFIN",  DTOC(dDataFin)) 
PutMV ("MV_BXDTFIN",  DTOC(dDataFin))
PutMV ("MV_DATAFIS",  DTOC(dDataFis))
PutMV ("MV_DBLQMOV",  DTOC(dDataEst))
PutMV ("MV_ULMES"  ,  DTOC(dDtFchEst))
PutMV ("MV_SPEDEXEC", DTOC(cHorasNfe))

SET CENTURY OFF
MsgInfo("Alteracao Efetuada!", "FECHAM")

Close(oDlgFecha)

Return Nil                      

Static Function FECHADLG()                   

SET CENTURY OFF
Close(oDlgFecha)

Return Nil
