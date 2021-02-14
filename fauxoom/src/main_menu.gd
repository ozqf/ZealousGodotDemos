extends Node

onready var _loadInfo:RichTextLabel = $load_from_text/load_results
onready var _play:Button = $load_from_text/play_button
onready var _edit:Button = $load_from_text/edit_button

onready var _newMap:Button = $new_map/new_24x24
onready var _back:Button = $new_map/back

onready var _loadBox = $load_from_text/paste_box
onready var _saveBox = $save_to_text/paste_box

var _pendingMap:MapDef = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game")
	var _f
	_f = $load_from_text/load_button.connect("pressed", self, "_on_load_text_pressed")
	_f = $save_to_text/save_button.connect("pressed", self, "_on_save_text_pressed")
	_f = $load_from_text/copy_button.connect("pressed", self, "_on_copy_text_from_save")
	_f = _newMap.connect("pressed", self, "_on_new_map")
	_f = _back.connect("pressed", self, "_on_back")
	_f = _play.connect("pressed", self, "_on_play_pressed")
	_f = _edit.connect("pressed", self, "_on_edit_pressed")
	# save box cannot be written in, it is just for displaying and
	# copying base64 text
	$save_to_text/paste_box.readonly = true
	on_wrote_map_text(MapEncoder.map_to_b64(game.get_map()))

func _on_new_map() -> void:
	var map:MapDef = MapEncoder.empty_map(24, 24)
	map.set_all(1)
	game.set_pending_map(map)
	game.on_game_edit_level()

func _on_back() -> void:
	pass

func _on_copy_text_from_save() -> void:
	_loadBox.text = _saveBox.text

func _on_load_text_pressed() -> void:
	var txt:String = _loadBox.text
	if txt.length() == 0:
		_loadInfo.text = "You need to paste in some text to load from first!"
		return
	print("Menu - Load from " + str(txt.length()) + " chars")
	# get_tree().call_group("game", "on_load_base64", txt)
	var messages = []
	_pendingMap = MapEncoder.b64_to_map(txt, messages)
	_loadInfo.text = ZqfUtils.join_strings(messages, "\n")
	# load failed
	if _pendingMap == null:
		_play.disabled = true
		_edit.disabled = true
		return
	
	# print entities
	_loadInfo.text += "\n"
	for i in range(0, _pendingMap.spawns.size()):
		var spawn = _pendingMap.spawns[i]
		var p = spawn.position
		_loadInfo.text += (str(spawn.type) + ": " + str(p.x) + ", " + str(p.z)) + "\n"
	# load okay
	_play.disabled = false
	_edit.disabled = false

func _on_save_text_pressed() -> void:
	print("Save map text")
	# get_tree().call_group("game", "on_save_map_text")

	var def:MapDef = game.get_map()
	var b64:String = MapEncoder.map_to_b64(def)
	on_wrote_map_text(b64)

func _on_play_pressed() -> void:
	if _pendingMap == null:
		print("No pending map to play!")
		return
	print("Play")
	game.set_pending_map(_pendingMap)
	game.on_game_play_level()

func _on_edit_pressed() -> void:
	if _pendingMap == null:
		print("No pending map to edit!")
		return
	print("Edit")
	game.set_pending_map(_pendingMap)
	game.on_game_edit_level()

func on_wrote_map_text(txt:String) -> void:
	_saveBox.text = txt

func on_read_map_text_success(_map, messages) -> void:
	print("Set load messages - success")
	_loadInfo.text = ZqfUtils.join_strings(messages, "\n")
	_play.disabled = false
	_edit.disabled = false

func on_read_map_text_fail(messages) -> void:
	print("Set load messages - fail")
	_loadInfo.text = ZqfUtils.join_strings(messages, "\n")
	_play.disabled = true
	_edit.disabled = true
