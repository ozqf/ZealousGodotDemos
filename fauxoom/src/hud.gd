extends CanvasLayer
class_name Hud

var _hit_indicator_t = load("res://prefabs/ui/hud_hit_indicator.tscn")
var _ssgShoot:AudioStream = preload("res://assets/sounds/ssg/ssg_fire.wav")
var _ssgOpen:AudioStream = preload("res://assets/sounds/ssg/ssg_open.wav")
var _ssgLoad:AudioStream = preload("res://assets/sounds/ssg/ssg_load.wav")
var _ssgClose:AudioStream = preload("res://assets/sounds/ssg/ssg_close.wav")

var _pistolShoot:AudioStream = preload("res://assets/sounds/weapon/pistol_fire.wav")
var _rocketShoot:AudioStream = preload("res://assets/sounds/weapon/rocket_fire.wav")

onready var _centreSprite:AnimatedSprite = $gun/weapon_centre
onready var _rightSprite:AnimatedSprite = $gun/weapon_right
onready var _leftSprite:AnimatedSprite = $gun/weapon_left
onready var _prompt:Label = $centre/interact_prompt
onready var _energyBar:TextureProgress = $centre/energy
onready var _healthBar:TextureProgress = $centre/health
onready var _audio:AudioStreamPlayer = $AudioStreamPlayer
onready var _audio2:AudioStreamPlayer = $AudioStreamPlayer2

var _maxHealthColour:Color = Color(0, 1, 0, 1)
var _minHealthColour:Color = Color(1, 0, 0, 1)

var _isShooting:bool = false
var _centreTrans:Transform2D
var _rightTrans:Transform2D
var _leftTrans:Transform2D

var _currentWeapName:String = "ssg"
var _currentWeap:Dictionary = Weapons.weapons["ssg"]
var _akimbo:bool = false
var _leftHandNext:bool = false

var _swayTime:float = 0.0
var _lastSoundFrame:int = -1

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

	if _centreSprite.animation == "ssg_shoot":
		if _centreSprite.frame == 4 && _lastSoundFrame < 4:
			_lastSoundFrame = 4
			_audio2.stream = _ssgOpen
			_audio2.play()
		elif _centreSprite.frame == 7 && _lastSoundFrame < 7:
			_lastSoundFrame = 7
			_audio2.stream = _ssgLoad
			_audio2.play()
		elif _centreSprite.frame == 9 && _lastSoundFrame < 9:
			_lastSoundFrame = 9
			_audio2.stream = _ssgClose
			_audio2.play()

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
	$player_status/energy.text = "ENERGY " + str(data.energy)
	$player_status/bullets.text = "BULLETS: " + str(data.bullets)
	$player_status/shells.text = "SHELLS: " + str(data.shells)
	var c:Color = Color(1, 1, 1, 1)
	# _maxHealthColour _minHealthColour
	var t:float = float(data.health) / 100.0
	c.r = _minHealthColour.r + (_maxHealthColour.r - _minHealthColour.r) * t
	c.g = _minHealthColour.g + (_maxHealthColour.g - _minHealthColour.g) * t
	c.b = _minHealthColour.b + (_maxHealthColour.b - _minHealthColour.b) * t
	$centre/red_dot.color = c
	_energyBar.value = data.energy
	_healthBar.value = data.health 
	_swayTime = data.swayTime 
	_prompt.visible = data.hasInteractionTarget

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
	_currentWeapName = _name
	_currentWeap = Weapons.weapons[_name]
	self._apply_weapon_change(_currentWeap)

func _play_ssg_shot() -> void:
	_audio.stream = _ssgShoot
	_audio.volume_db = -5
	_audio.play()
	_lastSoundFrame = -1

func _play_pistol_shot() -> void:
	_audio.stream = _pistolShoot
	_audio.volume_db = -5
	_audio.play()
	_lastSoundFrame = -1

func _play_rocket_shot() -> void:
	_audio.stream = _rocketShoot
	_audio.volume_db = -5
	_audio.play()
	_lastSoundFrame = -1

func on_player_shoot() -> void:
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
	if _currentWeapName == Weapons.PistolLabel:
		_play_pistol_shot()
	elif _currentWeapName == Weapons.DualPistolsLabel:
		_play_pistol_shot()
	elif _currentWeapName == Weapons.SuperShotgunLabel:
		_play_ssg_shot()
	elif _currentWeapName == Weapons.RocketLauncherLabel:
		_play_rocket_shot()
