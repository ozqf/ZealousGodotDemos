extends StaticBody

@onready var _ent:Entity = $Entity
@onready var _area:Area3D = $Area
@onready var _solidShape:CollisionShape3D = $CollisionShape
@onready var _hurtShape:CollisionShape3D = $Area/CollisionShape

var _bodies = []
var _hitInfo:HitInfo
var _frames:int = 0

var _active:bool = true

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	_hitInfo.damage = 1
	_hitInfo.direction = Vector3.UP
	_hitInfo.damageType = Interactions.DAMAGE_TYPE_SLIME
	_area.connect("body_entered", self, "_on_body_entered")
	_area.connect("body_exited", self, "_on_body_exited")

	var _err = _ent.connect("entity_restore_state", self, "restore_state")
	_err = _ent.connect("entity_append_state", self, "append_state")
	_err = _ent.connect("entity_trigger", self, "on_trigger")
	set_active(_active)

func restore_state(dict:Dictionary) -> void:
	set_active(ZqfUtils.safe_dict_b(dict, "active", _active))
	ZqfUtils.safe_dict_apply_transform(dict, "xform", self)

func append_state(dict:Dictionary) -> void:
	dict["active"] = _active
	dict["xform"] = ZqfUtils.transform_to_dict(self.global_transform)

func get_editor_info() -> Dictionary:
	self.visible = true
	var info:Dictionary = _ent.get_editor_info_base()
	ZEEMain.create_field(info.fields, "active", "Active", "bool", str(self._active))
	info.scalable = true
	return info

func restore_from_editor(dict:Dictionary) -> void:
	_ent.restore_state(dict)

func _on_body_entered(body) -> void:
	if body is Player:
		body.set_over_slime(true)
		_bodies.push_back(body)

func _on_body_exited(body) -> void:
	if body is Player:
		body.set_over_slime(false)
		var i:int = _bodies.find(body)
		_bodies.remove(i)

func on_trigger(_msg:String, _params:Dictionary) -> void:
	if _msg == "on":
		set_active(true)
	elif _msg == "off":
		set_active(false)
	else:
		set_active(!_active)

func ents_on_global_command(command:String) -> void:
	if command == Groups.ENTS_CMD_DISABLE_ALL_FORCEFIELDS:
		set_active(false)
	elif command == Groups.ENTS_CMD_ENABLE_ALL_FORCEFIELDS:
		set_active(true)
	pass

func set_active(flag:bool) -> void:
	_active = flag
	if _active:
		visible = true
		_solidShape.disabled = false
		_hurtShape.disabled = false
	else:
		if !Main.is_in_editor():
			visible = false
		_solidShape.disabled = true
		_hurtShape.disabled = true

func _physics_process(_delta) -> void:
	_frames += 1
	if (_frames % 2) != 0:
		return
	for body in _bodies:
		if body is Player:
			Interactions.hit(_hitInfo, body)
	pass
