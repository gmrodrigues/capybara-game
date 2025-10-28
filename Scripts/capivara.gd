class_name Character extends CharacterBody2D

var _is_bound : bool
var _min : Vector2
var _max : Vector2

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

@export_category("Swim")
@export var _density: float = -0.1
@export var _drag: float = 0.5
var _water_surface_height: float
var _is_in_water: bool
var _is_below_surface: bool

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

func set_bounds(min_boundary : Vector2, max_boundary: Vector2):
	_is_bound = true
	_min = min_boundary
	_max = max_boundary
	var sprite_size : Vector2 = _sprite.get_rect().size
	_min.x += sprite_size.x / 2
	_max.x -= sprite_size.x / 2
	_min.y += sprite_size.y / 2
	_max.y -= sprite_size.y / 2
	

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
	if _is_in_water:
		if _is_below_surface:
			velocity.y = _jump_velocity * _drag
			landed.emit(position.y)
		else:
			velocity.y = _jump_velocity
	elif is_on_floor():
		velocity.y = _jump_velocity
		_spawn_dust(_jump_dust)
		
func stop_jump():
	if velocity.y < 0 && not _is_in_water:
		velocity.y = 0
		
func enter_water(water_surface_height: float):
	_water_surface_height = water_surface_height
	_is_in_water = true
	_is_below_surface = false
	landed.emit(position.y)
	if velocity.y > 0:
		velocity.y *= _drag
	
func exit_water():
	_is_in_water = false
	
func dive():
	_is_below_surface = true

#endregion

func _physics_process(delta: float) -> void:
	if not _is_facing_left && (_direction) == -1:
		face_left()
	elif _is_facing_left && (_direction) == 1:
		face_right()
		
	if _is_in_water:
		_water_physics(delta)
	elif is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)		
	_was_on_floor = is_on_floor()
	move_and_slide()
	if not _was_on_floor && is_on_floor():
		_landed()
	if _is_bound:
		position.x = clamp(position.x, _min.x, _max.x)
		position.y = clamp(position.y, _min.y, _max.y)
		
func _air_physics(delta: float) -> void:
	velocity.y += gravity * delta
	if _direction:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _air_control * delta)

func _water_physics(delta: float):
	if _direction == 0:
		velocity.x = move_toward(velocity.x, 0, _deceleration * _drag * delta)
	else:
		velocity.x = move_toward(velocity.x, _direction * _speed, _acceleration * _drag * delta)
		
	if _is_below_surface || _density > 0:
		velocity.y = move_toward(velocity.y, gravity * _density * _drag, gravity * _drag * delta)
	elif position.y - float(Global.ppt) / 4 < _water_surface_height:
		velocity.y = move_toward(velocity.y, gravity * _density * _drag, gravity * _drag * delta)
	else:
		velocity.y = move_toward(velocity.y, gravity * _density * _drag * -1, gravity * _drag * delta)
		

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
