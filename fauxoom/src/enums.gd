
enum EnemyType {
	Punk,
	Gunner,
	FleshWorm,
	Serpent,
	Cyclops,
	Spider,
	Titan
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

# enum HitResponeeType {
# 	None,
# 	Damaged,
# 	Killed
# }
