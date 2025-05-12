class_name ItemStack

signal item_changed(item: ItemStats)

static var max_count := 999

var item : ItemStats:
	set(val):
		item = val
		item_changed.emit(val)
		
var count : int

func _init(some_item: ItemStats, some_count: int = 0):
	self.item = some_item
	self.count = some_count
	
func is_empty() -> bool:
	return item == null
	
func _to_string() -> String:
	return "Item: " + str(item) + " - " + str(count)
