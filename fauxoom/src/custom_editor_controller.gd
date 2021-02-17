extends Node

onready var _ed:FlatMapEditor = $flat_map_editor
var _mapDef:MapDef = null;

var _templates = [
	{
		"typeId": MapDef.ENT_TYPE_MOB_GRUNT,
		"label": "Mob: Grunt",
		"body": "actor"
	},
	{
		"typeId": MapDef.ENT_TYPE_START,
		"label": "PlayerStart",
		"body": "actor"
	},
	{
		"typeId": MapDef.ENT_TYPE_END,
		"label": "End"
	},
	{
		"typeId": MapDef.ENT_TYPE_KEY,
		"label": "Key"
	},
]

func _ready() -> void:
	add_to_group("game")
	# _mapDef = AsciMapLoader.build_test_map()
	# _mapDef = MapEncoder.empty_map(DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)
	# _mapDef.set_all(1)
	_mapDef = game.get_map()
	_ed.init(_mapDef, _templates)

func game_on_load_base64(b64:String) -> void:
	print("Custom editor load from " + str(b64.length()) + " base64 chars")
	#var bytes:PoolByteArray = Marshalls.base64_to_raw(b64)
	# print("Editor reading " + str(bytes.size()) + " bytes")

	var messages = []
	var newMapDef:MapDef = MapEncoder.b64_to_map(b64, messages)
	print("Results: " + ZqfUtils.join_strings(messages, "\n"))
	print("Call game group on_read_map_text")
	if newMapDef != null:
		get_tree().call_group("game", "game_on_read_map_text_success", newMapDef, messages)
	else:
		get_tree().call_group("game", "game_on_read_map_text_fail", messages)

func game_on_save_map_text() -> void:
	# var b64 = AsciMapLoader.str_to_b64(_mapText)
	var b64:String = MapEncoder.map_to_b64(_mapDef)
	get_tree().call_group("game", "game_on_wrote_map_text", b64)
