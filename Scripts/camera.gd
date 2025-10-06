extends Camera2D

@export var _subject : Node2D
@export var _offset : Vector2
@export var _trans_type : Tween.TransitionType
@export var _ease : Tween.EaseType
@export var _duration : float = 2
@onready var _look_ahead_distance : float = _offset.x
@onready var _floor_height : float = _subject.position.y
var _look_ahead_tween : Tween
var _floor_height_teen : Tween

func _ready() -> void:
	_offset *= Global.ppt

func _process(_delta: float) -> void:
	position.x = move_toward(position.x, _subject.position.x + _look_ahead_distance, _delta * Global.ppt * 8)
	position.y = _floor_height + _offset.y
	
func _on_subject_changed_direction(is_facing_left: bool) -> void:
	_look_ahead_tween = create_tween().set_trans(_trans_type).set_ease(_ease)
	_look_ahead_tween.tween_property(self, "_look_ahead_distance", _offset.x * (-1 if is_facing_left else 1), _duration)


func _on_subject_landed(floor_height: float) -> void:
	_floor_height_teen = create_tween().set_trans(_trans_type).set_ease(_ease)
	_floor_height_teen.tween_property(self, "_floor_height", floor_height, _duration)
