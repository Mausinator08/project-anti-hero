extends CharacterBody2D

# Emitted when health reaches 0 — GameManager listens for this
signal defeated

const GRAVITY = 980.0

# Hero returns to this position after every defeat
const SPAWN_POSITION = Vector2(172, 448)

# --- Combat constants ---
const ATTACK_DAMAGE: int = 10
const ATTACK_COOLDOWN_DURATION: float = 1.5
const ATTACK_RANGE: float = 70.0   # Hero attacks when within this distance of Boss
const STOP_DISTANCE: float = 65.0  # Hero stops walking here — inside ATTACK_RANGE

# --- Stats (scaled by GameManager on each respawn) ---
var max_health: int = 100
var health: int = max_health
var move_speed: int = 80

# --- State flags ---
var is_dead: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0

# --- Node references ---
# $"../Boss"  = go up to Main, then find the Boss node
# $StrikeHitbox = direct child of this Hero node
@onready var boss = $"../Boss"
@onready var strike_hitbox: Area2D = $StrikeHitbox

func _ready() -> void:
	# Hitbox starts hidden and inactive — only turns on during an attack
	strike_hitbox.monitoring = false
	strike_hitbox.visible = false

func _physics_process(delta: float) -> void:
	# Skip all logic while dead
	if is_dead:
		return

	# Apply gravity when airborne
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Count down the attack cooldown every frame
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# --- AI Movement ---
	var distance_to_boss: float = abs(boss.position.x - position.x)

	if distance_to_boss > STOP_DISTANCE:
		# Walk toward Boss
		var direction: float = sign(boss.position.x - position.x)
		velocity.x = direction * move_speed
	else:
		# In position — stop walking
		velocity.x = 0

	# --- AI Attack ---
	# Trigger a strike when: close enough, cooldown expired, not mid-swing
	if distance_to_boss <= ATTACK_RANGE and attack_cooldown <= 0.0 and not is_attacking:
		perform_strike()

	move_and_slide()

func perform_strike() -> void:
	is_attacking = true
	attack_cooldown = ATTACK_COOLDOWN_DURATION

	# Place the hitbox on whichever side the Boss is on
	# Hero visual is 60px wide starting at x=0
	# Facing right: hitbox starts at right edge (x=60)
	# Facing left:  hitbox ends at left edge (x=0), starts at x=-60
	var direction_to_boss: float = sign(boss.position.x - position.x)
	if direction_to_boss >= 0:
		strike_hitbox.position = Vector2(60, 5)
	else:
		strike_hitbox.position = Vector2(-60, 5)

	# Activate and show the hitbox
	strike_hitbox.monitoring = true
	strike_hitbox.visible = true

	# Wait two physics frames so the engine registers who is inside
	await get_tree().process_frame
	await get_tree().process_frame

	# Deal damage to anything inside the hitbox that has take_damage()
	for body in strike_hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(ATTACK_DAMAGE)

	# Keep hitbox visible briefly, then hide it
	await get_tree().create_timer(0.2).timeout

	strike_hitbox.monitoring = false
	strike_hitbox.visible = false
	is_attacking = false

func take_damage(amount: int) -> void:
	if is_dead:
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
	attack_cooldown = 0.0  # Reset so Hero can attack immediately after respawn
	print("Hero respawned! Health: ", health, " / ", max_health, " | Speed: ", move_speed)
