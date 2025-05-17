extends Button

@onready var inventory: Inventory = $"../../../../../../"
@onready var blueprint_manager: BlueprintManager = $"../../../../../../../BlueprintManager"
@onready var blueprint_create: BlueprintCreate = $"../../"

func _ready() -> void:
	pressed.connect(on_button_pressed)
func on_button_pressed():
	#Checking if player has required items
	for material: BlueprintMaterial in blueprint_create.blueprint.input:
		if not inventory.has_item(material.item, material.amount):
			return
	#Removing Items required for crafting
	for material: BlueprintMaterial in blueprint_create.blueprint.input:
		inventory.remove_item(material.item, material.amount)
	#Adding Output item to inventory
	inventory.add_item(ItemStack.new(blueprint_create.blueprint.output, 1))
	blueprint_manager.update_amounts()
