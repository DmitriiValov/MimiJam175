extends CharacterBody2D
class_name Player

signal touched_player

const SPEED = 110.0
const DASH_SPEED = 800.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_timer = $DashTimer
@onready var can_dash_timer = $CanDashTimer

var active = true
var direction = 1
var gravity = true
var in_jump = false
var dashing = false
var can_dash = true
	
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
		if Input.is_action_just_pressed("jump") and is_on_floor() && gravity == true:
			jump(JUMP_VELOCITY)
			AudioPlayer.play_sfx("jump")
		elif Input.is_action_just_pressed("jump") and is_on_ceiling() && gravity == false:
			jump(-JUMP_VELOCITY)
			AudioPlayer.play_sfx("jump")
						
		if Input.get_axis("move_left", "move_right") != 0:
			direction = Input.get_axis("move_left", "move_right")
								
		if is_on_wall():
			direction *= -1
			velocity.x = SPEED
			dashing = false
	
	
	if direction:
		animated_sprite.flip_h = (direction == -1)
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	update_animations(direction)

	move_and_slide()


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
	if Input.is_action_just_pressed("dash") && can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		can_dash_timer.start()

func reset():
	direction = 1
	gravity = true
	animated_sprite.flip_v = false
	animated_sprite.position = Vector2(0.0, -10.0)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	touched_player.emit()

func _on_dash_timer_timeout() -> void:
	dashing = false

func _on_can_dash_timer_timeout() -> void:
	can_dash = true
