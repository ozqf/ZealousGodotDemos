## Fauxoom TODO

### Quick list

> Gameplay
	> Spawning
		> Wave based arenas and spawn combinations.
	> Gameplay structure
		> Level to level progression
		> Scoring
		> Difficulty modes
	> Basic enemy AI
		> Moving
		> LoS check
		> Navigation - mesh...?, nodes for big stuff?
		> Attack-sequences
			> single
			> burst
			> repeat
		> Attack types
			> Projectile attacks
			> Melee attacks
> Gamefeel
	> Gun kick, sound gun sway (movement)
	> View sway
	> Movement accel/friction
	> Dash mechanic has no feel atm
> Aesthetic
	> Look into light-baking/GI - or waiting for Godot 4 :/
	> Skybox - 3D - requires specific canvas layers and all visible nodes to be their children.
	> Fog
> music
	> convert some Freedoom midis to mp3
> Menus
	> Options
		> mouse sensitivity
		> sfx/bgm volume

### Arena Spawning

Arena spawning needs to be adaptable to various spawning sequences and spawn types. eg a spawn that is continuous until emptyed, a spawn that is a fixed number of enemies all at once, etc.

### Issue - current spawning has duplicate classes

horde_spawn_entity and horde_spawn_component should be consolidated.

horde_spawn entity script is part of static_entities/horde_spawn.tscn prefab, used in several levels.



#### Concept node arrangement

spawn_points
	point_1
	point_2
	point_3
	...etc
survival_controller -> master control node. trigger to start the arena. on init will find its spawn_points sibling by name
	horde_spawns
		spawn_1 -> spawns have a mob to spawn and are given the spawn points list which they can filter.
		spawn_2
		spawn_3
		...etc
	waves
		wave_1 -> waves have a list of the horde_spawn nodes it should run during this wave.
		wave_2
		etc...

Notes on this arrangement:
> Spawn points can be shared between multiple survival controllers.
> horde_spawns can be shared between waves.
> Waves are run in sequence by the 'controller'.
> A wave is 'completed' when all of its spawns say they are finished. Spawns marked as 'endless' are always considered complete, unless they are the last in the sequence, where they must be told to stop by the wave.

### Enemy movement/behaviours

Navigation nodes must have a 'navigation_service' scripted attached or it will not be found by mobs!

continuous
> strafes: attempts to move away from the direction of the player's aim
> cowardly: if player is aiming toward them the enemy will attack less and move more.
> flees: On half health attempts to move away from player
> enrages: on half health enters wild rapid firing mode

one off
> Nearby enemy is gibbed in one shot - stuns


### Issues

#### Register new entity

Scheme for handling saving/loading of game states requires significant wiring
when restoring 'dynamic' entities that may or may not exist (eg knowing the prefab to restore)

> In entities.gd
	> Add an entry for the new entity pointing at its prefab in entities.gd. This is required for save/load of dynamic entities.
	> Add a PREFAB_NAME_OF_ENTITY_TYPE string constant
> Sprite (custom_animator_3d.gd) node on mob instance
	> set Animation Set to set defined in animations.gd
> Enums - EntityType
	> entities.gd -> selects prefab to spawn
	> mob_spawn_proxy.gd
	> horde_spawn_entity.gd




#### Spawning map entities

System to support custom levels/entity setups and levels embedded via Godot scenes.

CustomMap: entities loaded from file. Save state easier - can ignore entities on load, and spawn godot entities from file data.
EmbeddedMap: entities preplaced, but cannot place the live godot objects. Need to place spawn points, and process them if level load is fresh.

MapDef needs to support these modes:

Custom map - contains grid geometry and entity spawns.

```
spawn point:
	Transform
	spawn type
	spawn settings - dictionary
```