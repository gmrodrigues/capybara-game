extends CharacterBody2D


@export_category("Locomotion")
@export var _speed : float = 16
@export var _acceleration : float = 16
@export var _deceleration : float = 32

@export_category("Jump")
const JUMP_VELOCITY = -400.0
@export var _jump_height: float = 4.5
@export var _air_control: float = 0.5
var _jump_velocity: float

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction: float

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	_jump_velocity = sqrt(_jump_height * gravity * 3) * -1

#region Public Methods

func face_left():
	return
	
func face_right():
	return
	
func run(direction: float):
	_direction = direction
	
	
func jump():
	if is_on_floor():
		velocity.y = _jump_velocity
		
func stop_jump():
	if velocity.y < 0:
		velocity.y = 0
#endregion

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	move_and_slide()
		
func _air_physics(delta: float) -> void:
	velocity.y += gravity * delta
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _air_control * delta)

func _ground_physics(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	
	# decelerate to zero
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, _deceleration * delta)
	# accelerate from not moving or move to same direction
	elif velocity.x == 0 || sign(_direction) == sign(velocity.x):
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * delta)
	# accelerate to oposite direction
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _deceleration * delta)
