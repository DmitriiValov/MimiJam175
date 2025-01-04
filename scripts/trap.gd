extends Node2D

signal touched_player

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		touched_player.emit()
