extends CharacterBody2D

# Emitted when Boss HP reaches 0 — GameManager listens for this
signal defeated

const SPEED = 200.0
const GRAVITY = 980.0
const MAX_HEALTH: int = 300

# --- Light attack: Backhand Swipe ---
const SWIPE_DAMAGE: int = 25

# --- Heavy attack: Ground Slam ---
const SLAM_DAMAGE: int = 50
const SLAM_COOLDOWN: float = 2.0   # seconds before Slam can be used again
const SLAM_WINDUP: float = 0.35    # warning visible before damage activates
const SLAM_ACTIVE_TIME: float = 0.3 # how long hitbox stays active after windup

var health: int = MAX_HEALTH
var facing_direction: int = -1

var is_attacking: bool = false  # true while Backhand Swipe is executing
var is_slamming: bool = false   # true while Ground Slam is executing
var slam_cooldown: float = 0.0  # counts down between Slam uses

var game_over: bool = false

@onready var swipe_hitbox: Area2D = $SwipeHitbox
@onready var slam_hitbox: Area2D  = $SlamHitbox

func _ready() -> void:
	# Both hitboxes start hidden and inactive
	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false
	slam_hitbox.monitoring = false
	slam_hitbox.visible = false

func _physics_process(delta: float) -> void:
	if game_over:
		return

	# Apply gravity when airborne
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Read movement input
	var direction := 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	elif Input.is_action_pressed("move_right"):
		direction = 1

	if direction != 0:
		facing_direction = direction

	velocity.x = direction * SPEED
	move_and_slide()

	# Count down Slam cooldown every frame
	if slam_cooldown > 0.0:
		slam_cooldown -= delta

	# Light attack — blocked while Slam is running
	if Input.is_action_just_pressed("boss_light_attack") and not is_attacking and not is_slamming:
		perform_swipe()

	# Heavy attack — blocked while Swipe is running, and while on cooldown
	if Input.is_action_just_pressed("boss_heavy_attack") and not is_slamming and not is_attacking and slam_cooldown <= 0.0:
		perform_slam()

func set_game_over() -> void:
	game_over = true
	velocity = Vector2.ZERO

# --- Backhand Swipe (unchanged from Phase 10) ---
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

	if not game_over:
		for body in swipe_hitbox.get_overlapping_bodies():
			if body == self:
				continue  # Never damage yourself
			if body.has_method("take_damage"):
				body.take_damage(SWIPE_DAMAGE)

	await get_tree().create_timer(0.25).timeout

	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false
	is_attacking = false

# --- Ground Slam (new) ---
func perform_slam() -> void:
	is_slamming = true
	slam_cooldown = SLAM_COOLDOWN

	# Position the slam hitbox in front of Boss
	# Hitbox is 130px wide — Boss visual ends at x=80 facing right, starts at x=0 facing left
	if facing_direction == 1:
		slam_hitbox.position = Vector2(80, 5)     # right of Boss
	else:
		slam_hitbox.position = Vector2(-130, 5)   # left of Boss

	# --- Windup phase ---
	# Show the hitbox as a visible WARNING — monitoring is still OFF
	# The player sees the purple box and has 0.35s to react
	slam_hitbox.visible = true
	slam_hitbox.monitoring = false

	await get_tree().create_timer(SLAM_WINDUP).timeout

	# If game ended during windup, clean up and stop
	if game_over:
		slam_hitbox.visible = false
		is_slamming = false
		return

	# --- Damage phase ---
	# Now turn on monitoring — hitbox is hot
	slam_hitbox.monitoring = true

	await get_tree().process_frame
	await get_tree().process_frame

	if not game_over:
		for body in slam_hitbox.get_overlapping_bodies():
			if body == self:
				continue  # Never damage yourself
			if body.has_method("take_damage"):
				body.take_damage(SLAM_DAMAGE)

	# Keep hitbox active and visible briefly for feedback
	await get_tree().create_timer(SLAM_ACTIVE_TIME).timeout

	slam_hitbox.monitoring = false
	slam_hitbox.visible = false
	is_slamming = false

func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health -= amount
	print("Boss took ", amount, " damage. Health: ", health, " / ", MAX_HEALTH)

	if health <= 0:
		health = 0
		print("The Boss has been defeated!")
		defeated.emit()
