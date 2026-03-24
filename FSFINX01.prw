#include 'protheus.ch'



/*/{Protheus.doc} FSFINX01
Gatilho acionado ao ser preenchido o campo FW5_PARTIC
@type function
@version  12.2410
@author lucas
@since 24/10/2025
@return logical , se permite ou nao o registro informado
/*/
User function FSFINX01()
    Local a_Area := FwGetArea()
    Local c_Cont := FWFldGet("FW5_PARTIC")
    Local l_Ret  := .t.

    l_Ret := FSFINX01A(c_Cont)

    IF l_Ret 
        l_Ret := FSFINX01B(c_Cont)
    endif    
    
    FwRestArea(a_Area)

return l_Ret


/*/{Protheus.doc} FSFINX01A
a.	O Código do Participante (FW5_PARTIC) existe na tabela AA1_CODUSR? 
@type function
@version 12.2410
@author lucas
@since 24/10/2025
@param c_Cont, character, conteudo do FW5_PARTIC
@return logical, se existe ou nao na tabela AA1
/*/
Static function FSFINX01A(c_Cont)
    Local a_Area := FwGetArea()
    Local l_Ret  := .t.
    
    DbSelectArea("RD0")
    RD0->(DbSetOrder(1))
    IF RD0->(MsSeek(xFilial("RD0") + AvKey(c_Cont, "RD0_CODIGO")))

        IF !empty(RD0->RD0_USER)

            //4	AA1_FILIAL + AA1_CODUSR	Cod. Usuario
            DbSelectArea("AA1")
            AA1->(DbSetOrder(4))
            IF AA1->(!MsSeek(xFilial("AA1") + AvKey(RD0->RD0_USER,"AA1_CODUSR")))
                FwAlertError("O participante não é um Atendente!.", "Atenção")
                l_Ret := .f.
            endif

            AA1->(DbCloseArea())
        else
            l_Ret := .F.
            FwAlertError("O Participante não possui usuario protheus Vinculado!","Atenção")
        endif
    endif
    RD0->(DbCloseArea())

    FwRestArea(a_Area)

return l_Ret


/*/{Protheus.doc} FSFINX01B
b.	Validar se o participante informado está alocado em uma ordem de serviço deste projeto.
    - Procurar uma OS (AB6) do projeto informado no campo FW3_XITCONT (relacionamento feito pelo campo AB6_CONTRT).
        i.	Deve ser uma ordem de serviço aberta – AB6_STATUS == ‘A’
        ii.	OS precisa ser deste participante – relacionamento AB6_ATEND X FW5_PARTIC
@type function
@version 12.2410 
@author lucas
@since 24/10/2025
@return logical, se permite seguir com a inclusao do conteudo ao campo ou nao
/*/
static function FSFINX01B(c_Cont)
    Local a_Area        := FwGetArea()
    Local l_Ret         := .t.
    Local c_xitcont     := FWFldGet("FW3_XITCON")
    Local c_Query       := ""
    Local o_StateQRY    := Nil

    if empty(c_xitcont)
        FwAlertError("Preencha o projeto informado ao campo Item Contábil!","Campo não preenchido")
        FwRestArea(a_Area)
        l_Ret := .f.
        return l_Ret
    endif

    DbSelectArea("RD0")
    RD0->(DbSetOrder(1))
    IF RD0->(MsSeek(xFilial("RD0") + AvKey(c_Cont, "RD0_CODIGO")))

        o_StateQRY    := FWPreparedStatement():New()

        c_Query += " SELECT COUNT(*) AS REGISTROS       " 
        c_Query += " FROM   " + RetSQLName("AB6") + "   " 
        c_Query += " WHERE  AB6_CONTRT     =  ?         " 
        c_Query += "        AND AB6_STATUS = 'A'        " 
        c_Query += "        AND AB6_XUSER  =  ?         " 
        c_Query += "        AND D_E_L_E_T_ = ''         " 

        o_StateQRY:SetQuery(c_Query)
        o_StateQRY:SetString(1,c_xitcont)
        o_StateQRY:SetString(2,RD0->RD0_USER)

        c_Query    := o_StateQRY:GetFixQuery()

        PLSQUERY(c_Query, "AB6T")

        IF AB6T->(EOF()) .OR. AB6T->REGISTROS == 0
            FwAlertError("Participante informado não está alocado em uma ordem de serviço/projeto.","Atenção")
            l_Ret := .f.
        endif

        AB6T->(DbCloseArea())
    endif
    RD0->(DbCloseArea())

    FwRestArea(a_Area)

return l_Ret
