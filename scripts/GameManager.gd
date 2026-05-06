extends Node

# Tracks how many times the Hero has been defeated
var attempt_count: int = 0

# Get a reference to the Hero node
# GameManager and Hero are both children of Main, so we go up (..) then back down
@onready var hero = $"../Hero"

func _ready() -> void:
	# Listen for the Hero's defeated signal
	hero.defeated.connect(_on_hero_defeated)
	print("GameManager ready. Hero begins attempt #1.")

func _on_hero_defeated() -> void:
	# This runs every time Hero emits the defeated signal
	attempt_count += 1
	print("Attempt #", attempt_count, " ended. Respawning in 1 second...")
	respawn_hero()

func respawn_hero() -> void:
	# Wait 1 second before bringing the Hero back
	await get_tree().create_timer(1.0).timeout

	# Base max health is 100, gains 10 for each completed attempt
	var new_max_health: int = 100 + (attempt_count * 10)

	# Tell the Hero to reset itself with the new max health
	hero.respawn(new_max_health)
	print("Hero begins attempt #", attempt_count + 1, " with ", new_max_health, " max health.")
