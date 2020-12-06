extends Node2D
class_name Game

const LAYER_WORLD = 1
const LAYER_PLAYER = 2
const LAYER_ENEMY = 4
const LAYER_ITEM = 8
const LAYER_PROJECTILE = 16
const LAYER_SWITCH = 32
const LAYER_SENSOR = 64
const LAYER_TRIGGER = 128
const LAYER_WORLD_SLIPPY = 256
const LAYER_FENCE = 512
const LAYER_FENCE_SLIPPY = 1024

const TEAM_ENEMY = 0
const TEAM_PLAYER = 1

onready var _debugLabel:Label = $menu_game/debug

func set_debug_text(text:String):
	_debugLabel.text = text

func on_player_start(_player):
	pass

func on_player_finish(_player):
	pass

func _process(_delta):
#	if Input.is_action_just_pressed("ui_cancel"):
#		var _result = get_tree().reload_current_scene()
	pass
