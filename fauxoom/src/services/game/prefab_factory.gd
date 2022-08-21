extends Node
class_name PrefabFactory

##############################
# def objects
var _def_t = preload("res://src/defs/spawn_def.gd")

###########################
# scene objects
var _player_t = preload("res://prefabs/player.tscn")
var _gib_t = preload("res://prefabs/gib.tscn")
var _head_gib_t = preload("res://prefabs/player_gib.tscn")

var _hitInfo_type = preload("res://src/defs/hit_info.gd")
var _tagSet_t = preload("res://src/defs/ent_tag_set.gd")
var _mobHealthInfo_t = preload("res://src/defs/mob_health_info.gd")
var _corpse_spawn_info_t = preload("res://src/defs/corpse_spawn_info.gd")

var _rage_drop_t = preload("res://prefabs/dynamic_entities/rage_drop.tscn")

var prefab_impact_debris_t = preload("res://prefabs/gfx/bullet_hit_debris.tscn")
var prefab_blood_debris_t = preload("res://prefabs/gfx/blood_hit_debris.tscn")
var prefab_explosion_sprite_t = preload("res://prefabs/gfx/gfx_explosion.tscn")

var prefab_impact = preload("res://prefabs/bullet_impact.tscn")
var prefab_blood_hit = preload("res://prefabs/blood_hit_sprite.tscn")

var _prefab_blood_spurt = preload("res://prefabs/gfx/gfx_blood_spurt.tscn")

var _trail_t = preload("res://prefabs/gfx/gfx_rail_trail.tscn")
var _prefab_ground_target_t = preload("res://prefabs/gfx/ground_target_marker.tscn")
var prefab_shockwave_t = preload("res://prefabs/gfx/gfx_shockwave.tscn")

var _prefab_ejected_bullet = preload("res://prefabs/gfx/ejected_bullet.tscn")
var _prefab_ejected_shell = preload("res://prefabs/gfx/ejected_shell.tscn")

var prj_point_t = preload("res://prefabs/projectiles/prj_point.tscn")
var prj_golem_t = preload("res://prefabs/projectiles/prj_golem.tscn")
var prj_spike_t = preload("res://prefabs/projectiles/prj_ground_spike.tscn")
var prj_column_t = preload("res://prefabs/projectiles/prj_column.tscn")
var flame_t = preload("res://prefabs/projectiles/prj_flame.tscn")
var hyper_aoe_t = preload("res://prefabs/hyper_aoe.tscn")

var stake_t = preload("res://prefabs/projectiles/prj_player_stake.tscn")
var flare_t = preload("res://prefabs/projectiles/prj_player_flare.tscn")
var trail_t = preload("res://prefabs/gfx/gfx_rail_trail.tscn")
var rocket_t = preload("res://prefabs/projectiles/prj_player_rocket.tscn")
var statis_grenade_t = preload("res://prefabs/projectiles/prj_stasis_grenade.tscn")

var point_t = preload("res://prefabs/point_gizmo.tscn")

var punk_corpse_t = preload("res://prefabs/corpses/punk_corpse.tscn")
var _generic_corpse_t = preload("res://prefabs/corpses/generic_corpse.tscn")

# when saw blade is launched, input handling is passed onto the projectile
# the projectile is recycled, if we don't have one, create one and reuse it
var prj_player_saw_t = preload("res://prefabs/projectiles/prj_player_saw.tscn")

############################################

var _dynamicRoot:Spatial = null
var _entRoot:Spatial = null

func prefab_factory_init(dynamicRoot:Spatial, entRoot:Spatial) -> void:
	_dynamicRoot = dynamicRoot
	_entRoot = entRoot

func get_dynamic_parent():
	if _dynamicRoot != null:
		return _dynamicRoot
	return _entRoot

##############################
# new def objects
##############################

func new_spawn_def() -> SpawnDef:
	return _def_t.new()

##############################
# spawn entities/scene objects
##############################

func spawn_mob(def:SpawnDef) -> Object:
	var mob = Ents.create_mob_by_name(def.type, def.t, def.forceAwake)
	return mob

func spawn_corpse(spawnerPrefabType:String, info:CorpseSpawnInfo, t:Transform) -> void:
	var prefab = null
	var offsetY:int = 32
	var pixelSize:float = 0.03
	if spawnerPrefabType == "mob_punk":
		prefab = self.punk_corpse_t.instance()
		get_dynamic_parent().add_child(prefab)
		prefab.spawn(info, t)
		return
	elif spawnerPrefabType == "mob_worm":
		prefab = _generic_corpse_t.instance()
	elif spawnerPrefabType == "mob_cyclops":
		prefab = _generic_corpse_t.instance()
		prefab.animationSet = "cyclops"
	elif spawnerPrefabType == "mob_spider":
		prefab = _generic_corpse_t.instance()
		prefab.animationSet = "mob_spider"
	elif spawnerPrefabType == "mob_golem":
		prefab = _generic_corpse_t.instance()
		prefab.animationSet = "mob_golem"
		offsetY = 48
		pixelSize = 0.04
	elif spawnerPrefabType == "mob_serpent":
		prefab = _generic_corpse_t.instance()
		prefab.animationSet = "serpent"
	elif spawnerPrefabType == "mob_titan":
		prefab = _generic_corpse_t.instance()
		prefab.animationSet = "mob_titan"
		pixelSize = 0.04
		offsetY = 64
	if prefab == null:
		return
	get_dynamic_parent().add_child(prefab)
	prefab.set_sprite_offset(0, offsetY)
	prefab.set_sprite_pixel_size(pixelSize)
	prefab.spawn(info, t)

func spawn_rage_drops(pos:Vector3, dropType:int, dropCount:int, throwYawDegrees:float = -1.0,  autoGather:bool = false) -> void:
	var prefab = _rage_drop_t
	for _i in range(0, dropCount):
		var drop:RigidBody = prefab.instance()
		add_child(drop)
		drop.launch_rage_drop(pos, dropType, throwYawDegrees, autoGather)

# returns last gib spawned
func spawn_gibs(origin:Vector3, dir:Vector3, count:int) -> Spatial:
	var def = _entRoot.get_prefab_def(Entities.PREFAB_GIB)
	var result = null;
	for _i in range(0, count):
		var gib = def.prefab.instance()
		result = gib
		add_child(gib)
		var pos:Vector3 = origin
		pos.x += rand_range(-0.5, 0.5)
		pos.y += rand_range(0, 1.5)
		pos.z += rand_range(-0.5, 0.5)
		gib.global_transform.origin = pos
		gib.launch_gib(dir, 1, 0)
	return result

func spawn_impact_sprite(origin:Vector3) -> void:
	var impact:Spatial = prefab_impact.instance()
	get_dynamic_parent().add_child(impact)
	var t:Transform = impact.global_transform
	t.origin = origin
	impact.global_transform = t

func _spawn_debris_prefab(
	prefab, origin:Vector3, normal:Vector3, minSpeed:float, maxSpeed:float, count:int) -> void:

	for _i in range(0, count):
		var debris:Spatial = prefab.instance()
		get_dynamic_parent().add_child(debris)
		var t:Transform = Transform.IDENTITY
		t.origin = origin
		debris.global_transform = t
		var rigidBody:RigidBody = debris.find_node("RigidBody")
		if rigidBody != null:
			var launchVel:Vector3 = normal
			launchVel.x += rand_range(-0.3, 0.3)
			launchVel.y += rand_range(-0.3, 0.3)
			launchVel.z += rand_range(-0.3, 0.3)
			launchVel = launchVel.normalized()
			launchVel *= rand_range(minSpeed, maxSpeed)
			rigidBody.linear_velocity = launchVel

func spawn_impact_debris(
	origin:Vector3, normal:Vector3, minSpeed:float, maxSpeed:float, count:int) -> void:
	if Config.cfg.r_hitDebris:
		_spawn_debris_prefab(prefab_impact_debris_t, origin, normal, minSpeed, maxSpeed, count)

func spawn_ejected_bullet(
	origin:Vector3, normal:Vector3, minSpeed:float, maxSpeed:float, count:int) -> void:
	if Config.cfg.r_hitDebris:
		_spawn_debris_prefab(_prefab_ejected_bullet, origin, normal, minSpeed, maxSpeed, count)
		
func spawn_ejected_shell(
	origin:Vector3, normal:Vector3, minSpeed:float, maxSpeed:float, count:int) -> void:
	if Config.cfg.r_hitDebris:
		_spawn_debris_prefab(_prefab_ejected_shell, origin, normal, minSpeed, maxSpeed, count)

func draw_trail(origin:Vector3, dest:Vector3) -> void:
	var trail = _trail_t.instance()
	self.get_dynamic_parent().add_child(trail)
	trail.spawn(origin, dest)

func spawn_ground_target(targetPos:Vector3, duration:float) -> Vector3:
	var obj = _prefab_ground_target_t.instance()
	self.get_dynamic_parent().add_child(obj)
	return obj.run(targetPos, duration)

func spawn_blood_spurt(pos:Vector3) -> void:
	var obj = _prefab_blood_spurt.instance()
	self.get_dynamic_parent().add_child(obj)
	obj.global_transform.origin = pos
	obj.emitting = true

func explosion_shake(_origin:Vector3) -> void:
	get_tree().call_group(Groups.GAME_GROUP_NAME, Groups.GAME_FN_EVENT_EXPLOSION, _origin, 1.0)
	pass

func spawn_explosion_sprite(_origin:Vector3, normal:Vector3) -> void:
	var obj = prefab_explosion_sprite_t.instance()
	self.get_dynamic_parent().add_child(obj)
	obj.global_transform.origin = _origin
	ZqfUtils.set_forward(obj, normal)
