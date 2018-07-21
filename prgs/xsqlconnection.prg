define class xSQLConnection as Custom
	
	oHandle = .null. && Armazena a referência que faz a comunicação com o banco.
	cSQLError = []  && Armazena qualquer erro de sql.
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure: INIT
	*- Descrição: Inicia com as propriedades padrão. 
	*- Retorno: Lógico
	procedure init
		*- Desativa as mensagens do SQL quando falha um statment 
		SQLSETPROP(0,"DispLogin",3)
		
		return .T.
	endproc 
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*			
	*- Procedure: 	cGetConnString
	*- Descrição: 	Monta uma connection string.
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
	*- Descrição: 	Realiza a conexão com o banco de dados. 
	*- Retorno: 	Lógico

	procedure lConnectSQL 
		lparameters cSqlString
		
		this.oHandle = sqlstringconnect(cSqlString)
		
		*- retorna <0 quando falha na conexão.
		if this.oHandle < 0
			this.lSQLErrHand()
			this.oHandle = .null. 
			return .F.
		endif 
		
		return .T.
	endproc 
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure 	lExecuteSQL
	*- Descrição: 	Executa um comando SQL.
	*- Retorno: 	Lógico
	
	procedure lExecuteSQL
		lparameters cQuery, cCursor , nParameters ,aParameters
		
		private cFinalQuery
		store [] to cFinalQuery
		
		*- Verifica se está passando parâmetros.	
		if vartype(nParameters) == [N] and nParameters > 0
			&& bolar jeito de adicionar parâmetros na query
			
		else 
			cFinalQuery = alltrim(cQuery)
		endif 
		
		*- Verifica se o cCursor foi preenchido. 
		if vartype(cCursor) <> [C]
			cCursor = [] 
		endif 
		
		*- Mata o cursor caso já exista. 
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
	*- Descrição: 	Disconecta do servidor SQL já conectado.
	*- Retorno:	Lógico
	
	procedure lDisconnectSQL
		*- se retornou < 0, ocorreu algum problema. 
		if sqldisconnect(this.oHandle) < 0 
			this.lSQLErrHand()
			return .F. 
		endif 
		
		*- Zera a referência. 		
		this.oHandle = .null. 
		return .T.
	endproc 

	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure: 	lSQLErrHand	
	*- Descrição: 	Pega o último erro e armazena em uma variável interna. (cSQLError)
	*- Retorno: ?
	
	Procedure lSQLErrHand
		local lcError
		lcError = ''
		*- Pega o último erro encontrado e joga em um array.
		Aerror(arrCheck)
		
		*- Pega a posição 2, que contém a descrição do erro. 
		lcError = Trans( arrCheck[2])
		
		*- Preenche a variável do objeto que armazena os últimos erros.
		this.cSQLError = lcError
		
		return 
	endproc
	
	*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	*- Procedure 	lCheckEnvironment 
	*- Descrição: 	Checa se o ambiente SQL da aplicação está criado.
	*- Retorno:	Lógico	
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
		*- Falhou na verificação. 
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
	*- 	Descrição: Cria o ambiente da aplicação. 
	*- 	Retorno: Lógico
	
	procedure lEnvironmentCreate
		local lReturn 
		
		*- Script de criação da tabela. 		
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
	*- Descrição:	Deleta o ambiente da aplicação sem dó.
	*- Retorno: 	Lógico
		
	procedure lEnvironmentDrop
		local lReturn, cSQLcmd
		*- Script de deleção da tabela. 
		text to cSQLcmd textmerge noshow 

		drop table <<oGlobalSet.database>>.dbo.tAtividades
	
		endtext 
		
		lReturn = this.lExecuteSQL(cSQLcmd)
	
		return lReturn 		
	endproc 




enddefine 