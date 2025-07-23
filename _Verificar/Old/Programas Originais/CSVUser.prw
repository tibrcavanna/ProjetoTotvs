#include "rwmake.ch"
#define _ArqLog "\SIGAADV\ISNULL"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บCSVUser   บ Autor บ Mauro Paladini Han บ Data ณ  23/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบObjetivo  ณLista em formato CSV todos os usuarios cadastrados no arquivบฑฑ
ฑฑบ          ณo de senhas.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNil                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CSVUser()
	
	@ 000,000 To 160,350 Dialog _WndMain TITLE "Rela็ใo de Usuแrios"
	@ 005,005 To 040,165
	@ 015,010 Say OemToAnsi("Este programa ir agerar um arquivo CSV contendo a lista")
	@ 025,010 say OemToAnsi("dos usuแrios cadastrado no arquivo de senhas." )
	@ 055,080 Bmpbutton Type 1 Action ProcSenhas()
	@ 055,110 Bmpbutton Type 2 Action Close(_WndMain)
	@ 055,140 Bmpbutton Type 5 Action Pergunte("X1NULL",.T.)
	Activate Dialog _WndMain Centered
	
Return

Static Function ProcSenhas()
      
	Close(_WndMain)
	Processa({|| RunReport()},"Gerando relat๓rio" )
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณRunReport บAutor  ณMauro Paladini      บ Data ณ  23/02/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar para processamento do relatorio             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RunReport()
	
	Local cNomeRel	:= "USERS.CSV"	
	Local aUsuario	:= AllUsers()
    Local aGrupos   := Allgroups()
	
	cCabec := "Codigo;Login;Nome;Validade;Senha;Departamento;Ramal;Cargo;EMail;Conex๕es;Altera็ใo;Status;Digitos;Diret๓rio Relato;"
	cCabec += "Produto (E);Produto (A);Cadastro (E);Ped Compra (A);Ped Compra (E);TES (A);TES (E);Inventแrio;Fechto Mensal;Dif Inventแrio;F3 Inclusใo;Atendimento;"
	cCabec += "Troco;Sangria;Como Pagar;Recebimento;Trocas;Tab Pre็o;Database (A);A/F Caixa;Exc Cupom/NF;Alt No NF;NF Retroativa;BX Receber (E);"
	cCabec += "BX Pagar (A);Cadastros (I);Cadastros(A);Exce็ใo Fiscal;"
	cCabec += "Ativo Fixo;Compras;Contabilidade;Estoque;Faturamento;Financeiro;Gestใo Pessoal;SigaFas;Fiscal;PCP;Veํculos;SigaLoja;Televendas;"
	cCabec += "SigaOfi;SigaRPM;Ponto;SigaEIC;SigaGRH;SigaMnt;SigaRSP;SigaQIE;SigaQMT;SigaFRT;SigaQDO;SigaQIP;SigaTRM;SigaEIF;Field Service;"
	cCabec += "SigaEEC;SigaEEF;SigaECO;SigaAFV;SigaPLS;SigaCTB;SigaMDT;SigaQNC;SigaQAD;SigaQCP;SigaOMS;SigaCSA;SigaPEC;SigaWMS;SigaTMS;SigaPMS;"
	cCabec += "SigaCDA;SigaACD;SigaPPAP;R้plica;SigaGE;SigaEDC;SigaHSP;SigaVDoc;SigaAPD;SigaGSP;SigaCRD;SigaESP;SigaESP1"
	
	If File(cNomeRel)
		Delete File &(cNomeRel)
	Endif
	
	LJWriteLog( cNomeRel , cCabec )	
	
	ProcRegua(Len(aUsuario))
	For x := 1 To Len(aUsuario)
	
		// Desmembra em tres vetores os dados
		// do usuario posicionado do aUsuario.

		aDados1 := aUsuario[x,1]
		aDados2	:= aUsuario[x,2]
		aDados3 := aUsuario[x,3] // Menus
		
		cID		:= "*"+aDados1[1]
		cLogin	:= aDados1[2]
		cSenha	:= aDados1[3]
		cNome	:= AllTrim(aDados1[4])
		dValid	:= aDados1[6]
		lChange	:= aDados1[8]
		cDepto	:= AllTrim(aDados1[12])
		cCargo	:= AllTrim(aDados1[13])
		cEMail	:= AllTrim(aDados1[14])
		nConex	:= aDados1[15]
		dDataRef:= aDados1[16]
		lStatus	:= aDados1[17]
		nDigito	:= aDados1[18]
		cRamal	:= RTrim(aDados1[20])
		cDir	:= RTrim(aDados2[3])
		cAcesso	:= aDados2[5]
		aEmpresa:= aDados2[6]
        aGrupo  := aDados1[10]
        
		IncProc( cNome )
		
		// Imprime dados cadastrais
		cTXT := cID + ";" + cLogin + ";" + cNome + ";" + IIF(!Empty(dValid),dtoc(dValid),"") + ";" + IIF(lChange,"Sim","Nao") + ";" + cDepto + ";" + cRamal + ";"
		cTXT += cCargo + ";" + cEMail + ";" + AllTrim(Str(nConex)) + ";" + dtoc(dDataRef) + ";" + IIF(!lStatus,"Ativo","Bloq") + ";"
		cTXT += AllTrim(Str(nDigito)) + ";" + cDir + ";"
		
		// Imprime acesso detalhado
		cTXT += Ra(1) + ";" + Ra(2) + ";" + Ra(3) + ";" + Ra(6) + ";" + Ra(7) + ";" + Ra(15) + ";" + Ra(16) + ";" + Ra(17) + ";" + Ra(18) + ";"
		cTXT += Ra(19) + ";" + Ra(24) + ";" + Ra(25) + ";" + Ra(26) + ";" + Ra(27) + ";" + Ra(29) + ";" + Ra(30) + ";" + Ra(31) + ";" + Ra(32) + ";"
		cTXT += Ra(36) + ";" + Ra(41) + ";" + Ra(42) + ";" + Ra(50) + ";" + Ra(51) + ";" + Ra(52) + ";" + Ra(53) + ";" + Ra(81) + ";" + Ra(82) + ";"
		cTXT += Ra(108)	+ ";"
		
		// Lista os modulos e menus
		cTXT += Modulos(aDados3)
		
		// Lista as empresas
		cTXT += Empresas(aEmpresa)

		// Lista os grupo
		cTXT += Grupos(aGrupo)

		
		LJWriteLog( cNomeRel , cTXT )
	
	Next


	ProcRegua(Len(aGrupos))
	For x := 1 To Len(aGrupos)
	
		// Desmembra em tres vetores os dados

		aDados1 := aGrupos[x,1]
		//aDados2	:= aGrupos[x,2]
		aDados3 := aGrupos[x,2] // Menus
		
		cID		:= "*"+aDados1[1]
		cLogin	:= "GRUPOS"
		cSenha	:= ""
		cNome	:= AllTrim(aDados1[2])
		dValid	:= aDados1[4]
		lChange	:= .t.
		cDepto	:= ""
		cCargo	:= ""
		cEMail	:= ""
		nConex	:= 0
		dDataRef:= aDados1[12]
		lStatus	:= .f.
		nDigito	:= 0
		cRamal	:= ""
		cDir	:= RTrim(aDados1[8])
		cAcesso	:= aDados1[10]
		//aEmpresa:= aDados2[6]

		IncProc( cNome )
		
		// Imprime dados cadastrais
		cTXT := cID + ";" + cLogin + ";" + cNome + ";" + IIF(!Empty(dValid),dtoc(dValid),"") + ";" + IIF(lChange,"Sim","Nao") + ";" + cDepto + ";" + cRamal + ";"
		cTXT += cCargo + ";" + cEMail + ";" + AllTrim(Str(nConex)) + ";" + dtoc(dDataRef) + ";" + IIF(!lStatus,"Ativo","Bloq") + ";"
		cTXT += AllTrim(Str(nDigito)) + ";" + cDir + ";"
		
		// Imprime acesso detalhado
		cTXT += Ra(1) + ";" + Ra(2) + ";" + Ra(3) + ";" + Ra(6) + ";" + Ra(7) + ";" + Ra(15) + ";" + Ra(16) + ";" + Ra(17) + ";" + Ra(18) + ";"
		cTXT += Ra(19) + ";" + Ra(24) + ";" + Ra(25) + ";" + Ra(26) + ";" + Ra(27) + ";" + Ra(29) + ";" + Ra(30) + ";" + Ra(31) + ";" + Ra(32) + ";"
		cTXT += Ra(36) + ";" + Ra(41) + ";" + Ra(42) + ";" + Ra(50) + ";" + Ra(51) + ";" + Ra(52) + ";" + Ra(53) + ";" + Ra(81) + ";" + Ra(82) + ";"
		cTXT += Ra(108)	+ ";"
		
		// Lista os modulos e menus
		cTXT += Modulos(aDados3)
		
		LJWriteLog( cNomeRel , cTXT )
	
	Next


Return


Static Function Modulos( aMenus )

	Local cRet	:= ""
	
	For s := 1 To Len(aMenus)
	
		cReg 	:= aMenus[s]
		lUsado	:= IIF(Substr(cReg,3,1)=="X",.F.,.T.)
		cMenu	:= Capital(AllTrim(Substr(cReg,4,Len(cReg))))
		
		If lUsado
			cRet	+= cMenu + ";"
		Else
			cRet	+= "N;"
		Endif	
	
	Next
	
	cRet += ";;"


Return(cRet)

Static Function Empresas( aEmp )

	Local cRet	:= ""
	
	For s := 1 To Len(aEmp)
	
		cReg 	:= "*"+aEmp[s]
		cRet	+= cReg + ";"
	
	Next
	
	//cRet := Substr(cRet,1,Len(cRet)-1)


Return(cRet)

Static Function Grupos( aGrp )

	Local cRet	:= ""
	
	For s := 1 To Len(aGrp)
	
		cReg 	:= "*"+aGrp[s]
		cRet	+= cReg + ";"
	
	Next
	
	cRet := Substr(cRet,1,Len(cRet)-1)


Return(cRet)


Static Function Ra( nPos )	

	Local cRet := Substr(cAcesso,nPos,1)
	
Return( cRet )