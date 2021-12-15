extends CanvasLayer
class_name Hud

var _hit_indicator_t = load("res://prefabs/ui/hud_hit_indicator.tscn")

# player sprites
onready var gunsContainer:Control = $gun
onready var centreSprite:AnimatedSprite = $gun/weapon_centre
onready var rightSprite:AnimatedSprite = $gun/weapon_right
onready var leftSprite:AnimatedSprite = $gun/weapon_left

onready var _handRight:AnimatedSprite = $bottom_right/right_hand
onready var _handLeft:AnimatedSprite = $bottom_left/left_hand

# player status
onready var _prompt:Label = $centre/interact_prompt
onready var _promptBG:ColorRect = $centre/interact_prompt_bg
onready var _energyBar:TextureProgress = $centre/energy
onready var _healthBar:TextureProgress = $centre/health

# left side - immediate status
onready var _healthCount:Label = $player_status/player_status/health/count
onready var _energyCount:Label = $player_status/player_status/energy/count
onready var _ammoCount:Label = $player_status/player_status/ammo/count
onready var _rageCount:Label = $player_status/player_status/rage/count

# right side - weapon bar
onready var _bulletCount:Label = $bottom_right_panel/bottom_right_panel/ammo_counts/bullets/count
onready var _shellCount:Label = $bottom_right_panel/bottom_right_panel/ammo_counts/shells/count
onready var _plasmaCount:Label = $bottom_right_panel/bottom_right_panel/ammo_counts/plasma/count
onready var _rocketCount:Label = $bottom_right_panel/bottom_right_panel/ammo_counts/rockets/count
onready var _fuelCount:Label = $bottom_right_panel/bottom_right_panel/ammo_counts/fuel/count

# audio
onready var audio:AudioStreamPlayer = $audio/AudioStreamPlayer
onready var audio2:AudioStreamPlayer = $audio/AudioStreamPlayer2
onready var _pickupAudio:AudioStreamPlayer = $audio/audio_pickup

onready var hudAudio = $audio

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

var currentIdleAnim:String = "pistol_idle"
var centreNextAnim:String = ""
var rightNextAnim:String = ""
var leftNextAnim:String = ""

var _swayTime:float = 0.0
var _lastSoundFrame:int = -1

func _ready() -> void:
	add_to_group(Groups.PLAYER_GROUP_NAME)
	var _f = centreSprite.connect("animation_finished", self, "_on_centre_animation_finished")
	_f = rightSprite.connect("animation_finished", self, "_on_right_animation_finished")
	_f = leftSprite.connect("animation_finished", self, "_on_left_animation_finished")
	_f = _handRight.connect("animation_finished", self, "_on_right_hand_animation_finished")
	_f = _handLeft.connect("animation_finished", self, "_on_left_hand_animation_finished")

	# centreSprite.play(_currentWeap["idle"])
	# self.on_change_weapon("ssg")
	_centreTrans = centreSprite.transform
	_rightTrans = rightSprite.transform
	_leftTrans = leftSprite.transform

func inventory_weapon_changed(_newWeap:InvWeapon, _prevWeap:InvWeapon) -> void:
	if _prevWeap != null:
		print("HUD disconnect from " + _prevWeap.name)
		_prevWeap.disconnect("weapon_action", self, "weapon_action")
	if _newWeap != null:
		print("HUD connect to " + _newWeap.name)
		var _err = _newWeap.connect("weapon_action", self, "weapon_action")
	# set_to_idle(_newWeap)

func weapon_action(_weap:InvWeapon, _actionName:String) -> void:
	print("HUD saw weapon action " + _actionName)

func hide_all_sprites() -> void:
	centreSprite.visible = false
	rightSprite.visible = false
	leftSprite.visible = false
	centreNextAnim = ""
	rightNextAnim = ""
	leftNextAnim = ""

# func set_to_idle_defunct(weap:InvWeapon) -> void:
# 	if weap == null || weap.idle == "":
# 		hide_all_sprites()
# 		return
# 	centreSprite.visible = true
# 	centreSprite.play(_currentWeap["idle"])

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
	centreSprite.transform = t

	t = _rightTrans
	t.origin.x += x
	t.origin.y += y
	rightSprite.transform = t
	
	t = _leftTrans
	t.origin.x += x
	t.origin.y += y
	leftSprite.transform = t

func player_hit(_data:Dictionary) -> void:
	var hit = _hit_indicator_t.instance()
	$centre.add_child(hit)
	hit.spawn(_data.selfYawDegrees, _data.direction)

func player_status_update(data:PlayerHudStatus) -> void:
	# crosshair
	var c:Color = Color(1, 1, 1, 1)
	# _maxHealthColour _minHealthColour
	var t:float = float(data.health) / 100.0
	c.r = _minHealthColour.r + (_maxHealthColour.r - _minHealthColour.r) * t
	c.g = _minHealthColour.g + (_maxHealthColour.g - _minHealthColour.g) * t
	c.b = _minHealthColour.b + (_maxHealthColour.b - _minHealthColour.b) * t
	$centre/red_dot.color = c
	_energyBar.value = data.energy
	_energyBar.visible = (_energyBar.value < 100)
	
	_healthBar.value = data.health
	_healthBar.visible = (_healthBar.value < 100)
	_swayTime = data.swayTime 
	_prompt.visible = data.hasInteractionTarget
	_promptBG.visible = data.hasInteractionTarget

	# counts
	_healthCount.text = str(data.health)
	if data.godMode:
		_healthCount.text += " (INVUL)"
	_energyCount.text = str(data.energy)
	if data.currentLoadedMax > 0:
		_ammoCount.text = str(data.currentLoaded) + " / " + str(data.currentLoadedMax) + " - " + str(data.currentAmmo)
	else:
		_ammoCount.text = str(data.currentAmmo)
	_rageCount.text = str(data.rage)
	
	if data.hasPistol:
		_bulletCount.get_parent().visible = true
		_bulletCount.text = str(data.bullets)
	else:
		_bulletCount.get_parent().visible = false
	if data.hasSuperShotgun:
		_shellCount.get_parent().visible = true
		_shellCount.text = str(data.shells)
	else:
		_shellCount.get_parent().visible = false
	if data.hasRailgun:
		_plasmaCount.get_parent().visible = true
		_plasmaCount.text = str(data.plasma)
	else:
		_plasmaCount.get_parent().visible = false
	if data.hasRocketLauncher:
		_rocketCount.get_parent().visible = true
		_rocketCount.text = str(data.rockets)
	else:
		_rocketCount.get_parent().visible = false
	if data.hasFlameThrower:
		_fuelCount.get_parent().visible = true
		_fuelCount.text = str(data.fuel)
	else:
		_fuelCount.get_parent().visible = false

func _on_centre_animation_finished() -> void:
	if centreNextAnim != "":
		centreSprite.play(centreNextAnim)
		centreNextAnim = ""

func _on_right_animation_finished() -> void:
	if rightNextAnim != "":
		rightSprite.play(rightNextAnim)
		rightNextAnim = ""

func _on_left_animation_finished() -> void:
	if leftNextAnim != "":
		leftSprite.play(leftNextAnim)
		leftNextAnim = ""
	
func _on_right_hand_animation_finished() -> void:
	_handRight.visible = false
	_handLeft.visible = false
	gunsContainer.visible = true

func _on_left_hand_animation_finished() -> void:
	_handRight.visible = false
	_handLeft.visible = false
	gunsContainer.visible = true

func play_offhand_punch() -> void:
	gunsContainer.visible = false
	_handLeft.visible = true
	_handLeft.frame = 0
	_handLeft.play()

func player_pickup(_description:String) -> void:
	# var pitch:float = rand_range(0.9, 1.1)
	# _pickupAudio.pitch_scale = pitch
	if _description == "weapon":
		hudAudio.play_weapon_pickup()
		# _pickupAudio.stream = _reloadSample
	else:
		hudAudio.play_item_pickup()
		# _pickupAudio.stream = _pickupSample
	_pickupAudio.play()
	pass
