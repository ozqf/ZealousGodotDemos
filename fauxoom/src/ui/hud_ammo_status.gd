extends Node


# right side - weapon bar
onready var _bulletCount:Label = $bottom_right_panel/ammo_counts/bullets/count
onready var _shellCount:Label = $bottom_right_panel/ammo_counts/shells/count
onready var _plasmaCount:Label = $bottom_right_panel/ammo_counts/plasma/count
onready var _rocketCount:Label = $bottom_right_panel/ammo_counts/rockets/count
onready var _fuelCount:Label = $bottom_right_panel/ammo_counts/fuel/count
onready var _bonusCount:Label = $bonus_count
onready var _bg:ColorRect = $bg

func _update_label(label:Label, count:int, percentage:float) -> void:
	label.text = str(count)
	if percentage >= 100.0:
		label.add_color_override("font_color", Color(1, 1, 1, 1))
	elif percentage >= 50.0:
		label.add_color_override("font_color", Color(0, 1, 0, 1))
	elif percentage >= 25.0:
		label.add_color_override("font_color", Color(1, 1, 0, 1))
	else:
		label.add_color_override("font_color", Color(1, 0, 0, 1))

func player_status_update(data:PlayerHudStatus) -> void:
	if data.hyperLevel > 0:
		_bg.color = Color(0, 1, 0, 0.25)
	else:
		_bg.color = Color(0, 0, 0, 0.25)
	
	if data.hasPistol:
		_bulletCount.get_parent().visible = true
		_update_label(_bulletCount, data.bullets, data.bulletsPercentage)
	else:
		_bulletCount.get_parent().visible = false
		
	if data.hasSuperShotgun:
		_shellCount.get_parent().visible = true
		_update_label(_shellCount, data.shells, data.shellsPercentage)
	else:
		_shellCount.get_parent().visible = false
	
	if data.hasRailgun:
		_plasmaCount.get_parent().visible = true
		_update_label(_plasmaCount, data.plasma, data.plasmaPercentage)
	else:
		_plasmaCount.get_parent().visible = false
	
	if data.hasRocketLauncher:
		_rocketCount.get_parent().visible = true
		_update_label(_rocketCount, data.rockets, data.rocketsPercentage)
	else:
		_rocketCount.get_parent().visible = false
	
	if data.hasFlameThrower:
		_fuelCount.get_parent().visible = true
		_update_label(_fuelCount, data.fuel, data.fuelPercentage)
	else:
		_fuelCount.get_parent().visible = false
	
	_bonusCount.text = str(data.bonus)
	pass
