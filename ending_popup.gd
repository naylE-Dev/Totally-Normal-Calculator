# ending_popup.gd

extends Control

@onready var panel = $Panel
@onready var title_label = $Panel/Label
@onready var image_texture_rect = $Panel/TextureRect
@onready var close_button = $Panel/Button

# --- Variáveis ---
var ending_title := "Good Ending"
var ending_image_path := "" # Caminho para a imagem da tela do final (string)
var ending_id := "good_ending"

func _ready():
	# Esconde o popup inicialmente
	hide()
	
	# Conecta o botão de fechar
	close_button.pressed.connect(_on_close_button_pressed)

func show_ending(ending_title: String, ending_image_path: String, ending_id: String):
	# Define os dados do final
	self.ending_title = ending_title
	self.ending_image_path = ending_image_path
	self.ending_id = ending_id
	
	# Atualiza os elementos visuais
	title_label.text = ending_title
	# Carrega a imagem dinamicamente com load(), não com preload()
	if ending_image_path != "":
		var texture = load(ending_image_path)
		image_texture_rect.texture = texture
	
	# Mostra o popup
	show()

func _on_close_button_pressed():
	# Fecha o popup
	hide()
	# Reinicia o jogo
	get_tree().reload_current_scene() # Isso reinicia a cena atual (seu jogo)
