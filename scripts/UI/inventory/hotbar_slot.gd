class_name HotbarSlot
extends Slot

@onready var weapon_manager = $"../../../../WeaponManager"

var inventory: Inventory = null

func on_set_as_active():
	weapon_manager.equip_weapon(item)
	
func set_slot(new_item: ItemStats, new_amount: int):
	if new_item != null and not (new_item is WeaponStats):
		return  # Only allow weapons
		
	super.set_slot(new_item, new_amount)
	
	if inventory and inventory.hotbar_slots[inventory.active_slot_index] == self:
		on_set_as_active()
		
func _can_drop_data(at_position, data):
	if not super._can_drop_data(at_position, data):
		return false
	if data["item"] is WeaponStats:
		return true
	return false  # Only allow weapons
