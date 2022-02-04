extends Spatial

const DAMAGE_PER_TICK:int = 10
const DAMAGE_TICKS_DELAY:float = 0.5

onready var _cone:MeshInstance = $cone
onready var _area:Area = $Area

var _player = null

var _spikeState:int = 0
var _time:float = 0
var _hitInfo:HitInfo = null
var _hitTick:float = 0

func _ready() -> void:
	_hitInfo = Game.new_hit_info()
	_area.connect("body_entered", self, "on_body_entered")
	_area.connect("body_exited", self, "on_body_exited")
	_hitInfo.attackTeam = Interactions.TEAM_ENEMY
	_hitInfo.damage = DAMAGE_PER_TICK
	pass

func on_body_entered(body) -> void:
	if _player != null:
		return
	if ZqfUtils.is_obj_safe(body) && body is Player:
		_player = body
	pass

func on_body_exited(body) -> void:
	if body == _player:
		_player = null
	pass

func _set_scale(weight:float) -> void:
	if weight > 1:
		weight = 1
	if weight < 0:
		weight = 0
	var t:float = lerp(0, 1, weight)
	_cone.scale = Vector3(t, t, t)
	_cone.transform.origin = Vector3(0, t, 0)
	visible = true

func _process(_delta:float) -> void:
	_time += _delta
	var weight:float = 1
	if _spikeState == 0:
		weight = _time / 0.2
		if _time > 0.2:
			_time = 0
			_spikeState = 1
	elif _spikeState == 1:
		# hit player?
		if ZqfUtils.is_obj_safe(_player):
			if _hitTick <= 0:
				# print("Spike hit player")
				_hitTick = DAMAGE_TICKS_DELAY
				_hitInfo.origin = global_transform.origin
				_player.hit(_hitInfo)
			else:
				_hitTick -= _delta
		else:
			_player = null
		if _time > 2:
			_time = 0
			_spikeState = 2
	elif _spikeState == 2:
		weight = _time / 1
		weight = 1 - weight
		if _time > 1:
			_time = 0
			# _spikeState = 0
			queue_free()
	else:
		return
	_set_scale(weight)
