extends CharacterBody3D

@onready var _input:PlayerInput = $PlayerInput

func _ready() -> void:
	print("Avatar type B spawned")

func _reset() -> void:
	pass

func _physics_process(_delta) -> void:

	var t:Transform3D = self.global_transform

	var pushDir:Vector3 = ZqfUtils.input_to_push_vector_flat(_input.inputDir, t.basis)
	pushDir *= 10.0
	self.velocity = pushDir
	self.move_and_slide()
	pass