#INCLUDE "PROTHEUS.CH"


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEPCP01
  Função para identificar mudanças em uma Estrutura de Produto e notificar o usuario por e-mail.
  @type function
  @author Silvio Mota
  @since 01/08/2025
  @param a_Recnos, 	array, 	Array com lista dos recno alterados (recebido do ponto de entrada P200GRAV).
  @return nil
/*/
//-------------------------------------------------------------------------------------------------------------
User Function PEPCP01( a_Recnos )
	Local n_Ind
	Local n_Ind1
	Local a_AltEP    := {}
	Local c_MailBody := ""
	Local c_MailTo   := AllTrim(GetMV( 'MV_XXMAEP' ))
	Local a_EPAlt

	If empty(c_MailTo)
		Return(nil)
	EndIf

	// Monta uma listas de todas as EP que foram alteradas, com nova revisao que foi gerada.
	a_EPAlt := {}
	For n_Ind1 := 1 to len( a_Recnos )
		SG1->(dbgoto( a_Recnos[n_Ind1,2] ))

		n_Pos := aScan( a_EPAlt, {|x| x[1] == SG1->G1_COD }  )
		If n_Pos > 0
			If SG1->G1_REVFIM > a_EPAlt[n_Pos,2]
				a_EPAlt[n_Pos,2] := SG1->G1_REVFIM
			EndIf
		Else
			aAdd( a_EPAlt, { SG1->G1_COD, SG1->G1_REVFIM, Nil } )
		EndIf
	Next

	// Complementa o array com a Revisao Anterior
	For n_Ind1 := 1 to len(a_EPAlt)
		a_EPAlt[n_Ind1,3] := RevAnt( a_EPAlt[n_Ind1, 2] )
	Next

	// Obtem a listas das diferenças entre a revisão anterior e atual das EP alteradas.
	a_AltEP := GetAltEp( a_EPAlt )

	If len(a_AltEP) > 0
		c_MailSubj := "Notificação de Alterações em Estrutura de Produto "

		c_MailBody := "<HTML> "
		c_MailBody += "<BODY> "
		c_MailBody += "Foram identificadas as seguintes alterações em  Estrutura de Produto : <br/><br/> "
		c_MailBody += " <table>                          "
		c_MailBody += " <thead> <tr>                     "
		c_MailBody += "         <th> Produto       </th> "
		c_MailBody += "         <th> Rev. Atual    </th> "
		c_MailBody += "         <th> Rev. Anterior </th> "
		c_MailBody += "         <th> Componente    </th> "
		c_MailBody += "         <th> Mudança       </th> "
		c_MailBody += "</tr></thead>                     "
		c_MailBody += "<tbody>                           "

		For n_Ind := 1 to len(a_AltEP)
			c_MailBody += "<tr>
			c_MailBody += "<td> " + a_AltEP[ n_Ind, 1 ] + "-" + a_AltEP[ n_Ind, 2 ]  +  "</td> "
			c_MailBody += "<td> " + a_AltEP[ n_Ind, 3 ] +                               "</td> "
			c_MailBody += "<td> " + a_AltEP[ n_Ind, 4 ] +                               "</td> "
			c_MailBody += "<td> " + a_AltEP[ n_Ind, 5 ] + "-" + a_AltEP[ n_Ind, 6 ]  +  "</td> "
			c_MailBody += "<td> " + iif( a_AltEP[ n_Ind, 7 ] == 1, 'Componente Incluido',  iif( a_AltEP[ n_Ind, 7 ] == 2, 'Componente Excluido',  iif( a_AltEP[ n_Ind, 7 ] == 3, "Alterado campo do componente (conforme controle de revisões)" , "" ) ) )  +  "</td> "
			c_MailBody += "</tr>
		Next
		c_MailBody += "</tbody>           "
		c_MailBody += "</table> <BR> <BR> "
		c_MailBody += "OBS: Essa é uma mensagem automática gerada pelo sistema Protheus. Em caso de inconformidades, favor contatar a equipe de T.I.<br/> "
		c_MailBody += "</BODY>"
		c_MailBody += "</HTML>"

		If ! U_EnvMail( , , c_MailTo,  c_MailSubj, c_MailBody, "", "", {} )
			Conout("Falha inesperada no envio de e-mail de validade de orçamentos.")
		Endif
	EndIf

Return(Nil)




//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetAltEp( a_EPAlt )
  Função para listas as diferenças entre as duas revisoes das EP
  @type function
  @author Silvio Mota
  @since 01/08/2025
  @param a_EPAlt, 	array, 	Array multidimencional com lista de cada componente que teve mudança( incluidor, excluidos e alterados)

	Elemento dos array:
	[Linha][1] - Codigo de Produto da EP
	[Linha][2] - Descricao do codigo
	[Linha][3] - Revisao Atual da EP
	[Linha][4] - Revisao anterior da EP
	[Linha][5] - Codigo do componente
	[Linha][6] - Descricao do componente
	[Linha][7] - Id da mudança : 1. Inclusão de Componete / 2. Exclusão de Componente / 3. Alteração de Compoente  (alterou alguma campo do item)
	[Linha][8] - Ação (NÃO IMPLEMENTADAO - A ideia era detalhra a alteração de necessario.)
  @return nil
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function GetAltEp( a_EPAlt )
	Local a_Ret   := {}
	Local c_Query := ""
	Local n_Ind1
	Local c_Cod
	Local c_RevNew
	Local c_RevOld
	Local a_QryField := CmpCtlRev()

	For n_Ind1 := 1 to len(a_EPAlt)
		c_Cod    := a_EPAlt[n_Ind1,1]
		c_RevNew := a_EPAlt[n_Ind1,2]
		c_RevOld := a_EPAlt[n_Ind1,3]

		c_Query := "SELECT  ISNULL(OLD.G1_COMP, NEW.G1_COMP) AS COMP,                                       "
		c_Query += "        CASE WHEN OLD.G1_COMP  IS NULL         THEN 1 ELSE                              "
		c_Query += "        CASE WHEN NEW.G1_COMP  IS NULL         THEN 2 ELSE                              "
		c_Query += "        CASE WHEN " + a_QryField[2] + " THEN 3 ELSE 0 END END END AS IDACAO, '' AS ACAO "
		c_Query += "FROM   (SELECT  G1_COMP, '" + c_RevOld + "' AS REV " + a_QryField[1]
		c_Query += "        FROM    "+RetSqlName("SG1")+"                                                                                                          "
		c_Query += "        WHERE   G1_FILIAL = '01' AND G1_COD = '" + c_Cod + "'  AND  ('" + c_RevOld + "' BETWEEN G1_REVINI AND G1_REVFIM ) AND D_E_L_E_T_ = ''      "
		c_Query += "        ) OLD                                                                                                                   "
		c_Query += "        FULL JOIN                                                                                                               "
		c_Query += "       (SELECT  G1_COMP, '" + c_RevNew + "' AS REV " + a_QryField[1]
		c_Query += "        FROM    "+RetSqlName("SG1")+"                                                                                                          "
		c_Query += "        WHERE   G1_FILIAL = '"+xFilial("SG1")+"' AND G1_COD = '" + c_Cod + "'  AND  ('" + c_RevNew + "' BETWEEN G1_REVINI AND G1_REVFIM ) AND D_E_L_E_T_ = ''      "
		c_Query += "       ) NEW                                                                                                                    "
		c_Query += "       ON OLD.G1_COMP = NEW.G1_COMP                                                                                             "
		c_Query += "WHERE  ( OLD.G1_COMP IS NULL OR NEW.G1_COMP IS NULL ) OR                                                                      "
		c_Query += "       ( ( OLD.G1_COMP IS NOT NULL AND NEW.G1_COMP IS NOT NULL ) AND (" + a_QryField[2] + ")  ) "

		dbUseArea( .T., "TOPCONN", TCGenQry(,,c_Query), "QRY", .F., .T.)
		c_Query := ChangeQuery(c_Query)

		QRY->(dbGotop())
		Do While  QRY->(! eof())
			aAdd( a_Ret, { c_Cod, Posicione("SB1", 1, xFilial("SB1") + c_Cod, "B1_DESC" ) , c_RevNew, c_RevOld, QRY->COMP, Posicione("SB1", 1, xFilial("SB1") + QRY->COMP, "B1_DESC" ), QRY->IDACAO, QRY->ACAO } )
			QRY->(dbSkip())
		EndDo

		QRY->(dbCloseArea())
	Next

Return( a_Ret )




//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RevAnt
  Função para, dada uma revisão, retorna a anterior
  @type function
  @author Silvio Mota
  @since 04/08/2025
  @param c_Revnew, 	Char, 	Revisao atual
  @return c_Ret, 	char, 	revisao anterior
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function RevAnt( c_RevNew )
	Local c_Ret
	Local n_Valor

	n_Valor := val(c_RevNew)
	If n_Valor == 1
		c_Ret := space(3)
	Else
		c_Ret := StrZero( n_Valor-1, 3 )
	EndIf

Return( c_Ret )




//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CmpCtlRev
  Retorno um array com 2 posições, com string para ser usada no Script de comparação das Estruturas de Produto.
  @type function
  @author Silvio Mota
  @since 04/08/2025
  @param 
  @return a_Fields, 	array, 	Campos alterado
 	a_Fields[1] -> Lista dos campos para usar na clause SELECT do Script
 	a_Fields[2] -> Strng com Comparação dos campos para ser se foram alterados ou não.
/*/
//-------------------------------------------------------------------------------------------------------------

Static Function CmpCtlRev()
	Local a_Fields  := { '', '', {} }

	SOW->(dbSetOrder(1)) //OW_FILIAL, OW_CODIGO
	SOW->(dbSeek( xFilial('SOW') ))
	Do While SOW->(! eof()) .and. SOW->OW_FILIAL == xFilial('SOW')
		If SOW->OW_REVISA =='2'
			a_Fields[1] += ", "  + SOW->OW_CODIGO
			a_Fields[2] += iif( empty(a_Fields[2]), "", " OR " ) +  "( OLD." + SOW->OW_CODIGO + " <> NEW." + SOW->OW_CODIGO + ") "
			aAdd( a_Fields[3], SOW->OW_CODIGO )
		EndIf
		SOW->(dbSkip())
	EndDo

	If Empty(a_Fields[1])
		a_Fields := { '', '1=0', {} }
	EndIf

Return( a_Fields )
