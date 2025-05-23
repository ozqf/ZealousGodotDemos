extends AnimatedSprite3D
class_name HudWeaponSprite

@export var pushBoostDistance:int = 48
@export var pushDuration:float = 0.15
var nextAnim:String = ""

var _screenOrigin:Vector3
var _pushOrigin:Vector3
var _pushOffset:Vector2 = Vector2()
var _pushTime:float = 0.0

var _a:Vector3 = Vector3()
var _b:Vector3 = Vector3()

var _swayOffset:Vector3 = Vector3()

var baseColour:Color = Color.WHITE
var hyperColour:Color = Color.GREEN

var _colourTick:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_screenOrigin = position
	_pushOrigin = _screenOrigin
	_pushOrigin.y += pushBoostDistance
	_a = _screenOrigin
	_b = _screenOrigin
	var _r = connect("animation_finished", on_animation_finished)

func on_animation_finished() -> void:
	if nextAnim != "":
		play(nextAnim)
		nextAnim = ""

func update_sway_time(swayTime:float) -> void:
	#swayTime += (_delta * 12)
	# x can sway from -1 to 1 (left to right)
	var mulX:float = sin(swayTime * 0.5)
	# keep y between 0 and 1 so it never moves
	# above original screen position
	var mulY:float = (1 + sin(swayTime)) * 0.5
	_swayOffset.x = mulX * 16
	_swayOffset.y = mulY * 16

func run_shoot_push() -> void:
	_pushTime = 0.0
	_a = _pushOrigin
	_b = _screenOrigin
	position = _a

func _process(_delta:float):
	_pushTime += _delta
	var weight:float = _pushTime / pushDuration
	if weight > 1.0:
		weight = 1.0
	position = _a.lerp(_b, weight) + _swayOffset
	
	# colour
	if Game.hyperLevel > 0:
		_colourTick += (_delta * 4.0)
		var colourWeight:float = (cos(_colourTick) + 1.0) * 0.5
		self.modulate = baseColour.lerp(hyperColour, colourWeight)
	else:
		self.modulate = baseColour
