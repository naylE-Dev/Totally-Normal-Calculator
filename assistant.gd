extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_label = get_parent().get_node("DialogLabel")
@onready var sim_button: Button = get_parent().get_node("SimButton")
@onready var rng = RandomNumberGenerator.new()

signal modo_troll

var is_awake = false
var dialog_stage = 0
var can_click = true  # controla cooldown

func _ready():
	sprite.animation = "dormindo"
	sprite.play()
	dialog_label.text = ""
	sim_button.hide()
	rng.randomize()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if not can_click:
			return # ainda em cooldown
		can_click = false
		_start_cooldown(1.0) # 1 segundo de espera entre cliques

		match dialog_stage:
			0:
				await _wake_up()
				dialog_label.text = "EI, SE TA MALUCO CARA, QUEM 
				É VO-"
				dialog_stage += 1

			1:
				sprite.animation = "default"
				sprite.play()
				dialog_label.text = "ahahahaha, você é só mais 
				um idiota!"
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
	await get_tree().create_timer(1.5).timeout # ajusta esse tempo pro tamanho real da animação "rindo"
	sprite.animation = "default"
	sprite.play()
	sim_button.hide()
	emit_signal("modo_troll")
	await get_tree().create_timer(2.0).timeout
	hide()
	dialog_label.hide()

# -------- utilitário --------
func _start_cooldown(time: float) -> void:
	await get_tree().create_timer(time).timeout
	can_click = true
