#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 14/12/01
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CODBARVL2 �Autor  �Claudio D. de Souza � Data �  14/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validar o codigo de barras ou a linha digitavel de titulos ���
���          � a pagar ou a receber                                       ���
���          � Parametros: cCodBar - Codigo de barras ou linha digitavel  ���
���          � Retorno   : aRet    - Matriz com os retornos possiveis     ���
���          �             aRet[1] - 0 Codigo de barras de titulos/Boletos���
���          �                       1 Codigo de barras de concessionarias���
���          �                       2 Linha digitavel de titulos/Boletos ���
���          �                       3 Linha digitavel de concessionarias ���
���          �             aRet[2] - .T. Codigo de barras ou linha digita-���
���          �                           vel validos                      ���
���          �                       .F. Caso contrario                   ���
�������������������������������������������������������������������������͹��
���Uso       � AP6                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CodBarV2(cCodBar)
Local lRet := .T.,;
		nX			  ,;
		cCampo     ,;
		nRet := 0

cCodBar := Alltrim(cCodBar)
// Completa o tamanho do codigo de barras se ele for menor que 44 por se tratar de uma
// linha digitavel.
If Len(cCodBar) < 44
	cCodBar := Left(cCodBar+Replicate("0", 48-Len(cCodBar)),47)
Endif

Do Case
Case Len(cCodBar)==44 // Validacao do codigo de Barras
	// Boletos
	nRet := 0
	// Se nao conseguir validar o DV do codigo de barras, tenta validar como
	// se fosse titulo de concessionaria.	
	If Dv_BarCode(Left(cCodBar,4)+SubStr(cCodBar,6))!=SubStr(cCodBar,5,1)
		nRet := 1 // Codigo de barras de concessionarias
		// Concessionarias
		If Mod10(Left(cCodBar,3)+SubStr(cCodBar,5))!=SubStr(cCodBar,4,1)
			lRet := .F. // Invalido
		Endif	
	Endif
Case Len(cCodBar)==47 // Validacao da linha digitavel 
	nRet := 2
	// Elimina os digitos
	cCodSemDv := Left(cCodBar,9)+SubStr(cCodBar,11,10)+SubStr(cCodBar,22,10)
	// Calcula os digitos e os compara com os digitos informados
	For nX := 1 To 3
		cCampo := SubStr(cCodSemDv,If(nX==1,1,If(nX==2,10,20)),If(nX==1,9,10))
		If Mod10(cCampo) != SubStr(cCodBar,If(nX==1,10,If(nX==2,21,32)),1)
			lRet := .F.
			Exit
		Endif
	Next
OtherWise // Validacao da linha digitavel de concessionarias
	nRet := 3
	// Elimina os digitos
	cCodSemDv := Left(cCodBar,11)+SubStr(cCodBar,13,11)+SubStr(cCodBar,25,11)+SubStr(cCodBar,37,11)
	// Calcula os digitos e os compara com os digitos informados
	For nX := 1 To Len(cCodSemDv) Step 11
		cCampo := SubStr(cCodSemDv,nX,11)
		If Mod10(cCampo) != SubStr(cCodBar,nX+If(nX==1,11,12),1)
			lRet := .F.
			Exit
		Endif
	Next
EndCase
Return {nRet,lRet}

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �Dv_BarCode�Autor  �Claudio D. de Souza � Data �  14/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o digito verificador de um codigo de barras padrao  ���
���          �Febraban.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � CodBarVl2                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function DV_BarCode( cBarCode )
Local cDig     ,;
      nPos     ,;
      nAux := 0

    For nPos := 1 To 43
        nAux += Val(SubStr(cBarCode,nPos,1)) * If( nPos<= 3, ( 5-nPos),     ;
                                                If( nPos<=11, (13-nPos),     ;
                                                If( nPos<=19, (21-nPos),     ;
                                                If( nPos<=27, (29-nPos),     ;
                                                If( nPos<=35, (37-nPos),     ;
                                                               (45-nPos) )))))
    Next
    nAux := nAux % 11
    cDig := If( (11-nAux)>9, 1, (11-nAux) )
    
Return StrZero( cDig, 1 )
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Rotina    �Mod10     �Autor  �Claudio D. de Souza � Data �  14/12/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calcula o digito verificador de uma sequencia de numeros    ���
���          �baseando-se no modulo 10. Utilizado para verificar o digito ���
���          �em linhas digitaveis e codigo de barras de concessionarias  ���
���          �de servicos publicos                                        ���
�������������������������������������������������������������������������͹��
���Uso       � CodBarVl2                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Mod10( cNum )
Local nFor    := 0,;
      nTot    := 0,;
      cNumAux

   If Len(cNum)%2 #0
      cNum := "0"+cNum
   EndIf

   For nFor := 1 To Len(cNum)
      If nFor%2 == 0
         cNumAux := StrZero(2 * Val(SubStr(cNum,nFor,1)), 2)
      Else
         cNumAux := StrZero(Val(SubStr(cNum,nFor,1))    , 2)
      Endif
      nTot += ( Val(LEFT(cNumAux,1)) + Val(Right(cNumAux,1)) )
   Next

   nTot := nTot % 10
   nTot := If( nTot#0, 10-nTot, nTot )

Return StrZero(nTot,1)