#Include "Totvs.ch"

/*/{Protheus.doc} FIMPOSTOS
Função para cálculo de impostos em faturamento
@type function
@version  
@author Gabriel Souza
@since 11/14/2025
@param cCliente, character, Codigo Cliente/Fornecedor
@param cLoja, character, Loja do Cliente/Fornecedor
@param cTipo, character, Tipo do Cliente/Fornecedor
@param cProduto, character, Codigo Produto
@param cTes, character, TES
@param nQtd, numeric, Quantidade
@param nPrc, numeric, Preco Unit
@param nValor, numeric, Valor total
@return aImp, array com impostos calculados
/*/
User function FIMPOSTOS(cCliente,cLoja,cTipo,cProduto,cTes,nQtd,nPrc,nValor)
	local aImp := {}
   Local i := 0
	
	for i := 1 to 62
		AAdd(aImp,0)
	next
	
	// -------------------------------------------------------------------
	// Realiza os calculos necessários
	// -------------------------------------------------------------------
	MaFisIni(cCliente,;									// 01- Codigo Cliente/Fornecedor
			 cLoja,;										   // 02- Loja do Cliente/Fornecedor
			 "C",;											// 03- C: Cliente / F: Fornecedor
			 "N",;											// 04- Tipo da NF
			 cTipo,;										   // 05- Tipo do Cliente/Fornecedor
			 MaFisRelImp("MTR700",{"SC5","SC6"}),;	// 06- Relacao de Impostos que suportados no arquivo
			 ,;												// 07- Tipo de complemento
			 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
			 "SB1",;										   // 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
			 "MTR700")										// 10- Nome da rotina que esta utilizando a funcao
		// MaFisIni(cCliente,;									// 01- Codigo Cliente/Fornecedor
		// 	 cLoja,;										   // 02- Loja do Cliente/Fornecedor
		// 	 "C",;											// 03- C: Cliente / F: Fornecedor
		// 	 "N",;											// 04- Tipo da NF
		// 	 cTipo,;										   // 05- Tipo do Cliente/Fornecedor
		// 	 MaFisRelImp("MT100",{"SF2","SD2"}),;//MaFisRelImp("MTR700",{"SC5","SC6"}),;	// 06- Relacao de Impostos que suportados no arquivo
		// 	 ,;												// 07- Tipo de complemento
		// 	 ,;												// 08- Permite incluir impostos no rodape (.T./.F.)
		// 	 "SB1",;										   // 09- Alias do cadastro de Produtos - ("SBI" para Front Loja)
		// 	 "MATA461")										// 10- Nome da rotina que esta utilizando a funcao
	
	// -------------------------------------------------------------------
	// Monta o retorno para a MaFisRet
	// -------------------------------------------------------------------
	MaFisAdd(cProduto,cTes,nQtd,nPrc,0,"","",,0,0,0,0,nValor,0)
	
	// -------------------------------------------------------------------
	// Monta um array com os valores necessários
	// -------------------------------------------------------------------
	aImp[01] := cProduto
	aImp[02] := cTes
	aImp[03] := "ICM"							      //03 ICMS
	aImp[04] := MaFisRet(1,"IT_BASEICM" )		//04 Base do ICMS
	aImp[05] := MaFisRet(1,"IT_ALIQICM" )		//05 Aliquota do ICMS
	aImp[06] := MaFisRet(1,"IT_VALICM"  )		//06 Valor do ICMS
	aImp[07] := "IPI"							      //07 IPI
	aImp[08] := MaFisRet(1,"IT_BASEIPI" )		//08 Base do IPI
	aImp[09] := MaFisRet(1,"IT_ALIQIPI" )		//09 Aliquota do IPI
	aImp[10] := MaFisRet(1,"IT_VALIPI"  )		//10 Valor do IPI
	aImp[11] := "PIS"							      //11 PIS/PASEP
	aImp[12] := MaFisRet(1,"IT_BASEPIS" )		//12 Base do PIS
	aImp[13] := MaFisRet(1,"IT_ALIQPIS" )		//13 Aliquota do PIS
	aImp[14] := MaFisRet(1,"IT_VALPIS"  )		//14 Valor do PIS
	aImp[15] := "COF"							      //15 COFINS
	aImp[16] := MaFisRet(1,"IT_BASECOF" )		//16 Base do COFINS
	aImp[17] := MaFisRet(1,"IT_ALIQCOF" )		//17 Aliquota COFINS
	aImp[18] := MaFisRet(1,"IT_VALCOF"  )		//18 Valor do COFINS
	aImp[19] := "ISS"							      //19 ISS
	aImp[20] := MaFisRet(1,"IT_BASEISS" )		//20 Base do ISS
	aImp[21] := MaFisRet(1,"IT_ALIQISS" )		//21 Aliquota ISS
	aImp[22] := MaFisRet(1,"IT_VALISS"  )		//22 Valor do ISS
	aImp[23] := "IRR"							      //23 IRRF
	aImp[24] := MaFisRet(1,"IT_BASEIRR" )		//24 Base do IRRF
	aImp[25] := MaFisRet(1,"IT_ALIQIRR" )		//25 Aliquota IRRF
	aImp[26] := MaFisRet(1,"IT_VALIRR"  )		//26 Valor do IRRF
	aImp[27] := "INS"							      //27 INSS
	aImp[28] := MaFisRet(1,"IT_BASEINS" )		//28 Base do INSS
	aImp[29] := MaFisRet(1,"IT_ALIQINS" )		//29 Aliquota INSS
	aImp[30] := MaFisRet(1,"IT_VALINS"  )		//30 Valor do INSS
	aImp[31] := "CSL"							      //31 CSLL
	aImp[32] := MaFisRet(1,"IT_BASECSL" )		//32 Base do CSLL
	aImp[33] := MaFisRet(1,"IT_ALIQCSL" )		//33 Aliquota CSLL
	aImp[34] := MaFisRet(1,"IT_VALCSL"  )  	//34 Valor do CSLL
	aImp[35] := "PS2"							      //35 PIS/Pasep - Via Apuração
	aImp[36] := MaFisRet(1,"IT_BASEPS2" ) 		//36 Base do PS2 (PIS/Pasep - Via Apuração)
	aImp[37] := MaFisRet(1,"IT_ALIQPS2" )		//37 Aliquota PS2 (PIS/Pasep - Via Apuração)
	aImp[38] := MaFisRet(1,"IT_VALPS2"  )  	//38 Valor do PS2 (PIS/Pasep - Via Apuração)
	aImp[39] := "CF2"							      //39 COFINS - Via Apuração
	aImp[40] := MaFisRet(1,"IT_BASECF2" )		//40 Base do CF2 (COFINS - Via Apuração)
	aImp[41] := MaFisRet(1,"IT_ALIQCF2" )		//41 Aliquota CF2 (COFINS - Via Apuração)
	aImp[42] := MaFisRet(1,"IT_VALCF2"  )		//42 Valor do CF2 (COFINS - Via Apuração)
	aImp[43] := "ICC"							      //43 ICMS Complementar
	aImp[44] := MaFisRet(1,"IT_ALIQCMP" )		//44 Base do ICMS Complementar
	aImp[45] := MaFisRet(1,"IT_ALIQCMP" )		//45 Aliquota do ICMS Complementar
	aImp[46] := MaFisRet(1,"IT_VALCMP"  )		//46 Valor do do ICMS Complementar
	aImp[47] := "ICA"							      //47 ICMS ref. Frete Autonomo
	aImp[48] := MaFisRet(1,"IT_BASEICA" )		//48 Base do ICMS ref. Frete Autonomo
	aImp[49] := 0								      //49 Aliquota do ICMS ref. Frete Autonomo
	aImp[50] := MaFisRet(1,"IT_VALICA"  )  	//50 Valor do ICMS ref. Frete Autonomo
	aImp[51] := "TST"							      //51 ICMS ref. Frete Autonomo ST
	aImp[52] := MaFisRet(1,"IT_BASETST" )		//52 Base do ICMS ref. Frete Autonomo ST
	aImp[53] := MaFisRet(1,"IT_ALIQTST" )		//53 Aliquota do ICMS ref. Frete Autonomo ST
	aImp[54] := MaFisRet(1,"IT_VALTST"  )		//54 Valor do ICMS ref. Frete Autonomo ST
	aImp[55] := MaFisRet(1,"IT_BASESOL" )		//55 Base do ICMS ST
	aImp[56] := MaFisRet(1,"IT_ALIQSOL" )		//56 Aliquota do ICMS ST
	aImp[57] := MaFisRet(1,"IT_VALSOL"  )  	//57 Valor do ICMS ST
	aImp[58] := MaFisRet(1,"IT_DESCONTO")		//58 Valor do Desconto
	aImp[59] := MaFisRet(1,"IT_FRETE"   )		//59 Valor do Frete
	aImp[60] := MaFisRet(1,"IT_SEGURO"  )	   //60 Valor do Seguro
	aImp[61] := MaFisRet(1,"IT_DESPESA" )		//61 Valor das Despesas
	aImp[62] := MaFisRet(1,"IT_VALMERC" )		//62 Valor da Mercadoria
	
	MaFisEnd()
return aImp
