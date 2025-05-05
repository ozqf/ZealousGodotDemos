extends CharacterBody3D

const Enums = preload("res://src/enums.gd")

export(Enums.KeyType) var requiredKey = Enums.KeyType.None


func use_interactive(_user) -> String:
	print("Door - use!")
	return ""
