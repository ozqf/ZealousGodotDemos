extends Particles

export var on:bool = true
export var repeatTime:float = 0.0
var _tick:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta:float) -> void:
	_tick -= _delta
	if !on:
		return
	if _tick <= 0.0:
		self.emitting = true
		_tick = repeatTime
		if repeatTime <= 0.0:
			on = false
