extends Node

var blueprints = {
	"tier1": []
}

func _ready() -> void:
	_load_rooms()
	
func pick_blueprint(level: int):
	match level:
		1:
			return blueprints["tier_1"].pick_random()

func _load_rooms():
	blueprints["tier_1"] = _load_room_group("res://resources/blueprints/tier_1/")

func _load_room_group(path: String) -> Array:
	var room_group = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tres"):
				room_group.append(load(path + file))
			file = dir.get_next()
	return room_group
