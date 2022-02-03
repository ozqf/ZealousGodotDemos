extends InstantAreaScan
class_name HyperAoe

const Enums = preload("res://src/enums.gd")

const TYPE_HYPER_ON:int = 0
const TYPE_HYPER_OFF:int = 1
const TYPE_HYPER_CANCEL:int = 2
const TYPE_SUPER_PUNCH:int = 3

var _aoeType:int = 0
var _weight:float = 0.0

func _ready() -> void:
	self.connect("scan_result", self, "on_scan_result")
	pass

func on_scan_result(bodies) -> void:
	var pos:Vector3 = global_transform.origin
	for body in bodies:
		if !Interactions.is_obj_a_mob(body):
			continue
		var mobPos:Vector3 = body.global_transform.origin
		var toward:Vector3 = (mobPos - pos).normalized()
		if _aoeType == TYPE_HYPER_CANCEL:
			body.apply_stun(toward, 6.0 * _weight)
		elif _aoeType == TYPE_SUPER_PUNCH:
			body.apply_stun(toward, 4.0)
			Game.spawn_rage_drops(mobPos, Enums.QuickDropType.Health, 1)
		else:
			body.apply_stun(toward, 2.0)
		print("Hyper aoe - stunning mob")
	queue_free()

func run_hyper_aoe(aoeType:int, weight:float) -> void:
	_aoeType = aoeType
	_weight = weight
	var shockwave = Game.prefab_shockwave_t.instance()
	Game.get_dynamic_parent().add_child(shockwave)
	shockwave.global_transform.origin = global_transform.origin
	shockwave.run(15)
	.run()
