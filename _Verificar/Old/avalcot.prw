#INCLUDE "rwmake.ch"
//PONTO DE ENTRADA NA ANALISE DA COTACAO NA GRAVAO DO PEDIDO CE COMPRAS 

User Function AVALCOT() 

Local _aArea := GetArea()

Reclock("SC7",.f.)
 sc7->c7_op := sc1->c1_op
Msunlock()


RestArea(_aArea)

Return
