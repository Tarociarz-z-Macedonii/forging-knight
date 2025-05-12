class_name Projectile
extends Area2D

var stats: ProjectileStats
var sprite: Sprite2D
var angle
var speed: float
var spread: float 
var damage: float
var critical_chance: float 
var critical_chance_multiplier: float 
var rotate_sprite
var live_time 

var current_damage: float
var is_critical: bool
var timer: SceneTreeTimer

func _process(delta: float) -> void:
	_move(delta)


	
func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is DamageTaker:
		body.take_damage(current_damage, is_critical)
		queue_free()
		
func _on_body_entered(body: Node):
	if body.name == "Obstacles" or body.get_node("../").name == "RoomWalls":
		queue_free()  

func initialize(some_position, some_angle, some_stats):
	body_shape_entered.connect(_on_body_shape_entered)
	body_entered.connect(_on_body_entered)
	position = some_position
	angle = some_angle
	stats = some_stats
	_set_stats()
	var angle_offset: float = 0
	angle_offset = randf_range(-spread, spread)
	angle_offset = deg_to_rad(angle_offset)
	angle += angle_offset
	if rotate_sprite:	
		global_rotation = angle + deg_to_rad(45)
	else:
		global_rotation = angle + deg_to_rad(90)
	_critical_damage()
	timer = get_tree().create_timer(live_time)
	timer.timeout.connect(die)

func _set_stats():
	sprite = $"Sprite2D"
	sprite.texture = stats.sprite
	speed = stats.speed
	spread = stats.spread
	damage = stats.damage
	critical_chance = stats.critical_chance
	critical_chance_multiplier = stats.critical_chance_multiplier
	live_time = stats.live_time
	rotate_sprite = stats.rotate_sprite

func die():
	queue_free()
	
func _move(delta):
	var dir = Vector2(cos(angle), sin(angle))
	position += dir * speed * delta
	
func _critical_damage():
	var rand = randf_range(0, 1.0)
	if rand < critical_chance:
		current_damage = damage * critical_chance_multiplier
		is_critical = true
		return
	current_damage = damage 
	is_critical = false
