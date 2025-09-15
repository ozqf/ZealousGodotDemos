extends Node3D

func _physics_process(_delta:float) -> void:
	var plyr:Node3D = get_tree().get_first_node_in_group("player") as Node3D
	if plyr == null:
		return
	
	var p:Vector3 = self.global_position
	p.x = plyr.global_position.x
	self.global_position = p
