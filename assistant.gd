extends Area2D

@export var calculator_path: NodePath
@onready var calculator: Node = null
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_label = get_parent().get_node("DialogLabel")
@onready var sim_button: Button = get_parent().get_node("SimButton")
@onready var rng = RandomNumberGenerator.new()

signal modo_troll

var is_awake = false
var dialog_stage = 0
var can_click = true
var first_time_interaction = true

const CONFIG_FILE_NAME = "user://calculator_progress.cfg"
const FIRST_TIME_INTERACTION_KEY = "first_time_interaction_completed"

func _ready():
	print("🚀 Assistant _ready() iniciado")
	
	# tenta pegar o nó da calculadora
	if calculator_path != NodePath(""):
		calculator = get_node_or_null(calculator_path)
	
	# Verificar se dialog_label é válido
	if not dialog_label:
		print("❌ Erro: dialog_label não encontrado!")
		print("🔍 Caminho tentado: ", get_parent().get_path())
		print("🔍 Nós filhos do parent: ", get_parent().get_children())
		return
	
	print("✅ dialog_label encontrado: ", dialog_label)
	print("🔍 Tipo do dialog_label: ", dialog_label.get_class())
	print("🔍 Script do dialog_label: ", dialog_label.get_script())

	_load_first_time_status()
	rng.randomize()
	
	print("🔍 Assistant configurado:")
	print("  - first_time_interaction: ", first_time_interaction)
	print("  - monitoring: ", monitoring)
	print("  - visible: ", visible)
	print("  - position: ", global_position)
	print("  - collision disabled: ", $CollisionShape2D.disabled)
	
	# Garantir que a área de colisão está habilitada
	$CollisionShape2D.disabled = false
	monitoring = true
	
	# Conectar o sinal programaticamente para garantir que funciona
	if not is_connected("input_event", Callable(self, "_on_input_event")):
		connect("input_event", Callable(self, "_on_input_event"))
		print("✅ Sinal input_event conectado programaticamente")
	
	# Também conectar unhandled_input como backup
	set_process_unhandled_input(true)

	if first_time_interaction:
		# Primeira vez abrindo o jogo
		sprite.animation = "dormindo"
		sprite.play()
		dialog_label.text = ""
		sim_button.hide()
	
	else:
		# Volta ao jogo depois de já ter jogado antes
		sprite.animation = "duvidoso"
		sprite.play()

		var possible_lines = [
			"Ah... olha só quem voltou.",
			"Você de novo? Pensei que
			tivesse desistido.",
			"Bem-vindo de volta, 
			gênio da matemática...",
			"Não acredito que 
			abriu isso outra vez.",
			"Ah, ótimo... 
			o masoquista voltou."
		]
		dialog_label.text = possible_lines[rng.randi_range(0, possible_lines.size() - 1)]
		sim_button.hide()

		await get_tree().create_timer(4.0).timeout
		if is_instance_valid(dialog_label):
			dialog_label.text = ""
		sprite.animation = "default"
		sprite.play()

	# conecta finais da calculadora
	if calculator and not calculator.is_connected("ending_reached", Callable(self, "_on_ending_reached")):
		calculator.connect("ending_reached", Callable(self, "_on_ending_reached"))

# --- persistência ---
func _load_first_time_status():
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE_NAME) == OK:
		first_time_interaction = config.get_value("progress", FIRST_TIME_INTERACTION_KEY, true)
	else:
		first_time_interaction = true

func _save_first_time_status():
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE_NAME) != OK:
		pass
	config.set_value("progress", FIRST_TIME_INTERACTION_KEY, first_time_interaction)
	config.save(CONFIG_FILE_NAME)

# --- interação inicial ---
var COOLDOWN_TIME = 1.0
func _on_input_event(viewport, event, shape_idx):
	print("🔍 Input event detectado! first_time_interaction: ", first_time_interaction)
	print("🔍 Event type: ", event.get_class())
	print("🔍 Mouse button pressed: ", event is InputEventMouseButton and event.pressed)
	
	if not first_time_interaction:
		print("❌ Não é primeira vez, retornando")
		return
	if event is InputEventMouseButton and event.pressed:
		print("✅ Mouse button pressed!")
		if not can_click:
			print("⏳ Ainda em cooldown")
			return
		can_click = false
		_start_cooldown(COOLDOWN_TIME)

		match dialog_stage:
			0:
				await _wake_up()
				dialog_label.text = ("EI, SE TA MALUCO CARA, 
				QUEM É VO-")
				dialog_stage += 1
			1:
				sprite.animation = "default"
				sprite.play()
				dialog_label.text = ("ahahahaha, você é só mais 
				um idiota!")
				dialog_stage += 1
			2:
				dialog_label.text = ("O que você quer? é só uma 
				calculadora normal cara, 
				sai daqui.")
				dialog_stage += 1
			3:
				dialog_label.text = ("O que você esperava? um jogo?")
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
	dialog_label.text = ("Bem, você já me irritou 
	demais, aqui tá o seu jogo.")
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
	dialog_label.text = ""

# --- chamado pelo button_blocker quando tudo é desbloqueado ---
func _on_all_unlocked_first_time():
	first_time_interaction = false
	_save_first_time_status()

	show()
	dialog_label.text = ("")

	sprite.animation = "duvidoso"
	sprite.play()

	dialog_label.text = ("Como você conseguiu derrotar 
	o meu sistema maligno? 
	Ah, quer saber? 
	Não importa, bobão.")

	await get_tree().create_timer(4.0).timeout

	if is_instance_valid(dialog_label):
		dialog_label.text = ""
	sprite.animation = "default"
	sprite.play()

# --- finais (placeholders) ---
func _on_ending_reached(final_id: String, expression: String):
	if final_id == "div_zero":
		_react_div_zero(expression)
	
	
	elif final_id == "42":
		_react_42(expression)

	elif final_id == "67":
		_react_67(expression)

func _react_67(expression: String):
	show()
	dialog_label.text = ("Esse número... 
	não... você condenou
	a todos nós...")
	sprite.animation = "duvidoso"
	sprite.play()
	await get_tree().create_timer(5.0).timeout
	var final_screen = preload("res://Final_Screen.tscn").instantiate()
	get_tree().root.add_child(final_screen)
	final_screen.show_final("SIX SEVEN!!!")



func _react_42(expression: String):
	show()
	dialog_label.text = ("42? Sério que você 
	acha que esse é o sentido da vida?")
	sprite.animation = "duvidoso"
	sprite.play()
	await get_tree().create_timer(5.0).timeout
	dialog_label.text = ("Que tal você sair 
	daqui e viver a sua vida, 
	ao invés de ficar 
	procurando respostas fáceis?")
	await get_tree().create_timer(5.0).timeout
	sprite.animation = "puto"
	sprite.play()
	dialog_label.text = ("esse definitivamente 
	não é o sentido da vida, 
	eu sei qual é o sentido da vida.")
	await get_tree().create_timer(5.0).timeout
	dialog_label.text = ("Não vou te contar, 
	é muito mais profundo
	e você não aguentaria.")
	await get_tree().create_timer(5.0).timeout
	var final_screen = preload("res://Final_Screen.tscn").instantiate()
	get_tree().root.add_child(final_screen)
	final_screen.show_final("Esse NÃO é o sentido da vida.")

func _react_div_zero(expression: String):
	show()
	dialog_label.text = ("VOCÊ... tentou dividir 
	por ZERO?! Seu 
	doente mental!")
	sprite.animation = "puto"
	sprite.play()
	await get_tree().create_timer(2.0).timeout
	dialog_label.text = ("Chega, acabou a brincadeira!")
	await get_tree().create_timer(1.5).timeout
	var final_screen = preload("res://Final_Screen.tscn").instantiate()
	get_tree().root.add_child(final_screen)
	final_screen.show_final("Tu é doente mano? 
	Querendo quebrar 
	meu jogo? Que idiota.")

func _unhandled_input(event):
	print("🔍 _unhandled_input detectado!")
	if event is InputEventMouseButton and event.pressed:
		print("🔍 Mouse button via _unhandled_input!")
		# Chama a mesma lógica do _on_input_event
		_on_input_event(null, event, 0)

func _start_cooldown(time: float) -> void:
	await get_tree().create_timer(time).timeout
	can_click = true
