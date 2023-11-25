extends Node3D
class_name MeleePods

@onready var _animator:AnimationPlayer = $AnimationPlayer
@onready var _rightPod:MeleePod = $right_pod/melee_pod
@onready var _leftPod:MeleePod = $left_pod/melee_pod

func _ready():
	pass

func _process(delta):
	pass

func update_yaw(_degrees:float) -> void:
	pass
