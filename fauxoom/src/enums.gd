
enum EnemyType {
	Punk,
	Gunner,
	FleshWorm,
	Brain,
	Serpent,
	Cyclops,
	Spider,
	Golem,
	Psychic,
	Titan
}

enum ProjectileType {
	Common,
	Rocket,
	Column
}

# roles assigned by the manager to a mob during gameplay
enum CombatRole {
	Assault,
	Ranged
}

# roles than an enemy can perform
enum EnemyRoleClass {
	Mix,
	Melee,
	Ranged
}

enum PatternType {
	None,
	Arc,
	Scatter,
	CubeVolume,
	SphereVolume
}

enum TriggerVolumeAction {
	TriggerTargets,
	TeleportSubject
}

enum QuickDropType {
	Rage,
	Health
}

enum SequenceOrder {
	Linear,
	Random
}

# enum HitResponeeType {
# 	None,
# 	Damaged,
# 	Killed
# }
