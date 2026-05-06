extends CharacterBody2D

const GRAVITY = 980.0

func _physics_process(delta: float) -> void:
	# Pull Hero downward when not standing on something
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Move and handle collisions. No input yet — Hero just stands there.
	move_and_slide()
