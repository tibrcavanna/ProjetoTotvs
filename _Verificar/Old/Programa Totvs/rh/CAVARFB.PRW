#Include 'Protheus.ch'
#Include 'tbiconn.ch'
/*
{Protheus.doc} CAVAPON()
Envia email
@Author     Davi Torchio
@Since      07/10/2020
@Version    P12.1.25
@Project    Portal CAVANNA

*/ 
User Function CAVARFB()

    Local cQuery := 'DELETE FROM RFB010'

    Prepare Environment Empresa "01" Filial "01"


	nStatus := TCSQLEXEC(cQuery)

RETURN 
