extends Window

@onready var calculadora: Control = get_node("/root/Node/Calculadora")
@onready var assistant: Area2D = $assistant

func _ready():
	# Configura a janela para ser transparente mas ainda visível
	self.transparent = true
	self.mouse_passthrough = false  # Permite cliques na janela
	self.unfocusable = false

	# Define a posição da janela
	position = Vector2(925, 95)
	visible = true
	
	print("🔍 PopupAssistant configurado:")
	print("  - transparent: ", self.transparent)
	print("  - mouse_passthrough: ", self.mouse_passthrough)
	print("  - unfocusable: ", self.unfocusable)
	print("  - visible: ", self.visible)
	print("  - position: ", self.position)
	print("  - size: ", self.size)

	# Garante que o assistant está recebendo input
	if assistant:
		assistant.set_process_input(true)
		assistant.set_process_unhandled_input(true)
		assistant.monitoring = true
		assistant.visible = true
		print("✅ Assistant pronto para receber input dentro do Popup.")
		print("✅ Assistant visível: ", assistant.visible)
		print("✅ Assistant posição: ", assistant.global_position)
		print("✅ Assistant monitoring: ", assistant.monitoring)
		print("✅ Assistant collision disabled: ", assistant.get_node("CollisionShape2D").disabled)
	else:
		print("❌ Assistant não encontrado!")

	# Conecta o sinal dos finais
	if calculadora and not calculadora.is_connected("ending_reached", Callable(self, "_on_ending_reached")):
		calculadora.connect("ending_reached", Callable(self, "_on_ending_reached"))
	
	# Conecta o sinal de input da janela para debug
	connect("gui_input", Callable(self, "_on_gui_input"))

func _on_gui_input(event):
	print("🔍 PopupAssistant recebeu input: ", event.get_class())
	if event is InputEventMouseButton:
		print("🔍 Mouse button na janela: ", event.pressed, " button: ", event.button_index)

func _on_ending_reached(final_id: String, expression_string: String):
	var janela = get_window()
	if janela:
		janela.mode = Window.MODE_WINDOWED
		janela.always_on_top = true
		janela.grab_focus()
		var nova_posicao = Vector2(550, 95)
		position = nova_posicao
		visible = true
		print("Popup movido para posição nova por causa de um final: ", final_id)
