extends Area2D

signal coin_collected

func _ready():
    body_entered.connect(_on_body_entered)

func _on_body_entered(body):
    if body is Player:
        coin_collected.emit()
        AudioPlayer.play_sfx("coin")
        queue_free()
