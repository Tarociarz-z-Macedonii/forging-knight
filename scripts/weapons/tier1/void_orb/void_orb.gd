extends Weapon
var projectile_2_angle
var projectile_2_stats
func _set_stats_override():
	projectile_2_angle = projectile_stats.projectile_2_angle
	projectile_2_stats = projectile_stats.projectile_2_stats
	
func _set_projectile_stats_override(temp_projectile):
	temp_projectile.projectile_2_angle = projectile_2_angle
	temp_projectile.projectile_2_stats = projectile_2_stats
