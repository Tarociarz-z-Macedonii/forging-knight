class_name ItemStats
extends Resource

@export var sprite: Texture2D 
@export var item_name: String = 'default name'
@export var description: String = 'default description of this amazing item because this item is very very amazing'
var id: int

func is_stackable() -> bool:
	return true
