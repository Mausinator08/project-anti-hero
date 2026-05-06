extends CharacterBody2D

const SPEED = 200.0
const GRAVITY = 980.0
const MAX_HEALTH: int = 300

# Boss health persists across Hero attempts — this is intentional
# The Hero chips away at the Boss over multiple runs
var health: int = MAX_HEALTH

var facing_direction: int = -1
var is_attacking: bool = false

@onready var swipe_hitbox: Area2D = $SwipeHitbox

func _ready() -> void:
	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false

func _physics_process(delta: float) -> void:
	# Apply gravity when airborne
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Read player movement input
	var direction := 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1

	if direction != 0:
		facing_direction = direction

	velocity.x = direction * SPEED
	move_and_slide()

	# Check for attack input
	if Input.is_action_just_pressed("boss_light_attack") and not is_attacking:
		perform_swipe()

func perform_swipe() -> void:
	is_attacking = true

	# Place hitbox in front of Boss based on facing direction
	if facing_direction == 1:
		swipe_hitbox.position = Vector2(80, 10)
	else:
		swipe_hitbox.position = Vector2(-70, 10)

	swipe_hitbox.monitoring = true
	swipe_hitbox.visible = true

	await get_tree().process_frame
	await get_tree().process_frame

	for body in swipe_hitbox.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(25)

	await get_tree().create_timer(0.25).timeout

	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false
	is_attacking = false

func take_damage(amount: int) -> void:
	if health <= 0:
		return  # Already defeated, ignore further damage

	health -= amount
	print("Boss took ", amount, " damage. Health: ", health, " / ", MAX_HEALTH)

	if health <= 0:
		health = 0
		print("The Boss has been defeated! (No win condition yet)")
