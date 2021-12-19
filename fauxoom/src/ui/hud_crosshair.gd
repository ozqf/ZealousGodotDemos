extends Node

# crosshair
onready var _prompt:Label = $interact_prompt
onready var _promptBG:ColorRect = $interact_prompt_bg
onready var _energyBar:TextureProgress = $energy
onready var _healthBar:TextureProgress = $health
onready var _redDot:ColorRect = $red_dot
onready var _weaponCharge:ProgressBar = $weapon_charge_bar

var _maxHealthColour:Color = Color(0, 1, 0, 1)
var _minHealthColour:Color = Color(1, 0, 0, 1)

func player_status_update(data:PlayerHudStatus) -> void:

	_prompt.visible = data.hasInteractionTarget
	_promptBG.visible = data.hasInteractionTarget

	# weapon charge metre
	if data.weaponChargeMode == 1:
		_weaponCharge.visible = true
		_weaponCharge.value = data.currentAmmo
	else:
		_weaponCharge.visible = false

	# crosshair
	var c:Color = Color(1, 1, 1, 1)
	var t:float = float(data.health) / 100.0
	c.r = _minHealthColour.r + (_maxHealthColour.r - _minHealthColour.r) * t
	c.g = _minHealthColour.g + (_maxHealthColour.g - _minHealthColour.g) * t
	c.b = _minHealthColour.b + (_maxHealthColour.b - _minHealthColour.b) * t
	_redDot.color = c
	_energyBar.value = data.energy
	_energyBar.visible = (_energyBar.value < 100)
	
	_healthBar.value = data.health
	_healthBar.visible = (_healthBar.value < 100)
