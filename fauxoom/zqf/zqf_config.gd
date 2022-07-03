extends Node
class_name ZqfConfig

const GROUP:String = "config"
const GROUP_FN_CHANGE:String = "config_changed"

const ROOT_DIRECTORY:String = "user://cfg/"

export var cfgName:String = "fauxoom"

# public... I got lazy :/
var cfg:Dictionary = {
	r_fullscreen = true,
	r_fov = 90,
	r_fpsTarget = 120,
	r_vsync = true,
	r_hitDebris = false,
	r_bloodParticles = false,
	i_sensitivity = 1,
	i_invertedY = false,
	s_sfx = 80,
	s_bgm = 60,
	move_forward = 0,
	move_backward = 0,
	move_left = 0,
	move_right = 0,
	move_up = 0,
	move_down = 0,
	move_special = 0,
	attack_1 = 0,
	attack_2 = 0,
	attack_offhand = 0,
	interact = 0,
	hyper = 0,
	slot_1 = 0,
	slot_2 = 0,
	slot_3 = 0,
	slot_4 = 0,
	slot_5 = 0,
	slot_6 = 0,
	slot_7 = 0,
	slot_8 = 0
}

# buffer action to write a new config file to avoid writing instantly
# as cfg changes can be spammed out fast (eg volume sliders)
var _pendingFilePath:String = ""
var _saveTick:float = 0

func _ready():
	# broadcast change if file load failed, have to give everyone the default
	if !load_cfg(cfgName):
		broadcast_cfg_change()
	set_process(false)

func _process(_delta:float) -> void:
	_saveTick -= _delta
	if _saveTick <= 0:
		_write_cfg(_pendingFilePath)
		set_process(false)

################################
# saving/loading
################################

# variables being added/remove between versions make the dictionary's
# members brittle. So compare keys and don't just copy the other
# over the default as it may be missing keys.
func _apply_loaded_dict(other:Dictionary) -> void:
	for key in other.keys():
		if !cfg.has(key):
			print("Unrecognised setting " + key)
			continue
		cfg[key] = other[key]

func broadcast_cfg_change() -> void:
	get_tree().call_group(GROUP, GROUP_FN_CHANGE, cfg)
	save_cfg(cfgName)

func _write_cfg(fileName:String) -> void:
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

func load_cfg(fileName:String) -> bool:
	var path = ROOT_DIRECTORY + fileName + ".json"
	print("Load cfg from " + path)
	var dict:Dictionary = ZqfUtils.load_dict_json_file(path)
	if !dict:
		print("Failed to read cfg")
		return false
	_apply_loaded_dict(dict)
	broadcast_cfg_change()
	return true

func save_cfg(fileName:String) -> void:
	_pendingFilePath = fileName
	_saveTick = 1
	set_process(true)

	# var path = ROOT_DIRECTORY + fileName + ".json"
	# print("Writing cfg to " + path)
	# ZqfUtils.make_dir(ROOT_DIRECTORY)
	# var file = File.new()
	# var err = file.open(path, File.WRITE)
	# if err != 0:
	# 	print("Err " + str(err) + " opening " + path)
	# 	return
	# file.store_string(to_json(cfg))
	# file.close()
	# print("Write done")
