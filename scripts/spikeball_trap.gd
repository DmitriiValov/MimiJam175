@tool
extends Node2D

signal position_changed

var area: Area2D
var path_line: Line2D
var positions_node: Node2D
var start_position: Marker2D
var end_position: Marker2D

@export_range(0.1, 10.0, 0.1) var duration: float = 1.0:
	set(value):
		duration = value
		_queue_update()

@export_range(0.0, 1.0, 0.01) var start_offset: float = 0.0:
	set(value):
		start_offset = value
		if Engine.is_editor_hint():
			_queue_update()

@export_enum("Linear", "Quad", "Cubic", "Quart", "Quint", "Sine", "Expo", "Circ", "Back", "Bounce", "Elastic") var transition_type: String = "Quad":
	set(value):
		transition_type = value
		_queue_update()

@export_enum("In", "Out", "InOut", "OutIn") var ease_type: String = "InOut":
	set(value):
		ease_type = value
		_queue_update()

@export var easing_curve: Curve

@export_group("Movement", "movement_")
@export var movement_vector: Vector2 = Vector2(100, 0):
	set(value):
		movement_vector = value
		if Engine.is_editor_hint() and end_position and not dragging_start and not dragging_end:
			end_position.position = movement_vector
			_queue_update()

@export_range(-500, 500, 10) var movement_x: float = 100.0:
	set(value):
		if movement_x != value:
			movement_x = value
			movement_vector.x = value
			_queue_update()

@export_range(-500, 500, 10) var movement_y: float = 0.0:
	set(value):
		if movement_y != value:
			movement_y = value
			movement_vector.y = value
			_queue_update()

@export_group("Position Markers")
@export var start_pos: Vector2 = Vector2.ZERO:
	set(value):
		start_pos = value
		if start_position:
			start_position.position = value
			_queue_update()

@export var end_pos: Vector2 = Vector2(100, 0):
	set(value):
		end_pos = value
		if end_position:
			end_position.position = value
			movement_vector = value
			movement_x = value.x
			movement_y = value.y
			_queue_update()

var dragging_start: bool = false
var dragging_end: bool = false
var _update_queued: bool = false
var time: float = 0.0

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		var scene_root = get_tree().edited_scene_root
		if scene_root and scene_root != self:
			for child in get_children():
				if child.owner == null:
					child.set_owner(scene_root)
					for grandchild in child.get_children():
						if grandchild.owner == null:
							grandchild.set_owner(scene_root)
		_initialize_nodes()
		print("SpikeBall: _enter_tree called") # Отладочный вывод

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Принудительная инициализация в игровом режиме
		area = $Area2D
		path_line = $PathLine
		positions_node = $Positions
		start_position = $Positions/StartPosition
		end_position = $Positions/EndPosition

		if path_line:
			path_line.visible = false
		time = start_offset * 2.0
	else:
		_initialize_nodes()

func _initialize_nodes() -> void:
	if not is_node_ready():
		return

	area = $Area2D
	path_line = $PathLine
	positions_node = $Positions if has_node("Positions") else Node2D.new()
	if not positions_node.is_inside_tree():
		positions_node.name = "Positions"
		add_child(positions_node)
		positions_node.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self

	start_position = positions_node.get_node_or_null("StartPosition")
	if not start_position:
		start_position = Marker2D.new()
		start_position.name = "StartPosition"
		positions_node.add_child(start_position)
		start_position.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
		start_position.position = start_pos

	end_position = positions_node.get_node_or_null("EndPosition")
	if not end_position:
		end_position = Marker2D.new()
		end_position.name = "EndPosition"
		positions_node.add_child(end_position)
		end_position.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
		end_position.position = end_pos

	# Важно! Сохраняем начальные позиции
	start_pos = start_position.position
	end_pos = end_position.position
	movement_vector = end_position.position
	movement_x = movement_vector.x
	movement_y = movement_vector.y

	if Engine.is_editor_hint():
		_queue_update()
	else:
		path_line.visible = false # Принудительно скрываем path_line в игре

func _process(delta: float) -> void:
	if not area or not start_position or not end_position:
		return

	if Engine.is_editor_hint():
		# Проверяем изменение позиций маркеров
		if start_position.position != start_pos:
			start_pos = start_position.position
			_queue_update()
		if end_position.position != end_pos:
			end_pos = end_position.position
			movement_vector = end_position.position
			movement_x = movement_vector.x
			movement_y = movement_vector.y
			_queue_update()

		if _update_queued:
			_do_full_update()
			_update_queued = false
	else:
		# Игровой режим
		time = fmod(time + delta / duration, 2.0)
		update_position()

func update_position() -> void:
	if not is_node_ready() or not area or not start_position or not end_position:
		return

	var current_time: float
	if Engine.is_editor_hint():
		current_time = start_offset
	else:
		current_time = time
		if current_time > 1.0:
			current_time = 2.0 - current_time

	var curved_t = get_eased_value(current_time)
	var target_pos = start_position.position.lerp(end_position.position, curved_t)
	area.position = target_pos

	if not Engine.is_editor_hint():
		position_changed.emit()

func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint() or not start_position or not end_position:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()

		if event.pressed:
			var start_dist = mouse_pos.distance_to(start_position.position)
			var end_dist = mouse_pos.distance_to(end_position.position)

			if start_dist < 20:
				dragging_start = true
				get_tree().set_input_as_handled()
			elif end_dist < 20:
				dragging_end = true
				get_tree().set_input_as_handled()
		else:
			if dragging_start or dragging_end:
				# Сохраняем позиции при отпускании
				start_pos = start_position.position
				end_pos = end_position.position
				movement_vector = end_position.position
				movement_x = movement_vector.x
				movement_y = movement_vector.y
				dragging_start = false
				dragging_end = false
				_queue_update()
				get_tree().set_input_as_handled()

	elif event is InputEventMouseMotion:
		if dragging_start:
			start_position.position = get_local_mouse_position()
			start_pos = start_position.position
			_queue_update()
			get_tree().set_input_as_handled()
		elif dragging_end:
			end_position.position = get_local_mouse_position()
			end_pos = end_position.position
			movement_vector = end_position.position
			movement_x = movement_vector.x
			movement_y = movement_vector.y
			_queue_update()
			get_tree().set_input_as_handled()

func _queue_update() -> void:
	_update_queued = true

func _do_full_update() -> void:
	update_position()
	draw_path()

	if start_position and end_position:
		start_pos = start_position.position
		end_pos = end_position.position
		movement_vector = end_position.position
		movement_x = movement_vector.x
		movement_y = movement_vector.y

func draw_path() -> void:
	if not path_line or not start_position or not end_position:
		return

	path_line.clear_points()
	var steps = 20
	for i in range(steps + 1):
		var t = float(i) / steps
		var curved_t = get_eased_value(t)
		var pos = start_position.position.lerp(end_position.position, curved_t)
		path_line.add_point(pos)
	path_line.visible = Engine.is_editor_hint()

func create_default_curve() -> void:
	easing_curve = Curve.new()
	# Easy In Easy Out кривая с более выраженным эффектом
	easing_curve.add_point(Vector2(0, 0), 0, 4.0) # Более сильный Easy In
	easing_curve.add_point(Vector2(0.5, 0.5), 0, 0) # Средняя точка для более плавного перехода
	easing_curve.add_point(Vector2(1, 1), -4.0, 0) # Более сильный Easy Out

func get_eased_value(linear: float) -> float:
	var t = linear

	if ease_type == "InOut":
		t = t * t * (3.0 - 2.0 * t) # Smooth step для InOut
	elif ease_type == "In":
		t = t * t # Quad In
	elif ease_type == "Out":
		t = t * (2.0 - t) # Quad Out
	elif ease_type == "OutIn":
		t = t * t * (t * -2.0 + 3.0) # Обратный Smooth step

	return t
