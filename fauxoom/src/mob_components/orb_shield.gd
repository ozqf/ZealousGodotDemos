extends Area
class_name OrbShield

signal shield_broke(index)
signal shield_restored(index)

onready var _shape:CollisionShape = $CollisionShape
onready var _restoreParticles = $restore_particles
onready var _mesh:MeshInstance = $MeshInstance

export var restoreTime:float = 0
export var health:int = 100

var index:int = 0
var _state:int = 0
var _health:int = 100
var _tick:float = 0

func _ready():
	_health = health
	_restoreParticles.emitting = false

func on() -> void:
	_tick = 0
	_state = 0
	_health = health
	_mesh.visible = true
	_shape.disabled = false
	emit_signal("shield_restored", index)
	_restoreParticles.emitting = false

func off() -> void:
	_restoreParticles.emitting = false
	_state = 1
	_mesh.visible = false
	_shape.disabled = true
	emit_signal("shield_broke", index)

func hit(_hitInfo:HitInfo) -> int:
	if _state == 1:
		#print("Orbs - state is inactive")
		return Interactions.HIT_RESPONSE_PENETRATE
	# only permit certain damage types
	var damage:int = _hitInfo.damage
	if !_hitInfo.damageType == Interactions.DAMAGE_TYPE_PLASMA:
		#print("Orbs - hit was not plasma!")
		#return Interactions.HIT_RESPONSE_NONE
		damage /= 3
		if damage < 1:
			damage = 1
	_health -= _hitInfo.damage
	# print("Hit shield orb")
	if _health <= 0:
		off()
	return _hitInfo.damage

func _process(_delta:float) -> void:
	if _state == 1 && restoreTime > 0:
		_tick += _delta
		if _tick >= restoreTime:
			on()
		else:
			var diff:int = restoreTime - _tick
			if diff < 5:
				_restoreParticles.emitting = true
