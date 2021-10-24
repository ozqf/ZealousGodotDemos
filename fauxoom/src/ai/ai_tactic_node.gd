extends Spatial
class_name AITacticNode

export var tag:int = 0
# Do not consider this node for cover
export var isVulnerable:bool = false
# This is a good node for ranged attacks
export var sniperSpot:bool = false

# set by manager when registered
var index:int = -1

var canSeePlayer:bool = false
var distToPlayer:float = 999999.0

var mobs = []
var mobProximityWeight:float = 0

var flags:int = -1

func _ready() -> void:
	var influence = $influence
	$influence.connect("body_entered", self, "on_body_entered")
	$influence.connect("body_exited", self, "on_body_exited")
	$influence.connect("area_entered", self, "on_area_entered")
	$influence.connect("area_exited", self, "on_area_exited")

func on_body_entered(body:Node) -> void:
	if body.has_method("is_mob"):
		mobs.push_back(body)

func on_body_exited(body:Node) -> void:
	if body.has_method("is_mob"):
		var i:int = mobs.find(body)
		if i != -1:
			mobs.remove(i)
		else:
			print("Mob left influence but wasn't in list!")

func on_area_entered(area:Area) -> void:
	pass

func on_area_exited(area:Area) -> void:
	pass
func _enter_tree() -> void:
	AI.register_tactic_node(self)

func _exit_tree() -> void:
	AI.deregister_tactic_node(self)
	# var aStar = AStar.new()
	# aStar.

func get_debug_string() -> String:
	var txt:String = str(index) + " flags: " + str(flags)
	txt += " mobs: " + str(mobs.size()) + " prox. weight: " + str(mobProximityWeight)
	txt += "\n"
	return txt

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

	# calculate mob proxity weight
	mobProximityWeight = 0
	for i in range(0, mobs.size()):
		var mobPos:Vector3 = mobs[i].global_transform.origin
		var dist:float = pos.distance_to(mobPos)
		if dist > 4:
			continue
		if dist < 0:
			dist = 0
		var ratio:float = dist / 4
		ratio = 1 - ratio
		mobProximityWeight += ratio
	mobProximityWeight *= 1000.0
	mobProximityWeight = round(mobProximityWeight)
