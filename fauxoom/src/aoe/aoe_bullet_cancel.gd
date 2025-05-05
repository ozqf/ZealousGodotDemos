extends Node3D

@onready var _scanner:ZqfVolumeScanner = $Area

var _tick:float = 0.0
var _dead:bool = false

func _physics_process(_delta) -> void:
	if _dead:
		return
	_tick += _delta
	var grp:String = Groups.PRJ_GROUP_NAME
	var fn:String = Groups.PRJ_FN_BULLET_CANCEL_AT
	var origin:Vector3 = self.global_transform.origin
	var radius:float = 4.0
	get_tree().call_group(grp, fn, origin, radius, Interactions.TEAM_ENEMY)

	if _tick > 3.0:
		_dead = true
		queue_free()
