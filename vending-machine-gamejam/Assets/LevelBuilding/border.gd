extends Node3D

func resize_border(tile_size, tile_count):
	pass


func make_border(tile_size, tile_count):
	var wall_size = tile_size * tile_count
	$N_wall.position = Vector3(wall_size/2, $N_wall.size.y/2, -1)
	$S_wall.position = Vector3(wall_size/2, $S_wall.size.y/2, wall_size + 1)
	$W_wall.position = Vector3(-1, $W_wall.size.y/2, wall_size/2)
	$E_wall.position = Vector3(wall_size + 1, $E_wall.size.y/2, wall_size/2)
	$W_wall.rotate_y(1.5708) # rotates 90
	$E_wall.rotate_y(1.5708) # rotates 90
	for child in get_children():
		child.width = wall_size + 2 
		child.use_collision = true
