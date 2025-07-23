#Include "rwmake.ch"
#Include "topconn.ch"

User Function COMP2()    

WfPrepEnv("01","01")

dbUseArea(.T.,,"\SYSTEM\FINAIS.DBF","TRB",.F.,.F.) // CLIENTES
cIndex := CriaTrab(nil,.f.)
cKey   := "TRB->COD"
IndRegua("TRB",cIndex,cKey,,,"Selecionando registros...")

Processa({||COMP2a()})

Return

Static Function COMP2a()


dbSelectarea("TRB")
dbSetOrder(1)
dbGotop()
While !Eof()
	_aAreaSB2 := GetArea()
	_cCodigo := Rtrim(TRB->COD) 
	_cEnder := Rtrim(TRB->ENDER) 
	
	
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+Rtrim(_cCodigo))   
	        RecLock("SB2",.F.) 
	        SB2->B2_LOCALIZ := _cEnder
	        MsUnLock()
	EndIf	   
	
	RestArea(_aAreaSB2)
	dbSkip()
	
EndDo

dbSelectArea("TRB")
dbCloseArea()


Alert("Termino")

Return


/*/
Static Function CriaTRB

//+----------------------------------------------------------
//| Cria o arquivo Temporario - TRB
//+----------------------------------------------------------
aStru := {}
aTam:=TamSX3("F2_FILIAL")
aAdd(aStru,{ "FILIAL"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_VEND1")
aAdd(aStru,{ "VEND"     ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("A3_NOME")
aAdd(aStru,{ "NOMEVEN"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B1_GRUPO")
aAdd(aStru,{ "GRUPO"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B1_COD")
aAdd(aStru,{ "PRODUTO"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B1_XCODOLD")
aAdd(aStru,{ "CODOLD"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("B1_DESC")
aAdd(aStru,{ "DESC"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_DOC")
aAdd(aStru,{ "DOC"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_QUANT")
aAdd(aStru,{ "QUANT"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_PRCVEN")
aAdd(aStru,{ "PRCVEN"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_TOTAL")
aAdd(aStru,{ "TOTAL"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_TES")
aAdd(aStru,{ "TES"   ,"C",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_QTDEDEV")
aAdd(aStru,{ "QTDEDEV"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("D2_VALDEV")
aAdd(aStru,{ "VALDEV"   ,"N",aTam[1],aTam[2] } )
aTam:=TamSX3("F2_COND")
aAdd(aStru,{ "COND"   ,"C",aTam[1],aTam[2] } )
aAdd(aStru,{ "PZMEDIO"   ,"N", 10, 02} )   //Total dias pz. medio
aAdd(aStru,{ "PZMEDCX"   ,"N", 14, 02} )   //Pz. medio caixa acumulado em dias
aAdd(aStru,{ "TPZMEDCX"   ,"N", 14, 02} )   //QTDE X PZ.MEDIO -> PZMEDIO*PZMEDCX)

aAdd(aStru,{ "QTDDEV"   ,"N", 14, 02} )   //QTDE X PZ.MEDIO -> PZMEDIO*PZMEDCX)
aAdd(aStru,{ "VALORDEV" ,"N", 14, 02} )   //QTDE X PZ.MEDIO -> PZMEDIO*PZMEDCX)

aTam:=TamSX3("D2_DESCON")
aAdd(aStru,{ "DESCON"   ,"N",aTam[1],aTam[2] } )
aAdd(aStru,{ "PARTIC"   ,"N", 6, 02} )   //Participacao na venda
aAdd(aStru,{ "VALBONI"  ,"N", 14, 02} )  //VLR.  Bonificacao
aAdd(aStru,{ "QTDBONI"  ,"N", 14, 02} )  //QTDE. Bonificacao
aAdd(aStru,{ "QTPVABEV"  ,"N", 10, 02} )  //Qtde. vendida em aberto VIRADA
aAdd(aStru,{ "QTBNABEV"  ,"N", 10, 02} )  //Qtde. Bonus   em aberto VIRADA
aAdd(aStru,{ "QTENTDIA" ,"N", 10, 02} )  //Qtde. pvs. que entrou no dia
aAdd(aStru,{ "QTPVABEM"  ,"N", 10, 02} )  //Qtde. vendida em aberto MES
aAdd(aStru,{ "QTBNABEM"  ,"N", 10, 02} )  //Qtde. Bonus   em aberto MES
aAdd(aStru,{ "VLPVABEM"  ,"N", 14, 02} )  //Vlr. total aberto Mes.
aAdd(aStru,{ "DTEMIS"    ,"D",  8, 02} )  //Vlr. total aberto Mes.

_cArqTRB := Criatrab(aStru,.T.)
dbUseArea(.T.,,_cArqTRB,"TRB",.F.,.F.)

If nOrdem == 1  // Resumo Geral
	IndRegua("TRB",_cIndTRB,"FILIAL+GRUPO+PRODUTO",,,"Criando Indice ...")
Else  // Por Vendedor
	IndRegua("TRB",_cIndTRB,"FILIAL+VEND+GRUPO+PRODUTO",,,"Criando Indice ...")
Endif

Return
/*/
