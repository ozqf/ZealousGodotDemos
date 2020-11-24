extends Node2D

var _tile_prefab = preload("res://prefabs/gate_tile.tscn")

enum GateDirection {
	Down,
	Up,
	Left,
	Right
}
export var direction = GateDirection.Up
export var tileCount:int = 2
export var target_name:String = ""
var _tiles = []
var _on:bool = true

func _ready():
	var stepX:int = 0
	var stepY:int = 32
	var pos = Vector2()
	for i in range(0, tileCount):
		var tile = _tile_prefab.instance()
		_tiles.push_back(tile)
		add_child(tile)
		pos.x += stepX
		pos.y += stepY
		tile.offset = Vector2(stepX, stepY)
		tile.position = pos
	print("Gate trigger name: " + target_name)

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
		print("Gate " + target_name + " triggered")
		_set_state(!_on)
