extends Node 

var tiles = []
var map_size = Vector2()
var roads = []
var road_size = Vector2()

var rotation = [0,90,180,270]

var number_of_vend1 = 100
var number_of_vend2 = 100
var number_of_vend3 = 100
var number_of_vend4 = 100
var offset = Vector2(1,1)
var no_offset = Vector2(4,2)
var number_of_shelves = 100

@export var machine1:PackedScene
@export var pallet:PackedScene
@export var shelves:PackedScene
@export var machine2:PackedScene


func generate_props(tile_list, size):
	tiles = tile_list
	map_size = size
	place_vending_machines(machine1, number_of_vend1, no_offset)
	place_vending_machines(shelves, number_of_shelves, no_offset)
	place_vending_machines(machine2, number_of_shelves, offset)
	place_roadblocks(pallet, number_of_vend1)

func generate_road(road, map_size):
	roads = road
	road_size = map_size




func random_tile(tile_count):
	var tile_list = tiles
	var selected_tiles = []
	tile_list.shuffle()
	for i in range(tile_count):
		var tile = tile_list[i]
		selected_tiles.append(tile)
	return selected_tiles
	


func place_vending_machines(type,amount,offset):
	var tile_list = random_tile(amount)
	for i in range(amount):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = rotation[randi() % rotation.size() -1]
			tile.y += tile.y + .75
			spawn_vending_machine(tile, tile_rotation,type,offset)
		tile_list.pop_front()


func place_roadblocks(type, amount):
	var tile_list = random_tile(amount)
	for i in range(amount):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = rotation[randi() % rotation.size() -1]
			tile.y += tile.y + .125
			
			spawn_roadblocks(tile, tile_rotation, type)
		tile_list.pop_front()


func place_shelves_():
	var tile_list = random_tile(number_of_shelves)
	for i in range(number_of_shelves):
		var tile = tile_list[0]
		var tile_type = get_parent().get_cell_item(tile)
		var allowed_rotations = $ObjectRotationCheck.look_up_rotation(tile_type)
		if not allowed_rotations == null:
			var tile_rotation = allowed_rotations[randi() % allowed_rotations.size() -1] * -1
			tile.y += tile.y + .75
			spawn_shelves(tile)
		tile_list.pop_front()

func spawn_vending_machine(tile, vending_machine_rotation, type, offset):
	var vending_machine1 = type.instantiate()
	vending_machine1.position = Vector3(((tile.x * 4) + offset.x),tile.y,((tile.z * 4) + offset.x))
	vending_machine1.rotation_degrees.y = vending_machine_rotation
	add_child(vending_machine1)


func spawn_roadblocks(tile, vending_machine_rotation, type):
	var vending_machine2 = type.instantiate()
	vending_machine2.position = Vector3(((tile.x * 4)),tile.y,((tile.z * 4) + 2))
	vending_machine2.rotation_degrees.y = vending_machine_rotation
	add_child(vending_machine2)


func spawn_vending_machine3(tile, vending_machine_rotation):
	var vending_machine3 = preload("res://Destructibles/small_destructible_machine.tscn").instantiate()
	var vending_machine4 = preload("res://Destructibles/small_destructible_machine.tscn").instantiate()
	vending_machine3.position = Vector3(((tile.x * 4) +2),tile.y,((tile.z * 4) + 4))
	vending_machine3.rotation_degrees.y = vending_machine_rotation
	add_child(vending_machine3)


func spawn_shelves(tile):
	var shelve = preload("res://Assets/LevelBuilding/Shelf1.tscn").instantiate()
	shelve.position = Vector3(((tile.x * 4) + 2),tile.y,((tile.z * 4) + 2))
	#vending_machine.rotation_degrees.y = vending_machine_rotation
	add_child(shelve)
