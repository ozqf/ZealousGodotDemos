extends Spatial

# Do not consider this node for cover
export var isVulnerable:bool = false
# This is a good node for ranged attacks
export var sniperSpot:bool = false

# set by manager when registered
var index:int = -1

var canSeePlayer:bool = false
var distToPlayer:float = 999999.0

var flags:int = -1

func _ready() -> void:
	$influence/CollisionShape.connect("body_entered", self, "on_body_entered")
	$influence/CollisionShape.connect("body_exited", self, "on_body_exited")

func on_body_entered() -> void:
	pass

func on_body_exited() -> void:
	pass
	
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
	
	var newFlags:int = 0
	if canSeePlayer:
		newFlags |= AI.CAN_SEE_PLAYER_FLAG
	else:
		newFlags |= AI.CANNOT_SEE_PLAYER_FLAG
	if sniperSpot:
		newFlags |= AI.SNIPER_FLAG
	if isVulnerable:
		newFlags |= AI.VULNERABLE_FLAG
	
	flags = newFlags
