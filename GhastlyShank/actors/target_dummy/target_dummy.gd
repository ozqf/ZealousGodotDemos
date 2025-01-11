extends Node

@onready var _model:HumanoidModel = $humanoid

var _tick = 1.0

func _ready() -> void:
	_model.play_idle()

func _physics_process(_delta:float) -> void:
	if !_model.is_performing_move():
		_tick -= _delta
		if _tick <= 0.0:
			_tick = randf_range(1.0, 3.0)
			var r:float = randf()
			if r > 0.6:
				_model.begin_move("uppercut_slow")
			elif r > 0.3:
				_model.begin_sweep(0.5)
			else:
				_model.begin_move("jab_slow")
	pass
