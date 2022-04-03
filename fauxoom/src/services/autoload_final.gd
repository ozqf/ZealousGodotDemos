# This class should be the last auto loader item that can
# run final initialisation after the other autoloaders have
# run their ready() functions.
extends Node

func _ready() -> void:
	print("Autoload final")
	Config.broadcast_cfg_change()
