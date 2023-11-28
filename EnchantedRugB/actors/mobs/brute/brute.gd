extends CharacterBody3D

var _popGfx = preload("res://gfx/mob_pop/mob_pop.tscn")

#@onready var _hitBox:HitBox = $hitbox

func _ready():
	#_hitBox.connect("health_depleted", _on_health_depleted)
	#_hitBox.teamId = Game.TEAM_ID_ENEMY
	pass

func _on_health_depleted() -> void:
	var gfx = _popGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_transform = self.global_transform

func hit(_hitInfo:HitInfo) -> int:
	print("Brute - took hit")
	Game.gfx_spawn_impact_sparks(_hitInfo.hitPosition)
	return 1
