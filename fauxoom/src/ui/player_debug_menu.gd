extends Control

const Enums = preload("res://src/enums.gd")

onready var _godMode:Button = $HBoxContainer/cheats_container/god_mode
onready var _giveAll:Button = $HBoxContainer/cheats_container/give_all

onready var _deathray:Button = $HBoxContainer/laser_container/deathray
onready var _scanEnemy:Button = $HBoxContainer/laser_container/scan_enemy
onready var _atkTestColumn:Button = $HBoxContainer/laser_container/attack_test_column
onready var _atkTestSpikes:Button = $HBoxContainer/laser_container/attack_test_spikes

onready var _spawnPunk:Button = $HBoxContainer/spawns_container/punk
onready var _spawnWorm:Button = $HBoxContainer/spawns_container/worm
onready var _spawnSpider:Button = $HBoxContainer/spawns_container/spider
onready var _spawnGolem:Button = $HBoxContainer/spawns_container/golem
onready var _spawnTitan:Button = $HBoxContainer/spawns_container/titan
onready var _spawnGasSac:Button = $HBoxContainer/spawns_container/gas_sac

onready var _spawnMinorHp:Button = $HBoxContainer/items_container/minor_health
onready var _spawnMinorRage:Button = $HBoxContainer/items_container/minor_rage
onready var _spawnMinorBonus:Button = $HBoxContainer/items_container/minor_bonus

func _ready() -> void:
	visible = false
	add_to_group(Groups.PLAYER_GROUP_NAME)
	var _r
	_r = connect("tree_exiting", self, "_on_tree_exiting")
	
	_r = _godMode.connect("pressed", self, "_click_god_mode")
	_r = _giveAll.connect("pressed", self, "_click_give_all")
	
	_r = _deathray.connect("pressed", self, "_click_deathray")
	_r = _scanEnemy.connect("pressed", self, "_click_scan_enemy")
	_r = _atkTestColumn.connect("pressed", self, "_click_attack_test_column")
	_r = _atkTestSpikes.connect("pressed", self, "_click_attack_test_spikes")
	
	_r = _spawnPunk.connect("pressed", self, "_click_spawn_punk")
	_r = _spawnWorm.connect("pressed", self, "_click_spawn_worm")
	_r = _spawnSpider.connect("pressed", self, "_click_spawn_spider")
	_r = _spawnGolem.connect("pressed", self, "_click_spawn_golem")
	_r = _spawnTitan.connect("pressed", self, "_click_spawn_titan")
	_r = _spawnGasSac.connect("pressed", self, "_click_spawn_gas_sac")

	_r = _spawnMinorHp.connect("pressed", self, "_click_spawn_minor_health")
	_r = _spawnMinorRage.connect("pressed", self, "_click_spawn_minor_rage")
	_r = _spawnMinorBonus.connect("pressed", self, "_click_spawn_minor_bonus")

func _exec(txt:String) -> void:
	var tokens = ZqfUtils.tokenise(txt)
	get_tree().call_group("console", "console_on_exec", txt, tokens)

func _on_tree_exiting() -> void:
	player_close_debug_menu()
	
func player_toggle_debug_menu() -> void:
	if visible:
		player_close_debug_menu()
	else:
		player_open_debug_menu()

func player_open_debug_menu() -> void:
	print("Open debug menu")
	visible = true
	Game.debuggerOpen = true
	get_tree().call_group(MouseLock.GROUP_NAME, MouseLock.ADD_LOCK_FN, "debug_menu")

func player_close_debug_menu() -> void:
	print("Close debug menu")
	visible = false
	Game.debuggerOpen = false
	get_tree().call_group(MouseLock.GROUP_NAME, MouseLock.REMOVE_LOCK_FN, "debug_menu")

func _print_mode(mode, modeName) -> void:
	print("Set debugger mode " + str(mode) + ": " + modeName)

func _click_god_mode() -> void:
	_exec("god")
	pass

func _click_give_all() -> void:
	_exec("give all")

func _click_deathray() -> void:
	Game.debuggerMode = Enums.DebuggerMode.Deathray
	_print_mode(Game.debuggerMode, "Deathray")

func _click_scan_enemy() -> void:
	Game.debuggerMode = Enums.DebuggerMode.ScanEnemy
	_print_mode(Game.debuggerMode, "Scan enemy")

func _click_attack_test_column() -> void:
	Game.debuggerMode = Enums.DebuggerMode.AttackTest
	Game.debuggerAtkMode = "column"
	#_print_mode(Game.debuggerMode, "Attack Test")

func _click_attack_test_spikes() -> void:
	Game.debuggerMode = Enums.DebuggerMode.AttackTest
	Game.debuggerAtkMode = "spikes"
	#_print_mode(Game.debuggerMode, "Attack Test")
	
func _click_spawn_punk() -> void:
	Game.debuggerMode = Enums.DebuggerMode.SpawnPunk

func _click_spawn_worm() -> void:
	Game.debuggerMode = Enums.DebuggerMode.SpawnWorm

func _click_spawn_spider() -> void:
	Game.debuggerMode = Enums.DebuggerMode.SpawnSpider

func _click_spawn_golem() -> void:
	Game.debuggerMode = Enums.DebuggerMode.SpawnGolem

func _click_spawn_titan() -> void:
	Game.debuggerMode = Enums.DebuggerMode.SpawnTitan

func _click_spawn_gas_sac() -> void:
	Game.debuggerMode = Enums.DebuggerMode.SpawnGasSac

func _click_generic() -> void:
	pass

func _click_spawn_minor_health() -> void:
	Game.debuggerMode = Enums.DebuggerMode.ItemSpawnMinorHealth

func _click_spawn_minor_rage() -> void:
	Game.debuggerMode = Enums.DebuggerMode.ItemSpawnMinorRage

func _click_spawn_minor_bonus() -> void:
	Game.debuggerMode = Enums.DebuggerMode.ItemSpawnMinorBonus
