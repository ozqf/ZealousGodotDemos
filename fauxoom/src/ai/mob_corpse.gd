extends KinematicBody

var _death1:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_1.wav")
var _death2:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_2.wav")
var _death3:AudioStream = preload("res://assets/sounds/mob/punk/punk_death_3.wav")

var _slop:AudioStream = preload("res://assets/sounds/impact/slop.wav")
var _headshot:AudioStream = preload("res://assets/sounds/impact/headshot.wav")

enum CorpseState {
	None,
	RegularDeath,
	HeadshotSpurt,
	Gibbed,
	Unresponsive # if this, don't respond to hits etc anymore
}

onready var _sprite:CustomAnimator3D = $CustomAnimator3D
onready var _headshotSpurt:CPUParticles = $headshot_spurt
onready var _wholebodyBurst:CPUParticles = $wholebody_burst
onready var _collisionShape:CollisionShape = $CollisionShape
onready var _audio:AudioStreamPlayer3D = $AudioStreamPlayer3D

var _velocity:Vector3 = Vector3()
var _friction:float = 0.95

var _state = CorpseState.None
var _tick:float = 0
var _damageTaken:int = 0

var _wholeBodyBleedTick:float = 0.0

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)

func game_cleanup_temp_ents() -> void:
	queue_free()

func _damage_hit(direction:Vector3, _hitStrength:float = 1.5) -> void:
	_velocity += direction * _hitStrength

# func _play_stream(audio: AudioStreamPlayer3D, stream:AudioStream, pitchAlt:float = 0.0, plusDb:float = 0.0) -> void:
# 	_audio.pitch_scale = rand_range(1 - pitchAlt, 1 + pitchAlt)
# 	_audio.volume_db = plusDb
# 	_audio.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
# 	_audio.stream = stream
# 	_audio.play(0)

func _spawn_hit_particles(pos:Vector3, deathHit:bool) -> void:
	var numParticles = 4
	var _range:float = 0.15
	if deathHit:
		numParticles = 12
		_range =- 0.35
	var root:Node = get_tree().get_current_scene()
	for _i in range(0, numParticles):
		var blood = Game.get_factory().prefab_blood_hit.instance()
		root.add_child(blood)
		var offset:Vector3 = Vector3(
			rand_range(-_range, _range),
			rand_range(-_range, _range),
			rand_range(-_range, _range))
		blood.global_transform.origin = (pos + offset)

func hit(_spawnInfo:HitInfo) -> int:
	# in a state that is not hittable
	if _state == CorpseState.Unresponsive:
		return Interactions.HIT_RESPONSE_PENETRATE
	
	# gib - remove self
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		_gib_death(_spawnInfo.direction)
		return Interactions.HIT_RESPONSE_PENETRATE
	
	if _sprite.get_frame_number() > 1:
		return Interactions.HIT_RESPONSE_PENETRATE

	if _state == CorpseState.RegularDeath:
		_damageTaken += _spawnInfo.damage
		var selfPos:Vector3 = global_transform.origin
		var hitHeight:float = _spawnInfo.origin.y - selfPos.y
		
		if _damageTaken > 100 && hitHeight > 1.2:
			_headshot_death()
		else:
			var pushStrength = 1.5
			if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_SHARPNEL:
				pushStrength = 3
			_damage_hit(_spawnInfo.direction, pushStrength)
			if _sprite.get_frame_number() == 1:
				_sprite.set_frame_number(0)
			_spawn_hit_particles(_spawnInfo.origin, false)
			
	return Interactions.HIT_RESPONSE_PENETRATE

func _headshot_death() -> void:
	_headshotSpurt.emitting = true
	_state = CorpseState.HeadshotSpurt
	_tick = 2
	var pos:Vector3 = global_transform.origin
	pos.y += 1.3
	_spawn_hit_particles(pos, true)
	_sprite.play_animation("headshot_stand")
	ZqfUtils.play_3d(_audio, _headshot)

func _play_death_sound() -> void:
	var r = randf()
	var stream = _death3
	if r > 0.666:
		stream = _death1
	elif r > 0.333:
		stream = _death2
	_audio.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	_audio.stream = stream
	_audio.play(0)

func _gib_death(_forward:Vector3) -> void:
	# show doom style gib animation
	# _sprite.play_animation("dying_gib")
	# _state = CorpseState.Unresponsive
	
	# build style explode into gibs
	Game.get_factory().spawn_gibs(global_transform.origin, Vector3.UP, 8)
	_state = CorpseState.Unresponsive
	# disappear in 10 seconds
	_tick = 10
	# self.queue_free()
	_collisionShape.disabled = true
	visible = false
	_whole_body_bleed(96, 0.3)

	_audio.set_attenuation_model(AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE)
	_audio.stream = _slop
	_audio.play(0)

func _regular_death() -> void:
	_sprite.play_animation("dying")
	_state = CorpseState.RegularDeath
	_play_death_sound()

func _whole_body_bleed(amount:int, duration:float) -> void:
	_wholebodyBurst.emitting = true
	_wholebodyBurst.amount = amount
	_wholeBodyBleedTick = duration

func spawn(_spawnInfo:CorpseSpawnInfo, _trans:Transform) -> void:
	global_transform = _trans
	var selfPos:Vector3 = global_transform.origin
	if _spawnInfo == null:
		_regular_death()
		return
	var hitHeight:float = _spawnInfo.origin.y - selfPos.y
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
		_gib_death(_spawnInfo.direction)
		return
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_PUNCH:
		_regular_death()
		return
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_SAW:
		_regular_death()
		_damage_hit(_spawnInfo.direction, 5.0)
		return
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_SUPER_PUNCH:
		_gib_death(_spawnInfo.direction)
		return
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_SHARPNEL:
		_regular_death()
		_whole_body_bleed(48, 0.3)
		
		_damage_hit(_spawnInfo.direction, 3.0 * _spawnInfo.hitCount)
		return
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_NONE:
		if hitHeight >= 1.3 && randf() > 0.9:
			_headshot_death()
			return
	if _spawnInfo.damageType == Interactions.DAMAGE_TYPE_PLASMA:
		_headshot_death()
		_whole_body_bleed(48, 0.3)
		return
	_regular_death()
	_whole_body_bleed(16, 0.3)
	# if hitHeight > 1.2:
	# 	_headshot_death()
	# elif _spawnInfo.damageType == Interactions.DAMAGE_TYPE_EXPLOSIVE:
	# 	__gib_Death(_spawnInfo.direction)
	# else:
	# 	_regular_death()

func _physics_process(_delta:float) -> void:
	_tick -= _delta
	if _state == CorpseState.HeadshotSpurt && _tick <= 0:
		_tick = 99999
		_sprite.play_animation("headshot_dying")
		_state = CorpseState.None
		_headshotSpurt.emitting = false
	elif _state == CorpseState.Unresponsive:
		if _tick <= 0:
			_tick = 99999
			queue_free()
		return
	_velocity.x *= _friction
	_velocity.z *= _friction
	_velocity.y -= 15.0 * _delta
	_velocity = move_and_slide(_velocity)
	
	if _wholeBodyBleedTick > 0.0:
		_wholeBodyBleedTick -= _delta
		if _wholeBodyBleedTick <= 0.0:
			_wholebodyBurst.emitting = false
