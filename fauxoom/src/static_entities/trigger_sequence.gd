extends Spatial

const Enums = preload("res://src/enums.gd")

onready var _ent:Entity = $Entity

export var selfName:String = ""
export var triggerTargetName:String = ""
export var waitSeconds:float = 0
export var targetsPerTrigger:int = 1

var _targets = []

var _active:bool = false
var _tick:float = 0
var _running:bool = false
var _index:int = 0

export(Enums.SequenceOrder) var type = Enums.SequenceOrder.Linear

export var intParameter1:int = 0

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = selfName
	_ent.triggerTargetName = triggerTargetName
	_targets = ZqfUtils.tokenise(triggerTargetName)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _targets.size() == 0:
		return
	if waitSeconds <= 0:
		if type == Enums.SequenceOrder.Random:
			var i:int = int(rand_range(0, _targets.size()))
			Interactions.triggerTargets(get_tree(), _targets[i])
		elif type == Enums.SequenceOrder.Linear:
			var i:int = _index
			_index += 1
			if _index >= _targets.size():
				_index = 0
			print("Sequence triggering " + str(i) + ": " + _targets[i])
			Interactions.triggerTargets(get_tree(), _targets[i])
	else:
		# TODO: periodic logic
		pass

func append_state(_dict:Dictionary) -> void:
	_dict.active = _active
	_dict.tick = _tick
	_dict.index = _index

func restore_state(_dict:Dictionary) -> void:
	_active = _dict.active
	_tick = _dict.tick
	_index = _dict.index

func _process(_delta:float) -> void:
	if !_running:
		return
