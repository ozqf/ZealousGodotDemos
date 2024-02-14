extends Area3D
class_name HitBox

const HITBOX_EVENT_DAMAGED:String = "damaged"
const HITBOX_EVENT_GUARD_DAMAGED:String = "guard_damaged"
const HITBOX_EVENT_EVADED:String = "evade"

signal health_depleted
signal hitbox_event(eventType, hitbox)

enum HitboxGFXType { Enemy, Player }

@export var teamId:int = 0
@export var initialHealth:int = 500
@export var gfxType:HitboxGFXType = HitboxGFXType.Enemy

var evadeTick:float = 0.0
var guardStrength:float = 30
var isGuarding:bool = false
var attackActive:bool = false

var lastHit:HitInfo = null

var _health:float = 50
var _dead:bool = false;

func _ready() -> void:
	_health = initialHealth

func get_health_percentage() -> float:
	return (_health / initialHealth) * 100

func _die() -> void:
	_dead = true
	self.emit_signal("health_depleted")

func receive_grab(grabber) -> Node3D:
	var p:Node = get_parent()
	if p.has_method("receive_grab"):
		return p.receive_grab(grabber)
	return null

func _physics_process(delta) -> void:
	if evadeTick > 0:
		evadeTick -= delta

func hit(hitInfo:HitInfo) -> int:
	if _dead:
		return Game.HIT_RESPONSE_IGNORED
	if (hitInfo.teamId == teamId):
		return Game.HIT_RESPONSE_IGNORED
	if evadeTick > 0:
		print("Evaded!")
		Game.gfx_spawn_score_plug(self.global_position, "EVADE!")
		self.emit_signal("hitbox_event", HITBOX_EVENT_EVADED, self)
		return Game.HIT_RESPONSE_EVADED
	if isGuarding:
		if hitInfo.teamId == Game.TEAM_ID_ENEMY:
			print("Guard whiff")
		self.emit_signal("hitbox_event", HITBOX_EVENT_GUARD_DAMAGED, self)
		Game.gfx_spawn_melee_whiff_particles(hitInfo.hitPosition)
		return Game.HIT_RESPONSE_PARRIED
	
	_health -= hitInfo.damage
	hitInfo.lastInflicted = hitInfo.damage
	lastHit = hitInfo

	if hitInfo.teamId == Game.TEAM_ID_ENEMY:
		print("hit for " + str(hitInfo.damage) + " hp " + str(_health))
	if _health <= 0:
		_die()
		return hitInfo.damage
	else:
		match gfxType:
			HitboxGFXType.Enemy:
				Game.gfx_spawn_impact_sparks(hitInfo.hitPosition)
			HitboxGFXType.Player:
				Game.gfx_spawn_red_sparks_pop(self.global_position)
		# no guard == parried
		self.emit_signal("hitbox_event", HITBOX_EVENT_DAMAGED, self)
	
	# if we are not guarding but our attack isn't active, parry the attacker as well
	if !attackActive:
		return Game.HIT_RESPONSE_PARRIED

	return hitInfo.damage
