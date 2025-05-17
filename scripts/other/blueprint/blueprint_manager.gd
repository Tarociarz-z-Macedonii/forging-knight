extends Node2D

@onready var inventory = $"../Inventory"
@onready var vgrid = $"../Inventory/UI/Blueprints/VGrid"
@onready var craft: PackedScene = load("res://scenes/UI/blueprint/blueprint_create.tscn")
@onready var craft_material: PackedScene = load("res://scenes/UI/blueprint/material.tscn")
@onready var blueprint_materials = []

var blueprints: Array[BlueprintData]
var items_amounts: Dictionary[String, int] = {}

func _ready() -> void:
	inventory.inventory_updated.connect(update_amounts)

func add_blueprint(blueprint: BlueprintData):
	blueprints.append(blueprint)
	#creates UI
	var inst_craft = craft.instantiate()
	vgrid.add_child(inst_craft)
	var output: TextureRect = inst_craft.get_node("Output")
	var output_name: Label = inst_craft.get_node("Name")
	output.texture = blueprint.output.sprite
	output_name.text = blueprint.output.item_name
	for i in range(blueprint.input.size()):
		var inst_craft_material = craft_material.instantiate()
		inst_craft.add_child(inst_craft_material)
		blueprint_materials.push_back(inst_craft_material)
		var input: TextureRect = inst_craft_material.get_node("Input")
		var amount: BlueprintMaterialLabel = inst_craft_material.get_node("Amount")
		input.texture = blueprint.input[i].item.sprite
		amount.max_amount = blueprint.input[i].amount
		amount.item_name = blueprint.input[i].item.item_name
		amount.amount = get_items_amounts(amount.item_name)
		amount.set_amount()

func update_items_amounts(item_name: String, amount: int):
	if items_amounts.get(item_name) == null:
		items_amounts[item_name] = amount
		return
	items_amounts[item_name] += amount
	print('added')
	print(items_amounts[item_name])
	if items_amounts[item_name] < 0:
		items_amounts[item_name] = 0
		
func get_items_amounts(item_name: String):
	if items_amounts.get(item_name) == null:
		return 0
	return items_amounts[item_name]
	
func update_amounts():
	for material in blueprint_materials:
		var amount: BlueprintMaterialLabel = material.get_node("Amount")
		amount.amount = get_items_amounts(amount.item_name)
		amount.set_amount()
