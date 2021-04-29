extends PhysicsBody

onready var _sprite:AnimatedSprite3D = $sprite
onready var _areaShape:CollisionShape = $Area/CollisionShape
var _ent:Entity
# move to separate class
# https://godotengine.org/qa/40827/how-to-declare-a-global-named-enum
enum SoundType {
	Generic,
	Weapon
}
export(SoundType) var soundType = SoundType.Generic

# two item types are specified, as items like weapons will give two
# items (the weapon itself + ammunition)
export(String) var type:String = ""
export(int) var quantity:int = 1

export(String) var subType:String = ""
export(int) var subQuantity:int = 1

export(int) var respawnTime:int = 0
# export(String) var targetName:String = ""
var _active:bool = true

var _player = null

var _spawnState:Dictionary

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	_spawnState = write_state()
	var _result = $Area.connect("body_entered", self, "on_body_entered")
	_result = $Area.connect("body_exited", self, "on_body_exited")

	_ent = get_parent().get_node("Entity")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_append_state", self, "append_state")

func append_state(_dict:Dictionary) -> void:
	_dict.pos = ZqfUtils.v3_to_dict(get_parent().global_transform.origin)
	_dict.active = _active

func write_state() -> Dictionary:
	return {
		position = global_transform.origin,
		active = _active
	}

func restore_state(_dict:Dictionary) -> void:
	get_parent().global_transform.origin = ZqfUtils.v3_from_dict(_dict.pos)
	# global_transform.origin = data.position
	_set_active(_dict.active)

func game_on_reset() -> void:
	# print("Item saw reset")
	restore_state(_spawnState)

func on_body_entered(body:Node) -> void:
	if body.has_method("give_item"):
		_player = body

func on_body_exited(body:Node) -> void:
	if body == _player:
		_player = null

func _set_active(flag:bool) -> void:
	_active = flag
	_sprite.visible = _active
	_areaShape.disabled = !_active
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_PICKUP
	var description = ""
	if soundType == SoundType.Weapon:
		description = "weapon"
	get_tree().call_group(grp, fn, description)

func _process(_delta:float) -> void:
	
	if !_active || !_player:
		return
	
	# attempt to give item(s)
	# if either is taken, despawn
	var despawn:bool = false
	if type != "" && quantity > 0:
		var taken:int = _player.give_item(type, quantity)
		if taken > 0:
			despawn = true
	if subType != "" && subQuantity > 0:
		var taken:int = _player.give_item(subType, subQuantity)
		if taken > 0:
			despawn = true
	
	if despawn:
		_set_active(false)
