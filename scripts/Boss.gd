extends CharacterBody2D

const SPEED = 200.0
const GRAVITY = 980.0

func _physics_process(delta: float) -> void:
	# Pull the boss downward when not standing on something
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Check keyboard input for left/right movement
	var direction := 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1

	velocity.x = direction * SPEED

	# Move the body and automatically handle collisions
	move_and_slide()
