#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CAVTIT05  � Autor � Microsiga          � Data �  26/08/11   ���
�������������������������������������������������������������������������͹��
���Descricao �Axcadastro SE2 - para colocar o numero da OP                ���
�������������������������������������������������������������������������͹��
���Uso       �Especifico para CAVANNA                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CAVTIT05


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.           
lAltera := .T.

Private cString := "SE2"

dbSelectArea("SE2")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de contas a receber",cVldExc,cVldAlt)

Return
