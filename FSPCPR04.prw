#include "totvs.ch"
#include "fileio.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} 
(TELA DE PRODUÇÃO, APONTAMENTOS ENGENHARIA)
@type  function
@author Silvio Nogueira
@since 23/09/2025
@version 01
@param c_TpApt : E - Engenharia / P - Produção
/*/

User Function ListaApont(c_TpApt)
    Local o_Report
    Local c_Perg    := "XLSTAPT"

    Private c_TipoApont := c_TpApt

    //Pergunte(c_Perg,.F.)

    //MV_PAR01 := d_DataIni

    Pergunte(c_Perg,.T.)

    o_Report    := ReportDef(c_Perg)
    o_Report:PrintDialog()


Return

Static Function ReportDef(c_Perg)
    Local o_Report
    Local o_Section1
    Local c_Titulo  := "Lista Apontamentos"

    o_Report    := TReport():New('ListaApont',c_Titulo, c_Perg, {|o_Report| PrintReport(o_Report)})

    o_Section1  := TRSection():New(o_Report,"Apontamentos")


    //TSay():New(n_Lin,005,{|| (c_Alias)->Z01_PROJ + "  " +(c_Alias)->Z01_COPER + "  " + (c_Alias)->Z01_DESCR + "  " + Dtoc(Stod((c_Alias)->Z01_DTINI)) + "  " + (c_Alias)->Z01_HRINI  + "  " + Dtoc(Stod((c_Alias)->Z01_DTFIM)) + "  " + (c_Alias)->Z01_HRFIM + "  " + Str((c_Alias)->Z01_TOTAL,6,2) + "  " + Dtoc(Stod((c_Alias)->Z01_DTAPON))},o_Container,/*cPicture*/,/*oFontPadrao*/,,,,.T.,,,300,100,,,,,,.T.)

    If c_TipoApont = 'E'
        TRCell():New(o_Section1,'Z01_PROJ',,'Projeto','',TamSX3('Z01_PROJ')[1])
    Else
        TRCell():New(o_Section1,'Z01_OP',,'O.P.','',TamSX3('Z01_OP')[1])
    Endif
    TRCell():New(o_Section1,'Z01_COPER',,'Operação','',TamSX3('Z01_COPER')[1])
    TRCell():New(o_Section1,'Z01_DESCR',,'Descrição','',TamSX3('Z01_DESCR')[1])
    TRCell():New(o_Section1,'Z01_DTINI',,'Data Inicial','',TamSX3('Z01_DTINI')[1])
    TRCell():New(o_Section1,'Z01_HRINI',,'Hora Inicial','',TamSX3('Z01_HRINI')[1])
    TRCell():New(o_Section1,'Z01_DTFIM',,'Data Final','',TamSX3('Z01_DTFIM')[1])
    TRCell():New(o_Section1,'Z01_HRFIM',,'Hora Final','',TamSX3('Z01_HRFIM')[1])
    TRCell():New(o_Section1,'Z01_TOTAL',,'Total','@E 999.99',TamSX3('Z01_TOTAL')[1])
    TRCell():New(o_Section1,'Z01_DTAPON',,'Dt Apontamento','',TamSX3('Z01_DTAPON')[1])
    TRCell():New(o_Section1,'STATUS',,'Pendência','',1)
    
Return o_Report

Static Function PrintReport(o_Report)
    Local o_Section1    := o_Report:Section(1)
    Local c_AliasZ01    := GetNextAlias()
    Local c_Qry
    Local o_QryC
    Local o_ModelMVC := FWModelActive()
    Local d_ProxMin
    Local c_Status
    Local d_Data

    c_Oper  :=  o_ModelMVC:GetModel("CABID"):GetValue("TMP_OPER")
    //d_Data  :=  o_ModelMVC:GetModel("GRIDID"):GetValue("TMP_DTINI")
    d_Data  := MV_PAR01

    If c_TipoApont == 'E'

        If o_QryC == Nil
            c_Qry := "SELECT Z01_PROJ,Z01_COPER,Z01_DESCR,Z01_DTINI,Z01_DTFIM,Z01_HRINI,Z01_HRFIM,Z01_TOTAL,Z01_DTAPON FROM ? Z01 "
            c_Qry += "WHERE D_E_L_E_T_ = '' "
            c_Qry += "AND (Z01_DTINI = ? OR Z01_DTFIM = ?) "
            c_Qry += "AND Z01_OPER = ? "
            c_Qry += "ORDER BY Z01_DTINI,Z01_HRINI"
            c_Qry := ChangeQuery(c_Qry)
            o_QryC := FWPreparedStatement():New(c_Qry)
        EndIf

        o_QryC:SetUnsafe(1, RetSqlName("Z01"))
        o_QryC:SetString(2, Dtos(d_Data) )
        o_QryC:SetString(3, Dtos(d_Data) )
        o_QryC:SetString(4, c_Oper )

    Else

        If o_QryC == Nil
            c_Qry := "SELECT Z01_PROJ,Z01_OP,Z01_COPER,Z01_DESCR,Z01_DTINI,Z01_DTFIM,Z01_HRINI,Z01_HRFIM,Z01_TOTAL,Z01_DTAPON FROM ? Z01 "
            c_Qry += "WHERE Z01.D_E_L_E_T_ = '' "
            c_Qry += "AND (Z01_DTINI = ? OR Z01_DTFIM = ?) "
            c_Qry += "AND Z01_OPER = ? "

            c_Qry += "UNION ALL "

            c_Qry += "SELECT '' Z01_PROJ,H6_OP Z01_OP,H6_OPERAC Z01_COPER, SVI.VI_DESCRI Z01_DESCR,H6_DATAINI Z01_DTINI,H6_DATAFIN Z01_DTFIM,H6_HORAINI Z01_HRINI,H6_HORAFIN Z01_HRFIM, ROUND(CONVERT(INTEGER,LEFT(H6_TEMPO,3))+CONVERT(NUMERIC,SUBSTRING(H6_TEMPO,5,2))/60,2) Z01_TOTAL, H6_DTAPONT Z01_DTAPON FROM ? SH6 "
            c_Qry += "INNER JOIN ? SVI ON H6_FILIAL = VI_FILIAL AND H6_OPERAC = VI_CODIGO "           
            c_Qry += "WHERE SH6.D_E_L_E_T_ = '' "
            c_Qry += "AND (H6_DATAINI = ? OR H6_DATAFIN = ?)"
            c_Qry += "AND H6_RECURSO = ?"

            c_Qry += "ORDER BY Z01_DTINI,Z01_HRINI"

            c_Qry := ChangeQuery(c_Qry)
            o_QryC := FWPreparedStatement():New(c_Qry)
        EndIf

        o_QryC:SetUnsafe(1, RetSqlName("Z01"))
        o_QryC:SetString(2, Dtos(d_Data) )
        o_QryC:SetString(3, Dtos(d_Data) )
        o_QryC:SetString(4, c_Oper )
        o_QryC:SetUnsafe(5, RetSqlName("SH6"))
        o_QryC:SetUnsafe(6, RetSqlName("SVI"))
        o_QryC:SetString(7, Dtos(d_Data) )
        o_QryC:SetString(8, Dtos(d_Data) )
        o_QryC:SetString(9, c_Oper )

    Endif

    c_Qry       := o_QryC:GetFixQuery()
    c_AliasZ01  := MPSysOpenQuery( c_Qry )

    //d_TempAnt   := fwtimestamp(1,MV_PAR01,"08:00")
    d_TempAnt   := fwtimestamp(1,MV_PAR01,HoraInicio(MV_PAR01))

    (c_AliasZ01)->(dbGotop())

    While !(c_AliasZ01)->(Eof())

        c_Status    := ' '

        o_Section1:Init()

        If c_TipoApont = 'E'
            o_Section1:Cell('Z01_PROJ'):SetValue(Alltrim((c_AliasZ01)->Z01_PROJ))
        Else
            o_Section1:Cell('Z01_OP'):SetValue(Alltrim((c_AliasZ01)->Z01_OP))
        Endif
        o_Section1:Cell('Z01_COPER'):SetValue(Alltrim((c_AliasZ01)->Z01_COPER))
        o_Section1:Cell('Z01_DESCR'):SetValue(Alltrim((c_AliasZ01)->Z01_DESCR))
        o_Section1:Cell('Z01_DTINI'):SetValue(Stod((c_AliasZ01)->Z01_DTINI))
        o_Section1:Cell('Z01_HRINI'):SetValue(Alltrim((c_AliasZ01)->Z01_HRINI))
        o_Section1:Cell('Z01_DTFIM'):SetValue(Stod((c_AliasZ01)->Z01_DTFIM))
        o_Section1:Cell('Z01_HRFIM'):SetValue(Alltrim((c_AliasZ01)->Z01_HRFIM))
        o_Section1:Cell('Z01_TOTAL'):SetValue((c_AliasZ01)->Z01_TOTAL)
        o_Section1:Cell('Z01_DTAPON'):SetValue(Stod((c_AliasZ01)->Z01_DTAPON))

        //    Local dDataHora := StoD("20251111083000") // 11/11/2025 08:30:00
        // Exemplo com verificação de virada de dia (simplificado):
        
        c_DataAnt   := SubStr(d_TempAnt, 1, 8)
        c_HoraAnt   := SubStr(d_TempAnt, 9, 4)

        c_HoraNew   := IncTime(Left(c_HoraAnt,2)+":"+Substring(c_HoraAnt,3,2),0,1,0)

        If c_HoraNew >= '24:00'

            d_DataNew   := Stod(c_DataAnt) + 1
            c_HoraNew   := "00:00"

        Else

            d_DataNew   := Stod(c_DataAnt)

        Endif

        /*
        n_TimeIniSec := Hrs2Sec(c_HoraAnt)                  // Converte hora para segundos
        n_TimeFimSec := n_TimeIniSec +  60                  // Adiciona minuto em segundos
    
        // Se o resultado passar de 24h, ajustamos a data
        IF n_TimeFimSec >= 86400                            // 24 * 60 * 60 segundos em um dia
            n_TimeFimSec := n_TimeFimSec - 86400
            c_DataNew := Dtoc(Stod(c_DataAnt) + 1)           // Adiciona um dia à data
        ELSE
            c_DataNew := c_DataAnt
        ENDIF

        // Converte segundos de volta para hora (formato HHMMSS)
        c_HoraNew := Sec2Hrs(n_TimeFimSec) 

        */

        d_ProxMin := fwtimestamp(1,d_DataNew,Left(c_HoraNew,5))
        
        If fwtimestamp(1,Stod((c_AliasZ01)->Z01_DTINI),(c_AliasZ01)->Z01_HRINI) <> d_ProxMin .And. HoraValida(d_DataNew,c_HoraNew)

            c_Status := '*'

        Endif

        o_Section1:Cell('STATUS'):SetValue(c_Status)

        o_Section1:PrintLine()

        d_TempAnt   := fwtimestamp(1,Stod((c_AliasZ01)->Z01_DTFIM),(c_AliasZ01)->Z01_HRFIM)

        (c_AliasZ01)->(dbSkip())

    Enddo

    o_Section1:Finish()

    (c_AliasZ01)->(dbCloseArea())

Return

Static Function HoraValida(d_Data,c_Hora)

    Local n_Atual
    Local n_Vezes   := 0
    Local cCaracter := "X"
    Local c_HrIni   := 0
    Local a_Horas   := {}
    Local l_Inicia  := .T. 
    Local d_DiaSem  := DoW(d_Data)
    Local c_CalPad  := SuperGetMv("MV_XCALPAD",.F.,'001')    
    Local c_Aloc    := Left(Posicione("SH7",1,FWxFilial("SH7") + c_CalPad,"H7_ALOC"),672)
    Local n_HrCent  := Int(Val(Left(c_Hora,2)))+(Val(Substring(c_Hora,4,2))/60)
    Local l_Dentro  := .F.
    Local n_D

    If d_DiaSem = 1

        c_Palavra := Substring(c_Aloc,1+(96*6),96)
    
    Else

        c_Palavra := Substring(c_Aloc,1+(96*(d_DiaSem-2)),96)

    Endif

    //Percorre todas as letras da palavra
    For n_Atual := 1 To Len(c_Palavra)
        //Se a posição atual for igual ao caracter procurado, incrementa o valor
        If SubStr(c_Palavra, n_Atual, 1) == cCaracter
            n_Vezes++
            If l_Inicia
                Aadd(a_Horas,(n_Atual * 0.25)-0.25)
                l_Inicia    := .F.
            Endif
            c_HrIni := n_Atual * 0.25
        Else
            If !l_Inicia
                Aadd(a_Horas,(n_Atual * 0.25)-0.25)
                l_Inicia    := .T.
            Endif
        EndIf
    Next

    For n_D := 1 to len(a_Horas) step 2

        If n_HrCent >= a_Horas[n_D] .And. n_HrCent <= a_Horas[n_D+1]

            l_Dentro    := .T.

        Endif

    Next

Return l_Dentro


Static Function HoraInicio(d_Data)

    Local n_Atual
    Local n_Vezes   := 0
    Local cCaracter := "X"
    Local c_HrIni   := 0
    Local a_Horas   := {}
    Local l_Inicia  := .T. 
    Local d_DiaSem  := DoW(d_Data)
    Local c_CalPad  := SuperGetMv("MV_XCALPAD",.F.,'001')    
    Local c_Aloc    := Left(Posicione("SH7",1,FWxFilial("SH7") + c_CalPad,"H7_ALOC"),672)
    Local c_Hora

    If d_DiaSem = 1

        c_Palavra := Substring(c_Aloc,1+(96*6),96)
    
    Else

        c_Palavra := Substring(c_Aloc,1+(96*(d_DiaSem-2)),96)

    Endif

    //Percorre todas as letras da palavra
    For n_Atual := 1 To Len(c_Palavra)
        //Se a posição atual for igual ao caracter procurado, incrementa o valor
        If SubStr(c_Palavra, n_Atual, 1) == cCaracter
            n_Vezes++
            If l_Inicia
                Aadd(a_Horas,(n_Atual * 0.25)-0.25)
                l_Inicia    := .F.
            Endif
            c_HrIni := n_Atual * 0.25
        Else
            If !l_Inicia
                Aadd(a_Horas,(n_Atual * 0.25)-0.25)
                l_Inicia    := .T.
            Endif
        EndIf
    Next

    c_Hora  := Strzero(Int(a_Horas[1]),2) + ":" + Strzero((a_Horas[1]-Int(a_Horas[1]))*60,2)

    c_Hora  := DecTime(Left(c_Hora,2)+":"+Substring(c_Hora,4,2),0,1,0)    

Return c_Hora
