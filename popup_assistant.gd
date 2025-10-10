extends Window

@onready var calculadora: Control = get_node("/root/Node/Calculadora")  # Ajuste o caminho pro nó da calculadora (use $ se relativo)


func _ready():
	# Define a posição inicial específica (ex: 100 pixels do topo-esquerda)
	var posicao_inicial = Vector2(910, 95)  # Ajuste os valores x e y como quiser
	

	# Exibe o popup na posição desejada (corrigido pra Window: usa position e visible)
	position = posicao_inicial
	visible = true
	print("Popup exibido na posição inicial: ", posicao_inicial)
	
	# Conecta ao sinal ending_reached da calculadora (independente do final_id)
	if calculadora and not calculadora.is_connected("ending_reached", Callable(self, "_on_ending_reached")):
		calculadora.connect("ending_reached", Callable(self, "_on_ending_reached"))



func _on_ending_reached(final_id: String, expression_string: String):
	# Função chamada quando o sinal ending_reached é emitido pela calculadora (ignora params, reage a qualquer final)
	var janela = get_window()
	if janela:
		# Desminimiza a janela (muda o modo para windowed ou fullscreen, dependendo do que você quer)
		janela.mode = Window.MODE_WINDOWED  # Ou MODE_FULLSCREEN para tela cheia
		# Alternativa: Se quiser maximizada: janela.mode = Window.MODE_MAXIMIZED
		
		# Define como "always on top" (por cima de tudo)
		janela.always_on_top = true
		
		# Traz a janela para o foreground (foco imediato)
		janela.grab_focus()
		var nova_posicao = Vector2(550, 95)
		position = nova_posicao
		visible = true  # Garante que fique visível
		print("Popup movido para posição nova por causa de um final: ", final_id)
