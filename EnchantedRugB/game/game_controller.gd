extends Node

#@onready var _loadTimer:Timer = $load_timer
var _sandboxWorld = preload("res://worlds/sandbox/sandbox.tscn")

func _ready():
#	_loadTimer.connect("timeout", _on_load_timeout)
#	_loadTimer.wait_time = 2.0
#	_loadTimer.one_shot = true
#	_loadTimer.start()
	call_deferred("_app_init")

func _on_load_timeout() -> void:
	_app_init()

func _app_init() -> void:
	var world = _sandboxWorld.instantiate()
	Zqf.get_world_root().add_child(world)
	var proxies = get_tree().get_nodes_in_group(Zqf.GROUP_NAME_ACTOR_PROXIES)
	for proxy in proxies:
		print("Found actor proxy: " + proxy.name)
		if proxy.has_method("spawn"):
			proxy.spawn()
	pass
