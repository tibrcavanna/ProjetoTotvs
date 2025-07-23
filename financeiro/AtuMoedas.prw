#include "rwmake.ch"
#include "topconn.ch"
#include "tbiConn.ch"
#include "tbiCode.ch"
#include "protheus.ch"
//
////////////////////////////////////////////////////////////////////////////// 
//                                                                          //
//  Programa ...: AtuMoedas                            Modulo : Sigaadv     //
//                                                                          //
//  Autor ......: Diversos Colaboradores               Data ..: 25/11/20    //
//                                                                          //
//  Empresa ....: Armi Consultoria e Treinamento                            //
//                                                                          //
//  Descricao ..: Atualizacao dos Cadastros de Moedas                       //
//                                                                          //
//  Uso ........: Especifico da Cavanna                                     //
//                                                                          //
//  Observacao .: Utiliza as cotacoes disponibilizadas no  site  do  Banco  //
//                Central do Brasil atraves de um servico do Protheus  que  //
//                deve ser colocado no arquivo .INI do Server com  as  se-  //
//                guintes linhas de instrucao:                              //
//                                                                          //
//                ;Opcao 1 para Utilizar Apenas o Job Sem Scheduler         //
//                [ONSTART]                                                 //
//                Jobs=Moedas                                               //
//                ;Tempo em Segundos para Atualizar onde 86400=24 Horas     //
//                ;ou 18000=5 Horas ou 120=2 Minutos, 15=15 Segundos, Etc   //
//                RefreshRate=86400                                         //
//                                                                          //
//                [Moedas]                                                  //
//                Main=U_AtuMoeda                                           //
//                Environment=Ambiente                                      //
//                                                                          //
//                ;Opcao 2 para Adicionar no Scheduler                      //
//                [ONSTART]                                                 //
//                Jobs=Moedas                                               //
//                ;Tempo em Segundos 86400=24 Horas ou 15=15 Segundos, Etc  //
//                ;RefreshRate=15                                           //
//                                                                          //
//                [Moedas]                                                  //
//                Main=WFONSTART                                            //
//                Environment=Ambiente                                      //
//                nParms=0                                                  //
//                                                                          //
//                Criar o Arquivo Scheduler.wf na Pasta \SYSTEM             //
//                como no Seguinte Exemplo de Conteudo:                     //
//                01,01,Ambiente,T                                          //
//                                                                          //
//                ;Opcao 3 a Partir do Menu do Sistema                      //
//                                                                          //
//                ;Opcao 4 a Partir de Servico do Schedule                  //
//                                                                          //
//  Atualizacao : 17/02/21 - Paulo Roberto de Oliveira                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//

/////////////////////////
User Function AtuMoedas()
/////////////////////////
//
	Private lAuto     := .F.               // Flag de Rotina Automatica Via Servico ou Job (.T.) ou Via Menu (.F.)
	Private dDataAtu  := Date()            // Data de Atualizacao Desejada
	Private dDataRef  := Date()            // Data de Referencia
	Private dDataAux  := Ctod("")          // Data Auxiliar
//
	Private nValMoe1  := 1.000000          // Valores das Moedas:
	Private nValMoe2  := 0.000000          // 1 -> R$  = REAL
	Private nValMoe3  := 0.828700          // 2 e 6 -> USD = DOLAR AMERICANO
	Private nValMoe4  := 0.000000          // 3 -> UFI = UFIR
	Private nValMoe5  := 0.000000          // 4 e 7 -> EUR = EURO
	Private nValMoe6  := 0.000000          // 5 -> JPY = IENE JAPONES
	Private nValMoe7  := 0.000000          // 8 e 9 -> COP = PESO COLOMBIANO
	Private nValMoe8  := 0.000000          // 10 e 11 -> MXN = PESO MEXICANO
	Private nValMoe9  := 0.000000          // 12 e 13 -> ARS = PESO ARGENTINO
	Private nValMoe10 := 0.000000          // 14 e 15 -> DOP = PESO REPUBLICA DOMINICANA
	Private nValMoe11 := 0.000000
	Private nValMoe12 := 0.000000
	Private nValMoe13 := 0.000000
	Private nValMoe14 := 0.000000
	Private nValMoe15 := 0.000000
	Private nValMoe16 := 0.000000
	Private nValMoe17 := 0.000000
	Private nValMoe18 := 0.000000
	Private nValMoe19 := 0.000000
	Private nValMoe20 := 0.000000
	Private nValMoe21 := 0.000000
	Private nValMoe22 := 0.000000
	Private nValMoe23 := 0.000000
	Private nValMoe24 := 0.000000
//
	Private cNomeRot := "MANMOEDA,"        // Nome da Rotina Via Menu
//
	If Select("SX2") == 0                  // Execucao Via Servico ou Job
		//
		RPCSetType(3)                       // Nao Consome Licensa de Uso
		//
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" TABLES "SM2,SYE,CTO,CTP"
		//
		Sleep(5000)                         // Aguarda 5 Segundos p/ Que os Jobs IPC Subam
		//
		ConOut("AtuMoedas - Iniciando Atualizacao de Moedas em " + Dtoc(dDataAtu) + " as " + Time())
		//
		lAuto := .T.
		//
	Endif
//
	If (!lAuto)
		//
		dDataAtu := M->dDataBase            // Utilizar a Data Base do Sistema Se For Via Menu
		dDataRef := M->dDataBase
		//
		If Upper(Alltrim(FunName())) $ cNomeRot
			//
			If MsgBox("Confirma a Atualização de Moedas do Site do Banco Central do Brasil com as Taxas para a Data Base de " + Dtoc(dDataAtu) + " ?",;
					"Cotação de Moedas para " + Dtoc(dDataAtu), "YESNO")
				//
				LjMsgRun("Atualizando Cotações de Taxas de Moedas ...",, {|| xExecMoeda()})
				//
			Endif
			//
		Else
			xExecMoeda()
		Endif
		//
	Else
		xExecMoeda()
	Endif
//
	If (lAuto)                             // Execucao Via Servico ou Job
		//
		RpcClearEnv()                       // Libera o Ambiente
		//
		ConOut("AtuMoedas - Atualizacao de Moedas Concluida em " + Dtoc(dDataAtu) + " as " + Time())
		//
	Endif
//
Return (.T.)

////////////////////////////
Static Function xExecMoeda()
////////////////////////////
//
	Local cFile, cTexto, cLinha, J, K      // Ler o Arquivo de Cotacao de Moedas a Partir do Site do Banco Central
//
	dDataRef := (dDataAtu - 1)             // Verificar Feriados Bancarios Fixos e Final de Semana
//
	cMesDia := Substr(Dtos(dDataRef), 5, 4)
//
	If cMesDia == "0101" .Or.;             // Dia Mundial da Paz
		cMesDia == "0421" .Or.;             // Dia de Tiradentes
		cMesDia == "0501" .Or.;             // Dia do Trabalho
		cMesDia == "0907" .Or.;             // Dia da Independencia
		cMesDia == "1012" .Or.;             // Dia de Nossa Senhora de Aparecida
		cMesDia == "1102" .Or.;             // Dia de Finados
		cMesDia == "1115" .Or.;             // Dia da Proclamacao da Republica
		cMesDia == "1225" .Or.;             // Dia de Natal
		cMesDia == "1231"                   // Dia Sem Expediente Bancario
		//
		dDataRef := (dDataRef - 1)
		//
		cMesDia := Substr(Dtos(dDataRef), 5, 4)
		//
		If cMesDia == "1231"
			dDataRef := (dDataRef - 1)
		Endif
		//
	Endif
//
	If Dow(dDataRef) == 1                  // Domingo
		cFile := Dtos(dDataRef - 2) + ".csv"
	Elseif Dow(dDataRef) == 7              // Sabado
		cFile := Dtos(dDataRef - 1) + ".csv"
	Else                                   // Dia Normal
		cFile := Dtos(dDataRef) + ".csv"
	Endif
//
	cTexto := HttpGet("https://www4.bcb.gov.br/Download/fechamento/" + cFile)
//
	If !Empty(cTexto)                      // Se Existe o Arquivo Texto de Cotacoes
		//
		If (lAuto)
			ConOut("AtuMoedas - DownLoad do Banco Central do Arquivo " + cFile + " em " + Dtoc(dDataAtu))
		Endif
		//
	Elseif !Empty(cFile) .And. File(cFile) // Se o Arquivo Texto de Cotacoes Estiver na Pasta de Sistema \System
		//
		cTexto := MemoRead(cFile)           // Ler o Conteudo do Arquivo .CSV Encontrado
		//
	Else
		//
		If (lAuto)
			ConOut("AtuMoedas - Arquivo de Cotacoes " + cFile + " Nao Encontrado")
		Else
			//
			If Upper(Alltrim(FunName())) $ cNomeRot
				MsgBox("O Arquivo de Cotações " + cFile + " Não Foi Encontrado !!!", "Atenção !!!", "ALERT")
			Endif
			//
		Endif
		//
	Endif
//
	cEOL := ""                             // Caracter(es) de Identificacao de Final de Aquivo
//
	If !Empty(cTexto)                      // Se Existe o Arquivo Texto de Cotacoes
		//
		If At(Chr(13) + Chr(10), cTexto) > 0
			cEOL := Chr(13) + Chr(10)
		Elseif At(Chr(10), cTexto) > 0
			cEOL := Chr(10)
		Endif
		//
		If Empty(cEOL)
			//
			If (lAuto)
				ConOut("AtuMoedas - Nao Foi Possivel Determinar a Estrutura do Arquivo")
			Else
				//
				If Upper(Alltrim(FunName())) $ cNomeRot
					MsgBox("Não Foi Possível Determinar a Estrutura do Arquivo !!!", "Atenção !!!", "ALERT")
				Endif
				//
			Endif
			//
		Endif
		//
	Endif
//
	If !Empty(cTexto) .And. !Empty(cEOL)             // Se o Arquivo Existe e Sua Estrutura Pode Ser Identificada
		//
   /* Com as Posicoes Fixas dos Campos no Arquivo .CSV (Nao Mais Fornecido pelo Banco Central), Poderiamos Ter:
   //
   nLinhas := MLCount(cTexto, 81)                // Conta Quantas Linhas de 80 Posicoes Existem no Arquivo
   //
   For J := 1 To nLinhas
       //
       cLinha  := Memoline(cTexto, 81, J)        // Le a Linha Corrente do Arquivo
       //
       cData   := Substr(cLinha, 1, 10)          // Define os Campos pelas Posicoes Relativas
       cCompra := StrTran(Substr(cLinha, 22, 14), ",", ".")
       cVenda  := StrTran(Substr(cLinha, 37, 14), ",", ".")
       cCodMoe := Substr(cLinha, 12, 3)
       //
       ...
       //
   Next J
   // Ja Com as Posicoes Variaveis dos Campos no Arquivo .CSV, Teremos:
   */
		aTexto := StrTokArr(cTexto, Chr(10))          // Divide o Conteudo do Texto do Arquivo Num Array p/ Cada Quebra de Linha Encontrada (Cada Linha, Um Elemento do Array)
		//
		For J := 1 To Len(aTexto)                     // Percorre Todas os Elementos do Array (Percorre Todas as Linhas)
			//
			cLinha := aTexto[J]                       // Linha ou Elemento Corrente do Array
			//
			aLinha := StrTokArr(cLinha, ";")          // Novo Array Que Divite o Conteudo da Linha Sendo Cada Campo Um Elemento deste Novo Array (Cada ";" Define a Posicao de Um Campo)
			//
			If Len(aLinha) >= 6                       // Cada Linha Deve Possuir ao Menos Seis Campos
				//
				cData   := aLinha[1]                   // Define os Campos pelas Posicoes Relativas
				cCodMoe := Strzero(Val(aLinha[2]), 3)  // Codigo da Moeda Com Tres Digitos
				cCompra := Strtran(aLinha[5], ",", ".")
				cVenda  := Strtran(aLinha[6], ",", ".")
				//
				dDataAux := Ctod(cData)                // Data da Cotacao da Moeda
				nVenda   := Val(cVenda)                // Valor de Venda da Moeda
				nCompra  := Val(cCompra)               // Valor de Compra da Moeda
				//
				If cCodMoe == "220"                    // Dolar Americano (USD)
					//
					nValMoe2 := nCompra
					nValMoe6 := nVenda
					//
				Endif
				//
				If cCodMoe == "978"                    // Euro (EUR)
					//
					nValMoe4 := nCompra
					nValMoe7 := nVenda
					//
				Endif
				//
				If cCodMoe == "470"                     // Iene (JPY)
					//
					nValMoe5 := nCompra
					//
				Endif
				//
				If cCodMoe == "720"                     // Peso Colombiano (COP)
					//
					nValMoe8 := nCompra
					nValMoe9 := nVenda
					//
				Endif
				//
				If cCodMoe == "741"                     // Peso Mexicano (MXN)
					//
					nValMoe10 := nCompra
					nValMoe11 := nVenda
					//
				Endif
				//
				If cCodMoe == "706"                     // Peso Argentino (ARS)
					//
					nValMoe12 := nCompra
					nValMoe13 := nVenda
					//
				Endif
				//
				If cCodMoe == "730"                     // Peso Republica Dominicana (DOP)
					//
					nValMoe14 := nCompra
					nValMoe15 := nVenda
					//
				Endif
				//
				If cCodMoe == "055"                     // Coroa Dinamarquesa (DKK)
					//
				Endif
				//
				If cCodMoe == "150"                     // Dolar Australiano (AUD)
					//
				Endif
				//
				If cCodMoe == "425"                     // Franco Suico (CHF)
					//
				Endif
				//
				If cCodMoe == "785"                     // Rande Sul-Africano (ZAR)
					//
				Endif
				//
				If cCodMoe == "540"                     // Libra Esterlina (GBP)
					//
					nValMoe16 := nCompra
					nValMoe17 := nVenda
				Endif
				//
				If cCodMoe == "165"                     // Dolar Canadense (CAD)
					//
				Endif
				//
				If cCodMoe == "795"                     // Renmimbi Iuan Chines (CNY)
					//
					nValMoe18 := nCompra
					nValMoe19 := nVenda
				Endif
				//
				If cCodMoe == "715"                     // Peso Chileno (CLP)
					//
				Endif
				//
			Endif
			//
		Next J
		//
	Else
		//
		VerifDados()                        // Verificar os Dados da Data Desejada
		//
		Return (.T.)                        // Caso Nao Tenha Sido Liberado o Arquivo o Sistema Finaliza a Rotina
		//
	Endif
//
	GravaDados()                           // Gravar os Dados da Data Desejada
//
	VerifDados()                           // Verificar os Dados da Data Desejada
//
	lProjMoe := .F.                        // Flag p/ Projetar (.T.) ou Nao (.F.) as Taxas das Moedas p/ os Dias Posteriores
//
	If (Dow(dDataRef) == 6) .And. lProjMoe // Se For Sexta-Feira (Nao Utilizado por Considerar a Cotacao de Quinta-Feira p/ o Fim de Semana)
		//
		For K := 1 To 2
			//
			dDataAux ++
			dDataAtu := dDataAux
			//
			GravaDados()                    // Gravar os Valores de Sabado e Domingo Posteriores Tambem
			//
		Next K
		//
	Endif
//
Return (.T.)

////////////////////////////
Static Function GravaDados()
////////////////////////////
//
	Local nI := 0                          // Variavel Auxiliar
//
	Private cLisCTB := ""                  // Lista de Moedas a Serem Atualizadas no Modulo da Contabilidade (CTB), Ex.: "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,"
	Private cLisEIC := ""                  // Lista de Moedas a Serem Atualizadas no Modulo de Importacao (EIC), Ex.: "2,3,4,5,6,7,8,9,"
//
	SM2->(DbSetOrder(1))                   // Cadastro de Moedas (FIN)
	CTO->(DbSetOrder(1))                   // Moedas Contabeis (CTB)
	CTP->(DbSetOrder(1))                   // Cambio (CTB)
	SYE->(DbSetOrder(1))                   // Cotacao das Moedas (EIC)
//
	DbSelectArea("SM2")                    // Atualizar o Cadastro de Moedas do Financeiro
	If SM2->(DbSeek(Dtos(dDataAtu)))
		lGravarSM2 := .F.                   // Alteracao
	Else
		lGravarSM2 := .T.                   // Inclusao
	Endif
//
	lAtualiz := .F.                        // Flag de Atualizacao Realizada (.T.) ou Nao (.F.)
//
	DbSelectArea("SM2")
	If SM2->(RecLock("SM2", lGravarSM2))
		//
		If lGravarSM2
			//
			SM2->M2_DATA   := dDataAtu
			SM2->M2_INFORM := "S"
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA1")) > 0 .And. SM2->M2_MOEDA1 <= 0 .And. nValMoe1 > 0
			//
			SM2->M2_MOEDA1 := nValMoe1
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA2")) > 0 .And. SM2->M2_MOEDA2 <= 0 .And. nValMoe2 > 0
			//
			SM2->M2_MOEDA2 := nValMoe2
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA3")) > 0 .And. SM2->M2_MOEDA3 <= 0 .And. nValMoe3 > 0
			//
			SM2->M2_MOEDA3 := nValMoe3
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA4")) > 0 .And. SM2->M2_MOEDA4 <= 0 .And. nValMoe4 > 0
			//
			SM2->M2_MOEDA4 := nValMoe4
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA5")) > 0 .And. SM2->M2_MOEDA5 <= 0 .And. nValMoe5 > 0
			//
			SM2->M2_MOEDA5 := nValMoe5
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA6")) > 0 .And. SM2->M2_MOEDA6 <= 0 .And. nValMoe6 > 0
			//
			SM2->M2_MOEDA6 := nValMoe6
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA7")) > 0 .And. SM2->M2_MOEDA7 <= 0 .And. nValMoe7 > 0
			//
			SM2->M2_MOEDA7 := nValMoe7
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA8")) > 0 .And. SM2->M2_MOEDA8 <= 0 .And. nValMoe8 > 0
			//
			SM2->M2_MOEDA8 := nValMoe8
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA9")) > 0 .And. SM2->M2_MOEDA9 <= 0 .And. nValMoe9 > 0
			//
			SM2->M2_MOEDA9 := nValMoe9
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA10")) > 0 .And. SM2->M2_MOEDA10 <= 0 .And. nValMoe10 > 0
			//
			SM2->M2_MOEDA10 := nValMoe10
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA11")) > 0 .And. SM2->M2_MOEDA11 <= 0 .And. nValMoe11 > 0
			//
			SM2->M2_MOEDA11 := nValMoe11
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA12")) > 0 .And. SM2->M2_MOEDA12 <= 0 .And. nValMoe12 > 0
			//
			SM2->M2_MOEDA12 := nValMoe12
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA13")) > 0 .And. SM2->M2_MOEDA13 <= 0 .And. nValMoe13 > 0
			//
			SM2->M2_MOEDA13 := nValMoe13
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA14")) > 0 .And. SM2->M2_MOEDA14 <= 0 .And. nValMoe14 > 0
			//
			SM2->M2_MOEDA14 := nValMoe14
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA15")) > 0 .And. SM2->M2_MOEDA15 <= 0 .And. nValMoe15 > 0
			//
			SM2->M2_MOEDA15 := nValMoe15
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA16")) > 0 .And. SM2->M2_MOEDA16 <= 0 .And. nValMoe16 > 0
			//
			SM2->M2_MOEDA16 := nValMoe16
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA17")) > 0 .And. SM2->M2_MOEDA17 <= 0 .And. nValMoe17 > 0
			//
			SM2->M2_MOEDA17 := nValMoe17
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA18")) > 0 .And. SM2->M2_MOEDA18 <= 0 .And. nValMoe18 > 0
			//
			SM2->M2_MOEDA18 := nValMoe18
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA19")) > 0 .And. SM2->M2_MOEDA19 <= 0 .And. nValMoe19 > 0
			//
			SM2->M2_MOEDA19 := nValMoe19
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA20")) > 0 .And. SM2->M2_MOEDA20 <= 0 .And. nValMoe20 > 0
			//
			SM2->M2_MOEDA20 := nValMoe20
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA21")) > 0 .And. SM2->M2_MOEDA21 <= 0 .And. nValMoe21 > 0
			//
			SM2->M2_MOEDA21 := nValMoe21
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA22")) > 0 .And. SM2->M2_MOEDA22 <= 0 .And. nValMoe22 > 0
			//
			SM2->M2_MOEDA22 := nValMoe22
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA23")) > 0 .And. SM2->M2_MOEDA23 <= 0 .And. nValMoe23 > 0
			//
			SM2->M2_MOEDA23 := nValMoe23
			lAtualiz := .T.
			//
		Endif
		//
		If SM2->(FieldPos("M2_MOEDA24")) > 0 .And. SM2->M2_MOEDA24 <= 0 .And. nValMoe24 > 0
			//
			SM2->M2_MOEDA24 := nValMoe24
			lAtualiz := .T.
			//
		Endif
		//
		SM2->(MsUnLock())
		//
		_lCTB := .T.                        // Flag p/ Atualizar (.T.) ou Nao (.F.) o Cadastro de Moedas da Contabilidade
		_lEIC := .F.                        // Flag p/ Atualizar (.T.) ou Nao (.F.) o Cadastro de Moedas do EIC
		//
		If lAtualiz .And. _lCTB
			//
			dDatCTB := SM2->M2_DATA          // Atualizar o Cadastro de Moedas da Contabilidade
			//
			For nI := 1 To 99
				//
				cMoeSM2 := cValToChar(nI)    // Numero da Moeda em Caracter
				//
				If SM2->(FieldPos("M2_MOEDA" + cMoeSM2)) > 0 .And. SM2->&("M2_MOEDA" + cMoeSM2) > 0 .And.;
						((!Empty(cLisCTB) .And. cMoeSM2 $ cLisCTB) .Or. Empty(cLisCTB))
					//
					xCTP_FILIAL := xFilial("CTP")
					xCTP_DATA   := dDatCTB -1
					xCTP_MOEDA  := Strzero(nI, 2)
					xCTP_TAXA   := SM2->&("M2_MOEDA" + cMoeSM2)
					xCTP_BLOQ   := "2"        // Bloqueado (1=Sim ,2=Nao)
					//
					CTO->(DbSeek(xFilial("CTO") + xCTP_MOEDA, .F.))
					//
					If CTO->(Found()) .And.;
							CTO->CTO_BLOQ # "1"    // Bloequeado (1=Sim, 2=Nao)
						//
						CTP->(DbSeek(xFilial("CTP") + Dtos(xCTP_DATA) + xCTP_MOEDA, .F.))
						//
						If CTP->(Found())
							lGravarCTP := .F.   // Alteracao
						Else
							lGravarCTP := .T.   // Inclusao
						Endif
						//
						DbSelectArea("CTP")
						If CTP->(RecLock("CTP", lGravarCTP))
							//
							If lGravarCTP
								//
								CTP->CTP_FILIAL := xFilial("CTP")
								CTP->CTP_DATA   := xCTP_DATA
								CTP->CTP_MOEDA  := xCTP_MOEDA
								//
							Endif
							//
							CTP->CTP_BLOQ := xCTP_BLOQ
							CTP->CTP_TAXA := xCTP_TAXA
							//
							CTP->(MsUnLock())
							//
						Endif
						//
					Endif
					//
				Endif
				//
			Next nI
			//
		Endif
		//
		If lAtualiz .And. _lEIC
			//
			dDatSYE := SM2->M2_DATA          // Atualizar o Cadastro de Moedas do EIC
			//
			For nI := 2 To 99
				//
				cMoeSM2 := cValToChar(nI)    // Numero da Moeda em Caracter
				//
				If SM2->(FieldPos("M2_MOEDA" + cMoeSM2)) > 0 .And. SM2->&("M2_MOEDA" + cMoeSM2) > 0 .And.;
						!Empty(cLisEIC) .And. cMoeSM2 $ cLisEIC
					//
					cMoedSYE := GetMv("MV_SIMB" + cMoeSM2,, "")
					//
					If !Empty(cMoedSYE)       // Atualizar os Valores Fiscal, de Venda e de Compra
						//
						nValMoeF := SM2->&("M2_MOEDA" + cMoeSM2)
						nValMoeV := SM2->&("M2_MOEDA" + cMoeSM2)
						nValMoeC := SM2->&("M2_MOEDA" + cMoeSM2)
						//
						If SYE->(DbSeek(xFilial("SYE") + Dtos(dDatSYE) + cMoedSYE))
							lGravarSYE := .F.   // Alteracao
						Else
							lGravarSYE := .T.   // Inclusao
						Endif
						//
						DbSelectArea("SYE")
						If SYE->(RecLock("SYE", lGravarSYE))
							//
							If lGravarSYE
								//
								SYE->YE_FILIAL := xFilial("SYE")
								SYE->YE_DATA   := dDatSYE
								SYE->YE_MOEDA  := cMoedSYE
								//
							Endif
							//
							SYE->YE_VLFISCA := nValMoeF
							SYE->YE_VLCON_C := nValMoeV
							SYE->YE_TX_COMP := nValMoeC
							SYE->YE_MOE_FIN := cMoeSM2
							//
							SYE->(MsUnLock())
							//
						Endif
						//
					Endif
					//
				Endif
				//
			Next nI
			//
		Endif
		//
	Endif
//
Return (.T.)

////////////////////////////
Static Function VerifDados()           // Verificar e Atualizar a Data Utilizando a Ultima Cotacao Valida (Quando a Rotina For Via Menu)
////////////////////////////
//
	wNomeRot := cNomeRot + "REPMOEDAS,"    // Rotinas Executadas Via Menu do Sistema
//
	If (lAuto)
		//
		lOk := .F.                          // Flag p/ Executar (.T.) ou Nao (.F.) a Verificacao Quando a Rotina for Chamada Via Servico ou Job
		//
		If !lOk
			Return (.T.)
		Endif
		//
		ConOut("AtuMoedas - Verificacao de Moedas Atualizadas em " + Dtoc(dDataAtu))
		//
	Endif
//
	If !(Upper(Alltrim(FunName())) $ wNomeRot)
		Return (.T.)                        // Se Nao For Via Menu Nao Executar Esta Rotina
	Endif
//
	SM2->(DbSetOrder(1))                   // Cadastro de Moedas (FIN)
//
	dDataRef := (dDataAtu - 1)             // Data de Referencia Como Sendo o Dia Anterior ou o Ultimo Dia c/ Taxas de Moedas Cadastradas
	lAtualiz := .F.                        // Flag de Moedas a Serem Atualizadas (.T.) ou Nao (.F.) por Falha no Arquivo do Banco Central
//
	nValMoe1  := 0.000000                  // Valores das Moedas a Verificar
	nValMoe2  := 0.000000
	nValMoe4  := 0.000000
	nValMoe5  := 0.000000
	nValMoe6  := 0.000000
	nValMoe7  := 0.000000
	nValMoe8  := 0.000000
	nValMoe9  := 0.000000
	nValMoe10 := 0.000000
	nValMoe11 := 0.000000
	nValMoe13 := 0.000000
	nValMoe14 := 0.000000
	nValMoe15 := 0.000000
	nValMoe16 := 0.000000
	nValMoe17 := 0.000000
	nValMoe18 := 0.000000
	nValMoe19 := 0.000000
	nValMoe20 := 0.000000
	nValMoe21 := 0.000000
	nValMoe22 := 0.000000
	nValMoe23 := 0.000000
	nValMoe24 := 0.000000
//
	DbSelectArea("SM2")
	lCadRef := .F.                         // Flag do Cadastro das Taxas de Moedas de Referencia do Ultimo Dia Cadastrado Encontrado (.T.) ou Nao (.F.)
//
	While .T.
		//
		SM2->(DbSeek(Dtos(dDataRef)))    // Pesquisar a Data de Referencia no Cadastro e c/ Valores Nao Zerados
		//
		If SM2->(Found()) .And. !ValZerados()
			//
			lCadRef := .T.
			Exit
			//
		Endif
		//
		dDataRef := (dDataRef - 1)
		//
		If dDataRef < (dDataAtu - 730)   // Pesquisar No Maximo Ate Dois Anos Atras
			Exit
		Endif
		//
	Enddo
//
	If lCadRef                             // Obter as Taxas das Moedas do Ultimo Dia Cadastrado p/ a Data de Referencia
		//
		nValMoe1  := IIf(SM2->(FieldPos("M2_MOEDA1")) > 0 .And. SM2->M2_MOEDA1 > 0, SM2->M2_MOEDA1, 0)
		nValMoe2  := IIf(SM2->(FieldPos("M2_MOEDA2")) > 0 .And. SM2->M2_MOEDA2 > 0, SM2->M2_MOEDA2, 0)
		nValMoe3  := IIf(SM2->(FieldPos("M2_MOEDA3")) > 0 .And. SM2->M2_MOEDA3 > 0, SM2->M2_MOEDA3, 0)
		nValMoe4  := IIf(SM2->(FieldPos("M2_MOEDA4")) > 0 .And. SM2->M2_MOEDA4 > 0, SM2->M2_MOEDA4, 0)
		nValMoe5  := IIf(SM2->(FieldPos("M2_MOEDA5")) > 0 .And. SM2->M2_MOEDA5 > 0, SM2->M2_MOEDA5, 0)
		nValMoe6  := IIf(SM2->(FieldPos("M2_MOEDA6")) > 0 .And. SM2->M2_MOEDA6 > 0, SM2->M2_MOEDA6, 0)
		nValMoe7  := IIf(SM2->(FieldPos("M2_MOEDA7")) > 0 .And. SM2->M2_MOEDA7 > 0, SM2->M2_MOEDA7, 0)
		nValMoe8  := IIf(SM2->(FieldPos("M2_MOEDA8")) > 0 .And. SM2->M2_MOEDA8 > 0, SM2->M2_MOEDA8, 0)
		nValMoe9  := IIf(SM2->(FieldPos("M2_MOEDA9")) > 0 .And. SM2->M2_MOEDA9 > 0, SM2->M2_MOEDA9, 0)
		nValMoe10 := IIf(SM2->(FieldPos("M2_MOEDA10")) > 0 .And. SM2->M2_MOEDA10 > 0, SM2->M2_MOEDA10, 0)
		nValMoe11 := IIf(SM2->(FieldPos("M2_MOEDA11")) > 0 .And. SM2->M2_MOEDA11 > 0, SM2->M2_MOEDA11, 0)
		nValMoe12 := IIf(SM2->(FieldPos("M2_MOEDA12")) > 0 .And. SM2->M2_MOEDA12 > 0, SM2->M2_MOEDA12, 0)
		nValMoe13 := IIf(SM2->(FieldPos("M2_MOEDA13")) > 0 .And. SM2->M2_MOEDA13 > 0, SM2->M2_MOEDA13, 0)
		nValMoe14 := IIf(SM2->(FieldPos("M2_MOEDA14")) > 0 .And. SM2->M2_MOEDA14 > 0, SM2->M2_MOEDA14, 0)
		nValMoe15 := IIf(SM2->(FieldPos("M2_MOEDA15")) > 0 .And. SM2->M2_MOEDA15 > 0, SM2->M2_MOEDA15, 0)
		nValMoe16 := IIf(SM2->(FieldPos("M2_MOEDA16")) > 0 .And. SM2->M2_MOEDA16 > 0, SM2->M2_MOEDA16, 0)
		nValMoe17 := IIf(SM2->(FieldPos("M2_MOEDA17")) > 0 .And. SM2->M2_MOEDA17 > 0, SM2->M2_MOEDA17, 0)
		nValMoe18 := IIf(SM2->(FieldPos("M2_MOEDA18")) > 0 .And. SM2->M2_MOEDA18 > 0, SM2->M2_MOEDA18, 0)
		nValMoe19 := IIf(SM2->(FieldPos("M2_MOEDA19")) > 0 .And. SM2->M2_MOEDA19 > 0, SM2->M2_MOEDA19, 0)
		nValMoe20 := IIf(SM2->(FieldPos("M2_MOEDA20")) > 0 .And. SM2->M2_MOEDA20 > 0, SM2->M2_MOEDA20, 0)
		nValMoe21 := IIf(SM2->(FieldPos("M2_MOEDA21")) > 0 .And. SM2->M2_MOEDA21 > 0, SM2->M2_MOEDA21, 0)
		nValMoe22 := IIf(SM2->(FieldPos("M2_MOEDA22")) > 0 .And. SM2->M2_MOEDA22 > 0, SM2->M2_MOEDA22, 0)
		nValMoe23 := IIf(SM2->(FieldPos("M2_MOEDA23")) > 0 .And. SM2->M2_MOEDA23 > 0, SM2->M2_MOEDA23, 0)
		nValMoe24 := IIf(SM2->(FieldPos("M2_MOEDA24")) > 0 .And. SM2->M2_MOEDA24 > 0, SM2->M2_MOEDA24, 0)
		//
	Endif
//
	DbSelectArea("SM2")                    // Pesquisar a Data Desejada p/ Atualizacao das Moedas Deixando de Avaliar o Real
	SM2->(DbSeek(Dtos(dDataAtu)))
//
	If SM2->(Found())
		//
		If (SM2->(FieldPos("M2_MOEDA2")) > 0 .And. SM2->M2_MOEDA2 <= 0 .And. nValMoe2 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA3")) > 0 .And. SM2->M2_MOEDA3 <= 0 .And. nValMoe3 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA4")) > 0 .And. SM2->M2_MOEDA4 <= 0 .And. nValMoe4 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA5")) > 0 .And. SM2->M2_MOEDA5 <= 0 .And. nValMoe5 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA6")) > 0 .And. SM2->M2_MOEDA6 <= 0 .And. nValMoe6 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA7")) > 0 .And. SM2->M2_MOEDA7 <= 0 .And. nValMoe7 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA8")) > 0 .And. SM2->M2_MOEDA8 <= 0 .And. nValMoe8 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA9")) > 0 .And. SM2->M2_MOEDA9 <= 0 .And. nValMoe9 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA10")) > 0 .And. SM2->M2_MOEDA10 <= 0 .And. nValMoe10 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA11")) > 0 .And. SM2->M2_MOEDA11 <= 0 .And. nValMoe11 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA12")) > 0 .And. SM2->M2_MOEDA12 <= 0 .And. nValMoe12 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA13")) > 0 .And. SM2->M2_MOEDA13 <= 0 .And. nValMoe13 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA14")) > 0 .And. SM2->M2_MOEDA14 <= 0 .And. nValMoe14 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA15")) > 0 .And. SM2->M2_MOEDA15 <= 0 .And. nValMoe15 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA16")) > 0 .And. SM2->M2_MOEDA16 <= 0 .And. nValMoe16 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA17")) > 0 .And. SM2->M2_MOEDA17 <= 0 .And. nValMoe17 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA18")) > 0 .And. SM2->M2_MOEDA18 <= 0 .And. nValMoe18 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA19")) > 0 .And. SM2->M2_MOEDA19 <= 0 .And. nValMoe19 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA20")) > 0 .And. SM2->M2_MOEDA20 <= 0 .And. nValMoe20 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA21")) > 0 .And. SM2->M2_MOEDA21 <= 0 .And. nValMoe21 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA22")) > 0 .And. SM2->M2_MOEDA22 <= 0 .And. nValMoe22 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA23")) > 0 .And. SM2->M2_MOEDA23 <= 0 .And. nValMoe23 > 0) .Or.;
				(SM2->(FieldPos("M2_MOEDA24")) > 0 .And. SM2->M2_MOEDA24 <= 0 .And. nValMoe24 > 0)
			//
			lAtualiz := .T.
			//
		Endif
		//
	Else
		lAtualiz := .T.
	Endif
//
	If lCadRef .And. lAtualiz
		//
		GravaDados()                        // Gravar os Dados da Data Desejada
		//
	Endif
//
Return (.T.)

////////////////////////////
Static Function ValZerados()
////////////////////////////
//
	Local _lZerados := .T.                 // Indicador de Valores das Taxas das Moedas Zerados (.T.) ou Nao (.F.) Deixando de Avaliar o Real e a Ufir
//
	If (SM2->(FieldPos("M2_MOEDA2")) > 0 .And. SM2->M2_MOEDA2 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA4")) > 0 .And. SM2->M2_MOEDA4 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA5")) > 0 .And. SM2->M2_MOEDA5 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA6")) > 0 .And. SM2->M2_MOEDA6 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA7")) > 0 .And. SM2->M2_MOEDA7 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA8")) > 0 .And. SM2->M2_MOEDA8 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA9")) > 0 .And. SM2->M2_MOEDA9 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA10")) > 0 .And. SM2->M2_MOEDA10 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA11")) > 0 .And. SM2->M2_MOEDA11 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA12")) > 0 .And. SM2->M2_MOEDA12 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA13")) > 0 .And. SM2->M2_MOEDA13 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA14")) > 0 .And. SM2->M2_MOEDA14 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA15")) > 0 .And. SM2->M2_MOEDA15 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA16")) > 0 .And. SM2->M2_MOEDA16 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA17")) > 0 .And. SM2->M2_MOEDA17 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA18")) > 0 .And. SM2->M2_MOEDA18 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA19")) > 0 .And. SM2->M2_MOEDA19 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA20")) > 0 .And. SM2->M2_MOEDA20 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA21")) > 0 .And. SM2->M2_MOEDA21 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA22")) > 0 .And. SM2->M2_MOEDA22 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA23")) > 0 .And. SM2->M2_MOEDA23 > 0) .Or.;
			(SM2->(FieldPos("M2_MOEDA24")) > 0 .And. SM2->M2_MOEDA24 > 0)
		//
		_lZerados := .F.
		//
	Endif
//
Return (_lZerados)

/* Exemplo do Arquivo 20130815.csv (Estrutura Atual):
15/08/2013;5;A;AFN;0,04152000;0,04161000;56,32000000;56,42000000
15/08/2013;9;A;ETB;0,12380000;0,12510000;18,73700000;18,92400000
15/08/2013;15;A;THB;0,07480000;0,07494000;31,27000000;31,32000000
15/08/2013;20;A;PAB;2,34280000;2,34340000;1,00000000;1,00000000
15/08/2013;26;A;VEF;0,37190000;0,37290000;6,28420000;6,30000000
15/08/2013;30;A;BOB;0,33660000;0,34160000;6,86000000;6,96000000
15/08/2013;35;A;GHS;1,08970000;1,10540000;2,12000000;2,15000000
15/08/2013;40;A;CRC;0,00459300;0,00469500;499,10000000;510,10000000
15/08/2013;45;A;SVC;0,26770000;0,26800000;8,74250000;8,75250000
15/08/2013;51;A;NIO;0,09421000;0,09423000;24,86880000;24,86880000
15/08/2013;55;A;DKK;0,41660000;0,41680000;5,62260000;5,62320000
15/08/2013;60;A;ISK;0,01944000;0,01949000;120,23000000;120,49000000
15/08/2013;65;A;NOK;0,39410000;0,39440000;5,94110000;5,94510000
15/08/2013;70;A;SEK;0,35810000;0,35830000;6,54000000;6,54200000
15/08/2013;75;A;CZK;0,12030000;0,12050000;19,44700000;19,47700000
15/08/2013;90;A;GMD;0,07076000;0,07298000;32,11000000;33,11000000
15/08/2013;95;A;DZD;0,02911000;0,02947000;79,51000000;80,47000000
15/08/2013;100;A;KWD;8,20310000;8,26010000;0,28370000;0,28560000
15/08/2013;105;A;BHD;6,21430000;6,21590000;0,37700000;0,37700000
15/08/2013;115;A;IQD;0,00201200;0,00201600;1162,20000000;1164,20000000
15/08/2013;125;A;JOD;3,30300000;3,31320000;0,70730000;0,70930000
15/08/2013;130;A;LYD;1,83120000;1,85340000;1,26440000;1,27940000
15/08/2013;132;A;MKD;0,05042000;0,05068000;46,24000000;46,47000000
15/08/2013;133;A;RSD;0,02728000;0,02732000;85,77000000;85,87000000
15/08/2013;134;A;SDG;0,52880000;0,53340000;4,39300000;4,43000000
15/08/2013;135;A;TND;1,41120000;1,41390000;1,65740000;1,66010000
15/08/2013;136;A;SSP;0,58570000;0,78110000;3,00000000;4,00000000
15/08/2013;138;B;SDR;3,55680000;3,55770000;1,51820000;1,51820000
15/08/2013;139;A;MAD;0,27800000;0,27860000;8,41250000;8,42750000
15/08/2013;145;A;AED;0,63780000;0,63800000;3,67280000;3,67320000
15/08/2013;148;A;STD;0,00013220;0,00013230;17717,23000000;17717,23000000
15/08/2013;150;B;AUD;2,13290000;2,13370000;0,91040000;0,91050000
15/08/2013;155;A;BSD;2,34280000;2,34340000;1,00000000;1,00000000
15/08/2013;160;A;BMD;2,34280000;2,34340000;1,00000000;1,00000000
15/08/2013;165;A;CAD;2,26530000;2,26660000;1,03390000;1,03420000
15/08/2013;170;A;GYD;0,01135000;0,01169000;200,45000000;206,45000000
15/08/2013;173;A;NAD;0,23440000;0,23450000;9,99230000;9,99480000
15/08/2013;175;A;BBD;1,17730000;1,17760000;1,99000000;1,99000000
15/08/2013;180;A;BZD;1,19530000;1,19560000;1,96000000;1,96000000
15/08/2013;185;A;BND;1,84050000;1,84140000;1,27260000;1,27290000
15/08/2013;190;B;KYD;2,85700000;2,85780000;1,21950000;1,21950000
15/08/2013;195;A;SGD;1,83990000;1,84190000;1,27230000;1,27330000
15/08/2013;200;B;FJD;1,23110000;1,25490000;0,52550000;0,53550000
15/08/2013;205;A;HKD;0,30210000;0,30220000;7,75470000;7,75530000
15/08/2013;210;A;TTD;0,36320000;0,36670000;6,39000000;6,45000000
15/08/2013;215;A;XCD;0,86130000;0,87770000;2,67000000;2,72000000
15/08/2013;220;A;USD;2,34280000;2,34340000;1,00000000;1,00000000
15/08/2013;230;A;JMD;0,02304000;0,02318000;101,08000000;101,68000000
15/08/2013;235;A;LRD;0,02966000;0,03004000;78,00000000;79,00000000
15/08/2013;245;B;NZD;1,88430000;1,88600000;0,80430000;0,80480000
15/08/2013;250;B;SBD;0,31890000;0,33980000;0,13610000;0,14500000
15/08/2013;255;A;SRD;0,69930000;0,72100000;3,25000000;3,35000000
15/08/2013;260;A;VND;0,00011100;0,00011120;21070,00000000;21115,00000000
15/08/2013;275;A;AMD;0,00574600;0,00578300;405,25000000;407,75000000
15/08/2013;295;A;CVE;0,02840000;0,02840000;82,50000000;82,50000000
15/08/2013;325;A;ANG;1,33870000;1,33910000;1,75000000;1,75000000
15/08/2013;328;A;AWG;1,30160000;1,31650000;1,78000000;1,80000000
15/08/2013;345;A;HUF;0,01039000;0,01041000;225,18000000;225,48000000
15/08/2013;363;A;CDF;0,00247400;0,00259500;903,00000000;947,00000000
15/08/2013;365;A;BIF;0,00151300;0,00153400;1528,11000000;1548,11000000
15/08/2013;368;A;KMF;0,00629800;0,00631600;371,00000000;372,00000000
15/08/2013;370;A;XAF;0,00469400;0,00472000;496,45000000;499,15000000
15/08/2013;372;A;XOF;0,00466200;0,00481600;486,58000000;502,56000000
15/08/2013;380;A;XPF;0,02598000;0,02620000;89,44000000;90,16000000
15/08/2013;390;A;DJF;0,01341000;0,01341000;174,70000000;174,70000000
15/08/2013;398;A;GNF;0,00032630;0,00034590;6775,00000000;7180,00000000
15/08/2013;406;A;MGA;0,00104600;0,00108600;2158,00000000;2239,00000000
15/08/2013;420;A;RWF;0,00359900;0,00364400;643,00000000;651,00000000
15/08/2013;425;A;CHF;2,50970000;2,51060000;0,93340000;0,93350000
15/08/2013;440;A;HTG;0,05404000;0,05406000;43,35000000;43,35000000
15/08/2013;450;A;PYG;0,00052060;0,00053260;4400,00000000;4500,00000000
15/08/2013;460;A;UAH;0,28860000;0,28880000;8,11550000;8,11850000
15/08/2013;470;A;JPY;0,02395000;0,02396000;97,81000000;97,82000000
15/08/2013;482;A;GEL;1,40680000;1,41630000;1,65460000;1,66530000
15/08/2013;485;A;LVL;4,42120000;4,42820000;0,52920000;0,52990000
15/08/2013;490;A;ALL;0,02213000;0,02227000;105,22000000;105,88000000
15/08/2013;495;A;HNL;0,11490000;0,11490000;20,39000000;20,39000000
15/08/2013;500;A;SLL;0,00053650;0,00055000;4261,00000000;4367,00000000
15/08/2013;503;A;MDL;0,18230000;0,18450000;12,70000000;12,85000000
15/08/2013;506;A;RON;0,69900000;0,70000000;3,34770000;3,35170000
15/08/2013;510;A;BGN;1,58890000;1,58960000;1,47420000;1,47450000
15/08/2013;530;B;GIP;3,63840000;3,64020000;1,55300000;1,55340000
15/08/2013;535;A;EGP;0,33520000;0,33530000;6,98890000;6,98900000
15/08/2013;540;B;GBP;3,64800000;3,64940000;1,55710000;1,55730000
15/08/2013;545;B;FKP;3,63840000;3,64020000;1,55300000;1,55340000
15/08/2013;560;A;LBP;0,00154800;0,00155400;1508,00000000;1513,00000000
15/08/2013;570;B;SHP;3,63770000;3,64090000;1,55270000;1,55370000
15/08/2013;575;A;SYP;0,02149000;0,02163000;108,36000000;109,01000000
15/08/2013;585;A;SZL;0,23390000;0,23510000;9,96800000;10,01800000
15/08/2013;601;A;LTL;0,89980000;0,90070000;2,60170000;2,60360000
15/08/2013;603;A;LSL;0,23380000;0,23500000;9,97000000;10,02000000
15/08/2013;608;A;TMT;0,81860000;0,82170000;2,85200000;2,86200000
15/08/2013;622;A;MZN;0,07809000;0,07917000;29,60000000;30,00000000
15/08/2013;625;A;ERN;0,15860000;0,15860000;14,77580000;14,77580000
15/08/2013;630;A;NGN;0,01452000;0,01455000;161,10000000;161,30000000
15/08/2013;635;A;AOA;0,02424000;0,02437000;96,16000000;96,66000000
15/08/2013;640;A;TWD;0,07813000;0,07818000;29,97600000;29,98600000
15/08/2013;642;A;TRY;1,20640000;1,20920000;1,93800000;1,94200000
15/08/2013;660;A;PEN;0,83670000;0,83750000;2,79800000;2,80000000
15/08/2013;665;A;BTN;0,03821000;0,03823000;61,29800000;61,31800000
15/08/2013;670;A;MRO;0,00775800;0,00783700;299,00000000;302,00000000
15/08/2013;680;B;TOP;1,26140000;1,35120000;0,53840000;0,57660000
15/08/2013;685;A;MOP;0,29300000;0,29370000;7,98000000;7,99600000
15/08/2013;706;A;ARS;0,42000000;0,42030000;5,57500000;5,57750000
15/08/2013;715;A;CLP;0,00459400;0,00460800;508,50000000;510,00000000
15/08/2013;720;A;COP;0,00123100;0,00123400;1898,65000000;1903,65000000
15/08/2013;725;A;CUP;2,34280000;2,34340000;1,00000000;1,00000000
15/08/2013;730;A;DOP;0,05539000;0,05566000;42,10000000;42,30000000
15/08/2013;735;A;PHP;0,05343000;0,05348000;43,81500000;43,84500000
15/08/2013;741;A;MXN;0,18250000;0,18260000;12,83330000;12,83530000
15/08/2013;745;A;UYU;0,10720000;0,10850000;21,60000000;21,85000000
15/08/2013;755;B;BWP;0,27250000;0,27370000;0,11630000;0,11680000
15/08/2013;760;A;MWK;0,00689100;0,00732300;320,00000000;340,00000000
15/08/2013;766;A;ZMW;0,43070000;0,43240000;5,42000000;5,44000000
15/08/2013;770;A;GTQ;0,29740000;0,29760000;7,87500000;7,87800000
15/08/2013;775;A;MMK;0,00239800;0,00241300;971,00000000;977,00000000
15/08/2013;778;B;PGK;0,95610000;1,08050000;0,40810000;0,46110000
15/08/2013;779;A;HRK;0,41180000;0,41220000;5,68500000;5,68880000
15/08/2013;780;A;LAK;0,00029930;0,00030070;7793,00000000;7827,00000000
15/08/2013;785;A;ZAR;0,23430000;0,23460000;9,98850000;9,99850000
15/08/2013;795;A;CNY;0,38330000;0,38340000;6,11230000;6,11270000
15/08/2013;796;A;CNH;0,38320000;0,38360000;6,10970000;6,11320000
15/08/2013;800;A;QAR;0,64310000;0,64370000;3,64060000;3,64290000
15/08/2013;805;A;OMR;6,08520000;6,08680000;0,38500000;0,38500000
15/08/2013;810;A;YER;0,01087000;0,01091000;214,75000000;215,50000000
15/08/2013;815;A;IRR;0,00009450;0,00009450;24791,00000000;24791,00000000
15/08/2013;820;A;SAR;0,62470000;0,62490000;3,75030000;3,75050000
15/08/2013;825;A;KHR;0,00057680;0,00057690;4062,00000000;4062,00000000
15/08/2013;828;A;MYR;0,71450000;0,71530000;3,27600000;3,27900000
15/08/2013;829;A;BYR;0,00026290;0,00026300;8910,00000000;8910,00000000
15/08/2013;830;A;RUB;0,07094000;0,07098000;33,01550000;33,02580000
15/08/2013;835;A;TJS;0,49150000;0,49160000;4,76690000;4,76690000
15/08/2013;840;A;MUR;0,07533000;0,07658000;30,60000000;31,10000000
15/08/2013;845;A;NPR;0,02371000;0,02396000;97,80000000;98,80000000
15/08/2013;850;A;SCR;0,18670000;0,20250000;11,57000000;12,55000000
15/08/2013;855;A;LKR;0,01782000;0,01784000;131,35000000;131,45000000
15/08/2013;860;A;INR;0,03813000;0,03816000;61,41000000;61,44000000
15/08/2013;865;A;IDR;0,00022630;0,00022650;10345,00000000;10355,00000000
15/08/2013;870;A;MVR;0,15050000;0,15450000;15,17000000;15,57000000
15/08/2013;875;A;PKR;0,02279000;0,02284000;102,60000000;102,80000000
15/08/2013;880;A;ILS;0,65590000;0,65790000;3,56170000;3,57170000
15/08/2013;892;A;KGS;0,04830000;0,04832000;48,50070000;48,50070000
15/08/2013;893;A;UZS;0,00110400;0,00110800;2115,00000000;2123,00000000
15/08/2013;905;A;BDT;0,02996000;0,03016000;77,70000000;78,20000000
15/08/2013;911;A;WST;5,34760000;5,63320000;0,41600000;0,43810000
15/08/2013;913;A;KZT;0,01533000;0,01534000;152,81000000;152,87000000
15/08/2013;915;A;MNT;0,00149700;0,00150200;1560,00000000;1565,00000000
15/08/2013;916;A;CLF;0,00010190;0,00010190;23003,12000000;23003,12000000
15/08/2013;920;A;VUV;0,02370000;0,02457000;95,36000000;98,85000000
15/08/2013;930;A;KRW;0,00209400;0,00209600;1118,00000000;1119,00000000
15/08/2013;946;A;TZS;0,00144400;0,00145400;1612,00000000;1622,00000000
15/08/2013;950;A;KES;0,02676000;0,02680000;87,45000000;87,55000000
15/08/2013;955;A;UGX;0,00091090;0,00091470;2562,00000000;2572,00000000
15/08/2013;960;A;SOS;0,00170600;0,00184100;1273,00000000;1373,00000000
15/08/2013;975;A;PLN;0,73420000;0,73490000;3,18880000;3,19080000
15/08/2013;978;B;EUR;3,10700000;3,10880000;1,32620000;1,32660000
15/08/2013;998;A;XAU;100,80900000;100,83480000;0,02324000;0,02324000
*/
/* Exemplo do Arquivo 20130131.csv (Estrutura Anterior):
31/01/2013;005;A;AFN;00000000,03825;00000000,03826;000000051,9700;000000051,9700
31/01/2013;055;A;DKK;000000000,3616;000000000,3617;000000005,4966;000000005,4968
31/01/2013;150;B;AUD;000000002,0702;000000002,0710;000000001,0415;000000001,0416
31/01/2013;165;A;CAD;000000001,9859;000000001,9867;000000001,0008;000000001,0009
31/01/2013;220;A;USD;000000001,9877;000000001,9883;000000001,0000;000000001,0000
31/01/2013;328;A;AWG;000000001,1104;000000001,1108;000000001,7900;000000001,7900
31/01/2013;363;A;CDF;0000000,002168;0000000,002169;000000916,7181;000000916,7181
31/01/2013;425;A;CHF;000000002,1797;000000002,1806;000000000,9118;000000000,9119
31/01/2013;470;A;JPY;00000000,02179;000000000,0218;000000091,2000;000000091,2100
31/01/2013;540;B;GBP;000000003,1414;000000003,1425;000000001,5804;000000001,5805
31/01/2013;715;A;CLP;0000000,004217;00000000,00422;000000471,1400;000000471,4000
31/01/2013;785;A;ZAR;000000000,2224;000000000,2226;000000008,9327;000000008,9367
31/01/2013;795;A;CNY;000000000,3196;000000000,3197;000000006,2185;000000006,2195
31/01/2013;875;A;PKR;00000000,02033;00000000,02034;000000097,7300;000000097,7500
31/01/2013;978;B;EUR;000000002,6977;000000002,6987;000000001,3572;000000001,3573
*/

////////////////////////
User Function ManMoeda()               // Rotina de Atualizacao Manual de Taxas de Moedas
////////////////////////
//
	Private cCadastro := "Manutenção de Taxas de Moedas"
	Private aCoresBrw := {{'(SM2->M2_MOEDA1 > 0 .And. SM2->M2_MOEDA2 > 0 .And. SM2->M2_MOEDA3 > 0 .And. SM2->M2_MOEDA4 > 0)' , 'BR_VERDE'   },; // Taxas das Moedas Preenchidas
	{'(SM2->M2_MOEDA1 == 0 .Or. SM2->M2_MOEDA2 == 0 .Or. SM2->M2_MOEDA3 == 0 .Or. SM2->M2_MOEDA4 == 0)', 'BR_VERMELHO'}}  // Taxas das Moedas Nao Preenchidas
	Private cCondBrow := ".F."
	Private aRotina   := {{"Pesquisar", "AxPesqui"    , 0, 1},;
		{"Atualizar", "U_AxAtuMoe()", 0, 6},;
		{"Legenda"  , "U_AxLegMoe()", 0, 7}}
//
	SM2->(DbSetOrder(1))                   // Cadastro de Moedas
//
	DbSelectArea("SM2")                    // CondBrowse True=Vermelho, False=Verde
//
	Set Filter To (SM2->M2_DATA >= (M->dDataBase - 10) .And. SM2->M2_DATA <= (M->dDataBase + 4))
//
	mBrowse(06, 01, 22, 75, "SM2",, '&cCondBrow',,, 2, aCoresBrw)
//
	Set Filter To
//
Return (.T.)

////////////////////////
User Function AxLegMoe()               // Legenda de Cores
////////////////////////
//
	Local _cTitulo  := "Situação dos Registros"
	Local _aLegenda := {{'BR_VERDE'   , "Taxas das Moedas Preenchidas    "},;
		{'BR_VERMELHO', "Taxas das Moedas Não Preenchidas"}}
//
	BrwLegenda(_cTitulo, "Legenda", _aLegenda)
//
Return (.T.)

////////////////////////
User Function AxAtuMoe()               // Atualizacao de Moedas
////////////////////////
//
	Local _dDatBas := M->dDataBase         // Salvar a Data Base Corrente
//
	If Empty(SM2->M2_DATA)
		//
		MsgBox("A Data Selecionada Não é Válida !!!", "Atenção !!!", "ALERT")
		Return (.T.)
		//
	Endif
//
	M->dDataBase := SM2->M2_DATA
//
	U_AtuMoedas()                          // Chamada da Rotina de Atualizacao de Moedas p/ a Data Corrente
//
	M->dDataBase := _dDatBas               // Restaurar a Data Base Corrente
//
Return (.T.)
