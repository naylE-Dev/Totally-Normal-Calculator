extends Control

@export var assistant_path: NodePath
@export var input_display_path: NodePath

@onready var assistant: Node = get_node(assistant_path)
@onready var input_display: LineEdit = get_node(input_display_path)

var covers := {}        # dicionário { "2": Panel, "4": Panel, ... }
var troll_mode := false
var unlocked := {}      # guarda quais já foram liberados

var last_text := ""     # usado pro polling
var last_expression := "" # última expressão avaliada
var repeat_counter := {}  # { "2+2": 2, "3+3": 1, ... }

func _ready():
	visible = false  # começa invisível
	input_display.editable = false # trava digitação no LineEdit

	# Indexa os covers pelos nomes dos filhos (os Panels dentro do ButtonBlocker)
	for child in get_children():
		if child is Control:
			covers[child.name] = child
			child.hide()

	assistant.connect("modo_troll", Callable(self, "_on_modo_troll"))

func _process(_delta):
	if not troll_mode:
		return
	
	if input_display.text != last_text:
		last_text = input_display.text
		_on_text_changed(last_text)

func _on_modo_troll():
	visible = true
	troll_mode = true
	_block_all()

func _on_text_changed(new_text: String):
	if not troll_mode:
		return

	var t := new_text.strip_edges()

	# desbloqueio normal dos números
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

	# Verifica se já liberou todos os números 2-9
	if _all_numbers_unlocked():
		_unlock_cover("-") # libera subtração

	# Detecta expressões repetidas (tipo 2+2, 3+3...)
	if t.ends_with("="):
		var expr = t.substr(0, t.length() - 1) # remove o "="
		_check_repeated_expression(expr)

# -------- utilitários --------

func _block_all():
	for key in covers.keys():
		covers[key].show()

func _unlock_cover(key: String):
	if covers.has(key) and not unlocked.has(key):
		unlocked[key] = true
		covers[key].hide()
		print("Desbloqueado:", key)

func _all_numbers_unlocked() -> bool:
	for n in ["2","3","4","5","6","7","8","9"]:
		if not unlocked.has(n):
			return false
	return true

func _check_repeated_expression(expr: String):
	# conta quantas vezes essa expressão já foi feita
	if not repeat_counter.has(expr):
		repeat_counter[expr] = 1
	else:
		repeat_counter[expr] += 1

	print("Expressão:", expr, "vezes:", repeat_counter[expr])

	# Se a mesma soma for feita 3 vezes → desbloqueia "*"
	if repeat_counter[expr] >= 3:
		_unlock_cover("*")

	# (mais pra frente podemos usar a mesma lógica pro "/")
