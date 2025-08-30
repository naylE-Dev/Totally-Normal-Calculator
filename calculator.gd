# calculator.gd (atualizado com o sinal)

extends Control

# --- Sinal adicionado ---
signal expression_evaluated(result, expression_string)
# ---

@onready var input_display: LineEdit = $PanelContainer/VBoxContainer/InputDisplay
@onready var grid_container: GridContainer = $PanelContainer/VBoxContainer/GridContainer

func _ready() -> void:
	for button in grid_container.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button.get_text()))

func setup_calculator() -> void:
	pass

func _on_button_pressed(value: String) -> void:
	if value == "=":
		var expression_string = input_display.get_text() # Captura a expressão antes de avaliar
		var result = _evaluate_expression(expression_string)
		var formatted_result = _format_result(result)
		input_display.set_text(formatted_result)
		# --- Emite o sinal após a avaliação ---
		emit_signal("expression_evaluated", result, expression_string)
		# ---
	elif value == "C":
		input_display.set_text("")
	else:
		var text = input_display.get_text() + value
		input_display.set_text(text)

func _evaluate_expression(expression: String) -> float:
	var result: float = 0.0
	var error_message: String = "Error"
	# --- Verificação de divisão por zero textual simples ---
	var clean_expr = expression.replace(" ", "")
	if "/0" in clean_expr:
		# Emite um sinal específico para divisão por zero tentada
		emit_signal("divided_by_zero_attempt", expression)
	# --- ---
	var expr = Expression.new()
	var error = expr.parse(expression, [])
	if error == OK:
		result = expr.execute([], null, true)
		if expr.has_execute_failed():
			# Verifica se o erro foi especificamente divisão por zero
			# Infinito positivo ou negativo indica divisão por zero
			if is_inf(result):
				emit_signal("divided_by_zero_executed", expression, result)
			input_display.set_text(error_message)
			return 0.0
	else:
		input_display.set_text(error_message)
		return 0.0
	return result

func _format_result(value: float) -> String:
	# Se for "inteiro disfarçado" (tipo 4.0), mostra só "4"
	if abs(value - int(value)) < 0.000001:
		return str(int(value))
	# Senão, mostra decimal normal (ex: 4.5, 3.14159)
	return str(value)

# --- Sinais para divisão por zero ---
signal divided_by_zero_attempt(original_expression)
signal divided_by_zero_executed(original_expression, result)
# ---
