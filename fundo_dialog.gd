extends ColorRect

func _ready():
	# Configurar o fundo da caixa de diálogo
	color = Color.WHITE
	custom_minimum_size = Vector2(200, 50)
	
	# Adicionar bordas pretas
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.WHITE
	style_box.border_color = Color.BLACK
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	# Aplicar o estilo
	theme_override_styles["panel"] = style_box