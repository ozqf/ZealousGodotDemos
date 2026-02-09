extends Node3D
class_name GameMain

var _sandboxWorld:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")

var _playerType:PackedScene = preload("res://actors/player_avatar/player_avatar.tscn")

var _prjColumn:PackedScene = preload("res://actors/prj_column/prj_column.tscn")

var _tracerType:PackedScene = preload("res://fx/tracer/gfx_tracer.tscn")
var _impactType:PackedScene = preload("res://fx/impacts/gfx_impact_bullet.tscn")

@onready var _target:TargetInfo = $TargetInfo

enum State
{
	Title,
	PreGame,
	Game
}

var _state:State = State.Title

func _ready() -> void:
	print("Game start")

func get_target() -> TargetInfo:
	return _target

func prj_column() -> PrjColumn:
	var n:PrjColumn = _prjColumn.instantiate() as PrjColumn
	self.add_child(n)
	return n

func spawn_player() -> bool:
	var n:Node3D = self.get_tree().get_first_node_in_group("player_starts") as Node3D
	if n == null:
		return false
	var plyr = _playerType.instantiate() as Node3D
	self.add_child(plyr)
	plyr.global_position = n.global_position
	return true

func _physics_process(_delta: float) -> void:
	match _state:
		State.PreGame:
			if Input.is_action_just_pressed("attack_2") && spawn_player():
				_state = State.Game
			pass

func gfx_tracer() -> GFXTracer:
	var tracer:GFXTracer = _tracerType.instantiate() as GFXTracer
	self.add_child(tracer)
	return tracer

func gfx_impact_bullet(pos:Vector3) -> Node3D:
	var n:Node3D = _impactType.instantiate()
	self.add_child(n)
	n.global_position = pos
	return n

func _delete_dynamic_actors() -> void:
	var nodes:Array[Node] = get_tree().get_nodes_in_group("temp")
	for n in nodes:
		n.queue_free()

func start_game() -> void:
	if _state != State.Title:
		return
	_delete_dynamic_actors()
	self.get_tree().change_scene_to_packed(_sandboxWorld)
	_state = State.PreGame
	pass

func exit_game() -> void:
	self.get_tree().quit()
