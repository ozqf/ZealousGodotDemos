extends Node3D
class_name GameMain

const GROUP_GLOBAL_EVENTS:String = "global_events"
# signature: (msg:String)
const FN_GLOBAL_EVENT:String = "global_event"

const GLOBAL_EVENT_END_OF_LEVEL:String = "end_of_level"

var _titleWorld:PackedScene = preload("res://worlds/title/title.tscn")
var _sandboxWorld:PackedScene = preload("res://worlds/sandbox/sandbox.tscn")

var _playerType:PackedScene = preload("res://actors/player_avatar/player_avatar.tscn")

var _prjColumn:PackedScene = preload("res://actors/prj_linear/prj_column.tscn")
var _prjCrescent:PackedScene = preload("res://actors/prj_linear/prj_crescent.tscn")
var _prjSphere:PackedScene = preload("res://actors/prj_linear/prj_sphere.tscn")

var _tracerType:PackedScene = preload("res://fx/tracer/gfx_tracer.tscn")
var _impactType:PackedScene = preload("res://fx/impacts/gfx_impact_bullet.tscn")
var _impactBulletWorld:PackedScene = preload("res://fx/impacts/gfx_impact_bullet_world.tscn")
var _mobDebrisExplosion:PackedScene = preload("res://fx/explosions/fx_debris_omni.tscn")

@onready var _gameRoot:Node3D = $game
@onready var _worldRoot:Node3D = $game/world
@onready var _actorsRoot:Node3D = $game/actors
@onready var _target:TargetInfo = $TargetInfo
@onready var _pause:Control = $pause_menu
@onready var _deadMenu:Control = $dead_menu

enum State
{
	Starting,
	Title,
	PreGame,
	Game,
	PostGame,
	Paused,
	Loading,
	PlayerDead
}

var _state:State = State.Starting

var _cursorClaim:Dictionary = {}
var _framesInState:int = 0
var _lastWorldPack:PackedScene = null

func _ready() -> void:
	print("Game start")
	_pause.visible = false

func get_actors_root() -> Node3D:
	return _actorsRoot

func add_cursor_claim(tag:String) -> void:
	if !_cursorClaim.has(tag):
		_cursorClaim[tag] = tag
		_refresh_mouse()

func remove_cursor_claim(tag:String) -> void:
	if _cursorClaim.has(tag):
		_cursorClaim.erase(tag)
		_refresh_mouse()

func _refresh_mouse() -> void:
	var numClaims:int = _cursorClaim.size()
	if numClaims > 0:
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_target() -> TargetInfo:
	return _target

func goto_title() -> void:
	if _state == State.Title:
		return
	unpause_game()
	_state = State.Title
	_load_world(_titleWorld)

func _physics_process(_delta: float) -> void:
	_target.ticksSinceRefresh += 1
	_framesInState += 1
	match _state:
		State.Starting:
			_state = State.Title
			_load_world(_titleWorld)
		State.PreGame:
			if Input.is_action_just_pressed("attack_2") && spawn_player():
				_state = State.Game
				#_spawn_mobs()
			pass
		State.Game:
			if Input.is_action_just_pressed("toggle_menu"):
				#_state = State.Paused
				pause_game()
	pass

func pause_game() -> void:
	if _state != State.Game:
		print("Cannot pause - not in game state")
		return
	_state = State.Paused
	add_cursor_claim("pause")
	_pause.visible = true
	get_tree().paused = true

func unpause_game() -> void:
	if _state != State.Paused:
		print("Cannot unpause - not paused")
		return
	_state = State.Game
	remove_cursor_claim("pause")
	_pause.visible = false
	get_tree().paused = false

func player_died() -> void:
	assert(_state == State.Game)
	_state = State.PlayerDead
	_pause.visible = false
	_deadMenu.show_menu()
	pass

func restart() -> void:
	assert(_lastWorldPack != null)
	_state = State.PreGame
	_load_world(_lastWorldPack)

func _clear_world() -> void:
	print("Clear world")
	for n in _worldRoot.get_children():
		n.queue_free()
	for n in _actorsRoot.get_children():
		n.queue_free()
	_delete_dynamic_actors()

func _delete_dynamic_actors() -> void:
	var nodes:Array[Node] = get_tree().get_nodes_in_group("temp")
	for n in nodes:
		n.queue_free()

func _load_world(packedScene:PackedScene) -> void:
	_clear_world()
	var world:Node3D = packedScene.instantiate() as Node3D
	_worldRoot.add_child(world)
	_lastWorldPack = packedScene
	print("World loaded")

func start_game() -> void:
	if _state != State.Title:
		return
	_delete_dynamic_actors()
	#self.get_tree().change_scene_to_packed(_sandboxWorld)
	_load_world(_sandboxWorld)
	_state = State.PreGame

func end_level() -> void:
	var grp:String = GROUP_GLOBAL_EVENTS
	var fn:String = FN_GLOBAL_EVENT
	get_tree().call_group(grp, fn, GLOBAL_EVENT_END_OF_LEVEL)
	_pause.visible = false
	_deadMenu.show_menu()
	

func exit_game() -> void:
	self.get_tree().quit()

#region spawning
func gfx_tracer() -> GFXTracer:
	var tracer:GFXTracer = _tracerType.instantiate() as GFXTracer
	_actorsRoot.add_child(tracer)
	return tracer

func gfx_impact_bullet(pos:Vector3) -> Node3D:
	var n:Node3D = _impactType.instantiate()
	_actorsRoot.add_child(n)
	n.global_position = pos
	return n

func gfx_impact_bullet_world(pos:Vector3) -> Node3D:
	var n:Node3D = _impactBulletWorld.instantiate()
	_actorsRoot.add_child(n)
	n.global_position = pos
	return n

func gfx_mob_debris(pos:Vector3) -> Node3D:
	var n:Node3D = _mobDebrisExplosion.instantiate()
	_actorsRoot.add_child(n)
	n.global_position = pos
	return n

func prj_column() -> PrjLinear:
	var n:PrjLinear = _prjColumn.instantiate() as PrjLinear
	assert(n != null)
	_actorsRoot.add_child(n)
	return n

func prj_crescent() -> PrjLinear:
	var n:PrjLinear = _prjCrescent.instantiate() as PrjLinear
	assert(n != null)
	_actorsRoot.add_child(n)
	return n

func prj_sphere() -> PrjLinear:
	var n:PrjLinear = _prjSphere.instantiate() as PrjLinear
	assert(n != null)
	_actorsRoot.add_child(n)
	return n

func spawn_player(newParent:Node3D = null) -> bool:
	var n:Node3D = self.get_tree().get_first_node_in_group("player_starts") as Node3D
	if n == null:
		return false
	if newParent == null:
		newParent = _actorsRoot
	var plyr = _playerType.instantiate() as Node3D
	newParent.add_child(plyr)
	plyr.global_position = n.global_position
	return true

#endregion
