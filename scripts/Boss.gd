extends CharacterBody2D

signal defeated

# Load the Projectile scene so we can spawn copies of it at runtime
const PROJECTILE_SCENE = preload("res://scenes/Projectile.tscn")

const SPEED = 200.0
const GRAVITY = 980.0
const MAX_HEALTH: int = 300

# --- Light attack: Backhand Swipe ---
const SWIPE_DAMAGE: int = 25

# --- Heavy attack: Ground Slam ---
const SLAM_DAMAGE: int = 50
const SLAM_COOLDOWN: float = 2.0
const SLAM_WINDUP: float = 0.35
const SLAM_ACTIVE_TIME: float = 0.3

# --- Ranged attack: Dark Projectile ---
const PROJECTILE_COOLDOWN: float = 1.0

var health: int = MAX_HEALTH
var facing_direction: int = -1

var is_attacking: bool = false   # true while Backhand Swipe is executing
var is_slamming: bool = false    # true while Ground Slam is executing
var slam_cooldown: float = 0.0
var projectile_cooldown: float = 0.0

var game_over: bool = false

@onready var swipe_hitbox: Area2D = $SwipeHitbox
@onready var slam_hitbox: Area2D  = $SlamHitbox

func _ready() -> void:
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

	# Count down cooldowns every frame
	if slam_cooldown > 0.0:
		slam_cooldown -= delta
	if projectile_cooldown > 0.0:
		projectile_cooldown -= delta

	# Light attack (J) — blocked while Slam is running
	if Input.is_action_just_pressed("boss_light_attack") and not is_attacking and not is_slamming:
		perform_swipe()

	# Heavy attack (K) — blocked while Swipe is running, must be off cooldown
	if Input.is_action_just_pressed("boss_heavy_attack") and not is_slamming and not is_attacking and slam_cooldown <= 0.0:
		perform_slam()

	# Ranged attack (L) — independent cooldown, fires any time it's ready
	if Input.is_action_just_pressed("boss_projectile") and projectile_cooldown <= 0.0:
		perform_projectile()

func set_game_over() -> void:
	game_over = true
	velocity = Vector2.ZERO

# --- Backhand Swipe ---
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
				continue
			if body.has_method("take_damage"):
				body.take_damage(SWIPE_DAMAGE)

	await get_tree().create_timer(0.25).timeout

	swipe_hitbox.monitoring = false
	swipe_hitbox.visible = false
	is_attacking = false

# --- Ground Slam ---
func perform_slam() -> void:
	is_slamming = true
	slam_cooldown = SLAM_COOLDOWN

	if facing_direction == 1:
		slam_hitbox.position = Vector2(80, 5)
	else:
		slam_hitbox.position = Vector2(-130, 5)

	slam_hitbox.visible = true
	slam_hitbox.monitoring = false

	await get_tree().create_timer(SLAM_WINDUP).timeout

	if game_over:
		slam_hitbox.visible = false
		is_slamming = false
		return

	slam_hitbox.monitoring = true

	await get_tree().process_frame
	await get_tree().process_frame

	if not game_over:
		for body in slam_hitbox.get_overlapping_bodies():
			if body == self:
				continue
			if body.has_method("take_damage"):
				body.take_damage(SLAM_DAMAGE)

	await get_tree().create_timer(SLAM_ACTIVE_TIME).timeout

	slam_hitbox.monitoring = false
	slam_hitbox.visible = false
	is_slamming = false

# --- Dark Projectile ---
func perform_projectile() -> void:
	projectile_cooldown = PROJECTILE_COOLDOWN

	# Create a new copy of the Projectile scene
	var proj = PROJECTILE_SCENE.instantiate()

	# Spawn just outside the Boss's edge in the facing direction
	# Boss visual is 80px wide (x: 0 to 80)
	# Facing right: spawn at x=85 (5px gap from right edge)
	# Facing left:  spawn at x=-35 (projectile is 30px wide, so 5px gap from left edge)
	if facing_direction == 1:
		proj.global_position = global_position + Vector2(85, 40)
	else:
		proj.global_position = global_position + Vector2(-35, 40)

	# Tell the projectile which direction to travel
	proj.setup(facing_direction)

	# Add to Main scene (parent of Boss) so the projectile is independent of Boss
	# If we added it as a child of Boss, it would move with Boss
	get_parent().add_child(proj)

	print("Boss fired Dark Projectile!")

func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health -= amount
	print("Boss took ", amount, " damage. Health: ", health, " / ", MAX_HEALTH)

	if health <= 0:
		health = 0
		print("The Boss has been defeated!")
		defeated.emit()
