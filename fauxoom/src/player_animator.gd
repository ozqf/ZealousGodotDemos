extends AnimatedSprite3D
class_name PlayerAnimator

const _walk_frames:Array = [
	[ 0, 8, 16, 24 ],
	[ 1, 9, 17, 25 ],
	[ 2, 10, 18, 26 ],
	[ 3, 11, 19, 27 ],
	[ 4, 12, 20, 28 ],
	[ 5, 13, 21, 29 ],
	[ 6, 14, 22, 30 ],
	[ 7, 15, 23, 31 ]
]
const _aim_frames = [[32],[33],[34],[35],[36],[37],[38],[39]]
const _shoot_frames = [[40],[41],[42],[43],[44],[45],[46],[47]]
const _pain_frames = [[48],[49],[50],[51],[52],[53],[54],[55]]
const _die_frames = [[56,57,58,59,60,61,62]]
const _gib_frames = [[63,64,65,66,67,68,69,70,71]]

var _frameRate:float = 5
var _tick:float = 0
var _frame:int = 0
var _maxFrames:int = 4
var _currentAnim:Array = _walk_frames

var yawDegrees:float = 0

func _ready() -> void:
	_currentAnim = _walk_frames
	_maxFrames = _currentAnim[0].size()

func _calc_dir_index() -> int:
	var cam:Transform = game.get_camera_pos()
	var i:int = ZqfUtils.sprite_index(cam, self.global_transform, yawDegrees, _currentAnim.size())
	return i

func _process(_delta:float) -> void:
	_tick += _delta
	var cap:float = 1.0 / _frameRate
	if _tick > cap:
		_tick = 0
		_frame += 1
		if _frame >= _maxFrames:
			_frame = 0
		var dirIndex:int = _calc_dir_index()
		var animatorFrame:int = _currentAnim[dirIndex][_frame]
		frame = animatorFrame
