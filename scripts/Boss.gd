extends CharacterBody2D

const SPEED = 200.0
const GRAVITY = 980.0

# 1 means facing right, -1 means facing left.
# Boss starts on the right side of the screen, facing left toward the Hero.
var facing_direction: int = -1

func _physics_process(delta: float) -> void:
	# Apply gravity when not standing on something
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Read keyboard input
	var direction := 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1

	# Update facing direction whenever the Boss moves
	if direction != 0:
		facing_direction = direction

	velocity.x = direction * SPEED

	# Move and handle collisions
	move_and_slide()
