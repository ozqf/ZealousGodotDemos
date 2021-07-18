extends Spatial

export var respawns:bool = false
export var selfRespawnTime:float = 20

func _ready() -> void:
	$item_base.set_settings(self)
