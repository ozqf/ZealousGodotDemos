extends Control

signal menu_navigate(name)

func _ready() -> void:
	var _f = $VBoxContainer/back.connect("pressed", self, "_on_back")
	_f = $VBoxContainer/test_gameplay.connect("pressed", self, "_on_test_gameplay")

func _on_test_gameplay() -> void:
	print("Test gameplay")
	var txt:String = "map test_gameplay"
	var tokens = ZqfUtils.tokenise(txt)
	get_tree().call_group(
		Groups.CONSOLE_GROUP_NAME,
		Groups.CONSOLE_FN_EXEC,
		txt, tokens)
	pass

func _on_back() -> void:
	self.emit_signal("menu_navigate", "back")

func on() -> void:
	self.visible = true

func off() -> void:
	self.visible = false
