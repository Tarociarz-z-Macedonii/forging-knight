extends Node2D

@export var max_num_rooms: int = 20 #inclusive
@export var min_num_rooms: int  = 20 #inclusive
@export var chance_for_room: float  = 0.5 #0.5 = 50%
@export var max_neighbours: int  = 1 #inclusive
@export var room_level: int  = 1
@export var room_cell_width: int = 30
@export var room_cell_height: int = 22
@export var min_starting_cords := Vector2i(0,0)
@export var max_starting_cords := Vector2i(0,0)
@export var max_x_grid: int = 4 #inclusive
@export var min_x_grid: int = -4 #inclusive
@export var max_y_grid: int = 4 #inclusive
@export var min_y_grid: int = -4 #inclusive
@export var min_chest_room_num: int = 1 #inclusive
@export var max_chest_room_num: int = 1 #inclusive
@export var min_end_rooms: int = 2

var room = preload("res://scenes/dungeon_generator/room.tscn")
var rooms = {} 
var end_rooms = []
var cords_to_create_neighbours = []
var added_neighbours = 0
var finished_creating := false
var minimap_displayer
var room_width: int = room_cell_width * 16
var room_height: int =  room_cell_height * 16
var offset_x: int 
var offset_y: int 
var chest_room_num
var starting_cords: Vector2i

func _ready() -> void:
	minimap_displayer = get_node("MinimapDisplayer")
	starting_cords.x = randi_range(min_starting_cords.x, max_starting_cords.x)
	starting_cords.y = randi_range(min_starting_cords.y, max_starting_cords.y)
	minimap_displayer.last_current_cords = starting_cords
	minimap_displayer.currnet_room_cords = starting_cords
	offset_x = starting_cords.x * -room_width
	offset_y = starting_cords.y * -room_height
	position = Vector2(offset_x, offset_y)
	
	_create_room(starting_cords)
	cords_to_create_neighbours.append(starting_cords)

func _process(_delta: float) -> void:
	if len(cords_to_create_neighbours) > 0:
		var cords = cords_to_create_neighbours.pop_front()
		_try_to_add_to_neighbours(cords) 
		return
		
	if not finished_creating:
		_on_finished_creating()	

func _create_room(cords):
	var temp_room = room.instantiate()
	rooms[cords] = temp_room
	add_child(temp_room)

func _try_to_add_to_neighbours(cords):
	added_neighbours = 0
	if cords.x + 1 <= max_x_grid:
		_try_to_add_to_neighbour(Vector2i(cords.x + 1, cords.y ))
	if cords.x - 1 >= min_x_grid:
		_try_to_add_to_neighbour(Vector2i(cords.x - 1, cords.y ))
	if cords.y + 1 <= max_y_grid:
		_try_to_add_to_neighbour(Vector2i(cords.x, cords.y + 1))
	if cords.y - 1 >= min_y_grid:
		_try_to_add_to_neighbour(Vector2i(cords.x, cords.y - 1))
	if added_neighbours == 0:
		end_rooms.push_back(cords)

func _try_to_add_to_neighbour(cords):
	if (randf_range(0,1.0) < chance_for_room 
	and not is_room_existing(cords) 
	and _count_neighbours(cords) <= max_neighbours 
	and len(rooms) < max_num_rooms):
		cords_to_create_neighbours.push_back(cords)
		_create_room(cords)
		added_neighbours += 1

func is_room_existing(cords):
	for key in rooms:
		if cords == key:
			return true
	return false

func _count_neighbours(cords):
	var neighbours = 0
	if is_room_existing(Vector2i(cords.x, cords.y - 1)):
		neighbours += 1
	if is_room_existing(Vector2i(cords.x, cords.y + 1)):
		neighbours += 1
	if is_room_existing(Vector2i(cords.x - 1, cords.y )):
		neighbours += 1
	if is_room_existing(Vector2i(cords.x + 1, cords.y )):
		neighbours += 1
	return neighbours

func _on_finished_creating():
	if len(rooms) < min_num_rooms or len(end_rooms) < min_end_rooms:
		_restart()
		return
	finished_creating = true
	_assign_final_room_values()
	minimap_displayer.display_minimap(rooms)

func _restart():
	print("_restarted: " + str(len(rooms)))
	rooms.clear()
	end_rooms.clear()
	_create_room(starting_cords)
	cords_to_create_neighbours.append(starting_cords)
	
func _assign_final_room_values():
	print("Rooms: " + str(len(rooms)) + " EndRooms: " + str(len(end_rooms)))
	_assign_room_types()
	for key in rooms:
		rooms[key].cords = key
		rooms[key].status = Enums.RoomStatus.UNSEEN
		rooms[key].level = room_level
		rooms[key].position = Vector2i(key.x * room_width, key.y * room_height) 
		rooms[key].instantiate_interior()
		_assign_openings(key, rooms[key])
		rooms[key].make_corridors()

func _assign_room_types():
	for key in rooms:
		rooms[key].type = Enums.RoomType.ENEMY
		if key == starting_cords:
			rooms[key].type = Enums.RoomType.START
			
	rooms[end_rooms.pop_back()].type = Enums.RoomType.BOSS
	chest_room_num = randi_range(min_chest_room_num, max_chest_room_num)
	for i in range(chest_room_num):
		if len(end_rooms) > 0:
			var rand_index = randi_range(0, len(end_rooms) - 1)
			rooms[end_rooms[rand_index]].type = Enums.RoomType.CHEST
			end_rooms.remove_at(rand_index)

func _assign_openings(cords, temp_room):
	if is_room_existing(Vector2i(cords.x + 1, cords.y)):
		temp_room.is_right_open = true	
	if is_room_existing(Vector2i(cords.x - 1, cords.y )):
		temp_room.is_left_open = true
	if is_room_existing(Vector2i(cords.x, cords.y - 1)):
		temp_room.is_top_open = true
	if is_room_existing(Vector2i(cords.x, cords.y + 1)):
		temp_room.is_bottom_open = true
