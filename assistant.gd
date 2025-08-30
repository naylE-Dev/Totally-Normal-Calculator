# assistant.gd (atualizado)

extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_label = get_parent().get_node("DialogLabel")
@onready var sim_button: Button = get_parent().get_node("SimButton")
@onready var rng = RandomNumberGenerator.new()

signal modo_troll

var is_awake = false
var dialog_stage = 0
var can_click = true  # controla cooldown
var first_time_interaction = true  # controla se é a primeira vez

# Constantes para persistência
const CONFIG_FILE_NAME = "user://calculator_progress.cfg"
const FIRST_TIME_INTERACTION_KEY = "first_time_interaction_completed"

func _ready():
	_load_first_time_status()
	
	if first_time_interaction:
		# Primeira vez - assistant dormindo
		sprite.animation = "dormindo"
		sprite.play()
		dialog_label.text = ""
		sim_button.hide()
	else:
		# Não é a primeira vez - assistant já está acordado e duvidoso
		sprite.animation = "duvidoso"
		sprite.play()
		dialog_label.text = "Como você conseguiu derrotar o 
		meu sistema maligno? Ah, quer 
		saber? Não importa, bobão."
		sim_button.hide()
		# Esconde o assistant após alguns segundos
		await get_tree().create_timer(4.0).timeout
		sprite.animation = "default"
		sprite.play()
		dialog_label.text = ""

	
	rng.randomize()

func _load_first_time_status():
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE_NAME) == OK:
		first_time_interaction = config.get_value("progress", FIRST_TIME_INTERACTION_KEY, true)
		print("First time interaction status loaded: ", first_time_interaction)
	else:
		print("No config file found. First time interaction: true")
		first_time_interaction = true

func _save_first_time_status():
	var config = ConfigFile.new()
	# Carrega o arquivo existente primeiro para não sobrescrever outros dados
	if config.load(CONFIG_FILE_NAME) != OK:
		# Se não existe, cria um novo
		pass
	
	config.set_value("progress", FIRST_TIME_INTERACTION_KEY, first_time_interaction)
	var err = config.save(CONFIG_FILE_NAME)
	if err != OK:
		push_error("Failed to save first time status")
	else:
		print("First time status saved successfully")

# --- Nova função chamada quando tudo é desbloqueado pela primeira vez ---
func _on_all_unlocked_first_time():
	# Muda a animação para "duvidoso"
	sprite.animation = "duvidoso"
	sprite.play()
	
	# Mostra o diálogo com a frase específica
	dialog_label.show()
	dialog_label.text = "Como você conseguiu derrotar
	 o meu sistema maligno?
	  Ah, quer saber, não importa, bobão."
	
	# Esconde o assistant após alguns segundos
	await get_tree().create_timer(4.0).timeout
	if is_instance_valid(self):
		hide()
		dialog_label.hide()
# ---

func _on_input_event(viewport, event, shape_idx):
	# Se não é a primeira vez, não permite interação
	if not first_time_interaction:
		return
		
	if event is InputEventMouseButton and event.pressed:
		if not can_click:
			return # ainda em cooldown
		can_click = false
		_start_cooldown(1.0) # 1 segundo de espera entre cliques

		match dialog_stage:
			0:
				await _wake_up()
				dialog_label.text = "EI, SE TA MALUCO CARA,
				 QUEM É VO-"
				dialog_stage += 1

			1:
				sprite.animation = "default"
				sprite.play()
				dialog_label.text = "ahahahaha, você é 
				só mais um idiota!"
				dialog_stage += 1

			2:
				dialog_label.text ="O que você quer? é só uma 
				calculadora normal cara, 
				sai daqui"
				dialog_stage += 1

			3:
				dialog_label.text = "O que você esperava? um jogo?"
				dialog_stage += 1
				sim_button.show()
			_:
				_random_reaction()

func _wake_up():
	if not is_awake:
		is_awake = true
		sprite.animation = "puto"
		sprite.play()

func _random_reaction():
	var reactions = ["puto", "rindo", "duvidoso"]
	var choice = reactions[rng.randi_range(0, reactions.size() - 1)]
	sprite.animation = choice
	sprite.play()
	await get_tree().create_timer(1.5).timeout
	sprite.animation = "default"
	sprite.play()

func _on_sim_button_pressed():
	dialog_label.text = "Bem, você já me irritou demais,
	 aqui tá o seu jogo."
	sprite.animation = "rindo"
	sprite.play()
	await get_tree().create_timer(1.5).timeout
	sprite.animation = "default"
	sprite.play()
	sim_button.hide()
	emit_signal("modo_troll")
	
	# Marca que a interação inicial foi completada
	first_time_interaction = false
	_save_first_time_status()
	
	await get_tree().create_timer(2.0).timeout
	hide()
	dialog_label.hide()

# -------- utilitário --------
func _start_cooldown(time: float) -> void:
	await get_tree().create_timer(time).timeout
	can_click = true
