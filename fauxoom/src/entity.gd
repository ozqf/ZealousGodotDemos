extends Node
class_name Entity

export var isStatic:bool = false
export var prefabName:String = ""
export var triggerTargetName:String = ""
var id:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(Groups.GAME_GROUP_NAME)
	add_to_group(Groups.ENTS_GROUP_NAME)
	var _r = connect("tree_entered", self, "_on_tree_entered")
	_r = connect("tree_exiting", self, "_on_exiting_tree")
	if isStatic:
		id = Ents.assign_static_id()
		add_to_group(Groups.STATIC_ENTS_GROUP_NAME)
	else:
		id = Ents.assign_dynamic_id()
		add_to_group(Groups.DYNAMIC_ENTS_GROUP_NAME)
	print("Ent " + get_parent().name + " id: " + str(id))

func on_trigger_entities(target:String) -> void:
	if target == "":
		return
	if get_parent().name == target:
		# trigger!
		pass

func _on_exiting_tree() -> void:
	# deregister entity...?
	pass

func write_state() -> Dictionary:
	# if this entity isn't static we must know what prefab to use
	# when restoring this entity!
	if !isStatic:
		assert(prefabName != "")
	return {
		prefab = prefabName,
		id = id,
		selfName = get_parent().name,
		triggerTargetName = triggerTargetName,
	}

func restore_state(data:Dictionary) -> void:
	assert(data)
	get_parent().name = data.selfName
	triggerTargetName = data.triggerTargetName
	id = data.id

func game_on_reset() -> void:
	# restore_state(_spawnState)
	pass
