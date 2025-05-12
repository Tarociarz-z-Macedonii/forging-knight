extends DamageTaker

@export var stats: EnemyStats

var item_drop : PackedScene = preload("res://scenes/UI/inventory/item_drop.tscn")

@onready var dps_label = $Dps
var damage_history = []
var dps_damage_time = 2.0

func _on_animated_sprite_2d_animation_looped() -> void:
	$AnimatedSprite2D.stop()

func _add_to_damage_history(damage):
	var now = Time.get_ticks_msec() 
	damage_history.append({"time": now, "damage": damage})

func _calculate_dps():
	if len(damage_history) > 0:
		var total_damage = 0
		for entry in damage_history:
			total_damage += entry["damage"]
		var dps = total_damage/dps_damage_time
		dps = snapped(dps, 0.01)
		dps_label.text = "Dps: " +  str(dps)
		return
	dps_label.text = "" 

func _remove_old_damage_history():
	var now = Time.get_ticks_msec() 
	while damage_history.size() > 0 and (now - damage_history[0]["time"]) > dps_damage_time * 1000: #Remove Old entries
		damage_history.pop_front()
		
func _process(_delta: float) -> void:
	_remove_old_damage_history()
	_calculate_dps()

func _create_damage_pop_up(damage, is_critical):
	var temp_pop_up = pop_up.instantiate()
	temp_pop_up.position =  Vector2(0,-25)
	var pop_up_node = temp_pop_up.get_child(0)
	pop_up_node.text = str(damage)
	if is_critical:
		pop_up_node.add_theme_color_override("font_color", Color(1, 0, 0))
	add_child(temp_pop_up)

func take_damage(damage, is_critical):
	$AnimatedSprite2D.play('hit')
	_add_to_damage_history(damage)
	_create_damage_pop_up(damage, is_critical)
	drop()
	
func drop() -> void:
	if not stats or not stats.loot_table:
		return
		
	var dropped_items = stats.loot_table.roll_loot()
	for item_stack in dropped_items:
		if item_stack and not item_stack.is_empty():
			var drop_instance = item_drop.instantiate()
			drop_instance.initialize(item_stack, position)
			# Add to the current scene with proper layer
			get_tree().current_scene.call_deferred("add_child", drop_instance)

#func _on_body_entered(body: Node2D) -> void:
	#body.take_damage(10,false)
