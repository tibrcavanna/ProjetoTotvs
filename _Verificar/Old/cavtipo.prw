#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Cavtipo     � Autor � Cesar Moura      � Data �  19/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Tipos de Produ��o para consulta padr�o campo   ���
���          � G1_TDP                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP811                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function cavtipo()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZ1"

dbSelectArea("SZ1")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Tipos de Producao",cVldExc,cVldAlt)

Return
