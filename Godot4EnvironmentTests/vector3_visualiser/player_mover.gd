extends Node3D


func _process(_delta) -> void:
	var moveAxis:float = Input.get_axis("ui_down", "ui_up")
	var turnAxis:float = Input.get_axis("ui_left", "ui_right")
	if turnAxis < 0:
		self.rotate(Vector3.UP, PI * _delta)
	elif turnAxis > 0:
		self.rotate(Vector3.UP, -(PI * _delta))
	
	var forward:Vector3 = -self.global_transform.basis.z
	
	var move:Vector3 = (forward * moveAxis * 3)
	self.global_position += move * _delta
	
	#print("axis " + str(moveAxis) + " forward " + str(forward) + " move " + str(move))
