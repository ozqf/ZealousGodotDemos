extends Node

var _burnTime:float = 8.0

var _burningMask:int = 0
var _burningTick:float = 0.0
var _stackCount:int = 0

func get_stack_count() -> int:
	return _stackCount

func apply_burn(sourceMask:int = 1) -> void:
	if sourceMask == 0:
		return
	#print("Applying burn mask " + str(sourceMask))
	_burningMask |= sourceMask
	_burningTick = _burnTime
	_stackCount = ZqfUtils.count_bits_set(_burningMask)

func _process(_delta:float) -> void:
	if _burningTick <= 0.0:
		return
	_burningTick -= _delta
	if _burningTick <= 0.0:
		#print("Mob - Burn faded")
		_burningMask = 0
		_stackCount = 0
