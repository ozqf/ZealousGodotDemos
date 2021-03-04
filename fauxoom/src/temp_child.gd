extends Node

# todo set via injection
onready var m_worldBody: Area # = $vs_world_body

var m_worldParent: Node = null
var m_attachParent: Node = null
var m_recallGlobalT: Transform

func stick_to_node(node: Node):
	# save world parent if it hasn't been already
	if m_worldParent == null:
		m_worldParent = get_parent()
	# attach to new parent
	m_attachParent = node
	var globalT = m_worldBody.get_global_transform()
	get_parent().remove_child(self)
	m_attachParent.add_child(self)
	m_worldBody.global_transform = globalT
	var _foo = m_attachParent.connect("tree_exiting", self, "on_attach_parent_removed")
	# print("Disc attached to " + m_attachParent.name)
	#var _foo = self.connect("tree_exiting", self, "_on_attach_parent_removed")


func on_attach_parent_removed():
	if m_attachParent == null:
		# automatic recall might cancel attach
		return
	# return to previous parent
	# print("Disc saw parent '" + m_attachParent.name + "' exiting tree: " + str(m_attachParent.is_inside_tree()))
	# print("World body in tree? " + str(m_worldBody.is_inside_tree()))
	#var globalT = m_worldBody.get_global_transform() # errors... sigh
	var globalT = m_recallGlobalT
	get_parent().remove_child(self)
	m_worldParent.add_child(self)
	m_worldBody.global_transform = globalT
	m_attachParent.disconnect("tree_exiting", self, "_on_attach_parent_removed")
	#self.disconnect("tree_exiting", self, "_on_attach_parent_removed")
	m_attachParent = null

func custom_physics_process(_delta:float) -> void:
	# record global transform for recall if attach parent dies
	m_recallGlobalT = m_worldBody.get_global_transform()
