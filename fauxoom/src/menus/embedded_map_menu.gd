extends Control

signal menu_navigate(name)

func _ready() -> void:
	var _f = $VBoxContainer/back.connect("pressed", self, "_on_back")
	_f = $VBoxContainer/test_arenas.connect("pressed", self, "_on_test_arenas")
	_f = $VBoxContainer/test_gameplay.connect("pressed", self, "_on_test_gameplay")
	_f = $VBoxContainer/test_entities.connect("pressed", self, "_on_test_entities")

func _on_test_gameplay() -> void:
	_on_back()
	# Main.submit_console_command("map test_gameplay")
	Main.submit_console_command("play catacombs_entity_Test")
#	var txt:String = "map test_gameplay"
#	var tokens = ZqfUtils.tokenise(txt)
#	get_tree().call_group(
#		Groups.CONSOLE_GROUP_NAME,
#		Groups.CONSOLE_FN_EXEC,
#		txt, tokens)
	pass

func _on_test_arenas() -> void:
	_on_back()
	# Main.submit_console_command("map test_arena")
	Main.submit_console_command("play test_arena")

func _on_test_entities() -> void:
	_on_back()
	Main.submit_console_command("map test_entities")

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func on() -> void:
	self.visible = true

func off() -> void:
	self.visible = false
