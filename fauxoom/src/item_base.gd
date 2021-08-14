extends KinematicBody

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

var _selfRespawnTick:float = 20
# export(String) var targetName:String = ""
var _active:bool = true
var _dead:bool = false
var _settings = null
var _player = null
var _spawnState:Dictionary
var _bRespawns:bool = false
var _respawnTime:float = 20

var _velocity:Vector3 = Vector3()

var _hasTriggeredTargets:bool = false

func _ready() -> void:
	# hide editor volume - only on the prefab to
	# make it easier to select in the editor
	$editor_volume.hide()



	add_to_group(Groups.GAME_GROUP_NAME)
	_spawnState = write_state()
	var _result = $Area.connect("body_entered", self, "on_body_entered")
	_result = $Area.connect("body_exited", self, "on_body_exited")

	_ent = get_parent().get_node("Entity")
	_result = _ent.connect("entity_restore_state", self, "restore_state")
	_result = _ent.connect("entity_append_state", self, "append_state")

func set_settings(settings) -> void:
	_bRespawns = settings.respawns
	_respawnTime = settings.selfRespawnTime

func append_state(_dict:Dictionary) -> void:
	_dict.pos = ZqfUtils.v3_to_dict(get_parent().global_transform.origin)
	_dict.active = _active
	_dict.tick = _selfRespawnTick
	_dict.bRespawns = _bRespawns

func write_state() -> Dictionary:
	return {
		position = global_transform.origin,
		active = _active
	}

func restore_state(_dict:Dictionary) -> void:
	get_parent().global_transform.origin = ZqfUtils.v3_from_dict(_dict.pos)
	_selfRespawnTick = _dict.tick
	_bRespawns = _dict.bRespawns
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

func broadcast_pickup() -> void:
	var grp = Groups.PLAYER_GROUP_NAME
	var fn = Groups.PLAYER_FN_PICKUP
	var description = ""
	if soundType == SoundType.Weapon:
		description = "weapon"
	get_tree().call_group(grp, fn, description)

func _set_active(flag:bool) -> void:
	# broadcast pickup for sound
	# print("Set item_base active: " + str(flag))
	
	# hide object until respawn
	_active = flag
	_areaShape.disabled = !_active

	if flag == true:
		_sprite.modulate = Color.white
	else:
		broadcast_pickup()
		if _bRespawns:
			_selfRespawnTick = _respawnTime 
		else:
			print("Culling item " + str(_ent.prefabName))
			get_parent().queue_free()

func _process(_delta:float) -> void:
	_velocity.y += -20 * _delta
	_velocity.x *= 0.95
	_velocity.z *= 0.95
	_velocity = move_and_slide(_velocity)
	# tick respawn timer
	if !_active:
		if _selfRespawnTick <= 0:
			_set_active(true)
		else:
			var step:float = 1 - (_selfRespawnTick / _respawnTime)
			var stepColour:float = 0.5 + (step * 0.5)
			var colour:Color = Color(stepColour, 0.3, 0.3, stepColour)
			_sprite.modulate = colour

			_selfRespawnTick -= _delta
			return
	
	# check for a player overlap and drop out if none
	if !_player:
		return
	
	# attempt to give item(s)
	# if either is taken, despawn
	var despawn:bool = false
	var triggerTargets:bool = false
	if type != "" && quantity > 0:
		var taken:int = _player.give_item(type, quantity)
		if taken > 0:
			despawn = true
		triggerTargets = true
	if subType != "" && subQuantity > 0:
		var taken:int = _player.give_item(subType, subQuantity)
		if taken > 0:
			despawn = true
		triggerTargets = true
	if triggerTargets && !_hasTriggeredTargets:
		_hasTriggeredTargets = true
		_ent.trigger()
	
	if despawn:
		_set_active(false)
