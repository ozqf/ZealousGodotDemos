extends Spatial

const DAMAGE_PER_TICK:int = 10
const DAMAGE_TICKS_DELAY:float = 0.5

const STATE_WAITING:int = -1
const STATE_GROWING:int = 0
const STATE_GROWN:int = 1
const STATE_SHRINKING:int = 2
const STATE_DEAD:int = 3

const GROW_TIME:float = 2.0 # 0.4
const GROWN_TIME:float = 1.5

export var harmlessMaterial:SpatialMaterial = null
export var dangerousMaterial:SpatialMaterial = null

onready var _cone:MeshInstance = $cone
onready var _area:Area = $Area

var _player = null

var _spikeState:int = 0
var _time:float = 0
var _spawnWait:float = 1.0
var _hitInfo:HitInfo = null
var _hitTick:float = 0

func _ready() -> void:
	self.add_to_group(Groups.PRJ_GROUP_NAME)
	_hitInfo = Game.new_hit_info()
	_area.connect("body_entered", self, "on_body_entered")
	_area.connect("body_exited", self, "on_body_exited")
	_hitInfo.attackTeam = Interactions.TEAM_ENEMY
	_hitInfo.damage = DAMAGE_PER_TICK
	_spikeState = STATE_GROWING

func prj_bullet_cancel_at(point:Vector3, radius:float, teamId:int) -> void:
	if teamId != Interactions.TEAM_ENEMY:
		return
	var origin:Vector3 = self.global_transform.origin
	if origin.distance_squared_to(point) < (radius * radius):
		_spikeState = STATE_DEAD
		queue_free()

func wait(seconds:float) -> void:
	_spawnWait = seconds
	_time = 0.0
	_spikeState = STATE_WAITING
	visible = false
	if harmlessMaterial != null:
		_cone.material_override = harmlessMaterial

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
	if _spikeState == STATE_GROWING:
		weight = _time / GROW_TIME
		if _time > GROW_TIME:
			_time = 0
			_spikeState = STATE_GROWN
			if dangerousMaterial != null:
				_cone.material_override = dangerousMaterial
	elif _spikeState == STATE_GROWN:
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
		if _time > GROWN_TIME:
			_time = 0
			_spikeState = STATE_SHRINKING
			if harmlessMaterial != null:
				_cone.material_override = harmlessMaterial
	elif _spikeState == STATE_SHRINKING:
		weight = _time / 1
		weight = 1 - weight
		if _time > 1:
			_time = 0
			_spikeState = STATE_DEAD
			queue_free()
	elif _spikeState == STATE_WAITING:
		if _time >= _spawnWait:
			weight = 0.0
			visible = true
			_time = 0.0
			_spikeState = STATE_GROWING
			if harmlessMaterial != null:
				_cone.material_override = harmlessMaterial
		else:
			return
	else:
		return
	_set_scale(weight)
