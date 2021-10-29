extends Node

export var triggerName:String = ""
export var triggerTargetName:String = ""
export var durationSeconds:int = 180

onready var _ent:Entity = $Entity


# Game.show_hint_text(hintMessage)


# Called when the node enters the scene tree for the first time.
func _ready():
	var _result = _ent.connect("entity_trigger", self, "on_trigger")
	_ent.selfName = triggerName
	_ent.triggerTargetName = triggerTargetName

func on_trigger() -> void:
	var minutes:int = int(floor(float(durationSeconds) / float(60)))
	var seconds:int = durationSeconds % 60
	Game.show_hint_text("DEADLINE START: " + str(minutes) + ":" + str(seconds))
