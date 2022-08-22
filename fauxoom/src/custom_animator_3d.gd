extends AnimatedSprite3D
class_name CustomAnimator3D

export var active:bool = false
export var useParentYaw:bool = false
export var animationSet:String = ""
export var defaultAnimation:String = ""

var _yawOverride:Spatial = null

var _frameRate:float = 5
var _tick:float = 0
var _frame:int = 0
var _maxFrames:int = 4

var _currentSet:Dictionary = {}
var _currentAnimation:Dictionary = {}
var _currentFrames:Array
var _pendingAnimation:String = ""
var _loopIndex:int = 0

var _updateAccumulator:float = 0.0

var yawDegrees:float = 0

func _ready() -> void:
	change_set_and_animation(animationSet, defaultAnimation)

func set_yaw_override(yawSourceOverride:Spatial) -> void:
	_yawOverride = yawSourceOverride

# returns true if animation was successfully changed
func play_animation(animName:String, followUpAnimName:String = "") -> bool:
	if animName == "" || !_currentSet.anims.has(animName):
		active = false
		# print("No animation '" + animName + "' in set '" + _currentSet.name + "'")
		return false
	_currentAnimation = _currentSet.anims[animName]
	if _currentAnimation.has("loopIndex"):
		_loopIndex = _currentAnimation.loopIndex
	else:
		_loopIndex = 0
	_currentFrames = _currentAnimation.frames
	_maxFrames = _currentFrames[0].size()
	_frame = 0
	active = true
	_pendingAnimation = followUpAnimName
	# print("Custom animator playing " + animName)
	return true

func change_set_and_animation(setName:String, animName:String) -> void:
	if setName == "" || !Animations.data.has(setName):
		# print("No animation set '" + setName + "' found")
		active = false
		return
	_currentSet = Animations.data[setName]
	frames = load(_currentSet.path)
	play_animation(animName)

func get_frame_number() -> int:
	return _frame

func set_frame_number(val:int) -> void:
	_tick = 0
	_frame = val

func _calc_dir_index() -> int:
	var cam:Transform = Main.get_camera_pos()
	if _yawOverride != null:
		yawDegrees = _yawOverride.rotation_degrees.y
	elif useParentYaw:
		yawDegrees = get_parent().rotation_degrees.y
	# else:
	# 	yawDegrees = rotation_degrees.y
	# rotation_degrees.y = yawDegrees
	# print("enemy yaw " + str(yawDegrees))
	var i:int = ZqfUtils.sprite_index(cam, self.global_transform, yawDegrees, _currentFrames.size())
	return i

func _process(_delta:float) -> void:
	if !active:
		return
	_tick += _delta
	var cap:float = 1.0 / _frameRate
	if _tick > cap:
		_tick = 0
		_frame += 1
		# check for finish
		if _frame >= _maxFrames:
			_frame = _loopIndex
	_updateAccumulator += _delta
	# with only eight angles and very short animations
	# for sprites this really doesn't need to updated frequently
	if _updateAccumulator < (1.0 / 15.0):
		return
	_updateAccumulator = 0.0
	# refresh frame
	var dirIndex:int = _calc_dir_index()
	var animatorFrame:int = _currentFrames[dirIndex][_frame]
	frame = animatorFrame
