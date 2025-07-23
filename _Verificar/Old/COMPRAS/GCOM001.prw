#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GCOM001   � Autor � Antonio Domingos   � Data �  08/04/16   ���
�������������������������������������������������������������������������͹��
���Descricao � Gatilho para Alterar ICMS do Simples Nacional              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cavanna                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function GCOM001()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cGETMV   := GETMV("MV_ALIQICM")
Local lRet     := .T.
Local nD1_PICM := M->D1_PICM //aCols[n,aScan(aHeader,{|x| Alltrim(x[2]) == 'D1_PICM'})]
Local cNewAliq := Str(nD1_PICM,5,2)

//Alert("Campo Aliquota de ICMS "+cNewAliq)

If right(cNewAliq,2) == "00"
	cNewAliq := Substr(cNewAliq,1,2)
EndIf

If AT(alltrim(cNewAliq),cGETMV) == 0

	cGETMV := Alltrim(cGETMV)+"/"+alltrim(cNewAliq)

EndIf

//Alert("Param.Aliquota de ICMS "+cGETMV)

PUTMV("MV_ALIQICM",cGETMV)

cGETMV  := GETMV("MV_ALIQICM")

//Alert("Novo Param.Aliquota de ICMS "+cGETMV)

Return(lRet)
