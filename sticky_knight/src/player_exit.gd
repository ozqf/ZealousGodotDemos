extends Area2D

func _ready():
	var _foo = connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body):
	print("Player exit touched")
	get_tree().call_group("game", "on_player_finish", _body)
