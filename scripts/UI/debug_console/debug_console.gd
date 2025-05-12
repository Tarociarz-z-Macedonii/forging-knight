extends LineEdit

var item_in_world_template : PackedScene = preload("res://scenes/UI/inventory/item_drop.tscn")
@onready var player = $"../../../Player"
@onready var vbox = $"../VBoxContainer"
@onready var container = $"../"
var command_used: bool
var labels: Array[Label]
var max_labels = 16

func _ready() -> void:
	text_submitted.connect(_process_commands)	
	
func _process(delta: float) -> void:	
	_enable_and_disable()
	
func _enable_and_disable():
	if Input.is_action_just_pressed("Debug_Menu"):
		container.visible = !container.visible
		player.can_move = !container.visible
		if container.visible:
			grab_focus()
			clear()

func create_label(message):
	var label = Label.new()
	label.text = message
	vbox.add_child(label)
	labels.push_front(label)
	
	if len(labels) > max_labels:
		labels.pop_back().queue_free()

func _process_commands(text):
	clear()
	command_used = false
	var parts = text.split(" ")
	if len(parts) == 0:
		return
	create_label("> " + parts[0])
	help(parts)
	create(parts)
	items(parts)
	if not command_used:
		create_label("invalid command")
	
func help(parts):
	if parts[0] == "help":
		command_used = true
		if (len(parts) > 1):
			create_label("this command does not have arguments")
			return
			
		create_label("help - shows every commands")
		create_label("create (id, amount, position x, position y) - creates item")
		create_label("items - shows every item's id")
		
func create(parts):
	if parts[0] == "create":
		command_used = true
		if( (len(parts) < 2 and len(parts) > 5) or (not ItemDatabase.items_ids.get(parts[1])) or 
		(len(parts) == 3 and not parts[2].is_valid_int()) or (len(parts) == 4) or 
		(len(parts) == 5 and (not parts[3].is_valid_int() or not parts[4].is_valid_int())) ):
			create_label("invalid arguments")
			return 
			
		var temp_item_drop: ItemDrop = item_in_world_template.instantiate()
		var temp_item_stack = ItemStack.new(ItemDatabase.items[ItemDatabase.items_ids[parts[1]]])
		if len(parts) > 2 and parts[2].is_valid_int():
			temp_item_stack.count = parts[2]
		else:
			temp_item_stack.count = 1
		if len(parts) == 5 and parts[3].is_valid_int() and parts[4].is_valid_int():
			temp_item_drop.initialize(temp_item_stack, player.global_position / 6 + Vector2(int(parts[3]),int(parts[4])))
		else:
			temp_item_drop.initialize(temp_item_stack, player.global_position / 6)
		get_tree().current_scene.call_deferred("add_child", temp_item_drop)
		create_label("item spawned")

func items(parts):
	if parts[0] == "items":
		command_used = true
		if (len(parts) > 1):
			create_label("this command does not have arguments")
			return
		var keys = ItemDatabase.items_ids.keys()
		for key in keys:
			create_label(key)
		
		
		
		
		
		
