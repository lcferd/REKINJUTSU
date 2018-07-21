*- Seta os settings padr�o. 
lSetSettings()

*- Verifica se � iniciado com o Fox. 
if _vfp.StartMode <> 4 
	do case
		*- M�quina pessoal
		case sys(0) = [LUCAS-PC # LUCASRODRIGUES]
			set path to 	[C:\Users\LUCASRODRIGUES\Documents\GITHUB\REKINJUTSU\prgs\] additive 
			set path to 	[C:\Users\LUCASRODRIGUES\Documents\GITHUB\REKINJUTSU\forms\] additive 
			set path to 	[C:\Users\LUCASRODRIGUES\Documents\GITHUB\REKINJUTSU\classes\] additive 
			on key label f12 suspend 
		*- M�quina trabalho.
		case sys(0) = [SSA-503 # lrodrigues]
			set path to 	[C:\Users\lrodrigues\Desktop\GITHUB\REKINJUTSU\prgs\] additive 
			set path to 	[C:\Users\lrodrigues\Desktop\GITHUB\REKINJUTSU\forms\] additive 
			set path to 	[[C:\Users\lrodrigues\Desktop\GITHUB\REKINJUTSU\classes\] additive 
			on key label f12 suspend 
		*- M�quina pessoal
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

*- Caso seja o exe, deixa o _screen invis�vel
with _screen
	if _vfp.StartMode = 4
		 .visible = .f. 
		 .caption ="Shinigami Project"
	 endif 
endwith
**************************************




public oGlobalSet

*- Vari�vel com fun��es globais.
oGlobalSet = newobject([xGlobalSettings], [xGlobalSettings.vcx])

*- pega o user logado.
with oGlobalSet
	.HomePath = getenv("userprofile")
	.HomePath = .HomePath + [\Documents\Rekinjutsu\]

	*- Verifica se existe o caminho de configura��o. 
	.ConfigPath = .HomePath + [config\]
	if !DIrectory(.ConfigPath)
		Md &.ConfigPath 
	EndIf 

	*- Verifica se o arquivo de configura��o com o banco de dados est� criado.
	cFile = .ConfigPath  + [config.luc]	
endwith 

if !file(cFile)
	do form f_First_Input
	read events
	*- tem um clear events no unload do form, s� sai de l� quando fechar. 

else 
	*- Tenta validar as informa��es do arquivo.
	if !oGlobalSet.lValidaConfig(cFile)
		if messagebox([A aplica��o n�o pode ser iniciada, existe um problema com a configura��o do SQL. Deseja reconfigurar?], 64 + 4, [Aten��o!]) = 6
			do form f_First_Input
			read events
			*- tem um clear events no unload do form, s� sai de l� quando fechar. 		
		endif 
	endif 
endif 


*- Novamente valida as informa��es do arquivo.
if oGlobalSet.lValidaConfig(cFile)
	*- Form Principal.
	do form f_tela_atividades
	read events
endif 





**************************************
*- Caso tenha sido iniciado com o Fox, n�o fecha o mesmo. 
if _vfp.StartMode <> 4 
	release all
	return
else
	quit
endif 


function lCloseApp
	*- Finaliza o programa, sem deixar nenhuma coisa na mem�ria. 
	*- Ignora todos os erros poss�veis.
	on error *


	clear events
	close database all
	close tables
	on shutdown 

	quit
endfunc 


function lSetSettings
	*- Seta as configura��es iniciais.
	set exact on 
	set talk off
	set safety off
	set deleted on
	set exclusive off
	set sysformats on
endfunc 