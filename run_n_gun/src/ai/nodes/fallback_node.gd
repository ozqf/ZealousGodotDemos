extends AINodeBase

func tick(info:AIInfo) -> int:
	for i in range(0, numChildren):
		print(name + " fallback node trying child " + str(i + 1) + " of " + str(numChildren))
		var result:int = children[i].tick(info)
		# if node failed, try next
		if result != FAILURE:
			if info.verbose:
				print(name + " picked fallback node child " + children[i].name + " " + str(i + 1) + " of " + str(numChildren))
			return result
	# no nodes are running or succeeded
	return FAILURE
