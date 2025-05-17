extends Control
class_name Inventory

enum ActiveCategory {INVENTORY, BLUEPRINTS}

signal inventory_opened
signal inventory_closed
signal inventory_updated

@onready var hotbar : HBoxContainer
@onready var grid : GridContainer = $UI/GridContainer
@onready var blueprints : Node = $UI/Blueprints
@onready var buttons : Control = $UI/Buttons
@onready var item_button : Button = $UI/Buttons/Items
@onready var blueprint_button : Button = $UI/Buttons/Blueprints
@onready var blueprint_manager : Node2D = $"../BlueprintManager"
var slots : Array[Slot] = []
@export var hotbar_slots: Array[HotbarSlot] = [] 

var is_open: bool = false
var category: ActiveCategory = ActiveCategory.INVENTORY
var active_slot_index: int = 0

func _ready():
	slots = []
	for child in grid.get_children():
		if child is Slot:
			slots.append(child)
	for slot in slots:
		slot.update_slot()
	for hotbar_slot in hotbar_slots:
		hotbar_slot.inventory = self
		
	item_button.pressed.connect(on_item_button)
	blueprint_button.pressed.connect(on_blueprint_button)

func _process(delta: float) -> void:
	change_active_slots()

func _input(event):
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func on_item_button():
	category = ActiveCategory.INVENTORY
	blueprints.visible = false
	grid.visible = true
	
func on_blueprint_button():
	category = ActiveCategory.BLUEPRINTS
	blueprints.visible = true
	grid.visible = false

func toggle_inventory():
	is_open = not is_open
	buttons.visible = is_open
	if category == ActiveCategory.INVENTORY:
		blueprints.visible = false
		grid.visible = is_open
	elif category == ActiveCategory.BLUEPRINTS:
		grid.visible = false
		blueprints.visible = is_open

	if is_open:
		emit_signal("inventory_opened")
	else:
		emit_signal("inventory_closed")

func add_item(item_stack: ItemStack) -> ItemStack:
	if not item_stack or item_stack.is_empty():
		return null
		
	var is_stackable = item_stack.item.is_stackable()
	
	if is_stackable:
		# Try to stack with existing slots
		for slot in slots:
			if slot.item == item_stack.item and slot.amount < ItemStack.max_count:
				var remaining_space = ItemStack.max_count - slot.amount
				var add_amount = min(remaining_space, item_stack.count)
				slot.amount += add_amount
				item_stack.count -= add_amount
				slot.update_slot()
				
				if item_stack.count <= 0:
					blueprint_manager.update_items_amounts(item_stack.item.item_name, add_amount)
					emit_signal("inventory_updated")
					return null
					
	for slot in slots:
		if slot.item == null:
			var add_count = item_stack.count if is_stackable else 1
			slot.set_slot(item_stack.item, add_count)
			item_stack.count -= add_count
			
			if item_stack.count <= 0:
				blueprint_manager.update_items_amounts(item_stack.item.item_name, slot.amount)
				emit_signal("inventory_updated")
				return null
				
	emit_signal("inventory_updated")
	return item_stack

func has_item(item: ItemStats, amount: int = 1) -> bool:
	var total = 0
	for slot in slots:
		if slot.item == item:
			total += slot.amount
			if total >= amount:
				return true
	return false

func remove_item(item: ItemStats, amount: int = 1) -> bool:
	if not has_item(item, amount):
		return false
		
	var remaining = amount
	for slot in slots:
		if slot.item == item:
			var remove_amount = min(remaining, slot.amount)
			slot.amount -= remove_amount
			remaining -= remove_amount
			
			if slot.amount <= 0:
				blueprint_manager.update_items_amounts(slot.item.item_name, remove_amount)
				slot.clear_slot()
				
			if remaining <= 0:
				blueprint_manager.update_items_amounts(slot.item.item_name, 0)
				emit_signal("inventory_updated")
				return true
				
	emit_signal("inventory_updated")
	return false
	
func change_active_slots():
	if Input.is_action_just_pressed("Change_Hotbar_Slot_1"):
		change_active_slot(0)
	elif Input.is_action_just_pressed("Change_Hotbar_Slot_2"):
		change_active_slot(1)
	elif Input.is_action_just_pressed("Change_Hotbar_Slot_3"):
		change_active_slot(2)
	elif Input.is_action_just_pressed("Change_Hotbar_Slot_4"):
		change_active_slot(3)

func change_active_slot(index):	
	active_slot_index = index
	for i in range(len(hotbar_slots)):
		hotbar_slots[i].modulate = Color(1,1,1,1)
	hotbar_slots[index].modulate = Color(.7, .7, 1, 1)
	hotbar_slots[index].on_set_as_active()
