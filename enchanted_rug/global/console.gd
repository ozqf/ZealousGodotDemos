extends Node

const GROUP:String = "console"
const EXEC_FN:String = "console_execute"

func _ready() -> void:
	add_to_group(GROUP)

func execute(txt:String) -> void:
	var tokens = ZqfUtils.tokenise(txt)
	if tokens.size() == 0:
		return
	get_tree().call_group(GROUP, EXEC_FN, txt, tokens)

func console_execute(txt:String, tokens) -> void:
	print("EXEC " + txt + ": " + str(tokens))
