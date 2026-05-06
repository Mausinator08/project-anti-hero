extends CharacterBody2D

# Emitted when Hero's health reaches 0 — GameManager listens for this
signal defeated

const GRAVITY = 980.0

# Hero returns here after every defeat
const SPAWN_POSITION = Vector2(172, 448)

var max_health: int = 100
var health: int = max_health
var is_dead: bool = false

# AI movement values — GameManager updates these on each respawn
var move_speed: int = 80
var stop_distance: float = 85.0

# Reference to the Boss node — found automatically when the scene loads
# Boss is a sibling of Hero under Main, so the path goes up (..) then to Boss
@onready var boss = $"../Boss"

func _physics_process(delta: float) -> void:
	# Do nothing while dead — wait for GameManager to call respawn()
	if is_dead:
		return

	# Apply gravity when not standing on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# --- AI Movement ---
	# How far away is the Boss (left edge to left edge)?
	var distance_to_boss: float = abs(boss.position.x - position.x)

	if distance_to_boss > stop_distance:
		# Walk toward the Boss
		# sign() returns -1 if Boss is to the left, +1 if Boss is to the right
		var direction: float = sign(boss.position.x - position.x)
		velocity.x = direction * move_speed
	else:
		# Close enough — stop and stand still
		velocity.x = 0

	move_and_slide()

func take_damage(amount: int) -> void:
	# Ignore damage while already dead
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

# Called by GameManager after the respawn delay
# Receives updated max health and move speed for this new attempt
func respawn(new_max_health: int, new_move_speed: int) -> void:
	max_health = new_max_health
	health = max_health
	move_speed = new_move_speed

	position = SPAWN_POSITION
	velocity = Vector2.ZERO
	is_dead = false

	print("Hero respawned! Health: ", health, " / ", max_health, " | Speed: ", move_speed)
