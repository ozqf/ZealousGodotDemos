extends Area3D
class_name HitBox



signal health_depleted
signal hitbox_event

@export var teamId:int = 0 
@export var initialHealth:int = 50



var _health:int = 50
var _dead:bool = false;

func _ready() -> void:
	_health = initialHealth

func _die() -> void:
	_dead = true
	self.emit_signal("health_depleted")

func receive_grab(grabber) -> Node3D:
	var p:Node = get_parent()
	if p.has_method("receive_grab"):
		return p.receive_grab(grabber)
	return null

func hit(hitInfo:HitInfo) -> int:
	if _dead:
		return -1
	if (hitInfo.teamId == teamId):
		return -1
	_health -= hitInfo.damage
	print("hit for " + str(hitInfo.damage) + " hp " + str(_health))
	if _health <= 0:
		_die()
		return hitInfo.damage
	else:
		Game.gfx_spawn_impact_sparks(hitInfo.hitPosition)
	return hitInfo.damage
