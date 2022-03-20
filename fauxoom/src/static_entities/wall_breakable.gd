extends Node

onready var _crackedMesh:MeshInstance = $cracked
onready var _smashedMesh:MeshInstance = $smashed
onready var _ent:Entity = $Entity
var _dead:bool = false

func _ready():
	$cracked/StaticBody.set_subject(self)
	_crackedMesh.visible = true
	_smashedMesh.visible = false
	_ent.connect("entity_append_state", self, "append_state")
	_ent.connect("entity_restore_state", self, "restore_state")
	_ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = self.name

func append_state(_dict:Dictionary) -> void:
	_dict.dead = _dead

func restore_state(_dict:Dictionary) -> void:
	if _dict.dead:
		_die()
	else:
		_restore()

func on_trigger(_msg, _dict) -> void:
	print("Wall breakable has no trigger action!")

func _check_damage_type(dmgType:int) -> bool:
	if dmgType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		return true
	if dmgType == Interactions.DAMAGE_TYPE_SUPER_PUNCH:
		return true
	return false

func _restore() -> void:
	_dead = false
	$cracked.visible = true
	$cracked/StaticBody/CollisionShape.disabled = false
	$smashed.visible = false

func _die() -> void:
	_dead = true
	$cracked.visible = false
	$cracked/StaticBody/CollisionShape.disabled = true
	$smashed.visible = true

func hit(_hitInfo:HitInfo) -> int:
	if _dead == true:
		return Interactions.HIT_RESPONSE_NONE
	if !_check_damage_type(_hitInfo.damageType):
		print("Bad damage type " + str(_hitInfo.damageType))
		return Interactions.HIT_RESPONSE_NONE
	_die()
	return 1
