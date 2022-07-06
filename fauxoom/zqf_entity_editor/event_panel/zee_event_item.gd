extends Node

signal action(eventItem, action)

onready var _edit:Button = $event_edit
onready var _delete:Button = $event_delete

var eventDetails = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_edit.connect("pressed", self, "_on_edit")
	_delete.connect("pressed", self, "_on_delete")

func refresh(newEventDetails = null) -> void:
	if newEventDetails != null:
		eventDetails = newEventDetails
	_edit.text = eventDetails.get_event_name()

func _on_edit() -> void:
	self.emit_signal("action", self, "edit")

func _on_delete() -> void:
	self.emit_signal("action", self, "delete")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
