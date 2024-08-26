extends Node

func look_up_rotation(tile):
	var rotations = []
	match tile :
		0:
			rotations = null
		17,18:
			rotations.append(0)
		16,17,18:
			rotations.append(90)
		16,17,18:
			rotations.append(180)
		15,16,17,18:
			rotations.append(270)
	
	return rotations
