extends KinematicBody

onready var _shape:CollisionShape = $CollisionShape
onready var _sprite:Sprite3D = $Sprite3D
onready var _sprite2:Sprite3D = $Sprite3D2
# signal trigger()

onready var _ent:Entity = $Entity

export var health:int = 50
var _dead:bool = false

func _ready() -> void:
	var _r = _ent.connect("entity_append_state", self, "append_state")
	_r = _ent.connect("entity_restore_state", self, "restore_state")
	_r = _ent.connect("entity_trigger", self, "on_trigger")

func append_state(_dict:Dictionary) -> void:
	pass

func restore_state(_dict:Dictionary) -> void:
	pass

func check_damage_type(damageType:int) -> bool:
	if damageType == Interactions.DAMAGE_TYPE_SAW:
		return true
	return false

func hit(_hitInfo:HitInfo) -> int:
	if _dead:
		return 0
	if !check_damage_type(_hitInfo.damageType):
		print("Bad damage type " + str(_hitInfo.damageType))
		return 0
	health -= _hitInfo.damage
	print("breakable hp: " + str(health))
	if health <= 0:
		_shape.disabled = true
		_sprite.visible = false
		_sprite2.visible = false
		_dead = true
	return _hitInfo.damage
