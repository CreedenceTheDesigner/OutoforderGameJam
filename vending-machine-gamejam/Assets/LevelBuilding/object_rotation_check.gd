extends Node

func look_up_rotation(tile):
	var rotations = []
	match tile :
		0:
			rotations = null
		15:
			rotations.append(0)
		15:
			rotations.append(90)
		15:
			rotations.append(180)
		15:
			rotations.append(270)
	
	return rotations
