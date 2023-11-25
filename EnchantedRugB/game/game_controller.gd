extends Node

const TEAM_ID_ENEMY:int = 0
const TEAM_ID_PLAYER:int = 1

# hit response > 0 is the damage caused
const HIT_RESPONSE_ABSORBED:int = 0
const HIT_RESPOSNE_IGNORED:int = -1

#@onready var _loadTimer:Timer = $load_timer
var _sandboxWorld = preload("res://worlds/sandbox/sandbox.tscn")

var _hitInfoType = preload("res://shared/structs/hit_info.gd")

func _ready():
#	_loadTimer.connect("timeout", _on_load_timeout)
#	_loadTimer.wait_time = 2.0
#	_loadTimer.one_shot = true
#	_loadTimer.start()
	call_deferred("_app_init")

func _on_load_timeout() -> void:
	_app_init()

func _app_init() -> void:
	var world = _sandboxWorld.instantiate()
	Zqf.get_world_root().add_child(world)
	var proxies = get_tree().get_nodes_in_group(Zqf.GROUP_NAME_ACTOR_PROXIES)
	for proxy in proxies:
		proxy.visible = false
		print("Found actor proxy: " + proxy.name)
		if proxy.has_method("spawn"):
			proxy.spawn()
	pass

func new_hit_info() -> HitInfo:
	return _hitInfoType.new()

func try_hit(attackInfo:HitInfo, victimHitbox) -> int:
	if !victimHitbox.has_method("hit"):
		return 0
	return victimHitbox.hit(attackInfo)

func add_actor_scene(actorType:PackedScene, t:Transform3D) -> Node3D:
	var obj:Node3D = actorType.instantiate() as Node3D
	Zqf.get_actor_root().add_child(obj)
	if obj.has_method("teleport"):
		obj.teleport(t)
	else:
		obj.global_transform = t
	return obj
