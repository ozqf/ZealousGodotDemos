extends CharacterBody3D

@onready var _ent:Entity = $Entity
@onready var _shape:CollisionShape3D = $CollisionShape
@onready var _sprite:AnimatedSprite3D = $Sprite

var _dead:bool = false
var _beingCarried:bool = false

func _ready():
	_ent.connect("entity_append_state", self, "append_state")
	_ent.connect("entity_restore_state", self, "restore_state")
	pass # Replace with function body.

func append_state(_dict:Dictionary) -> void:
	_dict.pos = ZqfUtils.v3_to_dict(global_transform.origin)
	_dict.dead = _dead

func restore_state(_dict:Dictionary) -> void:
	global_transform.origin = ZqfUtils.v3_from_dict(_dict.pos)
	_dead = _dict.dead

func use_interactive(_user) -> String:
	
	print("Barrel - use!")
	_beingCarried = true
	_shape.disabled = true
	_sprite.modulate = Color(1, 0, 0, 0.5)
	return ""

func hit(_hitInfo:HitInfo) -> int:
	print("Barrel - hit for " + str(_hitInfo.damage))
	return Interactions.HIT_RESPONSE_NONE

func _process(_delta:float) -> void:
	if _beingCarried:
		var info:Dictionary = AI.get_player_target()
		if info.id == 0:
			return
		var t:Transform3D = info.throwableTransform
		#global_transform = t
		global_transform.origin = t.origin
