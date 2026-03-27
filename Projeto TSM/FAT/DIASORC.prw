#include "totvs.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'




/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Função responsável pelo envio de e-mail, conforme a regra a considerar de validade  @@@
@ de orçamentos                                                                       @@@
@ Autor: Lucas Apolinario                                                             @@@
@ Since: 01/06/2025                                                                   @@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
User Function DIASORC()
    Local aArea  := FwGetArea()
    Local cQuery := ''
    Local nDias  := GetMv("MV_XDIAORC") // Dias para considerar na soma com o contrato para data limite
    Local _cUser := ''
    Local aOrc   := {}
    Local nX     := 0
    Local cTempo := ''


    if Select('SX2') == 0
        RPCSetEnv('01', '0101', 'totvs', 'TSM@2025', 'TEC') // necessário alterar para as informações do ambiente da cavanna posteriormente
    endif

    cQuery += " SELECT AB3_NUMORC, AB3_ATEND, AB3_XUSER, AB3_XVALID FROM "+ RETSQLNAME("AB3")+ " AB3  " 
    cQuery += " WHERE AB3_STATUS <> 'E' AND D_E_L_E_T_ = '' AND AB3_FILIAL = '" +xFilial("AB3")+ "' "   
    cQuery += " ORDER BY AB3_XUSER "

    PLSQuery(cQuery, "TMPAB3")
    While TMPAB3->(!EOF())
        aOrc := {}
        _cUser := TMPAB3->AB3_XUSER
        _cNome := UsrRetName(_cUser)
        _cMail := Alltrim(UsrRetMail(_cUser))

        WHILE TMPAB3->(!EOF() .AND. TMPAB3->AB3_XUSER == _cUser)
            if TMPAB3->AB3_XVALID <= dDatabase + nDias
                aadd(aOrc, {TMPAB3->AB3_NUMORC,TMPAB3->AB3_XVALID,IIF(dDatabase == TMPAB3->AB3_XVALID , 0, DateDiffDay(dDatabase + nDias, TMPAB3->AB3_XVALID))})
            endif
        
            TMPAB3->(DbSkip())
        Enddo
 

        _cCorpo := "<HTML>"
        _cCorpo += "<BODY>"
        _cCorpo += "Prezado(a) "+_cNome+" <br/><br/>"
        _cCorpo += "Foi identificado orçamentos com data de validade próxima.<br/><br/>"
        _cCorpo += "Segue a lista com os nºs: </b><br/>"
        
        for nX:= 1 to len(aOrc)
            cTempo := IIF(aOrc[nX][3] == 0, "Vencimento hoje", "Dias restantes: "+cValToChar(aOrc[nX][3]))

            _cCorpo += "nº:"+aOrc[nX][1]+ " - Válido até: <B>"+DTOC(aOrc[nX][2])+ "<B> - "+cTempo+". <br/>"

        next

        _cCorpo += "OBS: Esta é uma mensagem automática gerada pelo sistema Protheus.<br/><br/>"
        _cCorpo += "</BODY>"
        _cCorpo += "</HTML>"


         if !empty(_cMail)
            //                  PARA QUEM			TITULO DO E-MAIL                         CORPO 
            If !U_EnvMail(, ,Alltrim(_cMail),"Orçamentos com validade próxima - Notificação",_cCorpo,"","",{})
                Conout("Falha inesperada no envio de e-mail de validade de orçamentos.")
            Endif
        endif



        TMPAB3->(DbSkip())
    enddo


    TMPAB3->(DbCloseArea())



    FwRestArea(aArea)
Return
