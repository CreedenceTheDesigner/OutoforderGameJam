extends CharacterBody3D
class_name Player

## How fast the player moves on the ground.
@export var base_speed := 6.0
## How high the player can jump in meters.
@export var jump_height := 1.2
## How fast the player falls after reaching max jump height.
@export var fall_multiplier := 2.5

@export_category("Camera")
## How much moving the mouse moves the camera. Overwritten in settings.
@export var mouse_sensitivity: float = 0.00075
## Limits how low the player can look down.
@export var bottom_clamp: float = -90.0
## Limits how high the player can look up.
@export var top_clamp: float = 90.0

@export_category("Third Person")
## Limits how far the player can zoom in.
@export var min_zoom: float = 1.5
## Limits how far the player can zoom out.
@export var max_zoom: float = 6.0
## How quickly to zoom the camera
@export var zoom_sensitivity: float = 0.4

@export var destruction_particles : PackedScene
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
# Stores the direction the player is trying to look this frame.
var _look := Vector2.ZERO

enum state {IDLE, RUNNING, ATTACK, ATTACK2, HEAVYATTACK}

@onready var current_state = state.IDLE

enum {WRENCH, PIPE, BAT}

@onready var weapon = WRENCH:
	set(value):
		weapon = value
		match weapon:
			WRENCH:
				wrench.visible = true
				pipe.visible = false
				bat.visible = false
				#wrench_collider.disabled = false
				#bat_collider.disabled = true
				#pipe_collider.disabled = true
			PIPE:
				wrench.visible = false
				pipe.visible = true
				bat.visible = false
				#wrench_collider.disabled = true
				#bat_collider.disabled = true
				#pipe_collider.disabled = false
			BAT:
				wrench.visible = false
				pipe.visible = false
				bat.visible = true
				#wrench_collider.disabled = true
				#bat_collider.disabled = false
				#pipe_collider.disabled = true

enum VIEW {
	FIRST_PERSON,
	THIRD_PERSON_BACK
}

# Updates the cameras to swap between first and third person.
var view := VIEW.FIRST_PERSON:
	set(value):
		view = value
		match view:
			VIEW.FIRST_PERSON:
				# Get the fov of the current camera and apply it to the target.
				camera.fov = get_viewport().get_camera_3d().fov
				camera.current = true
				UserInterface.hide_reticle(false)
			VIEW.THIRD_PERSON_BACK:
				# Get the fov of the current camera and apply it to the target.
				third_person_camera.fov = get_viewport().get_camera_3d().fov
				third_person_camera.current = true
				UserInterface.hide_reticle(true)

# Control the target length of the third person camera arm..
var zoom := min_zoom:
	set(value):
		zoom = clamp(value, min_zoom, max_zoom)
		if value < min_zoom:
			# When the player zooms all the way in swap to first person.
			view = VIEW.FIRST_PERSON
		elif value > min_zoom:
			# When the player zooms out at all swap to third person.
			view = VIEW.THIRD_PERSON_BACK

@onready var camera: Camera3D = $SmoothCamera
@onready var third_person_camera: Camera3D = %ThirdPersonCamera
@onready var spring_arm_3d: SpringArm3D = %SpringArm3D

@onready var camera_target: Node3D = $CameraTarget
@onready var camera_origin = camera_target.position

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var run_particles: GPUParticles3D = $BasePivot/RunParticles
@onready var jump_particles: GPUParticles3D = $BasePivot/JumpParticles

@onready var jump_audio: AudioStreamPlayer3D = %JumpAudio
@onready var run_audio: AudioStreamPlayer3D = %RunAudio
@onready var weapon_area: Area3D = $BasePivot/Model/Armature_002/Skeleton3D/WeaponArea
@onready var attack_timer: Timer = %AttackTimer
@onready var state_timer: Timer = $BasePivot/Model/Armature_002/Skeleton3D/WeaponArea/StateTimer
@onready var attack_timer_2: Timer = $BasePivot/Model/Armature_002/Skeleton3D/WeaponArea/AttackTimer2
@onready var animation_player: AnimationPlayer = $BasePivot/Model/AnimationPlayer

@onready var bat: MeshInstance3D = %Bat
@onready var pipe: MeshInstance3D = %Pipe
@onready var wrench: MeshInstance3D = %Wrench
@onready var bat_collider: CollisionShape3D = %BatCollider
@onready var pipe_collider: CollisionShape3D = %PipeCollider
@onready var wrench_collider: CollisionShape3D = %WrenchCollider
var is_attacking := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Whenever the player loads in, give the autoload ui a reference to itself.
	UserInterface.update_player(self)
	SignalManager.destruction_one.connect(change_wrench)
	SignalManager.destruction_two.connect(change_pipe)
	SignalManager.destruction_three.connect(change_bat)

func _process(delta: float) -> void:
	match current_state:
		state.IDLE:
			_idle(delta)
			print("idle")
		state.RUNNING:
			_running(delta)
			print("running")
		state.ATTACK:
			print("attacking")
			_attacking()
		#state.ATTACK2:
			#print("second attack")
			#_attacking2()
		
	if Input.is_action_just_pressed("attack") and is_on_floor():
		if not is_attacking:
			current_state = state.ATTACK
			weapon_area.monitoring = true
		#if is_attacking:
			#current_state = state.ATTACK2
			#weapon_area.monitoring = true

func _physics_process(delta: float) -> void:

			
	frame_camera_rotation()
	smooth_camera_zoom(delta)

		

# Turn movent inputs into a locally oriented vector.
func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
# Apply the _look variables rotation to the camera.
func frame_camera_rotation() -> void:
	rotate_y(_look.x)
	# The smooth camera orients the camera to align with the target smoothly.
	camera_target.rotate_x(_look.y)
	camera_target.rotation.x = clamp(camera_target.rotation.x, 
		deg_to_rad(bottom_clamp), 
		deg_to_rad(top_clamp)
	)
	# Reset the _look variable so the same offset can't be reapplied.
	_look = Vector2.ZERO


# Blend the walking animation based on movement direction.
func update_animation_tree() -> void:
	# Get the local movement direction.
	var movement_direction = basis.inverse() * velocity / base_speed
	# Convert the direction to a Vector2 to select the correct movement animation.
	var animation_target = Vector2(movement_direction.x, -movement_direction.z)
	animation_tree.set("parameters/blend_position", animation_target)

func _unhandled_input(event: InputEvent) -> void:
	# Update the _look variable to the latest mouse offset.
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			_look = -event.relative * mouse_sensitivity
	# Capture the mouse if it is uncaptured.
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	# Camera controls.
	if event.is_action_pressed("toggle_view"):
		cycle_view()
	if event.is_action_pressed("zoom_in"):
		zoom -= zoom_sensitivity
	elif event.is_action_pressed("zoom_out"):
		zoom += zoom_sensitivity
	
func cycle_view() -> void:
	# Swap from third to first person and vice versa.
	match view:
		VIEW.FIRST_PERSON:
			view = VIEW.THIRD_PERSON_BACK
			# Set the default third person zoom to halfway between min and max.
			zoom = lerp(min_zoom, max_zoom, 0.5)
		VIEW.THIRD_PERSON_BACK:
			view = VIEW.FIRST_PERSON
		_:
			view = VIEW.FIRST_PERSON

# Interpolate the third person distance to the target length.
func smooth_camera_zoom(delta: float) -> void:
	spring_arm_3d.spring_length = lerp(
		spring_arm_3d.spring_length,
		zoom,
		delta * 10.0
	)

# Play a footstep sound effect when moving.
func _on_footstep_timer_timeout() -> void:
	if is_on_floor() and get_movement_direction():
		run_audio.play()


func _on_state_timer_timeout() -> void:
	current_state = state.IDLE
	is_attacking = false

func _idle(delta: float):
	animation_player.play("Idle")
	_player_movement(delta)
	
	
func _running(delta: float):
	animation_player.play("Run")
	_player_movement(delta)
	
func _attacking():
	if attack_timer.is_stopped():
		animation_player.play("OverhandStrike")
		attack_timer.start(1)
		state_timer.start(1)
		is_attacking = true
	
#func _attacking2():
	#if state_timer.get_time_left() and attack_timer_2.is_stopped():
		#animation_player.queue("BackHand")
		#attack_timer_2.start(1)
		#state_timer.start(1)
	
func _player_movement(delta: float):
		# Add gravity.
	if not is_on_floor():
		# if holding jump and ascending be floaty.
		if velocity.y >= 0 and Input.is_action_pressed("ui_accept"):
			velocity.y -= gravity * delta
		else:
			# Double fall speed, after peak of jump or release of jump button.
			velocity.y -= gravity * delta * fall_multiplier
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Projectile motion to turn jump height into a velocity.
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		jump_particles.restart()
		jump_audio.play()
		run_audio.play()

	# Handle movement.
	var direction = get_movement_direction()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * base_speed, base_speed * delta)
		velocity.z =  lerp(velocity.z, direction.z * base_speed, base_speed * delta)
		current_state = state.RUNNING
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed * delta * 5.0)
		velocity.z = move_toward(velocity.z, 0, base_speed * delta * 5.0)
		current_state = state.IDLE
	
	# Emit run particles when moving on the floor.
	run_particles.emitting = not direction.is_zero_approx() and is_on_floor()
		
	#update_animation_tree()
	move_and_slide()

func change_wrench():
	weapon = WRENCH
	
func change_pipe():
	weapon = PIPE
	
func change_bat():
	weapon = BAT
