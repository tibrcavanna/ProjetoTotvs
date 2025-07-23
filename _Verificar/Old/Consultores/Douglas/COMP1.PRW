#Include "rwmake.ch"
#Include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCARSD3SC2 บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CARSD3SC2()

Local cPerg := "CASD3SC201"

PutSx1(cPerg,"01","Data de  ?","","","mv_ch1","D",8,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"02","Data ate ?","","","mv_ch2","D",8,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"03","Op de    ?","","","mv_ch3","C",13,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",,,,"")
PutSx1(cPerg,"04","Op ate   ?","","","mv_ch4","C",13,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",,,,"")

If !Pergunte(cPerg,.T.)
   Return
Endif   		
                
CriaTRB()

_cQuery := " SELECT * FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) "
_cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"' AND SD3.D_E_L_E_T_ = ' ' "
_cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+Dtos(mv_par01)+"' AND '"+Dtos(mv_par02)+"' "
_cQuery += " AND SD3.D3_OP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' "

If Select("QUESD3") > 0
	dbCloseArea()
EndIf

TCQUERY _cQuery NEW ALIAS "QUESD3"

dbSelectarea("QUESD3")
dbSetOrder(1)
dbGotop()
While !Eof()
	_aAreaSD3 := GetArea()
	
	_cCodigo := Rtrim(QUESD3->OP)
	
	dbSelectArea("TRB")
	dbSetOrder(1)
	RecLock("TRB",.T.)
	TRB->FILIAL     := xFilial("SD3")
	TRB->TIPO       := QUESD3->D3_TIPO
	TRB->COD        := QUESD3->D3_COD
	TRB->EMISSAO    := Stod(QUESD3->D3_EMISSAO)
	TRB->UM         := QUESD3->D3_UM
	TRB->QUANT      := QUESD3->D3_QUANT
	TRB->CUSTO1     := QUESD3->D3_CUSTO1
	TRB->D3_CF      := QUESD3->D3_CF
	TRB->D3_OP      := QUESD3->D3_OP
	TRB->DESC       := GetAdvFVal("SB1","B1_DESC",xFilial("SB1")+QUESD3->D3_COD,1)
	TRB->TPPROD     := GetAdvFVal("SB1","B1_TIPO",xFilial("SB1")+QUESD3->D3_COD,1)
	TRB->LOCPAD     := QUESD3->D3_LOCAL
	TRB->DTREALFIM  := Stod(GetAdvFVal("SC2","C2_DATRF",xFilial("SC2")+_cCodigo,1))
	MsUnLock()
	
	RestArea(_aAreaSD3)
	dbSkip()
	
EndDo

dbSelectArea("TRB") 
COPY TO DOUGLAS.DBF
dbCloseArea() 

dbSelectArea("QUESD3")
dbCloseArea() 

Alert("Termino")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaTRB   บAutor  ณMicrosiga           บ Data ณ  02/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria TRB                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CriaTRB()

//+----------------------------------------------------------
//| Cria o arquivo Temporario - TRB
//+----------------------------------------------------------
aStru := {}
aTam:=TamSX3("D3_TIPO")
aAdd(aStru,{ "TIPO"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_EMISSAO")
aAdd(aStru,{ "EMISSAO"     ,"D",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_COD")
aAdd(aStru,{ "COD"     ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_UM")
aAdd(aStru,{ "UM"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_QUANT")
aAdd(aStru,{ "QUANT"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_CF")
aAdd(aStru,{ "CF"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_OP")
aAdd(aStru,{ "OP"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B1_DESC")
aAdd(aStru,{ "DESC"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B1_TIPO")
aAdd(aStru,{ "TPPROD"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D3_LOCAL")
aAdd(aStru,{ "LOCPAD"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("C2_DATRF")
aAdd(aStru,{ "DTREALFIM" ,"D",aTam[1],aTam[2] } )

_cArqTRB := Criatrab(aStru,.T.)
dbUseArea(.T.,,_cArqTRB,"TRB",.F.,.F.)

IndRegua("TRB",_cIndTRB,"FILIAL+COD",,,"Criando Indice ...")

Return
