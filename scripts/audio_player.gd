extends Node

@onready var music_player = $MusicPlayer

var hurt = preload("res://assets/audio/hurt.wav")
var jump = preload("res://assets/audio/jump.wav")
var win = preload("res://assets/audio/hurt.wav")
var coin = preload("res://assets/audio/coin.wav")

func _ready() -> void:
	music_player.connect("finished", Callable(self,"_on_loop_sound").bind(music_player))
	#music_player.play()
	
func play_sfx(sfx_name: String):
	var stream = null
	if sfx_name == "hurt":
		stream = hurt
	elif sfx_name == "jump":
		stream = jump
	elif sfx_name == "win":
		stream = win
	elif sfx_name == "coin":
		stream = coin
	else:
		print("Invalid sfx name")
		return

	var asp = AudioStreamPlayer.new()
	asp.stream = stream
	asp.name = "SFX"

	add_child(asp)

	asp.play()

	await asp.finished
	asp.queue_free()
	
func _on_loop_sound():
	music_player.stream_paused = false
	music_player.play()
