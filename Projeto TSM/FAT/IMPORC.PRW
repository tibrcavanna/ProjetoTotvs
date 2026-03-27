#Include "TOTVS.ch"
#INCLUDE "rwmake.ch"
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'



/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Responsável pela chamada da funcao padrao ORCFAT, e logo após a impressão           @@@
@ do documento, é feito a inclusão no banco de conhecimento                           @@@
@ Autor: Lucas Apolinario                                                             @@@
@ Since: 04/06/2025                                                                   @@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
User Function IMPORC()
    Local aArea := FwGetArea()

    u_ORCFAT() // Chama a funcao ORCFAT, que é a rotina de imprimir orçamentos

    SavePdf()

    FwRestArea(aArea)
Return



/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Responsável por salvar o documento tanto na pasta quanto nas tabelas                @@@
@ envolvidas de banco de conhecimento                                                 @@@
@ Autor: Lucas Apolinario                                                             @@@
@ Since: 04/06/2025                                                                   @@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
Static function SavePdf()
    Local cDirDoc := Alltrim(GetMv("MV_DIRDOC"))
    Local cPath   := ''
    Local cArqOri := ''
    Local cArqNew := '' // Nome do arquivo pdf, mas considerando o registro dele como FILIAL + NUMERO DO ORÇAMENTO, para ser localizado posteriormente
    Local aArq    := {}
    Local nX      := 1
    Local lRet    := .t.


    FwAlertInfo("Selecione o PDF que foi gerado", "Impressão de PDF")
    cArqOri := tFileDialog( "PDF files (*.pdf) ", 'Seleção de Arquivos', , , .F., )
    
    if !empty(Alltrim(cArqOri))
        aArq := StrTokArr(cArqOri, "\")
        cArqAtu:= aArq[len(aArq)]

    
        //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
        If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
            cDirDoc := cDirDoc + "\"
        EndIf
        cPathBco := cDirDoc + 'co'+cEmpAnt+'\shared\'

        //se o diretorio nao existe, cria a pasta dirdoc para evitar erros
        If ! ExistDir(cPathBco)
            if ! ExistDir("\DIRDOC\")
                MakeDir("\DIRDOC\")
                MakeDir("\DIRDOC\co"+cEmpAnt+"")
                MakeDir(cPathBco)
            else
                MakeDir("\DIRDOC\co+"+cEmpAnt+"\")
                MakeDir(cPathBco)
            endif
        endif

        //Faz a cópia da origem, para a pasta do banco de conhecimento
        Copy File &(cArqOri) To &(cPathBco + cArqAtu)

        for nX:=1 to len(aArq)
            IIF(nX <> len(aArq), cPath += aArq[nX] + "\", cArqNew +=  cFilAnt + SCJ->CJ_NUM + ".pdf" ) // coloco novo nome no arquivo
        next nX

        FRename(cPathBco + cArqAtu, cPathBco + cArqNew)

        //Se não conseguiu copiar, mostra um alerta, e volta o laço
        If ! File(cPathBco + cArqNew)
            MsgAlert("Erro ao importar: " + cPathBco + cArqNew, "Atencao!")
            lRet := .f.
        EndIf


        if lRet 
    
            //Pega o próximo registro da ACB
            DbSelectArea("ACB")
            ACB->(DbSetOrder(1))
            ACB->(DbGoBottom())
            cProxObj := StrZero((Val(ACB->ACB_CODOBJ) + 1), 10)
            ACB->(DbSetOrder(2))
            
            //Se não tiver o arquivo na ACB, irá incluir
            If ! ACB->(DbSeek(FWxFilial('ACB') + cArqNew))
                Reclock("ACB", .T.)
                    ACB->ACB_FILIAL := FWxFilial('ACB')
                    ACB->ACB_CODOBJ := cProxObj
                    ACB->ACB_OBJETO := cArqNew
                    ACB->ACB_DESCRI := cArqNew
                ACB->(MsUnlock())
                
                //Se não existir na tabela de vinculos, irá criar
                DbSelectArea("AC9")
                AC9->(DbSetOrder(1))
                If ! AC9->(DbSeek(FWxFilial('AC9') + cProxObj + SCJ->CJ_NUM))
                    Reclock("AC9", .T.)
                        AC9->AC9_FILIAL := FWxFilial('AC9')
                        AC9->AC9_ENTIDA := 'SCJ'
                        AC9->AC9_CODENT := cFilAnt + SCJ->CJ_NUM
                        AC9->AC9_FILENT := cFilAnt
                        AC9->AC9_CODOBJ := cProxObj
                    AC9->(MsUnlock())
                EndIf
            EndIf

        ENDIF

    else
        FwAlertWarning("Nenhum arquivo PDF foi selecionado para salvar ao banco de conhecimento!", "Impressão de PDF")
    endif



return
