#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
//
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//  Programa ...: RepMoedas                            Modulo : Sigaadv     //
//                                                                          //
//  Autor ......: Paulo Roberto de Oliveira            Data ..: 17/02/21    //
//                                                                          //
//  Empresa ....: Armi Consultoria e Treinamento                            //
//                                                                          //
//  Descricao ..: Reprocessamento de Taxas de Moedas                        //
//                                                                          //
//  Uso ........: Especifico da Cavanna                                     //
//                                                                          //
//  Observacao .: Rotina  de  reprocessamento  do  cadastro  de  taxas  de  //
//                moedas de um determinado periodo informado                //
//                                                                          //
//  Atualizacao : 17/02/21 - Paulo Roberto de Oliveira                      //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//

/////////////////////////
User Function RepMoedas()
/////////////////////////
//
Private _dDatIni := M->dDataBase                 // Datas Inicio e Fim do Reprocessamento de Taxas de Moedas
Private _dDatFim := M->dDataBase
//
Private cPerg := Substr("REPMOEDAS1" + Space(Len(SX1->X1_GRUPO)), 1, Len(SX1->X1_GRUPO))
//
PgRepMoedas()                                    // Verificar e Criar as Perguntas Especificas
//
If !Pergunte(cPerg, .T.)
   Return (.T.)
Endif
//
If Mv_Par01 > Mv_Par02 .Or. Empty(Mv_Par02)
   //
   MsgAlert("Existem Parâmetros Informados Incorretamente !!!", "Atenção !!!")
   Return (.T.)
   //
Endif
//
_dDatIni := Mv_Par01
_dDatFim := Mv_Par02
//
If MsgYesNo("Deseja Reprocessar o Perí­odo de " + Dtoc(_dDatIni) + " a " + Dtoc(_dDatFim) + " das Taxas de Moedas da Filial " + Alltrim(M->cFilAnt) +;
            "-" + Alltrim(Upper(SM0->M0_FILIAL)) + " ?", "Reprocessamento de Moedas")
   //
   Processa({|lEnd| ProcMoedas()}, "Reprocessamento de Moedas")
   //
Endif
//
Return (.T.)

/////////////////////////////
Static Function PgRepMoedas()
/////////////////////////////
//
Local sAlias := Alias()                          // Variaveis Auxiliares
Local aRegs  := {}
Local i, j
//
SX1->(DbSetOrder(1))                             // Perguntas do Sistema
//
Aadd(aRegs,{cPerg,"01","Data de Apuracao Inicial     ?","","","mv_cha","D",08,0,0,"G","NaoVazio()",;
    "Mv_Par01","","","","01/01/20","","","","","","","","","","","","","","","","","","","","","   ","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Data de Apuracao Final       ?","","","mv_chb","D",08,0,0,"G","NaoVazio()",;
    "Mv_Par02","","","","31/01/20","","","","","","","","","","","","","","","","","","","","","   ","","","","","","","","","","","","","","",""})
//
For i := 1 To Len(aRegs)                         // Gravar as Perguntas
    //
    SX1->(DbSeek(cPerg + aRegs[i, 2]))
    //
    If SX1->(!Found())
       //
       DbSelectArea("SX1")
       If SX1->(Reclock("SX1", .T.))
          //
          For j := 1 To FCount()
              //
              If j <= Len(aRegs[i])
                 FieldPut(j, aRegs[i, j])
              Endif
              //
          Next j
          //
          SX1->(MsUnlock())
          //
       Endif
       //
    Endif
    //
Next i
//
DbSelectArea(sAlias)
//
Return (.T.)

////////////////////////////
Static Function ProcMoedas()                     // Reprocessamento de Taxas de Moedas
////////////////////////////
//
Local _nQtdTotal := 0                            // Variaveis Auxiliares
Local _nContador := 0
Local _nPercentu := 0
Local _dDatBas := M->dDataBase                   // Salvar a Data Base Original
Local _dDatAux := _dDatIni                       // Data Auxiliar
//
_nQtdTotal := (_dDatFim - _dDatIni)
//
ProcRegua(_nQtdTotal)
//
While _dDatAux <= _dDatFim
      //
      _nContador += 1
      _nPercentu := ((_nContador / IIf(_nQtdTotal == 0, 1, _nQtdTotal)) * 100)
      //
      IncProc("Reprocessando Moedas -> " + Dtoc(_dDatAux) + " (" + Alltrim(Transform(_nPercentu, "@ER 9999.99 %")) + ")")
      //
      M->dDataBase := _dDatAux
      //
      U_AtuMoedas()                              // Chamada da Rotina de Atualizacao de Moedas p/ a Data Corrente
      //
      _dDatAux += 1
      //
Enddo
//
M->dDataBase := _dDatBas                         // Restaurar a Data Base Original
//
If _nContador > 0
   MsgInfo(IIf(_nContador == 1, "Foi Atualizado ", "Foram Atualizados ") + Alltrim(Str(_nContador, 6)) +;
           " Registro" + IIf(_nContador == 1, "", "s") +;
           " do Cadastro de Taxas de Moedas !!!", "Reprocessamento de Moedas")
Else
   MsgAlert("Não Foram Atualizados os Registros do Cadastro de Taxas de Moedas !!!", "Atenção !!!")
Endif
//
Return (.T.)
