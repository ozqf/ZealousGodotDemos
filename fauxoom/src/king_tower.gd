extends Spatial
class_name KingTower

var _gameOverUI_t = preload("res://prefabs/ui/king_game_over_ui.tscn")
var _king_status_t = preload("res://src/king_status.gd")

const Enums = preload("res://src/enums.gd")

enum KingTowerState {
	Idle,
	InEditor,
	MovingToEvent,
	RunningEvent,
	WaitingForEvent,
	WaitingForPlayer
}

onready var _ent:Entity = $Entity
onready var _outerShellMesh = $display/outer_shell_mesh
onready var _path:GroundPath = $ground_path
onready var _forcefieldDetector:Area = $forcefield_detector
onready var _prismTop:MeshInstance = $display/prism_top
onready var _prismBottom:MeshInstance = $display/prism_bottom
onready var _coreReceptacle = $core_receptacle
onready var _coreCollisionShape = $core_receptacle/CollisionShape

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

var _hudStatus:PlayerHudStatus = null
var _kingStatus:KingStatus = null

var _lastWeaponId:int = 0
var _awaitingWeaponPickup:bool = false
var _awaitingCore:bool = true

var _weapons = [
	"pistol",
	"chainsaw",
	"ssg",
	"pg",
	"rocket_launcher"
]

var _hintTick:float = 2.0
var _hintMessage:String = "foo"
var _throwCoreObjective:String = "Press R to throw a Power Core into the ammo dispenser. Costs 10 Energy."
var _takeGunObjective:String = "Pickup the weapon."

func _ready() -> void:
	_eventCount = 5
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.PLAYER_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	_kingStatus = _king_status_t.new()
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_path.ground_path_init(AI.create_nav_agent(), self)
	_forcefieldDetector.connect("body_entered", self, "_on_body_entered_forcefield_detector")
	# _result = _ent.connect("entity_trigger", self, "on_trigger")
	# skip ahead a little - need a proper option for this!
	#_eventCount = 2
	var _err = _coreReceptacle.connect("body_entered", self, "on_body_entered_core_receptacle")
	if !Main.is_in_game():
		_set_state(KingTowerState.InEditor)
	open_for_core()

func open_for_core() -> void:
	_awaitingCore = true
	_prismTop.transform.origin = Vector3(0, 1.5, 0)
	_prismBottom.transform.origin = Vector3(0, -0.5, 0)
	_coreCollisionShape.disabled = false
	get_tree().call_group(HudObjectives.GROUP_NAME, HudObjectives.FN_ADD_OBJECTIVE, _throwCoreObjective)

func close_from_core() -> void:
	_spawn_next_weapon()
	_awaitingCore = false
	_prismTop.transform.origin = Vector3(0, 1.0, 0)
	_prismBottom.transform.origin = Vector3(0, 0, 0)
	_coreCollisionShape.disabled = true
	_hintMessage = ""
	get_tree().call_group(HudObjectives.GROUP_NAME, HudObjectives.FN_REMOVE_OBJECTIVE, _throwCoreObjective)

func is_core_receptacle() -> bool:
	return true

func give_core() -> void:
	close_from_core()

func on_body_entered_core_receptacle(body) -> void:
	# print("Body touched core receptacle: " + str(body))
	if body.has_method("core_collect"):
		body.core_collect()
		close_from_core()
	pass

func player_status_update(data:PlayerHudStatus) -> void:
	_hudStatus = data

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
	#print("King tower saw mob die " + str(id))
	var i:int = _activeMobIds.find(id)
	if i == -1:
		return
	_activeMobIds.remove(i)
	if _activeMobIds.size() == 0:
		print("King tower - All mobs dead!")
	pass

func ents_item_collected_id(id:int) -> void:
	if id == _lastWeaponId:
		print("King tower - saw awaiting item " + str(id) + " collected")
		_lastWeaponId = 0
		var grp = HudObjectives.GROUP_NAME
		var fn = HudObjectives.FN_REMOVE_OBJECTIVE
		get_tree().call_group(grp, fn, _takeGunObjective)
		_awaitingWeaponPickup = false
	else:
		print("King tower - saw unknown item " + str(id) + " collected")

func get_editor_info() -> Dictionary:
	visible = true
	var info = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "nodesCSV", "Node CSV", "text", nodesCSV)
	return info

func _weapon_prefab_to_item_type(prefabType:String) -> String:
	if prefabType == "pistol":
		return "pistol"
	if prefabType == "chainsaw":
		return "chainsaw"
	if prefabType == "ssg":
		return "super_shotgun"
	if prefabType == "pg":
		return "plasma_gun"
	if prefabType == "rocket_launcher":
		return "rocket_launcher"
	return ""

func _refresh_weapons_list() -> void:
	for i in range(_weapons.size() - 1, -1, -1):
		var itemType:String = _weapon_prefab_to_item_type(_weapons[i])
		if itemType == "":
			continue
		var has:bool = AI.get_player_item_count(itemType) > 0
		if has:
			_weapons.remove(i)

func _spawn_next_weapon() -> void:
	_refresh_weapons_list()
	var hasPistol:bool = _weapons.find("pistol") == -1
	if hasPistol:
		if _eventCount < 9 && _eventCount % 3 != 0:
			return
	var type:String
	# always spawn pistol first
	if !hasPistol:
		type = "pistol"
	else:
		var l:int = _weapons.size()
		if l == 0:
			return
		var i:int = int(rand_range(0, l))
		type = _weapons[i]
	# _weapons.remove(i)
	_lastWeaponId = _spawn_item(type, 99999, true, false)
	_awaitingWeaponPickup = true
	var grp = HudObjectives.GROUP_NAME
	var fn = HudObjectives.FN_ADD_OBJECTIVE
	get_tree().call_group(grp, fn, _takeGunObjective)

func pick_spawn_point() -> Transform:
	var numPoints:int = _pointEnts.size()
	if numPoints == 0:
		return self.global_transform
	var i:int = int(rand_range(0, numPoints))
	var ent:Entity = _pointEnts[i]
	return ent.get_ent_transform()

func _spawn_item(
	type:String,
	timeToLive:float = 16.0,
	isImportant:bool = false,
	horizontalKick:bool = true) -> int:
	# var bulletDef = Ents.get_prefab_def("bullets_s")
	# var bullets = Ents.prefab
	var pos:Vector3 = self.global_transform.origin
	pos.y += 1.0
	var item = Ents.create_item(type, pos, isImportant)
	if item == null:
		print("King tower - failed to spawn item")
		return 0
	var vel:Vector3 = Vector3()
	vel.y = 10.0 # rand_range(5.0, 15.0)
	if horizontalKick:
		var radians:float = rand_range(0, PI * 2)
		var throwSpeed = rand_range(2.0, 4.0)
		vel.x = cos(radians) * throwSpeed
		vel.z = sin(radians) * throwSpeed
	item.set_velocity(vel)
	item.set_time_to_live(timeToLive)
	return item.get_ent_id()

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
	open_for_core()
	_outerShellMesh.visible = true
	_eventCount += 1

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
	var stepSize:float = speed * _delta
	var stillMoving:bool = _path.tick(_delta, stepSize)
	if stillMoving:
		var toward:Vector3 = _path.direction
		var step:Vector3 = ((toward * speed) * _delta)
		global_transform.origin += step
	else:
		global_transform.origin = _path.get_target_position()
		_state = KingTowerState.WaitingForPlayer

	#var origin:Vector3 = self.global_transform.origin
	#var plyr = AI.get_player_target()
	#var distToPlayer:float = origin.distance_to(plyr.position)
	# if distToPlayer > 8:
	# 	return
	
	#var dest:Vector3 = _get_event_ent().get_parent().global_transform.origin
	#var dist:float = origin.distance_to(dest)
	#var stillMoving:bool = false
	##_path.set_target_position(dest)
	#var stepSize:float = speed * _delta
	## still ground to cover, keep moving
	#if dist > (stepSize * 2.0):
	#	stillMoving = _path.tick(_delta, stepSize)
	#
	## did we finish this frame?
	#if stillMoving:
	#	var toward:Vector3 = _path.direction
	#	# just lerp straight to it
	#	# var toward:Vector3 = (dest - origin).normalized()
	#	var step:Vector3 = ((toward * speed) * _delta)
	#	global_transform.origin += step
	#else:
	#	if distToPlayer < 8:
	#		_outerShellMesh.visible = false
	#		_start_event()
	
func _move_spawn_tick(_delta:float) -> void:
	pass

func _broadcast_status() -> void:
	_kingStatus.waveCount = _eventCount
	_kingStatus.totalEventSeconds = _totalEventSeconds
	var ev = _get_event_ent()
	if ev != null:
		ev.get_parent().king_event_append_status(_kingStatus)
	var grp:String = Groups.GAME_GROUP_NAME
	var fn:String = Groups.GAME_FN_KING_STATUS_UPDATE
	get_tree().call_group(grp, fn, _kingStatus)

func _spawn_transition_mobs() -> void:
	var numNodes:int = _path.get_node_count()
	print("Spawning transition mobs - path has " + str(numNodes))
	var accumulator:float = 0.0
	var lastPos:Vector3 = _path.get_node_pos_by_index(0)
	var mobStep:float = 4.0
	var escape:int = 0
	var def:SpawnDef = Game.get_factory().new_spawn_def()
	for i in range(1, numNodes):
		var nextPos:Vector3 = _path.get_node_pos_by_index(i)
		accumulator = lastPos.distance_to(nextPos)
		while accumulator > mobStep:
			print("Transition spawn at " + str(nextPos))
			def.t = Transform.IDENTITY
			def.t.origin = nextPos
			def.type = Ents.PREFAB_MOB_PUNK
			def.forceAwake = false
			var mob = Game.get_factory().spawn_mob(def)
			accumulator -= mobStep
			escape += 1
			if escape > 1000:
				print("Transitions - ran away!")
				return
		lastPos = nextPos

func _tick_idle(_delta) -> void:
	var origin:Vector3 = self.global_transform.origin
	var losCheckOrigin:Vector3 = origin + Vector3(0, 1.0, 0)
	var dist:float = AI.get_distance_to_player_sqr(losCheckOrigin)
	if _awaitingWeaponPickup == true:
		return
	if _awaitingCore == true:
		return
	if dist < (8 * 8) && AI.check_los_to_player(losCheckOrigin) && _pick_event():
		var dest:Vector3 = _get_event_ent().get_parent().global_transform.origin
		_path.set_target_position(dest)
		_state = KingTowerState.MovingToEvent
		_outerShellMesh.visible = true
		Game.set_all_forcefields(true)
		_spawn_transition_mobs()

func _tick_hint_message(_delta:float) -> void:
	if _hintMessage == "":
		_hintTick = 0
		return
	_hintTick -= _delta
	var dict = AI.get_player_target()
	if dict.id == 0:
		return
	if _hintTick <= 0:
		_hintTick = 2.0
		# Game.show_hint_text(_hintMessage)

func _process(_delta:float):
	if _state == KingTowerState.InEditor:
		return
	
	_tick_hint_message(_delta)
	
	var origin:Vector3 = self.global_transform.origin
	var losCheckOrigin:Vector3 = origin + Vector3(0, 1.0, 0)
	if _state == KingTowerState.Idle:
		_tick_idle(_delta)
	elif _state == KingTowerState.RunningEvent:
		_totalEventSeconds += _delta
		pass
	elif _state == KingTowerState.MovingToEvent:
		_move_tick(_delta)
	elif _state == KingTowerState.WaitingForPlayer:
		var dist:float = AI.get_distance_to_player_sqr(losCheckOrigin)
		if dist < (8 * 8):
			_outerShellMesh.visible = false
			_start_event()
	elif _state == KingTowerState.WaitingForEvent:
		pass
	#if _mobSpawnTick <= 0.0:
	#	_mobSpawnTick = 0.1
	#	if _activeMobIds.size() < 3:
	#		var t:Transform = pick_spawn_point()
	#		var mob = Ents.create_mob_by_enum(Enums.EnemyType.Punk, t, true)
	#		mob.force_awake()
	#		var childId:int = mob.get_node("Entity").id
	#		_activeMobIds.push_back(childId)
	#	pass
	#else:
	#	_mobSpawnTick -= _delta
	
	if _ammoTick <= 0.0 && _hudStatus != null:
		_ammoTick = _ammoCooldown
		for _i in range(0, 2):
			if _hudStatus.hasPistol:
				_spawn_item("bullet_l")
			if _hudStatus.hasSuperShotgun:
				_spawn_item("shell_l")
			if _hudStatus.hasRailgun:
				_spawn_item("cell_l")
			if _hudStatus.hasRocketLauncher:
				_spawn_item("rocket_l")
	else:
		_ammoTick -= _delta
	
	_broadcast_status()
