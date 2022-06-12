extends Node

# left side - immediate status
onready var _healthCount:Label = $player_status/health/count
onready var _energyCount:Label = $player_status/energy/count
onready var _ammoCount:Label = $player_status/ammo/count
onready var _rageCount:Label = $player_status/rage/count
onready var _hyperTime:TextureProgress = $hyper_time
onready var _bg:ColorRect = $bg

onready var _healthLabel:Label = $player_status/health/Label
onready var _rageLabel:Label = $player_status/rage/Label

const PICKUP_GLOW_TIME:float = 1.0

var _healthGlowTick:float = 0.0
var _rageGlowTick:float = 0.0

func _ready() -> void:
	add_to_group(Groups.PLAYER_GROUP_NAME)

func player_got_item(itemType:String) -> void:
	if itemType == "rage":
		_rageGlowTick = PICKUP_GLOW_TIME
	elif itemType == "health":
		_healthGlowTick = PICKUP_GLOW_TIME
	pass
	if itemType == "pistol":
		Main.submit_console_command("flashy Dual Pistols")
	elif itemType == "super_shotgun":
		Main.submit_console_command("flashy Super Shotgun")
	elif itemType == "plasma_gun":
		Main.submit_console_command("flashy Plasma Gun")
	elif itemType == "rocket_launcher":
		Main.submit_console_command("flashy Rocket Launcher")
	elif itemType == "chainsaw":
		Main.submit_console_command("flashy Saw Blade")

func _process(_delta) -> void:
	_healthGlowTick -= _delta
	_rageGlowTick -= _delta
	if _healthGlowTick < 0.0:
		_healthGlowTick = 0.0
	if _rageGlowTick < 0.0:
		_rageGlowTick = 0.0
	
	var c = Color(1, 1, 1).linear_interpolate(Color(0, 0, 1), _healthGlowTick)
	_healthLabel.add_color_override("font_color", c)
	
	var c2 = Color(1, 1, 1).linear_interpolate(Color(0, 1, 0), _rageGlowTick)
	_rageLabel.add_color_override("font_color", c2)

func player_status_update(data:PlayerHudStatus) -> void:
	# counts
	_healthCount.text = str(data.health)
	if data.godMode:
		# _healthCount.text += " (INVUL)"
		_healthCount.add_color_override("font_color",  Color(0.5, 0.5, 0.5))
	elif data.health > 50:
		_healthCount.add_color_override("font_color",  Color(1, 1, 1))
	elif data.health > 25:
		_healthCount.add_color_override("font_color",  Color(1, 1, 0))
	else:
		_healthCount.add_color_override("font_color",  Color(1, 0, 0))
	
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
