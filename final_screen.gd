extends Control

@onready var label_title: Label = $LabelTitle
@onready var background: TextureRect = $Background

func show_final(final_name: String, texture: Texture2D = null):
	# Atualiza o texto
	label_title.text = final_name.to_upper()

	# Se quiser trocar a textura de fundo dependendo do final
	if texture:
		background.texture = texture

	# Mostra a tela de final
	visible = true
	get_tree().paused = true  # pausa o resto do jogo

func _on_Button_pressed():#reinicia o jogo
	restart_game()


func restart_game():
	var exec_path = OS.get_executable_path()
	OS.create_process(exec_path, [])
	get_tree().quit()
