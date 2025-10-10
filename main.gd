extends Node  # Ou extends Node2D se for um jogo 2D, etc.

func _ready():
    # Acessa a janela principal do Godot
    var janela = get_window()
    
    if janela:
        # Desminimiza a janela (muda o modo para windowed ou fullscreen, dependendo do que você quer)
        janela.mode = Window.MODE_WINDOWED  # Ou MODE_FULLSCREEN para tela cheia
        # Alternativa: Se quiser maximizada: janela.mode = Window.MODE_MAXIMIZED
        
        # Define como "always on top" (por cima de tudo)
        janela.always_on_top = true
        
        # Traz a janela para o foreground (foco imediato)
        janela.grab_focus()
        
        print("Janela principal configurada: desminimizada, always on top e em foco.")
    else:
        push_warning("Não foi possível acessar a janela principal!")