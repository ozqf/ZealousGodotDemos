extends Node

# left side - immediate status
onready var _healthCount:Label = $player_status/health/count
onready var _energyCount:Label = $player_status/energy/count
onready var _ammoCount:Label = $player_status/ammo/count
onready var _rageCount:Label = $player_status/rage/count
onready var _hyperTime:TextureProgress = $hyper_time

func player_status_update(data:PlayerHudStatus) -> void:
	# counts
	_healthCount.text = str(data.health)
	if data.hyperLevel > 0:
		_healthCount.add_color_override("font_color",  Color(1, 1, 0))
	else:
		_healthCount.add_color_override("font_color",  Color(1, 1, 1))
	if data.godMode:
		_healthCount.text += " (INVUL)"
	_energyCount.text = str(data.energy)
	if data.currentLoadedMax > 0:
		_ammoCount.text = str(data.currentLoaded) + " / " + str(data.currentLoadedMax) + " - " + str(data.currentAmmo)
	else:
		_ammoCount.text = str(data.currentAmmo)
	_rageCount.text = str(data.rage)
	
	if data.hyperLevel > 0:
		_hyperTime.visible = true
		_hyperTime.value = int((data.hyperTime / Interactions.HYPER_DURATION) * 100.0)
	else:
		_hyperTime.visible = false
