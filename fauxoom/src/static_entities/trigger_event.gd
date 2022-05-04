extends Spatial

onready var _ent:Entity = $Entity

export var selfName:String = ""
export var triggerTargetName:String = ""
export var waitSeconds:float = 0
export(Environment) var worldEnvironment:Environment = null

var _active:bool = false
var _tick:float = 0

enum EventType {
	None = 0,
	LevelComplete = 1,
	ActivateWaypointTag = 2,
	DeactivateWaypointTag = 3,
	ApplyEnvironment = 4,
	Checkpoint
}

export(EventType) var type = EventType.None
export var intParameter1:int = 0

var _lastHintCount:int = -1

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	visible = false
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	if selfName != "":
		_ent.selfName = selfName
	else:
		_ent.selfName = name
	_ent.triggerTargetName = triggerTargetName
	if worldEnvironment != null:
		Game.register_environment(worldEnvironment, _ent.selfName)
	# _spawnState = write_state()

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if waitSeconds > 0:
		if _active:
			return
		_tick = waitSeconds
		_active = true
	else:
		run_event()

func append_state(_dict:Dictionary) -> void:
	_dict.active = _active
	_dict.tick = _tick

func restore_state(_dict:Dictionary) -> void:
	_active = _dict.active
	_tick = _dict.tick

func _process(_delta:float) -> void:
	if !_active:
		return
	_tick -= _delta
	
	if _tick <= 0:
		_active = false
		Game.show_hint_text("FIGHT")
		run_event()
	else:
		var hintCount:int = int(_tick) + 1
		if hintCount != _lastHintCount:
			_lastHintCount = hintCount
			Game.show_hint_text(str(hintCount))

func run_event() -> void:
	Interactions.triggerTargets(get_tree(), triggerTargetName)
	
	if type == EventType.None:
		# if none, just trigger targets ala a trigger relay
		return
	elif type == EventType.LevelComplete:
		get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_LEVEL_COMPLETED)
	elif type == EventType.ActivateWaypointTag:
		AI.activate_waypoint_tag(intParameter1)
	elif type == EventType.DeactivateWaypointTag:
		AI.deactivate_waypoint_tag(intParameter1)
	elif type == EventType.ApplyEnvironment:
		# get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_SET_ENVIRONMENT, worldEnvironment)
		get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_SET_ENVIRONMENT, _ent.selfName)
	elif type == EventType.Checkpoint:
		print("Checkpoint")
		Main.submit_console_command("save checkpoint")
	else:
		print("Trigger event has invalid type set: " + str(int(type)))
