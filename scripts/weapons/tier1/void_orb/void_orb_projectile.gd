extends Projectile

var projectile_template = preload('res://scenes/weapons/projectile_template.tscn')
#var player
var projectile_2_angle: float
var projectile_2_stats: ProjectileStats

func _spawn_projectile(side):
	var temp_projectile = projectile_template.instantiate()
	$/root/Main.add_child(temp_projectile)
	temp_projectile.set_script(projectile_2_stats.projectile_script)
	temp_projectile.initialize(position, deg_to_rad((projectile_2_angle + rad_to_deg(rotation) + 90) + side), projectile_2_stats )

func die():
	_spawn_projectile(0)
	_spawn_projectile(180)
	queue_free()
