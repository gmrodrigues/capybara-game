extends CharacterBody2D


@export_category("Locomotion")
@export var _speed : float = 16
@export var _acceleration : float = 16
@export var _deceleration : float = 32


@export_category("Jump")
const JUMP_VELOCITY = -400.0
@export var _jump_height: float = 4.5
@export var _air_control: float = 0.5
@export var _jump_dust : PackedScene
var _jump_velocity: float

@export_category("Sprite")
@export var _sprites_faces_left : bool = false
@export var _is_facing_left: bool
@onready var _sprite : Sprite2D = $Sprite2D
var _was_on_floor : bool

signal changed_direction(is_facing_left: bool)
signal landed(floor_height: float)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction: float

func _ready():
	_speed *= Global.ppt
	_acceleration *= Global.ppt
	_deceleration *= Global.ppt
	_jump_height *= Global.ppt
	_jump_velocity = sqrt(_jump_height * gravity * 3) * -1
	face_left() if _is_facing_left else face_right()

#region Public Methods

func face_left():
	_is_facing_left = true
	_sprite.flip_h = not _sprites_faces_left
	changed_direction.emit(_is_facing_left)
	
func face_right():
	_is_facing_left = false
	_sprite.flip_h = _sprites_faces_left
	changed_direction.emit(_is_facing_left)
	
func run(direction: float):
	_direction = direction
	
	
func jump():
	_spawn_dust(_jump_dust)
	if is_on_floor():
		velocity.y = _jump_velocity
		
func stop_jump():
	if velocity.y < 0:
		velocity.y = 0
#endregion

func _physics_process(delta: float) -> void:
	if not _is_facing_left && (_direction) == -1:
		face_left()
	elif _is_facing_left && (_direction) == 1:
		face_right()
	
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)		
	_was_on_floor = is_on_floor()
	move_and_slide()
	if not _was_on_floor && is_on_floor():
		_landed()
		
func _air_physics(delta: float) -> void:
	velocity.y += gravity * delta
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _air_control * delta)

func _ground_physics(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta

	# Handle jump.
	#if Input.is_action_just_pressed  ("ui_accept") and is_on_floor():
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

func _landed():
	landed.emit(position.y)

func _spawn_dust(dust: PackedScene):
	var _dust = dust.instantiate()
	_dust.position = position
	_dust.flip_h = _sprite.flip_h
	get_parent().add_child(_dust)


func _on_changed_direction(is_facing_left: bool) -> void:
	pass # Replace with function body.
