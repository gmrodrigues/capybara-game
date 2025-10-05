extends Node

@onready var _character = get_parent()

func _input(event: InputEvent):
	if event.is_action_pressed("jump"):
		_character.jump()
		
func _process(_delta: float):
	_character.run(Input.get_axis("run_left", "run_right"))
