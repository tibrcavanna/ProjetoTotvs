/*
+----------------------------------------------------------------------------+
!                         FICHA TECNICA DO PROGRAMA                          !
+----------------------------------------------------------------------------+
!   DADOS DO PROGRAMA                                                        !
+------------------+---------------------------------------------------------+
!Tipo              ! Miscelanea                                              !
+------------------+---------------------------------------------------------+
!Modulo            ! Contabilidade Gerencial e Financeiro                    !
+------------------+---------------------------------------------------------+
!Nome              ! MOEDAS001                                               !
+------------------+---------------------------------------------------------+
!Descricao         ! Atualiza e Projeta Moedas/Cambio                        !
!                  !                                                         !
!                  ! Colocar as linhas abaixo no APPSERVER.INI               !
!                  ! [ONSTART]                                               !
!                  ! jobs=Moedas                                             !
!                  ! RefreshRate=86400                                       !
!                  !                                                         !
!                  ! [Moedas]                                                !
!                  ! main=U_MOEDAS001                                        !
!                  ! Environment=JOB                                       !
!                  !                                                         !
!                  ! Fonte retirado da internet e modificado conforme neces- !
!                  ! sidade da empresa                                       !
+------------------+---------------------------------------------------------+
*/

#include 'protheus.ch'
#include "topconn.ch"

User Function MOEDAS001(_aMoedas,lAuto,_dDtAtual,lPtax)

	Private lAuto
	Private dDataRef, dData
	Private nValReal  := 1.000000
	Private nValUfir  := 0 
	Private nN         := 0
	Private nS1, nS2, nS3
	Private nI1, nI2, nI3
	Private oDlg
	Private nDiasPro  := 10
	Private nDiasreg  := 10
	Private aMoedas    := {} 
	Private aNMoedas    := {}
	Default lAuto    := .F.                   
	Default  lPtax    := .F.
	Default _dDtAtual   := iif(Empty(_dDtAtual),date(),_dDtAtual)
	Private nValorC    := 0
	Private nValorV    := 0
	dData := _dDtAtual

	U_AtuMoedas()
  /* RETIRADO PARA AJUSTES HUGO PIERONI
	if valType("_aMoedas")<>"U"
		if(!Empty(_aMoedas))
			aMoedas := _aMoedas
		Endif
	Endif

	//Testa se esta sendo rodado do menu
	If  Select('SX2') == 0            
		RPCSetType( 3 )            //Não consome licensa de uso
		RpcSetEnv('01','01',,,,GetEnvServer(),{ "SM2","SYE" })
		sleep( 5000 )            //Aguarda 5 segundos para que as jobs IPC subam.
		lAuto := .F.
	EndIf

	If  ( lAuto )               
		LjMsgRun(OemToAnsi('Atualizacao On-line de moedas (Banco Central do Brasil)'),,{|| fAtuaMoeda(lAuto,"SM2")} )
	Else
		//Atualizacao tabela SM2
		aMoedas := faaMoedas() //pego as informaacoes necessarias das moedas que utilizo

		DbSelectArea("SM2")
		SM2->(DbSetorder(1))
		ConOut('Verifica se existe registro na SM2')
		If SM2->(DbSeek(Dtos(dDataBase)))           
			ConOut('Verifica se existe valor na moeda4')                 
			if(SM2->M2_MOEDA4==0)
				ConOut('Iniciando atualização de Moedas SM2... '+Dtoc(dDatabase)+' - '+Time())
				fAtuaMoeda(lAuto,"SM2")                               
				ConOut('Moedas SM2 Atualizadas. '+Dtoc(dDatabase)+' - '+Time())
			Else
				ConOut('Nao eh necessario atualizacao, tabela SM2 ja atualizada!')
			Endif
		Else                                       
			ConOut('Iniciando atualizacao de Moedas SM2... '+Dtoc(dDatabase)+' - '+Time())
			fAtuaMoeda(lAuto,"SM2")                               
			ConOut('Moedas SM2 Atualizadas. '+Dtoc(dDatabase)+' - '+Time())
		Endif    
		RpcClearEnv()               //Libera o Ambiente
	EndIf
/*/
Return

Static Function fAtuaMoeda(lAuto,cAlias)

	Local nPass, cFile, cTexto, nLinhas, cLinha, cdata, cCompra, cVenda   
	Local cFile   := ""
	Local aLinha  := {}
	Local cMoeda  := ""
	Local nArquivo:= 0
	Local cArqImpor := "\moedas\moedasbcb.csv"
	Local nHdl
	Local nTamArq
	Local nTamLinha
	Local nLinhas
	Local nPass := IIF(cAlias=="SM2",1,2)    //Se moeda padrao do sistema, basear em um dia util anterior,caso contrario (PTAX) em 2 dias uteis anterior a data informada 
	Local cMesDia   := ""
	Local aFeriados := {}
	Local i := 0
	Local nW := 0

	dDataRef := ( dData - nPass )
	if Dow(dDataRef)==1 //domingo        
		dDataRef:= dData -3
	Endif

	//no código original, era chumbado todos os feriados
	//estarei usando a tabela DV8 para cadastrar meus feriados e dias bancarios nao trabalhados
	//Feriados Bancário Fixo
	dbSelectArea("DV8")
	DV8->(dbSetOrder(1))
	DV8->(dbGoTop())
	While DV8->(!EOF())  
		cMesDia := Left(DV8->DV8_DIAMES,2)+Right(DV8->DV8_DIAMES,2)
		aadd(aFeriados,cMesDia)
		DV8->(dbSkip())
	End
	DV8->(dbCloseArea())

	For i:= 1 to len(aFeriados)
		if Dtos(dDataRef) == STR(Year(Date()),4)+aFeriados[i]
			dDataRef:= dDataRef - 1

			If  Dow(dDataRef) == 1    //Se for domingo
				cFile := Dtos(dDataRef - 2)+'.csv'
			ElseIf  Dow(dDataRef) == 7  //Se for sabado
				cFile := Dtos(dDataRef - 1)+'.csv'
			Else            //Se for dia normal
				cFile := Dtos(dDataRef)+'.csv'  
			EndIf
		Endif  
	Next     
	if(Empty(cFile))
		If  Dow(dDataRef) == 1    //Se for domingo
			cFile := Dtos(dDataRef - 2)+'.csv'
		ElseIf  Dow(dDataRef) == 7  //Se for sabado
			cFile := Dtos(dDataRef - 1)+'.csv'
		Else            //Se for dia normal
			cFile := Dtos(dDataRef)+'.csv'  
		EndIf
	Endif

	//armazena-se o conteudo do arquivo pego no banco central
	cTexto  := HttpGet('http://www4.bcb.gov.br/Download/fechamento/'+cFile)

	nArquivo := FCreate( cArqImpor, 0 )    
	FWrite( nArquivo , cTexto)
	fClose( nArquivo ) 
	If  ( !lAuto )
		ConOut('DownLoading from BCB '+cFile+' In '+Dtoc(Date()))
	EndIf
	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	nHdl := fOpen(cArqImpor)
	If nHdl == -1 
		IF FERROR()== 516 
			If  ( lAuto )
				ALERT("Feche a planilha que gerou o arquivo.")
			ENDIF
			ConOut("Feche a planilha que gerou o arquivo.")
		EndIF
	EndIf

	//+---------------------------------------------------------------------+
	//| Verifica se foi possível abrir o arquivo                            |
	//+---------------------------------------------------------------------+
	If nHdl == -1
		cMsg := "O arquivo de nome "+cArqImpor+" nao pode ser aberto! Verifique os parametros."
		If  ( lAuto )
			MsgAlert(cMsg,"Atencao!")
		ENDIF
		ConOut(cMsg)
		Return
	Endif

	//+---------------------------------------------------------------------+
	//| Posiciona no Inicio do Arquivo                                      |
	//+---------------------------------------------------------------------+
	FSEEK(nHdl,0,0)

	//+---------------------------------------------------------------------+
	//| Traz o Tamanho do Arquivo TXT                                       |
	//+---------------------------------------------------------------------+
	nTamArq:=FSEEK(nHdl,0,2)

	//+---------------------------------------------------------------------+
	//| Posicona novamemte no Inicio                                        |
	//+---------------------------------------------------------------------+
	FSEEK(nHdl,0,0)

	//+---------------------------------------------------------------------+
	//| Fecha o Arquivo                                                     |
	//+---------------------------------------------------------------------+
	fClose(nHdl)
	FT_FUse(cArqImpor)  //abre o arquivo 
	FT_FGOTOP()         //posiciona na primeira linha do arquivo      
	nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := Int(nTamArq/nTamLinha)

	ProcRegua(nLinhas)                                                                
	aDados:={}        
	nCont := 0
	While !FT_FEOF()// .and. ncont < 16 

		IncProc('Validando Linha: ' + Alltrim(Str(nCont)) )

		aTab := {}
		clinha := FT_FREADLN() 

		if(At("<!",cLinha)>0)
			MsgStop("Nao foi encontrado no Banco Central o arquivo correspondente ("+cFile+")")
			Return
		Endif

		aLinha  := Separa(cLinha,";",.T.)
		cData   := aLinha[1]                
		cMoeda  := aLinha[2]                
		cCompra := aLinha[5] 
		cVenda  := aLinha[6] 
		For nW := 1 to len(aMoedas)     
			If  ( cMoeda==aMoedas[nW,2] )
				nValor  := "nVal"+aMoedas[nW,1]+Alltrim(aMoedas[nW,3])
				&nValor  := Val(StrTran(cVenda,",","."))
				If(!Empty(aMoedas[nW,4]))
					nValor  := "nVal"+aMoedas[nW,1]+Alltrim(aMoedas[nW,4])    
					&nValor  := Val(StrTran(cCompra,",","."))
				Endif
				nValorV  := Val(StrTran(cVenda,",","."))
				nValorC  := Val(StrTran(cCompra,",","."))

				AADD(aNMoedas,{aMoedas[nW,1],aMoedas[nW,2],aMoedas[nW,3],aMoedas[nW,4]})
			EndIf
		Next    
		FT_FSKIP()
		nCont++
	EndDo
	FT_FUse()
	fClose(nHdl)

	if len(aNMoedas) > 0
		GravaDados()
		If  ( lAuto )
			LjMsgRun(OemToAnsi("Atualizado Moedas e Cambio!"),,{|| } )
		Endif
	Else
		cAviso:= "Ocorreu um erro ao atualizar Moedas! Arquivo "+cFile+" nao encontrado em "+Dtoc(Date())
		ConOut(cAviso)
		If  ( lAuto )
			LjMsgRun(OemToAnsi(cAviso),,{|| } )
		EndIf          
	Endif

Return

Static Function GravaDados()

	Local lGrava                                                                    
	Local cMoFin1
	Local cnMoeda1
	Local nValor1
	Local cMoFin2
	Local cnMoeda2
	Local nValor2
	Local nW := 0

	DbSelectArea("SM2")        
	SM2->(DbSetorder(1))
	lGrava := SM2->(DbSeek(Dtos(dData)))  
	Reclock('SM2',!lGrava)
	SM2->M2_DATA    := dData
	SM2->M2_MOEDA1  := nValReal
	SM2->M2_MOEDA3  := 0.8287    
	cnMoeda  := ""

	For nW := 1 to len(aNMoedas)  

		cMoFin1  := Alltrim(Posicione("SYF",1,xFilial("SYF")+aNMoedas[nW,1],"YF_CODVERP"))
		cnMoeda1 := "SM2->M2_MOEDA"+cMoFin1
		nValor1  := "nVal"+aNMoedas[nW,1]+Alltrim(aNMoedas[nW,3])

		if(cnMoeda1!="SM2->M2_MOEDA0")
			&cnMoeda1 := &nValor1 
		endif                       

		cMoFin2 := Alltrim(Posicione("SYF",1,xFilial("SYF")+aNMoedas[nW,1],"YF_CODCERP"))

		if(cMoFin2!="0")
			cnMoeda2 := "SM2->M2_MOEDA"+cMoFin2
			nValor2  := "nVal"+aNMoedas[nW,1]+Alltrim(aNMoedas[nW,4])
			&cnMoeda2 := &nValor2         
		Endif 

	Next
	
	SM2->M2_INFORM  := "S"
	
	MsUnlock('SM2')
	SM2->(dbCloseArea())

	BEGIN TRANSACTION  

		If CtbInUse()
			GrvCTBCTP(dData)
		EndIf  

	END TRANSACTION   

Return

Static Function GrvCTBCTP(dData,cMoeda)

	Local aSaveArea := GetArea()
	Local cVal
	Local cBloq
	Local nTaxa
	Local nCont    
	Local nQtas := iif( __nQuantas < 5 , 5 , __nQuantas )  
	Local lGrava

	/*Grava CTP -> quando estiver usando SIGACTB*/

	If ChkFile("CTP") .And. ChkFile("CTO")
		For nCont  := 1 To nQtas
			cMoeda    := StrZero(nCont,2)
			cVal    := Alltrim( Str( nCont ))
			nTaxa    := CriaVar("CTP_TAXA",.T.)
			cBloq    := CriaVar("CTP_BLOQ",.T.)
			If ChkFile("CTO")
				dbSelectArea("CTO")
				dbSetOrder(1)
				If dbSeek( xFilial() + cMoeda )
					If ChkFile("CTP")
						dbSelectArea("CTP")
						dbSetOrder(1) 
						lGrava := CTP->(dbSeek( xFilial() + DTOS(dData) + cMoeda ))
						RecLock("CTP",!lGrava)
						Replace CTP_FILIAL    With xFilial()
						Replace CTP_DATA    With dData
						Replace CTP_MOEDA    With cMoeda
						Replace CTP_BLOQ    With cBloq        // Taxa Nao Bloqueada

						If Empty(&("SM2->M2_MOEDA"+cVal))
							Replace CTP_TAXA  With nTaxa
						Else  
							Replace CTP_TAXA   With &("SM2->M2_MOEDA"+cVal)
						EndIf  
						MsUnlock()
						dbCommit()
					EndIf  
				EndIf  
			EndIf  
		Next nCont
	EndIf   

	RestArea(aSaveArea)

Return                    

Static Function faaMoedas()

//	Local aMoeSis   := {}
//	Local cCampo    := ""
	Local aaMoedas  := {}
	Local cQuery    := ""
//	Local i := 0
//	Local _aCodMoe := SUPERGETMV("MV_ATUMOED",,"2,4,6,7")

//	aMoeSis := StrTokArr(_aCodMoe,",")

//	dbSelectArea("SX3")      
	
	
//	For i := 1 to len(aMoeSis) 
//		cCampo := "M2_MOEDA"+Substr(Alltrim(aMoeSis[i]),1,1)
//		SX3->(dbSetOrder(2))
//		SX3->(dbGoTop())
//		If SX3->(dbSeek(@cCampo))
			cQuery := "SELECT * FROM " + RetSQLName("SYF") + " WHERE D_E_L_E_T_='' AND YF_FILIAL='"+xFilial("SYF")+"' AND YF_MOEFAT <> 0 ORDER BY YF_MOEDA"

			If ( SELECT("TMP") ) > 0
				dbSelectArea("TMP")
				TMP->(dbCloseArea())
			EndIf

			TCQUERY cQuery NEW ALIAS "TMP"                        

			if TMP->(!EOF())          
				While TMP->(!EOF())          
					Aadd(aaMoedas, {TMP->YF_MOEDA,TMP->YF_COD_GI,TMP->YF_CODVERP,TMP->YF_CODCERP} )
					TMP->(dbSkip())
				EndDo
			Endif   

//		Endif
//	Next

Return(aaMoedas)
