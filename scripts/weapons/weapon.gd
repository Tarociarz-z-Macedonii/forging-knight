class_name Weapon
extends Node2D

@export var stats: WeaponStats
@export var projectile_stats: ProjectileStats
var item_name: String
var description: String 
var sprite: Texture2D
var cooldown: float 
var bullet_number: int
var auto_swing: bool 
var equal_spread: float
#Private
var projectile_template = load('res://scenes/weapons/projectile_template.tscn')
var weapon_manager
var timer: Timer
var can_attack: bool = true
	
func set_stats():
	sprite = stats.sprite
	$Sprite2D.texture = sprite
	item_name = stats.item_name
	description = stats.description
	cooldown = stats.cooldown
	bullet_number = stats.bullet_number
	auto_swing = stats.auto_swing
	projectile_stats = stats.projectile_stats
	equal_spread = stats.equal_spread
	_set_stats_override()
	
func _set_stats_override():
	pass
	
func _set_projectile_stats_override(temp_projectile):
	pass
	
func _set_references():
	weapon_manager = $"../"
	timer = weapon_manager.get_node('Timer')
	
func _ready() -> void:
	_set_references()
	set_stats()

func attack():
	if can_attack:
		for i in range(bullet_number):
			_perform_attack()
		can_attack = false
		
		timer.wait_time = cooldown
		timer.start()
		await(timer.timeout)
		
		can_attack = true

func calculate_equal_spread_increment(bullet_num, i):
	var x: float = 0
	if bullet_num % 2 == 0:
		if i % 2 == 0:
			x = 1
		else:
			x = -1
	else:
		if i == 0:
			x = 0
		elif not(i % 2) == 0:
			x = 1
		else:
			x = -1
	if abs(x) == 1 and bullet_num % 2 == 0:
		x /= 2
	return x

func _perform_attack():
	for i in range(bullet_number):	
		var x: float = calculate_equal_spread_increment(bullet_number, i)
		var angle: float 
		angle = rad_to_deg(angle) + equal_spread * i * x
		angle = deg_to_rad(angle)
		var temp_projectile = projectile_template.instantiate()
		get_tree().root.get_node("Main").add_child(temp_projectile)
		temp_projectile.set_script(projectile_stats.projectile_script)
		_set_projectile_stats_override(temp_projectile)
		temp_projectile.initialize(weapon_manager.global_position / 6, weapon_manager.angle, projectile_stats)
