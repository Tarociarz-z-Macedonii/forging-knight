extends Node

var id = 0
var items: Dictionary[int, Resource] = {}
var items_ids: Dictionary[String, int] = {}

func _ready() -> void:
	_load_room_group('res://resources/weapons/tier_1/')
	_load_room_group('res://resources/materials/')

func _load_room_group(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				id+=1
				items[id] = load(path + file)
				var file_name_without_tres = file.split(".")
				items_ids[file_name_without_tres[0]] = id
			file = dir.get_next()
