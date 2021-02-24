extends KinematicBody

onready var _sprite:EntitySprite = $body

const MOVE_SPEED:float = 5.0

var _curTarget = null

var _moveTick:float = 0
var _moveYaw:float = 0


func _ready() -> void:
	print("Mob Gunner init")

func move(_delta:float) -> void:
	# look_at(_curTarget.global_transform.origin, Vector3.UP)
	if _moveTick <= 0:
		# decide on next move
		_moveTick = 1
		var selfPos:Vector3 = global_transform.origin
		var tarPos:Vector3 = _curTarget.global_transform.origin
		var dist:float = ZqfUtils.flat_distance_between(selfPos, tarPos)
		if dist > 3:
			_moveYaw = ZqfUtils.yaw_between(selfPos, tarPos)
			var quarter:float = deg2rad(90)
			_moveYaw -= quarter
			_moveYaw += rand_range(0, quarter * 2.0)
	else:
		_moveTick -= _delta
	
	rotation.y = _moveYaw
	var move:Vector3 = Vector3()
	move.x = -sin(_moveYaw)
	move.z = -cos(_moveYaw)
	var _result = self.move_and_slide(move * MOVE_SPEED)

func _process(_delta:float) -> void:
	var wasNull:bool = _curTarget == null
	_curTarget = game.mob_check_target(_curTarget)
	if _curTarget && wasNull:
		print("Gunner got target!")
	elif _curTarget == null && !wasNull:
		print("Gunner lost target!")
	
	if _curTarget != null:
		move(_delta)
