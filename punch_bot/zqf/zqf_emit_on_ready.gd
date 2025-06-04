extends GPUParticles3D

@export var emitDuration:float = -1
@export var oneShot:bool = true

func _ready():
	self.one_shot = oneShot
	self.emitting = true
	set_duration(emitDuration)

func set_duration(seconds:float) -> void:
	emitDuration = seconds
	self.set_process(emitDuration > 0.0)

func _process(_delta:float) -> void:
	emitDuration -= _delta
	if emitDuration <= 0.0:
		emitDuration = 99999999
		self.emitting = false
