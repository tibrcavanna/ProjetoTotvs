#INCLUDE "rwmake.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PONCALM   � Autor �Marco - Primainfo   � Data �  20/06/18   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada - Inicio calculo Mensal                   ���
���          � Limpar calculos anteriores - Erro em 20/06/2016            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function PONCALM


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local a_Area := GetArea()

dbSelectArea("SPB")
dbSetOrder(1)
If dbSeek(SRA->RA_FILIAL+SRA->RA_MAT)
	While !SPB->(eof()) .And. SRA->RA_FILIAL+SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT
		If SPB->PB_DATA >= dDataIni .And. SPB->PB_DATA <= dDatafim
			RecLock("SPB",.f.)      
			dbDelete()
			SPB->(MsUnlock())		
		Endif
	
		SPB->(dbSkip())
	Enddo
Endif

RestArea(a_Area)

Return