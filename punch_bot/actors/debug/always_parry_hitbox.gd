extends Area3D

func hit(_incomingHit:HitInfo) -> int:
	return Game.HIT_RESPONSE_PARRIED
