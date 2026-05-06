extends CharacterBody2D

const GRAVITY = 980.0
const MAX_HEALTH = 100

var health: int = MAX_HEALTH

func _physics_process(delta: float) -> void:
	# Apply gravity when not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# No movement yet — Hero just stands still
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print("Hero took ", amount, " damage. Health remaining: ", health)

	if health <= 0:
		health = 0
		print("The Hero has been defeated! (Respawn not yet implemented)")
