#INCLUDE "rwmake.ch"
#include "tbiconn.ch"
#Include "TOPCONN.ch"
#Include "Protheus.ch"
// Ajustar Group by query das estruturas

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±³Programa  ³  FB101PCP  Autor ³Claudio H. Ferreira    ³Data  ³03.09.2015³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importa dados da tabela temporaria para o protheus. 	      º±±
±±º          ³                                               	          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Mepel                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function FB101PCP(_lauto)

	if 'SCHEDULE' $ Upper(Alltrim(GetEnvServer()))
		conout("##Iniciando processo inclusao importacao de dados CAD - FB101PCP")
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '010101' MODULO 'PCP' USER 'Administrador' PASSWORD 'totvsmepel' TABLES 'SG2,SB1,SG1'
		procprod() //Processa produtos
	

		procestrut() //processa estrutura
	

		procOpr()	//processa operacoes
		conout("##FIM rocesso inclusao importacao de dados CAD - FB101PCP")
	else
	
		// Dataroute.herminio em 06/02/2018	
		//Processa({|| Procimp() },"Efetuando Importações...")
		ProcImp()
	endif
	
	

Return

Static Function Procimp()

	// Dataroute.herminio em 06/02/2018
	// alteradas chamadas das funcoes para controlar a regua por operacao!
	
	lRet := MsgYesNo("Confirma a execução das rotinas de importação?","[FB101PCP] - Importação Solid-Totvs")

	If lRet
		
	// Procregua(3)

	//IncProc()
	//procprod() //Processa produtos
		Processa({|| procprod() },"Efetuando importações do cadastro de produtos... Etapa 01 de 03","Aguarde...",.F.)
	
	
	//IncProc()
	//procestrut() //processa estrutura
		Processa({|| procestrut() },"Efetuando importações do cadastro de estruturas... Etapa 02 de 03","Aguarde...",.F.)
	
	
	//IncProc()
	//procOpr()	//processa operacoes
		Processa({|| procOpr() },"Efetuando importações do cadastro de operacoes... Etapa 03 de 03","Aguarde...",.F.)
	
	EndIf

return


/*
Busco os dados na tabela temporaria - produtos
*/
static Function procprod()

	Local _cQuery := ""
	Local _aArea     := GetArea()
	Private lMsErroAuto := .t.
	Private lMsHelpAuto := .F.
	private l010Auto := .t.
	
	conout("##Buscando dados ...  - FB101PCP")
	_cQuery += " SELECT * "
	_cQuery += " FROM   [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.PRODUTOS PROD"
	_cQuery += " WHERE  PROD.IMPORT = 'N' AND PROD.FAMILIA <> ''"
	
	MEMOWRITE("C:\Temp\FB101PCP.txt", _cQuery)
	conout(_cQuery)
	TcQuery _cQuery new alias "_TRB"

	// Dataroute.herminio em 06/02/2018
	nTotReg := Contar("_TRB","!Eof()")
	_TRB->(DbGoTop())
	Procregua(nTotReg)

	DBSELECTAREA("SB1")
	SB1->(dbsetorder(1))
	
	nTotNum := 0
	
	While !_TRB->(EoF())

		// Dataroute.herminio em 06/02/2018
		nTotNum += 1
		IncProc("Importando... "+str(nTotNum)+" / "+str(nTotReg))

		If !(SB1->(dbseek(xfilial("SB1") + _TRB->B1_COD)))
			_aAuxCab := {}
			DBSELECTAREA("SBR")
			SBR->(dbsetorder(1))
			If (SBR->(dbseek(xfilial("SBR") + _TRB->FAMILIA)))
			
				aAdd(_aAuxCab,{"B1_FILIAL"		, xFilial("SB1")   	,NIL})
				aAdd(_aAuxCab,{"B1_COD"			, _TRB->B1_COD   	,".T."})
				aAdd(_aAuxCab,{"B1_GRUPO"		, _TRB->B1_GRUPO   	,NIL})
				aAdd(_aAuxCab,{"B1_PESO"		, _TRB->B1_PESO   	,NIL})
				aAdd(_aAuxCab,{"B1_PESBRU"		, _TRB->B1_PESBRU   ,NIL})
				//aAdd(_aAuxCab,{"B1_DESC"		, alltrim(_TRB->B1_DESC)   	,NIL})
				aAdd(_aAuxCab,{"B1_DESC"		, Left(_TRB->B1_DESC,120)  	,NIL})
				aAdd(_aAuxCab,{"B1_MDESC"		, _TRB->B1_DESC   	,NIL})
			
				aAdd(_aAuxCab,{"B1_TIPO"		, SBR->BR_TIPO   	,NIL})
				aAdd(_aAuxCab,{"B1_UM"			, SBR->BR_UM   		,NIL})
				aAdd(_aAuxCab,{"B1_LOCPAD"		, SBR->BR_LOCPAD    ,NIL})
				aAdd(_aAuxCab,{"B1_POSIPI"		, SBR->BR_POSIPI    ,NIL})
				aAdd(_aAuxCab,{"B1_IPI"			, SBR->BR_IPI   	,NIL})
			
				//aAdd(_aAuxCab,{"B1_MDESENHO"	, _TRB->B1_MDESENHO ,NIL})
				aAdd(_aAuxCab,{"B1_FANTASM"		, _TRB->B1_FANTASM ,NIL})
				aAdd(_aAuxCab,{"B1_ORIGEM"		,"0" ,NIL})
				
				aAdd(_aAuxCab,{"B1_RASTRO "		, SBR->BR_RASTRO    ,NIL})
				aAdd(_aAuxCab,{"B1_LOCALIZ"		, SBR->BR_LOCALIZ   ,NIL})
				aAdd(_aAuxCab,{"B1_BASE"		, ALLTRIM(_TRB->FAMILIA)	,NIL})
				_aAutoCab := aClone(U_OrdAuto(_aAuxCab))
				
				lMsErroAuto := .F.
				lMsHelpAuto := .F.
				
				Conout("##MsExecAuto ...  - FB101PCP - PROD")
				// daqui
				Begin Transaction
	 
					MsExecAuto({|x,y| MATA010(x,y)}, _aAutoCab, 3,.T.)
					If lMsErroAuto
						_cNomeLog := NomeAutoLog()
						MostraErro()
						EnviaWF("Inclusão de Produtos", "Erro na inclusão do item " + _TRB->B1_COD + "." )
						//ConOut(MemoRead( _cNomeLog ))
						Begin transaction
							_sQuery := ""
							//_sQuery += " update  [SRVMEPELW01].INTEGRACAO_PROTHEUS.dbo.PRODUTOS "
							_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.PRODUTOS "
							_sQuery += " set   IMPORT   	= 'E'"
							_sQuery += " where "
							_sQuery += " IMPORT  = 'N'"
							_sQuery += " and   B1_COD   = '" + _TRB->B1_COD + "'"
							// //u_log (_squery)
							TCSQLExec (_sQuery)
						End transaction
					EndIf
				End Transaction
				//ate aqui
			EndIf
		Else
			/************************************/
		//  Realiza a alteração do produto //  
			/**********************************/
			//ALERT("006")
			_aAuxCab := {}
			DBSELECTAREA("SBR")
			SBR->(dbsetorder(1))
			If (SBR->(dbseek(xfilial("SBR") + _TRB->FAMILIA)))
				
				aAdd(_aAuxCab,{"B1_FILIAL"		, SB1->B1_FILIAL   	,NIL})
				aAdd(_aAuxCab,{"B1_COD"			, _TRB->B1_COD   	,NIL})
				aAdd(_aAuxCab,{"B1_GRUPO"		, _TRB->B1_GRUPO   	,NIL})
				aAdd(_aAuxCab,{"B1_PESO"		, _TRB->B1_PESO   	,NIL})
				aAdd(_aAuxCab,{"B1_PESBRU"		, _TRB->B1_PESBRU   ,NIL})
				//aAdd(_aAuxCab,{"B1_DESC"		, alltrim(_TRB->B1_DESC)   	,NIL})
				aAdd(_aAuxCab,{"B1_DESC"		, Left(_TRB->B1_DESC,120)  	,NIL})

				aAdd(_aAuxCab,{"B1_MDESC"		, _TRB->B1_DESC   	,NIL})
				aAdd(_aAuxCab,{"B1_FANTASM"		, _TRB->B1_FANTASM  ,NIL})
				aAdd(_aAuxCab,{"B1_TIPO"		, SBR->BR_TIPO   	,NIL})
				aAdd(_aAuxCab,{"B1_UM"			, SBR->BR_UM   		,NIL})
				aAdd(_aAuxCab,{"B1_LOCPAD"		, SBR->BR_LOCPAD    ,NIL})
				aAdd(_aAuxCab,{"B1_POSIPI"		, SBR->BR_POSIPI    ,NIL})
				aAdd(_aAuxCab,{"B1_IPI"			, SBR->BR_IPI   	,NIL})
			
				//aAdd(_aAuxCab,{"B1_MDESENHO"	, _TRB->B1_MDESENHO ,NIL})
			
			
				aAdd(_aAuxCab,{"B1_ORIGEM"		,"0" ,NIL})
				
				aAdd(_aAuxCab,{"B1_RASTRO "		, SBR->BR_RASTRO    ,NIL})
				aAdd(_aAuxCab,{"B1_LOCALIZ"		, SBR->BR_LOCALIZ   ,NIL})
				aAdd(_aAuxCab,{"B1_BASE"		, ALLTRIM(_TRB->FAMILIA)    ,NIL})
				_aAutoCab := aClone(U_OrdAuto(_aAuxCab))
				
				lMsErroAuto := .F.
				lMsHelpAuto := .F.
				Conout("##MsExecAuto ...  - FB101PCP - PROD")
				// daqui
				Begin Transaction
	 				Conout("##MsExecAuto ...  - MATA010_EXECUTANDO")
					MsExecAuto({|x,y| MATA010(x,y)}, _aAutoCab, 4,.T.)
					If lMsErroAuto
						_cNomeLog := NomeAutoLog()
						MostraErro()
						EnviaWF("Inclusão de Produtos", "Erro na inclusão do item " + _TRB->B1_COD + "." )
						//ConOut(MemoRead( _cNomeLog ))
						Begin transaction
							_sQuery := ""
							_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.PRODUTOS "
							_sQuery += " set   IMPORT   	= 'E'"
							_sQuery += " where "
							_sQuery += " IMPORT  = 'N'"
							_sQuery += " and   B1_COD   = '" + _TRB->B1_COD + "'"
        					//u_log (_squery)
							TCSQLExec (_sQuery)
						End transaction
					Else
						Begin transaction
							_sQuery := ""
							_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.PRODUTOS "
							_sQuery += " set   IMPORT   	= 'A'"
							_sQuery += " where "
							_sQuery += " IMPORT  = 'N'"
							_sQuery += " and   B1_COD   = '" + _TRB->B1_COD + "'"
        					//u_log (_squery)
							TCSQLExec (_sQuery)
						End transaction
					
					EndIf
					
				End Transaction
				// ate aqui
			EndIf
		EndIf
		// daqui
		Begin transaction
			_sQuery := ""
			_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.PRODUTOS "
			_sQuery += " set   IMPORT   	= 'S'"
			_sQuery += " where "
			_sQuery += " IMPORT  = 'N'"
			_sQuery += " and   B1_COD   = '" + _TRB->B1_COD + "'"
         // //u_log (_squery)
			TCSQLExec (_sQuery)
		End transaction
		// ate aqui
		
		_TRB->(Dbskip())
	EndDo
	_TRB->(dbclosearea())
		
	RestArea(_aArea)

Return


/*
Busco os dados na tabela temporaria - produtos
*/
static Function procestrut()
	Local _cCod := _cCodAnt:= _cCmpAnt := ""
	Local _cArq := ""
	Local _cQuery := ""
	Local _aArea     := GetArea()
	Local _cOper := 3
	Local lBloq	:= .F.
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.
	Private nEstru := 0
	Private _cNome := ""
	
	conout("##Buscando dados ...  - FB101PCP")
	_cQuery += " SELECT G1_FILIAL,G1_COD,G1_COMP,G1_QUANT,G1_PERDA,G1_NIV,G1_NIVINV,IMPORT    "
	_cQuery += " FROM   [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.ESTRUTURAS EST"
	_cQuery += " WHERE  EST.IMPORT = 'N' "
	_cQuery += " group by G1_FILIAL"
	_cQuery += " ,G1_COD"
	_cQuery += " ,G1_COMP"
	_cQuery += " ,G1_QUANT"
	_cQuery += " ,G1_PERDA"
	_cQuery += " ,G1_NIV"
	_cQuery += " ,G1_NIVINV"
	_cQuery += " ,IMPORT"
	//_cQuery += " ,DATAIMP"
	//_cQuery += " ,HORAIMP"
	//_cQuery += " ORDER BY G1_NIV DESC,G1_COD, G1_COMP "
	_cQuery += " ORDER BY G1_NIV ,G1_COD, G1_COMP "
	
	MEMOWRITE("C:\Temp\FB101PCPEST.txt", _cQuery)
	conout(_cQuery)
	TcQuery _cQuery new alias "_TRB"
	
	// Dataroute.herminio em 06/02/2018
	nTotReg := Contar("_TRB","!Eof()")
	_TRB->(DbGoTop())
	Procregua(nTotReg)

	// * Add por Lucas
	While !_TRB->(EoF())

		SB1->(dbSetOrder(1))
		If SB1->(MsSeek(xFilial("SB1")+_cCod))
			If SB1->B1_MSBLQL == "1"
				// aqui
				EnviaWF("Inclusão de Estruturas", "Item " + _cCod + " do componente " + _cCoMP+ " se encontra bloqueado no sistema." )
				lBloq := .T.
			EndIf
		EndIf
		
		_TRB->(Dbskip())
	EndDo
	// * Fim bloco
	
	If lBloq
		MsgAlert("Favor corrigir erros enviados pelo workflow para continuar o processamento.")
	EndIf

	_TRB->(dbGoTop())
	
	nTotNum := 0 
	
	While !_TRB->(EoF()) .And. !lBloq

		// Dataroute.herminio em 06/02/2018
		nTotNum += 1
		IncProc("Importando...  "+str(nTotNum)+" / "+str(nTotReg))
		

		_cCod := _TRB->G1_COD
		_cCoMP := _TRB->G1_COmp
		
		IF 	_cCod <> _cCodAnt
		
			PARAMIXB1 := {}
			PARAMIXB2 := {}
			_atemp := {}

	/*		
			dbSelectArea("SG1")
			SG1->(dbSetOrder(1))

			nEstru := 0
			_cNome := ESTRUT2(_cCod,1,"PAI")
		
			dbSelectArea("PAI")
		
			PAI->(dbGoTop())
		
			While PAI->(!EoF())
		
				SG1->(dbGoTo(PAI->REGISTRO))

				RecLock("SG1", .F.)
				SG1->(dbDelete())
				MsUnLock()
			
				PAI->(dbSkip())
			Enddo
		
			FIMESTRUT2("PAI",_cNome)
		*/
			
			//while SG1->(!eoF()) .and. SG1->G1_COD == _cCod
			//	RecLock( "SG1",.F. )

			//	SG1->( dbDelete() )

			//	SG1->( MsUnlock() )
			//	SG1->( DBSKIP() )
			//ENDDO
		
			PARAMIXB1 := {	{"G1_COD",    _cCod,   	NIL},;
				{"G1_QUANT",  1, 		NIL},;
				{"NIVALT",    "N",     	NIL}}
		
			PARAMIXB1 := aclone (U_OrdAuto (PARAMIXB1))
		
			DBSELECTAREA("SG1")
			SG1->(dbsetorder(1))
			if SG1->( MsSeek(xFilial("SG1") + _cCod ) )
				PARAMIXB1 := {	{"G1_COD",    _cCod,   	NIL},;
					{"G1_QUANT",  1, 		NIL},;
					{"NIVALT",    "N",     	NIL}}
		
				PARAMIXB1 := aclone (U_OrdAuto (PARAMIXB1))
		
				// daqui
				BEGIN TRANSACTION
			
					MSExecAuto({|x,y,z| MATA200(x,y,z)},PARAMIXB1,PARAMIXB2,5)
			
					If lMsErroAuto
						MostraErro() //"C:\temp")
						DisarmTransaction()
					Endif
			
				END TRANSACTION
				// ate aqui
		
			endif
		ENDIF
	
		_cCodAnt:= _cCod
		_cCmpAnt:= _cComp
		_cNivel := "1"
					
		aStruct := {}
			
		DBSELECTAREA("SB1")
		SB1->(dbsetorder(1))
	
		if aScan(_atemp, {|x| x[2] ==  Padr( _TRB->G1_COMP,TamSx3('B1_COD')[1])  .and. x[1] ==  Padr( _TRB->G1_COD,TamSx3('B1_COD')[1])}) == 0
			IF 	/*SB1->( MsSeek(xFilial("SB1") + _cCod ) ) .AND. */	SB1->( MsSeek(xFilial("SB1") + _cCoMP ) )
				aADD(aStruct,{"G1_COD",	    Padr( _TRB->G1_COD ,TamSx3('B1_COD')[1]),	NIL})
				aADD(aStruct,{"G1_COMP",    Padr( _TRB->G1_COMP,TamSx3('B1_COD')[1]),	NIL})
				aADD(aStruct,{"G1_QUANT",   _TRB->G1_QUANT	,	NIL})
				aADD(aStruct,{"G1_PERDA",   _TRB->G1_PERDA,		NIL})
				aADD(aStruct,{"G1_INI",	    CTOD("01/01/01"),	NIL})
				aADD(aStruct,{"G1_FIM",	    CTOD("31/12/49"),	NIL})
				aADD(aStruct,{"G1_NIV",		alltrim(strzero(val(_TRB->G1_NIV), 2)),NIL})
													
				aADD(PARAMIXB2, aclone (U_OrdAuto (aStruct)))
				aadd(_atemp,{ Padr( _TRB->G1_COD,TamSx3('B1_COD')[1]),  Padr( _TRB->G1_COMP,TamSx3('B1_COD')[1])})
		
				// daqui
				begin transaction
					_sQuery := ""
					_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.ESTRUTURAS "
					_sQuery += " set   IMPORT = 'S' "
			//	_sQuery += " AND DATAIMP = '" + DToC(msDate()) + "'"
			//	_sQuery += " AND HORAIMP = '" + Time()		   + "'"
					_sQuery += " where "
					_sQuery += " IMPORT  = 'N'"
					_sQuery += " and   G1_COD   = '" + _TRB->G1_COD + "'"
					_sQuery += " and   G1_COMP   = '" + _TRB->G1_COMP + "'"
					_sQuery += " and   G1_FILIAL   = '" + xfilial ("SG1") + "'"
		 // //u_log (_squery)
					TCSQLExec (_sQuery)
				end transaction
				// ate aqui
			
			ELSE
				// aqui
				EnviaWF("Inclusão de Estruturas", "Erro na inclusão da Estrutura do item " + _cCod + " E componente " + _cCoMP + "." )
			ENDIF
		endif
		_TRB->(Dbskip())
	
		IF _cCod <> _TRB->G1_COD
			lMsErroAuto := .F.
			lMsHelpAuto := .F.

			// daqui
			BEGIN TRANSACTION
			
				MSExecAuto({|x,y,z| MATA200(x,y,z)},PARAMIXB1,PARAMIXB2,3)
			
				If lMsErroAuto
					MostraErro() ///"C:\temp")
					DisarmTransaction()
					begin transaction
						_sQuery := ""
						_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.ESTRUTURAS "
						_sQuery += " set   IMPORT   	= 'E'"
					//_sQuery += " AND DATAIMP = '" + DToC(msDate()) + "'"
					//_sQuery += " AND HORAIMP = '" + Time()		   + "'"
						_sQuery += " where "
						_sQuery += "    G1_COD   = '" + _cCod + "'"
						_sQuery += " and   G1_FILIAL   = '" + xfilial ("SG1") + "'"
					 // //u_log (_squery)
						TCSQLExec (_sQuery)
					end transaction
				
					EnviaWF("Inclusão de Estruturas", "Erro na inclusão da Estrutura do item " + _cCod + " do componente " + _cCoMP+ "." )

				Endif
			
			END TRANSACTION
			// ate aqui
	
		ENDIF
		
	enddo
	_TRB->(dbclosearea())


	RestArea(_aArea)

Return


/*
Busco os dados na tabela temporaria - produtos
*/
static Function procOpr()

	Local _cQuery := ""
	Local _aArea     := GetArea()
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	conout("##Buscando dados ...  - FB101PCP")
	_cQuery += " SELECT * "
	_cQuery += " FROM   [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.OPERACOES OPER"
	_cQuery += " WHERE  OPER.IMPORT = 'N' "
	_cQuery += " ORDER BY G2_COD, G2_PRODUTO, G2_OPERACAO "

	MEMOWRITE("C:\Temp\FB101PCP.txt", _cQuery)
	conout(_cQuery)
	TcQuery _cQuery new alias "_TRB"

	// Dataroute.herminio em 06/02/2018
	nTotReg := Contar("_TRB","!Eof()")
	_TRB->(DbGoTop())
	Procregua(nTotReg)

	DBSELECTAREA("SB1")
	SB1->(dbsetorder(1))
 
	nTotNum := 0

// Grava as operacoes novas
	While !_TRB->(EoF())

		// Dataroute.herminio em 06/02/2018
		nTotNum += 1
		IncProc("Importando... "+str(nTotNum)+" / "+str(nTotReg))

		if (SB1->(dbseek(xfilial("SB1") + _TRB->G2_PRODUTO)))
		
		 // Deleta as operações atuais
			IF _TRB->G2_OPERACAO == '01'
				DBSELECTAREA("SG2")
				SG2->(dbsetorder(1))
				SG2->(dbseek(xfilial("SG2") + padr(_TRB->G2_PRODUTO, TAMSX3("G2_PRODUTO")[1]) + padr(_TRB->G2_COD, TAMSX3("G2_CODIGO")[1]) ))
				While !SG2->(Eof()) .and. 	SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) == ;
						xfilial("SG2") + padr(_TRB->G2_PRODUTO, TAMSX3("G2_PRODUTO")[1]) + padr(_TRB->G2_COD, TAMSX3("G2_CODIGO")[1])
					
					RecLock( "SG2",.F. )
					SG2->( dbDelete() )
					SG2->( MsUnlock() )
			
					SG2->(DbSkip())
				end
		
				if (SB1->(dbseek(xfilial("SB1") + _TRB->G2_PRODUTO)))
					RecLock("SB1",.F.)
					SB1->B1_OPERPAD := ""
					MsUnLock()
				endif
			endif
		
			IF Empty(SB1->B1_OPERPAD)
				RecLock("SB1",.F.)
				SB1->B1_OPERPAD := padr(_TRB->G2_COD, TAMSX3("G2_CODIGO")[1])
				MsUnLock()
			endif
		
			
			RecLock("SG2",!SG2->(MsSeek(xFilial("SG2") + padr(_TRB->G2_PRODUTO, TAMSX3("G2_PRODUTO")[1]) + padr(_TRB->G2_COD, TAMSX3("G2_CODIGO")[1]) + _TRB->G2_OPERACAO )))
			SG2->G2_FILIAL 	 := xfilial("SG2")
			SG2->G2_CODIGO 	 := _TRB->G2_COD
			SG2->G2_PRODUTO  := _TRB->G2_PRODUTO
			SG2->G2_DESCRI   := _TRB->G2DESCRI
			SG2->G2_OPERAC 	 := _TRB->G2_OPERACAO
			SG2->G2_RECURSO  := _TRB->G2_RECURSO
			SG2->G2_SETUP 	 := _TRB->G2_SETUP
			SG2->G2_TEMPAD 	 := _TRB->G2_TEMPAD
			SG2->G2_LOTEPAD	 := _TRB->G2_LOTEPAD
			SG2->G2_MAOOBRA  := _TRB->G2_MAOOBRA
			MsUnlock()
			
			
		endif
	
		// daqui
		begin transaction
			_sQuery := ""
			_sQuery += " update  [SRVTOTVSDB].INTEGRACAO_PROTHEUS.dbo.OPERACOES "
			_sQuery += " set   IMPORT   	= 'S'"
			_sQuery += " where "
			_sQuery += " IMPORT  = 'N'"
			_sQuery += " and   G2_COD   = '" + _TRB->G2_COD + "'"
			_sQuery += " and   G2_PRODUTO   = '" + _TRB->G2_PRODUTO + "'"
	 // //u_log (_squery)
			TCSQLExec (_sQuery)
		end transaction
		// ate aqui
		
		_TRB->(Dbskip())
	enddo
	_TRB->(dbclosearea())
	
	RestArea(_aArea)

Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o Processamento  Do Workflow                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function EnviaWF(cerro, cInconf)

	Local _xEmail := alltrim(GetMv("ML_EMSKA"))

	oProcess := Nil
	oProcess := TWFProcess():New( "INTEGRASKA", "Integracao" )

	oProcess:NewTask( "Integracao", "\workflow\fontes\fb101pcp.html" )
	oProcess:cSubject := "Integração SKA - Protheus"


	oHTML :=oProcess:oHTML
	
	oHtml:ValByName( "cerro" , cInconf)
	//oHtml:ValByName( "cerro" , cerro)
	//oHtml:ValByName( "t1.3" , cInconf)

	//Aadd(oHtml:ValByName( "cerro")	, cerro)
	//Aadd(oHtml:ValByName( "t1.3")	, cInconf)
	

	oProcess:cTo := _xEmail  //Coloque aqui o destinatario do Email.
	cID := oProcess:Start("\workflow\cópia")


	oProcess:Free()

Return