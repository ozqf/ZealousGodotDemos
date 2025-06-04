extends Node

func hit(_hitInfo:HitInfo) -> int:
	return get_parent().hit(_hitInfo)
