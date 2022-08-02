extends Spatial
class_name ZqfTempChild

signal detached()

onready var m_subject: Spatial

var m_worldParent: Spatial = null
var m_attachParent: Spatial = null
var m_recallGlobalT: Transform

func _ready() -> void:
	set_subject(get_parent())

func set_subject(newSubject:Spatial) -> void:
	m_subject = newSubject
	m_worldParent = m_subject.get_parent() as Spatial

func attach(node: Spatial):
	if !ZqfUtils.is_obj_safe(node):
		return
	_on_attach_parent_removed()
	# attach to new parent
	m_attachParent = node
	var globalT = m_subject.get_global_transform()
	m_worldParent.remove_child(m_subject)
	m_attachParent.add_child(m_subject)
	m_subject.global_transform = globalT
	var _foo = m_attachParent.connect("tree_exiting", self, "_on_attach_parent_removed")

func detach() -> void:
	_on_attach_parent_removed()

func _on_attach_parent_removed():
	if m_attachParent == null:
		print("Temp child - has no parent to remove")
		return
	print("Temp child - parent removed")
	# return to previous parent
	# var globalT = m_recallGlobalT
	# var globalT = m_subject.global_transform
	m_attachParent.remove_child(m_subject)
	m_worldParent.add_child(m_subject)
	# m_subject.global_transform = globalT
	m_subject.global_transform = m_recallGlobalT
	m_attachParent.disconnect("tree_exiting", self, "_on_attach_parent_removed")
	m_attachParent = null
	self.emit_signal("detached")

func _physics_process(_delta:float) -> void:
	# record global transform for recall if attach parent dies
	# as on_exiting has already cleared transforms by the time we
	# hear about it
	m_recallGlobalT = m_subject.global_transform
