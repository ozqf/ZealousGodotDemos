extends Spatial

const GROUP_NAME:String = "game"

func _ready() -> void:
	add_to_group(Console.GROUP)

func console_execute(txt:String, tokens) -> void:
	if txt == "reset":
		get_tree().call_group(GROUP_NAME, "game_reset")
