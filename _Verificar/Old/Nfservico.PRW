#include "rwmake.ch"  

#IFNDEF WINDOWS
   #DEFINE PSAY SAY
#ENDIF

User Function Nfservico()   

SetPrvt("CBTXT,CBCONT,NORDEM,ALFA,Z,M")
SetPrvt("XCOD_CLI,XNOME_CLI,XEND_CLI,XBAIRRO,XCEP_CLI,XCOB_CLI")
SetPrvt("XREC_CLI,XMUN_CLI,XEST_CLI,XCGC_CLI,XINSC_CLI,XTRAN_CLI")
SetPrvt("XSUFRAMA,XCALCSUF,XNOME_TRANSP,XEND_TRANSP,XMUN_TRANSP,XEST_TRANSP")
SetPrvt("XVIA_TRANSP,TAMANHO,LIMITE,TITULO,CDESC1,CDESC2")
SetPrvt("CDESC3,CNATUREZA,ARETURN,NOMEPROG,CPERG,NLASTKEY")
SetPrvt("LCONTINUA,WNREL,CSTRING,XNUM_NF,XSERIE,XEMISSAO")
SetPrvt("XTOT_FAT,XLOJA,XICMS_RET,XVALOR_MERC,XNUM_DUPLIC,XCOND_PAG")
SetPrvt("XPBRUTO,XPLIQUI,XTIPO,XESPECIE,XVOLUME,CPEDATU")
SetPrvt("CITEMATU,XPED_VEND,XITEM_PED,XPREF_DV,XICMS,XCOD_PRO")
SetPrvt("XQTD_PRO,XPRE_UNI,XPRE_TAB,XDESC,XVAL_MERC,XTES")
SetPrvt("XCF,XICMSOL,XPESO_PRO,XPESO_UNIT,XDESCRICAO,XUNID_PRO")
SetPrvt("XMEN_TRIB,XMEN_POS,XISS,XTIPO_PRO,XLUCRO,XCLFISCAL")
SetPrvt("I,XPED,XCLIENTE,XTIPO_CLI,XCOD_MENS,XMENSAGEM")
SetPrvt("XCONDPAG,XPESOL,XCOD_VEND,XDESC_NF,XDESC_PAG,XPED_CLI")
SetPrvt("XDESC_PRO,J,XTEL_TRANSP,XPARC_DUP,XVENC_DUP,XVALOR_DUP")
SetPrvt("XDUPLICATAS,WPESQ,XNATUREZA,NOPC,CCOR,NTAMDET")
SetPrvt("WQTD2,WVALMERC,WUNIT,WCONTA,WUNID,WDESC")
SetPrvt("XPRODUTO,LI,NTAMOBS,SPED,L,X")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³          ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Nota Fiscal de Saida de Servico                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Ambientais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01             // Da Nota Fiscal                       ³
//³ mv_par02             // Ate a Nota Fiscal                    ³
//³ mv_par03             // Da Serie                             ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CbTxt:=""
CbCont:=""
nOrdem :=0
Alfa := 0
Z:=0
M:=0
xCOD_CLI := " " 
xNOME_CLI:= " " 
xEND_CLI := " " 
xBAIRRO  := " " 
xCEP_CLI := " " 
xCOB_CLI := " " 
xREC_CLI := " " 
xMUN_CLI := " " 
xEST_CLI := " " 
xCGC_CLI := " " 
xINSC_CLI:= " " 
xTRAN_CLI:= " " 
xSUFRAMA := " " 
xCALCSUF := " " 
	    
xNOME_TRANSP := " "
xEND_TRANSP  := " "
xMUN_TRANSP  := " "
xEST_TRANSP  := " "
xVIA_TRANSP  := " "


tamanho:="G"
limite :=220
titulo :=PADC("Nota Fiscal - Cavanna",74)
cDesc1 :=PADC("Este programa ira emitir a Nota Fiscal de Servico",74)
cDesc2 :=""
cDesc3 :="" 
cNatureza:="" 
aReturn := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
nomeprog:="nfservico" 
cPerg:="NFSIGW"
nLastKey:= 0 
lContinua := .T.
wnrel    := "NFSER"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas, busca o padrao da Nfiscal           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cPerg,.F.)               // Pergunta no SX1

cString:="SF2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel:=SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.T.)

If nLastKey == 27
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Posicao do Formulario na Impressora                 ³          
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

VerImp()       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do Processamento da Nota Fiscal                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RptDetail()})

Return

Static Function RptDetail()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa  regua de impressao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Val(mv_par02)-Val(mv_par01))

//* ... Seleciona Impressora ... *
set device to print
setprc(0,0)

//@ 0,0 PSAY CHR(27)+"C"+CHR(66) && ... Determina Tamanho do Papel ... *


dbSelectArea("SF2")                // * Cabecalho da Nota Fiscal Saida
dbSetOrder(1)
dbSeek(xFilial()+mv_par01+mv_par03,.t.)
   While !eof() .and. SF2->F2_DOC    <= mv_par02 .and. lContinua

      If SF2->F2_SERIE #mv_par03    // Se a Serie do Arquivo for Diferente
    	 DbSkip()                        // do Parametro Informado !!!
	     Loop
      Endif

	#IFNDEF WINDOWS
	      IF LastKey()==286
		    @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
		    lContinua := .F.
		    Exit
	      Endif
	#ELSE
	      IF lAbortPrint
		   @ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
		   lContinua := .F.
		   Exit
	      Endif
	#ENDIF

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Inicio de Levantamento dos Dados da Nota Fiscal              ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      // * Cabecalho da Nota Fiscal

      xNUM_NF     :=SF2->F2_DOC             // Numero
      xSERIE      :=SF2->F2_SERIE           // Serie
      xEMISSAO    :=SF2->F2_EMISSAO         // Data de Emissao
      xTOT_FAT    :=SF2->F2_VALFAT          // Valor Total da Fatura
      if xTOT_FAT == 0
    	 xTOT_FAT := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
      endif

      xLOJA       :=SF2->F2_LOJA            // Loja do Cliente
      xICMS_RET   :=SF2->F2_ICMSRET         // Valor  do ICMS Retido
      xVALOR_MERC :=SF2->F2_VALFAT         // Valor  da Mercadoria
      xNUM_DUPLIC :=SF2->F2_DUPL            // Numero da Duplicata
      xCOND_PAG   :=SF2->F2_COND            // Condicao de Pagamento
      xPBRUTO     :=SF2->F2_PBRUTO          // Peso Bruto
      xPLIQUI     :=SF2->F2_PLIQUI          // Peso Liquido
      xTIPO       :=SF2->F2_TIPO            // Tipo do Cliente
      xESPECIE    :=SF2->F2_ESPECI1         // Especie 1 no Pedido
      xVOLUME     :=SF2->F2_VOLUME1         // Volume 1 no Pedido
      xBASEISS    :=SF2->F2_BASEISS
      xVALISS     :=SF2->F2_VALISS  
      xVALINSS    :=SF2->F2_VALINSS  
      
      dbSelectArea("SD2")                   // * Itens de Venda da N.F.
      dbSetOrder(3)
      dbSeek(xFilial()+xNUM_NF+xSERIE)

      cPedAtu  := SD2->D2_PEDIDO
      cItemAtu := SD2->D2_ITEMPV

      xPED_VEND:={}                         // Numero do Pedido de Venda
      xITEM_PED:={}                         // Numero do Item do Pedido de Venda
      xPREF_DV :={}                         // Serie  quando houver devolucao
      xICMS    :={}                         // Porcentagem do ICMS
      xCOD_PRO :={}                         // Codigo  do Produto
      xQTD_PRO :={}                         // Peso/Quantidade do Produto
      xPRE_UNI :={}                         // Preco Unitario de Venda
      xPRE_TAB :={}                         // Preco Unitario de Tabela
      xDESC    :={}                         // Desconto por Item
      xVAL_MERC:={}                         // Valor da Mercadoria
      xTES     :={}                         // TES
      xCF      :={}                         // Classificacao quanto natureza da Operacao
      xICMSOL  :={}                         // Base do ICMS Solidario

      while !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
	    If SD2->D2_SERIE #mv_par03        // Se a Serie do Arquivo for Diferente
		 DbSkip()                   // do Parametro Informado !!!
		 Loop
	    Endif
	    AADD(xPED_VEND ,SD2->D2_PEDIDO)
	    AADD(xITEM_PED ,SD2->D2_ITEMPV)
	    AADD(xPREF_DV  ,SD2->D2_SERIORI)
	    AADD(xICMS     ,IIf(Empty(SD2->D2_PICM),0,SD2->D2_PICM))
	    AADD(xCOD_PRO  ,SD2->D2_COD)
	    AADD(xQTD_PRO  ,SD2->D2_QUANT)     // Guarda as quant. da NF
	    AADD(xPRE_UNI  ,SD2->D2_PRCVEN)
	    AADD(xPRE_TAB  ,SD2->D2_PRUNIT)
	    AADD(xDESC     ,SD2->D2_DESC)
	    AADD(xVAL_MERC ,SD2->D2_TOTAL)
	    AADD(xTES      ,SD2->D2_TES)
	    AADD(xCF       ,SD2->D2_CF)
        dbskip()
      End

      xPESO_PRO:={}                           // Peso Liquido
      xPESO_UNIT :={}                         // Peso Unitario do Produto
      xDESCRICAO :={}                         // Descricao do Produto
      xUNID_PRO:={}                           // Unidade do Produto
      xMEN_TRIB:={}                           // Mensagens de Tributacao
      xMEN_POS :={}                           // Mensagem da Posicao IPI
      xISS     :={}                           // Aliquota de ISS
      xTIPO_PRO:={}                           // Tipo do Produto
      xLUCRO   :={}                           // Margem de Lucro p/ ICMS Solidario
      xCLFISCAL   :={}
      I:=1

      For I:=1 to Len(xCOD_PRO)

	  dbSelectArea("SB1")                     // * Desc. Generica do Produto
	  dbSetOrder(1)
	  dbSeek(xFilial()+xCOD_PRO[I])
	  AADD(xUNID_PRO ,SB1->B1_UM)
	  AADD(xDESCRICAO ,SB1->B1_DESC)

	  If SB1->B1_ALIQISS > 0
	     AADD(xISS ,SB1->B1_ALIQISS)
	  Endif
	  AADD(xTIPO_PRO ,SB1->B1_TIPO)
	  AADD(xLUCRO    ,SB1->B1_PICMRET)
      Next

      dbSelectArea("SC5")                            // * Pedidos de Venda
      dbSetOrder(1)
      xPED        := {}

      For I:=1 to Len(xPED_VEND)

	   dbSeek(xFilial()+xPED_VEND[I])

	   If ASCAN(xPED,xPED_VEND[I])==0
	    dbSeek(xFilial()+xPED_VEND[I])
	    xCLIENTE    :=SC5->C5_CLIENTE            // Codigo do Cliente
	    xTIPO_CLI   :=SC5->C5_TIPOCLI            // Tipo de Cliente
	    xCOD_MENS   :=SC5->C5_MENPAD             // Codigo da Mensagem Padrao
	    xMENSAGEM   :=SC5->C5_MENNOTA            // Mensagem para a Nota Fiscal
	    xCONDPAG    :=SC5->C5_CONDPAG            // Condicao de Pagamento
        xPESOL      :=SC5->C5_PESOL              // Peso Liquido do Pedido
	    xCOD_VEND:= {SC5->C5_VEND1,;             // Codigo do Vendedor 1
			 SC5->C5_VEND2,;             // Codigo do Vendedor 2
			 SC5->C5_VEND3,;             // Codigo do Vendedor 3
			 SC5->C5_VEND4,;             // Codigo do Vendedor 4
			 SC5->C5_VEND5}              // Codigo do Vendedor 5
	    xDESC_NF := {SC5->C5_DESC1,;             // Desconto Global 1
			 SC5->C5_DESC2,;             // Desconto Global 2
			 SC5->C5_DESC3,;             // Desconto Global 3
			 SC5->C5_DESC4}              // Desconto Global 4
	    AADD(xPED,xPED_VEND[I])
	    Endif
      Next

      dbSelectArea("SE4")                    // Condicao de Pagamento
      dbSetOrder(1)
      dbSeek(xFilial("SE4")+xCONDPAG)
      xDESC_PAG := SE4->E4_DESCRI

      dbSelectArea("SC6")                    // * Itens de Pedido de Venda
      dbSetOrder(1)
      xPED_CLI :={}                          // Numero de Pedido
      xDESC_PRO:={}                          // Descricao do produto
      J:=Len(xPED_VEND)
      For I:=1 to J
	    dbSeek(xFilial()+xPED_VEND[I]+xITEM_PED[I])
	    AADD(xPED_CLI ,SC6->C6_PEDCLI)
	    AADD(xDESC_PRO,SC6->C6_DESCRI)
      Next

      If xTIPO=='N' .OR. xTIPO=='C' .OR. xTIPO=='P' .OR. xTIPO=='I' .OR. xTIPO=='S' .OR. xTIPO=='T' .OR. xTIPO=='O'

	    dbSelectArea("SA1")                // * Cadastro de Clientes
	    dbSetOrder(1)
	    dbSeek(xFilial()+xCLIENTE+xLOJA)
	    xCOD_CLI :=SA1->A1_COD             // Codigo do Cliente
	    xNOME_CLI:=SA1->A1_NOME            // Nome
	    xEND_CLI :=SA1->A1_END             // Endereco
	    xBAIRRO  :=SA1->A1_BAIRRO          // Bairro
	    xCEP_CLI :=SA1->A1_CEP             // CEP
	    xCOB_CLI :=SA1->A1_ENDCOB          // Endereco de Cobranca
	    xREC_CLI :=SA1->A1_ENDENT          // Endereco de Entrega
	    xMUN_CLI :=SA1->A1_MUN             // Municipio
	    xEST_CLI :=SA1->A1_EST             // Estado
	    xCGC_CLI :=SA1->A1_CGC             // CGC
	    xINSC_CLI:=SA1->A1_INSCR           // Inscricao estadual
	    xTRAN_CLI:=SA1->A1_TRANSP          // Transportadora
	    xSUFRAMA :=SA1->A1_SUFRAMA            // Codigo Suframa
	    xCALCSUF :=SA1->A1_CALCSUF            // Calcula Suframa
      endif

      dbSelectArea("SA4")                   // * Transportadoras
      dbSetOrder(1)
      dbSeek(xFilial()+SF2->F2_TRANSP)
      xNOME_TRANSP :=SA4->A4_NOME           // Nome Transportadora
      xEND_TRANSP  :=SA4->A4_END            // Endereco
      xMUN_TRANSP  :=SA4->A4_MUN            // Municipio
      xEST_TRANSP  :=SA4->A4_EST            // Estado
      xVIA_TRANSP  :=SA4->A4_VIA            // Via de Transporte
      xTEL_TRANSP  :=SA4->A4_TEL            // Telefone
      

      dbSelectArea("SE1")                   // * Contas a Receber
      dbSetOrder(1)
      xPARC_DUP  :={}                       // Parcela
      xVENC_DUP  :={}                       // Vencimento
      xVALOR_DUP :={}                       // Valor
      xDUPLICATAS:=IIF(dbSeek(xFilial()+xSERIE+xNUM_DUPLIC,.T.),.T.,.F.) // Flag p/Impressao de Duplicatas

      while !eof() .and. SE1->E1_NUM==xNUM_DUPLIC .and. xDUPLICATAS==.T.
         If !("NF" $ SE1->E1_TIPO)
            dbSkip()
            Loop
         Endif
         AADD(xPARC_DUP ,SE1->E1_PARCELA)
         AADD(xVENC_DUP ,SE1->E1_VENCTO)
         AADD(xVALOR_DUP,SE1->E1_VALOR)
         dbSkip()
      EndDo

      dbSelectArea("SF4")                   // * Tipos de Entrada e Saida
      DbSetOrder(1)
      dbSeek(xFilial()+xTES[1])
      xNATUREZA:=SF4->F4_TEXTO              // Natureza da Operacao

      //* ... Imprime Cabecalho da Nota ... *
      Imprime()

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Termino da Impressao da Nota Fiscal                          ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      IncRegua()                    // Termometro de Impressao

      dbSelectArea("SF2")     
      dbSkip()                      // passa para a proxima Nota Fiscal

   EndDo
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fechamento do Programa da Nota Fiscal                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SF2")
Retindex("SF2")
dbSelectArea("SD2")
Retindex("SD2")
Set Device To Screen

If aReturn[5] == 1
   Set Printer TO
   dbcommitAll()
   ourspool(wnrel)
Endif

MS_FLUSH()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VERIMP   ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica posicionamento de papel na Impressora             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VerImp()

If aReturn[5]==2

   nOpc       := 1
   
   While .T.

      SetPrc(0,0)
      dbCommitAll()

      IF MsgYesNo("Fomulario esta posicionado ? ")
	 	 nOpc := 1
	   ElseIF MsgYesNo("Tenta Novamente ? ")
		 nOpc := 2
	   Else
		nOpc := 3
	  Endif

      Do Case
	    Case nOpc==1
	      lContinua:=.T.
	      Exit
	    Case nOpc==2
	      Loop
	    Case nOpc==3
	      lContinua:=.F.
	      Return
      EndCase
   End

Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPDET   ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Linhas de Detalhe da Nota Fiscal              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function IMPDET()

nTamDet :=10            // Tamanho da Area de Detalhe
* ...
wQTD2   :=0
wVALMERC:=0.00
wUNIT   :=0.00
wconta  :=0
wunid   :=" "
wDESC   :=" "
xproduto:=" "

* ...
dbSelectArea("SD2")                   // * Itens de Venda da N.F.
dbSetOrder(3)
dbSeek(xFilial()+xNUM_NF+xSERIE)

while !eof() .and. SD2->D2_DOC==xNUM_NF .and. SD2->D2_SERIE==xSERIE
               
      If SD2->D2_SERIE == mv_par03        // Se a Serie do Arquivo for Diferente

         if wconta==0
            xproduto:=d2_cod
            wconta  :=1
         endif

         If xproduto == d2_cod
            wQTD2   :=wQTD2+SD2->D2_QUANT
            wVALMERC:=wVALMERC+SD2->D2_TOTAL
            wUNIT   :=SD2->D2_PRCVEN

            dbSelectArea("SC6")                     // * Desc. Generica do Produto
            dbSetOrder(1)
            dbSeek(xFilial()+SD2->D2_PEDIDO+SD2->D2_ITEMPV+xproduto)
            if .not. eof()
               wunid:=SC6->C6_UM
               wDESC:=alltrim(SC6->C6_DESCRI)
            endif
         Endif
      endif

      * ...
      dbselectarea("SD2")
      dbskip()

      * ...
      if eof() .or. xproduto <> d2_cod .or. SD2->D2_DOC<>xNUM_NF .or. SD2->D2_SERIE<>xSERIE
         if wQTD2 >0
            @ Li,004  PSAY wQTD2 picture "@r 99,999.99"
            @ Li,016  PSAY wunid               
            //@ Li,001  PSAY xproduto
            @ Li,020  PSAY wDESC
            @ Li,096  PSAY round(wUNIT,2) picture "@r 9,999,999.99" 
            @ Li,120  PSAY wVALMERC picture "@r 99,999,999.99"	
            * ...
            Li:=Li+1
            wQTD2   :=0
            wunid   :=" "
            wVALMERC:=0.00
            wUNIT   :=0.00
            wconta  :=0
            wDESC   :=" "
         endif
      endif

Enddo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MENSOBS  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao Mensagem no Campo Observacao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MENSOBS()

nTamObs:=65

@ Li, 020 PSAY UPPER(SUBSTR(xMENSAGEM,1,nTamObs))
If len(xMENSAGEM) > 65
 Li:=Li+1
 @ Li, 020 PSAY UPPER(SUBSTR(xMENSAGEM,66,nTamObs))    
Endif
If len(xMENSAGEM) > 131
 Li:=Li+1
 @ Li, 020 PSAY UPPER(SUBSTR(xMENSAGEM,132,nTamObs))
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DUPLIC   ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao do Parcelamento das Duplicacatas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DUPLIC()

IF LEN(XPARC_DUP)==1
   @ Li, 020 PSAY "Cond. Pgto "+xDESC_PAG
   Li +=1
   //@ Li,070 PSAY XNUM_DUPLIC                   //NUMERO DE DUPLICATA
   @ Li,020 PSAY XVENC_DUP[1]                 //VENCIMENTO
   @ Li,036 PSAY XVALOR_DUP[1]  picture  "@E 99,999,999.99"            //VALOR DA DUPLICATA
ENDIF
IF LEN(XPARC_DUP)==2
   Li +=1
   //@ Li,070 PSAY XNUM_DUPLIC                   //NUMERO DE DUPLICATA
   @ Li,020 PSAY XVENC_DUP[2]                 //VENCIMENTO
   @ Li,036 PSAY XVALOR_DUP[2] picture  "@E 99,999,999.99"                //VALOR DA DUPLICATA
ENDIF
IF LEN(XPARC_DUP)==3
   Li +=1
   //@ Li,070 PSAY XNUM_DUPLIC                   //NUMERO DE DUPLICATA
   @ Li,020 PSAY XVENC_DUP[3]                 //VENCIMENTO
   @ Li,036 PSAY XVALOR_DUP[3] picture  "@E 99,999,999.99"               //VALOR DA DUPLICATA
ENDIF
IF LEN(XPARC_DUP)==4
   Li +=1
   //@ Li,070 PSAY XNUM_DUPLIC                   //NUMERO DE DUPLICATA
   @ Li,020 PSAY XVENC_DUP[4]                 //VENCIMENTO
   @ Li,036 PSAY XVALOR_DUP[4] picture  "@E 99,999,999.99"                //VALOR DA DUPLICATA
ENDIF

RETURN
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IMPRIME  ³ Autor ³                       ³Data  ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime a Nota Fiscal de Servico                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Imprime()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do Cabecalho da N.F.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00,000 psay chr(15)

//For I := 1 to 60 //                         1         2         3         4         5         6         7         8         9         A         1         2         3         4         5         6         7        8          9         2
// @ I, 0 PSAY transform(I,"@E 99")+"2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
//Next I

//@ Li, 121 PSAY xNUM_NF                 // Numero da Nota Fiscal
@ 02, 90 PSAY xNATUREZA                 // Texto da Natureza de Operacao
@ 04, 90 PSAY "ASSIST. TECNICA"
@ 06, 90 PSAY xEMISSAO                 // Data da Emissao do Documento


@ 08, 15 PSAY xNOME_CLI                 //Nome do Cliente
@ 09, 15 PSAY xEND_CLI+" - "+xBAIRRO    // Endereco
@ 10, 15 PSAY xMUN_CLI                  // Municipio
@ 10, 87 PSAY xEST_CLI                  // U.F.
@ 10, 105 PSAY xCEP_CLI Picture "@R 99999-999"  // CEP

If !EMPTY(xCGC_CLI)                 // Se o C.G.C. do Cli/Forn nao for Vazio
   @ 11, 15 PSAY xCGC_CLI  picture "@R 99.999.999/9999-99"
Else
   @ 11, 15 PSAY " "                // Caso seja vazio
Endif

@ 12, 15 PSAY xINSC_CLI             // Insc. Estadual

Li:=15
ImpDet()                 // Detalhe da NF
Li+=1
MENSOBS()
If xVALINSS <> 0
 Li+=2
 @ Li, 020 PSAY "RETENCAO PARA SEGURIDADE SOCIAL 11% "+TRANSFORM(xVALINSS,"@E 999,999,999.99")
EndIf
Li:=35
DUPLIC() 

//@ Li, 017 PSAY xBASEISS  Picture"@E@Z 999,999,999.99"  // Valor Tot. Prod.
//@ Li, 051 PSAY xVALISS   Picture"@E@Z 999,999,999.99"  // Valor Tot. Prod.
@ 40, 001 PSAY chr(14)
@ 41, 120 PSAY xVALOR_MERC Picture "@E@Z 999,999,999.99"
@ 42, 001 PSAY chr(15)  // Valor Tot. Prod.

//@ 46, 007 PSAY xNUM_NF                 // Numero da Nota Fiscal

@ 51, 000 PSAY CHR(18)

SetPrc(0,0)                              // (Zera o Formulario)

Return(.t.)
