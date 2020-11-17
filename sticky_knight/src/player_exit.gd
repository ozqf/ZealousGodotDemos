extends Area2D

func _ready():
	var _foo = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body):
	print("Player exit touched")
