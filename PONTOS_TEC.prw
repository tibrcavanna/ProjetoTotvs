


/*/{Protheus.doc} PJxOS
Ao clicar no menu do SIGATEC, na função Ordem de Serviço. Esse fonte é chamado antes de acessar a ordem de serviço TECA450
@type function
@version  
@author Lucas
@since 22/01/2026
@return 
/*/
User Function PJxOS()

    c_Area := GetArea()

    o_StateQRY    := FWPreparedStatement():New()

        c_Query := " SELECT * "
        c_Query += " FROM   " + RetSQLName("AB6") + " AB6   " 
        c_Query += " INNER JOIN " + RetSQLName("ABI") + " ABI ON LEFT(ABI_NUMOS,6) = AB6_NUMOS "    "
        c_Query += " WHERE  AB6.D_E_L_E_T_ = '' AND ABI.D_E_L_E_T_ = '' "           

        o_StateQRY:SetQuery(c_Query)

        c_Query    := o_StateQRY:GetFixQuery()

        PLSQUERY(c_Query, "AB6T")

        DBSelectArea("AB6")
        DbSetOrder(1)

        While !AB6T->(EOF())

            MsSeek(xFilial("AB6") + AvKey(AB6T->ABI_NUMOS, "ABI_NUMOS"))
            
            Reclock("AB6",.F.)
                AB6->AB6_PROJET := AB6T->ABI_PROJET
                AB6->AB6_CONTRT := AB6T->ABI_PROJET
            MsUnLock()

        AB6T->(DbSkip())
        Enddo

    RestArea(c_Area)
    TECA450()

Return
