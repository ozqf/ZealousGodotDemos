extends Node

const TEAM_ID_ENEMY:int = 0
const TEAM_ID_PLAYER:int = 1

const GROUP_PLAYER_INTERNAL:String = "group_plyr_int"
# params; data:dictionary
const PLAYER_INTERNAL_FN_MELEE_ATTACK_STARTED:String = "plyr_int_melee_attack_started"

# hit response > 0 is the damage caused
const HIT_RESPONSE_ABSORBED:int = 0
const HIT_RESPOSNE_IGNORED:int = -1

#@onready var _loadTimer:Timer = $load_timer
var _sandboxWorld = preload("res://worlds/sandbox/sandbox.tscn")
var _hitInfoType = preload("res://shared/structs/hit_info.gd")
var _userType = preload("res://actors/player/user.tscn")

# gfx
var _popGfx = preload("res://gfx/mob_pop/mob_pop.tscn")
var _sparksHitGfx = preload("res://gfx/projectile_impact/projectile_impact_sparks.tscn")

@onready var _users:Node3D = $users
@onready var _pauseMenu:Control = $pause_menu

func _ready():
#	_loadTimer.connect("timeout", _on_load_timeout)
#	_loadTimer.wait_time = 2.0
#	_loadTimer.one_shot = true
#	_loadTimer.start()
	call_deferred("_app_init")
	_pauseMenu.visible = false

func _on_load_timeout() -> void:
	_app_init()

func restart() -> void:
	start_world("sandbox")
	pass

func _clear_world() -> void:
	for child in Zqf.get_world_root().get_children():
		child.free()
	pass

func _clear_dynamic_actors() -> void:
	for child in Zqf.get_actor_root().get_children():
		child.free()
	pass

func _clear_users() -> void:
	for user in _users.get_children():
		user.free()
	pass

# func load_world(worldName:String) -> void:
# 	pass

func start_world(worldName:String) -> void:
	_clear_dynamic_actors()
	_clear_world()
	_clear_users()
	
	var worldType
	match worldName:
		"sandbox":
			worldType = _sandboxWorld
		_:
			worldType = _sandboxWorld
	
	var world = worldType.instantiate()
	Zqf.get_world_root().add_child(world)
	
	var proxies = get_tree().get_nodes_in_group(Zqf.GROUP_NAME_ACTOR_PROXIES)
	for proxy in proxies:
		proxy.visible = false
		print("Found actor proxy: " + proxy.name)
		if proxy.has_method("spawn"):
			proxy.spawn()

func _app_init() -> void:
	start_world("sandbox")
	pass

func _process(_delta):
	if Input.is_action_just_pressed("toggle_console"):
		var isPlaying:bool = Zqf.get_player_input_on()
		if isPlaying:
			Zqf.set_player_input_on(false)
			_pauseMenu.visible = true
		else:
			Zqf.set_player_input_on(true)
			_pauseMenu.visible = false
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

func spawn_player(_pos:Vector3, _yawDegrees:float = 0) -> void:
	if _users.get_child_count() > 0:
		print("Already have a player")
		return
	var user = _userType.instantiate()
	_users.add_child(user)
	user.spawn(_pos, _yawDegrees)
	pass

func gfx_spawn_pop_sparks(pos:Vector3) -> void:
	var gfx = _popGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_position = pos

func gfx_spawn_impact_sparks(pos:Vector3) -> void:
	var gfx = _sparksHitGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_position = pos
