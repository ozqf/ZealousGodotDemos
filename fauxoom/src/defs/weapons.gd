class_name Weapons

const PistolLabel:String = "pistol"
const DualPistolsLabel:String = "dual_pistols"
const SuperShotgunLabel:String = "ssg"
const ChaingunLabel:String = "cg"
const RocketLauncherLabel:String = "rl"
const FlameThrowerLabel:String = "ft"
const PlasmaGunLabel:String = "pg"

const AmmoTypeBullets:String = "Bullets"
const AmmoTypeShells:String = "Shells"
const AmmoTypeRockets:String = "Rockets"

const weapons:Dictionary = {
	PistolLabel: {
		"idle": "pistol_idle",
		"shoot": "pistol_shoot",
		"ammoType": AmmoTypeBullets,
		"refireTime": 0.3,
		"extraPellets": 0
	},
	DualPistolsLabel: {
		"idle": "pistol_idle",
		"shoot": "pistol_shoot",
		"ammoType": AmmoTypeBullets,
		"akimbo": true,
		"refireTime": 0.15,
		"extraPellets": 0
	},
	SuperShotgunLabel: {
		"idle": "ssg_idle",
		"shoot": "ssg_shoot",
		"ammoType": AmmoTypeShells,
		"refireTime": 1,
		"extraPellets": 10
	},
	ChaingunLabel: {
		"idle": "cg_idle",
		"shoot": "cg_shoot",
		"ammoType": AmmoTypeBullets,
		"refireTime": 0.1,
		"extraPellets": 2
	},
	RocketLauncherLabel: {
		"idle": "rl_idle",
		"shoot": "rl_shoot",
		"ammoType": AmmoTypeRockets,
		"refireTime": 1,
		"extraPellets": 0
	},
	FlameThrowerLabel: {
		"idle": "ft_idle",
		"shoot": "ft_shoot",
		"ammoType": AmmoTypeRockets,
		"refireTime": 0.5,
		"extraPellets": 0
	},
	PlasmaGunLabel: {
		"idle": "pg_idle",
		"shoot": "pg_shoot",
		"ammoType": AmmoTypeRockets,
		"refireTime": 0.05,
		"extraPellets": 0
	}
}
