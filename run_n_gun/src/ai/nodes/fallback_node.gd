extends AINodeBase

func tick(info:AIInfo) -> int:
	for i in range(0, numChildren):
		var result:int = children[i].tick(info)
		# if node failed, try next
		if result != FAILURE:
			return result
	# no nodes are running or succeeded
	return FAILURE
