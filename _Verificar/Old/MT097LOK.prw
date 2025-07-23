#include "rwmake.ch" 
#include "protheus.ch" 

User Function MT097LOK()                                                 

Local aArea        := GetArea()
Local lOk          := .t.
Local aAreaSC7     := sc7->(GetArea())
Local _nOpc        := 0
Local _aH          := {}


Private _cTitulo      := "Verificacao de Precos"
Private _aAltera      := {}
Private _oDlg, _oBrw
Private nOpc          := 0
Private	aHeader	      := {}
Private	aCols	      := {}
Private lRefresh      := .T.

If SCR->CR_TIPO = "NF"
 RestArea( aAreaSC7 )
 RestArea( aArea )  
 Return( lOk )
EndIf

aCols	 := _fMonta()

If !empty(aCols)


 Define MsDialog _oDlg From 000, 000 To 400, 720 Title OemToAnsi( _cTitulo ) Pixel


	DEFINE SBUTTON FROM 185,005 TYPE  1 ACTION ( _nOpc := 1, _oDlg:End() ) ENABLE OF _oDlg
	//DEFINE SBUTTON FROM 185,043 TYPE  2 ACTION ( _oDlg:End() ) ENABLE OF _oDlg

	n := 1
	AADD(_aH,{"Cod.Produto"     ,"DA1_CODPRO","@!",15,0,".f.","","C",""})
	AADD(_aH,{"Desc.Produto"    ,"DA1_DESC"  ,"@!",30,0,".f.","","C",""})
	AADD(_aH,{"Pr   Compra "    ,"DA1_PRCATU","@E 999,999.99"  ,10,2,".f.","","N",""})
	AADD(_aH,{"Ult. Compra "    ,"DA1_PRCANT","@E 999,999.99"  ,10,2,".f.","","N",""})
	AADD(_aH,{"Variacao %"      ,"DA1_MARG"  ,"@E 9999.9999"   ,9,4 ,".f.","","N",""})		
	AADD(_aH,{"Data Compra"     ,"DA1_UCOM"  ,"@!",8,0,".f.","","D",""})

	aHeader	 := aClone( _aH )
	_oBrw    := MsGetDados():New(005,002,180,355,3,"AllwaysTrue()","AllwaysTrue()",,.f.,_aAltera,,.f.,,,,,,_oDlg)
	_oBrw:oBrowse:lDisablePaint := .F.
	_oBrw:nMax := Len( aCols )
	_oBrw:oBrowse:Refresh()

 Activate MsDialog _oDlg Centered 
	
 If _nOpc == 1

 Endif

EndIf
	

/* Retorna Ambiente */
RestArea( aAreaSC7 )
RestArea( aArea )

Return( lOk )


Static Function _fMonta()

Local _ac     := {}

dbSelectArea("SC7")
dbSetOrder(1)
If DbSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))
   While !eof() .and. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
      dbSelectArea("SB1")
      dbSetOrder(1)
      If dbseek(xfilial("SB1")+SC7->C7_PRODUTO)
         //If sc7->c7_preco > sb1->b1_uprc .and. sb1->b1_uprc <> 0
            AADD(_aC,Array(6))
            _aC[Len(_aC),1] := SC7->C7_PRODUTO
            _aC[Len(_aC),2] := SB1->B1_DESC
            _aC[Len(_aC),3] := SC7->C7_PRECO
            _aC[Len(_aC),4] := SB1->B1_UPRC
            _aC[Len(_aC),5] := Iif(sb1->b1_uprc <> 0,((SC7->C7_PRECO-SB1->B1_UPRC)/SB1->B1_UPRC)*100,100)
            _aC[Len(_aC),6] := SB1->B1_UCOM
         //EndIf
      Endif
  	  dbSelectArea( "SC7" )  
	  dbskip()
   End
EndIf

Return(_ac)