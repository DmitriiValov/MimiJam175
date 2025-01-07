extends Control

var coins = 0

#func set_time_label(value):
	#$TimerLabel.text = "TIME: " + str(value)

func set_coins_label(value):
	coins = value
	$CoinsLabel.text = "COINS: " + str(coins)

func add_coin():
	coins += 1
	set_coins_label(coins)
