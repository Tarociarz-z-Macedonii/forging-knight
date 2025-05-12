class_name Slot
extends Panel

@export var item: ItemStats = null
@export var amount: int = 0

func _ready():
	update_slot()

func update_slot():
	if item == null or amount <= 0:
		$Icon.texture = null
		$Amount.text = ""
		$Amount.visible = false
	else:
		$Icon.texture = item.sprite
		$Amount.text = str(amount)
		$Amount.visible = amount > 1

func set_slot(new_item: ItemStats, new_amount: int):
	item = new_item
	amount = clamp(new_amount, 0, ItemStack.max_count)
	update_slot()

func clear_slot():
	item = null
	amount = 0
	update_slot()

func can_accept_item(check_item: ItemStats) -> bool:
	if item == null:
		return true
	if item == check_item and item.is_stackable():
		return amount < ItemStack.max_count
	return false

func _get_drag_data(_at_position):
	if item == null:
		return null

	# Create the drag preview (keeping your exact visual setup)
	var preview_texture = TextureRect.new()
	preview_texture.texture = item.sprite
	preview_texture.size = Vector2(16, 16)
	preview_texture.position = -Vector2(8 * 5, 8 * 5)  # Offset to center
	preview_texture.scale = Vector2(5, 5)
	preview_texture.z_index = 100
	
	var preview = Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)

	return {
		"item": item,
		"amount": amount,
		"source_slot": self
	}

func _can_drop_data(_at_position, data):
	# Only allow drops if the data contains valid item info
	return data is Dictionary and data.has("item") and data.has("amount") and data.has("source_slot")

func _drop_data(at_position, data):
	if not _can_drop_data(at_position, data):
		return

	var source_slot: Slot = data["source_slot"]
	if source_slot == self:
		return  # Don't drop on self

	var dragged_item: ItemStats = data["item"]
	var dragged_amount: int = data["amount"]

	# Case 1: Target slot is empty
	if item == null:
		set_slot(dragged_item, dragged_amount)
		source_slot.clear_slot()
		return

	# Case 2: Same item type - try to merge stacks
	if item == dragged_item and item.is_stackable():
		var total = amount + dragged_amount
		if total <= ItemStack.max_count:
			set_slot(item, total)
			source_slot.clear_slot()
		else:
			var remaining = total - ItemStack.max_count
			set_slot(item, ItemStack.max_count)
			source_slot.set_slot(item, remaining)
		return


	# Case 3: Different items - swap them
	var temp_item = item
	var temp_amount = amount
	set_slot(dragged_item, dragged_amount)
	source_slot.set_slot(temp_item, temp_amount)
