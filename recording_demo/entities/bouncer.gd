extends RigidBody2D


var _entity:Entity = null
# var _velocity:Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	_entity = $entity
	var v:Vector2 = Vector2()
	v.x = rand_range(-128, 128)
	v.y = rand_range(-128, 128)
	linear_velocity = v
	print("Set velocity: " + str(v))

func _process(_delta:float) -> void:
	pass
