extends StaticBody2D

@onready var blueprint_drop: PackedScene = load("res://scenes/other/blueprint/blueprint_drop.tscn")
@onready var player: Player = $"/root/Main/Player"
@onready var animator: AnimatedSprite2D = $"AnimatedSprite2D"
var opened: bool = false
var interact_distance: int = 32
var tier: int = 1

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and global_position.distance_to(player.global_position)/6 < interact_distance and not opened:
		opened = true
		animator.play("open")
		_drop_item()

func _drop_item():
	var blueprint_drop_inst: Blueprint =  blueprint_drop.instantiate()
	add_child(blueprint_drop_inst)
	blueprint_drop_inst.data = BlueprintDatabase.pick_blueprint(tier)
