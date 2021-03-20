extends Area

var _bodies = []

func _ready() -> void:
	var _f1 = self.connect("body_entered", self, "on_body_entered")
	var _f2 = self.connect("body_exited", self, "on_body_exited")

func on_body_entered(_body:PhysicsBody) -> void:
	print("Body entered wind volume")
	_bodies.push_back(_body)

func on_body_exited(_body:PhysicsBody) -> void:
	print("Body exited wind volume")
	var _i:int = _bodies.find(_body)
	if _i == -1:
		return
	_bodies.remove(_i)

func _process(_delta:float) -> void:
	var forward:Vector3 = global_transform.basis.y
	forward = forward.normalized() * 80
	for _i in range(0, _bodies.size()):
		var body:Node = _bodies[_i]
		if body.has_method("touch_booster"):
			body.touch_booster(forward)
		elif body.has_method("add_impulse"):
			body.add_impulse(forward)
