extends Node

var current_dungeon = -1
var dungeon_levels = []
var first_scene = preload("res://scenes/places/main.tscn")
var death_screen = preload('res://scenes/UI/death_screen.tscn')

func _ready() -> void:
	dungeon_levels.append(load("res://scenes/places/dungeon_1.tscn"))

func load_next_dungeon():
	if len(dungeon_levels) - 1 > current_dungeon:
		current_dungeon += 1
		get_tree().change_scene_to_packed(dungeon_levels[current_dungeon]) 

func death():
	current_dungeon = -1
	get_tree().change_scene_to_packed(death_screen)

func main_scene():
	get_tree().change_scene_to_packed(first_scene)
