extends Node2D

@export var level_number: int = 1

@onready var start_position = $Start
@onready var exit = $Exit
@onready var death_zone_down = $DeathzoneDown
@onready var death_zone_up = $DeathzoneUp
@onready var audio_player = get_node("/root/AudioPlayer")

@onready var hud = $UILayer/HUD
@onready var ui_layer = $UILayer

@export var next_level: PackedScene = null
@export var is_final_level: bool = false

var player = null
var win = false

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout

	print("Setting level number: ", level_number)
	var scene_path = get_scene_file_path()
	var level_num = scene_path.split("/")[-1].replace("level", "").replace(".tscn", "").to_int()
	if level_num == 0:
		level_num = 1
	GameState.set_current_level(level_num)

	# Ждем пока сцена полностью загрузится
	await get_tree().process_frame

	# Используем существующего игрока из сцены
	player = $Player
	if player == null:
		push_error("Player node not found in the scene!")
		return

	# Добавляем игрока в группу, если он еще не в ней
	if not player.is_in_group("player"):
		player.add_to_group("player")

	if start_position:
		player.global_position = start_position.get_spawn_position()

	var traps = get_tree().get_nodes_in_group("traps")
	for trap in traps:
		if trap.has_signal("touched_player"):
			trap.connect("touched_player", _on_trap_touched_player)

	if player.has_signal("touched_player"):
		player.connect("touched_player", _on_trap_touched_player)

	if exit != null && exit.has_signal("body_entered"):
		exit.body_entered.connect(_on_exit_body_entered)

	if death_zone_down != null:
		death_zone_down.body_entered.connect(_on_deathzone_body_entered)

	if death_zone_up != null:
		death_zone_up.body_entered.connect(_on_deathzone_body_entered)

	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		coin.coin_collected.connect(_on_coin_collected)

func _on_coin_collected():
	GameState.add_coin()
	hud.add_coin()

func _on_deathzone_body_entered(_body: CharacterBody2D) -> void:
	audio_player.play_sfx("hurt")
	reset_player()

func _on_trap_touched_player() -> void:
	audio_player.play_sfx("hurt")
	reset_player()

func reset_player():
	player.velocity = Vector2.ZERO
	player.global_position = start_position.get_spawn_position()
	player.reset()

func _on_exit_body_entered(body):
	if body is Player:
		load_next_level()

func load_next_level():
	if is_final_level:
		exit.animate()
		audio_player.play_sfx("win")
		win = true
		player.active = false
		player.die()
		await get_tree().create_timer(1.5).timeout
		var win_screen_scene = preload("res://scenes/win_screen.tscn")
		if win_screen_scene:
			get_tree().change_scene_to_packed(win_screen_scene)
		else:
			push_error("Failed to load win screen scene!")
	elif next_level != null:
		exit.animate()
		audio_player.play_sfx("win")
		win = true
		player.active = false
		player.die()
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_packed(next_level)
