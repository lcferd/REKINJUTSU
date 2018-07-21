*- Seta os settings padrão. 
lSetSettings()

*- Verifica se é iniciado com o Fox. 
if _vfp.StartMode <> 4 
	do case
		*- Máquina pessoal
		case sys(0) = [LUCAS-PC # LUCASRODRIGUES]
			set path to 	[C:\Users\LUCASRODRIGUES\Documents\GITHUB\REKINJUTSU\prgs\] additive 
			set path to 	[C:\Users\LUCASRODRIGUES\Documents\GITHUB\REKINJUTSU\forms\] additive 
			set path to 	[C:\Users\LUCASRODRIGUES\Documents\GITHUB\REKINJUTSU\classes\] additive 
			on key label f12 suspend 
		*- Máquina trabalho.
		case sys(0) = [SSA-503 # lrodrigues]
			set path to 	[C:\Users\lrodrigues\Desktop\GITHUB\REKINJUTSU\prgs\] additive 
			set path to 	[C:\Users\lrodrigues\Desktop\GITHUB\REKINJUTSU\forms\] additive 
			set path to 	[[C:\Users\lrodrigues\Desktop\GITHUB\REKINJUTSU\classes\] additive 
			on key label f12 suspend 
		*- Máquina pessoal
		case sys(0) = [RENAN-PC # zDark]
			set path to 	[C:\Users\zDark\Documents\GitHub\REKINJUTSU\prgs\]	additive
			set path to 	[C:\Users\zDark\Documents\GitHub\REKINJUTSU\forms\]	additive
			set path to 	[C:\Users\zDark\Documents\GitHub\REKINJUTSU\classes\]	additive
			on key label f12 suspend
			on key label f11 set sysmenu to default
		otherwise
			*- Safado tentando explorar meu fonte. 
			messagebox("ta tentando entrar com o fox danadinho")
			lCloseApp()
		endcase
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




public oGlobalSet

*- Variável com funções globais.
oGlobalSet = newobject([xGlobalSettings], [xGlobalSettings.vcx])

*- pega o user logado.
with oGlobalSet
	.HomePath = getenv("userprofile")
	.HomePath = .HomePath + [\Documents\Rekinjutsu\]

	*- Verifica se existe o caminho de configuração. 
	.ConfigPath = .HomePath + [config\]
	if !DIrectory(.ConfigPath)
		Md &.ConfigPath 
	EndIf 

	*- Verifica se o arquivo de configuração com o banco de dados está criado.
	cFile = .ConfigPath  + [config.luc]	
endwith 

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