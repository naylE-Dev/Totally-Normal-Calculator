# button_blocker.gd (atualizado)

extends Control

@export var assistant_path: NodePath
@export var input_display_path: NodePath
@export var calculator_path: NodePath

@onready var assistant: Node = get_node(assistant_path)
@onready var input_display: LineEdit = get_node(input_display_path)
@onready var calculator: Node = get_node(calculator_path)
# --- Onready para o assistant principal (na raiz da cena Calculadora) ---
@onready var main_assistant: Node = get_parent().get_node("assistant")
# ---

var covers := {}
var troll_mode := false
var unlocked := {}

# --- Variáveis para controlar os desbloqueios ---
var unlocked_asterisk_by_multiplication = false
var unlocked_barra_by_zero_multiplication = false
# ---

# --- Variável para verificar se tudo foi desbloqueado e salvo ---
var all_unlocked_permanently = false
# --- Nome do arquivo de configuração ---
const CONFIG_FILE_NAME = "user://calculator_progress.cfg"
# --- Chave para salvar se está tudo desbloqueado permanentemente ---
const ALL_UNLOCKED_PERMANENTLY_KEY = "calculator_all_unlocked_perm"

var last_text := ""

func _ready():
	_load_progress() # Carrega o progresso salvo ao iniciar

	if all_unlocked_permanently:
		# Se já foi desbloqueado permanentemente, pula o modo troll
		print("Calculadora já desbloqueada permanentemente. Modo livre ativado.")
		_make_calculator_fully_free()
		return # Sai do _ready, não precisa inicializar o modo troll

	# Se não foi desbloqueado permanentemente, inicializa o modo troll normal
	visible = false
	input_display.editable = false

	for child in get_children():
		if child is Control:
			covers[child.name] = child
			child.hide()

	assistant.connect("modo_troll", Callable(self, "_on_modo_troll"))
	if calculator != null:
		calculator.connect("expression_evaluated", Callable(self, "_on_calculator_expression_evaluated"))

func _process(_delta):
	# Se já está tudo desbloqueado permanentemente, não precisa do process
	if all_unlocked_permanently:
		return

	if not troll_mode:
		return

	if input_display.text != last_text:
		last_text = input_display.text
		_on_text_changed(last_text)

func _on_modo_troll():
	# Se já está tudo desbloqueado permanentemente, o modo troll não faz nada
	if all_unlocked_permanently:
		return

	visible = true
	troll_mode = true
	_block_all()

func _on_text_changed(new_text: String):
	# Se já está tudo desbloqueado permanentemente, não faz nada aqui
	if all_unlocked_permanently:
		return

	if not troll_mode:
		return

	var t := new_text.strip_edges()

	match t:
		"2": _unlock_cover("2")
		"3": _unlock_cover("3")
		"4": _unlock_cover("4")
		"5": _unlock_cover("5")
		"6": _unlock_cover("6")
		"7": _unlock_cover("7")
		"8": _unlock_cover("8")
		"9": _unlock_cover("9")
		"0": _unlock_cover("0")

	if _all_numbers_unlocked():
		_unlock_cover("-")

# --- Função para lidar com o sinal da calculadora ---
func _on_calculator_expression_evaluated(result: float, expression_string: String):
	# Se já está tudo desbloqueado permanentemente, não faz nada aqui
	if all_unlocked_permanently:
		return

	if not troll_mode:
		return

	# --- Lógica para desbloquear o ASTERISCO ---
	if not unlocked_asterisk_by_multiplication:
		var result_as_int = int(result)
		if result > 9 and abs(result - result_as_int) < 0.000001:
			if _can_be_multiplied(result_as_int):
				print("Número inteiro %d pode ser obtido via multiplicação. Liberando 'asterisco'." % result_as_int)
				_unlock_cover("asterisco")
				unlocked_asterisk_by_multiplication = true
	# ---

	# --- Lógica para desbloquear a BARRA ---
	if not unlocked_barra_by_zero_multiplication:
		if abs(result - 0.0) < 0.000001:
			if "*" in expression_string:
				print("Resultado 0 obtido por multiplicação (expressão: '%s'). Liberando 'barra'." % expression_string)
				_unlock_cover("barra")
				unlocked_barra_by_zero_multiplication = true
	# ---

	# --- Verificação se TUDO foi desbloqueado ---
	# Movemos esta verificação para dentro de _on_calculator_expression_evaluated
	# porque é aqui que sabemos quando uma operação foi concluída.
	if not all_unlocked_permanently: # Verificação redundante, mas segura
		if _is_everything_unlocked():
			all_unlocked_permanently = true
			_save_progress() # Salva o progresso
			print("TUDO FOI DESBLOQUEADO PELA PRIMEIRA VEZ!")
			# Chama a função para mostrar o assistente principal e tornar tudo livre
			_show_main_assistant_and_make_free()

# -------- utilitários --------

func _block_all():
	if all_unlocked_permanently:
		return

	for key in covers.keys():
		if covers[key] != null and covers[key] is CanvasItem:
			covers[key].show()

func _unlock_cover(key: String):
	if all_unlocked_permanently:
		return

	if covers.has(key) and not unlocked.has(key) and covers[key] != null and covers[key] is CanvasItem:
		unlocked[key] = true
		covers[key].hide()
		print("Desbloqueado:", key)

		# Verifica se TUDO foi desbloqueado após este desbloqueio
		# (alternativa à verificação em _on_calculator_expression_evaluated)
		# if not all_unlocked_permanently and _is_everything_unlocked():
		#     all_unlocked_permanently = true
		#     _save_progress()
		#     print("TUDO FOI DESBLOQUEADO!")
		#     _show_main_assistant_and_make_free()

func _all_numbers_unlocked() -> bool:
	if all_unlocked_permanently:
		return true # Se está tudo livre, considera como desbloqueado

	for n in ["2", "3", "4", "5", "6", "7", "8", "9"]:
		if not unlocked.has(n):
			return false
	return true

func _can_be_multiplied(number: int) -> bool:
	if number <= 1:
		return false

	var sqrt_number = sqrt(float(number))
	for i in range(2, int(sqrt_number) + 1):
		if number % i == 0:
			return true
	return false

# --- Verifica se TODOS os botões/operações foram desbloqueados ---
func _is_everything_unlocked() -> bool:
	# Certifique-se de que os nomes aqui correspondem EXATAMENTE aos nomes
	# dos nós Panel filhos do ButtonBlocker e às chaves usadas em _unlock_cover
	# Estes são os botões que começam bloqueados e precisam ser "desbloqueados"
	# durante o modo troll.
	var all_keys_to_unlock = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "asterisco", "barra"]
	# NOTA: "1", "+", "=", "C" começam desbloqueados, então não precisam estar em 'unlocked'
	for key in all_keys_to_unlock:
		if not unlocked.has(key):
			return false
	return true

# --- Função para mostrar o assistente principal após desbloqueio completo ---
func _show_main_assistant_and_make_free():
	# Torna o assistente visível novamente e faz ele falar
	if main_assistant != null:
		main_assistant.show()
		# Chama uma função no assistant.gd para a reação específica
		if main_assistant.has_method("_on_all_unlocked_first_time"):
			main_assistant._on_all_unlocked_first_time()

	# Torna a calculadora completamente livre
	_make_calculator_fully_free()

# --- Função para tornar a calculadora completamente livre ---
func _make_calculator_fully_free():
	# Esconde todos os covers
	_block_all() # Reutiliza, mas como all_unlocked_permanently é true, não faz nada
	# Ou esconde explicitamente:
	for key in covers.keys():
		if covers[key] != null and covers[key] is CanvasItem:
			covers[key].hide() # Garante que estejam escondidos

	# Torna o ButtonBlocker invisível e inativo
	visible = false
	troll_mode = false # Desativa o modo troll

	# Permite a edição no input display
	input_display.editable = true

	# Desconecta os sinais para evitar processamento desnecessário?
	# (Opcional, depende se você quiser manter alguma lógica)
	# if calculator != null:
	#     calculator.disconnect("expression_evaluated", Callable(self, "_on_calculator_expression_evaluated"))

	print("Calculadora agora está completamente livre!")

# --- Funções para salvar e carregar o progresso ---

func _save_progress():
	var config = ConfigFile.new()
	config.set_value("progress", ALL_UNLOCKED_PERMANENTLY_KEY, all_unlocked_permanently)
	var err = config.save(CONFIG_FILE_NAME)
	if err != OK:
		push_error("Failed to save progress to %s" % CONFIG_FILE_NAME)
	else:
		print("Progress saved successfully: all_unlocked_permanently = %s" % str(all_unlocked_permanently))

func _load_progress():
	var config = ConfigFile.new()
	if config.load(CONFIG_FILE_NAME) == OK:
		all_unlocked_permanently = config.get_value("progress", ALL_UNLOCKED_PERMANENTLY_KEY, false)
		print("Progress loaded: all_unlocked_permanently = %s" % str(all_unlocked_permanently))
	else:
		print("No progress file found. Starting fresh.")
		all_unlocked_permanently = false
