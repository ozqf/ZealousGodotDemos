extends Control

signal menu_navigate(name)

onready var _filesList = $ItemList/VBoxContainer
onready var _description:Label = $map_description

var _selectedFileName:String = ""

func _ready():
	$actions_container/play.connect("pressed", self, "_on_click_play")
	$actions_container/edit.connect("pressed", self, "_on_click_edit")
	$actions_container/back.connect("pressed", self, "_on_click_back")

func _refresh() -> void:
	var userRoot:String = Main.get_entities_directory(true)
	var userFiles = ZqfUtils.get_files_in_directory(userRoot, ".json")
	print("-- Custom maps found in " + str(userRoot) + " --")
	for file in userFiles:
		file = file.split(".")[0]
		print("\t" + str(file))
		var b = Button.new()
		b.name = file
		b.text = file
		_filesList.add_child(b)
		b.connect("pressed", self, "_on_click_file", [b])

func _set_selected_file_name(fileName:String) -> void:
	if fileName == null || fileName == "":
		_selectedFileName = ""
		_description.text = "No file selected."
	_selectedFileName = fileName
	_description.text = _selectedFileName

func on() -> void:
	_refresh()
	visible = true

func off() -> void:
	visible = false

func _on_click_file(button) -> void:
	# print("Pressed " + str(button.text))
	_set_selected_file_name(button.text)

func _on_click_play() -> void:
	if _selectedFileName == "":
		return
	
	off()
	Main.submit_console_command("play " + _selectedFileName)
	self.emit_signal("menu_navigate", "back")

func _on_click_edit() -> void:
	off()
	Main.submit_console_command("edit " + _selectedFileName)
	self.emit_signal("menu_navigate", "back")

func _on_click_back() -> void:
	off()
	self.emit_signal("menu_navigate", "back")
