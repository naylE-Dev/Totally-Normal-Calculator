# calculator.gd (corrigido e completo)
extends Control

# Sinais
signal expression_evaluated(result, expression_string)
signal divided_by_zero_attempt(original_expression)
# Signal para o final
signal ending_reached(final_id, expression_string)

@onready var input_display = $PanelContainer/VBoxContainer/InputDisplay
@onready var grid_container = $PanelContainer/VBoxContainer/GridContainer

func _ready() -> void:
	for button in grid_container.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(button.get_text()))

func _on_button_pressed(value: String) -> void:
	if value == "=":
		var expression_string = input_display.get_text()
		var result = _evaluate_expression(expression_string)

		# Formata o resultado (pra casos válidos)
		var formatted_result = _format_result(result)

		# Verifica se um final foi acionado com base no resultado
		if _check_for_ending(result, expression_string):
			# Final foi acionado e deve impedir exibição (ex: div_zero)
			return

		# Se não impediu, exibe o resultado (ex: pra 42)
		input_display.set_text(formatted_result)
		emit_signal("expression_evaluated", result, expression_string)

	elif value == "C":
		input_display.set_text("")
	else:
		var text = input_display.get_text() + value
		input_display.set_text(text)

func _evaluate_expression(expression: String) -> float:
	var error_message = "Error"
	var clean_expr = expression.strip_edges()

	# Protege contra expressão vazia
	if clean_expr == "":
		# Não emite sinal aqui, é um erro de sintaxe
		return 0.0

	# Remove zeros à esquerda (ex: "03" → "3"), mas sem quebrar "0.x"
	# Nota: Esta regex pode precisar de ajustes dependendo da complexidade desejada
	var regex = RegEx.new()
	regex.compile(r"\b0+(\d)")
	clean_expr = regex.sub(clean_expr, "$1", true)

	# Protege contra expressão terminando com operador
	if clean_expr.ends_with("+") or clean_expr.ends_with("-") or clean_expr.ends_with("*") or clean_expr.ends_with("/"):
		# Não emite sinal aqui, é um erro de sintaxe
		return 0.0

	# Check manual de /0 - PRINCIPAL MUDANÇA
	# Verifica se há divisão por zero *antes* de tentar executar a expressão
	# para evitar o erro interno do Godot.
	var contains_div_by_zero = false
	# Verificação textual simples: procura por "/0" após remover espaços.
	# Cuidado: pode falhar em casos complexos como "10/(2-2)" que não são capturados aqui,
	# mas a verificação pós-execução cuida disso.
	if "/0" in clean_expr.replace(" ", ""):
		contains_div_by_zero = true

	if contains_div_by_zero:
		# Emite o sinal de tentativa de divisão por zero
		emit_signal("divided_by_zero_attempt", expression)
		# Retorna INF para que _check_for_ending o identifique como um final
		return INF

	# Avalia com Expression
	var expr = Expression.new()
	var error = expr.parse(clean_expr, [])
	if error == OK:
		var result = expr.execute([], null, true)

		# Protege contra nil (embora raro com execute)
		if result == null:
			# Não emite sinal aqui, é um erro interno genérico
			return 0.0

		# Erros matemáticos detectados *após* a execução bem-sucedida do parser
		if expr.has_execute_failed() or is_inf(result) or str(result) == "nan":
			# Se falhou ou resultou em inf/nan, considera como erro/divisão por zero
			# Isso cobre casos onde a verificação textual falha (ex: "2/(1-1)")
			if is_inf(result) or str(result) == "nan":
				# Emite o sinal específico para divisão por zero executada
				emit_signal("divided_by_zero_executed", expression, result)
			# Retorna o resultado (inf/nan) mesmo assim, para _check_for_ending poder verificar
			return result if result != null else 0.0

		# Se chegou aqui, a execução foi bem-sucedida
		return float(result) if result != null else 0.0
	else:
		# Erro de parsing (sintaxe inválida)
		# Não emite sinal aqui, é um erro de sintaxe
		return 0.0

func _format_result(value: float) -> String:
	# Se for infinito ou nan, mostra uma mensagem de erro específica
	# Isso é útil se, por algum motivo, o resultado for exibido diretamente.
	if is_inf(value):
		return "Error: Inf"
	if str(value) == "nan":
		return "Error: NaN"

	# Formatação normal para números válidos
	if abs(value - int(value)) < 0.000001:
		return str(int(value))

	# Arredonda para evitar problemas de precisão de ponto flutuante
	var rounded = round(value * 1000000.0) / 1000000.0
	var s = str(rounded)

	# Remove zeros à direita após o ponto decimal
	if "." in s:
		while s.ends_with("0"):
			s = s.substr(0, s.length() - 1)
		if s.ends_with("."):
			s = s.substr(0, s.length() - 1)
	return s

# -------- finais / checagens --------
func _check_for_ending(result: float, expression: String) -> bool:
	# Verifica se o resultado indica um final específico
	if is_inf(result) or str(result) == "nan":
		# Emite o sinal de final alcançado para divisão por zero e impede exibição
		emit_signal("ending_reached", "div_zero", expression)
		return true  # Impede set_text
	# Adicione mais verificações de finais aqui, por exemplo:
	elif result == 42:
		# Emite o sinal, mas permite exibição do resultado
		emit_signal("ending_reached", "42", expression)
		return false  # Continua e faz set_text

	elif result == 67:
		emit_signal("ending_reached", "67", expression)
		return false
	return false