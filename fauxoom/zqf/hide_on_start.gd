extends Spatial

export var hideOnStart:bool = true

func _ready():
	visible = !hideOnStart
