extends Node

var attempt_count: int = 0

# --- Node references ---
# Hero and Boss are siblings of GameManager under Main
@onready var hero = $"../Hero"
@onready var boss = $"../Boss"

# Labels live inside HUD, which is also a sibling under Main
@onready var boss_hp_label: Label    = $"../HUD/BossHPLabel"
@onready var hero_hp_label: Label    = $"../HUD/HeroHPLabel"
@onready var attempt_label: Label    = $"../HUD/AttemptLabel"
@onready var hero_speed_label: Label = $"../HUD/HeroSpeedLabel"

func _ready() -> void:
	# Listen for Hero defeat
	hero.defeated.connect(_on_hero_defeated)
	print("GameManager ready. Hero begins attempt #1.")

func _process(_delta: float) -> void:
	# This runs every frame and keeps all four labels current
	# No manual update calls needed anywhere else
	boss_hp_label.text    = "Boss HP:     " + str(boss.health) + " / " + str(boss.MAX_HEALTH)
	hero_hp_label.text    = "Hero HP:     " + str(hero.health) + " / " + str(hero.max_health)
	attempt_label.text    = "Attempt:     " + str(attempt_count + 1)
	hero_speed_label.text = "Hero Speed:  " + str(hero.move_speed)

func _on_hero_defeated() -> void:
	attempt_count += 1
	print("Attempt #", attempt_count, " ended. Respawning in 1 second...")
	respawn_hero()

func respawn_hero() -> void:
	await get_tree().create_timer(1.0).timeout

	var new_max_health: int = 100 + (attempt_count * 10)
	var new_move_speed: int = 80 + (attempt_count * 5)

	hero.respawn(new_max_health, new_move_speed)
	print("Attempt #", attempt_count + 1, " | Speed: ", new_move_speed, " | Max Health: ", new_max_health)
