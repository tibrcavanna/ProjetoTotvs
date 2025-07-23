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

User Function GCOM001(nD1_PICM)

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cGETMV  := GETMV("MV_ALIQICM")
Local lRet    := .T.

Alert("Campo Aliquota de ICMS "+Str(nD1_PICM,5,2))

If AT(alltrim(Str(nD1_PICM,5,2)),cGETMV) == 0

	cGETMV := Alltrim(cGETMV)+"/"+alltrim(Str(nD1_PICM,5,2))

EndIf

Alert("Param.Aliquota de ICMS "+cGETMV)

PUTMV("MV_ALIQICM",cGETMV)

cGETMV  := GETMV("MV_ALIQICM")

Alert("Novo Param.Aliquota de ICMS "+cGETMV)

Return(lRet)
