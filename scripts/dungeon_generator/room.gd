extends Node2D

var cords: Vector2i
var status: Enums.RoomStatus
var type: Enums.RoomType
var level: int
var interior: PackedScene
var interior_instance: Node2D

var wall_instance: Node2D
var is_left_open := false
var is_right_open := false
var is_top_open := false
var is_bottom_open := false 
var are_enemies_in_room = false
var enemy_count: int = 0

var block_left 
var block_right
var block_bottom
var block_top

var room_generator
var minimap_displayer

func _ready() -> void:
	room_generator = get_node("/root/Main/DungeonGenerator")
	minimap_displayer = room_generator.get_node("MinimapDisplayer")
	
func block_doors():
	block_left.enabled = is_left_open
	block_right.enabled = is_right_open
	block_bottom.enabled = is_bottom_open
	block_top.enabled = is_top_open

func unblock_doors():
	block_left.enabled = false
	block_right.enabled = false
	block_bottom.enabled = false
	block_top.enabled = false

func instantiate_interior():
	interior = DungeonDatabase.pick_interior(type, level)
	interior_instance = interior.instantiate()
	wall_instance = DungeonDatabase.walls.instantiate()
	add_child(interior_instance)
	add_child(wall_instance)
	
func make_corridors():
	wall_instance.get_node("WallLeftOpen").enabled = is_left_open
	wall_instance.get_node("WallLeftClose").enabled = !is_left_open
	wall_instance.get_node("WallRightOpen").enabled = is_right_open
	wall_instance.get_node("WallRightClose").enabled = !is_right_open
	wall_instance.get_node("WallTopOpen").enabled = is_top_open
	wall_instance.get_node("WallTopClose").enabled = !is_top_open
	wall_instance.get_node("WallBottomOpen").enabled = is_bottom_open
	wall_instance.get_node("WallBottomClose").enabled = !is_bottom_open
	
	block_left = wall_instance.get_node('BlockLeft')
	block_right = wall_instance.get_node('BlockRight')
	block_bottom = wall_instance.get_node('BlockBottom')
	block_top = wall_instance.get_node('BlockTop')

func on_hitbox_enter():
	if minimap_displayer.currnet_room_cords != cords:
		minimap_displayer.currnet_room_cords = cords
		if room_generator.rooms[cords].status == Enums.RoomStatus.UNEXPLORED:
			print('Entered First Time')
			_on_enemy_room_enter()
		minimap_displayer.on_room_change(cords)

func _on_enemy_room_enter():
	if type == Enums.RoomType.ENEMY or type == Enums.RoomType.BOSS:
		var enemies_layer: TileMapLayer = interior_instance.get_node("Enemies")
		enemies_layer.enabled = true
		enemy_count = len(enemies_layer.get_used_cells())
		are_enemies_in_room = true
		block_doors()
		
func on_enemy_death():
	enemy_count -= 1
	print(enemy_count)
	if enemy_count <= 0:
		unblock_doors()
		if type == Enums.RoomType.BOSS:
			interior_instance.get_node("Entrance").enabled = true
