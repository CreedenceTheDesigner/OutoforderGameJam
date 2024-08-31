extends Node 

var tiles = []
var map_size = Vector2()
var roads = []
var road_size = Vector2()

var rotation = [0,90,180,270]

@export var number_of_vend1 = 50
@export var number_of_vend2 = 50
@export var number_of_vend3 = 50
@export var number_of_vend4 = 20
@export var number_of_shelves = 150
@export var number_of_block = 50


var offset1 = Vector2(1,1)
var offset2 =Vector2(3,3)
var offset3 =Vector2(2,0)
var no_offset = Vector2(4,2)

@export var machine1:PackedScene
@export var pallet:PackedScene
@export var shelves:PackedScene
@export var machine2:PackedScene
@export var barricade:PackedScene
@export var cones:PackedScene
@export var machine3:PackedScene
@export var machine4:PackedScene

func generate_props(tile_list, size):
	tiles = tile_list
	map_size = size
	place_vending_machines(machine1, number_of_vend1, no_offset)
	place_shelves(shelves,number_of_shelves, offset3)
	place_vending_machines(machine2, number_of_shelves, offset1)
	place_vending_machines(cones, number_of_vend1,offset2)
	place_vending_machines(machine3,number_of_vend3,offset2)
	place_vending_machines(machine4,number_of_vend4, offset3)

func generate_road(roaded, map_size):
	roads = roaded
	road_size = map_size
	place_roadblocks(pallet, number_of_block, offset1)
	place_roadblocks(barricade,number_of_block, offset3)
	place_roadblocks(cones,number_of_block,offset2)
	




func random_tile(tile_count):
	var tile_list = tiles
	var selected_tiles = []
	tile_list.shuffle()
	for i in range(tile_count):
		var tile = tile_list[i]
		selected_tiles.append(tile)
	return selected_tiles
	
func random_road_list(road_count):
	var tile_list = roads
	var selected_roads = []
	tile_list.shuffle()
	for i in range(road_count):
		var road = tile_list[i]
		selected_roads.append(road)
	return selected_roads

func place_vending_machines(type,amount,offset):
	var tile_list = random_tile(amount)
	for i in range(amount):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = rotation[randi() % rotation.size() -1]
			tile.y += tile.y + .5
			spawn_vending_machine(tile, tile_rotation,type,offset)
		tile_list.pop_front()


func place_roadblocks(type, amount,roffset):
	var road_list = random_road_list(amount)
	for i in range(amount):
		var roads = road_list[0]
		var tile_type = get_parent().get_cell_item(roads)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = rotation[randi() % rotation.size() -1]
			roads.y += roads.y + .5
			
			spawn_roadblocks(roads, tile_rotation, type, roffset)
		road_list.pop_front()


func place_shelves(type,amount,offset):
	var tile_list = random_tile(amount)
	for i in range(amount):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = rotation[randi() % rotation.size() -1]
			tile.y += tile.y + .6
			spawn_Shelves(tile, tile_rotation,type,offset)
		tile_list.pop_front()

func spawn_vending_machine(tile, vending_machine_rotation, type, offset):
	var vending_machine1 = type.instantiate()
	vending_machine1.position = Vector3(((tile.x * 4) + offset.x),tile.y,((tile.z * 4) + offset.x))
	vending_machine1.rotation_degrees.y = vending_machine_rotation
	add_child(vending_machine1)


func spawn_roadblocks(tiles, vending_machine_rotation, type, roffset):
	var vending_machine2 = type.instantiate()
	vending_machine2.position = Vector3(((tiles.x * 4) + roffset.x),tiles.y,((tiles.z * 4) + roffset.x))
	vending_machine2.rotation_degrees.y = vending_machine_rotation
	add_child(vending_machine2)

func spawn_Shelves(tiles, vending_machine_rotation, type, roffset):
	var vending_machine2 = type.instantiate()
	vending_machine2.position = Vector3(((tiles.x * 4) + roffset.x),tiles.y,((tiles.z * 4) + roffset.x))
	add_child(vending_machine2)
