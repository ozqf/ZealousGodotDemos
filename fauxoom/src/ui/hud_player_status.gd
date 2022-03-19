extends Node

# left side - immediate status
onready var _healthCount:Label = $player_status/health/count
onready var _energyCount:Label = $player_status/energy/count
onready var _ammoCount:Label = $player_status/ammo/count
onready var _rageCount:Label = $player_status/rage/count
onready var _hyperTime:TextureProgress = $hyper_time
onready var _bg:ColorRect = $bg

func player_status_update(data:PlayerHudStatus) -> void:
	# counts
	_healthCount.text = str(data.health)
	if data.health > 50:
		_healthCount.add_color_override("font_color",  Color(1, 1, 1))
	elif data.health > 25:
		_healthCount.add_color_override("font_color",  Color(1, 1, 0))
	else:
		_healthCount.add_color_override("font_color",  Color(1, 0, 0))
	if data.godMode:
		_healthCount.text += " (INVUL)"
	_energyCount.text = str(data.energy)
	if data.currentLoadedMax > 0:
		_ammoCount.text = str(data.currentLoaded) + " / " + str(data.currentLoadedMax) + " - " + str(data.currentAmmo)
	else:
		_ammoCount.text = str(data.currentAmmo)
	
	if data.rage >= Interactions.HYPER_SAVE_COST:
		_rageCount.add_color_override("font_color", Color(1, 1, 0))
	else:
		_rageCount.add_color_override("font_color", Color(1, 1, 1))
	_rageCount.text = str(data.rage)
	
	if data.hyperLevel > 0:
		_bg.color = Color(1, 1, 0, 0.25)
		_hyperTime.tint_progress = Color(1, 1, 0)
		_hyperTime.visible = true
		_hyperTime.value = data.rage
		#_hyperTime.value = int((data.hyperTime / Interactions.HYPER_DURATION) * 100.0)
	else:
		_bg.color = Color(0, 0, 0, 0.25)
		if data.hyperTime > 0 && Interactions.HYPER_COOLDOWN_DURATION > 0.0:
			_hyperTime.visible = true
			_hyperTime.tint_progress = Color(0, 0, 1)
			_hyperTime.value = int((data.hyperTime / Interactions.HYPER_COOLDOWN_DURATION) * 100.0)
		else:
			_hyperTime.visible = false
