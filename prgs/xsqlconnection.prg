define class xSQLConnection as Custom
	
	oHandle = .null. && Armazena a refer�ncia que faz a comunica��o com o banco.
	cSQLError = []  && Armazena qualquer erro de sql.
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure: INIT
	*- Descri��o: Inicia com as propriedades padr�o. 
	*- Retorno: L�gico
	procedure init
		*- Desativa as mensagens do SQL quando falha um statment 
		SQLSETPROP(0,"DispLogin",3)
		
		return .T.
	endproc 
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*			
	*- Procedure: 	cGetConnString
	*- Descri��o: 	Monta uma connection string.
	*- Retorno: 	String
	*- 		   	Retorna a connection string criada. 
	procedure cGetConnString
		lparameters cServidor, cUsuario, cSenha, nTrustedConnection, cDatabase
		
		local cDriver, cServ, cUID, cPWD, cTC, cPacketSize, cDB, cReturn
		
		store [] to cDriver, cServ, cUID, cPWD, cTC, cPacketSize, cDB, cReturn
		
		cDriver = [DRIVER=SQL Server;]
		
		cServ = [SERVER=] + alltrim(cServidor) + [;]
		
		cDB =  [DATABASE=] + alltrim(cDatabase) + [;]
		
		cUID = [UID=] + alltrim(cUsuario) + [;]
		
		cPWD = [PWD=] +alltrim(cSenha) + [;]
		
		cTC = [TRUSTED_CONNECTION=] + iif(nTrustedConnection = 1, [YES], [NO]) + [;]
		
		cPacketSize = [PACKETSIZE=8]
		
		cReturn = cDriver + cServ + cDB + cUID + cPWD + cTC + cPacketSize
		
		return cReturn
		
	endproc 
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure 	lConnectSQL
	*- Descri��o: 	Realiza a conex�o com o banco de dados. 
	*- Retorno: 	L�gico

	procedure lConnectSQL 
		lparameters cSqlString
		
		this.oHandle = sqlstringconnect(cSqlString)
		
		*- retorna <0 quando falha na conex�o.
		if this.oHandle < 0
			this.lSQLErrHand()
			this.oHandle = .null. 
			return .F.
		endif 
		
		return .T.
	endproc 
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure 	lExecuteSQL
	*- Descri��o: 	Executa um comando SQL.
	*- Retorno: 	L�gico
	
	procedure lExecuteSQL
		lparameters cQuery, cCursor , nParameters ,aParameters
		
		private cFinalQuery
		store [] to cFinalQuery
		
		*- Verifica se est� passando par�metros.	
		if vartype(nParameters) == [N] and nParameters > 0
			&& bolar jeito de adicionar par�metros na query
			
		else 
			cFinalQuery = alltrim(cQuery)
		endif 
		
		*- Verifica se o cCursor foi preenchido. 
		if vartype(cCursor) <> [C]
			cCursor = [] 
		endif 
		
		*- Mata o cursor caso j� exista. 
		use in select(cCursor)
		
		*- Executa o comando. Caso retorne < 0, deu erro. 
		if sqlexec(this.oHandle, cFinalQuery, cCursor) < 0 
			this.lSQLErrHand()
			return .F.
		else 
			return .T. 
		endif 
	endproc
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure:	lDisconnectSQL
	*- Descri��o: 	Disconecta do servidor SQL j� conectado.
	*- Retorno:	L�gico
	
	procedure lDisconnectSQL
		*- se retornou < 0, ocorreu algum problema. 
		if sqldisconnect(this.oHandle) < 0 
			this.lSQLErrHand()
			return .F. 
		endif 
		
		*- Zera a refer�ncia. 		
		this.oHandle = .null. 
		return .T.
	endproc 

	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure: 	lSQLErrHand	
	*- Descri��o: 	Pega o �ltimo erro e armazena em uma vari�vel interna. (cSQLError)
	*- Retorno: ?
	
	Procedure lSQLErrHand
		local lcError
		lcError = ''
		*- Pega o �ltimo erro encontrado e joga em um array.
		Aerror(arrCheck)
		
		*- Pega a posi��o 2, que cont�m a descri��o do erro. 
		lcError = Trans( arrCheck[2])
		
		*- Preenche a vari�vel do objeto que armazena os �ltimos erros.
		this.cSQLError = lcError
		
		return 
	endproc
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure 	lCheckEnvironment 
	*- Descri��o: 	Checa se o ambiente SQL da aplica��o est� criado.
	*- Retorno:	L�gico	
	procedure lCheckEnvironment
		local cSQLcmd, lReturn, nTableCount, nColumnCount
		
		lReturn = .T.
		nTableCount = 1
		nColumnCount = 17
		
		*- Primeiro verifica se a tabela existe. 
		text to cSQLcmd  textmerge noshow 
		select count(1) nCount from <<oGlobalSet.database>>.sys.tables t (nolock) where t.name = 'tAtividades'		
		endtext 
		
		this.lExecuteSQL(cSQLcmd, [SQLVerify])
		
		select ([SQLVerify])
		*- Falhou na verifica��o. 
		if SQLVerify.nCount < nTableCount 
			lReturn = .F.
		endif 
		
		*- Depois verifica as colunas 
		text to cSQLcmd textmerge noshow 
		select count(1) nCount from <<oGlobalSet.database>>.sys.columns (nolock) c 
		inner join <<oGlobalSet.database>>.sys.tables (nolock) t on t.object_id = c.object_id
		where t.name = 'tAtividades'
		endtext 
		
		this.lExecuteSQL(cSQLcmd, [SQLVerify])
		
		
		select ([SQLVerify])		
		if SQLVerify.nCount < nCountCount 
			lReturn = .F.
		endif 
	
		return lReturn
	
	endproc 
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*	
	*- 	Procedure lEnvironmentCreate
	*- 	Descri��o: Cria o ambiente da aplica��o. 
	*- 	Retorno: L�gico
	
	procedure lEnvironmentCreate
		local lReturn 
		
		*- Script de cria��o da tabela. 		
		text to cSQLcmd textmerge noshow 
		CREATE TABLE <<oGlobalSet.database>>.dbo.tAtividades (
		_cID int primary key,
		_Chamado varchar(50) default '' not null , 
		_Cliente varchar(30) default '' not null ,
		_Descricao varchar(250) default '' not null,
		_data date,
		_horaIni varchar(10),
		_horaFim varchar(10),
		_minutos Numeric(16,2),
		_descT text,
		_DynamUso Numeric(1,0),
		_dynamFile varchar(100),
		_tAcesso Numeric(1,0),
		_Acesso varchar(50),
		_Usuario varchar(30),
		_Senha varchar(30),
		_Agenda Numeric(1,0),
		_rdp varchar(100))
		
		endtext 
		
		lReturn = this.lExecuteSQL(cSQLcmd)
		
		return lReturn 
		
	endproc 
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure 	lEnvironmentDrop
	*- Descri��o:	Deleta o ambiente da aplica��o sem d�.
	*- Retorno: 	L�gico
		
	procedure lEnvironmentDrop
		local lReturn, cSQLcmd
		*- Script de dele��o da tabela. 
		text to cSQLcmd textmerge noshow 

		drop table <<oGlobalSet.database>>.dbo.tAtividades
	
		endtext 
		
		lReturn = this.lExecuteSQL(cSQLcmd)
	
		return lReturn 		
	endproc 




enddefine 