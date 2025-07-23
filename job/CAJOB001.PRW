#include "protheus.ch"

/*/==============================================================================
{Protheus.doc} CAJOB001
@description Chamada de job para executar a gravacao da tabela fronteira SZ3 conforme os itens da nota SD1 (Integracao LN)
@author thiago.reis
@since 23/01/2023
@version 1.0
@type function
==============================================================================/*/
User Function CAJOB001(_cEmp, _cFil)

	Local _cLockName := "CAJOB001"

	Default _cEmp := "01"
	Default _cFil := "01"

	RpcSetType(3)
	if !RpcSetEnv(_cEmp,_cFil)
		Return
	endif

	conout("JOB CAJOB001 INICIADA - " +DtoC(Date()) + " - "+Time())

	if !LockByName(_cLockName,.T.,.T.)
		Return
	endif

	Process()

	UnLockByName(_cLockName,.T., .T.)


	conout("JOB CAJOB001 FINALIZADA - " +DtoC(Date()) + " - "+Time())

Return

/*/==============================================================================
	{Protheus.doc} Process
	@description Rotina de execucao
	@author thiago.reis
	@since 23/01/2023
	@version 1.0
	@type function
==============================================================================/*/
Static Function Process()

	Local _nx
	Local _aRecno := ExecQry()


	For _nx := 1 To Len(_aRecno)

		SD1->(dbGoTo(_aRecno[_nx]))
		u_CAEST002()

	Next

Return

/*/==============================================================================
	{Protheus.doc} ExecQry
	@description Rotina de query para retornar os dados a serem gravados na tabela SZ3
	@author thiago.reis
	@since 23/01/2023
	@version 1.0
	@type function
==============================================================================/*/
Static Function ExecQry()

	Local _cAliasQry 	:= GetNextAlias()
	Local _aRet			:= {}
	Local _cEmiLim		:= GetNewPar("CA_DTLIMLN","20230201")


	BeginSql Alias _cAliasQry

			SELECT R_E_C_N_O_ RECSD1
			FROM %Table:SD1%
			WHERE %NotDel%
			AND D1_FILIAL = %Exp:xFilial("SD1")%
			AND D1_SEQLN = ' '
			AND D1_DTDIGIT >= %Exp:_cEmiLim%
			AND D1_TES <> ' '

	EndSql

	While !(_cAliasQry)->(Eof())
		aAdd(_aRet,(_cAliasQry)->RECSD1)
		(_cAliasQry)->(dbSkip())
	end

	(_cAliasQry)->(dbCloseArea())

Return (_aRet)
