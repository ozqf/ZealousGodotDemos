extends CharacterBody3D

# if none, must be triggered to break
enum DamageMode {
	All,
	SawOnly,
	PunchOnly,
	ExplosiveOnly,
	SiegeOnly,
	None
}

@onready var _shape:CollisionShape3D = $CollisionShape
@onready var _meshes:Node3D = $meshes
# @onready var _sprite:Sprite3D = $Sprite3D
# @onready var _sprite2:Sprite3D = $Sprite3D2
# signal trigger()

@onready var _ent:Entity = $Entity

export(DamageMode) var damageMode = DamageMode.All
@export var health:int = 50
var _acceptedDamageType:int = 0
var _dead:bool = false

func _ready() -> void:
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")
	refresh_damage_mode()

func refresh_damage_mode() -> void:
	
	if damageMode == DamageMode.SawOnly:
		_acceptedDamageType = Interactions.DAMAGE_TYPE_SAW
	elif damageMode == DamageMode.ExplosiveOnly:
		_acceptedDamageType = Interactions.DAMAGE_TYPE_EXPLOSIVE
	elif damageMode == DamageMode.SiegeOnly:
		_acceptedDamageType = Interactions.DAMAGE_TYPE_SIEGE
	elif damageMode == DamageMode.PunchOnly:
		_acceptedDamageType = Interactions.DAMAGE_TYPE_PUNCH

func append_state(_dict:Dictionary) -> void:
	_dict.dead = _dead
	_dict.hp = health

func restore_state(_dict:Dictionary) -> void:
	refresh_damage_mode()
	health = _dict.hp
	set_dead(_dict.dead)

func set_dead(flag:bool) -> void:
	_dead = flag
	if _dead:
		_shape.disabled = true
		_meshes.visible = false
	else:
		_shape.disabled = false
		_meshes.visible = true

func check_damage_type(_incomingType:int) -> bool:
	if damageMode == DamageMode.All:
		return true
	if damageMode == DamageMode.None:
		return false
	if _incomingType == _acceptedDamageType:
		return true
	return false

func hit(_hitInfo:HitInfo) -> int:
	if _dead:
		return 0
	if !check_damage_type(_hitInfo.damageType):
		# print("Bad damage type " + str(_hitInfo.damageType) + " vs " + str(_acceptedDamageType))
		return 0
	health -= _hitInfo.damage
	# print("breakable hp: " + str(health))
	if health <= 0:
		_shape.disabled = true
		_meshes.visible = false
		_dead = true
	return _hitInfo.damage
