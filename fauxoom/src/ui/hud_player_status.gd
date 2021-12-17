extends Node

# left side - immediate status
onready var _healthCount:Label = $player_status/health/count
onready var _energyCount:Label = $player_status/energy/count
onready var _ammoCount:Label = $player_status/ammo/count
onready var _rageCount:Label = $player_status/rage/count


func player_status_update(data:PlayerHudStatus) -> void:
	# counts
	_healthCount.text = str(data.health)
	if data.godMode:
		_healthCount.text += " (INVUL)"
	_energyCount.text = str(data.energy)
	if data.currentLoadedMax > 0:
		_ammoCount.text = str(data.currentLoaded) + " / " + str(data.currentLoadedMax) + " - " + str(data.currentAmmo)
	else:
		_ammoCount.text = str(data.currentAmmo)
	_rageCount.text = str(data.rage)
