extends Label

@onready var _plyr:Node3D = $player
@onready var _mobA:Node3D = $mob_a
@onready var _mobB:Node3D = $mob_b

func calc() -> void:
	var plyrPos:Vector3 = _plyr.global_position
	var plyrDir:Vector3 = _plyr.global_transform.basis.x
	var towardA:Vector3 = plyrPos.direction_to(_mobA.global_position).normalized()
	var towardB:Vector3 = plyrPos.direction_to(_mobB.global_position).normalized()
	var dpA:float = plyrDir.dot(towardA)
	var dpB:float = plyrDir.dot(towardB)
	var txt:String = "Dot A: " + str(dpA) + " Dot B: " + str(dpB)
	print(txt)
	self.text = txt
	pass

func _process(_delta:float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		calc()
