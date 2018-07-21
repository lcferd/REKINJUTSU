*- Seta os settings padrão. 
lSetSettings()

*- Verifica se é iniciado com o Fox. 
if _vfp.StartMode <> 4 
	*- Máquina pessoal.
	if sys(0) = [LUCAS-PC # LUCASRODRIGUES] 
		set path to [C:\Users\LUCASRODRIGUES\Documents\Projeto Shinigami]
		on key label f12 suspend 
	else
		*- Máquina trabalho.
		if sys(0) = [SSA-503 # lrodrigues]
			set path to [C:\Users\lrodrigues\Desktop\Projeto Shinigami]
			on key label f12 suspend 
		else
			*- Safado tentando explorar meu fonte. 
			messagebox("ta tentando entrar com o fox danadinho")
			lCloseApp()
		endif 
	endif 
endif 


**************************************
on shutdown Do lCloseApp in xStart.PRG
**************************************

*- Caso seja o exe, deixa o _screen invisível
with _screen
	if _vfp.StartMode = 4
		 .visible = .f. 
		 .caption ="Shinigami Project"
	 endif 
endwith
**************************************




public cDirectory, oGlobalSet

*- Variável com funções globais.
oGlobalSet = newobject([xGlobalSettings], [xGlobalSettings.vcx])

*- pega o user logado.
cDirectory = getenv("userprofile")
cDirectory = cDirectory + [\Documents\Rekinjutsu\config\]

*- Verifica se existe o caminho de configuração. 
if !DIrectory(cDirectory)
	Md &cDirectory
EndIf 

public cHomePath

cHomePath = cDirectory

*- Verifica se o arquivo de configuração com o banco de dados está criado.
cFile = cDirectory + [config.luc]
if !file(cFile)
	do form f_First_Input
	read events
	*- tem um clear events no unload do form, só sai de lá quando fechar. 

else 
	*- Tenta validar as informações do arquivo.
	if !oGlobalSet.lValidaConfig(cFile)
		if messagebox([A aplicação não pode ser iniciada, existe um problema com a configuração do SQL. Deseja reconfigurar?], 64 + 4, [Atenção!]) = 6
			do form f_First_Input
			read events
			*- tem um clear events no unload do form, só sai de lá quando fechar. 		
		endif 
	endif 
endif 


*- Novamente valida as informações do arquivo.
if oGlobalSet.lValidaConfig(cFile)
	*- Form Principal.
	do form f_tela_atividades
	read events
endif 





**************************************
*- Caso tenha sido iniciado com o Fox, não fecha o mesmo. 
if _vfp.StartMode <> 4 
	release all
	return
else
	quit
endif 


function lCloseApp
	*- Finaliza o programa, sem deixar nenhuma coisa na memória. 
	*- Ignora todos os erros possíveis.
	on error *


	clear events
	close database all
	close tables
	on shutdown 

	quit
endfunc 


function lSetSettings
	*- Seta as configurações iniciais.
	set exact on 
	set talk off
	set safety off
	set deleted on
	set exclusive off
	set sysformats on
endfunc 