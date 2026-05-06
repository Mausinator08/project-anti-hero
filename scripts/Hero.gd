extends CharacterBody2D

# This signal is emitted when Hero's health reaches 0
# GameManager listens for this
signal defeated

const GRAVITY = 980.0

# The position Hero returns to after every defeat
const SPAWN_POSITION = Vector2(172, 448)

var max_health: int = 100
var health: int = max_health

# When true, Hero ignores gravity, movement, and damage
# This prevents anything from happening during the respawn delay
var is_dead: bool = false

func _physics_process(delta: float) -> void:
	# Do nothing while dead — wait for GameManager to call respawn()
	if is_dead:
		return

	# Apply gravity when not standing on something
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	move_and_slide()

func take_damage(amount: int) -> void:
	# Ignore any damage that arrives while Hero is already dead
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

	# Broadcast the defeated signal — GameManager will hear this
	defeated.emit()

func respawn(new_max_health: int) -> void:
	# Update max health and refill it
	max_health = new_max_health
	health = max_health

	# Move Hero back to its starting position
	position = SPAWN_POSITION
	velocity = Vector2.ZERO

	# Re-enable physics and damage
	is_dead = false

	print("Hero respawned! Health: ", health, " / ", max_health)
