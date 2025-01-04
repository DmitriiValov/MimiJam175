extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var area = $Area2D

@export var new_postion = Vector2(100.0, 0.0)
@export var duration = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		var anim_lib = AnimationLibrary.new()
	
		var anim = Animation.new()
		anim.length = duration * 2
		anim.loop_mode = 1
		anim.step = 0.1
		
		var track_index = anim.add_track(Animation.TYPE_VALUE)
		var path: NodePath = "%s:position" % area.get_path()
		anim.track_set_path(track_index, path)
		anim.track_set_interpolation_loop_wrap(track_index, true)
		anim.track_set_enabled(track_index, true)
		anim.track_set_interpolation_type(track_index, Animation.INTERPOLATION_CUBIC)
		anim.track_insert_key(track_index, 0.0, Vector2(0, 0))
		anim.track_insert_key(track_index, duration, new_postion)
		
		anim_lib.add_animation("move", anim)
		animation_player.add_animation_library("lib", anim_lib)
		animation_player.play("lib/move")
