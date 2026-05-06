extends Node

var attempt_count: int = 0

# Hero is a sibling of GameManager under Main
@onready var hero = $"../Hero"

func _ready() -> void:
	# Subscribe to Hero's defeated signal
	hero.defeated.connect(_on_hero_defeated)
	print("GameManager ready. Attempt #1 | Speed: 80 | Max Health: 100")

func _on_hero_defeated() -> void:
	attempt_count += 1
	print("Attempt #", attempt_count, " ended. Respawning in 1 second...")
	respawn_hero()

func respawn_hero() -> void:
	# Wait 1 second before bringing the Hero back
	await get_tree().create_timer(1.0).timeout

	# Calculate scaled stats for this attempt
	var new_max_health: int = 100 + (attempt_count * 10)
	var new_move_speed: int = 80 + (attempt_count * 5)

	# Pass both values into Hero's respawn function
	hero.respawn(new_max_health, new_move_speed)
	print("Attempt #", attempt_count + 1, " | Speed: ", new_move_speed, " | Max Health: ", new_max_health)
