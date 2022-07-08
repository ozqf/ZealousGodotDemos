extends CanvasLayer
class_name Hud

var _hit_indicator_t = load("res://prefabs/ui/hud_hit_indicator.tscn")

# player sprites
onready var gunsContainer:Control = $view_sprites/gun
onready var centreSprite:HudWeaponSprite = $view_sprites/gun/weapon_centre
onready var centreSpriteBig:HudWeaponSprite = $view_sprites/gun/weapon_centre_big
onready var rightSprite:HudWeaponSprite = $view_sprites/gun/weapon_right
onready var leftSprite:HudWeaponSprite = $view_sprites/gun/weapon_left

onready var _ssgSprite:HudWeaponSprite = $view_sprites/gun/weapon_ssg

onready var _handRight:AnimatedSprite = $view_sprites/bottom_right/right_hand
onready var _handLeft:AnimatedSprite = $view_sprites/bottom_left/left_hand

onready var _playerStatus = $player_status
onready var _ammoStatus = $bottom_right_panel
onready var _crosshair = $centre

# red bars for critical health
onready var _criticalHealthLeft:ColorRect = $hurt_left/ColorRect
onready var _criticalHealthRight:ColorRect = $hurt_right/ColorRect
onready var _criticalHealthTop:ColorRect = $hurt_top/ColorRect
onready var _criticalHealthBottom:ColorRect = $hurt_bottom/ColorRect

# audio
onready var audio:AudioStreamPlayer = $audio/AudioStreamPlayer
onready var audio2:AudioStreamPlayer = $audio/AudioStreamPlayer2
onready var _pickupAudio:AudioStreamPlayer = $audio/audio_pickup

onready var hudAudio = $audio

var _maxHealthColour:Color = Color(0, 1, 0, 1)
var _minHealthColour:Color = Color(1, 0, 0, 1)

var _weaponSprites:Array = []

# var _currentCentreSprite:HudWeaponSprite = null
# var _currentRightSprite:HudWeaponSprite = null
# var _currentLeftSprite:HudWeaponSprite = null

var _isShooting:bool = false
var _centreTrans:Transform2D
var _rightTrans:Transform2D
var _leftTrans:Transform2D

var _currentWeapName:String = "ssg"
var _currentWeap:Dictionary = Weapons.weapons["ssg"]
var _akimbo:bool = false
var _leftHandNext:bool = false

var currentIdleAnim:String = "pistol_idle" # this defunct?
var centreNextAnim:String = ""
var rightNextAnim:String = ""
var leftNextAnim:String = ""

var swayTime:float = 0.0
var _lastSoundFrame:int = -1

var _hurtFadeTick:float = 0.0
var _hurtFadeTime:float = 2.0
var _hurtColour:Color = Color(1.0, 0, 0, 1.0)

func _ready() -> void:
	centreSprite.visible = false
	centreSpriteBig.visible = false
	rightSprite.visible = false
	leftSprite.visible = false
	_handRight.visible = false
	_handLeft.visible = false
	_weaponSprites.push_back(centreSprite)
	_weaponSprites.push_back(centreSpriteBig)
	_weaponSprites.push_back(rightSprite)
	_weaponSprites.push_back(leftSprite)
	_weaponSprites.push_back(_ssgSprite)
	add_to_group(Groups.PLAYER_GROUP_NAME)
	add_to_group(Groups.HUD_GROUP_NAME)
	var _f
	_f = _handRight.connect("animation_finished", self, "_on_right_hand_animation_finished")
	_f = _handLeft.connect("animation_finished", self, "_on_left_hand_animation_finished")

	# centreSprite.play(_currentWeap["idle"])
	# self.on_change_weapon("ssg")
	_centreTrans = centreSprite.transform
	_rightTrans = rightSprite.transform
	_leftTrans = leftSprite.transform

func inventory_weapon_changed(_newWeap:InvWeapon, _prevWeap:InvWeapon) -> void:
	#if _prevWeap != null:
	#	print("HUD disconnect from " + _prevWeap.name)
	#	_prevWeap.disconnect("weapon_action", self, "weapon_action")
	#if _newWeap != null:
	#	print("HUD connect to " + _newWeap.name)
	#	var _err = _newWeap.connect("weapon_action", self, "weapon_action")
	# set_to_idle(_newWeap)
	pass

#func weapon_action(_weap:InvWeapon, _actionName:String) -> void:
#	print("HUD saw weapon action " + _actionName)

func _update_hurt_fade(_delta:float) -> void:
	var col:Color = Color(1.0, 0.0, 0.0, 0.0)
	var visible:bool = false
	if _hurtFadeTick <= 0:
		visible = false
	else:
		_hurtFadeTick -= _delta
		var weight:float = _hurtFadeTick / _hurtFadeTime
		weight = ZqfUtils.clamp_float(weight, 0.0, 1.0)
		visible = true
		col = _hurtColour
		col.a = weight
		# print("Hurt fade " + str(col))
	
	_criticalHealthLeft.visible = visible
	_criticalHealthRight.visible = visible
	_criticalHealthTop.visible = visible
	_criticalHealthBottom.visible = visible

	_criticalHealthLeft.color = col
	_criticalHealthRight.color = col
	_criticalHealthTop.color = col
	_criticalHealthBottom.color = col
	pass

func _process(_delta:float) -> void:
	_update_hurt_fade(_delta)
	#swayTime += (_delta * 12)
	# x can sway from -1 to 1 (left to right)
	var mulX:float = sin(swayTime * 0.5)
	# keep y between 0 and 1 so it never moves
	# above original screen position
	var mulY:float = (1 + sin(swayTime)) * 0.5
	var x:float = mulX * 16
	var y:float = mulY * 16
	
	for sprite in _weaponSprites:
		sprite.update_sway_time(swayTime)
	
	var t:Transform2D = _centreTrans
	#t.origin.x += x
	#t.origin.y += y
	#centreSprite.transform = t
	
	t = _rightTrans
	t.origin.x += x
	t.origin.y += y
	rightSprite.transform = t
	
	t = _leftTrans
	t.origin.x += x
	t.origin.y += y
	leftSprite.transform = t

func hide_all_sprites() -> void:
	for sprite in _weaponSprites:
		sprite.visible = false
	# centreSprite.visible = false
	# rightSprite.visible = false
	# leftSprite.visible = false
	centreNextAnim = ""
	rightNextAnim = ""
	leftNextAnim = ""

func hud_get_weapon_sprite(nodeName:String) -> HudWeaponSprite:
	var node = gunsContainer.find_node(nodeName) as HudWeaponSprite
	if node != null:
		node.visible = true
	return node

func hud_set_visible_weapon_sprite(nodeName:String) -> HudWeaponSprite:
	hide_all_sprites()
	var node = gunsContainer.find_node(nodeName) as HudWeaponSprite
	if node != null:
		node.visible = true
	return node

func hud_play_weapon_idle(idleAnimName:String, akimbo:bool = false) -> void:
	hide_all_sprites()
	if idleAnimName == null || idleAnimName == "":
		return
	# currentIdleAnim = idleAnimName
	if akimbo:
		rightSprite.visible = true
		rightSprite.play(idleAnimName)
		rightSprite.nextAnim = ""
		leftSprite.visible = true
		leftSprite.play(idleAnimName)
		leftSprite.nextAnim = ""
	else:
		centreSprite.visible = true
		centreSprite.play(idleAnimName)
		centreSprite.nextAnim = ""
	pass

func hud_play_weapon_shoot(
	shootAnimName:String,
	idleAnimName:String,
	loop:bool = false,
	akimbo:bool = false,
	heaviness:float = 1.0) -> void:
	var sprite:HudWeaponSprite
	if !akimbo:
		sprite = centreSprite
	else:
		if _leftHandNext:
			_leftHandNext = false
			sprite = leftSprite
		else:
			_leftHandNext = true
			sprite = rightSprite
	
	# not akimbo - most common
	sprite.play(shootAnimName)
	sprite.frame = 0
	if !loop:
		sprite.nextAnim = idleAnimName
	# kick sprite if attack is heavy
	if heaviness > 0.0:
		sprite.run_shoot_push()

func hud_play_weapon_empty() -> void:
	pass

func player_hit(_data:Dictionary) -> void:
	# spawn a centre hit indicator
	var hit = _hit_indicator_t.instance()
	$centre.add_child(hit)
	hit.spawn(_data.selfYawDegrees, _data.direction)
	
	# show hurt border
	_hurtFadeTick = _hurtFadeTime
	if _data.healthType == 0:
		_hurtColour = Color(1.0, 0, 0, 1.0)
	else:
		_hurtColour = Color(1.0, 1.0, 0.0, 1.0)

func player_status_update(data:PlayerHudStatus) -> void:
	
	swayTime = data.swayTime

	# show hurt if on very low hp
	# var criticalHealth:bool = data.health <= 25
	# _criticalHealthLeft.visible = criticalHealth
	# _criticalHealthRight.visible = criticalHealth
	# _criticalHealthTop.visible = criticalHealth
	# _criticalHealthBottom.visible = criticalHealth
	
	_crosshair.player_status_update(data)
	_playerStatus.player_status_update(data)
	_ammoStatus.player_status_update(data)

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
	if _description == "weapon":
		hudAudio.play_weapon_pickup()
	else:
		hudAudio.play_item_pickup()
	_pickupAudio.play()
	pass
