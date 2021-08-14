extends KinematicBody

func hit(_hitInfo:HitInfo) -> int:
	return Interactions.HIT_RESPONSE_PENETRATE
