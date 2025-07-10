extends CharacterBody3D

@onready var _input:PlayerInput = $PlayerInput

func _ready() -> void:
	print("Avatar type B spawned")

func _process(_delta: float) -> void:
	var yaw:float = _input.lookKeys.x
	var t:Transform3D = self.global_transform
	self.rotate(t.basis.y, yaw * _delta * 4.0)
	pass

func _physics_process(_delta) -> void:

	var t:Transform3D = self.global_transform
	
	# var _pushDirection:Vector3 = (basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	#var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(_input.inputDir, t.basis)
	var pushInput:Vector3 = Vector3(_input.inputDir.x, 0, _input.inputDir.y)
	var pushDir:Vector3 = (t.basis * pushInput).normalized()
	pushDir *= 10.0
	var v:Vector3 = self.velocity
	v.x = pushDir.x
	v.y += -20.0 * _delta
	v.z = pushDir.z
	self.velocity = v
	self.move_and_slide()
	pass
