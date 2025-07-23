#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
//
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Programa ...: SIGAFIN                              Modulo : Sigaadv     //
//                                                                          //
//  Autor ......: Paulo Roberto de Oliveira            Data ..: 25/11/20    //
//                                                                          //
//  Empresa ....: Armi Consultoria e Treinamento                            //
//                                                                          //
//  Descricao ..: Rotina de Execucao no Menu do Modulo Financeiro (P.E.)    //
//                                                                          //
//  Uso ........: Especifico da Cavanna                                     //
//                                                                          //
//  Observacao .: Ponto de entrada para execucao de rotinas  ao  entrar  e  //
//                navegar pelas rotinas do modulo Financeiro                //
//                                                                          //
//  Atualizacao : 17/02/21 - Paulo Roberto de Oliveira                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//

///////////////////////
User Function SIGAFIN()                          // Ponto de Entrada no Manipulacao do Menu do Modulo Financeiro
///////////////////////
//
U_AtzMoedas()                                    // Atualizacao de Cotacoes de Moedas
//
Return (Nil)

/////////////////////////
User Function AtzMoedas()                        // Atualizacao de Cotacoes de Moedas
/////////////////////////
//
Local _kAreaAtu := GetArea()                     // Salvar Contextos
Local _kAreaSM2 := SM2->(GetArea())
//
SM2->(DbSetOrder(1))                             // Cadastro de Cotacoes de Moedas
//
SM2->(DbSeek(Dtos(M->dDataBase)))
//
If SM2->(!Found())
   //
   U_AtuMoedas()                                 // Chamada da Rotina de Atualizacao de Moedas p/ a Data Corrente
   //
Elseif Empty(SM2->M2_MOEDA1) .Or. Empty(SM2->M2_MOEDA2) .Or. Empty(SM2->M2_MOEDA3) .Or. Empty(SM2->M2_MOEDA4) .Or.;
   Empty(SM2->M2_MOEDA6) .Or. Empty(SM2->M2_MOEDA7)
   //
   U_AtuMoedas()                                 // Chamada da Rotina de Atualizacao de Moedas p/ a Data Corrente
   //
EndIf
//
SM2->(RestArea(_kAreaSM2))                       // Restaurar Contextos
RestArea(_kAreaAtu)
//
Return (Nil)
