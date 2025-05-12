class_name WeaponStats
extends ItemStats

@export var weapon_script: Script
@export var cooldown: float = 0.5
@export var projectile_stats: ProjectileStats 
@export var bullet_number = 1
@export var auto_swing: bool = false 
@export var distance_from_player: float = 5

func is_stackable() -> bool:
	print("not stackable")
	return false
