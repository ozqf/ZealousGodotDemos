class_name Weapons

const PistolLabel:String = "pistol"
const DualPistolsLabel:String = "dual_pistols"
const SuperShotgunLabel:String = "ssg"
const ChaingunLabel:String = "cg"
const RocketLauncherLabel:String = "rl"

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
		"refireTime": 0.4
	},
	DualPistolsLabel: {
		"idle": pistol_idle,
		"shoot": pistol_shoot,
		"akimbo": true,
		"refireTime": 0.2
	},
	SuperShotgunLabel: {
		"idle": ssg_idle,
		"shoot": ssg_shoot,
		"refireTime": 1
	},
	ChaingunLabel: {
		"idle": cg_idle,
		"shoot": cg_shoot,
		"refireTime": 0.25
	},
	RocketLauncherLabel: {
		"idle": rl_idle,
		"shoot": rl_shoot,
		"refireTime": 0.25
	}
}
