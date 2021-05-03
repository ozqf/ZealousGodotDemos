extends InvWeapon

func read_input(_primaryOn:bool, _secondaryOn:bool) -> void:
	if tick <= 0 && _primaryOn:
		tick = refireTime
		var t:Transform = _launchNode.global_transform
		for _i in range(0, 10):
			var spreadX:float = rand_range(-1500, 1500)
			var spreadY:float = rand_range(-400, 400)
			var forward:Vector3 = ZqfUtils.calc_forward_spread_from_basis(t.origin, t.basis, spreadX, spreadY)
			_fire_single(forward, 1000)
		.play_fire_1(false)
		self.emit_signal("weapon_action", self, "fire")

func _process(_delta:float) -> void:
	if tick > 0:
		tick -= _delta
