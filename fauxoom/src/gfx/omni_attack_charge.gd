extends Spatial
class_name OmniAttackCharge

onready var _mesh:MeshInstance = $MeshInstance
onready var _particles:CPUParticles = $CPUParticles

var _duration:float = 1
var _tick:float = 0
var _on:bool = false
var _meshFullScale:Vector3 = Vector3(1, 1, 1)

func _ready() -> void:
	off()
	_meshFullScale = _mesh.scale

func on(duration:float) -> void:
	_on = true
	_duration = duration
	_tick = _duration
	_mesh.visible = true
	_particles.emitting = true

func off() -> void:
	_on = false
	_mesh.visible = false
	_particles.emitting = false

func _process(_delta:float) -> void:
	if !_on:
		return
	_tick -= _delta
	if _tick <= 0:
		off()
		return
	var lerpValue:float = _tick / _duration
	lerpValue = 1 - lerpValue
	_mesh.scale = _meshFullScale * lerpValue
