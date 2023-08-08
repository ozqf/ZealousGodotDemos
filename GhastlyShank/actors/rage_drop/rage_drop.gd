extends Area3D

const GROUP_NAME:String = "group_rage_drops"

const STATE_IDLE:int = 0
const STATE_FLYING:int = 1

@onready var _mesh:MeshInstance3D = $MeshInstance3D
@onready var _decal:Decal = $Decal

var _velocity:Vector3 = Vector3()

var _state:int = STATE_IDLE

func _ready() -> void:
	#self.connect("sleeping_state_changed", _on_sleep_changed)
	self.connect("body_entered", _on_body_entered)
	self.add_to_group(GROUP_NAME)
	var nodes = self.get_tree().get_nodes_in_group(GROUP_NAME)
	print(str(nodes.size()) + " rage drops spawned")

func _on_body_entered(body:Node) -> void:
	if _state == STATE_FLYING:
		_set_state(STATE_IDLE)
	pass

func _set_state(newState:int) -> void:
	_state = newState
	match _state:
		STATE_FLYING:
			_mesh.visible = true
			_decal.visible = false
			#self.freeze = false
		_:
			_mesh.visible = false
			_decal.visible = true
			#self.freeze = true

func _on_sleep_changed() -> void:
	if _state == STATE_FLYING:
		if self.sleeping:
			_set_state(STATE_IDLE)
#	if _state == STATE_IDLE:
#		if self.sleeping:

func _physics_process(delta:float) -> void:
	if _state == STATE_FLYING:
		_velocity += Vector3(0, -20, 0) * delta
		self.global_position = self.global_position + (self._velocity * delta)

func launch(origin:Vector3, forward:Vector3) -> void:
	_set_state(STATE_FLYING)
	self.global_position = origin
	ZqfUtils.look_at_safe(self, origin + forward)
	self._velocity = -global_transform.basis.z * 5.0
