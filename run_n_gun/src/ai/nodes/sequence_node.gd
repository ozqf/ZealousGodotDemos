extends AINodeBase

var index:int = -1

func tick(info:AIInfo) -> int:
	if numChildren <= 0:
		return SUCCESS
	if index == -1:
		# start
		print("Start sequence")
		index = 0
	elif index >= numChildren:
		# finished
		index = -1
		print("End  sequence")
		return SUCCESS
	
	var child:AINode = children[index]
	var result:int = child.tick(info)
	
	if result == SUCCESS:
		index += 1
		print("Advanced index to " + str(index))
		return SUCCESS
	elif result == RUNNING:
		return RUNNING
	else:
		# failed, abort sequence
		index = -1
		return FAILURE
