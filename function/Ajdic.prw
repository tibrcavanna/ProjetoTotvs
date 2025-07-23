#Include 'Totvs.ch'

User Function AjDic

	ConOut('***************************************')
	ConOut('Iniciando...')
	ConOut('***************************************')

	If Select("SX3") == 0
		RPCSetType(3)
		RPCSetEnv("01","01",,,"FAT","AJDIC")
		InitPublic()
		SetsDefault()
	EndIf

	ConOut('***************************************')
	ConOut('Atualizando...')
	ConOut('***************************************')

	X31UPDTABLE("FR3")
	DBSELECTAREA("FR3")

	ConOut('***************************************')
	ConOut('Concluido!')
	ConOut('***************************************')

Return
