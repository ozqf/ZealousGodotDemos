extends Node

var _player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = get_parent()
	$VBoxContainer/reset.connect("pressed", self, "reset_to_defaults")
	var settings = settings()
	$VBoxContainer/maxPushSpeed.init(settings, "maxPushSpeed")

func settings() -> Dictionary:
	return _player.get_settings()

func runtime() -> Dictionary:
	return _player.get_runtime()

func reset_to_defaults() -> void:
	$VBoxContainer/maxPushSpeed.reset()
