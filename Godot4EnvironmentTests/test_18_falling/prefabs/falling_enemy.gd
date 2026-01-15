extends CharacterBody3D

var _bulletType:PackedScene = preload("res://test_18_falling/prefabs/falling_bullet.tscn")

var _fireRate:float = 0.1
var _tick:float = 3.0

func _process(_delta:float) -> void:
	var plyrs = get_tree().get_nodes_in_group("player")
	if plyrs.size() > 0:
		var plyr:Node3D = plyrs[0] as Node3D
		if plyr != null:
			_chase(plyr.global_position, _delta)
			_tick -= _delta
			if _tick <= 0.0:
				_shoot(self.global_position.direction_to(plyr.global_position))
				_tick = _fireRate
			return
	_slow_and_stop(_delta)

func _slow_and_stop(_delta:float) -> void:
	self.velocity *= 0.8
	self.move_and_slide()

func _chase(target:Vector3, _delta:float) -> void:
	var pos:Vector3 = self.global_position
	var vel:Vector3 = self.velocity
	var toward:Vector3 = pos.direction_to(target)
	vel += toward * 10 * _delta
	vel = vel.limit_length(25)
	self.velocity = vel
	self.move_and_slide()

func _shoot(dir:Vector3) -> void:
	var bullet = _bulletType.instantiate()
	get_parent().add_child(bullet)
	bullet.launch(self.global_position, dir, 20.0)
	pass
