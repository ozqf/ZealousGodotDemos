extends AnimatedSprite3D

export var playOnReady:bool = true
export var hideOnLoop:bool = false

var _hasPlayed:bool = false

func _ready() -> void:
	if playOnReady:
		play()

func _process(_delta:float) -> void:
	if hideOnLoop:
		if _hasPlayed:
			if frame == 0:
				hide()
		else:
			if frame != 0:
				_hasPlayed = true

