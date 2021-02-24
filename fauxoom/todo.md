## Fauxoom TODO

### Quick list

> Gameplay
	> Damage - killing enemies
	> items
		> Health
		> Armour
		> Ammo
		> Weapons
		> powerups
	> Entities
		> Triggers
		> doors/gates
		> counters
		> relays
	> Basic enemy AI
		> Moving
		> LoS check
		> Attack-sequences
			> single
			> burst
			> repeat
		> Attack types
			> Projectile attacks
			> Melee attacks
		> States
			> idle
			> hunting/attacking
			> stunned
			> Dying
			> Gibbing
> Gamefeel
	> Gun kick
	> Gun sound
	> Gun sway
	> View sway
	> Movement accel/friction
	> Dash mechanic...?
> music
	> convert some Freedoom midis to mp3
> Menus
	> Options
		> mouse sensitivity
		> sfx/bgm volume

### Enemy movement/behaviours

continuous
> strafes: attempts to move away from the direction of the player's aim
> cowardly: if player is aiming toward them the enemy will attack less and move more.
> flees: On half health attempts to move away from player
> enrages: on half health enters wild rapid firing mode

one off
> Nearby enemy is gibbed in one shot - stuns


### Issues

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