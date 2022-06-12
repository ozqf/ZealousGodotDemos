extends Control

const farLeft:float = -640.0
const farRight:float = 1280.0
const nearLeft:float = 256.0
const nearRight:float = 384.0
# const nearLeft:float = 240.0
# const nearRight:float = 860.0

const flyTime:float = 0.25
const pauseTime:float = 1.5

onready var _left:Label = $left
onready var _right:Label = $right

var _messageStackLeft:PoolStringArray = PoolStringArray()
var _messageStackRight:PoolStringArray = PoolStringArray()

enum FlashyMessageState {
	Idle,
	FlyOn,
	Pause,
	FlyOff
}

var _state = FlashyMessageState.Idle
var _tick:float = 0.0
var _tock:float = 1.0

func _ready():
	# add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.CONSOLE_GROUP_NAME)
	_reset()

func console_on_exec(_text:String, tokens:PoolStringArray) -> void:
	var numTokens:int = tokens.size()
	if numTokens == 1:
		if _text == "flashy":
			print("Post a flashy message! Flashy <textA> <textB>")
		return
	if numTokens == 2:
		if tokens[0] != "flashy":
			return
		post_message(tokens[1], "")
	else:
		post_message(tokens[1], tokens[2])

func _reset() -> void:
	_tick = 0.0
	_left.rect_position.x = farLeft
	_right.rect_position.x = farRight

func run_message(topText:String, bottomText:String) -> void:
	_left.text = topText
	_right.text = bottomText
	_reset()
	_tock = flyTime
	_state = FlashyMessageState.FlyOn

func post_message(topText:String, bottomText:String) -> void:
	print("Flash! " + topText + ", " + bottomText)
	_messageStackLeft.push_back(topText)
	_messageStackRight.push_back(bottomText)

func game_on_player_spawned() -> void:
	post_message("KING OF THE HILL...", "...START!")
	pass

func _set_label_x(obj:Control, origin:float, dest:float, step:float) -> void:
	var x:float = lerp(origin, dest, step)
	obj.rect_position.x = x
	pass

func _process(_delta:float) -> void:
	_tick += _delta
	var step:float = _tick / _tock
	if _state == FlashyMessageState.Idle:
		if _messageStackLeft.size() == 0:
			return
		var top:String = _messageStackLeft[0]
		var bottom:String = _messageStackRight[0]
		_messageStackLeft.remove(0)
		_messageStackRight.remove(0)
		run_message(top, bottom)
	elif _state == FlashyMessageState.FlyOn:
		if step > 1.0:
			step = 1.0
		_set_label_x(_left, farLeft, nearLeft, step)
		_set_label_x(_right, farRight, nearRight, step)
		if step >= 1.0:
			_left.rect_position.x = nearLeft
			_right.rect_position.x = nearRight
			_state = FlashyMessageState.Pause
			_tick = 0.0
			_tock = pauseTime
	elif _state == FlashyMessageState.Pause:
		if step > 1.0:
			step = 1.0
		_set_label_x(_left, nearLeft, nearRight, step)
		_set_label_x(_right, nearRight, nearLeft, step)
		if step >= 1.0:
			_left.rect_position.x = nearRight
			_right.rect_position.x = nearLeft
			_state = FlashyMessageState.FlyOff
			_tick = 0.0
			_tock = flyTime
	elif _state == FlashyMessageState.FlyOff:
		if step > 1.0:
			step = 1.0
		_set_label_x(_left, nearRight, farRight, step)
		_set_label_x(_right, nearLeft, farLeft, step)
		if step >= 1.0:
			_state = FlashyMessageState.Idle
			_reset()
