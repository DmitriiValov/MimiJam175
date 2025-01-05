extends Node2D

@onready var start_position = $Start
@onready var exit = $Exit
@onready var death_zone_down = $DeathzoneDown
@onready var death_zone_up = $DeathzoneUp
@onready var audio_player = AudioPlayer

@onready var hud = $UILayer/HUD
@onready var ui_layer = $UILayer

@export var next_level: PackedScene = null
@export var level_time = 200
@export var is_final_level: bool = false

var player = null
var timer_node = null
var time_left
var win = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.global_position = start_position.get_spawn_position()
	var traps = get_tree().get_nodes_in_group("traps")
	for trap in traps:
		trap.connect("touched_player", _on_trap_touched_player)
	player.connect("touched_player", _on_trap_touched_player)
	exit.body_entered.connect(_on_exit_body_entered)
	death_zone_down.body_entered.connect(_on_deathzone_body_entered)
	death_zone_up.body_entered.connect(_on_deathzone_body_entered)

	time_left = level_time
	hud.set_time_label(time_left)

	timer_node = Timer.new()
	timer_node.name = "Level Timer"
	timer_node.wait_time = 1
	timer_node.timeout.connect(_on_level_timer_timeout)
	add_child(timer_node)
	timer_node.start()

	var coins = get_tree().get_nodes_in_group("coins")
	for coin in coins:
		coin.coin_collected.connect(_on_coin_collected)

func _on_coin_collected():
		hud.add_coin()

func _on_level_timer_timeout():
	if win == false:
		time_left -= 1
		hud.set_time_label(time_left)
		if time_left < 0:
			reset_player()
			time_left = level_time
			hud.set_time_label(time_left)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("skip_level"):
		load_next_level()


func _on_deathzone_body_entered(_body: CharacterBody2D) -> void:
	audio_player.play_sfx("hurt")
	reset_player()


func _on_trap_touched_player() -> void:
	audio_player.play_sfx("hurt")
	reset_player()

func reset_player():
	player.velocity = Vector2.ZERO
	player.global_position = start_position.get_spawn_position()
	hud.set_coins_label(0)
	player.reset()

func _on_exit_body_entered(body):
	if body is Player:
		load_next_level()

func load_next_level():
	if is_final_level || next_level != null:
		exit.animate()
		audio_player.play_sfx("win")
		win = true
		player.active = false
		await get_tree().create_timer(1.5).timeout
		if is_final_level:
			ui_layer.show_win_screen(true)
		else:
			get_tree().change_scene_to_packed(next_level)
