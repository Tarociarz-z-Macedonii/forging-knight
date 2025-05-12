extends Node2D

var current_weapon

var distance_from_player: float = 45
var firstScale: float 
var angle: float

var weapon_template = preload("res://scenes/weapons/weapon_template.tscn")

func equip_weapon(weapon_stats):
	if weapon_stats == null:
		if current_weapon != null:
			current_weapon.queue_free()		
		return
	if current_weapon != null:
		current_weapon.queue_free()
	current_weapon = weapon_template.instantiate()
	current_weapon.set_script(weapon_stats.weapon_script)
	current_weapon.stats = weapon_stats
	distance_from_player = weapon_stats.distance_from_player
	add_child(current_weapon)
	firstScale = current_weapon.scale.x

func _flip_weapon():
	var mousePos = get_global_mouse_position()
	if mousePos.x < global_position.x and current_weapon.scale.x > 0:
		current_weapon.scale.y = -firstScale
	if mousePos.x > global_position.x:
		current_weapon.scale.y = firstScale

func _set_weapon_pos():
	var mousePos = get_global_mouse_position()
	var dir = mousePos - global_position
	angle = dir.angle()
	current_weapon.global_rotation = angle
	current_weapon.position = Vector2( cos(angle) * distance_from_player, sin(angle) * distance_from_player)

func _attack():
	if Input.is_action_pressed("Attack") and current_weapon.auto_swing:
		current_weapon.attack()
		return
	if Input.is_action_just_pressed("Attack"):
		current_weapon.attack()
			
func _process(_delta: float) -> void:
	if current_weapon != null:
		_attack()
		_set_weapon_pos()
		_flip_weapon()
