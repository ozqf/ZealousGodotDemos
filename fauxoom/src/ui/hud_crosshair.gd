extends Node

# crosshair
onready var _prompt:Label = $interact_prompt
onready var _promptBG:ColorRect = $interact_prompt_bg
onready var _energyBar:TextureProgress = $energy
onready var _healthBar:TextureProgress = $health
onready var _redDot:ColorRect = $red_dot
onready var _weaponCharge:ProgressBar = $weapon_charge_bar
onready var _targetHealth:TextureProgress = $target_health
onready var _walldashIndicator:Control = $walldash_indicator
onready var _hyperTime:Label = $hyper_time/Label

var _maxHealthColour:Color = Color(0, 1, 0, 1)
var _minHealthColour:Color = Color(1, 0, 0, 1)

func player_status_update(data:PlayerHudStatus) -> void:

	_prompt.visible = data.hasInteractionTarget
	_promptBG.visible = data.hasInteractionTarget
	
	if data.targetHealth > 0.0:
		_targetHealth.value = data.targetHealth
		_targetHealth.visible = true
		if data.targetInvulnerable:
			_targetHealth.modulate = Color(0.25, 0.25, 0.25)
		elif !data.targetVulnerable:
			_targetHealth.modulate = Color(1, 1, 1)
		else:
			_targetHealth.modulate = Color(1, 0, 0)
	else:
		_targetHealth.visible = false
	
	_walldashIndicator.visible = data.isNearWall
	
	# weapon charge metre
	if data.weaponChargeMode == 1:
		_weaponCharge.visible = true
		_weaponCharge.value = data.currentAmmo
	else:
		_weaponCharge.visible = false
	
	if data.hyperLevel > 0:
		# meh doesn't give specific decimals when trailing 0000s
		#_hyperTime.text = str(stepify(data.hyperSecondsRemaining, 0.01))
		_hyperTime.text = str(floor(data.hyperSecondsRemaining))
		_hyperTime.visible = true
	else:
		_hyperTime.visible = false

	# crosshair
	var c:Color = Color(1, 1, 1, 1)
	var t:float = float(data.health) / 100.0
	c.r = _minHealthColour.r + (_maxHealthColour.r - _minHealthColour.r) * t
	c.g = _minHealthColour.g + (_maxHealthColour.g - _minHealthColour.g) * t
	c.b = _minHealthColour.b + (_maxHealthColour.b - _minHealthColour.b) * t
	_redDot.color = c
	_energyBar.value = data.energy
	_energyBar.visible = (_energyBar.value < 100)
	
	# show rage instead of health
	_healthBar.value = data.rage
	_healthBar.visible = (_healthBar.value < 100)
	#_healthBar.value = data.health
	#_healthBar.visible = (_healthBar.value < 100)
