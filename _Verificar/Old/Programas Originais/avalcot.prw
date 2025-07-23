#INCLUDE "rwmake.ch"


User Function AVALCOT() //PONTO DE ENTRADA NA ANALISE DA COTACAO NA GRAVAO DO PEDIDO CE COMPRAS 

Local _aArea := GetArea()

Reclock("SC7",.f.)
 sc7->c7_op := sc1->c1_op
Msunlock()


RestArea(_aArea)

Return
