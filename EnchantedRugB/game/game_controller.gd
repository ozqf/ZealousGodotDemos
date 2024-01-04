extends Node
class_name GameCtrl

const TEAM_ID_ENEMY:int = 0
const TEAM_ID_PLAYER:int = 1

const HIT_MASK_WORLD:int = (1 << 0)
const HIT_MASK_HITBOX:int = (1 << 1)
const HIT_MASK_PROJECTILE:int = (1 << 2)
const HIT_MASK_ACTOR_BODIES:int = (1 << 3)
const HIT_MASK_SCANNER:int = (1 << 4)
const HIT_MASK_GRAPPLE_POINT:int = (1 << 5)
const HIT_MASK_GRABBABLE:int = (1 << 6)

const GROUP_PLAYER_INTERNAL:String = "group_plyr_int"
const GROUP_PLAYER_STARTS:String = "group_plyr_start"

const AVATAR_EVENT_TYPE_DIED:String = "avatar_died"
const AVATAR_EVENT_TYPE_TELEPORT:String = "avatar_teleport"

# params; data:dictionary
const PLAYER_INTERNAL_FN_MELEE_ATTACK_STARTED:String = "plyr_int_melee_attack_started"

# hit response > 0 is the damage caused
const HIT_RESPONSE_ABSORBED:int = 0
const HIT_RESPOSNE_IGNORED:int = -1

const PLAYER_GRAPPLE_RANGE:float = 30.0

enum GameState { PreGame, Playing, PostGame, Dead }

enum MobState { Approaching, Swinging, StaticGuard, Parried, Staggered, Launched }
enum MoodAura { Idle, AttackWindup, AttackActive, Parried, Staggered }

#@onready var _loadTimer:Timer = $load_timer
var _sandboxWorld = preload("res://worlds/sandbox/sandbox.tscn")
var _hitInfoType = preload("res://shared/structs/hit_info.gd")
var _userType = preload("res://actors/player/user.tscn")

# gfx
var _popGfx = preload("res://gfx/mob_pop/mob_pop.tscn")
var _gfxRedSparksPop = preload("res://gfx/mob_pop/red_sparks_pop.tscn")
var _scorePlum = preload("res://gfx/score_plum/score_plum.tscn")
var _sparksHitGfx = preload("res://gfx/projectile_impact/projectile_impact_sparks.tscn")
var _gfxMeleeWhiffParticles = preload("res://gfx/melee_whiff/melee_whiff_particles.tscn")

@onready var _users:Node3D = $users
@onready var _pauseMenu:Control = $pause_menu

var _gameState:GameState = GameState.PreGame

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
	
	# create a new user
	spawn_user()

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
	_gameState = GameState.PreGame

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
	
	match _gameState:
		GameState.PreGame:
			if Input.is_action_just_pressed("attack_1"):
				var starts = get_tree().get_nodes_in_group(GROUP_PLAYER_STARTS)
				if starts.size() > 0:
					var n:Node3D = starts[0] as Node3D
					spawn_player(n.global_position, n.rotation_degrees.y)
					_gameState = GameState.Playing

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

func spawn_user() -> void:
	var user = _userType.instantiate()
	_users.add_child(user)

func spawn_player(_pos:Vector3, _yawDegrees:float = 0) -> void:
	if _users.get_child_count() == 0:
		print("No user to spawn avatars")
		return
	var user = _users.get_child(0)
	user.spawn(_pos, _yawDegrees)
	pass

func validate_target(tarInfo:ActorTargetInfo) -> bool:
	if _users.get_child_count() == 0:
		tarInfo.isValid = false
		return false
	return _users.get_child(0).write_target_info(tarInfo)

func user_died() -> void:
	pass

##############################################################
# GFX
##############################################################

func gfx_spawn_pop_sparks(pos:Vector3) -> void:
	var gfx = _popGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_position = pos

func gfx_spawn_impact_sparks(pos:Vector3) -> void:
	var gfx = _sparksHitGfx.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_position = pos

func gfx_spawn_red_sparks_pop(pos:Vector3) -> void:
	var gfx = _gfxRedSparksPop.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_position = pos

func gfx_spawn_melee_whiff_particles(pos:Vector3) -> void:
	var gfx = _gfxMeleeWhiffParticles.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.global_position = pos

func gfx_spawn_score_plug(pos:Vector3, msg:String) -> void:
	var gfx = _scorePlum.instantiate()
	Zqf.get_actor_root().add_child(gfx)
	gfx.get_node("Label3D").text = msg
	gfx.global_position = pos
