extends CharacterBody2D

# Emitted when Boss HP reaches 0 — GameManager listens for this
signal defeated

const SPEED = 200.0
const GRAVITY = 980.0
const MAX_HEALTH: int = 300

var health: int = MAX_HEALTH
var facing_direction: int = -1
var is_attacking: bool = false

# Set to true by GameManager when the game ends
var game_over: bool = false

@onready var swipe_hitbox: Area2D = $SwipeHitbox

func _ready() -> void:
	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false

func _physics_process(delta: float) -> void:
	# Freeze completely when game is over
	if game_over:
		return

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

func set_game_over() -> void:
	# Called by GameManager when either win or loss condition is met
	game_over = true
	velocity = Vector2.ZERO

func perform_swipe() -> void:
	is_attacking = true

	if facing_direction == 1:
		swipe_hitbox.position = Vector2(80, 10)
	else:
		swipe_hitbox.position = Vector2(-70, 10)

	swipe_hitbox.monitoring = true
	swipe_hitbox.visible = true

	await get_tree().process_frame
	await get_tree().process_frame

	# Skip damage if game ended during the two-frame wait
	if not game_over:
		for body in swipe_hitbox.get_overlapping_bodies():
			if body == self:
				continue  # Never damage yourself
			if body.has_method("take_damage"):
				body.take_damage(25)

	await get_tree().create_timer(0.25).timeout

	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false
	is_attacking = false

func take_damage(amount: int) -> void:
	# Ignore damage if already defeated
	if health <= 0:
		return

	health -= amount
	print("Boss took ", amount, " damage. Health: ", health, " / ", MAX_HEALTH)

	if health <= 0:
		health = 0
		print("The Boss has been defeated!")
		defeated.emit()
