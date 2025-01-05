extends Control

func _ready():
	var total_collected = GameManager.get_total_collected()
	var stats_text = "COLLECTED COINS: " + str(total_collected) + "/" + str(GameManager.total_coins) + "\n\n"
	stats_text += "STATS BY LEVEL:\n"

	var level_stats = GameManager.get_level_stats().split("\n")
	for stat in level_stats:
		if stat != "":
			var parts = stat.split(":")
			if parts.size() == 2:
				stats_text += parts[0].to_upper() + ":" + parts[1] + "\n"

	$StatsLabel.text = stats_text

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
