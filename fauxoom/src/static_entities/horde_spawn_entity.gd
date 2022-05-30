# simple entity wrapper for a horde spawner
extends Spatial

const Enums = preload("res://src/enums.gd")

# onready var _spawner:HordeSpawnComponent = $logic
onready var _ent:Entity = $Entity

export var triggerName:String = ""
export var triggerTargetName:String = ""

export var positionsSiblingName:String = ""
export var positionsFilter:String = ""

export(Enums.EnemyType) var type = Enums.EnemyType.Punk

export var tickMax:float = 2
export var totalMobs:int = 4
export var maxLiveMobs:int = 2

export(Enums.SequenceOrder) var order = Enums.SequenceOrder.Random

var _spawnPoints = []
var _spawnPointIndex = 0

var _liveMobs:int = 0
var _deadMobs:int = 0
var _tick:float = 0
var _active:bool = false
var _endless:bool = false
var _finished:bool = false

func _ready() -> void:
	visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	if triggerName == "":
		triggerName = self.name
	_ent.selfName = triggerName
	_ent.triggerTargetName = triggerTargetName
	find_positions_sibling()
	_endless = (totalMobs <= 0)
	if _endless:
		print("Spawner " + _ent.selfName + " is endless")

func is_horde_spawn() -> bool:
	return true

func is_endless() -> bool:
	return !(totalMobs > 0)

func has_mobs_remaining() -> bool:
	if is_endless():
		return true
	else:
		return _deadMobs + _liveMobs < totalMobs

func find_positions_sibling() -> void:
	if positionsSiblingName == "":
		return
	var positionNodes
	if positionsFilter == "":
		positionNodes = get_parent().find_node(positionsSiblingName).get_children()
	else:
		var children = get_parent().find_node(positionsSiblingName).get_children()
		positionNodes = []
		var tokens = ZqfUtils.tokenise(positionsFilter)
		for i in range(0, children.size()):
			var child = children[i]
			for j in range(0, tokens.size()):
				if child.name == tokens[j]:
					# print("Horde spawn - adding position " + child.name + ": " + str(child.global_transform.origin))
					positionNodes.push_back(child)
					break;
		# print("Horde spawn filtered " + str(children.size()) + " nodes to " + str(positionNodes.size()))
	for i in range(0, positionNodes.size()):
		_spawnPoints.push_back(positionNodes[i].global_transform)

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	_dict.liveMobs = _liveMobs
	_dict.deadMobs = _deadMobs
	_dict.totalMobs = totalMobs
	_dict.tick = _tick
	_dict.active = _active
	_dict.finished = _finished
	_dict.pIndex = _spawnPointIndex

func restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)
	_liveMobs = 		ZqfUtils.safe_dict_i(_dict, "liveMobs", _liveMobs)
	_deadMobs = 		ZqfUtils.safe_dict_i(_dict, "deadMobs", _deadMobs)
	totalMobs = 		ZqfUtils.safe_dict_i(_dict, "totalMobs", totalMobs)
	_tick = 			ZqfUtils.safe_dict_f(_dict, "tick", _tick)
	_active = 			ZqfUtils.safe_dict_b(_dict, "active", _active)
	_finished = 		ZqfUtils.safe_dict_b(_dict, "finished", _finished)
	_spawnPointIndex = 	ZqfUtils.safe_dict_i(_dict, "pIndex", _spawnPointIndex)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if !_active:
		print("Horde spawn start")
		_active = true
		# check for reset and running again
		if _finished:
			_finished = false
			_deadMobs = 0
			_liveMobs = 0
			_tick = 0
			if _endless:
				totalMobs = 0
	elif is_endless():
		print("Horde spawn - disabling endless mode")
		totalMobs = _liveMobs + _deadMobs
		_check_if_finished()

func _process(_delta:float) -> void:
	if !_active:
		return
	if (_liveMobs < maxLiveMobs) && has_mobs_remaining():
		_tick -= _delta
		if _tick <= 0:
			_tick = tickMax
			_liveMobs += 1
			_spawn_child()

func set_spawn_points(newTransformsArray) -> void:
	_spawnPoints = newTransformsArray

func pick_spawn_point() -> Transform:
	var numPoints:int = _spawnPoints.size()
	if numPoints == 0:
		return self.global_transform
	else:
		var _i:int = 0
		if order == Enums.SequenceOrder.Random:
			_i = int(rand_range(0, numPoints))
		else:
			_i = _spawnPointIndex
			_spawnPointIndex += 1
			if _spawnPointIndex >= numPoints:
				_spawnPointIndex = 0
		return _spawnPoints[_i]

func _spawn_child() -> void:
	var t:Transform = pick_spawn_point()
	# print("Horde spawn - spawn child at " + str(t.origin))
	var mob = Ents.create_mob(type, t, true)
	var _childId:int = mob.get_node("Entity").id
	mob.set_source(self, _ent.id)

func _check_if_finished() -> void:
	if !is_endless() && _deadMobs >= totalMobs:
		_active = false
		_finished = true
		# print("Horde spawn - all children dead")
		if triggerTargetName != "":
			Interactions.triggerTargets(get_tree(), triggerTargetName)

func _on_mob_died(_mob) -> void:
	_liveMobs -= 1
	_deadMobs += 1
	# print("Mob death: " + str(_deadMobs) + " dead vs " + str(totalMobs) + " max")
	_check_if_finished()
