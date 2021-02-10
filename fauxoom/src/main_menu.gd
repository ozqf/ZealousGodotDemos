extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("game")
	var _f
	_f = $load_from_text/load_button.connect("pressed", self, "_on_load_text_pressed")
	_f = $save_to_text/save_button.connect("pressed", self, "_on_save_text_pressed")
	
	# save box cannot be written in, it is just for displaying and
	# copying base64 text
	$save_to_text/paste_box.readonly = true

func _on_load_text_pressed() -> void:
	var txt:String = $load_from_text/paste_box.text
	print("Menu - Load from " + str(txt.length()) + " chars")
	get_tree().call_group("game", "on_load_base64", txt)

func _on_save_text_pressed() -> void:
	print("Save map text")
	get_tree().call_group("game", "on_save_map_text")

func on_wrote_map_text(txt:String) -> void:
	$save_to_text/paste_box.text = txt

func on_read_map_text_success(_map, messages) -> void:
	print("Set load messages - success")
	$load_from_text/load_results.text = ZqfUtils.join_strings(messages, "\n")

func on_read_map_text_fail(messages) -> void:
	print("Set load messages - fail")
	$load_from_text/load_results.text = ZqfUtils.join_strings(messages, "\n")
