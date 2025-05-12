extends Node2D

var minimap_offset_x 
var minimap_offset_y 

var icons = {}
var minimap_created = false
var last_current_cords: Vector2i
var currnet_room_cords: Vector2i

@onready var room_gen = $"../"
@onready var canvas = $"/root/Main/CanvasLayer"
@onready var player = $"/root/Main/Player"

func _ready() -> void:
	_set_minimap_panel()
	
func _set_minimap_panel():	
	var minimap_background = DungeonDatabase.minimap_background_packed.instantiate()
	canvas.add_child(minimap_background)
	var grid_width = abs(room_gen.max_x_grid - room_gen.min_x_grid) + 1
	var grid_height = abs(room_gen.max_y_grid - room_gen.min_y_grid) + 1
	minimap_background.size = Vector2(room_gen.room_cell_width * grid_width, room_gen.room_cell_height * grid_height)
	
func display_minimap(rooms):
	for key in rooms:
		var temp_icon = DungeonDatabase.room_icon.instantiate()
		canvas.add_child(temp_icon)
		temp_icon.get_child(0).texture = pick_icon(rooms[key].type)
		icons[key] = temp_icon
		temp_icon.position = Vector2((key.x - room_gen.min_x_grid) * room_gen.room_cell_width, (key.y - room_gen.min_y_grid) * room_gen.room_cell_height) 
		
	_update_room_types(room_gen.starting_cords)
	_update_room_icons()
	minimap_created = true
	
func pick_icon(type):
	match type:
		Enums.RoomType.CHEST:
			return DungeonDatabase.chest_icon
		Enums.RoomType.BOSS:
			return DungeonDatabase.skull_icon
		Enums.RoomType.ENEMY:
			return null

func on_room_change(current_cords):
	_update_room_types(current_cords)
	_update_room_icons()
	last_current_cords = current_cords

func _give_room_type_unexplored(cords):
	if room_gen.is_room_existing(cords):
		if room_gen.rooms[cords].status == Enums.RoomStatus.UNSEEN: 
			room_gen.rooms[cords].status = Enums.RoomStatus.UNEXPLORED

func _update_room_types(current_cords):
	_give_room_type_unexplored(Vector2i(current_cords.x - 1,current_cords.y))
	_give_room_type_unexplored(Vector2i(current_cords.x + 1,current_cords.y))
	_give_room_type_unexplored(Vector2i(current_cords.x,current_cords.y - 1))
	_give_room_type_unexplored(Vector2i(current_cords.x,current_cords.y + 1))
	room_gen.rooms[last_current_cords].status = Enums.RoomStatus.EXPLORED
	room_gen.rooms[current_cords].status = Enums.RoomStatus.CURRENT

func _update_room_icons():
	for key in room_gen.rooms:
		if room_gen.rooms[key].status == Enums.RoomStatus.UNSEEN:
			icons[key].visible = false
		else:
			icons[key].visible = true
		if room_gen.rooms[key].status == Enums.RoomStatus.UNEXPLORED:
			icons[key].texture = DungeonDatabase.unexplored_icon
		if room_gen.rooms[key].status == Enums.RoomStatus.EXPLORED:
			icons[key].texture = DungeonDatabase.explored_icon
		if room_gen.rooms[key].status == Enums.RoomStatus.CURRENT:
			icons[key].texture = DungeonDatabase.current_icon
