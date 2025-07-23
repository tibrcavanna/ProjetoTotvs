#include "rwmake.ch" 

//ponto de entrada na gravacao da nota fiscal

User Function SF2460I

Local _cAreaAtu  := getarea()

dbSelectArea("SF2")

RecLock("SF2",.F.)
   SF2->F2_ESPECI2 := "" //LIMPA ESSE CAMPO PQ ESTA SENDO USADO PARA INFORMAR A PLACA DO VEICULO
MsUnLock("SF2")

RestArea(_cAreaAtu)
Return
