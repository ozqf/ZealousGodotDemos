extends AINodeBase

func tick(info:AIInfo) -> int:
	var result:int = call_first_child(info)
	if result == FAILURE:
		return SUCCESS
	elif result == SUCCESS:
		return FAILURE
	return RUNNING
