class_name DamageTaker
extends CharacterBody2D

var pop_up: PackedScene = preload("res://scenes/UI/damage_pop_up.tscn")

func _create_damage_pop_up(damage, is_critical):
	var temp_pop_up = pop_up.instantiate()
	temp_pop_up.position = Vector2(0,-25)
	var pop_up_node = temp_pop_up.get_child(0)
	pop_up_node.text = str(damage)
	if is_critical:
		pop_up_node.add_theme_color_override("font_color", Color(1, 0, 0))
	add_child(temp_pop_up)
	
func take_damage(_damage, _is_critical):
	pass
