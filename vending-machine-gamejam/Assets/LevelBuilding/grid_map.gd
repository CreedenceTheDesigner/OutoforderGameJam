extends GridMap

const N = 1
const E = 2
const S = 4
const W = 8

@export var width = 24
@export var height = 24
@export var spacing = 2

@export var erase_fraction = 0.25




var cell_walls = {Vector3(0,0,spacing) : N, Vector3(-spacing,0,0) : E,
		Vector3(0,0,-spacing) : S, Vector3(spacing,0,0) : W}

func _ready():
	randomize()
	clear()
	make_map_border()
	make_map()
	record_tile_positions()
	erase_walls()


func make_map_border():
	$Border.make_border(cell_size.x, width)

func make_blank_map():
	for x in width:
		for z in height:
			var building = pick_building()
			var cell_position = Vector3(x,0,z)
			var cell = randi() % 15
			set_cell_item(cell_position, building , 0)


func pick_building():
	var possible_buildings = [15, 16, 17, 18]
	var building = possible_buildings[randi() % possible_buildings.size() -1]
	return building
	

func make_map():
	make_blank_map()
	make_maze()
	erase_walls()
	

func make_maze():
	var unvisited = []
	var stack = []
	
	for x in range(0,width,spacing):
		for z in range(0, height, spacing):
			unvisited.append( Vector3(x,0,z) )
	
	var current = Vector3(0,0,0)
	unvisited.erase(current)
	
	while unvisited:
		var surrounding = check_surroundings(current, unvisited)
		
		if surrounding.size() > 0:
			stack.append(current)
			
			var next = surrounding[randi() % surrounding.size()]
			var dir = next - current
			
			var current_path = min(get_cell_item(current), 15) - cell_walls[dir]
			var next_path = min(get_cell_item(next), 15) - cell_walls[-dir]
			
			set_cell_item(current, current_path, 0)
			set_cell_item(next, next_path, 0)
			fill_gaps(current, dir)
			
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()


func check_surroundings(cell, unvisited):
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell+n)
	return list


func fill_gaps(current, dir):
	var tile_type
	for i in range(1, spacing):
		if dir.x > 0:
			tile_type = 5
			current.x += 1
		elif dir.x < 0:
			tile_type = 5
			current.x -= 1
		elif dir.z > 0:
			tile_type = 10
			current.z += 1
		elif dir.z < 0:
			tile_type = 10
			current.z -= 1
		set_cell_item(current,tile_type,0)


func erase_walls():
	for i in range(width * height * erase_fraction):
		var x = int(randf_range(1, (width - 1)/spacing) )  * spacing
		var z = int(randf_range (1, (height - 1)/spacing) )  * spacing
		var cell = Vector3(x, 0, z)
		var current_cell = get_cell_item(cell)
		var neighbor = cell_walls.keys()[randi() % cell_walls.size()]
		
		if current_cell & cell_walls[neighbor]:
			var walls = current_cell - cell_walls[neighbor]
			walls = clamp(walls, 0, 15)
			var neighbor_walls_vector = Vector3(cell.x + neighbor.x, 0, cell.z + neighbor.z)
			var neighbor_walls = get_cell_item(neighbor_walls_vector) - cell_walls[-neighbor]
			neighbor_walls = clamp(neighbor_walls, 0, 15)
			set_cell_item(cell,walls, 0)
			set_cell_item(neighbor_walls_vector, neighbor_walls, 0)
			fill_gaps(cell,neighbor)


func record_tile_positions():
	var tiles = []
	for x in range(0, width):
		for z in range(0, height):
			var current_cell = Vector3(x, 0, z)
			var current_tile_type = get_cell_item(current_cell)
			if current_tile_type > 15:
				tiles.append(current_cell)
	var map_size = Vector2(width, height)
	$ObjectSpawner.generate_props(tiles, map_size)
