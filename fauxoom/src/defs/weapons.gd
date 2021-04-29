class_name Weapons

const ChainsawLabel:String = "chainsaw"
const PistolLabel:String = "pistol"
const DualPistolsLabel:String = "dual_pistols"
const SuperShotgunLabel:String = "ssg"
const ChaingunLabel:String = "cg"
const RocketLauncherLabel:String = "rl"
const FlameThrowerLabel:String = "ft"
const PlasmaGunLabel:String = "pg"

const AmmoTypeBullets:String = "bullets"
const AmmoTypeShells:String = "shells"
const AmmoTypeRockets:String = "rockets"

const weapons:Dictionary = {
	ChainsawLabel: {
		"name": ChainsawLabel,
		"idle": "saw_idle",
		"shoot": "saw_shoot",
		"y": 344,
		"ammoType": "",
		"refireTime": 0.02,
		"extraPellets": 0,
		"projectileType": "hitscan"
	},
	PistolLabel: {
		"name": PistolLabel,
		"idle": "pistol_idle",
		"shoot": "pistol_shoot",
		"y": 472,
		"ammoType": AmmoTypeBullets,
		"refireTime": 0.3,
		"extraPellets": 0,
		"projectileType": "hitscan"
	},
	DualPistolsLabel: {
		"name": DualPistolsLabel,
		"idle": "pistol_idle",
		"shoot": "pistol_shoot",
		"y": 472,
		"ammoType": AmmoTypeBullets,
		"akimbo": true,
		"refireTime": 0.15,
		"extraPellets": 0,
		"projectileType": "hitscan",
		"projectileDamage": 10
	},
	SuperShotgunLabel: {
		"name": SuperShotgunLabel,
		"idle": "ssg_idle",
		"shoot": "ssg_shoot",
		"y": 472,
		"ammoType": AmmoTypeShells,
		"refireTime": 1,
		"extraPellets": 10,
		"projectileType": "hitscan",
		"projectileDamage": 10
	},
	ChaingunLabel: {
		"name": ChaingunLabel,
		"idle": "cg_idle",
		"shoot": "cg_shoot",
		"y": 472,
		"ammoType": AmmoTypeBullets,
		"refireTime": 0.02,
		"extraPellets": 1,
		"projectileType": "hitscan",
		"projectileDamage": 10
	},
	RocketLauncherLabel: {
		"name": RocketLauncherLabel,
		"idle": "rl_idle",
		"shoot": "rl_shoot",
		"y": 472,
		"ammoType": AmmoTypeRockets,
		"refireTime": 1,
		"extraPellets": 0,
		"projectileType": "player_rocket",
		"projectileDamage": 100
	},
	FlameThrowerLabel: {
		"name": FlameThrowerLabel,
		"idle": "ft_idle",
		"shoot": "ft_shoot",
		"y": 472,
		"ammoType": AmmoTypeRockets,
		"refireTime": 0.5,
		"extraPellets": 0,
		"projectileType": "player_flame",
		"projectileDamage": 10
	},
	PlasmaGunLabel: {
		"name": PlasmaGunLabel,
		"idle": "pg_idle",
		"shoot": "pg_shoot",
		"y": 472,
		"ammoType": AmmoTypeRockets,
		"refireTime": 0.05,
		"extraPellets": 0,
		"projectileType": "player_plasma",
		"projectileDamage": 10
	}
}
