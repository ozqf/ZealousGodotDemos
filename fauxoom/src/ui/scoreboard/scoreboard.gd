extends Node

onready var _headings = $headings
onready var _test = $test

func _ready() -> void:
	_test.scoreboard_item_init("Bolt Vanderhuge", 19, 1295)
