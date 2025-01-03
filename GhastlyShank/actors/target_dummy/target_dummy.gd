extends Node

@onready var _model:PlayerModel = $player_model

func _ready() -> void:
	_model.play_idle()

func _physics_process(_delta:float) -> void:
	
	var tar:ActorTargetInfo = Game.get_player_target()
	if tar.isValid == false:
		return
	
	if !_model.is_performing_move():
		_model.look_at(tar.t.origin)
		_model.begin_horizontal_swing()
