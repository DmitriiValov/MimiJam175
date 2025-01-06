extends Control


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level.tscn")


func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		_on_start_btn_pressed()
	#elif Input.is_action_just_pressed("escape"):
		#_on_quit_btn_pressed()
