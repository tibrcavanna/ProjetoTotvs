#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TCBROWSE.CH"

USER FUNCTION INTEICAM()


    Local aPergs     := {}
    Local cProdAte := PADR("", TamSX3("B1_COD")[1], "Z")
    Local cProdDe  := Space(TamSX3("B1_COD")[1])
    Local cTipoAte := PADR("", TamSX3("B1_TIPO")[1], "Z")
    Local cTipoDe  := Space(TamSX3("B1_TIPO")[1])
    Local cGrpAte  := PADR("", TamSX3("B1_GRUPO")[1], "Z")
    Local cGrpDe   := Space(TamSX3("B1_GRUPO")[1])
    
    Private oSayObj1 
    Private cSayObj1    := 'Digite o Estado: '
    Private aCmbObj3    := {'XX=Nenhuma Região', 'NT=Norte', 'ND=Nordeste', 'CO=Centro Oeste', 'SD=Sudeste', 'SU=Sul'}
    Private oCmbObj3
    Private oFontPadrao := TFont():New('Tahoma', , -12)

    Private _aItens := {}  
    Private _oDlgInteg   
    Private _oProdutos

    /*
    aAdd(aPergs, {1, "Produto de:" , SPACE(TamSx3("B1_COD")[1]), "", ".T.", "SB1", ".T.", 0       , .F.}) // MV_PAR01
    aAdd(aPergs, {1, "Produto at?:", SPACE(TamSx3("B1_COD")[1]), "", ".T.", "SB1", ".T.", 0       , .F.}) // MV_PAR02
    aAdd(aPergs, {1, "Grupo de:" , SPACE(TamSx3("B1_GRUPO")[1]), "", ".T.", "SBM", ".T.", 0       , .F.}) // MV_PAR03
    aAdd(aPergs, {1, "Grupo at?:", SPACE(TamSx3("B1_GRUPO")[1]), "", ".T.", "SBM", ".T.", 0       , .F.}) // MV_PAR04
    aAdd(aPergs, {1, "Tipo:"     , SPACE(50)                   , "", ".T.", ""   , ".T.", 100       , .F.}) // MV_PAR05
    aAdd(aPergs, {1, "Validade tabela:", CTOD(""), "", ".T.", "", ".T.", 50       , .F.}) // MV_PAR06
    */

    // PESQUISAR PARAMBOX DE COMBO BOX
    aAdd(aPergs, {2, "Movimento a Integrar",      1, {"1=Solicitação ao Armazém", "2=Endereçamento", "3=Movimento Interno Entrada", "4=Transferência Entrada" , "5=Movimento Interno Saída", "6=Transferência Saída", "7=Cadastro de Produtos"},  100, ".T.", .F.})
    aAdd(aPergs, {1,'Produto de: '  ,cProdDe ,'@!' ,'.T.','SB1','.T.',60,.F.})
    aAdd(aPergs, {1,'Produto até: '  ,cProdAte ,'@!' ,'.T.','SB1','.T.',60,.F.})
    aAdd(aPergs, {1,'Tipo de: '  ,cTipoDe ,'@!' ,'.T.','02','.T.',60,.F.})
    aAdd(aPergs, {1,'Tipo até: '  ,cTipoAte ,'@!' ,'.T.','02','.T.',60,.F.})
    aAdd(aPergs, {1,'Grupo de: '  ,cGrpDe ,'@!' ,'.T.','SBM','.T.',60,.F.})
    aAdd(aPergs, {1,'Grupo até: '  ,cGrpAte ,'@!' ,'.T.','SBM','.T.',60,.F.})

    If ParamBox(aPergs, "Informe os parâmetros")
        FWMsgRun(, {|| PROCESSAR()}, "Carregando Dados, Aguarde...")
    EndIf

Return

//Função para gerar id unico
Static Function GeraIdUnico()

    Local cId := ""

    // Pega valor atual (string)
    cId := Soma1(AllTrim(GetMV("ES_IDUICAM"))) // "999999999" / "9999999AB"

    // Atualiza o parâmetro como string
    PutMV("ES_IDUICAM", cId)

Return cId

//Fim
Static Function PROCESSAR()

    Local cQuery := ""
    Local cAliasQry := ""
    Local aTamanho := FWGetDialogSize(oMainWnd)
    Local cTitulo := ""
    Local oCheck  	:= LoadBitmap( GetResources(), "CHECKED" )
	Local oNoCheck	:= LoadBitmap( GetResources(), "UNCHECKED" )

    MV_PAR01 := CValToChar(MV_PAR01)
    
    If MV_PAR01 == "1" // SOLICITAÇÃO AO ARMAZÉM

        cTitulo := "SOLICITAÇÃO AO ARMAZÉM" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM " + Retsqlname("SCP") + " SCP" + CRLF
        cQuery += "INNER JOIN " +Retsqlname("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = CP_PRODUTO AND B1_XICAM = 'S'" + CRLF
        cQuery += "WHERE SCP.D_E_L_E_T_ = ' ' AND CP_FILIAL = '" +xFilial("SCP")+ "'" + CRLF
        cQuery += "AND CP_XINICAM = ''" + CRLF
        cQuery += "ORDER BY CP_FILIAL+CP_NUM+CP_ITEM+CP_EMISSAO" + CRLF
        
    ElseIf MV_PAR01 == "2" // ENDEREÇAMENTO

        cTitulo := "ENDEREÇAMENTO" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM "+Retsqlname("SDB")+" SDB" + CRLF
        cQuery += "WHERE SDB.D_E_L_E_T_ = ' ' AND DB_FILIAL = '"+xFilial("SDB")+"'" + CRLF
        //cQuery += "AND DB_LOCALIZ = 'ICAM'" + CRLF
        cQuery += "AND DB_XINICAM = ''" + CRLF
        cQuery += "AND DB_ESTORNO = ' '" + CRLF
        cQuery += "ORDER BY DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM" + CRLF

    ElseIf MV_PAR01 == "3" //MOVIMENTO INTERNO ENTRADA

        cTitulo := "MOVIMENTO INTERNO ENTRADA" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM "+Retsqlname("SD3")+" SD3" + CRLF
        cQuery += "WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"'" + CRLF
        cQuery += "AND D3_XINICAM = ''" + CRLF
        //cQuery += "AND D3_LOCALIZ = 'ICAM'" + CRLF
        cQuery += "AND D3_TM < '499'" + CRLF
        cQuery += "AND D3_ESTORNO = ' '" + CRLF
        cQuery += "ORDER BY D3_DOC, D3_COD, D3_LOCAL" + CRLF

    ElseIf MV_PAR01 == "4" // TRANSFERENCIA ENTRADA

        cTitulo := "TRANSFERÊNCIA ENTRADA" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM "+Retsqlname("SD3")+" SD3" + CRLF
        cQuery += "WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"'" + CRLF
        cQuery += "AND D3_XINICAM = ' '" + CRLF
        cQuery += "AND D3_ESTORNO = ' '" + CRLF 
        //cQuery += "AND D3_LOCALIZ = 'ICAM'" + CRLF
        cQuery += "AND D3_TM = '499' " + CRLF
        cQuery += "ORDER BY D3_DOC, D3_COD, D3_LOCAL" + CRLF

    ElseIf MV_PAR01 == "5" //MOVIMENTO INTERNO SAIDA

        cTitulo := "MOVIMENTO INTERNO SAÍDA" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM "+Retsqlname("SD3")+" SD3" + CRLF
        cQuery += "WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"'" + CRLF
        cQuery += "AND D3_XINICAM = ''" + CRLF
        //cQuery += "AND D3_LOCALIZ = 'ICAM'" + CRLF
        cQuery += "AND D3_TM > '499' AND D3_TM < '999'" + CRLF
        cQuery += "AND D3_ESTORNO = ' '" + CRLF
        cQuery += "ORDER BY D3_DOC, D3_COD, D3_LOCAL" + CRLF

    ElseIf MV_PAR01 == "6" // TRANSFERENCIA SAIDA

        cTitulo := "TRANSFERÊNCIA SAÍDA" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM "+Retsqlname("SD3")+" SD3" + CRLF
        cQuery += "WHERE SD3.D_E_L_E_T_ = ' ' AND D3_FILIAL = '"+xFilial("SD3")+"'" + CRLF
        cQuery += "AND D3_XINICAM = ''" + CRLF
        cQuery += "AND D3_ESTORNO = ' '" + CRLF
        //cQuery += "AND D3_LOCALIZ = 'ICAM'" + CRLF
        cQuery += "AND D3_TM = '999' " + CRLF
        cQuery += "ORDER BY D3_DOC, D3_COD, D3_LOCAL" + CRLF

    ElseIf MV_PAR01 == "7" // CADASTRO DE PRODUTOS

        cTitulo := "CADASTRO DE PRODUTOS" 

        cQuery := "SELECT *" + CRLF
        cQuery += "FROM "+Retsqlname("SB1")+" SB1" + CRLF
        cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"'" + CRLF
        //cQuery += "AND B1_XINICAM <> 'S'" + CRLF
        //cQuery += "AND B1_XICAM = 'S'" + CRLF
        cQuery += "AND B1_COD >= '"+ MV_PAR02 +"' AND B1_COD <= '"+ MV_PAR03 +"'" + CRLF
        cQuery += "AND B1_TIPO >= '"+ MV_PAR04 +"' AND B1_TIPO <= '"+ MV_PAR05 +"'" + CRLF
        cQuery += "AND B1_GRUPO >= '"+ MV_PAR06 +"' AND B1_GRUPO <= '"+ MV_PAR07 +"'" + CRLF
        cQuery += "ORDER BY B1_COD" + CRLF

    EndIf

    cAliasQry := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .T., .T.)
    

    If MV_PAR01 == "1" // SOLICITAÇÃO AO ARMAZÉM
    
        While (cAliasQry)->(!EOF())
            Aadd(_aItens, {.T., ;
                            (cAliasQry)->CP_NUM, ; 
                            (cAliasQry)->CP_ITEM, ; 
                            (cAliasQry)->CP_PRODUTO, ;
                            (cAliasQry)->CP_DESCRI, ;  
                            (cAliasQry)->CP_UM, ; 
                            (cAliasQry)->CP_QUANT, ; 
                            (cAliasQry)->CP_QUJE, ;
                            (cAliasQry)->CP_EMISSAO, ; 
                            (cAliasQry)->CP_DATPRF, ; 
                            (cAliasQry)->CP_LOCAL, ; 
                            (cAliasQry)->CP_OBS, ; 
                            (cAliasQry)->CP_SOLICIT, ; 
                            (cAliasQry)->R_E_C_N_O_, ; 
                        })
            (cAliasQry)->(dbSkip())

        EndDo

    ElseIf MV_PAR01 == "2" // ENDEREÇAMENTO

        While (cAliasQry)->(!EOF())
            Aadd(_aItens, {.T., ;
                            (cAliasQry)->DB_ITEM, ; 
                            (cAliasQry)->DB_PRODUTO, ; 
                            (cAliasQry)->DB_LOCAL, ;
                            (cAliasQry)->DB_LOCALIZ, ;  
                            (cAliasQry)->DB_QUANT, ; 
                            (cAliasQry)->DB_DATA, ; 
                            (cAliasQry)->DB_DOC, ; 
                            (cAliasQry)->DB_SERIE, ; 
                            (cAliasQry)->DB_CLIFOR, ;
                            (cAliasQry)->DB_LOJA, ; 
                            (cAliasQry)->DB_TIPONF, ; 
                            (cAliasQry)->DB_TM, ; 
                            (cAliasQry)->DB_ORIGEM, ;                             
                            (cAliasQry)->R_E_C_N_O_, ;
                    })
            (cAliasQry)->(dbSkip())

        EndDo              

    ElseIf MV_PAR01 >= "3" .AND. MV_PAR01 <= "6" // MOVIMENTO INTERNO

        While (cAliasQry)->(!EOF())
            Aadd(_aItens, {.T., ;
                            (cAliasQry)->D3_DOC, ;
                            (cAliasQry)->D3_COD, ; 
                            (cAliasQry)->D3_LOCAL, ; 
                            (cAliasQry)->D3_QUANT, ; 
                            (cAliasQry)->D3_UM, ;     
                            (cAliasQry)->R_E_C_N_O_, ;                                                       
                    })
            (cAliasQry)->(dbSkip())

        EndDo                

    ElseIf MV_PAR01 == "7" // CADASTRO DE PRODUTOS

        While (cAliasQry)->(!EOF())
            Aadd(_aItens, {.T., ;
                            (cAliasQry)->B1_COD, ;
                            (cAliasQry)->B1_DESC, ;  
                            (cAliasQry)->B1_TIPO, ;     
                            (cAliasQry)->B1_UM, ;     
                            (cAliasQry)->B1_GRUPO, ;     
                            (cAliasQry)->R_E_C_N_O_, ;                                                       
                    })
            (cAliasQry)->(dbSkip())

        EndDo                
    EndIf

    (cAliasQry)->(dbCloseArea())

    DEFINE MSDIALOG _oDlgInteg TITLE "INTEGRAÇÃO COM ICAM - " + cTitulo FROM aTamanho[1], aTamanho[2] TO aTamanho[3], aTamanho[4] PIXEL

        _oProdutos := TCBrowse():New(0,0,aTamanho[4]*0.5,aTamanho[3]*0.44,,{},{},_oDlgInteg,,,,,{||DBLCLICK(_oProdutos:ColPos(),_oProdutos:nAt)},,,,,,,.F.,,.T.,,.F.,/*{||U_VALIDAR(_oProdutos:ColPos(),_oProdutos:nAt, nValorTot)}*/)
        //_oProdutos := TCBrowse():New(0,0,10,aTamanho[3]*0.44,,{},{},_oDlgInteg,,,,,{||U_DBLCLICK(_oProdutos:ColPos(),_oProdutos:nAt)},,,,,,,.F.,,.T.,,.F.,/*{||U_VALIDAR(_oProdutos:ColPos(),_oProdutos:nAt, nValorTot)}*/)
        _oProdutos:SetArray(_aItens)
        _oProdutos:bHeaderClick := {|o, nCol| CABCLICK(nCol) }

        IF MV_PAR01 == "1"
        
            _oProdutos:AddColumn(TCColumn():New("Sel."	       			,{|| If(Len(_aItens) <> 0 .and. _aItens[_oProdutos:nAt,1], oCheck , oNoCheck )},,,,"CENTER",0,.T.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_NUM") 		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,02],"")},PesqPict("SCP", "CP_NUM"),,,"LEFT",0,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_ITEM")		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,03],"")},PesqPict("SCP", "CP_ITEM"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_PRODUTO")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,04],"")},PesqPict("SCP", "CP_PRODUTO"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_DESCRI")   ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,05],"")},PesqPict("SCP", "CP_DESCRI"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_UM")		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,06],"")},PesqPict("SCP", "CP_UM"),,,"LEFT",,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_QUANT") 	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,07],"")},PesqPict("SCP", "CP_QUANT"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_QUJE")		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,08],"")},PesqPict("SCP", "CP_QUJE"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_EMISSAO")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,09],"")},PesqPict("SCP", "CP_EMISSAO"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_DATPRF")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,10],"")},PesqPict("SCP", "CP_DATPRF"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_LOCAL")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,11],"")},PesqPict("SCP", "CP_LOCAL"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_OBS")	    ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,12],"")},PesqPict("SCP", "CP_OBS"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("CP_SOLICIT")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,13],"")},PesqPict("SCP", "CP_SOLICIT"),,,"LEFT",0,.F.,.T.,,,,.F.,) )
        
        ElseIF MV_PAR01 == "2" 
        
            _oProdutos:AddColumn(TCColumn():New("Sel."	       			,{|| If(Len(_aItens) <> 0 .and. _aItens[_oProdutos:nAt,1], oCheck , oNoCheck )},,,,"CENTER",0,.T.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_ITEM")     ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,02],"")},PesqPict("SDB", "DB_ITEM"),,,"LEFT",0,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_PRODUTO")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,03],"")},PesqPict("SDB", "DB_PRODUTO"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_LOCAL")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,04],"")},PesqPict("SDB", "DB_LOCAL"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_LOCALIZ")  ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,05],"")},PesqPict("SDB", "DB_LOCALIZ"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_QUANT")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,06],"")},PesqPict("SDB", "DB_QUANT"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_DATA") 	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,07],"")},PesqPict("SDB", "DB_DATA"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_DOC")		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,08],"")},PesqPict("SDB", "DB_DOC"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_SERIE")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,09],"")},PesqPict("SDB", "DB_SERIE"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_CLIFOR")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,10],"")},PesqPict("SDB", "DB_CLIFOR"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_LOJA")	    ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,11],"")},PesqPict("SDB", "DB_LOJA"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_TIPONF")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,12],"")},PesqPict("SDB", "DB_TIPONF"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_TM")	    ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,13],"")},PesqPict("SDB", "DB_TM"),,,"LEFT",0,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("DB_ORIGEM")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,14],"")},PesqPict("SDB", "DB_ORIGEM"),,,"LEFT",0,.F.,.T.,,,,.F.,) )
        
        ElseIF MV_PAR01 >= "3" .AND. MV_PAR01 <= "6" 
        
            _oProdutos:AddColumn(TCColumn():New("Sel."	       			,{|| If(Len(_aItens) <> 0 .and. _aItens[_oProdutos:nAt,1], oCheck , oNoCheck )},,,,"CENTER",0,.T.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("D3_DOC") 		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,02],"")},PesqPict("SD3", "D3_DOC"),,,"LEFT",45,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("D3_COD") 		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,03],"")},PesqPict("SD3", "D3_COD"),,,"LEFT",50,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("D3_LOCAL")    ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,04],"")},PesqPict("SD3", "D3_LOCAL"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("D3_QUANT")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,05],"")},PesqPict("SD3", "D3_QUANT"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("D3_UM")	    ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,06],"")},PesqPict("SD3", "D3_UM"),,,"LEFT",0,.F.,.T.,,,,.F.,))

        ElseIF MV_PAR01 == "7"
        
            _oProdutos:AddColumn(TCColumn():New("Sel."	       			,{|| If(Len(_aItens) <> 0 .and. _aItens[_oProdutos:nAt,1], oCheck , oNoCheck )},,,,"CENTER",0,.T.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("B1_COD") 		,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,02],"")},PesqPict("SB1", "B1_COD"),,,"LEFT",45,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("B1_DESC") 	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,03],"")},PesqPict("SB1", "B1_DESC"),,,"LEFT",50,.F.,.T.,,,,.F.,) )
            _oProdutos:AddColumn(TCColumn():New(RetTitle("B1_TIPO")     ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,04],"")},PesqPict("SB1", "B1_TIPO"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("B1_UM")	    ,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,05],"")},PesqPict("SB1", "B1_UM"),,,"LEFT",0,.F.,.T.,,,,.F.,))
            _oProdutos:AddColumn(TCColumn():New(RetTitle("B1_GRUPO")	,{|| If(Len(_aItens) <> 0, _aItens[_oProdutos:nAt,06],"")},PesqPict("SB1", "B1_GRUPO"),,,"LEFT",0,.F.,.T.,,,,.F.,))
 
        EndIf
        
        If MV_PAR01 >= "1" .AND. MV_PAR01 <= "6"
            tButton():New(aTamanho[3] * 0.448 + 3, aTamanho[3] * 0.75 + 207, "ENVIAR INTEGRAÇÃO", , {|| FWMsgRun(, {|| U_IMPORTL()}, "Integrando com ICAM, Aguarde..."), _oDlgInteg:End()} , 70, 20,,,,.T.)
        ElseIF MV_PAR01 == "7"
            tButton():New(aTamanho[3] * 0.448 + 3, aTamanho[3] * 0.75 + 207, "ENVIAR INTEGRAÇÃO", , {|| FWMsgRun(, {|| U_IMPORTIT()}, "Integrando com ICAM, Aguarde..."), _oDlgInteg:End()} , 70, 20,,,,.T.)
            //oCmbObj3  := TComboBox():New(aTamanho[3] * 0.448 + 3, aTamanho[3] * 0.75 + 100, {||}, aCmbObj3, 30, 15, _oDlgInteg, , /*bChange*/, /*bValid*/, /*nClrText*/, /*nClrBack*/, , oFontPadrao)
        EndIf
        //oSayObj1 := tSay():New(0.52, 45, {|| cSayObj1}, _oDlgInteg, , , , , , , , , 15, 15, , , , , ,)
        
        //_oDlgInteg:bInit := {|| _oProdutos:GoColumn(3)}
    
    ACTIVATE MSDIALOG _oDlgInteg CENTERED

RETURN

STATIC FUNCTION DBLCLICK(nColuna, nLinha)

    If nColuna == 1
        _aItens[_oProdutos:nAt, 1] := !_aItens[_oProdutos:nAt,1]
    EndIf
    
    /*
    If nColuna == 5 .or. nColuna == 6 .or. nColuna == 11 .or. nColuna == 12 .or. nColuna == 13 .or. nColuna == 14 .or. nColuna == 15
        lEditCell(_aItens, _oProdutos, PesqPict("SB1", "B1_PCOFINS"), nColuna)
    ElseIf nColuna == 10 .or. nColuna == 21
        lEditCell(_aItens, _oProdutos, PesqPict("DA1", "DA1_PRCVEN"), nColuna)
    ElseIf nColuna == 4 .or. nColuna == 7 .or. nColuna == 8 .or. nColuna == 9
        lEditCell(_aItens, _oProdutos, PesqPict("Z01", "Z01_CUSTD"), nColuna)
    ElseIf nColuna == 3 .and. _aItens[_oProdutos:nAt,03] == 0
        lEditCell(_aItens, _oProdutos, PesqPict("SB1", "B1_CUSTD"), nColuna)
    EndIf

    If nColuna == 21

        U_VALIDAR(nColuna, nLinha)

    EndIf
    */

RETURN

Static Function CABCLICK(nCol)

    Local nCount := 0

    Private _lCabClick := .T.

    If nCol == 1

        For nCount := 1 to Len(_aItens)

            _aItens[nCount][1] := ! _aItens[nCount][1]

        Next

        _oProdutos:Refresh()

    EndIf    

Return



User Function IMPORTL()
    
    Local cPostUrl      := SuperGetMV("ES_INTEICAM", .F., "http://192.168.10.231/servizi_xchange.asmx?WSDL") 
    Local nTimeOut      := 120
    Local aHeadOut      := {}
    Local cHeaderRet  := ""
    Local sPostRet      := ""
    Local cPostData  :=""
    Local nItens := 0
    Local nLists := 0
    Local cMens      := ''
    Local aXML := {}
    Local nGrid := 0
    Local lIncrem := .F.
    Local cLD := ""
    Local nPosDoc := 0
    Local nPosCod := 0
    Local nPosQuant := 0
    Local cIdUnico := ""

    For nGrid := 1 to Len(_aItens)
        If _aItens[nGrid][1] // SE O CHECKBOX ESTÁ MARCADO
            Aadd(aXML, Aclone(_aItens[nGrid]))
        EndIf
    Next

    If MV_PAR01 == "1"
        cLD := "DOWNLOAD"
        nPosDoc := 2
        nPosCod := 4 
        nPosQuant := 7
    ElseIf MV_PAR01 == "2"
        cLD := "LOAD"
        nPosDoc := 1
        nPosCod := 3 
        nPosQuant := 6
    ElseIf MV_PAR01 == "3"
        cLD := "LOAD"
        nPosDoc := 2
        nPosCod := 3 
        nPosQuant := 5
    ElseIf MV_PAR01 == "4"
        cLD := "LOAD"
        nPosDoc := 2
        nPosCod := 3 
        nPosQuant := 5
    ElseIf MV_PAR01 == "5"
        cLD := "DOWNLOAD"
        nPosDoc := 2
        nPosCod := 3 
        nPosQuant := 5
    ElseIf MV_PAR01 == "6"
        cLD := "DOWNLOAD"
        nPosDoc := 2
        nPosCod := 3 
        nPosQuant := 5
    EndIf

    Aadd(aHeadOut,'Content-Type: text/xml;charset=UTF-8')
    
    cPostData:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://servizi_xchange.org/">'
    cPostData+='    <soapenv:Header/>'
    cPostData+='    <soapenv:Body>'
    cPostData+='        <ser:ImportLists>'
    cPostData+='            <!--Optional:-->'
    cPostData+='            <ser:InputLists>'
    cPostData+='                <!--Zero or more repetitions:-->'
    
    cIdUnico := GeraIdUnico() // Gera o código único

        cPostData+='                <ser:ListToImport>'
        cPostData+='                <!--Optional:-->'
        cPostData+='                <ser:ListHead>'
        cPostData+='                    <!--Optional:-->'
        
        // AQUI VAI O ID ÚNICO CONTOLADO PELO PARAMETRO ES_IDUICAM COM CONTEÚDO INICIAL "000000000" E GRAVA NA TABELA DA RESPECTIVA QUERY O ID QUE FOI USADO EM CAMPO QUE SERÁ CRIADO PARA ESTE FIM.
        cPostData+=' <ser:external_list_code>' + cIdUnico + '</ser:external_list_code>'
            

        cPostData+='                    <!--Optional:-->'
        cPostData+='                    <ser:operation_type>VISUALIZATION</ser:operation_type>' 
        cPostData+='                    <!--Optional:-->'
        cPostData+='                    <ser:operation>'+ cLD +'</ser:operation>' // Entrada
        cPostData+='                    <ser:user_id>ADMINISTRATOR</ser:user_id>'
        cPostData+='                    <!--Optional:-->'
        cPostData+='                </ser:ListHead>'
        cPostData+='                <!--Zero or more repetitions:-->'
        
        For nItens := 1 to Len(aXML)

        
                cPostData+='                <ser:ListDetail>'
                cPostData+='                    <!--Optional:-->'
                cPostData+='                    <ser:item_id>' + aXML[nItens][nPosCod] + '</ser:item_id>' // D3_COD
                cPostData+='                    <ser:quantity>' + CValToChar(aXML[nItens][nPosQuant]) + '</ser:quantity>' // D3_QUANT
                cPostData+='                </ser:ListDetail>'

                If nItens < Len(aXML)
                    nItens ++
                    lIncrem := .T.
                Else
                    lIncrem := .F.
                EndIf

            
        
        Next

        cPostData+='                </ser:ListToImport>'
        

    cPostData+='            </ser:InputLists>'
    cPostData+='            <ser:Output_Type>0</ser:Output_Type>' // XML
    cPostData+='        </ser:ImportLists>'
    cPostData+='    </soapenv:Body>'
    cPostData+='</soapenv:Envelope>'

    _cPostData := EncodeUTF8(cPostData)

    sPostRet := HttpPost(cPostUrl,cMens,_cPostData,nTimeOut,aHeadOut,@cHeaderRet)
    
    if AT("200 OK",cHeaderRet) > 0
        //ShowLog(sPostRet)
        //varinfo("Header", sPostRet)
        conout("Integração Realizada com Sucesso" + CValToChar(sPostRet) + dToC(date()) + time())
        Aviso("ICAM", "Integração Realizada com Sucesso: "+ CRLF + cHeaderRet, {"OK"}, 3, "Itegração", , "BR_AZUL")
        //FWAlertSuccess(AllTrim(sPostRet), "Integração Realizada com Sucesso")
    
        If MV_PAR01 == "1"

            For nLists := 1 to len(aXML)
                SCP->(dbGoTo(aXML[nLists][Len(aXML[nLists]) - 1]))
                RecLock("SCP", .F.)
                    SCP->CP_XINICAM := "S"
                    SCP->CP_XIDUINT  := cIdUnico
                SCP->(MsUnlock())
            Next

        ElseIf MV_PAR01 == "2"

            For nLists := 1 to len(aXML)
                SDB->(dbGoTo(aXML[nLists][Len(aXML[nLists]) - 1]))
                RecLock("SDB", .F.)
                    SDB->DB_XINICAM := "S"
                    SDB->DB_XIDUINT  := cIdUnico
                    
                SDB->(MsUnlock())
            Next
        
        ElseIF MV_PAR01 >= "3" .AND. MV_PAR01 <= "6"

            For nLists := 1 to len(aXML)

                SD3->(dbGoTo(aXML[nLists][Len(aXML[nLists]) - 1]))

                RecLock("SD3", .F.)
                    SD3->D3_XINICAM := "S"
                    SD3->D3_XIDUINT  := cIdUnico
                SD3->(MsUnlock())
            Next

        EndIf
            
    
    else
        conout("HttpPost Failed.")
        varinfo("Header", cHeaderRet)
        Aviso("ICAM", "Problemas na integração: " + CRLF + cHeaderRet, {"OK"}, 3, "Itegração", , "BR_VERMELHO")
        conout("Problemas na integração: " + CRLF + cHeaderRet + dToC(date()) + time())

        
    Endif

Return

User Function IMPORTIT()
    
    Local cPostUrl      := SuperGetMV("ES_INTEICAM", .F., "http://192.168.10.231/servizi_xchange.asmx?WSDL") 
    Local nTimeOut      := 120
    Local aHeadOut      := {}
    Local cHeaderRet  := ""
    Local sPostRet      := ""
    Local cPostData  :=""
    Local nLists := 0
    Local cMens      := ''
    Local aXML := {}
    Local nGrid := 0

    For nGrid := 1 to Len(_aItens)
        If _aItens[nGrid][1] // SE O CHECKBOX ESTÁ MARCADO
            Aadd(aXML, Aclone(_aItens[nGrid]))
        EndIf
    Next

    Aadd(aHeadOut,'Content-Type: text/xml;charset=UTF-8')
    
    cPostData:='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://servizi_xchange.org/">'
    cPostData+='    <soapenv:Header/>'
    cPostData+='    <soapenv:Body>'
    cPostData+='        <ser:ImportItems>'
    cPostData+='            <!--Optional:-->'
    cPostData+='            <ser:Items>'
    cPostData+='                <!--Zero or more repetitions:-->'
    
    For nLists := 1 to Len(aXML)

        cPostData+='                <ser:ItemToImport>'
        cPostData+='                    <!--Optional:-->'
        cPostData+='                    <ser:item_id>'+ AllTrim(aXML[nLists][2]) +'</ser:item_id>'
        cPostData+='                    <!--Optional:-->'
        cPostData+='                    <ser:description>'+ AllTrim(aXML[nLists][3]) +'</ser:description>'
        cPostData+='                    <!--Optional:-->'
        cPostData+='                    <ser:pickpolicy>FIFO</ser:pickpolicy>' 
        cPostData+='                </ser:ItemToImport>'
    
    Next
    cPostData+='            </ser:Items>'
    cPostData+='            <ser:Output_Type>0</ser:Output_Type>'
    cPostData+='        </ser:ImportItems>'
    cPostData+='    </soapenv:Body>'
    cPostData+='</soapenv:Envelope>'

    _cPostData := EncodeUTF8(cPostData)

    sPostRet := HttpPost(cPostUrl,cMens,_cPostData,nTimeOut,aHeadOut,@cHeaderRet)
    
    if AT("200 OK",cHeaderRet) > 0
        //ShowLog(sPostRet)
        //varinfo("Header", sPostRet)
        conout("Integração Realizada com Sucesso" + CValToChar(sPostRet) + dToC(date()) + time())
        Aviso("ICAM", "Integração Realizada com Sucesso: " + CRLF + cHeaderRet, {"OK"}, 3, "Itegração", , "BR_AZUL")
        //FWAlertSuccess(AllTrim(sPostRet), "Integração Realizada com Sucesso")

        For nLists := 1 to len(aXML)
            SB1->(dbGoTo(aXML[nLists][Len(aXML[nLists]) - 1]))
            RecLock("SB1", .F.)
                SB1->B1_XINICAM := "S"
            SB1->(MsUnlock())
        Next
    
    else
        conout("HttpPost Failed.")
        varinfo("Header", cHeaderRet)
        Aviso("ICAM", "Problemas na integração: " + CRLF + cHeaderRet, {"OK"}, 3, "Itegração", , "BR_VERMELHO")
        conout("Problemas na integração: " + CRLF + cHeaderRet + dToC(date()) + time())

    Endif

Return



