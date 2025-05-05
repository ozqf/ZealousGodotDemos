extends Node3D

@onready var _woundedParticles = $wounded_spurt
var _sprite:AnimatedSprite3D = null

var _mob

func _ready() -> void:
	_mob = get_parent()
	_sprite = get_parent().get_node("sprite")

func _process(_delta:float) -> void:
	var maxHp:int = _mob.get_health_max()
	var hp:int = _mob.get_health()
	if maxHp > Interactions.DAMAGE_SUPER_PUNCH:
		if hp < Interactions.DAMAGE_SUPER_PUNCH:
			_woundedParticles.emitting = true
	
	if _mob.get_orb_count() > 0:
		# cal a value moving between 0 and 1
		var time:float = float(OS.get_ticks_msec()) / 1000.0
		var step:float = time - int(time)
		step = cos((PI * 2) * step)
		step = (step + 1.0) / 2.0
		_sprite.modulate = Color(step, step, 1)
	else:
		_sprite.modulate = Color(1, 1, 1)
