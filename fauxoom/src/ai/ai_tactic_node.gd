extends Spatial

var info:Dictionary = {}

func _ready():
	info = {
		canSeePlayer = false,
		distToPlayer = 99999
	}

func _enter_tree() -> void:
	AI.register_tactic_node(self)

func _exit_tree() -> void:
	AI.deregister_tactic_node(self)
	# var aStar = AStar.new()
	# aStar.

func custom_update(_delta:float) -> void:
	var pos:Vector3 = global_transform.origin
	info.canSeePlayer = AI.check_los_to_player(pos)
	info.distToPlayer = AI.get_distance_to_player(pos)
