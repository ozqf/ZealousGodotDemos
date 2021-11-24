extends KinematicBody

var _prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")

enum CorpseState {
	None,
	RegularDeath,
	HeadshotSpurt,
	Gibbed,
	Unresponsive # if this, don't respond to hits etc anymore
}

onready var _sprite:CustomAnimator3D = $CustomAnimator3D
onready var _headshotSpurt:CPUParticles = $headshot_spurt

var _velocity:Vector3 = Vector3()
var _friction:float = 0.99

var _state = CorpseState.None
var _tick:float = 0
var _damageTaken:int = 0

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)

func game_cleanup_temp_ents() -> void:
	queue_free()

func damage_hit(_hitInfo:HitInfo) -> void:
	var strength:float = 1.5
	_velocity += _hitInfo.direction * strength

func _spawn_hit_particles(pos:Vector3, deathHit:bool) -> void:
	var numParticles = 4
	var _range:float = 0.15
	if deathHit:
		numParticles = 12
		_range =- 0.35
	var root:Node = get_tree().get_current_scene()
	for _i in range(0, numParticles):
		var blood = _prefab_blood_hit.instance()
		root.add_child(blood)
		var offset:Vector3 = Vector3(
			rand_range(-_range, _range),
			rand_range(-_range, _range),
			rand_range(-_range, _range))
		blood.global_transform.origin = (pos + offset)

func hit(_hitInfo:HitInfo) -> int:
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		# gib - remove self
		gib_death(_hitInfo.direction)
		return Interactions.HIT_RESPONSE_PENETRATE
	if _state == CorpseState.Unresponsive:
		return Interactions.HIT_RESPONSE_PENETRATE
	
	if _sprite.get_frame_number() > 1:
		return Interactions.HIT_RESPONSE_PENETRATE

	if _state == CorpseState.RegularDeath:
		_damageTaken += _hitInfo.damage
		var selfPos:Vector3 = global_transform.origin
		var hitHeight:float = _hitInfo.origin.y - selfPos.y
		if _damageTaken > 100 && hitHeight > 1.2:
			headshot_death()
		else:
			damage_hit(_hitInfo)
			if _sprite.get_frame_number() == 1:
				_sprite.set_frame_number(0)
			_spawn_hit_particles(_hitInfo.origin, false)
			
	return Interactions.HIT_RESPONSE_PENETRATE

func headshot_death() -> void:
	_headshotSpurt.emitting = true
	_state = CorpseState.HeadshotSpurt
	_tick = 2
	var pos:Vector3 = global_transform.origin
	pos.y += 1.3
	_spawn_hit_particles(pos, true)
	_sprite.play_animation("headshot_stand")
	pass

func gib_death(_forward:Vector3) -> void:
	# show doom style gib animation
	# _sprite.play_animation("dying_gib")
	# _state = CorpseState.Unresponsive
	
	# build style explode into gibs
	Game.spawn_gibs(global_transform.origin, Vector3.UP, 8)
	_state = CorpseState.Unresponsive
	self.queue_free()

func regular_death() -> void:
	_sprite.play_animation("dying")
	_state = CorpseState.RegularDeath

func spawn(_hitInfo:HitInfo, _trans:Transform) -> void:
	global_transform = _trans
	var selfPos:Vector3 = global_transform.origin
	var hitHeight:float = _hitInfo.origin.y - selfPos.y
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		gib_death(_hitInfo.direction)
		return
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_NONE:
		if hitHeight >= 1.3 && randf() > 0.9:
			headshot_death()
			return
	if _hitInfo.damageType == Interactions.DAMAGE_TYPE_PLASMA:
		headshot_death()
		return
	regular_death()
	# if hitHeight > 1.2:
	# 	headshot_death()
	# elif _hitInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
	# 	gib_death(_hitInfo.direction)
	# else:
	# 	regular_death()

func _process(_delta:float) -> void:
	_tick -= _delta
	if _state == CorpseState.HeadshotSpurt && _tick <= 0:
		_tick = 99999
		_sprite.play_animation("headshot_dying")
		_state = CorpseState.None
		_headshotSpurt.emitting = false
	_velocity.x *= _friction
	_velocity.z *= _friction
	_velocity.y -= 15.0 * _delta
	_velocity = move_and_slide(_velocity)
