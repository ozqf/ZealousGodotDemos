extends VehicleBody3D

@onready var _fl:VehicleWheel3D = $fl
@onready var _fr:VehicleWheel3D = $fr
@onready var _rl:VehicleWheel3D = $rl
@onready var _rr:VehicleWheel3D = $rr

const ENGINE_FORCE:float = 4000

var _origin:Transform3D

# Called when the node enters the scene tree for the first time.
func _ready():
	_origin = global_transform
	pass
#	var slip:float = 1.0
#	_fl.wheel_friction_slip = slip
#	_fr.wheel_friction_slip = slip
#	_rl.wheel_friction_slip = slip
#	_rr.wheel_friction_slip = slip

func _check_slide() -> void:
	var frontSlip:float = 10
	var backSlip:float = 8
	if Input.is_action_pressed("slide"):
		frontSlip = 0.5
		backSlip = 0.2
	_fl.wheel_friction_slip = frontSlip
	_fr.wheel_friction_slip = frontSlip
	_rl.wheel_friction_slip = backSlip
	_rr.wheel_friction_slip = backSlip

func _physics_process(_delta):
	if Input.is_action_just_pressed("reset"):
		self.global_transform = _origin
	
	self.steering = Input.get_axis("move_right", "move_left") * 0.5
	
	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir.y == -1:
		self.engine_force = ENGINE_FORCE
#		_rl.engine_force = 20
#		_rr.engine_force = 20
		print(str(input_dir))
	elif input_dir.y == 1:
		self.engine_force = -ENGINE_FORCE
#		self.brake = 200
		print(str(input_dir))
	else:
		self.engine_force = 0.0
	
	
