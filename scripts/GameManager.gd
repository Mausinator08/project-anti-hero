extends Node

# Boss wins after this many Hero defeats
const MAX_DEFEATS: int = 15

var attempt_count: int = 0
var game_over: bool = false

# --- Node references ---
@onready var hero = $"../Hero"
@onready var boss = $"../Boss"

@onready var boss_hp_label: Label    = $"../HUD/BossHPLabel"
@onready var hero_hp_label: Label    = $"../HUD/HeroHPLabel"
@onready var attempt_label: Label    = $"../HUD/AttemptLabel"
@onready var hero_speed_label: Label = $"../HUD/HeroSpeedLabel"
@onready var result_label: Label     = $"../HUD/ResultLabel"
@onready var restart_label: Label    = $"../HUD/RestartLabel"

func _ready() -> void:
	# Listen for both defeat signals
	hero.defeated.connect(_on_hero_defeated)
	boss.defeated.connect(_on_boss_defeated)
	print("GameManager ready. Hero begins attempt #1.")

func _process(_delta: float) -> void:
	# Keep HUD updated every frame
	boss_hp_label.text    = "Boss HP:     " + str(boss.health) + " / " + str(boss.MAX_HEALTH)
	hero_hp_label.text    = "Hero HP:     " + str(hero.health) + " / " + str(hero.max_health)
	attempt_label.text    = "Attempt:     " + str(attempt_count + 1)
	hero_speed_label.text = "Hero Speed:  " + str(hero.move_speed)

	# Only listen for restart input after game is over
	if game_over and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_hero_defeated() -> void:
	# Ignore if game already ended
	if game_over:
		return

	attempt_count += 1
	print("Attempt #", attempt_count, " ended.")

	if attempt_count >= MAX_DEFEATS:
		# Boss wins — Hero has been defeated too many times
		trigger_game_over("THE HERO'S WILL IS BROKEN")
	else:
		respawn_hero()

func _on_boss_defeated() -> void:
	# Ignore if game already ended
	if game_over:
		return

	# Hero wins — Boss HP reached 0
	trigger_game_over("THE BOSS HAS FALLEN")

func trigger_game_over(message: String) -> void:
	game_over = true
	print("GAME OVER: ", message)

	# Stop both characters immediately
	hero.set_game_over()
	boss.set_game_over()

	# Show the result on screen
	result_label.text = message
	result_label.visible = true
	restart_label.visible = true

func respawn_hero() -> void:
	await get_tree().create_timer(1.0).timeout

	# Check again after the delay — game might have ended while waiting
	if game_over:
		return

	var new_max_health: int = 100 + (attempt_count * 10)
	var new_move_speed: int = 80 + (attempt_count * 5)

	hero.respawn(new_max_health, new_move_speed)
	print("Attempt #", attempt_count + 1, " | Speed: ", new_move_speed, " | Max Health: ", new_max_health)
