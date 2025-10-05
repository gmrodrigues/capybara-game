extends CharacterBody2D


@export var _speed : float = 8
@export var _acceleration : float = 16
@export var _deceleration : float = 32
const JUMP_VELOCITY = -400.0

var _direction: float

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt

#region Public Methods

func face_left():
	return
	
func face_right():
	return
	
func run(direction: float):
	_direction = direction
	
	
func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
#endregion
	

func _physics_process(delta: float) -> void:
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
		

	move_and_slide()
