extends Label

@onready var dialog_box: PanelContainer = get_parent()
@onready var fundo_dialog: ColorRect = dialog_box.get_node("FundoDialog")

# Configurações da caixa de diálogo
const MIN_WIDTH = 200
const MAX_WIDTH = 400
const PADDING = 20
const BORDER_WIDTH = 3

func _ready():
	# Configurar o estilo da caixa de diálogo
	_setup_dialog_style()
	
	# Configurar o texto inicial
	text = ""
	visible = false

func _setup_dialog_style():
	# Configurar o fundo da caixa de diálogo
	if fundo_dialog:
		fundo_dialog.color = Color.WHITE
		fundo_dialog.custom_minimum_size = Vector2(MIN_WIDTH, 50)
	
	# Configurar o estilo do texto usando bbcode
	bbcode_enabled = true
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	# Configurar o estilo da borda no PanelContainer
	if dialog_box:
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color.WHITE
		style_box.border_color = Color.BLACK
		style_box.border_width_left = BORDER_WIDTH
		style_box.border_width_right = BORDER_WIDTH
		style_box.border_width_top = BORDER_WIDTH
		style_box.border_width_bottom = BORDER_WIDTH
		style_box.corner_radius_top_left = 8
		style_box.corner_radius_top_right = 8
		style_box.corner_radius_bottom_left = 8
		style_box.corner_radius_bottom_right = 8
		style_box.content_margin_left = PADDING
		style_box.content_margin_right = PADDING
		style_box.content_margin_top = PADDING
		style_box.content_margin_bottom = PADDING
		
		# Aplicar o estilo ao PanelContainer
		dialog_box.add_theme_stylebox_override("panel", style_box)

func show_dialog(new_text: String):
	# Usar bbcode para definir a cor do texto
	text = "[color=black]" + new_text + "[/color]"
	visible = true
	# Aguardar um frame para que o texto seja processado
	await get_tree().process_frame
	_resize_dialog_box()

func hide_dialog():
	text = ""
	visible = false

func set_dialog_text(new_text: String):
	if new_text.strip_edges() != "":
		show_dialog(new_text)
	else:
		hide_dialog()

func _resize_dialog_box():
	if not is_inside_tree():
		return
		
	# Calcular o tamanho necessário baseado no texto
	var text_size = _calculate_text_size()
	
	# Aplicar limites de tamanho
	var target_width = clamp(text_size.x + PADDING * 2, MIN_WIDTH, MAX_WIDTH)
	var target_height = text_size.y + PADDING * 2
	
	# Redimensionar a caixa de diálogo
	if dialog_box:
		dialog_box.custom_minimum_size = Vector2(target_width, target_height)
	
	# Redimensionar o fundo
	if fundo_dialog:
		fundo_dialog.custom_minimum_size = Vector2(target_width, target_height)

func _calculate_text_size() -> Vector2:
	# Obter o tamanho do texto renderizado
	var font = get_theme_font("normal_font")
	var font_size = get_theme_font_size("normal_font_size")
	
	if not font:
		return Vector2(200, 50)
	
	# Calcular o tamanho do texto com quebra de linha
	var clean_text = text.replace("[color=black]", "").replace("[/color]", "")
	var text_lines = clean_text.split("\n")
	var max_width = 0
	var total_height = 0
	
	for line in text_lines:
		if line.strip_edges() == "":
			total_height += font.get_height(font_size)
			continue
			
		var line_size = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		max_width = max(max_width, line_size.x)
		total_height += line_size.y
	
	# Aplicar limites
	max_width = clamp(max_width, MIN_WIDTH - PADDING * 2, MAX_WIDTH - PADDING * 2)
	
	return Vector2(max_width, total_height)
