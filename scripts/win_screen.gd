extends Control

func _ready():
	var total_collected = GameManager.get_total_collected()
	var stats_text = "Collected coins: " + str(total_collected) + "/" + str(GameManager.total_coins) + "\n\n"
	stats_text += "Stats by level:\n" + GameManager.get_level_stats()
	$StatsLabel.text = stats_text

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
