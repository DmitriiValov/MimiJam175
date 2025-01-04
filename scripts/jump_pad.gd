extends Area2D

@export var jump_force = -500
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		animated_sprite.play("jump")
		AudioPlayer.play_sfx("jump")
		body.jump(jump_force)
