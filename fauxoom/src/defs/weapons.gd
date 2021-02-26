class_name Weapons

const PistolLabel:String = "pistol"
const DualPistolsLabel:String = "dual_pistols"
const SuperShotgunLabel:String = "ssg"
const ChaingunLabel:String = "cg"
const RocketLauncherLabel:String = "rl"

const AmmoTypeBullets:String = "Bullets"
const AmmoTypeShells:String = "Shells"
const AmmoTypeRockets:String = "Rockets"

const pistol_idle:String = "pistol_idle"
const pistol_shoot:String = "pistol_shoot"

const ssg_idle:String = "ssg_idle"
const ssg_shoot:String = "ssg_shoot"

const cg_idle:String = "cg_idle"
const cg_shoot:String = "cg_shoot"

const rl_idle:String = "rl_idle"
const rl_shoot:String = "rl_shoot"

const weapons:Dictionary = {
	PistolLabel: {
		"idle": pistol_idle,
		"shoot": pistol_shoot,
		"ammoType": AmmoTypeBullets,
		"refireTime": 0.3,
		"extraPellets": 0
	},
	DualPistolsLabel: {
		"idle": pistol_idle,
		"shoot": pistol_shoot,
		"ammoType": AmmoTypeBullets,
		"akimbo": true,
		"refireTime": 0.15,
		"extraPellets": 0
	},
	SuperShotgunLabel: {
		"idle": ssg_idle,
		"shoot": ssg_shoot,
		"ammoType": AmmoTypeShells,
		"refireTime": 1,
		"extraPellets": 10
	},
	ChaingunLabel: {
		"idle": cg_idle,
		"shoot": cg_shoot,
		"ammoType": AmmoTypeBullets,
		"refireTime": 0.1,
		"extraPellets": 2
	},
	RocketLauncherLabel: {
		"idle": rl_idle,
		"shoot": rl_shoot,
		"ammoType": AmmoTypeRockets,
		"refireTime": 1,
		"extraPellets": 0
	}
}
