extends Spatial
class_name KingTower

var _gameOverUI_t = preload("res://prefabs/ui/king_game_over_ui.tscn")

const Enums = preload("res://src/enums.gd")

enum KingTowerState {
	Idle,
	InEditor,
	MovingToEvent,
	RunningEvent,
	WaitingForEvent
}

onready var _ent:Entity = $Entity
onready var _outerShellMesh = $display/outer_shell_mesh
onready var _path:GroundPath = $ground_path
onready var _forcefieldDetector:Area = $forcefield_detector

export var nodesCSV:String = ""

export var speed:float = 14

var _state = KingTowerState.Idle

var _nodeIndex:int = -1
var _nodeNames = []

var _pointEnts = []

var _activeMobIds = []
var _mobSpawnTick:float = 0.1

var _ammoTick:float = 4.0
var _ammoCooldown:float = 8.0

var _eventEnts = []
var _eventIndex = -1
var _eventCount:int = 0

var _totalEventSeconds:float = 0.0

var _weapons = [
	# "pistol",
	# "chainsaw",
	"ssg",
	"pg",
	"rocket_launcher"
]

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_path.ground_path_init(AI.create_nav_agent(), self)
	_forcefieldDetector.connect("body_entered", self, "_on_body_entered_forcefield_detector")
	# _result = _ent.connect("entity_trigger", self, "on_trigger")
	# skip ahead a little - need a proper option for this!
	#_eventCount = 2
	if !Main.is_in_game():
		_set_state(KingTowerState.InEditor)

func _on_body_entered_forcefield_detector(body) -> void:
	if body.has_method("set_active"):
		body.set_active(false)

func console_on_exec(txt:String, _tokens:PoolStringArray) -> void:
	if txt != "king":
		return
	print("-- King tower status --")
	print("Mob spawn tick " + str(_mobSpawnTick))
	var numMobs:int = _activeMobIds.size()
	print("Live mob ids: (" + str(numMobs) + "):")
	var mobTxt:String = ""
	for _i in range(0, numMobs):
		mobTxt += str(_activeMobIds[_i]) + ", "
	print(mobTxt)
	var numPoints:int = _pointEnts.size()
	print("Num point ents " + str(numPoints))

func _set_state(newState) -> void:
	_state = newState

func ents_post_load() -> void:
	if Main.is_in_editor():
		return
	_pointEnts = Ents.find_dynamic_entities("foo", "info_point")
	print("King Tower found " + str(_pointEnts.size()) + " point ents")
	_eventEnts = Ents.find_dynamic_entities("", "king_event")
	print("King tower found " + str(_eventEnts.size()) + " event ents")

func _find_nodes(csv) -> void:
	_nodeNames = csv.split(",")
	for nodeName in _nodeNames:
		var ent = Ents.find_dynamic_entity_by_name(nodeName)

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(self.global_transform)
	_dict.nlist = nodesCSV

func restore_state(_dict:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(_dict, "xform", self)
	nodesCSV = ZqfUtils.safe_dict_s(_dict, "nlist", nodesCSV)

# func ents_mob_awoke_id(id:int) -> void:
# 	print("King tower saw mob spawn " + str(id))
# 	var i:int = _activeMobIds.find(id)
# 	if i == -1:
# 		_activeMobIds.push_back(id)
# 	pass

func ents_mob_died_id(id:int) -> void:
	print("King tower saw mob die " + str(id))
	var i:int = _activeMobIds.find(id)
	if i == -1:
		return
	_activeMobIds.remove(i)
	if _activeMobIds.size() == 0:
		print("King tower - All mobs dead!")
	pass

func get_editor_info() -> Dictionary:
	visible = true
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "nodesCSV", "Node CSV", "text", nodesCSV)
	return info

func _spawn_next_weapon() -> void:
	var l:int = _weapons.size()
	if l == 0:
		return
	var i:int = int(rand_range(0, l))
	var type:String = _weapons[i]
	_weapons.remove(i)
	_spawn_item(type, 99, true)

func pick_spawn_point() -> Transform:
	var numPoints:int = _pointEnts.size()
	if numPoints == 0:
		return self.global_transform
	var i:int = int(rand_range(0, numPoints))
	var ent:Entity = _pointEnts[i]
	return ent.get_ent_transform()

func _spawn_item(type:String, timeToLive:float = 16.0, isImportant:bool = false) -> void:
	# var bulletDef = Ents.get_prefab_def("bullets_s")
	# var bullets = Ents.prefab
	var pos:Vector3 = self.global_transform.origin
	pos.y += 1.0
	var item = Ents.create_item(type, pos, isImportant)
	if item == null:
		print("King tower - failed to spawn item")
		return
	var vel:Vector3 = Vector3()
	vel.y = 10.0 # rand_range(5.0, 15.0)
	var radians:float = rand_range(0, PI * 2)
	var throwSpeed = rand_range(2.0, 4.0)
	vel.x = cos(radians) * throwSpeed
	vel.z = sin(radians) * throwSpeed
	item.set_velocity(vel)
	item.set_time_to_live(timeToLive)

func _pick_event() -> bool:
	var numEvents:int = _eventEnts.size()
	var sum:int = 0
	for i in range(0, numEvents):
		var eventObj = _eventEnts[i].get_parent()
		eventObj.weight += 1
		sum += eventObj.weight
	var randWeight:int = int(rand_range(0, sum))
	for i in range(0, numEvents):
		var eventObj = _eventEnts[i].get_parent()
		if randWeight < eventObj.weight:
			# reset weight so repetition is less likely
			eventObj.weight = 0
			_eventIndex = i
			return true
		randWeight -= eventObj.weight
	return false

func _pick_event_2() -> bool:
	var numEvents:int = _eventEnts.size()
	if numEvents > 0:
		_eventIndex = rand_range(0, numEvents)
		return true
	return false

func _get_event_ent():
	if _eventIndex < 0:
		return null
	return _eventEnts[_eventIndex]

func _start_event() -> void:
	Game.set_all_forcefields(false)
	_get_event_ent().get_parent().king_event_start(_eventCount)
	_state = KingTowerState.RunningEvent

func game_event_complete() -> void:
	print("King tower - event complete, returning to idle")
	_state = KingTowerState.Idle
	_outerShellMesh.visible = true
	_eventCount += 1
	if _eventCount % 2 == 0:
		_spawn_next_weapon()

func game_on_player_died(_info:Dictionary) -> void:
	var minutes:int = int(_totalEventSeconds / 60.0)
	var seconds:int = int(_totalEventSeconds) % 60
	var timeStr:String = str(minutes) + ":" + str(seconds)
	print("King mode ended: wave completed " + str(_eventCount) + " total time: " + timeStr)
	var ui = _gameOverUI_t.instance()
	get_tree().current_scene.add_child(ui)
	var grp:String = Groups.GAME_GROUP_NAME
	var fn:String = Groups.GAME_FN_KING_GAME_OVER
	var info = {
		"waves": _eventCount,
		"seconds": _totalEventSeconds
	}
	get_tree().call_group(grp, fn, info)
	self.queue_free()

func _move_tick(_delta:float) -> void:
	var origin:Vector3 = self.global_transform.origin
	var plyr = AI.get_player_target()
	var distToPlayer:float = origin.distance_to(plyr.position)
	# if distToPlayer > 8:
	# 	return
	
	var dest:Vector3 = _get_event_ent().get_parent().global_transform.origin
	_path.moveTargetPos = dest
	if !_path.tick(_delta):
		return
	var toward:Vector3 = _path.direction
	# just lerp straight to it
	# var toward:Vector3 = (dest - origin).normalized()
	var step:Vector3 = ((toward * speed) * _delta)
	var dist:float = origin.distance_to(dest)
	if dist <= 0.1 && distToPlayer < 8:
		_outerShellMesh.visible = false
		_start_event()
	else:
		global_transform.origin += step
	
func _move_spawn_tick(_delta:float) -> void:
	pass

func _process(_delta:float):
	if _state == KingTowerState.InEditor:
		return
	
	var origin:Vector3 = self.global_transform.origin
	if _state == KingTowerState.Idle:
		var dist:float = AI.get_distance_to_player(origin)
		if dist < 8 && AI.check_los_to_player(origin) && _pick_event():
			_state = KingTowerState.MovingToEvent
			_outerShellMesh.visible = true
			Game.set_all_forcefields(true)
	elif _state == KingTowerState.RunningEvent:
		_totalEventSeconds += _delta
		pass
	elif _state == KingTowerState.MovingToEvent:
		_move_tick(_delta)
	elif _state == KingTowerState.WaitingForEvent:
		pass
	#if _mobSpawnTick <= 0.0:
	#	_mobSpawnTick = 0.1
	#	if _activeMobIds.size() < 3:
	#		var t:Transform = pick_spawn_point()
	#		var mob = Ents.create_mob(Enums.EnemyType.Punk, t, true)
	#		mob.force_awake()
	#		var childId:int = mob.get_node("Entity").id
	#		_activeMobIds.push_back(childId)
	#	pass
	#else:
	#	_mobSpawnTick -= _delta
	
	if _ammoTick <= 0.0:
		_ammoTick = _ammoCooldown
		for _i in range(0, 4):
			_spawn_item("bullet_s")
			_spawn_item("shell_s")
			_spawn_item("cell_s")
			_spawn_item("rocket_s")
	else:
		_ammoTick -= _delta
