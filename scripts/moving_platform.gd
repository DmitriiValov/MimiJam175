@tool
extends Node2D

signal position_changed

@export_range(0.1, 20.0, 0.1) var duration: float = 15.0:
    set(value):
        duration = value
        _queue_update()

@export_group("Movement")
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

@export_range(0.0, 1.0, 0.01) var start_offset: float = 0.0:
    set(value):
        start_offset = value
        if Engine.is_editor_hint():
            _queue_update()

@export var start_pos: Vector2 = Vector2.ZERO:
    set(value):
        start_pos = value
        if start_position:
            start_position.position = value

@export var end_pos: Vector2 = Vector2(100, 0):
    set(value):
        end_pos = value
        if end_position:
            end_position.position = value
            movement_vector = value
            movement_x = value.x
            movement_y = value.y

@export var easing_curve: Curve

var platform: AnimatableBody2D
var path_line: Line2D
var positions_node: Node2D
var start_position: Marker2D
var end_position: Marker2D
var dragging_start: bool = false
var dragging_end: bool = false
var _update_queued: bool = false
var time: float = 0.0

func _enter_tree() -> void:
    if Engine.is_editor_hint():
        _initialize_nodes()

func _ready() -> void:
    _initialize_nodes()
    if not Engine.is_editor_hint():
        if path_line:
            path_line.visible = false
        time = 0.0
    else:
        if not easing_curve:
            create_default_curve()

func _initialize_nodes() -> void:
    if not is_node_ready():
        return

    platform = $AnimatableBody2D
    path_line = $PathLine

    if not positions_node:
        positions_node = $Positions if has_node("Positions") else Node2D.new()
        if not positions_node.is_inside_tree():
            positions_node.name = "Positions"
            add_child(positions_node)
            positions_node.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self

    if not start_position:
        start_position = positions_node.get_node_or_null("StartPosition")
        if not start_position:
            start_position = Marker2D.new()
            start_position.name = "StartPosition"
            positions_node.add_child(start_position)
            start_position.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
            start_position.position = start_pos

    if not end_position:
        end_position = positions_node.get_node_or_null("EndPosition")
        if not end_position:
            end_position = Marker2D.new()
            end_position.name = "EndPosition"
            positions_node.add_child(end_position)
            end_position.owner = get_tree().edited_scene_root if Engine.is_editor_hint() else self
            end_position.position = end_pos
            movement_vector = end_position.position
            movement_x = movement_vector.x
            movement_y = movement_vector.y

    _queue_update()

func _process(delta: float) -> void:
    if not is_node_ready() or not platform or not start_position or not end_position:
        return

    if Engine.is_editor_hint():
        if _update_queued:
            _do_full_update()
            _update_queued = false
    else:
        time = fmod(time + delta / duration, 2.0)
        update_position()

func update_position() -> void:
    if not is_node_ready() or not platform or not start_position or not end_position:
        return

    var current_time: float
    if Engine.is_editor_hint():
        current_time = start_offset
    else:
        current_time = time
        if current_time > 1.0:
            current_time = 2.0 - current_time

    var curved_t = easing_curve.sample(current_time) if easing_curve else current_time
    var target_pos = start_position.position.lerp(end_position.position, curved_t)
    platform.position = target_pos

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

    if Engine.is_editor_hint():
        if get_tree().edited_scene_root:
            get_tree().edited_scene_root.set_edited(true)

func draw_path() -> void:
    if not path_line or not start_position or not end_position:
        return

    path_line.clear_points()
    var steps = 20
    for i in range(steps + 1):
        var t = float(i) / steps
        var curved_t = easing_curve.sample(t) if easing_curve else t
        var pos = start_position.position.lerp(end_position.position, curved_t)
        path_line.add_point(pos)
    path_line.visible = Engine.is_editor_hint()

func create_default_curve() -> void:
    easing_curve = Curve.new()
    easing_curve.add_point(Vector2(0, 0), 0, 4.0)
    easing_curve.add_point(Vector2(0.5, 0.5), 0, 0)
    easing_curve.add_point(Vector2(1, 1), -4.0, 0)
