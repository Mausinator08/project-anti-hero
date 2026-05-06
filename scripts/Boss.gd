extends CharacterBody2D

const SPEED = 200.0
const GRAVITY = 980.0

# 1 = facing right, -1 = facing left
# Boss starts on the right side, so it begins facing left toward the Hero
var facing_direction: int = -1
var is_attacking: bool = false

# @onready means "find this node when the scene starts"
# $SwipeHitbox means "look for a child node named SwipeHitbox"
@onready var swipe_hitbox: Area2D = $SwipeHitbox

func _ready() -> void:
	# Make sure the hitbox starts hidden and inactive
	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false

func _physics_process(delta: float) -> void:
	# Apply gravity when not on the floor
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Read movement input
	var direction := 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1

	# Remember which way Boss is facing when moving
	if direction != 0:
		facing_direction = direction

	velocity.x = direction * SPEED
	move_and_slide()

	# Check for attack input — only if not already mid-attack
	if Input.is_action_just_pressed("boss_light_attack") and not is_attacking:
		perform_swipe()

func perform_swipe() -> void:
	is_attacking = true

	# Move the hitbox in front of Boss based on facing direction
	# Boss visual is 80px wide starting at x=0
	# Facing right: hitbox starts at the right edge (x=80)
	# Facing left:  hitbox ends at the left edge (x=0), so it starts at x=-70
	if facing_direction == 1:
		swipe_hitbox.position = Vector2(80, 10)
	else:
		swipe_hitbox.position = Vector2(-70, 10)

	# Show and activate the hitbox
	swipe_hitbox.monitoring = true
	swipe_hitbox.visible = true

	# Wait two physics frames so the engine can detect who is inside
	await get_tree().process_frame
	await get_tree().process_frame

	# Check every body currently inside the hitbox
	for body in swipe_hitbox.get_overlapping_bodies():
		# has_method checks if the body has a take_damage function
		# This avoids errors if something other than Hero is hit
		if body.has_method("take_damage"):
			body.take_damage(25)

	# Keep the hitbox visible for a moment so you can see it flash
	await get_tree().create_timer(0.25).timeout

	# Hide and deactivate the hitbox
	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false
	is_attacking = false
