extends TextureButton

var ativado := false
var current_line := 0
var cooldown := false

@onready var dialog_label := get_parent().get_node("DialogLabel")

var dialog_lines := [
	"Que falta de respeito.",
	"Já ouviu falar em 
    privacidade?",
	"Vai continuar clicando ou 
    vai usar a calculadora?"
]

func _pressed():
	if cooldown:
		return
	
	# Ativa o cooldown pra evitar spam
	cooldown = true
	await get_tree().create_timer(0.5).timeout
	cooldown = false
	
	if current_line < dialog_lines.size():
		dialog_label.text = dialog_lines[current_line]
		current_line += 1
	else:
		dialog_label.text = ""
		current_line = 0
