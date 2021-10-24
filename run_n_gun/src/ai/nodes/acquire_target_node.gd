extends AINodeBase

func tick(info:AIInfo) -> int:
	var target:Actor = Game.get_player()
	if target == null:
		if info.verbose:
			print(name + " target is null")
		return FAILURE
	info.targetPosition = target.global_position
	if info.verbose:
		print(name + " got target " + str(target.name) + " at pos " + str(info.targetPosition))
	return call_first_child(info)
