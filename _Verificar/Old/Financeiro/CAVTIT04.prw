#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVTIT04  � Autor � Microsiga          � Data �  26/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao �Axcadastro SE1 - para colocar o numero da OP                ���
�������������������������������������������������������������������������͹��
���Uso       �Especifico para CAVANNA                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CAVTIT04


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
lOCAL lAltera := .T.

Private cString := "SE1"

dbSelectArea("SE1")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de contas a receber",cVldExc,cVldAlt)

Return
