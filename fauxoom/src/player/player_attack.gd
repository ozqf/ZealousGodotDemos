extends Node
class_name PlayerAttack

# var _launchNode:Spatial = null
# var _parentBody:PhysicsBody = null
# var _inventory:Inventory = null
var _interactor:PlayerObjectInteractor
var _inventory = null
var _active:bool = false
var _tick:float = 0
var _pendingSlot:int = -1

var _meleeTick:float = 0
var _meleeTime:float = 0.5

func init_attack(interactor:PlayerObjectInteractor, inventory) -> void:
	_interactor = interactor
	_inventory = inventory

func set_attack_enabled(flag:bool) -> void:
	_active = flag

func check_action_press_or_release(actionName:String) -> bool:
	# need to use is_action_just_released as it is the only
	# event fired from the mousewheel...
	# return (Input.is_action_just_pressed(actionName) || Input.is_action_just_released(actionName))
	return (Input.is_action_just_released(actionName))

func _process(_delta:float) -> void:
	if _active:
		if check_action_press_or_release("slot_1"):
			_pendingSlot = 1
		if check_action_press_or_release("slot_2"):
			_pendingSlot = 2
		if check_action_press_or_release("slot_3"):
			_pendingSlot = 3
		if check_action_press_or_release("slot_4"):
			_pendingSlot = 4
		if check_action_press_or_release("slot_5"):
			_pendingSlot = 5
		if check_action_press_or_release("slot_6"):
			_pendingSlot = 6
		if check_action_press_or_release("slot_7"):
			_pendingSlot = 7
		
		if _pendingSlot != -1:
			var result:int = _inventory.change_weapon_by_slot(_pendingSlot)
			if result != 0:
				_pendingSlot = -1
	
	var primary:bool = Input.is_action_pressed("attack_1")
	var secondary:bool = Input.is_action_pressed("attack_2")
	if !_active:
		primary = false
		secondary = false

	if _meleeTick > 0:
		primary = false
		secondary = false
		_meleeTick -= _delta
	elif Input.is_action_just_pressed("interact"):
		_meleeTick = _meleeTime
		_inventory.offhand.offhand_punch()
		_interactor.use_target()

	var weap:InvWeapon = _inventory.get_current_weapon()
	if weap != null:
		weap.read_input(primary, secondary)
