
enum EnemyType {
	None,
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

enum EnemyStrengthClass {
	Fodder,
	Medium,
	Large,
	Boss
}

enum ProjectileType {
	Common,
	Rocket,
	Column
}

enum KeyType {
	None,
	Blue,
	Yellow,
	Red
}

# roles assigned by the manager to a mob during gameplay
# assault is a fancy way of saying "rush the player and hit them"
# ranged is a bit more wooly
enum CombatRole {
	Assault,
	Ranged
}

# roles that specific enemy types can perform
# eg punk is ranged only.
# worm is melee only.
enum EnemyRoleClass {
	Mix,
	Melee,
	Ranged,
	Ignored # this enemy is acting on its own
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
	Health,
	Bonus
}

enum SequenceOrder {
	Linear,
	Random
}

enum FileSource {
	EmbeddedAndUser,
	EmbeddedOnly,
	UserOnly
}

enum AppState { Game, Editor }

enum GameState { Pregame, Playing, Won, Lost }

enum GameMode { Classic, King }

enum DebuggerMode {
	Deathray,
	ScanEnemy,
	AttackTest,
	SpawnPunk,
	SpawnWorm,
	SpawnSpider,
	SpawnGolem,
	SpawnTitan,
	SpawnGasSac,
	SpawnSerpent,
	SpawnCyclops,
	ItemSpawnMinorHealth,
	ItemSpawnMinorRage,
	ItemSpawnMinorBonus
}

# enum HitResponeeType {
# 	None,
# 	Damaged,
# 	Killed
# }
