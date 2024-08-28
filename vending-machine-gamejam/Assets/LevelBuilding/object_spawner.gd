extends Node 

var tiles = []
var map_size = Vector2()

var number_of_vending_machines = 200

func generate_props(tile_list, size):
	tiles = tile_list
	map_size = size
	place_vending_machines()


func random_tile(tile_count):
	var tile_list = tiles
	var selected_tiles = []
	tile_list.shuffle()
	for i in range(tile_count):
		var tile = tile_list[i]
		selected_tiles.append(tile)
	return selected_tiles
	


func place_vending_machines():
	var tile_list = random_tile(number_of_vending_machines)
	for i in range(number_of_vending_machines):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = allowed_rotations[randi() % allowed_rotations.size() -1]
			tile.y += tile.y + .125
			
			spawn_vending_machine(tile, tile_rotation)
		tile_list.pop_front()


func spawn_vending_machine(tile, vending_machine_rotation):
	var vending_machine = preload("res://Assets/LevelBuilding/vending_machines.tscn").instantiate()
	vending_machine.position = Vector3((tile * 4))
	vending_machine.rotation_degrees.y = vending_machine_rotation
	add_child(vending_machine)
