extends Node


# right side - weapon bar
onready var _bulletCount:Label = $bottom_right_panel/ammo_counts/bullets/count
onready var _shellCount:Label = $bottom_right_panel/ammo_counts/shells/count
onready var _plasmaCount:Label = $bottom_right_panel/ammo_counts/plasma/count
onready var _rocketCount:Label = $bottom_right_panel/ammo_counts/rockets/count
onready var _fuelCount:Label = $bottom_right_panel/ammo_counts/fuel/count
onready var _bonusCount:Label = $bonus_count

func player_status_update(data:PlayerHudStatus) -> void:
	if data.hasPistol:
		_bulletCount.get_parent().visible = true
		_bulletCount.text = str(data.bullets)
	else:
		_bulletCount.get_parent().visible = false
		
	if data.hasSuperShotgun:
		_shellCount.get_parent().visible = true
		_shellCount.text = str(data.shells)
	else:
		_shellCount.get_parent().visible = false
	
	if data.hasRailgun:
		_plasmaCount.get_parent().visible = true
		_plasmaCount.text = str(data.plasma)
	else:
		_plasmaCount.get_parent().visible = false
	
	if data.hasRocketLauncher:
		_rocketCount.get_parent().visible = true
		_rocketCount.text = str(data.rockets)
	else:
		_rocketCount.get_parent().visible = false
	
	if data.hasFlameThrower:
		_fuelCount.get_parent().visible = true
		_fuelCount.text = str(data.fuel)
	else:
		_fuelCount.get_parent().visible = false
	
	_bonusCount.text = str(data.bonus)
	pass
