extends Node2D

@onready var vgrid = $"../Inventory/UI/Blueprints/VGrid"
@onready var craft: PackedScene = load("res://scenes/UI/blueprint/blueprint_create.tscn")
@onready var craft_material: PackedScene = load("res://scenes/UI/blueprint/material.tscn")

var blueprints: Array[BlueprintData]

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
		var input: TextureRect = inst_craft_material.get_node("Input")
		var amount: Label = inst_craft_material.get_node("Amount")
		input.texture = blueprint.input[i].item.sprite
		amount.text = "0" + " / " + str(blueprint.input[i].amount) 
		
	print('blueprint added')
