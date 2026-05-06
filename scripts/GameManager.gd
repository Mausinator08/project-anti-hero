extends Node

const MAX_DEFEATS: int = 15

var attempt_count: int = 0
var game_over: bool = false

@onready var hero = $"../Hero"
@onready var boss = $"../Boss"

@onready var boss_hp_label: Label       = $"../HUD/BossHPLabel"
@onready var hero_hp_label: Label       = $"../HUD/HeroHPLabel"
@onready var attempt_label: Label       = $"../HUD/AttemptLabel"
@onready var hero_speed_label: Label    = $"../HUD/HeroSpeedLabel"
@onready var hero_damage_label: Label   = $"../HUD/HeroDamageLabel"
@onready var hero_cooldown_label: Label = $"../HUD/HeroCooldownLabel"
@onready var result_label: Label        = $"../HUD/ResultLabel"
@onready var restart_label: Label       = $"../HUD/RestartLabel"

func _ready() -> void:
	hero.defeated.connect(_on_hero_defeated)
	boss.defeated.connect(_on_boss_defeated)
	print("GameManager ready. Hero begins attempt #1.")

func _process(_delta: float) -> void:
	boss_hp_label.text       = "Boss HP:        " + str(boss.health) + " / " + str(boss.MAX_HEALTH)
	hero_hp_label.text       = "Hero HP:        " + str(hero.health) + " / " + str(hero.max_health)
	attempt_label.text       = "Attempt:        " + str(attempt_count + 1)
	hero_speed_label.text    = "Hero Speed:     " + str(hero.move_speed)
	hero_damage_label.text   = "Hero Damage:    " + str(hero.attack_damage)
	hero_cooldown_label.text = "Hero Cooldown:  " + ("%.2f" % hero.attack_cooldown_duration) + "s"

	if game_over and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_hero_defeated() -> void:
	if game_over:
		return

	attempt_count += 1
	print("Attempt #", attempt_count, " ended.")

	if attempt_count >= MAX_DEFEATS:
		trigger_game_over("THE HERO'S WILL IS BROKEN")
	else:
		respawn_hero()

func _on_boss_defeated() -> void:
	if game_over:
		return
	trigger_game_over("THE BOSS HAS FALLEN")

func trigger_game_over(message: String) -> void:
	game_over = true
	print("GAME OVER: ", message)
	hero.set_game_over()
	boss.set_game_over()
	result_label.text = message
	result_label.visible = true
	restart_label.visible = true

func respawn_hero() -> void:
	await get_tree().create_timer(1.0).timeout

	if game_over:
		return

	# Use the DISPLAYED attempt number (what the HUD shows) so the scaling
	# functions read like the design table: "Attempt 4 starts tier 2."
	# attempt_count is 0-based internally; adding 1 gives the displayed number.
	var displayed_attempt: int = attempt_count + 1

	var new_max_health: int    = get_hero_health(displayed_attempt)
	var new_move_speed: int    = get_hero_speed(displayed_attempt)
	var new_attack_damage: int = get_hero_damage(displayed_attempt)
	var new_cooldown: float    = get_hero_cooldown(displayed_attempt)

	hero.respawn(new_max_health, new_move_speed, new_attack_damage, new_cooldown)

	print(
		"Attempt #", displayed_attempt,
		" | HP: ", new_max_health,
		" | Speed: ", new_move_speed,
		" | Damage: ", new_attack_damage,
		" | Cooldown: ", "%.2f" % new_cooldown, "s"
	)

# ---------------------------------------------------------------------------
# Scaling functions
# The 'attempt' parameter is always the DISPLAYED attempt number (1, 2, 3...)
# matching exactly what the HUD shows. This makes the tiers easy to read.
# ---------------------------------------------------------------------------

func get_hero_health(attempt: int) -> int:
	# Attempt 1 = 100, Attempt 2 = 110, Attempt 3 = 120, no cap
	return 100 + (attempt - 1) * 10

func get_hero_speed(attempt: int) -> int:
	# Attempt 1 = 80, Attempt 2 = 85 ... capped at 140
	return min(80 + (attempt - 1) * 5, 140)

func get_hero_damage(attempt: int) -> int:
	# Increases at milestone attempts — not every single attempt
	if attempt < 4:    # Attempts 1, 2, 3
		return 10
	elif attempt < 7:  # Attempts 4, 5, 6
		return 12
	elif attempt < 10: # Attempts 7, 8, 9
		return 15
	elif attempt < 13: # Attempts 10, 11, 12
		return 18
	else:              # Attempts 13 and beyond
		return 22

func get_hero_cooldown(attempt: int) -> float:
	# Shrinks at the same milestones as damage — Hero attacks faster each tier
	if attempt < 4:    # Attempts 1, 2, 3
		return 1.5
	elif attempt < 7:  # Attempts 4, 5, 6
		return 1.35
	elif attempt < 10: # Attempts 7, 8, 9
		return 1.2
	elif attempt < 13: # Attempts 10, 11, 12
		return 1.05
	else:              # Attempts 13 and beyond
		return 0.9
