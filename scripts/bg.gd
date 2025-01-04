extends ParallaxBackground

@onready var sprite = $ParallaxLayer/Sprite2D

@export var bg_rexture: CompressedTexture2D = preload("res://assets/textures/bg/Blue.png")

@export var scroll_speed = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = bg_rexture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite.region_rect.position += delta * Vector2(scroll_speed, scroll_speed)
	if sprite.region_rect.position >= Vector2(64, 64):
		sprite.region_rect.position = Vector2.ZERO	
	
