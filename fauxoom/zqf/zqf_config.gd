extends Node
class_name ZqfConfig

const GROUP:String = "config"
const GROUP_FN_CHANGE:String = "config_changed"

const ROOT_DIRECTORY:String = "user://cfg/"

var cfg:Dictionary = {
	r_fullscreen = true,
	r_fov = 80,
	i_sensitivity = 1,
	i_invertedY = false,
	s_sfx = 100,
	s_bgm = 60
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


################################
# saving/loading
################################

func _apply_loaded_dict(other:Dictionary) -> void:
	for key in other.keys:
		if !cfg.has(key):
			print("Unrecognised setting " + key)
			continue
		cfg[key] = other[key]

func broadcast_cfg_change() -> void:
	get_tree().call_group(GROUP, GROUP_FN_CHANGE, cfg)

func load_cfg(fileName:String) -> bool:
	var path = ROOT_DIRECTORY + fileName + ".json"
	print("Load cfg from " + path)
	var dict:Dictionary = ZqfUtils.load_dict_json_file(path)
	if !dict:
		print("Failed to read cfg")
		return false
	_apply_loaded_dict(dict)
	# cfg = dict
	print("Read cfg")
	broadcast_cfg_change()
	return true

func save_cfg(fileName:String) -> void:
	var path = ROOT_DIRECTORY + fileName + ".json"
	print("Writing cfg to " + path)
	ZqfUtils.make_dir(ROOT_DIRECTORY)
	var file = File.new()
	var err = file.open(path, File.WRITE)
	if err != 0:
		print("Err " + str(err) + " opening " + path)
		return
	file.store_string(to_json(cfg))
	file.close()
	print("Write done")