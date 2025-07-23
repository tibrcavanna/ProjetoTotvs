#INCLUDE "rwmake.ch"


User Function SB6GRAVA() //PONTO DE ENTRADA NA GERACAO DA NF PARA GRAVAR A OP NO SB6 PODER DE TERCEIROS

Local _aArea := GetArea()

sb6->b6_op := posicione("SC6",1,xfilial("SC6")+sd2->d2_pedido+sd2->d2_itempv+sd2->d2_cod,"C6_OP3")

RestArea(_aArea)

Return
