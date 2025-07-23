#INCLUDE "prothesp.CH"
#include "rwmake.ch"

User Function Utilit1() 

SetPrvt("_LCHESTR,_LCHCONT,_LCHQUANT,_LQUANT,_LESTRIG,_LRECIG")
SetPrvt("_CALIAS,_CPERG1,_CRDMAKE,_CEXPR,_CARQ1,_CARQ2")
SetPrvt("_LERRO,_CQUEBRAL,_NTEMORI,_NTEMDES,_CNOMERR,_NHDL")
SetPrvt("_VESTR1,_VESTR2,_VESTRLIT1,_VESTRLIT2,_NVEZ,_CDET")
SetPrvt("_CCHAVE,_CCAMPO,_CACRESC,CINDEX,CKEY,CFILTER")
SetPrvt("_CULTIMO,_NJAFOI,_CCOND,_CCONT1,_CCONT2,_CRESULT")
SetPrvt("_CEXPRT,_XRESULT,_CTIPO,_CRDMAKEXEC,_NALIAS,SSALIAS")
SetPrvt("AREGS,I,J,_LCHTOP,_LCHCODEBASE,_CTABELA")  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Utilit1   ºAutor  ³Microsiga           º Data ³  23/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotinas de Auxilio de Programacao                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Private cRootPath  := GetSrvProfString("ROOTPATH","")
   
cRootPath := AllTrim(cRootPath)
cRootPath := IF(Right(cRootPath,1)="\",Left(cRootPath,Len(cRootPath)-1),cRootPath)

_lChEstr:=_lChCont:=_lChQuant:=.t.
_lChTop :=_lChCodeBase:=_lChDrop:=_lChPack:=_lChInd:=.f.
_lQuant:=_lEstrIg:=_lRecIg:=.t.
_cAlias :=space(3)
_cTabela:=space(3)
_cPerg1 :='TCGENA'
_cRdmake:=space(12)
_cExpr  :=space(50)
validperg(_cPerg1)
pergunte(_cPerg1,.f.)

_cArq1:=alltrim(mv_par01)
_cArq2:=alltrim(mv_par02)



@ 000,000 To 360, 610 Dialog oDlg0 Title "(In) utilities" 

@ 010,020 Say u__fAjTxt("AxCadastro de:")
@ 020,015 Get _cAlias Picture "@!"
@ 020,070 BmpButton Type 1 Action _fAx()

@ 040,020 Say u__fAjTxt("Executar Rdmake:")
@ 050,015 Get _cRdmake Picture "@!" size 50,8
@ 050,070 BmpButton Type 1 Action _fRdmake()

@ 105,012 BmpButton Type 1 Action _fChecaDup()
@ 105,050 Say u__fajtxt("Checagem anti-duplicidade de registros")

@ 120,012 BmpButton Type 1 Action _fGeraDrv()
@ 120,050 Say u__fajtxt("Gerar drive de impressora em disco")

@ 135,012 BmpButton Type 1 Action _fTestaCond()                                             
@ 135,050 Say u__fajtxt("Testar condicoes de pagamento")

@ 150,012 BmpButton Type 1 Action _fGeraB2()                                             
@ 150,050 Say u__fajtxt("Gerar saldos em SB2")

@ 165,012 BmpButton Type 1 Action _fGeraB9()                                             
@ 165,050 Say u__fajtxt("Gerar saldos em SB9")

@ 075,010 Say u__fAjTxt("Testar expressao obtendo resultados na linguagem ADVLP")
@ 090,012 Get _cExpr SIZE 180,10
@ 088,210 BmpButton Type 1 Action _fTestExpr()

@ 010,125 Say u__fAjTxt("Comparar:")
@ 020,130 CHECKBOX "Estruturas             " var _lChEstr
@ 030,130 CHECKBOX "Conteudo               " var _lChCont
@ 040,130 CHECKBOX "Quantidade de registros" var _lChQuant
@ 050,130 CHECKBOX "TopSql  " var _lChTop 
@ 060,130 CHECKBOX "CodBase " var _lChCodeBase
@ 055,210 BmpButton Type 1 Action _fCompara()
@ 055,250 BmpButton Type 5 Action _fPar()

@ 010,265 BmpButton Type 2 Action _fSair()

@ 105,180 Say u__fAjTxt("Verificar Quantidades de Registros:")

@ 120,180 CHECKBOX "TopSql  " var _lChTop
@ 130,180 CHECKBOX "CodBase " var _lChCodeBase
@ 140,180 CHECKBOX "Deleta Tabelas Vazias" var _lChDrop
@ 150,180 CHECKBOX "Deleta Indices" var _lChInd
@ 160,180 CHECKBOX "Pack na Tabela" var _lChPack
@ 170,180 Say u__fAjTxt("Tabela") 
@ 170,200 Get _cTabela Picture "@!"
@ 170,265 BmpButton Type 1 Action _fQtdRegs()

Activate Dialog oDlg0 Centered

return

***************************************************
Static function _fAx() // AxCadastro
***************************************************
Dbselectarea(_cAlias)
if lower(alias())==lower(_cAlias)
   AxCadastro( _cAlias,'Arquivo '+_cAlias)
else 
   msgbox('Alias ['+_cAlias+'] nao disponivel')
endif   

Return

***************************************************
static function _fGeraDrv()  //Gera Drive de Impressora
***************************************************

wnrel:='driver'
cDesc1:=cDesc2:=cDesc3:=Titulo:='Nada'
aOrd:={}
Tamanho:="P"
cString:="SA2" 
cperg:=''
aReturn := { "Zebrado",;  // Tipo do formulario
                     1,;  // Numero de vias
       "Administracao",;  // Destinatario
                     2,;  // Formato 1-Comprimido  2-Normal
                     2,;  // Midia  1-Disco  2-Impressora
                     1,;  // Porta ou arquivo (1-LPT1...)
                    "",;  // Expressao do filtro
                     1 }  // Ordem (Numero do indice)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)
If nLastKey == 27
  Return
Endif
SetDefault(aReturn,cString)
set printer to driver.txt
@ 1,1 PSAY "Inicio"         

***************************************************
// Incrementa o texto com espacos, para que o protheus exiba corretamente
user function _fAjTxt(_cTexto)
return padr(_cTexto,(int(len(_cTexto)*1.5)))
***************************************************

//Compara estrutura e conteudo de dois arquivos dbf 
***************************************************
Static function _fCompara()
***************************************************
If _lChTop .and. _lChCodeBase
  Alert("Selecione Apenas um tipo de base de dados !!!")
  Return
EndIf

If !_lChTop .and. !_lChCodeBase
  Alert("Selecione um tipo de base de dados !!!")
  Return
EndIf

If _lChTop .and. !_lChCodeBase
  _xDriver   := "TOPCONN"
 Else
  _xDriver   := "DBFCDX"
EndIf

_fFechaArq()

MsAguarde({||_fCompstr()},'Comparando o conteudo dos arquivos')

return

Static function _fCompStr()

_lErro:=.f.
_cQuebral:=chr(13)+chr(10)
//_cArq1:=if(lower(right(_cArq1,4))<>lower('.dbf'),_cArq1+'.dbf',_cArq1)
//_cArq2:=if(lower(right(_cArq2,4))<>lower('.dbf'),_cArq2+'.dbf',_cArq2)
if _lChCont
   _lChEstr:=.t.
endif

if !_fMsExist(_cArq1,"\SIGAADV\")
   _lErro:=.t.
   msgbox('Arquivo origem '+_cArq1+' nao encontrado')
endif
if !_fMsExist(_cArq2,"\SIGAADV\")
   _lErro:=.t.
   msgbox('Arquivo destino '+_cArq2+' nao encontrado')
endif
if _lErro
   return
endif
dbusearea(.t.,_xDriver,_cArq1,'Origem',.t.,.t.)
if lower(alias())<>lower('origem')
   _lErro:=.t.
   msgbox('Erro de abertura em '+_cArq1)
endif
dbusearea(.t.,_xDriver,_cArq2,'Destino',.t.,.t.)
if lower(alias())<>lower('Destino')
   _lErro:=.t.
   msgbox('Erro de abertura em '+_cArq2)
endif
if _lErro
   return
endif
// Comparar a quantidade de registros nao deletados
_lQuant:=.t.
if _lChQuant

   origem->(dbgotop())
   destino->(dbgotop())
   _nTemOri:=1
   do while !origem->(eof()).and.lastkey()<>27
      msproctxt('Contando registros nao apagados na origem '+alltrim(str(_nTemOri)))
      _nTemOri:=_nTemOri+1
      origem->(dbskip(1))
   enddo
   _nTemDes:=1
   do while !destino->(eof()).and.lastkey()<>27
      msproctxt('Contando registros nao apagados no Destino '+alltrim(str(_nTemDes)))
      _nTemDes:=_nTemDes+1
      Destino->(dbskip(1))
   enddo
   if _nTemDes<>_nTemOri
      _lQuant:=.f.
      _lErro:=.t.
      msgbox('O arquivo '+_cArq1+' possue '+alltrim(str(_nTemOri))+' registros, porem '+;
             _cArq2+' possue '+alltrim(str(_nTemDes)))
      return
   endif
endif

// Criar o arquivo de erros
_cNomErr:='relato\ErroStru.##r'
ferase(_cNomErr)
if (_nHdl:=fcreate(_cNomErr,0))==-1
   msgbox('Erro na criacao do arquivo de log de erros')
   return
endif

// Comparar estruturas
_lEstrIg:=.t.
if _lChEstr
   _vEstr1:=origem->(dbstruct())
   _vEstr2:=destino->(dbstruct())

   if len(_vEstr1)<>len(_vEstr2)
      if len(_vEstr1)>len(_vEstr2)
         msgbox(_cArq1+' possue mais campos que '+_cArq2)
      else
         msgbox(_cArq2+' possue mais campos que '+_cArq1)
      endif
      _lEstrIg:=.f.
      _lErro:=.t.
      _fFechaArq()
      fclose(_nHdl)
      return
   endif
   _vEstrLit1:={}
   _vEstrLit2:={}
   for _nVez:=1 to len(_vEstr1)
       aadd(_vEstrLit1,padr(_vEstr1[_nVez][1],12)+_vEstr1[_nVez][2]+' '+;
           padr(alltrim(str(_vEstr1[_nVez][3])),5)+padr(alltrim(str(_vEstr1[_nVez][4])),5))
       aadd(_vEstrLit2,padr(_vEstr2[_nVez][1],12)+_vEstr2[_nVez][2]+' '+;
           padr(alltrim(str(_vEstr2[_nVez][3])),5)+padr(alltrim(str(_vEstr2[_nVez][4])),5))
   next
   // Colocar os 2 vetores em ordem alfabetica
   asort(_vEstrLit1) ; asort(_vEstrLit2)
   // Comparar as estruturas, se diferentes, gerar log
   _cDet:='Estruturas: '+_cQuebral
   for _nVez:=1 to len(_vEstrLit1)
       if _vEstrLit1[_nVez]<>_vEstrLit2[_nVez]
          _lErro:=.t.
          _cDet:=_cDet+'*--> '
       endif
       _cDet:=_cDet+_vEstrLit1[_nVez]+_vEstrLit2[_nVez]+_cQuebral
   next

   if _lErro
      if fwrite(_nHdl,_cDet)<len(_cDet)
        _lErro:=.t.
        _lEstrIg:=.f.
        msgbox('Erro de gravacao em '+_cNomTxt)
      endif
      fclose(_nHdl)
      _fFechaArq()
      msgbox('As Estruturas sao diferentes')
      ourspool('ErroStru')
      return
   endif
endif

// Se chegou nesse ponto, as estruturas e a quantidade de registros
// sao exatamente iguais

if _lChCont
   // Montagem da chave de indexacao com todos os campos

   _cChave:=''
   for _nVez:=1 to len(_vEstr1)
       msproctxt('Aguarde, indexando - Arquivo origem')
       _cCampo:=alias()+'->'+_vEstr1[_nVez][1]
       if valtype(&_cCampo)=='C'
          _cAcresc:=_vEstr1[_nVez][1]
       elseif valtype(&_cCampo)=='N'
          _cAcresc:='str('+_vEstr1[_nVez][1]+')'
       elseif valtype(&_cCampo)=='D'
          _cAcresc:='dtos('+_vEstr1[_nVez][1]+')'
       else
          _cAcresc:=''
       endif
       _cChave:=_cChave+_cAcresc+'+'
       if len(_cChave)>235
          exit
       endif
   next
   _cChave:=left(_cChave,len(_cChave)-1)

   if lastkey()<>27
      dbselectarea('Origem')
      cIndex:=CriaTrab(nil,.f.) ; cKey:=_cChave ; cFilter:=".t."
      IndRegua(alias(),cIndex,cKey,,cFilter,"Selecionando Registros no arquivo "+alias())
   endif
   if lastkey()<>27
      dbselectarea('Destino')
      cIndex:= CriaTrab(nil,.f.) ; cKey:=_cChave ; cFilter:=".t."
      IndRegua(alias(),cIndex,cKey,,cFilter,"Selecionando Registros no arquivo "+alias())
   endif
   _cUltimo:='/'+alltrim(str(origem->(lastrec())))

   origem->(dbgotop())
   destino->(dbgotop())
   _nJafoi:=0
   do while !origem->(eof()).and.lastkey()<>27
      _nJafoi:=_nJafoi+1
      msproctxt('Analisando '+alltrim(str(_nJafoi))+_cUltimo)
      for _nVez:=1 to len(_vEstr1)
          _cCond:='origem->'+_vEstr1[_nVez][1]+'==destino->'+_vEstr1[_nVez][1]
          _cCont1:='origem->'+_vEstr1[_nVez][1]
          _cCont2:='destino->'+_vEstr1[_nVez][1]
          _cCont1:=&_cCont1
          _cCont2:=&_cCont2
          if &_cCond==.f.
             _lRecIg:=.f.
             _cDet:='O registro '+alltrim(str(origem->(recno())))+' em '+_cArq1+;
                    ' e diferente do registro '+alltrim(str(destino->(recno())))+' no arquivo '+_cArq2+;
                    ' O Primeiro campo diferente e: '+_vEstr1[_nVez][1]+' o conteudo na origem e: '+_cCont1+' e no destino e: '+_cCont2

             if fwrite(_nHdl,_cDet)<len(_cDet)
               _lErro:=.t.
               msgbox('Erro de gravacao em '+_cNomTxt)
             endif
             fclose(_nHdl)
             msgbox('Ha diferencas no conteudo')
             ourspool('ErroStru')
             return
          endif
      next
      origem->(dbskip(1))
      destino->(dbskip(1))
   enddo
endif

_cResult:=''
if _lChEstr
   _cResult:=_cResult+if(_lEstrIg,'Estruturas Ok','Estruturas diferentes')+'  '
endif
if _lChCont
   _cResult:=_cResult+if(_lQuant,'Conteudo Ok','Conteudos diferentes')
endif
if _lChQuant
   _cResult:=_cResult+if(_lQuant,'Quant regs. Ok','Quant regs. diferentes')+'  '
endif
if lastkey()==27
   msgbox('Processamento interrompido')
else
   msgbox(_cResult)
endif

_fFechaArq()
fclose(_nHdl)
return


//Funcoes para controle do fluxo do programa
***************************************************
Static function _fPar()
***************************************************
pergunte(_cperg1,.t.)
_cArq1:=alltrim(mv_par01)
_cArq2:=alltrim(mv_par02)

return

// Funcoes ADVPL
***************************************************
Static function _fTestExpr()
***************************************************
_cExprT:=alltrim(_cExpr)
_xResult:=&_cExprT
_cTipo:=valtype(_xResult)


if _cTipo=='D'
    _xResult:=dtoc(_xResult)
 elseif _cTipo=='N'
    _xResult:=alltrim(str(_xResult))
 elseif _cTipo=='L'
    _xResult:=if(_xResult,'.T.','.F.') 
 elseif _cTipo=='B'
    _xResult:='A expressao retorna bloco de codigo'
 elseif _cTipo=='U'
    _xResult:='A variavel nao existe ou nao e visivel'
endif

Tone(400,3)
msgbox('('+_cTipo+') '+_xResult)

return

// Executa um programa em Rdmake
***************************************************
Static function _fRdmake()
***************************************************

_cExec:="u_"+alltrim(_cRdmake)//+"()"
_x:=&_cExec

return

***************************************************
Static function _fSair()
***************************************************
_fFechaArq()
fClose(_nHdl)
Close(oDlg0)
return

***************************************************
Static function _fFechaArq()
***************************************************
_nAlias:=1
do while .t.
   if empty(alltrim(alias(_nAlias)))
      exit
   endif
   if lower(alias(_nAlias))==lower('origem')
      origem->(dbclosearea())
   elseif lower(alias(_nAlias))==lower('destino')
      destino->(dbclosearea())
   endif
   _nAlias:=_nAlias+1
enddo

Return(nil) 

***************************************************
Static Function VALIDPERG(_cPerg1)
***************************************************
aRegs := {}
i := j := 0

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(_cPerg1,6)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Arquivo Origem  ?","",""        ,"mv_ch1","C",30,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Arquivo Destino ?","",""        ,"mv_ch2","C",30,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

Return

***************************************************
user function _fCloseDb(_cAlias)
***************************************************
//Tenta fechar o alias indicado                                               

local _cAliasAtu:=Upper(alias())
   
if u__fIsOpen(_cAlias)
   dbselectarea(_cAlias)
   DbClosearea()
endif              

if _cAliasAtu<>upper(_cAlias).and.!empty(_cAliasAtu)
   Dbselectarea(_cAliasAtu)
endif

Return

***************************************************
user function _fIsOpen(_cAlias)
***************************************************
//Retorna logico, se o alias esta ou nao aberto                        

local _cAliasAtu:=Upper(alias()),_nVez:=1,_lAberto:=.f.
dbselectarea(_nVez)
do while !empty(alias())
   dbselectarea(_nVez)
   _nVez++
   if lower(alltrim(alias()))==lower(alltrim(_cAlias))
     _lAberto:=.t.
     exit
   endif
enddo
dbselectarea(_cAliasAtu)

return _lAberto
                                                    
***************************************************
static function _fChecaDup()
***************************************************

_cAlias:='   '
_nOrdem:=1
_cChave:=space(200)

@ 010,000 To 200, 610 Dialog oDlg Title OemToAnsi( "Checagem anti-duplicidade")
@ 010,020 Say 'Alias    : '
@ 010,050 get _cAlias
@ 020,020 Say 'Ordem:     '
@ 020,050 get _nOrdem pict '99'    valid _fOrdem()
@ 030,020 Say 'Chave:     '  
@ 030,050 get _cChave pict '@ks50' SIZE 200,10
@ 080,080 BmpButton Type 1 Action _fProssegue()
@ 080,110 BmpButton Type 2 action Close(oDlg)
ACTIVATE DIALOG oDlg CENTER

Return

***************************************************
static function _fOrdem
***************************************************

if _nOrdem==0
   return .t.
endif   
dbselectarea(_cAlias)
if empty(alias())
   msgbox('Alias ['+_cAlias+'] nao disponivel')
   return .t.
endif            
dbsetorder(_nOrdem)
_cChave:=indexkey()

return .t.

***************************************************
static function _fProssegue
***************************************************
                  
ferase('pare.txt')            
msaguarde({||_fVerifica()},'Verificando arquivo...')

return                                                    
      
***************************************************
static function _fVerifica()
***************************************************

Local aTitulo := {"Registros Duplicados"} 
Local nOpc := 0
Local bOk, bCancel
Local _cLog := ""

_cChave:=alltrim(_cChave)

if _nOrdem=0.and.empty(_cChave)
   msgbox('Sem chave / Sem acordo')
   return
elseif _nOrdem==0
  dbselectarea(_cAlias)
  if empty(alias())
     msgbox('Alias ['+_cAlias+'] nao disponivel')
     return
  endif
  indregua(alias(),criatrab(,.f.),_cChave,,,"Ordenando: "+alias())

endif

dbgotop()
_nPerc   :=0
_cAnt    :='estanaotemmesmo...'
_nDuplic :=0
_nPerc   :=0
_vDuplic :={'Alias: '+alias()+' Chave: '+Indexkey(),''}
do while !eof() //.and.!file('pare.txt')
   msproctxt("Lidos: "+alltrim(str(_nperc++))+' / '+alltrim(str(lastrec()))+;
             '   Duplicados: '+alltrim(str(_nDuplic)))
   if &_cChave==_cAnt
      _nDuplic++      
      aadd(_vDuplic,'Registro: ['+strzero(recno(),6)+'] Chave: ['+_cAnt+']')
      _cLog += 'Registro: ['+strzero(recno(),6)+'] Chave: ['+_cAnt+']'+Chr(13)+Chr(10)
   endif              
   _cAnt:=&_cChave
   dbskip(1)
enddo

if _nDuplic > 0 //.and. msgyesno('Ha '+alltrim(str(_nDuplic))+' registros duplicados, deseja imprimir ?')

  If !Empty(_clog)
    memowrit("c:\duplicados.txt",_clog)
    commit
    winexec("notepad.exe c:\ErroSerie.txt")
  EndIf


 /*/
   aReturn := { "Zebrado",;      // Tipo do formulario
                        1,;      // Numero de vias
          "Administracao",; // Destinatario
                        1,;      // Formato 1-Comprimido  2-Normal
                        1,;      // Midia  1-Disco  2-Impressora
               'CHECADUP',;      // Porta ou arquivo (1-LPT1...)
                        "",;      // Expressao do filtro
                         1 }      // Ordem (Numero do indice)                                                                        
                         
   cString:=alias()                      
   wnrel:="CHECADUP" 
   Titulo:='Registros duplicados em '+alias()
                 
   cperg:=''
   cdesc1:=cdesc2:=cdesc3:=''
   tamanho:='P'
   
   WnRel := SetPrint( cString, WnRel, cPerg, @Titulo, cDesc1, cDesc2, cDesc3, .F. , "", .T., Tamanho, "", .F. )         
   
   SetDefault( aReturn, cString )
   RptStatus({||_fImprime()},Titulo)
  /*/

endif   

Return

***************************************************
static Function _fImprime
***************************************************

li:=1
SetRegua(len(_vDuplic))
for _nVez:=1 to len(_vDuplic)
    incregua()
    @ li++,02 PSAY _vDuplic[_nVez]
next

if aReturn[5]=1
   Set Device To Screen
   Set Printer To
   dbCommitAll()
   OurSpool( WnRel )
endif   

return

***************************************************
user function _fHelice()
***************************************************
//Retorna um string contendo uma das posicoes da helice

local _vHelice:={"-","\","|","/","-","\","|","/"}         
static _nPosic
if _nPosic==nil.or._nPosic==len(_vHelice) 
   _nPosic:=1
else
   _nPosic++
endif   
return _vHelice[_nPosic]

***************************************************
static function _fTestaCond()
***************************************************
//Testa a condicao de pagamento e exibe resultado

private _cCond:=se4->e4_codigo,_dDataIni:=ddatabase,_nValor:=100
@ 000,000 To 160,280 Dialog oDlg1 Title "Condicoes de pagamento" 

@ 010,015 Say u__fAjTxt("Data de referencia:")
@ 010,075 Get _dDataIni  size 50,8

@ 025,015 Say u__fAjTxt("Valor total:")
@ 025,075 Get _nValor pict "@er 999,999.99"

@ 040,015 Say u__fAjTxt("Condicao:")
@ 040,075 Get _cCond valid !empty(_cCond) f3 "SE4"

@ 055,100 bmpButton type 1 Action _fTestA()
@ 055,040 BmpButton Type 2 action Close(oDlg1)
Activate Dialog oDlg1 Centered
return                                                                                   

***************************************************
static function _fTestA()
***************************************************
local _nVez,_vDiasA:={'D','L','S','Q','F','Z'},;
      _vDiasB:={'Data do Dia','Fora o Dia','Fora Semana','Fora quinzena',;
                'Fora Mes','Fora Dezena'},;
                _vCondLit:={}

if empty(_cCond).or.empty(_nValor).or.empty(_dDataIni).or.;
  !se4->(dbseek(xfilial()+_cCond,.f.))
   msgbox("Desculpe, mas estou sem condicoes de testar essa condicao...")
   return
endif   
_vCondicao:=condicao(_nValor,_cCond,0,_dDataIni)           

for _nVez:=1 to len(_vCondicao)
    aadd(_vCondLit,"Parcela   "+alltrim(str(_nVez))+if(_nVez<10,":       ",":      ")+;
           dtoc(_vCondicao[_nVez][1])+"    "+tran(_vCondicao[_nVez][2],"@er 999,999,999.99"))
next
_cDias:=se4->e4_ddd  
if (_nVez:=ascan(_vDiasA,_cDias))>0
   _cDias:=alltrim(_cDias)+'    ('+_vDiasB[_nVez]+')'
endif
_nVez:=len(_vCondLit)  
@ 000,000 TO 235,515 DIALOG oDlg2 TITLE "Resultado "
@ 010,010 say u__fAjTxt("Condicao: ")
@ 010,060 say u__fAjTxt(se4->e4_codigo)
@ 020,010 say u__fAjTxt("Tipo: ")
@ 020,060 say u__fAjTxt(se4->e4_tipo)
@ 030,010 say u__fAjTxt("Parametro COND: ")
@ 030,060 say u__fAjTxt(alltrim(se4->e4_cond))
@ 040,010 say u__fAjTxt("Descricao: ")
@ 040,060 say u__fAjTxt(alltrim(se4->e4_descri))
@ 050,010 say u__fAjTxt("Parametro Dias: ")
@ 050,060 say u__fAjTxt(_cDias)
@ 060,010 say u__fAjTxt("Data de referencia: ")
@ 060,060 say u__fAjTxt(dtoc(_dDataIni))
@ 070,010 say "Valor a parcelar: "
@ 070,060 say u__fAjTxt(alltrim(tran(_nValor,"@er 999,999,999.99")))
@ 010,140 LISTBOX _nVez ITEMS _vCondLit SIZE 115,80
@ 095,225 BUTTON "_Ok" SIZE 30,15 ACTION Close(oDlg2)             
ACTIVATE DIALOG oDlg2 CENTER
Return                                     

***************************************************
static function _fGeraB2()  
***************************************************

_cPerg2  :="GeraB2"
@ 000,000 TO 150,350 DIALOG oDlg3 TITLE " Gerar saldos em SB2 "
@ 010,015 say u__fajtxt(" Esse programa atribui saldos ") 
@ 025,015 say u__fajtxt(" em quantidade para o SB2 ")
@ 050,020 BMPBUTTON type 1  ACTION msaguarde({||_fGeraB2a()},"Gerando Saldos") 
@ 050,060 BMPBUTTON type 5  ACTION _fGeraB2b()  // verifica Parametros
@ 050,100 BMPBUTTON type 2  ACTION Close(oDlg3) 
ACTIVATE DIALOG oDlg3 CENTER  

Return

Static Function _fGeraB2b()

_sAlias := Alias()
aRegs := {}
i := j := 0

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(_cPerg2,6)

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Almoxarifado","",""        ,"mv_ch1","C",2,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Do Produto  ","",""        ,"mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"03","Ate Produto ","",""        ,"mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"04","Qtde p/ B2_QATU ","",""    ,"mv_ch4","N",12,2,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Ja Existentes","",""       ,"mv_ch5","N",1,0,1,"C","","mv_par05","Sobrepoe","","","","","Ignora","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next

dbSelectArea(_sAlias)
pergunte(_cperg2,.t.)

Return

***************************************************
Static Function _fGeraB2a
***************************************************

pergunte(_cperg2,.f.)
_clocal   := Mv_Par01
_cProdIni := Mv_Par02
_cProdFim := Mv_Par03
_nQAtu    := Mv_Par04                                       
_nExist   := Mv_Par05

if empty (_clocal) // se almoxarifado nao foi informado
   msgbox("O almoxarifado deve ser informado!")
   return  // volta para quem chamou a funcao ou procedure
endif                                

SB1->(dbsetorder(1)) //_filial+_cod
SB2->(dbsetorder(1)) //_filial+_cod+_local
SB1->(dbseek(Xfilial()+alltrim(_cProdIni),.t.)) //se Sx2 for c=compartilhado , retorna branco 2pos. , senao retorna cod. da filial atual
While SB1->(!eof().and.Xfilial()==B1_Filial.and.B1_cod<=_cProdFim)
          _lTemB2:=SB2->(dbseek(Xfilial()+SB1->B1_Cod+_clocal,.f.))
          if !_lTemB2 .or. _nExist<>2 .or. (_nExist==2 .and. SB2->B2_Qatu==0)
                    SB2->(reclock("SB2",!_lTemB2))
                    SB2->B2_FILIAL:=XFILIAL("SB2")
                    SB2->B2_LOCAL:=_cLocal
                    SB2->B2_COD:=SB1->B1_COD 
                    SB2->B2_QATU:=_nQatu
                    SB2->(msunlock()) 
                    msproctxt("Gerando saldo do produto "+SB1->B1_COD)
          endif     
          SB1->(dbskip())
enddo

Alert("SB2 - Atualizado com Sucesso !!!")
return

***************************************************
static function _fGeraB9()  
***************************************************
_cPerg2  :="GeraB9"
@ 000,000 TO 150,350 DIALOG oDlg3 TITLE " Gerar saldos em SB9 "
@ 010,015 say u__fajtxt(" Esse programa atribui saldos ") 
@ 025,015 say u__fajtxt(" em quantidade para o SB9 ")
@ 050,020 BMPBUTTON type 1  ACTION msaguarde({||_fGeraB9a()},"Gerando Saldos") 
@ 050,060 BMPBUTTON type 5  ACTION _fGeraB9b()  // Parametros
@ 050,100 BMPBUTTON type 2  ACTION Close(oDlg3) 
ACTIVATE DIALOG oDlg3 CENTER  

Static Function _fGeraB9b()
   ssAlias  := Alias()
   _cPerg2       := PADR(_cPerg2,len(sx1->x1_grupo)) //acrescenta espacos em branco do lado direito de acordo com o tamanho do campo X1_grupo
   aRegs := {}   //cria vetor em branco
   dbSelectArea("SX1")
   dbSetOrder(1)
             *   1    2            3                4     5   6  7 8  9  10   11        12    13 14    15    16 17 18 19 20 21 22 23 24 25  26
             *+---------------------------------------------------------------------------------------------------------------------------------+
             *¦G    ¦ O  ¦ PERGUNT              ¦V       ¦T  ¦T ¦D¦P¦ G ¦V ¦V         ¦ D    ¦C ¦V ¦D       ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦V ¦D ¦C ¦F    ¦
             *¦ R   ¦ R  ¦                      ¦ A      ¦ I ¦A ¦E¦R¦ S ¦A ¦ A        ¦  E   ¦N ¦A ¦ E      ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦A ¦E ¦N ¦3    ¦
             *¦  U  ¦ D  ¦                      ¦  R     ¦  P¦MA¦C¦E¦ C ¦ L¦  R       ¦   F  ¦ T¦ R¦  F     ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦R ¦F ¦ T¦     ¦
             *¦   P ¦ E  ¦                      ¦   I    ¦  O¦NH¦ ¦S¦   ¦ I¦   0      ¦    0 ¦ 0¦ 0¦   0    ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦0 ¦0 ¦ 0¦     ¦
             *¦    O¦ M  ¦                      ¦    AVL ¦   ¦ O¦ ¦E¦   ¦ D¦    1     ¦    1 ¦ 1¦ 2¦    2   ¦ 2¦3 ¦3 ¦ 3¦4 ¦4 ¦ 4¦5 ¦5 ¦ 5¦     ¦
   AADD(aRegs,{_cPerg2,"01","Almoxarifado       ?","","","mv_ch1","C",02,0,0,"G","","mv_par01",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"02","Produto De         :","","","mv_ch2","C",15,0,0,"G","","mv_par02",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"03","Produto Ate        :","","","mv_ch3","C",15,0,0,"G","","mv_par03",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"04","Qtde p/ B2_QINI    :","","","mv_ch4","N",12,2,0,"G","","mv_par04",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"05","Data p/ B9_DATA    :","","","mv_ch5","D",08,2,0,"G","","mv_par05",""  ,"","",""      ,"","","","","","","","","","",""})
   AADD(aRegs,{_cPerg2,"06","Ja Existentes      :","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sobrepoe"  ,"","","Ignora"      ,"","","","","","","","","","",""})
   
   For i := 1 to Len(aRegs)
     If !DbSeek(_cPerg2+aRegs[i,2])
       RecLock("SX1",.T.)
       For j := 1 to FCount()
         FieldPut(j,aRegs[i,j])
       Next
       MsUnlock()
     Endif
   Next
   DbSelectArea(ssAlias)
   pergunte(_cperg2,.t.)
Return       

***************************************************
Static Function _fGeraB9a
***************************************************

pergunte(_cperg2,.f.)
_clocal   := Mv_Par01
_cProdIni := Mv_Par02
_cProdFim := Mv_Par03
_nQini    := Mv_Par04
_dData    := mv_par05
_nExist   := Mv_Par06

if empty (_clocal) // se almoxarifado nao foi informado
          msgbox("O almoxarifado deve ser informado!")
          return  // volta para quem chamou a funcao ou procedure
endif                                

SB1->(dbsetorder(1)) //_filial+_cod
SB9->(dbsetorder(1)) //_filial+_cod+_local+DTOS(B9_DATA)
SB1->(dbseek(Xfilial()+alltrim(_cProdIni),.t.)) 
While SB1->(!eof().and.Xfilial()==B1_Filial.and.B1_cod<=_cProdFim)
          _lTemB9:=SB9->(dbseek(Xfilial()+SB1->B1_Cod+_clocal+dtos(_dData),.f.))
          if !_lTemB9 .or. _nExist<>2 .or. (_nExist==2 .and. SB9->B9_Qini==0)
                    SB9->(reclock("SB9",!_lTemB9))
                    SB9->B9_FILIAL:=XFILIAL("SB9")
                    SB9->B9_LOCAL:=_cLocal
                    SB9->B9_COD:=SB1->B1_COD 
                    SB9->B9_QINI:=_nQini
                    SB9->B9_data:=_dData
                    SB9->(msunlock()) 
                    msproctxt("Gerando saldo do produto "+SB1->B1_COD)
          endif     
          SB1->(dbskip())
enddo
return

***************************************************
Static Function _fQtdRegs()
***************************************************
Private _cTexto    := ""
Private _nTabela   := 0
Private _aDropTab  := {}
Private	_xDriver   := ""


If _lChTop .and. _lChCodeBase
  Alert("Selecione Apenas um tipo de base de dados !!!")
  Return
EndIf

If !_lChTop .and. !_lChCodeBase
  Alert("Selecione um tipo de base de dados !!!")
  Return
EndIf

If _lChTop .and. !_lChCodeBase
  _xDriver   := "TOPCONN"
 Else
  _xDriver   := "DBFCDX"
EndIf


dbUseArea(.t.,,"SX2"+SM0->M0_CODIGO+"0.dbf","SX2TRB",.t.,.t.)
dbSetIndex("SX2"+SM0->M0_CODIGO+"0")   
dbSelectArea( "SX2TRB" )
dbSetOrder(1)

If !Empty(_cTabela)
   dbSelectArea( "SX2TRB" )
   dbSetOrder(1)
   If !dbseek(_cTabela)
    Alert("Tabela nao Existe !!!")
    dbSelectArea( "SX2TRB" )
    DbClosearea()
    Return
   Else
    MsAguarde( { || _fOkProc(_cTabela) }, "Verificando Tabela...", "Iniciando processamento...", .T. )
  EndIf
 Else
    MsAguarde( { || _fOkProc(_cTabela) }, "Verificando Tabelas...", "Iniciando processamento...", .T. )
EndIf

If _lChDrop .and. len(_aDropTab) > 0
  _fDropTab(_aDropTab)
EndIf

If !Empty(_cTexto)
 _cTexto += ""+chr(13)+chr(10)
 _ctexto +=("Total de Tabelas com Registros -> "+transform(_nTabela,"@E 9,999,999"))+chr(13)+chr(10)
 memowrit("c:\Arquivos.txt",_cTexto)
 commit
 winexec("notepad.exe c:\Arquivos.txt")
EndIf

_nTabela  := 0
_aDropTab := {}

Return

***************************************************
Static Function _fOkProc(_cTabela)
***************************************************
_nRecno    := 0
_nRecnoSX2 := 0
_cTexto    := ""
_nTabela   := 0
_aDropTab  := {}
_aInd      := {}


If Empty(_cTabela)
  dbSelectArea("SX2TRB") 
  _nRecnoSX2 := reccount()
  dbGoTop()
  While !eof()
   _nRecno ++
   If _fMSEXIST(AllTrim(SX2TRB->X2_ARQUIVO),AllTrim(SX2TRB->X2_PATH))
    If _lChInd 
      _fDelInd(sx2trb->x2_chave,alltrim(sx2trb->x2_arquivo),sx2trb->x2_nome)
    ElseIf _lChDrop
       dbUseArea(.t.,_xDriver,AllTrim(SX2TRB->X2_ARQUIVO),SX2TRB->X2_CHAVE+"TRB",.t.,.t.)
       dbSelectArea( sx2trb->x2_chave+"TRB" )
       dbGoTop()
       _nRecno := lastrec()
       If _nRecno > 0
         //MsProcTxt("A Tabela "+AllTrim(sx2trb->x2_arquivo)+" Contem "+transform(_nRecno,"@E 9,999,999")+" Registros ")
         _ctexto +=("Tabela "+AllTrim(sx2trb->x2_arquivo)+"-"+sx2trb->x2_nome+" Contem "+transform(_nRecno,"@E 9,999,999")+" Registros ")+chr(13)+chr(10)
         _nTabela ++
        Else
         If _lChDrop
          aadd(_aDropTab,{AllTrim(sx2trb->x2_arquivo),Alltrim(sx2trb->x2_nome),.t.,Alltrim(sx2trb->x2_path)})
         EndIf
       EndIf
       DbClosearea()
      _nRecno := 0
    ElseIf _lChPack
      Alert("Em Desenvolvimento")
    Endif
   EndIf
   dbSelectArea("SX2TRB") 
   dbskip()
  End
  If _lChInd 
   If len(_aInd) > 0
     _fDropInd(_aInd,"","Todas")
   EndIf
  EndIf
Else
  dbSelectArea("SX2TRB") 
  dbSetOrder(1)
  dbseek(_cTabela)
  If _fMSEXIST(AllTrim(SX2TRB->X2_ARQUIVO),AllTrim(SX2TRB->X2_PATH))
    If _lChInd 
      _fDelInd(sx2trb->x2_chave,alltrim(sx2trb->x2_arquivo),sx2trb->x2_nome)
      If len(_aInd) > 0
        _fDropInd(_aInd,alltrim(sx2trb->x2_arquivo),sx2trb->x2_nome)
       Else
        Alert("Nao ha Indices para esta tabela -> "+alltrim(sx2trb->x2_arquivo))
      EndIf
    EndIf
    If _lChDrop
      dbUseArea(.t.,_xDriver,SX2TRB->X2_ARQUIVO,"TRB",.t.,.t.)
      dbSelectArea( "TRB" )
      dbGoTop()
      _nRecno := lastrec()
      Alert("A Tabela "+AllTrim(sx2trb->x2_arquivo)+" Contem "+transform(_nRecno,"@E 9,999,999")+" Registros ")
      DbClosearea()
      _nRecno := 0
    EndIf
    If _lChpack
      Alert("Em Desenvolvimento")
    Endif
  Else
    Alert("A Tabela "+AllTrim(sx2trb->x2_arquivo)+" nao existe na base de dados !!!") 
  EndIf
EndIf

dbSelectArea( "SX2TRB" )
DbClosearea()

Return

******************************************************************************
Static Function _fMsExist(_cArquivo,_cPath)
******************************************************************************
Local _lOk    := .f.
Local _cQuery := ""
Local _aArea  := getarea()

If _lChTop
  _cQuery := "Select name From sysobjects"
  _cQuery += " Where type = 'U' and name = '"+_cArquivo+"' "
  dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), 'EXPROC', .F., .T.)

  If !eof()
   _lOk := .t.
  EndIf

  EXPROC->(dbCloseArea())
Else

  IF File(cRootPath+_cPath+_cArquivo+".DBF")
   _lOk := .t.
  EndIf

EndIf

RestArea(_aArea)

Return(_lOk)

******************************************************************************
Static Function _fDropTab(_aDTab)
******************************************************************************

Local aEstou    := GetArea()
Local cCadastro := OemToAnsi("Tabelas sem Registros ") 
Local _aDrop    := {}
Local cVarQ   	:= "  "
Local oDlgTab
Local oTabelas
Local oOk	  	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo	  	:= LoadBitmap( GetResources(), "LBNO" )


DEFINE MSDIALOG oDlgTab TITLE cCadastro From 12,1.5 To 25.6,79.5 OF oMainWnd

	@ 0.5,0.5 TO 5.4, 38.3 OF oDlgTab

    @ 1.0,1.0 LISTBOX oTabelas VAR cVarQ Fields;
	HEADER "", OemToAnsi("Tabela"),;
		       OemToAnsi("Descricao");
	COLSIZES 12,GetTextWidth(0,"BBBBBBB"),;
	            GetTextWidth(0,"BBBBBBBBBBBB");
	SIZE 293,54.5 ON DBLCLICK (_aDTab:=_fTroca(oTabelas:nAt,_aDTab),oTabelas:Refresh()) NOSCROLL
	oTabelas:SetArray(_aDTab)
	oTabelas:bLine := { || {If(_aDTab[oTabelas:nAt,3],oOk,oNo),;
	                          _aDTab[oTabelas:nAt,1],;
	                          _aDTab[oTabelas:nAt,2]}}
	DEFINE SBUTTON FROM 80,264.6 TYPE 1 ACTION oDlgTab:End() ENABLE OF oDlgTab

ACTIVATE MSDIALOG oDlgTab CENTERED

For Wq:= 1 to Len(_aDTab)
	If _aDTab[Wq,3]
      aAdd(_aDrop,{_aDTab[Wq,4],_aDTab[Wq,1]})
	Endif
Next

If len(_aDrop) > 0
  For I := 1 to len(_aDrop)
    If _lChTop
      _cSqlQuery := ""
      _cSqlQuery := " DROP TABLE "+_aDrop[I,2]+""
      TcSqlExec( _cSqlQuery )
     Else
      Ferase(cRootPath+_aDrop[I,1]+_aDrop[I,2]+".DBF")    
    EndIf
  Next
EndIf

RestArea(aEstou)

DeleteObject(oOk)
DeleteObject(oNo)	

Return

****************************************************************************
Static Function _fTroca(nIt,aArray)
****************************************************************************

aArray[nIt,3] := !aArray[nIt,3]

Return aArray

****************************************************************************
Static Function _fDelInd(_cAlias,_cTab,_cNome)
****************************************************************************
Local _aArea  := GetArea()
Local _cQuery := ""

dbUseArea(.t.,,"SIX"+SM0->M0_CODIGO+"0.dbf","SINTRB",.t.,.t.)
dbSetIndex("SIX"+SM0->M0_CODIGO+"0")     
dbSelectArea( "SINTRB" )
dbSetOrder(1)

If _lChTop
  _cQuery := "Select name From sysindexes"
  _cQuery += " Where substring(name,1,3) = '"+_cAlias+"' "
  _cQuery += " and substring(name,7,1) <> '_'"
  dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), 'INPROC', .F., .T.)
  dbselectarea("INPROC")
  dbGotop()
  While !Eof()
    dbSelectArea( "SINTRB" )
    dbSetOrder(1)
    dbseek(_cAlias+substr(inproc->name,7,1))
    aadd(_aInd,{inproc->name,AllTrim(sintrb->descricao),.t.})
    dbselectarea("INPROC") 
    dbskip()
  End
  dbselectarea("INPROC") 
  dbclosearea()
EndIf

dbSelectArea( "SINTRB" )
dbclosearea()

RestArea(_aArea)

Return   


******************************************************************************
Static Function _fDropInd(_aDInd,_cTab,_cNome)
******************************************************************************

Local aEstou    := GetArea()
Local cCadastro := OemToAnsi("Indices da Tabela "+_cTab+" - "+_cNome) 
Local _aDrop    := {}
Local cVarQ   	:= "  "
Local oDlgTab
Local oTabelas
Local oOk	  	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo	  	:= LoadBitmap( GetResources(), "LBNO" )


DEFINE MSDIALOG oDlgTab TITLE cCadastro From 12,1.5 To 25.6,79.5 OF oMainWnd

	@ 0.5,0.5 TO 5.4, 38.3 OF oDlgTab

    @ 1.0,1.0 LISTBOX oTabelas VAR cVarQ Fields;
	HEADER "", OemToAnsi("Indice"),;
		       OemToAnsi("Descricao");
	COLSIZES 12,GetTextWidth(0,"BBBBBBB"),;
	            GetTextWidth(0,"BBBBBBBBBBBB");
	SIZE 293,54.5 ON DBLCLICK (_aDInd:=_fTroca(oTabelas:nAt,_aDInd),oTabelas:Refresh()) NOSCROLL
	oTabelas:SetArray(_aDInd)
	oTabelas:bLine := { || {If(_aDInd[oTabelas:nAt,3],oOk,oNo),;
	                            _aDInd[oTabelas:nAt,1],;
	                            _aDInd[oTabelas:nAt,2]}}
	DEFINE SBUTTON FROM 80,264.6 TYPE 1 ACTION oDlgTab:End() ENABLE OF oDlgTab

ACTIVATE MSDIALOG oDlgTab CENTERED

For Wq:= 1 to Len(_aDInd)
	If _aDInd[Wq,3]
      aAdd(_aDrop,{_aDInd[Wq,1],Left(_aDInd[Wq,1],6)})
	Endif
Next

If len(_aDrop) > 0
  For I := 1 to len(_aDrop)
    If _lChTop
      _cSqlQuery := ""
      _cSqlQuery := " DROP INDEX "+_aDrop[I,2]+"."+_aDrop[I,1]+""
      TcSqlExec( _cSqlQuery )
     Else
      //Ferase(cRootPath+_aDrop[I,1]+_aDrop[I,2]+".DBF")    
    EndIf
  Next
   Alert("Todos os Indices foram exluidos com Exito !!!")
EndIf

RestArea(aEstou)

DeleteObject(oOk)
DeleteObject(oNo)	

Return
