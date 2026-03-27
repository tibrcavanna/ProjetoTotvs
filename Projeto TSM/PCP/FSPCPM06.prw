#Include "Protheus.ch"
#Include "FwMvcDef.ch"
/*/{Protheus.doc}
(TELA DE PARA BLOQUEIO DE OP)
@type  function
@author Silvio Nogueira
@since 24/01/2025
@version 01
@description Rotina será utilizada para bloqueio da OP através do campo C2_MSBLQL
/*/
User Function FSPCPM06()

    Local o_QryC
    Local c_Alias
    Local n_Campo
    Local a_Struct      := {}
	Local b_Ok          := {|| nOpca := 1, BloqOP(o_MrkBrw:data()), o_DlgLS:End()}
	Local b_Desblo      := {|| nOpca := 1, DesbEncOP(o_MrkBrw:data()), o_DlgLS:End()}
	Local b_Cancel      := {|| o_MrkBrw:Deactivate(), o_DlgLS:End()}
	Local a_Columns     := {}
    Local a_Area        := GetArea()
    Local a_Tamanho     := {}
    Local a_Pergs       := {}
    Local n_PosTam
    Local a_CpsFilt     := {}
    Local c_Acao        := "1"
    Local c_OPDe        := Space( TamSX3( "D3_OP")[01] )
    Local c_OPAte       := Replicate("Z", TamSX3( "D3_OP")[01] )
    Local c_ProjDe      := Space( TamSX3( "C2_ITEMCTA")[01] )
    Local c_ProjAte     := Replicate("Z", TamSX3( "C2_ITEMCTA")[01] )
    Local c_Title       := ""

    Private c_Tmptela   := "TST_" + RetCodUsr()
    Private a_Campos    := {}
    Private lMsErroAuto
    Private lMostraMsg  := .T.
    Private n_Acao      := 1
    
    // Grupo de Perguntas XTSMSC para permitir filtro por fornecedor/produto/sc

	//aAdd(aParamBox,{2, "Imprime Contas?",nOpcRel		,{"1=Bloqueio","2=Desbloqueio/Encerra"}, 090, ".T.", .F.})
    aAdd( a_Pergs, {2, "Ação "   		, c_Acao   , {"1=Bloqueio","2=Desbloqueio","3-Encerra"}  , 090 , ""  , .F. } )
    aAdd( a_Pergs, {1, "OP De "   		, c_OPDe   , ""            , ""           , "SC2"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "OP Ate "  		, c_OPAte  , ""            , ""           , "SC2"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Projeto De "   	, c_ProjDe   , ""            , ""         , "CTD"  , "",   0, .F. } )
    aAdd( a_Pergs, {1, "Projeto Ate "  	, c_ProjAte  , ""            , ""         , "CTD"  , "",   0, .F. } )

    If ParamBox( a_Pergs, "Bloqueio / Desbloqueio /Encerramento de OP",,,,,,,,, .F. )

        n_Acao  	:=  Val(M->MV_PAR01)
        c_OPDe  	:=  M->MV_PAR02
        c_OPAte 	:=  M->MV_PAR03
        c_ProjDe  	:=  M->MV_PAR04
        c_ProjAte 	:=  M->MV_PAR05

    Else

        l_Ret   := .F.

    EndIf

    c_Title := If(n_Acao == 1, "Bloqueio de OPs",If(n_Acao == 2,"Desbloqueio de OPs","Encerramento de OPs"))


	If o_QryC == Nil

        c_Alias := GetNextAlias()
    	_cMarca := Space(2)

        c_Qry := ""

        c_Qry += "SELECT C2_ITEMCTA, C2_NUM, C2_ITEM, C2_SEQUEN , C2_PRODUTO, B1_DESC, C2_QUANT, '  ' AS C2_OK FROM ? SC2 "
        c_Qry += "	INNER JOIN ? SB1 ON SB1.B1_FILIAL = '?' AND SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' "
        If n_Acao == 1
            c_Qry += "	WHERE C2_FILIAL= '?' AND C2_DATRF = '' AND C2_MSBLQL <> '1' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_TPOP = 'F' AND "
        ElseIf n_Acao == 2
            c_Qry += "	WHERE C2_FILIAL= '?' AND C2_DATRF = '' AND C2_MSBLQL = '1' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_TPOP = 'F' AND "
        Else
            c_Qry += "	WHERE C2_FILIAL= '?' AND C2_DATRF = '' AND SC2.D_E_L_E_T_ = ' ' AND SC2.C2_TPOP = 'F' AND "
        Endif
        c_Qry += "		C2_NUM+C2_ITEM+C2_SEQUEN >= '?' AND C2_NUM+C2_ITEM+C2_SEQUEN <= '?' AND C2_ITEMCTA >= '?' AND C2_ITEMCTA <= '?' "
        c_Qry += "	ORDER BY C2_NUM+C2_ITEM+C2_SEQUEN, C2_PRODUTO "

		c_Qry := ChangeQuery(c_Qry)
		o_QryC := FWPreparedStatement():New(c_Qry)

	EndIf

	o_QryC:SetUnsafe(1, RetSqlName( "SC2" ))
	o_QryC:SetUnsafe(2, RetSqlName( "SB1" ))
	o_QryC:SetUnsafe(3, xFilial( "SB1" ))
	o_QryC:SetUnsafe(4, xFilial( "SC2" ))
    o_QryC:SetUnsafe(5, c_OPDe)
    o_QryC:SetUnsafe(6, c_OPAte)
    o_QryC:SetUnsafe(7, c_ProjDe)
    o_QryC:SetUnsafe(8, c_ProjAte)
 
	c_Qry 	:= o_QryC:GetFixQuery()

    c_Alias 	:= MPSysOpenQuery( c_Qry )

    //AAdd(a_Columns, FWBrwColumn():New())
    a_Struct	:= (c_Alias)->(dbStruct())

    // Cria array para definir tamanho das colunas
    Aadd(a_Tamanho,{'C2_NUM', 80})
    Aadd(a_Tamanho,{'C2_ITEM', 40})
    Aadd(a_Tamanho,{'C2_SEQUEN', 60})
    Aadd(a_Tamanho,{'C2_PRODUTO', 100})
    Aadd(a_Tamanho,{'B1_DESC', 300})
    Aadd(a_Tamanho,{'C2_QUANT', 80})
    Aadd(a_Tamanho,{'C2_ITEMCTA', 100})
    Aadd(a_Tamanho,{'C2_OK', 80})


		//MarkBrowse
	For n_Campo := 1 To Len( a_Struct )

		If	(AllTrim(a_Struct[n_Campo][1]) $ "C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,B1_DESC,C2_QUANT,C2_ITEMCTA,C2_OK") // Para campos caracter e numérico

            n_PosTam := ascan(a_Tamanho, {|x| alltrim(x[1]) == AllTrim(a_Struct[n_Campo][1] )})
			AAdd(a_Columns, FWBrwColumn():New())
			a_Columns[Len(a_Columns)]:SetData( &("{||" + a_Struct[n_Campo][1] + "}") )
			a_Columns[Len(a_Columns)]:SetTitle(RetTitle(a_Struct[n_Campo][1]))
			a_Columns[Len(a_Columns)]:SetSize(If(n_PosTam<>0,a_Tamanho[n_PosTam][2], a_Struct[n_Campo][3]*2))
			a_Columns[Len(a_Columns)]:lAutoSize := .F.
			a_Columns[Len(a_Columns)]:nAlign := If(a_Struct[n_Campo][2]='N',2,3)
			a_Columns[Len(a_Columns)]:SetDecimal(a_Struct[n_Campo][4])
            If Left(a_Tamanho[n_PosTam][1],3) $ "SC2"
			    a_Columns[Len(a_Columns)]:SetPicture(PesqPict("SC2", a_Struct[n_Campo][1]))
            ElseIf Left(a_Tamanho[n_PosTam][1],3) $ "SB1"
			    a_Columns[Len(a_Columns)]:SetPicture(PesqPict("SB1", a_Struct[n_Campo][1]))
            Endif

		EndIf
		If	(AllTrim(a_Struct[n_Campo][1]) $ "") // Para campos data

            a_Struct[n_Campo,2]   := "D"

        Endif
	Next n_Campo

	For n_Campo := 1 To Len( a_Struct )

        //Aadd(a_Campos, {Left(RetTitle(a_Struct[n_Campo][1]),10),;
        Aadd(a_Campos, {a_Struct[n_Campo][1],;
                       a_Struct[n_Campo][2],;
                       a_Struct[n_Campo][3],;
                       a_Struct[n_Campo][4];
                      })

        Aadd(a_CpsFilt,{a_Struct[n_Campo][1],;
                       RetTitle(a_Struct[n_Campo][1]),;
                       a_Struct[n_Campo][2],;
                       a_Struct[n_Campo][3],;
                       a_Struct[n_Campo][4],;
                       PesqPict("SC2", a_Struct[n_Campo][1]);
                      })

    Next n_Campo

    o_TempTable:= FWTemporaryTable():New(c_Tmptela)
    o_TempTable:SetFields( a_Campos )
    o_TempTable:AddIndex( "01", {'C2_ITEMCTA','C2_NUM','C2_ITEM','C2_SEQUEN'} )
    o_TempTable:Create()

    If !(c_Alias)->(Eof())

        While !(c_Alias)->(Eof())

            RecLock(c_Tmptela,.T.)
            (c_Tmptela)->C2_NUM      := (c_Alias)->C2_NUM 
            (c_Tmptela)->C2_ITEM     := (c_Alias)->C2_ITEM
            (c_Tmptela)->C2_SEQUEN   := (c_Alias)->C2_SEQUEN
            (c_Tmptela)->C2_PRODUTO  := (c_Alias)->C2_PRODUTO
            (c_Tmptela)->B1_DESC     := (c_Alias)->B1_DESC
            (c_Tmptela)->C2_QUANT    := (c_Alias)->C2_QUANT
            (c_Tmptela)->C2_ITEMCTA  := (c_Alias)->C2_ITEMCTA
            (c_Tmptela)->C2_OK       := (c_Alias)->C2_OK

            (c_Alias)->(dbSkip())

        End

    Endif

    (c_Alias)->(dbCloseArea())

    //DbSelectArea(c_Alias)
    //(c_Alias)->(dbGotop())

    _cMarca := GetMark(,c_Tmptela,"C2_OK")

	If !(c_Tmptela)->(Eof())

		DEFINE MSDIALOG o_DlgLS TITLE c_Title From 100, 0 to 600,1200 OF oMainWnd PIXEL 

		o_MrkBrw := FWMarkBrowse():New()
		o_MrkBrw:oBrowse:SetEditCell(.F.)
		o_MrkBrw:SetFieldMark("C2_OK")

        //o_MrkBrw:SetQuery(c_Qry)
        o_MrkBrw:SetFields()

        o_MrkBrw:SetFieldFilter(a_CpsFilt)

		o_MrkBrw:SetOwner(o_DlgLS)
		o_MrkBrw:SetAlias(c_Tmptela)

		//o_MrkBrw:SetSeek(.T., aPesq)
		o_MrkBrw:SetMenuDef("")
        If n_Acao == 1
            o_MrkBrw:AddButton("Bloquear", b_Ok, NIL, 2) //Bloqueio
        ElseIf n_Acao == 2
            o_MrkBrw:AddButton("Desbloqueio", b_Desblo, NIL, 2) //Desbloqueio
        Else
            o_MrkBrw:AddButton("Encerra", b_Desblo, NIL, 2) //Desbloqueio
        Endif
		o_MrkBrw:AddButton("Cancelar", b_Cancel, NIL, 2) //Cancelar
        o_MrkBrw:SetValid({|| VldMark()})
		o_MrkBrw:SetMark( _cMarca, c_Tmptela, "C2_OK" )
        //o_MrkBrw:SetAllMark({|| FWAlertWarning("Serão marcados todos os registros com base nos registros já marcados ou no primeiro da lista.","Informação") , lMostraMsg := .F., o_MrkBrw:AllMark(), lMostraMsg := .T. ,o_MrkBrw:Refresh(.T.)})
        o_MrkBrw:SetAllMark({|| lMostraMsg := .F., o_MrkBrw:AllMark(), lMostraMsg := .T. ,o_MrkBrw:Refresh(.T.)})
		o_MrkBrw:SetDescription("")
		o_MrkBrw:SetColumns(a_Columns)
		o_MrkBrw:SetTemporary(.T.)
        o_MrkBrw:SetIgnoreARotina(.T.)
        o_MrkBrw:SetLocate({|| .T.})
        o_MrkBrw:Refresh(.T.)
        o_MrkBrw:GoTop(.T.)
       
		//o_MrkBrw:AllMark()
		//o_MrkBrw:SetAllMark( { || o_MrkBrw:AllMark() } )
		o_MrkBrw:Activate()
        (c_Tmptela)->(dbGotop())
		ACTIVATE MSDIALOG o_DlgLS CENTERED
	Else 
		FWAlertError("Não existem registros para o filtro selecionado", "Error")
	EndIf

    (c_Tmptela)->(dbCloseArea())

    RestArea(a_Area)

Return

/*/{Protheus.doc}
@type  function
@author Silvio Nogueira
@since 24/01/2025
@version 01
@description Função para validar 
/*/
Static Function VldMark()

    Local l_Ret  := .T.

Return l_Ret

/*/{Protheus.doc}
@type  function
@author Silvio Nogueira
@since 01/10/2025
@version 01
@description Função para efetuar o execauto no PC (MATA120) com base nas SCs selecionadas
/*/
Static Function BloqOP(o_Dados)

    Local l_Ret     := .T.
    Local l_Bloq    := .F.

    (c_Tmptela)->(dbGotop())
    
    While !(c_Tmptela)->(Eof())

        If (c_Tmptela)->C2_OK == _cMarca

            SC2->(dbSetOrder(1))

            If SC2->(MsSeek(xFilial("SC2")+(c_Tmptela)->C2_NUM+(c_Tmptela)->C2_ITEM+(c_Tmptela)->C2_SEQUEN))

                RecLock("SC2",.F.)
                SC2->C2_MSBLQL  := '1'
                SC2->(MsUnlock())

                l_Bloq    := .T.

            Endif

        Endif

        (c_Tmptela)->(dbSkip())

    Enddo

    If l_Bloq

        FWAlertWarning("As OPs selecionadas foram bloqueadas com Sucesso.","Aviso")

    Endif

Return l_Ret



/*/{Protheus.doc}
@type  function
@author Silvio Nogueira
@since 01/10/2025
@version 01
@description Função para efetuar o execauto no PC (MATA120) com base nas SCs selecionadas
/*/
Static Function DesbEncOP(o_Dados)

    Local l_Ret     := .T.
    Local l_Desb    := .F.
    Local l_Enc     := If(n_Acao==3,.T.,.F.)
    Local l_EncOK   := .T.

    /*
    If n_Acao == 2 // Desbloqueio com possibilidade de Encerramento

        If MsgYesNo( "Você está desbloqueando as OPs selecionadas. Deseja também ENCERRÁ-LAS nesse momento ?")

            l_Enc   := .T.

        Endif

    Endif
    */

    If n_Acao == 3 // Encerramento da OP

        If !MsgYesNo( "Tem certeza que deseja ENCERRAR as OPs selecionadas ?")

            Return .F.

        Endif

    Endif

    (c_Tmptela)->(dbGotop())
    
    While !(c_Tmptela)->(Eof())

        If (c_Tmptela)->C2_OK == _cMarca

            SC2->(dbSetOrder(1))

            If SC2->(MsSeek(xFilial("SC2")+(c_Tmptela)->C2_NUM+(c_Tmptela)->C2_ITEM+(c_Tmptela)->C2_SEQUEN))

                RecLock("SC2",.F.)
                SC2->C2_MSBLQL  := '2'
                SC2->(MsUnlock())

                l_Desb    := .T.

                If l_Enc

                    l_EncOK := EncerraOP(xFilial("SC2"),(c_Tmptela)->C2_NUM+(c_Tmptela)->C2_ITEM+(c_Tmptela)->C2_SEQUEN)

                Endif

            Endif

        Endif


        (c_Tmptela)->(dbSkip())

    Enddo

    If l_Desb .And. n_Acao == 2

        FWAlertWarning("As OPs selecionadas foram desbloqueadas com Sucesso.","Aviso")

    Endif

    If !l_EncOK

        FWAlertError("Ocorreu erro durante o encerramento das OPs. Favor tentar novamente ou encerrar manualmente.", "Erro")        

    Endif

Return l_Ret


Static Function EncerraOP(c_Filial,c_OP)
    Local l_Ret         := .T.
    Local c_OperEnc     := SuperGetMv("MV_XOPEREN",.F.,'99')    
    Local c_Local
    Local n_QtdProd

    // Inicia processo de encerramento da OP

    c_Prod      := GetAdvFval("SC2","C2_PRODUTO",xFilial("SC2") + c_OP, 1, '')
    c_Local     := GetAdvFval("SC2","C2_LOCAL",xFilial("SC2") + c_OP, 1, '')
    n_QtdProd   := GetAdvFval("SC2","C2_QUANT",xFilial("SC2") + c_OP, 1, '')

    DbSelectArea("SH6")
    SH6->(DbSetOrder(1))

    aVetor := {;
        {"H6_FILIAL"    , c_Filial       ,Nil},;
        {"H6_OP"        , c_OP             ,Nil},;
        {"H6_PRODUTO"   , c_Prod           ,Nil},;
        {"H6_OPERAC"    , c_OperEnc        ,Nil},;
        {"H6_PT"        , "T"             ,Nil},;
        {"H6_LOCAL"     , c_Local          ,Nil},;
        {"H6_DATAINI"   , dDatabase         ,Nil},;
        {"H6_DATAFIN"   , dDatabase         ,Nil},;
        {"H6_QTDPROD"   , n_QtdProd        ,Nil}}
/*
        {"H6_RECURSO"   , c_Recurso            ,Nil},;
        {"H6_HORAINI"   , oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRINI")         ,Nil},;
        {"H6_HORAFIN"   , oModelMVC:GetModel("GRIDID"):GetValue("TMP_HRFIM")         ,Nil},;
*/

    MSExecAuto({|x| mata681(x)},aVetor, 3)
    If lMsErroAuto

        Mostraerro()
        l_Ret := .F.

        //DisarmTransaction()
        //BREAK

    EndIf

    SH6->(dbCloseArea())

Return l_Ret

