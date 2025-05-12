class_name Enemy
extends DamageTaker

@export var stats: EnemyStats
var projectile_template: PackedScene = preload('res://scenes/weapons/projectile_template.tscn')
var projectile_stats: ProjectileStats
var current_hp: int 
var max_hp: int 
var speed: float
var attack_cooldown_min: float
var attack_cooldown_max: float
var bullet_num: int
var equal_spread: float

var died := false
var room
var flipped := false
var can_turn := true
var can_see_player: bool

@onready var target = $"/root/Main/Player"
@onready var health_bar: ProgressBar = $HealthBar
@onready var agent: NavigationAgent2D = $"NavigationAgent2D"
@onready var shoot_cooldown: Timer = $"ShootCooldown"
@onready var flip_cooldown: Timer = $"FlipCooldown"
@onready var raycast_cooldown: Timer = $"RaycastCooldown"
@onready var update_path_cooldown: Timer = $"UpdatePathCooldown"
@onready var animator: AnimatedSprite2D = $"AnimatedSprite2D"
@onready var raycast := $"RayCast"
@onready var nav_area := $"../../"
#@onready var label := $"Label"
var item_drop : PackedScene = preload("res://scenes/UI/inventory/item_drop.tscn")

func _ready() -> void:
	set_stats(stats)
	raycast.shape = RectangleShape2D.new()
	raycast.shape.size = Vector2(10, 10)
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	room = get_node("../../../")
	agent.target_position = target.position

	shoot_cooldown.one_shot = true
	flip_cooldown.one_shot = true
	raycast_cooldown.one_shot = true
	update_path_cooldown.one_shot = true
	
	agent.avoidance_enabled = true 
	agent.radius = 60.0 
	agent.neighbor_distance = 1000.0  
	agent.max_neighbors = 5  

func _physics_process(_delta):
	_flip()
	_play_animations()
	_enemy_AI()

func set_stats(stats):
	projectile_stats = stats.projectile_stats
	max_hp = stats.max_health
	current_hp = stats.max_health
	attack_cooldown_min = stats.attack_cooldown_min
	attack_cooldown_max = stats.attack_cooldown_max
	speed = stats.speed
	bullet_num = stats.bullet_num
	equal_spread = stats.equal_spread
	
	_set_custom_stats(stats)

func _set_custom_stats(_stats):
	pass

func _set_projectile_stats_override(temp_projectile):
	pass

func take_damage(damage, is_critical):
	current_hp -= damage
	health_bar.value = current_hp
	_create_damage_pop_up(damage, is_critical)
	if current_hp <= 0 and not died:
		died = true
		drop()
		room.on_enemy_death()
		queue_free()

func drop() -> void:
	if not stats or not stats.loot_table:
		return
	var dropped_items = stats.loot_table.roll_loot()
	for item_stack in dropped_items:
		if item_stack and not item_stack.is_empty():
			var drop_instance = item_drop.instantiate()
			drop_instance.initialize(item_stack, global_position / 6)
			# Add to the current scene with proper layer
			get_tree().current_scene.call_deferred("add_child", drop_instance)

func _flip():
	if not flip_cooldown.is_stopped(): 
		return
	if not animator.flip_h and velocity.x < 0:
		animator.flip_h = true
		flipped = true
		can_turn = false
		flip_cooldown.start()
		return
	if animator.flip_h and velocity.x > 0:
		animator.flip_h = false
		flipped = false
		can_turn = false
		flip_cooldown.start()
		
func _play_animations():
	if animator.animation == "attack" and animator.is_playing():
		return
	if velocity.length() > 0.3:
		if animator.animation != "walk":
			animator.play("walk")
		return
	if animator.animation != "idle":
		animator.play("idle")

func _enemy_AI():
	pass

# State Actions 
func _follow_target(pos):
	if update_path_cooldown.is_stopped():
		agent.target_position = pos
		var direction = global_position.direction_to(agent.get_next_path_position())
		agent.set_velocity(direction * speed) 
		var adjusted_velocity = await agent.velocity_computed
		velocity = adjusted_velocity
		update_path_cooldown.start()
	move_and_slide()
	
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

func shoot():
	if shoot_cooldown.is_stopped():
		animator.play("attack")
		shoot_cooldown.wait_time = randf_range(attack_cooldown_min, attack_cooldown_max)
		shoot_cooldown.start()
		var angle = global_position.direction_to(target.global_position).angle()
		
		for i in range(bullet_num):
			var x: float = calculate_equal_spread_increment(bullet_num, i)
			angle = rad_to_deg(angle) + equal_spread * i * x
			angle = deg_to_rad(angle)
		
			var temp_projectile = projectile_template.instantiate()
			get_tree().root.get_node("Main").add_child(temp_projectile)
			temp_projectile.set_script(projectile_stats.projectile_script)
			temp_projectile.initialize(global_position / 6, angle, projectile_stats)

func _set_can_see_player():
	if not raycast_cooldown.is_stopped():
		return
	raycast.target_position = to_local(target.global_position)
	raycast.force_shapecast_update()
	if raycast.is_colliding():
		for i in raycast.get_collision_count():
			var collider = raycast.get_collider(i)
			if collider.name == "Obstacles" or collider.get_node("../").name == "RoomWalls":
				can_see_player = false
				raycast_cooldown.start()
				return
	can_see_player = true
	raycast_cooldown.start()

func is_point_in_navigation_area(point: Vector2) -> bool:
	var region_rid = nav_area.get_region_rid()
	var map_rid = NavigationServer2D.region_get_map(region_rid)
	var closest_point = NavigationServer2D.map_get_closest_point(map_rid, point)
	return closest_point.distance_to(point) < 1.0 
