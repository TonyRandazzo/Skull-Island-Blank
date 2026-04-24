extends CharacterBody3D

# ---------- PLAYER PROPERTIES ---------- #
@export var move_speed : float = 4.5
@export var walk_speed : float = 1.5
@export var run_speed : float = 4.5
@export var jump_force : float = 5.0
@export var follow_lerp_factor : float = 4.0
@export var jumpStretchSize := Vector3(1, 1, 1)

# ---------- STATE ----------
var is_grounded = false
var is_falling = false

# ---------- NODES ----------
@onready var model = $Raev2
@onready var animation = $Raev2/AnimationPlayer
@onready var spring_arm = $Gimball

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

func _process(delta: float) -> void:
	handle_input(delta)
	update_grounded_state()
	animate_player()
	smooth_follow(delta)

func handle_input(delta: float) -> void:
	# --- MOVIMENTO ---
	var move_dir := Vector3.ZERO
	move_dir.x = Input.get_axis("ui_left", "ui_right")
	move_dir.z = Input.get_axis("ui_up", "ui_down")

	# Ruotiamo rispetto alla rotazione della camera
	move_dir = move_dir.rotated(Vector3.UP, spring_arm.rotation.y)
	if move_dir.length() > 0:
		move_dir = move_dir.normalized()
	
	# Imposta velocità orizzontale
	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed
	
	# --- ROTAZIONE MODELLO ---
	if move_dir.length() > 0:
		model.rotation.y = lerp_angle(model.rotation.y, atan2(move_dir.x, move_dir.z), delta * 12)
	
	# --- SALTO ---
	if Input.is_action_just_pressed("jump") and is_on_floor():
		perform_jump()
	
	# --- RUN/WALK ---
	if Input.is_action_pressed("run"):
		move_speed = run_speed
	else:
		move_speed = walk_speed
	
	# --- MUOVI PLAYER ---
	velocity.y -= gravity * delta
	move_and_slide()

func perform_jump() -> void:
	# Audio Salto
	$"Audio Jump".play()
	$"Audio Jump".pitch_scale = 0.95


	# Animazione salto
	if animation.has_animation("jumping"):
		animation.play("jumping", 0.2, 1)
		animation.seek(0.65, true)
	jump_tween()
	velocity.y = jump_force
	is_falling = false

func jump_tween() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", jumpStretchSize, 0.1)
	tween.tween_property(self, "scale", Vector3(1,1,1), 0.1)

func update_grounded_state() -> void:
	is_grounded = is_on_floor()
	if is_grounded:
		is_falling = false
	else:
		if velocity.y < 0:
			is_falling = true

func is_moving() -> bool:
	return abs(velocity.x) > 0.01 or abs(velocity.z) > 0.01

func animate_player() -> void:
	if is_on_floor():
		if is_moving():
			if move_speed == walk_speed and animation.has_animation("walk"):
				animation.play("walk", 0.5)
			elif move_speed == run_speed and animation.has_animation("run"):
				animation.play("run", 0.5)
		else:
			if animation.has_animation("idle"):
				animation.play("idle", 0.5)
	else:
		if is_falling:
			if animation.has_animation("fall"):
				animation.play("fall")
		elif velocity.y > 0:
			if animation.has_animation("jumping"):
				animation.play("jumping", 0.2, 1)
				animation.seek(0.65, true)

func smooth_follow(delta: float) -> void:
	# La camera segue il player in maniera morbida
	spring_arm.position = lerp(spring_arm.position, position, delta * follow_lerp_factor)

# Quit game
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
