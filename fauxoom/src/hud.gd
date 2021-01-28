extends CanvasLayer
class_name Hud

const pistol_idle:String = "pistol_idle"
const pistol_shoot:String = "pistol_shoot"
const ssg_idle:String = "idle"
const ssg_shoot:String = "shoot"

const _weapons:Dictionary = {
	"pistol": {
		"idle": pistol_idle,
		"shoot": pistol_shoot,
		"akimbo": false
	},
	"ssg": {
		"idle": ssg_idle,
		"shoot": ssg_shoot,
		"akimbo": false
	}
}

onready var _ssg:AnimatedSprite = $gun/ssg
var _isShooting:bool = false

var _currentWeap:Dictionary = _weapons["pistol"]
# var _currentIdle:String = pistol_idle
# var _currentShoot:String = pistol_shoot

func _ready() -> void:
	var _f = _ssg.connect("animation_finished", self, "_on_ssg_animation_finished")
	_ssg.play(_currentWeap["idle"])

func _on_ssg_animation_finished() -> void:
	if _isShooting:
		_isShooting = false
		_ssg.play(_currentWeap["idle"])

func on_change_weapon(_name:String) -> void:
	_currentWeap = _weapons[_name]
	_ssg.play(_currentWeap["idle"])

func on_shoot_ssg() -> void:
	_ssg.play(_currentWeap["shoot"])
	_isShooting = true
