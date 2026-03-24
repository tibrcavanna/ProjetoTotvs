//Bibliotecas
#Include "TOTVS.ch"
 

/*/{Protheus.doc} FSPCPM05
Função principal 
@type function
@version  
@author Anderson Quintiliano
@since 17/12/2025
@param c_operador, c_projeto, d_dataDe, d_dataAte
/*/ 
User Function FSPCPM05(c_operador)
    Local a_Area := FWGetArea()
    Private c_oper := c_operador

        fFSPCPM05()
 
    FWRestArea(a_Area)
Return

/*/{Protheus.doc} fFSPCPM05
Função principal da tela de visualização de apontamentos
@type function
@version  
@author Anderson Quintiliano
@since 17/12/2025

/*/

Static Function fFSPCPM05()
    Local n_LargBtn      := 50
//    Local nLinhaObj     := 0
//    Local nLargPanel    := 0
    //Objetos e componentes gerais

    Private oFwLayer
    Private oPanTitulo
    Private oPanGrid
    Private oPanCheck
    Private oPanTotal

    //Cabeçalho
    Private oSayModulo, c_SayModulo := ''
    Private oSayTitulo, c_SayTitulo := "Tela Visualização de Apontamentos"
    Private oSaySubTit, c_SaySubTit := ''

    //Tamanho da janela
    Private a_Size := MsAdvSize(.F.)
/*
    Private n_JanLarg := a_Size[5]
    Private nJanAltu := a_Size[6]
*/

    Private n_JanLarg := 900
    Private nJanAltu := 600

    //Fontes
    Private c_FontUti    := "Tahoma"
    Private oFontMod    := TFont():New(c_FontUti, , -38)
    Private oFontSub    := TFont():New(c_FontUti, , -20)
    Private oFontSubN   := TFont():New(c_FontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(c_FontUti, , -14)
    Private oFontSay    := TFont():New(c_FontUti, , -12)

    //Grid
    Private a_Campos := {}
    Private c_AliasTmp := "TMPPCP"
    Private a_Colunas := {}
    Private oMarkBrowse
    Private c_projeto:=  space(10)
    Private d_dataDe:=  FIRSTDATE(DATE()) // stod('')
    Private d_dataAte:=  LASTDATE(DATE())// stod('')
    Private c_NomeReal

    //Adiciona as colunas que serão criadas na temporária

    aAdd(a_Campos, {"Z01_FILIAL	","C", 2 ,0	})
    aAdd(a_Campos, {"Z01_OPER	","C", 6 ,0	})
    aAdd(a_Campos, {"Z01_PROJ	","C", 10, 0})
    aAdd(a_Campos, {"Z01_COPER	","C", 2 ,0	})
    aAdd(a_Campos, {"Z01_DESCR	","C", 20, 0})
    aAdd(a_Campos, {"Z01_DTINI	","D", 8 ,0	})
    aAdd(a_Campos, {"Z01_TOTAL	","N", 6 ,2	})

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(c_AliasTmp)
    oTempTable:SetFields( a_Campos )
    oTempTable:Create()  
    c_NomeReal:= oTempTable:GetRealName()
    
    //Busca as colunas do browse
    a_Colunas := fCriaCols()

    //Cria a janela
    DEFINE MSDIALOG oDlgVisual TITLE "Visualizador de Apontamentos"  FROM 0, 0 TO nJanAltu, n_JanLarg PIXEL
  
    //Criando a camada
    oFwLayer := FwLayer():New()
    oFwLayer:init(oDlgVisual,.F.)

    //Adicionando 3 linhas, a de título, a do corpo e a inferior
    oFWLayer:addLine("TITULO", 020, .F.)
    oFWLayer:addLine("CORPO",  078, .F.)
    oFWLayer:addLine("RODAPE", 002, .F.)

    //Adicionando as colunas das linhas
    oFWLayer:addCollumn("HEADERTEXT",   050, .T., "TITULO")
    oFWLayer:addCollumn("BLANKBTN",     010, .T., "TITULO")
    oFWLayer:addCollumn("BTNSAIR",      040, .T., "TITULO")

    oFWLayer:addCollumn("BLANKANTES",   001, .T., "CORPO")
    oFWLayer:addCollumn("COLGRID",      099, .T., "CORPO")

    //Criando os paineis
    oPanHeader := oFWLayer:GetColPanel("HEADERTEXT", "TITULO")
    oPanSair   := oFWLayer:GetColPanel("BTNSAIR",    "TITULO")
    oPanGrid   := oFWLayer:GetColPanel("COLGRID",    "CORPO")

    //Títulos e SubTítulos
    oSayModulo := TSay():New(004, 003, {|| c_SayModulo}, oPanHeader, "", oFontMod,  , , , .T., RGB(149, 179, 215), , 200, 30, , , , , , .F., , )
    oSayTitulo := TSay():New(004, 045, {|| c_SayTitulo}, oPanHeader, "", oFontSub,  , , , .T., RGB(031, 073, 125), , 200, 30, , , , , , .F., , )
    oSaySubTit := TSay():New(014, 045, {|| c_SaySubTit}, oPanHeader, "", oFontSubN, , , , .T., RGB(031, 073, 125), , 300, 30, , , , , , .F., , )

    @ 015, 005 SAY oSay1 PROMPT "Operador: " + c_oper SIZE 050, 007 OF oPanHeader COLORS 0, 16777215 PIXEL

    @ 020, 065 SAY oSay1 PROMPT "Projeto" SIZE 049, 007 OF oPanHeader COLORS 0, 16777215 PIXEL
    @ 020, 100 MSGET oGet1 VAR c_projeto SIZE 045, 007 OF oPanHeader COLORS 0, 16777215 PIXEL // ON CHANGE fFormaGrid()
    
    @ 035, 065 SAY oSay2 PROMPT "Período: " SIZE 049, 007 OF oPanHeader COLORS 0, 16777215 PIXEL

    //Popula a tabela temporária
    @ 035, 100 MSGET oGet2 VAR d_dataDe SIZE 060, 010 OF oPanHeader COLORS 0, 16777215 PIXEL //ON CHANGE Processa({||fFormaGrid() }, "Processando...")  
    @ 035, 160 MSGET oGet2 VAR d_dataAte SIZE 060, 010 OF oPanHeader COLORS 0, 16777215 PIXEL ON CHANGE Processa({||fFormaGrid() }, "Processando...") 

    // CRIANDO O BROWSE
    oMarkBrowse := FWMarkBrowse():New()
    oMarkBrowse:SetAlias(c_AliasTmp)
    oMarkBrowse:DisableFilter()
    oMarkBrowse:DisableConfig()
    oMarkBrowse:DisableReport()
    oMarkBrowse:DisableSeek()
    oMarkBrowse:DisableSaveConfig()
    oMarkBrowse:SetFontBrowse(oFontSay)
    //oMarkBrowse:SetFieldMark('OK')
    oMarkBrowse:SetTemporary(.T.)
    oMarkBrowse:SetColumns(a_Colunas)

    oMarkBrowse:SetOwner(oPanGrid)
    oMarkBrowse:refresh(.T.)
    oMarkBrowse:Activate()

    //Criando os botões
    oBtnSair := TButton():New(006, 070, "Fechar", oPanSair, {|| oDlgVisual:End()}      , n_LargBtn, 018, , oFontBtn, , .T., , , , , , )

        Activate MsDialog oDlgVisual Centered

    oTempTable:Delete()
    oMarkBrowse:DeActivate()

Return

/*/{Protheus.doc} fFormaGrid
Função responsável por criar o grid
@type function
@version  
@author Anderson Quintiliano
@since 17/12/2025
@return variant, return_description
/*/
Static Function fFormaGrid()
    //Atualiza o grid
    fPopula(c_oper, c_projeto, d_dataDe, d_dataAte)

    oMarkBrowse:refresh(.T.)
Return 


/*/{Protheus.doc} fCriaCols
Função responsável por popular a tabela temporária
@type function
@version  
@author Anderson Quintiliano
@since 17/12/2025
/*/
Static Function fCriaCols()
    Local n_Atual   := 0 
    Local a_Colunas := {}
    Local a_Estrut  := {}
    Local oColumn
      
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara

    aAdd(a_Estrut, {"Z01_FILIAL	", "Filial		","C", 2 ,0	, GetSX3Cache("Z01_FILIAL	","X3_PICTURE")})
    aAdd(a_Estrut, {"Z01_OPER	", "Operador	","C", 6 ,0	, GetSX3Cache("Z01_OPER		","X3_PICTURE")})
    aAdd(a_Estrut, {"Z01_PROJ	", "Projeto		","C", 10, 0, GetSX3Cache("Z01_PROJ		","X3_PICTURE")})
    aAdd(a_Estrut, {"Z01_COPER	", "Cód Operação","C", 2 ,0	, GetSX3Cache("Z01_COPER	","X3_PICTURE")})
    aAdd(a_Estrut, {"Z01_DESCR	", "Desc Operaç	","C", 20, 0, GetSX3Cache("Z01_DESCR	","X3_PICTURE")})
    aAdd(a_Estrut, {"Z01_DTINI	", "Data Inicio	","D", 8 ,0	, GetSX3Cache("Z01_DTINI	","X3_PICTURE")})
    aAdd(a_Estrut, {"Z01_TOTAL	", "Total Horas	","N", 6 ,2	, GetSX3Cache("Z01_TOTAL	","X3_PICTURE")})

    //Percorrendo todos os campos da estrutura
    For n_Atual := 1 To Len(a_Estrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| (c_AliasTmp)->" + a_Estrut[n_Atual][1] +"}"))
        oColumn:SetTitle(a_Estrut[n_Atual][2])
        oColumn:SetType(a_Estrut[n_Atual][3])
        oColumn:SetSize(a_Estrut[n_Atual][4])
        oColumn:SetDecimal(a_Estrut[n_Atual][5])
        oColumn:SetPicture(a_Estrut[n_Atual][6])
  
        //Adiciona a coluna
        aAdd(a_Colunas, oColumn)
    Next
Return a_Colunas
  
Static Function fPopula(c_operador, c_projeto, d_dtaDe, d_dtaAte)
    Local oQryC
    Local c_Alias
//    Local n_Atual := 0

    Local c_Query:= ""
    
    Local c_QueryDel
    c_QueryDel:= "Delete From "+ c_NomeReal
    TcSqlExec(c_QueryDel)


    c_Query += " SELECT Z01_FILIAL,Z01_OPER,Z01_PROJ,Z01_COPER,Z01_DESCR,Z01_DTINI,SUM(Z01_TOTAL) Z01_TOTAL " 
    c_Query += " FROM ? "
    c_Query += " WHERE Z01_OPER = '?' AND Z01_PROJ= '?' AND  Z01_DTINI BETWEEN '?' AND  '?' AND D_E_L_E_T_=''"    
    c_Query += " GROUP BY Z01_FILIAL,Z01_OPER ,Z01_PROJ ,Z01_COPER ,Z01_DESCR,Z01_DTINI " 

    c_Query := ChangeQuery(c_Query)
    oQryC := FWPreparedStatement():New(c_Query)

    oQryC:SetUnsafe(1, RetSqlName("Z01"))
    oQryC:SetUnsafe(2, c_operador) 
    oQryC:SetUnsafe(3, c_projeto) 
    oQryC:SetUnsafe(4, dtos(d_dtaDe) )
    oQryC:SetUnsafe(5, dtos(d_dtaAte) )

    c_Query 	:= oQryC:GetFixQuery()
    c_Alias 	:= MPSysOpenQuery( c_Query )

    While !(c_Alias)->(Eof())
        //Grava na temporária
        RecLock(c_AliasTmp, .T.)
            (c_AliasTmp)->Z01_FILIAL	:= (c_Alias)->Z01_FILIAL	
            (c_AliasTmp)->Z01_OPER	:= (c_Alias)->Z01_OPER	
            (c_AliasTmp)->Z01_PROJ	:= (c_Alias)->Z01_PROJ	
            (c_AliasTmp)->Z01_COPER	:= (c_Alias)->Z01_COPER	
            (c_AliasTmp)->Z01_DESCR	:= (c_Alias)->Z01_DESCR	
            (c_AliasTmp)->Z01_DTINI	:= stod((c_Alias)->Z01_DTINI	)
            (c_AliasTmp)->Z01_TOTAL	:= (c_Alias)->Z01_TOTAL	
        (c_AliasTmp)->(MsUnlock())
      
        (c_Alias)->(DBSkip())
    EndDo
    (c_AliasTmp)->(DbGoTop())
    (c_AliasTmp)->(DbGoBottom())
    (c_AliasTmp)->(DbGoTop())


Return
 
