extends Node
class_name AINode

const SUCCESS:int = 1
const FAILURE:int = 0
const RUNNING:int = -1

func tick(info:AIInfo) -> int:
	return SUCCESS
