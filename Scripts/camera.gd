extends Camera2D

@export var _subject : Node2D
@export var _offset : Vector2
var _look_ahead_distance : float = _offset.x

func _ready() -> void:
	_offset *= Global.ppt

func _process(_delta: float) -> void:
	position.x = move_toward(position.x, _subject.position.x + _look_ahead_distance, _delta * Global.ppt * 8)
	position.y = move_toward(position.y, _subject.position.y + _offset.y, _delta * Global.ppt * 5)
	
func _on_subject_changed_direction(is_facing_left: bool) -> void:
	_look_ahead_distance = _offset.x * (-1 if is_facing_left else 1)


func _on_subject_landed(floor_height: float) -> void:
	pass
