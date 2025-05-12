extends Node2D

var room_icon = preload('res://scenes/dungeon_generator/minimap_cell.tscn')
var current_icon = preload('res://sprites/dungeon_generator/current.png')
var explored_icon = preload('res://sprites/dungeon_generator/explored.png')
var unexplored_icon = preload('res://sprites/dungeon_generator/unexplored.png')
var chest_icon = preload("res://sprites/dungeon_generator/chest.png")
var skull_icon = preload("res://sprites/dungeon_generator/skull.png")
var minimap_background_packed = preload('res://scenes/dungeon_generator/minimap_background.tscn')
var walls: PackedScene = preload("res://scenes/dungeon_generator/room_walls.tscn")

var rooms = {
	"starter": preload('res://scenes/dungeon_generator/rooms/chests/tier_1/scratches.tscn'),
	"enemies": { "tier_1": [] },
	"chests":  { "tier_1": [] },
	"bosses":  { "tier_1": [] }
}

func _ready() -> void:
	load_rooms()

func pick_interior(type, level):
	match type:
		Enums.RoomType.START:
			return rooms["starter"]
		Enums.RoomType.ENEMY:
			match level:
				1:
					return rooms["enemies"]["tier_1"].pick_random()
		Enums.RoomType.CHEST:
			match level:
				1:
					return rooms["chests"]["tier_1"].pick_random()
		Enums.RoomType.BOSS:
			match level:
				1:
					return rooms["bosses"]["tier_1"].pick_random()

func load_rooms():
	# Starter rooms
	rooms["bosses"]["tier_1"] = _load_room_group("res://scenes/dungeon_generator/rooms/bosses/tier_1/")
	rooms["chests"]["tier_1"] = _load_room_group("res://scenes/dungeon_generator/rooms/chests/tier_1/")
	rooms["enemies"]["tier_1"] = _load_room_group("res://scenes/dungeon_generator/rooms/enemies/tier_1/")

func _load_room_group(path: String) -> Array:
	var room_group = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tscn"):
				room_group.append(load(path + file))
			file = dir.get_next()
	return room_group
