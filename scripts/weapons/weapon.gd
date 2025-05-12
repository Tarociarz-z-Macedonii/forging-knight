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

func _perform_attack():
	var temp_projectile = projectile_template.instantiate()
	get_tree().root.get_node("Main").add_child(temp_projectile)
	temp_projectile.set_script(projectile_stats.projectile_script)
	_set_projectile_stats_override(temp_projectile)
	temp_projectile.initialize(weapon_manager.global_position / 6, weapon_manager.angle, projectile_stats)
