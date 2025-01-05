extends CanvasLayer

@onready var win_screen = $WinScreen

func show_win_screen(value: bool):
	if win_screen:
		win_screen.visible = value
