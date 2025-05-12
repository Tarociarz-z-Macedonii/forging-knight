extends Control

@export var slot_parent : Control

var item_slots : Array[ItemSlot] = []

var _inventory : Inventory


func _ready():
	for child in slot_parent.get_children():
		if child is ItemSlot:
			item_slots.append(child)


func display_inventory(inventory: Inventory):
	if _inventory != inventory:
		if _inventory != null:
			inventory.updated.disconnect(on_inventory_update)
		inventory.updated.connect(on_inventory_update)
	_inventory = inventory
	on_inventory_update()


func on_inventory_update():
	for index in item_slots.size():
		var stack : ItemStack = _inventory.items[index]
		item_slots[index].stack = stack
