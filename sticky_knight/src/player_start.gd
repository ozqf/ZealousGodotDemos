extends Node2D

var _player_prefab = preload("res://prefabs/player.tscn")
onready var _gui:Control = $CanvasLayer/gui

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		var player = _player_prefab.instance()
		player.position = position
		var parent = get_tree().get_current_scene()
		parent.add_child(player)
		_gui.hide()
		set_process(false)
