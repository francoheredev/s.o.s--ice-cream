extends CharacterBody2D

@export var death_particles_scene: PackedScene

# --------------------
# VELOCIDAD (SMB)
# --------------------
@export var walk_speed := 500
@export var run_speed := 720

# --------------------
# ACELERACIÓN (SMB)
# --------------------
@export var ground_accel := 18000.0
@export var air_accel := 8000.0
@export var friction := 12000.0
@export var skid_friction := 26000.0

# --------------------
# GRAVEDAD (SMB)
# --------------------
@export var gravity := 5000
@export var low_gravity := 2500
@export var fall_gravity := 8000.0

# --------------------
# SALTO (SMB + MOMENTUM)
# --------------------
@export var jump_force := -900
@export var jump_cut := 0.3
@export var jump_horizontal_boost := 0.15

# --------------------
# COYOTE & BUFFER
# --------------------
@export var coyote_time := 0.08
@export var jump_buffer_time := 0.08

var coyote_timer := 0.0
var jump_buffer_timer := 0.0

# --------------------
# WALL MECHANICS (SMB)
# --------------------
@export var wall_slide_speed := 200
@export var wall_slide_accel := 5000
@export var wall_jump_force := Vector2(800, -1100)
@export var wall_jump_lock_time := 0.05

var wall_jump_lock_timer := 0.0

# --------------------
# DIRECCIÓN (NUEVO 🔥)
# --------------------
var last_dir := 1  # 1 = derecha, -1 = izquierda

# --------------------
# MUERTE
# --------------------
var dead := false
var can_move := true
@onready var anim = $AnimatedSprite2D
@onready var run_particles = $RunParticles


func _physics_process(delta):
	if dead or not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var input_dir = Input.get_axis("move_left", "move_right")
	var is_running = Input.is_action_pressed("run")
	var on_floor = is_on_floor()
	var on_wall = is_on_wall()

	var wall_dir = 0
	if on_wall:
		wall_dir = get_wall_normal().x

	var max_speed = run_speed if is_running else walk_speed
	var accel = ground_accel if on_floor else air_accel

	# --------------------
	# TIMERS
	# --------------------
	if on_floor:
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)

	# --------------------
	# WALL JUMP
	# --------------------
	if on_wall and not on_floor and Input.is_action_just_pressed("jump"):
		velocity.x = (wall_jump_force.x * wall_dir) + (velocity.x * 0.3)
		velocity.y = wall_jump_force.y

		if velocity.y > -200:
			velocity.y -= 100

		wall_jump_lock_timer = wall_jump_lock_time
		jump_buffer_timer = 0
		coyote_timer = 0

	# --------------------
	# SALTO NORMAL
	# --------------------
	elif (on_floor or coyote_timer > 0) and jump_buffer_timer > 0 and velocity.y >= 0:
		velocity.y = jump_force
		velocity.x += velocity.x * jump_horizontal_boost

		coyote_timer = 0
		jump_buffer_timer = 0

	# --------------------
	# MOVIMIENTO HORIZONTAL
	# --------------------
	if wall_jump_lock_timer > 0:
		wall_jump_lock_timer -= delta
	else:
		if input_dir != 0:
			var target_speed = input_dir * max_speed

			if on_floor and sign(velocity.x) != sign(input_dir) and abs(velocity.x) > 50:
				velocity.x = move_toward(velocity.x, 0, skid_friction * delta)
			else:
				velocity.x = move_toward(velocity.x, target_speed, accel * delta)
		else:
			if on_floor:
				velocity.x = move_toward(velocity.x, 0, friction * delta)

	# --------------------
	# GRAVEDAD + WALL SLIDE
	# --------------------
	if not on_floor:
		if on_wall:
			velocity.y = move_toward(
				velocity.y,
				wall_slide_speed,
				wall_slide_accel * delta
			)
		else:
			if velocity.y < 0:
				if Input.is_action_pressed("jump"):
					velocity.y += low_gravity * delta
				else:
					velocity.y += gravity * delta
			else:
				velocity.y += fall_gravity * delta

	# --------------------
	# CORTE DE SALTO
	# --------------------
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut

	# --------------------
	# RUN PARTICLES
	# --------------------
	var is_moving = abs(velocity.x) > 80

	if on_floor and is_moving:
		run_particles.emitting = true
		
		if velocity.x > 0:
			run_particles.position.x = -6
		else:
			run_particles.position.x = 6
	else:
		run_particles.emitting = false

	move_and_slide()
	update_animations(input_dir)
# --------------------
# MUERTE
# --------------------
# --------------------
# MUERTE
# --------------------
var dying := false

# --------------------
# MUERTE
# --------------------
func die():
	if dead:
		return
	
	dead = true

	GameManager.deaths += 1

	anim.play("death")

	if death_particles_scene:
		var particles = death_particles_scene.instantiate()
		particles.global_position = global_position
		particles.z_index = 100
		particles.emitting = true
		get_parent().add_child(particles)

	Engine.time_scale = 0.1
	await get_tree().create_timer(0.08).timeout
	Engine.time_scale = 1

	await get_tree().create_timer(0.2).timeout

	get_tree().reload_current_scene()
# --------------------
# ANIMACIONES
# --------------------
func update_animations(input_dir):
	var dir = Input.get_axis("move_left", "move_right")
	var is_running = Input.is_action_pressed("run")
	var on_floor = is_on_floor()
	# 🔥 Guardar última dirección
	if dir != 0:
		last_dir = dir
	# --------------------
	# SALTO / AIRE
	# --------------------
	if not on_floor:
		if last_dir > 0:
			play_anim("saltoder")
		else:
			play_anim("saltoizq")
		return

	# IDLE
	if dir == 0:
		if last_dir > 0:
			play_anim("idleder")
		else:
			play_anim("idleizq")
		return

	# CAMINAR
	if not is_running:
		if dir > 0:
			play_anim("der")
		else:
			play_anim("izq")
		return

	# CORRER
	if dir > 0:
		play_anim("der2")
	else:
		play_anim("izq2")


func play_anim(name):
	if anim.animation != name:
		anim.play(name)
