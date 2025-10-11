extends Node

# Script para resetar o progresso do jogo
# Use isso para testar a primeira interação novamente

func _ready():
	var config_file = "user://calculator_progress.cfg"
	var dir = DirAccess.open("user://")
	
	if dir and dir.file_exists("calculator_progress.cfg"):
		dir.remove("calculator_progress.cfg")
		print("Progresso resetado com sucesso!")
		print("Arquivo deletado: ", config_file)
	else:
		print("Nenhum arquivo de progresso encontrado.")
	
	# Sai do jogo após resetar
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()


