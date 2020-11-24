extends Node2D

var _tile_prefab = preload("res://prefabs/gate_tile.tscn")

enum GateDirection {
	Down,
	Up,
	Left,
	Right
}
export var direction = GateDirection.Down
export var tileCount:int = 2
export var target_name:String = ""
var _tiles = []
var _on:bool = true

func _ready():
	# default to down
	var step:Vector2 = Vector2(0, 32)
	if direction == GateDirection.Up:
		step = Vector2(0, -32)
	elif direction == GateDirection.Left:
		step = Vector2(-32, 0)
	elif direction == GateDirection.Right:
		step = Vector2(32, 0)
	var pos = Vector2()
	for _i in range(0, tileCount):
		var tile = _tile_prefab.instance()
		_tiles.push_back(tile)
		add_child(tile)
		pos += step
		tile.offset = Vector2(step.x, step.y)
		tile.position = pos
	#print("Gate trigger name: " + target_name)

func _set_state(isOn:bool):
	if isOn == _on:
		return
	_on = isOn
	for i in range(tileCount):
		if _on:
			_tiles[i].on()
		else:
			_tiles[i].off()

func trigger(tarName:String):
	if target_name != "" && target_name == tarName:
		#print("Gate " + target_name + " triggered")
		_set_state(!_on)
