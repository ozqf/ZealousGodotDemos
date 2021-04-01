extends CanvasLayer
class_name Hud

var _hit_indicator_t = load("res://prefabs/ui/hud_hit_indicator.tscn")

onready var _centreSprite:AnimatedSprite = $gun/weapon_centre
onready var _rightSprite:AnimatedSprite = $gun/weapon_right
onready var _leftSprite:AnimatedSprite = $gun/weapon_left
var _isShooting:bool = false
var _centreTrans:Transform2D
var _rightTrans:Transform2D
var _leftTrans:Transform2D

var _currentWeap:Dictionary = Weapons.weapons["ssg"]
var _akimbo:bool = false
var _leftHandNext:bool = false

var _swayTime:float = 0.0

func _ready() -> void:
	add_to_group(Groups.PLAYER_GROUP_NAME)
	var _f = _centreSprite.connect("animation_finished", self, "_on_centre_animation_finished")
	_f = _rightSprite.connect("animation_finished", self, "_on_right_animation_finished")
	_f = _leftSprite.connect("animation_finished", self, "_on_left_animation_finished")
	# _centreSprite.play(_currentWeap["idle"])
	self.on_change_weapon("ssg")
	_centreTrans = _centreSprite.transform
	_rightTrans = _rightSprite.transform
	_leftTrans = _leftSprite.transform

func _process(_delta:float) -> void:
	#_swayTime += (_delta * 12)
	# x can sway from -1 to 1 (left to right)
	var mulX:float = sin(_swayTime * 0.5)
	# keep y between 0 and 1 so it never moves
	# above original screen position
	var mulY:float = (1 + sin(_swayTime)) * 0.5
	var x:float = mulX * 16
	var y:float = mulY * 16

	var t:Transform2D = _centreTrans
	t.origin.x += x
	t.origin.y += y
	_centreSprite.transform = t

	t = _rightTrans
	t.origin.x += x
	t.origin.y += y
	_rightSprite.transform = t
	
	t = _leftTrans
	t.origin.x += x
	t.origin.y += y
	_leftSprite.transform = t

func player_hit(_data:Dictionary) -> void:
	var hit = _hit_indicator_t.instance()
	$centre.add_child(hit)
	hit.spawn(_data.selfYawDegrees, _data.direction)

func player_status_update(data:Dictionary) -> void:
	$player_status/health.text = "HEALTH " + str(data.health)
	$player_status/bullets.text = "BULLETS: " + str(data.bullets)
	$player_status/shells.text = "SHELLS: " + str(data.shells)
	_swayTime = data.swayTime

func _on_centre_animation_finished() -> void:
	if !_centreSprite.animation == "idle":
		#print("Centre anim finished " + _centreSprite.animation)
		_isShooting = false
		_centreSprite.play(_currentWeap["idle"])

func _on_right_animation_finished() -> void:
	if !_rightSprite.animation == "idle":
		# print("Right anim finished")
		_isShooting = false
		_rightSprite.play(_currentWeap["idle"])

func _on_left_animation_finished() -> void:
	if !_leftSprite.animation == "idle":
		# print("Left anim finished")
		_isShooting = false
		_leftSprite.play(_currentWeap["idle"])

func _apply_weapon_change(_weap:Dictionary) -> void:
	if _weap.has("akimbo"):
		_akimbo = true
		_centreSprite.hide()
		_rightSprite.show()
		_leftSprite.show()
		_rightSprite.play(_currentWeap["idle"])
		_leftSprite.play(_currentWeap["idle"])
	else:
		_akimbo = false
		_rightSprite.hide()
		_leftSprite.hide()
		_centreSprite.show()
		_centreSprite.play(_currentWeap["idle"])

func on_change_weapon(_name:String) -> void:
	if !Weapons.weapons.has(_name):
		_name = "pistol"
	
	_currentWeap = Weapons.weapons[_name]
	self._apply_weapon_change(_currentWeap)

func on_shoot_ssg() -> void:
	if _akimbo:
		if _leftHandNext:
			_leftHandNext = false
			_rightSprite.play(_currentWeap["idle"])
			_leftSprite.play(_currentWeap["shoot"])
		else:
			_leftHandNext = true
			_leftSprite.play(_currentWeap["idle"])
			_rightSprite.play(_currentWeap["shoot"])
		_isShooting = true
	else:
		# print("Shoot centre")
		_centreSprite.play(_currentWeap["shoot"])
		_isShooting = true
