extends CharacterBody2D
class_name Player

signal touched_player

const SPEED = 110.0
const DASH_SPEED = 900.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var can_dash_timer = $CanDashTimer
@onready var glow_sprite = $Glow
@onready var trail_timer = Timer.new()

var active = true
var direction = 1
var gravity = true
var in_jump = false
var dashing = false
var can_dash = true
var creating_trail = false

func _ready():
	add_to_group("player")
	trail_timer.wait_time = 1.1

	trail_timer.one_shot = true
	trail_timer.timeout.connect(_on_trail_timer_timeout)
	add_child(trail_timer)

	# Начальное состояние свечения
	glow_sprite.visible = can_dash

func _physics_process(delta: float) -> void:
	change_gravity()
	dash()

	# Add the gravity.
	if not is_on_floor() && gravity == true:
		velocity += get_gravity() * delta
		if velocity.y > 500:
			velocity.y = 500
	elif not is_on_ceiling() && gravity == false:
		velocity += get_gravity() * -delta
		if velocity.y < -500:
			velocity.y = -500

	if active == true:
		# Обработка прыжка
		if Input.is_action_just_pressed("jump") and is_on_floor() && gravity == true:
			jump(JUMP_VELOCITY)
			AudioPlayer.play_sfx("jump")
		elif Input.is_action_just_pressed("jump") and is_on_ceiling() && gravity == false:
				jump(-JUMP_VELOCITY)
				AudioPlayer.play_sfx("jump")

		# Изменение направления движения
		var input_direction = Input.get_axis("move_left", "move_right")
		if input_direction != 0:
			direction = sign(input_direction) # Используем только знак (-1 или 1)

		if is_on_wall():
			if !Input.is_action_pressed("move_left") && !Input.is_action_pressed("move_right"):
				direction *= -1
				velocity.x = SPEED
				dashing = false

	# Всегда двигаемся в текущем направлении
	if dashing:
		velocity.x = direction * DASH_SPEED
	else:
		velocity.x = direction * SPEED

	animated_sprite.flip_h = (direction == -1)
	update_animations(direction)
	move_and_slide()

	if !dashing && creating_trail:
		if !trail_timer.is_stopped():
			trail_timer.stop()
		trail_timer.start()
		creating_trail = false

func update_animations(_direction):
	if (is_on_floor() && gravity == true) || (is_on_ceiling() && gravity == false):
		if _direction != 0:
			animated_sprite.play("run")
	else:
		if (velocity.y < 0 && gravity == true) || (velocity.y > 0 && gravity == false):
			if in_jump == false:
				animated_sprite.play("jump")
				in_jump = true
		elif (velocity.y > 0 && gravity == true) || (velocity.y < 0 && gravity == false):
			if in_jump == true:
				animated_sprite.play("fall")
				in_jump = false

func jump(force):
	velocity.y = force

func change_gravity():
	if Input.is_action_just_pressed("change_gravity"):
		if gravity == false && is_on_ceiling() == true:
			gravity = true
			AudioPlayer.play_sfx("jump")
			animated_sprite.flip_v = false
			animated_sprite.position = Vector2(0.0, -10.0)
		elif gravity == true && is_on_floor() == true:
			gravity = false
			AudioPlayer.play_sfx("jump")
			animated_sprite.flip_v = true
			animated_sprite.position = Vector2(0.0, 10.0)

func dash():
	if Input.is_action_just_pressed("dash") && can_dash && active:
		dashing = true
		creating_trail = true
		can_dash = false
		glow_sprite.visible = false # Выключаем свечение при использовании dash
		dash_timer.start()
		can_dash_timer.start()
		AudioPlayer.play_sfx("dash")

	if dashing:
		velocity.x = direction * DASH_SPEED
		create_ghost()

func create_ghost():
	var ghost = Sprite2D.new()
	ghost.texture = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, animated_sprite.frame)
	ghost.global_position = global_position + animated_sprite.position * scale
	ghost.scale = scale
	ghost.flip_h = animated_sprite.flip_h
	ghost.flip_v = animated_sprite.flip_v
	ghost.modulate = Color(1, 1, 1, 0.5)
	get_parent().add_child(ghost)

	ghost.add_to_group("ghost_sprites")

	var tween = create_tween(

	)
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): ghost.queue_free())

func reset():
	direction = 1
	gravity = true
	animated_sprite.flip_v = false
	animated_sprite.position = Vector2(0.0, -10.0)

	# Сброс состояния dash и свечения
	can_dash = true
	dashing = false
	creating_trail = false
	glow_sprite.visible = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	touched_player.emit()

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_trail_timer_timeout() -> void:
	creating_trail = false

func _on_can_dash_timer_timeout() -> void:
	can_dash = true
	glow_sprite.visible = true

func die():
	direction = 0
