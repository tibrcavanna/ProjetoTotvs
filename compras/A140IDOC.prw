#Include 'Protheus.ch'

User Function A140IDOC()

    Local cDoc     := PARAMIXB[1]
    Local cSerie   := PARAMIXB[2]
    Local cCodFor  := PARAMIXB[3]
    Local cLojaFor := PARAMIXB[4]
    Local aRet     := {}

    If Len(trim(cSerie)) < 3

        aAdd(aRet,cDoc)
        aAdd(aRet,StrZero(val(cSerie),3))
        aAdd(aRet,cCodFor)
        aAdd(aRet,cLojaFor)

    Else

        aAdd(aRet,cDoc)
        aAdd(aRet,cSerie)
        aAdd(aRet,cCodFor)
        aAdd(aRet,cLojaFor)

    EndIf

Return aRet
