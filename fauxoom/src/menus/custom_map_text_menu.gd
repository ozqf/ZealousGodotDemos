extends Control

signal menu_navigate(name)

@onready var _loadInfo:RichTextLabel = $load_from_text/load_results
@onready var _play:Button = $load_from_text/play_button
@onready var _edit:Button = $load_from_text/edit_button

@onready var _loadFromText:Button = $load_from_text/load_button
@onready var _saveToText:Button = $save_to_text/save_button
@onready var _copyFromSave:Button = $load_from_text/copy_button
@onready var _toClipboard:Button = $load_from_text/to_clipboard
@onready var _toData:Button = $load_from_text/to_data

# new map UI nodes
@onready var _newMap:Button = $new_map/create_new
@onready var _newMapWidth:HSlider = $new_map/set_width/width_slider
@onready var _newMapHeight:HSlider = $new_map/set_height/height_slider
@onready var _back:Button = $new_map/back

@onready var _loadBox = $load_from_text/paste_box
@onready var _saveBox = $save_to_text/paste_box

var _pendingMap:MapDef = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.GAME_GROUP_NAME)
	var _f
	_f = _loadFromText.connect("pressed", self, "_on_load_text_pressed")
	_f = _saveToText.connect("pressed", self, "_on_save_text_pressed")
	_f = _copyFromSave.connect("pressed", self, "_on_copy_text_from_save")
	_f = _toClipboard.connect("pressed", self, "_on_map_to_clipboard")
	_f = _toData.connect("pressed", self, "_on_map_to_data")

	_f = _play.connect("pressed", self, "_on_play_pressed")
	_f = _edit.connect("pressed", self, "_on_edit_pressed")

	_f = _newMap.connect("pressed", self, "_on_new_map")
	_f = _back.connect("pressed", self, "_on_back")
	# save box cannot be written in, it is just for displaying and
	# copying base64 text
	$save_to_text/paste_box.readonly = true
	game_on_wrote_map_text(MapEncoder.map_to_b64(Main.get_map()))

func _process(_delta:float) -> void:
	var newW:int = int(_newMapWidth.value)
	var newH:int = int(_newMapHeight.value)
	_newMap.text = "NEW MAP - " + str(newW) + "x" + str(newH)

func on() -> void:
	visible = true
	_on_save_text_pressed()
	_on_copy_text_from_save()
	_on_load_text_pressed()

func off() -> void:
	visible = false

func _on_new_map() -> void:
	var map:MapDef = MapEncoder.empty_map(int(_newMapWidth.value), int(_newMapHeight.value))
	map.set_all(1)
	Main.set_pending_map(map)
	Main.on_game_edit_level()

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func _on_map_to_data() -> void:
	print("Save to data")
	var file:File = File.new()
	var path:String = "user://b64_map.txt"
	print("Writing " + str(_loadBox.text.length()) + " chars to " + path)
	var err = file.open(path, File.WRITE)
	if err != OK:
		print("Saving map to " + path + " failed with code " + str(err))
		return
	file.store_string(_loadBox.text)
	file.close()

func _on_map_to_clipboard() -> void:
	if OS.has_feature("JavaScript"):
		# save to local storage
		_on_map_to_data()
		# invoke js
		print("Calling JS")
		JavaScript.eval("copyToClipboard();")
		# eval with custom string is too unsafe
		# JavaScript.eval(cmd)
	else:
		print("No JS for clipboard copy")

func _on_copy_text_from_save() -> void:
	_loadBox.text = _saveBox.text

func _on_load_text_pressed() -> void:
	var txt:String = _loadBox.text
	if txt.length() == 0:
		_loadInfo.text = "You need to paste in some text to load from first!"
		return
	print("Menu - Load from " + str(txt.length()) + " chars")
	# get_tree().call_group(Groups.GAME_GROUP_NAME, "game_on_load_base64", txt)
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
	# get_tree().call_group(Groups.GAME_GROUP_NAME, "game_on_save_map_text")

	var def:MapDef = Main.get_map()
	var b64:String = MapEncoder.map_to_b64(def)
	game_on_wrote_map_text(b64)

func _on_play_pressed() -> void:
	if _pendingMap == null:
		print("No pending map to play!")
		return
	print("Play")
	Main.set_pending_map(_pendingMap)
	Main.on_game_play_level()

func _on_edit_pressed() -> void:
	if _pendingMap == null:
		print("No pending map to edit!")
		return
	print("Edit")
	Main.set_pending_map(_pendingMap)
	Main.on_game_edit_level()

func game_on_wrote_map_text(txt:String) -> void:
	_saveBox.text = txt

func game_on_read_map_text_success(_map, messages) -> void:
	print("Set load messages - success")
	_loadInfo.text = ZqfUtils.join_strings(messages, "\n")
	_play.disabled = false
	_edit.disabled = false

func game_on_read_map_text_fail(messages) -> void:
	print("Set load messages - fail")
	_loadInfo.text = ZqfUtils.join_strings(messages, "\n")
	_play.disabled = true
	_edit.disabled = true
