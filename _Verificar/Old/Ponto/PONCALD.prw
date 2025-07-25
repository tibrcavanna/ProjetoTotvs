#Include "RWMAKE.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PONCALD  � Autor � Ligia Marra           � Data � 20/05/19 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Escala de H.Extra Sindicato. Ponto Entrada Calculo mensal  ���
���          � do Ponto Eletronico                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico para Cavanna                                    ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function PONCALD()
//Salva Ambiente Atual
Local _aArea_ 	:= GetArea()
Local _nTot		:= 0
Local _c050		:= "114"
Local _n050		:= 0
Local _c060		:= "115"
Local _n060		:= 0
Local _c080		:= "116"
Local _n080		:= 0
Local _c100		:= "117"
Local _n100		:= 0

//���������������������������������������������������������������������Ŀ
//� Carrega parametro para nao executar o ponto de entrada              �
//�����������������������������������������������������������������������
//Local lPoncald := IIf(SuperGetMv("ON_PONCAL",.F.,"S",SRA->RA_FILIAL)=="S",.T.,.F.)

//If lPoncald
	//vai na tabela de resultados
	dbSelectArea("SPB")
	dbSetOrder(1)
	//Procura a Verba de horas extras
	If dbSeek(SRA->RA_FILIAL + SRA->RA_MAT)
		
		While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SPB->PB_FILIAL + SPB->PB_MAT
			//Apura os totais e deleta as verbas
			If SPB->PB_PD $ "114/115/116/117"
				_nTot += SPB->PB_HORAS
				RecLock("SPB",.F.)
				dbDelete()
				Msunlock()
			Endif
			SPB->(dbskip())
		Enddo
		
		//Acima de 60 horas - HE 100%
		If _nTot > 60
			_n100	:= 	_nTot - 60
			_nTot	:= _nTot - _n100
			RecLock("SPB",.T.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := _c100
			SPB->PB_HORAS  := _n100
			SPB->PB_DATA   := dDataFim
			SPB->PB_TIPO1	:=  "H"
			SPB->PB_TIPO2  := "G"
			MsUnlock()
		Endif
		
		//Acima de 40 horas HE 80%
		If _nTot > 40
			_n080	:= 	_nTot - 40
			_nTot	:= _nTot - _n080
			RecLock("SPB",.T.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := _c080
			SPB->PB_HORAS  := _n080
			SPB->PB_DATA   := dDataFim
			SPB->PB_TIPO1	:=  "H"
			SPB->PB_TIPO2  := "G"
			MsUnlock()
		Endif
		
		//Acima de 25 horas HE 60%
		If _nTot > 25
			_n060	:= 	_nTot - 25
			_nTot	:= _nTot - _n060
			RecLock("SPB",.T.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := _c060
			SPB->PB_HORAS  := _n060
			SPB->PB_DATA   := dDataFim
			SPB->PB_TIPO1	:=  "H"
			SPB->PB_TIPO2  := "G"
			MsUnlock()
		Endif
		
		//Ate 25 horas HE 50%
		If _nTot <= 25 .And. _nTot > 0
			_n050	:= 	_nTot
			RecLock("SPB",.T.)
			SPB->PB_FILIAL := SRA->RA_FILIAL
			SPB->PB_CC     := SRA->RA_CC
			SPB->PB_MAT    := SRA->RA_MAT
			SPB->PB_PD     := _c050
			SPB->PB_HORAS  := _n050
			SPB->PB_DATA   := dDataFim
			SPB->PB_TIPO1	:=  "H"
			SPB->PB_TIPO2  := "G"
			MsUnlock()
		Endif
	Endif
	
//Endif

RestArea(_aArea_)

Return 