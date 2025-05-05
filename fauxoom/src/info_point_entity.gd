extends Node3D

@onready var _ent:Entity = $Entity

@export var targetName:String = ""
@export var triggerTargetName:String = ""

var _losCheckTick:float = 0.0

var seesPlayer:bool = true
var timeSinceLastSighting:float = 0.0
var distanceToPlayer:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = _ent.connect("entity_append_state", self, "append_state")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	if targetName != "":
		_ent.selfName = targetName
	else:
		_ent.selfName = name
	if Main.is_in_game():
		visible = false

func append_state(_dict:Dictionary) -> void:
	_dict.xform = ZqfUtils.transform_to_dict(global_transform)
	pass

func restore_state(data:Dictionary) -> void:
	ZqfUtils.safe_dict_apply_transform(data, "xform", self)
	pass

func get_editor_info() -> Dictionary:
	var info = _ent.get_editor_info_base()
	return info

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func _physics_process(_delta:float) -> void:
	var _info:Dictionary = AI.get_player_target()
	if _info.id == 0:
		return
	var origin:Vector3 = global_transform.origin
	distanceToPlayer = origin.distance_to(_info.position)
	# tick los checker faster the closer the player is
	var weight:float = ZqfUtils.clamp_float(distanceToPlayer / 100.0, 0.0, 1.0)
	var step:float = _delta * lerp(10.0, 1.0, weight)
	_losCheckTick += step
	# print("Info node weight " + str(weight) + " Step " + str(step) + " time: " + str(_losCheckTick))
	if _losCheckTick >= 10.0:
		_losCheckTick = 0.0
		seesPlayer = AI.check_los_to_player(origin)
	if seesPlayer:
		timeSinceLastSighting += _delta


