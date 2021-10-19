extends Spatial

# Do not consider this node for cover
export var isVulnerable:bool = false
# This is a good node for ranged attacks
export var sniperSpot:bool = false

var canSeePlayer:bool = false
var distToPlayer:float = 999999.0

func _enter_tree() -> void:
	AI.register_tactic_node(self)

func _exit_tree() -> void:
	AI.deregister_tactic_node(self)
	# var aStar = AStar.new()
	# aStar.

func custom_update(_delta:float) -> void:
	var pos:Vector3 = global_transform.origin
	canSeePlayer = AI.check_los_to_player(pos)
	distToPlayer = AI.get_distance_to_player(pos)
