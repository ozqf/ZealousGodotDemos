extends Node

@onready var _sprite:CustomAnimator3D = $sprite

@export var animationSet:String = "flesh_worm"
@export var dyingAnimation:String = "dying"
@export var deadAnimation:String = "dead"

var _tick:float = 20.0

func _ready() -> void:
	add_to_group(Groups.GAME_GROUP_NAME)
	_sprite.play_animation("dying", "dead")

func game_cleanup_temp_ents() -> void:
	queue_free()

func set_sprite_offset(x:int, y:int) -> void:
	_sprite.offset = Vector2(x, y)

func set_sprite_pixel_size(size:float) -> void:
	_sprite.pixel_size = size

func spawn(_spawnInfo:CorpseSpawnInfo, _trans:Transform3D) -> void:
	self.global_transform = _trans
	_sprite.change_set_and_animation(animationSet, dyingAnimation)
	_sprite.play_animation("dying", "dead")

func hit(_spawnInfo:HitInfo) -> int:
	return Interactions.HIT_RESPONSE_PENETRATE

func _process(_delta:float) -> void:
	_tick -= _delta
	if _tick <= 0.0:
		queue_free()
	pass
