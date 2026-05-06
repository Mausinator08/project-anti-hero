extends CharacterBody2D

# Emitted when health reaches 0 — GameManager listens for this
signal defeated

const GRAVITY = 980.0
const SPAWN_POSITION = Vector2(172, 448)

const ATTACK_DAMAGE: int = 10
const ATTACK_COOLDOWN_DURATION: float = 1.5
const ATTACK_RANGE: float = 70.0
const STOP_DISTANCE: float = 65.0

var max_health: int = 100
var health: int = max_health
var move_speed: int = 80

var is_dead: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0

# Set to true by GameManager when the game ends
var game_over: bool = false

@onready var boss = $"../Boss"
@onready var strike_hitbox: Area2D = $StrikeHitbox

func _ready() -> void:
	strike_hitbox.monitoring = false
	strike_hitbox.visible = false

func _physics_process(delta: float) -> void:
	# Freeze completely when game is over or dead
	if is_dead or game_over:
		return

	# Apply gravity when airborne
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Count down attack cooldown
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# AI movement
	var distance_to_boss: float = abs(boss.position.x - position.x)

	if distance_to_boss > STOP_DISTANCE:
		var direction: float = sign(boss.position.x - position.x)
		velocity.x = direction * move_speed
	else:
		velocity.x = 0

	# AI attack
	if distance_to_boss <= ATTACK_RANGE and attack_cooldown <= 0.0 and not is_attacking:
		perform_strike()

	move_and_slide()

func set_game_over() -> void:
	# Called by GameManager when either win or loss condition is met
	game_over = true
	velocity = Vector2.ZERO

func perform_strike() -> void:
	is_attacking = true
	attack_cooldown = ATTACK_COOLDOWN_DURATION

	var direction_to_boss: float = sign(boss.position.x - position.x)
	if direction_to_boss >= 0:
		strike_hitbox.position = Vector2(60, 5)
	else:
		strike_hitbox.position = Vector2(-60, 5)

	strike_hitbox.monitoring = true
	strike_hitbox.visible = true

	await get_tree().process_frame
	await get_tree().process_frame

	# Skip damage if game ended during the two-frame wait
	if not game_over:
		for body in strike_hitbox.get_overlapping_bodies():
			if body == self:
				continue  # Never damage yourself
			if body.has_method("take_damage"):
				body.take_damage(ATTACK_DAMAGE)

	await get_tree().create_timer(0.2).timeout

	strike_hitbox.monitoring = false
	strike_hitbox.visible = false
	is_attacking = false

func take_damage(amount: int) -> void:
	# Ignore damage if already dead or game is over
	if is_dead or game_over:
		return

	health -= amount
	print("Hero took ", amount, " damage. Health: ", health, " / ", max_health)

	if health <= 0:
		health = 0
		die()

func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	print("The Hero has been defeated!")
	defeated.emit()

func respawn(new_max_health: int, new_move_speed: int) -> void:
	max_health = new_max_health
	health = max_health
	move_speed = new_move_speed
	position = SPAWN_POSITION
	velocity = Vector2.ZERO
	is_dead = false
	attack_cooldown = 0.0
	print("Hero respawned! Health: ", health, " / ", max_health)
