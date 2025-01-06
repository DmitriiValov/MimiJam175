extends Control

func _ready():
	update_stats()

func update_stats():
	print("\n=== Updating Win Screen Stats ===")
	for level in range(1, GameState.total_levels + 1):
		var label = get_node("StatsContainer/Level%dStats" % level)
		if label:
			var coins = GameState.get_level_coins(level)
			var max_coins = GameState.get_level_max_coins(level)
			print("Level ", level, " stats - Coins: ", coins, "/", max_coins)
			label.text = "LEVEL %d: %d/%d" % [level, coins, max_coins]

	var total = GameState.get_total_coins()
	var max_total = GameState.get_max_total_coins()
	print("Total stats - Coins: ", total, "/", max_total)

	var total_label = $StatsContainer/TotalStats
	if total_label:
		total_label.text = "TOTAL: %d/%d" % [total, max_total]
	print("=== Win Screen Update Complete ===\n")

func _on_button_pressed():
	GameState.reset_progress()
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
