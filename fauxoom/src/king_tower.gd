extends Spatial
class_name KingTower

const Enums = preload("res://src/enums.gd")

onready var _ent:Entity = $Entity

export var nodesCSV:String = ""

enum KingTowerState {
	Idle,
	InEditor
}

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

func _ready() -> void:
	add_to_group(Groups.ENTS_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	# _result = _ent.connect("entity_trigger", self, "on_trigger")
	if !Main.is_in_game():
		_set_state(KingTowerState.InEditor)

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
	var data = {
		scalable = false,
		rotatable = true,
		fields = {
			nodesCSV = { name = "nodesCSV", type = "text", "value": nodesCSV }
		}
	}
	return data

func pick_spawn_point() -> Transform:
	var numPoints:int = _pointEnts.size()
	if numPoints == 0:
		return self.global_transform
	var i:int = int(rand_range(0, numPoints))
	var ent:Entity = _pointEnts[i]
	return ent.get_ent_transform()

func _spawn_ammo() -> void:
	# var bulletDef = Ents.get_prefab_def("bullets_s")
	# var bullets = Ents.prefab
	var pos:Vector3 = self.global_transform.origin
	pos.y += 1.0
	var item = Ents.create_item("bullet_s", pos)
	if item == null:
		print("King tower - failed to spawn item")
		return
	var vel:Vector3 = Vector3()
	vel.y = 10.0 # rand_range(5.0, 15.0)
	var radians:float = rand_range(0, PI * 2)
	var speed = rand_range(2.0, 4.0)
	vel.x = cos(radians) * speed
	vel.z = sin(radians) * speed
	item.set_velocity(vel)
	item.set_time_to_live(16.0)

func _start_event() -> void:
	if _eventEnts.size() > 0:
		_eventIndex = 0
		_eventEnts[_eventIndex].get_parent().king_event_start()
	else:
		print("King tower - no events to start")

func _process(_delta:float):
	if _state == KingTowerState.InEditor:
		return
	if _eventIndex < 0:
		_start_event()
	if _mobSpawnTick <= 0.0:
		_mobSpawnTick = 0.1
		if _activeMobIds.size() < 3:
			var t:Transform = pick_spawn_point()
			var mob = Ents.create_mob(Enums.EnemyType.Punk, t, true)
			mob.force_awake()
			var childId:int = mob.get_node("Entity").id
			_activeMobIds.push_back(childId)
		pass
	else:
		_mobSpawnTick -= _delta
	
	if _ammoTick <= 0.0:
		_ammoTick = _ammoCooldown
		for _i in range(0, 4):
			_spawn_ammo()
	else:
		_ammoTick -= _delta