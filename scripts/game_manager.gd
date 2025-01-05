extends Node

var total_coins = 56
var collected_coins = {
    "level1": 0,
    "level2": 0,
    "level3": 0,
    "level4": 0
}

var max_coins_per_level = {
    "level1": 15,
    "level2": 11,
    "level3": 13,
    "level4": 17
}

func add_coin(level_name: String):
    if collected_coins.has(level_name):
        collected_coins[level_name] += 1

func get_total_collected():
    var total = 0
    for level in collected_coins.keys():
        total += collected_coins[level]
    return total

func get_level_stats() -> String:
    var stats = ""
    for level in collected_coins.keys():
        stats += level + ": " + str(collected_coins[level]) + "/" + str(max_coins_per_level[level]) + "\n"
    return stats
