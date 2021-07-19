extends Control

onready var _bulletCount:Label = $ammo_counts/bullets/count
onready var _shellCount:Label = $ammo_counts/shells/count
onready var _plasmaCount:Label = $ammo_counts/plasma/count
onready var _rocketCount:Label = $ammo_counts/rockets/count

func _ready():
	add_to_group(Groups.PLAYER_GROUP_NAME)

func player_status_update(data:Dictionary) -> void:
	_bulletCount.text = str(data.bullets)
	_shellCount.text = str(data.shells)
	_plasmaCount.text = str(data.plasma)
	_rocketCount.text = str(data.rockets)
