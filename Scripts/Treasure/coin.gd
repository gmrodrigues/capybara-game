extends Treasure

@export var _value : int = 1

func _collect():
	$/root/Game.collect_coin(_value)
