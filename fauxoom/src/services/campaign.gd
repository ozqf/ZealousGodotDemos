extends Node

const ROOT_DIRECTORY:String = "user://campaign/"
const FILE_NAME:String = "campaign"

var _campaign:Dictionary = {
	version = 1,
	completions = [],
	stats = {
		playTime = 0
	}
}

func _get_path() -> String:
	return ROOT_DIRECTORY + FILE_NAME + ".json"

func _ready():
	var path:String = _get_path()
	var dict:Dictionary = ZqfUtils.load_dict_json_file(path)
	if !dict:
		print("Failed to read campaign from " + path)
		return

func _write() -> void:
	ZqfUtils.write_dict_json_file(ROOT_DIRECTORY, FILE_NAME + ".json", _campaign)
