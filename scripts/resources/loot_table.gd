extends Resource
class_name LootTable

@export var item_rolls : Array[ItemRoll]
@export var roll_times := 1

func roll_loot() -> Array[ItemStack]:
	var items : Array[ItemStack] = []
	var weights : Array[float] = []
	
	# Filter out invalid rolls and collect weights
	for roll in item_rolls:
		if roll and roll.item:
			weights.append(roll.weight)
	
	if weights.is_empty():
		return items
	
	for i in roll_times:
		var index := randi_range(0, weights.size() - 1)  # Simple random selection
		var roll : ItemRoll = item_rolls[index]
		if roll and roll.item:
			items.append(ItemStack.new(roll.item, roll.amount))
			
	return items
