class_name Player
extends CharacterBody2D

@export var current_speed: int = 500
var max_health: float = 100
var current_health: float
var health_bar_packed = preload("res://scenes/UI/player_health_bar.tscn")
var health_bar: ProgressBar
@onready var canvas = $"../CanvasLayer"
@onready var inventory = $Inventory
@onready var camera = $Camera2D
@onready var animator = $"AnimatedSprite2D"

var screen_size
var flipped: bool
var can_move = true
var zoom_amount = Vector2(0.7, 0.7)

func _ready() -> void:
	health_bar = health_bar_packed.instantiate()
	canvas.add_child(health_bar)
	current_health = max_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	screen_size = get_viewport_rect().size
	animator.play("idle")
	inventory.inventory_opened.connect(_on_inventory_opened)
	inventory.inventory_closed.connect(_on_inventory_closed)
	
func _physics_process(_delta: float) -> void:
	#print(current_hp)
	_apply_velocity()
	if can_move:
		move_and_slide()
		_flip()
		_play_anims()
	else:
		animator.play("idle")

func _apply_velocity():
	var input_direction = Input.get_vector('Move_Left', 'Move_Right', 'Move_Up', 'Move_Down')
	velocity = current_speed * input_direction 
	
func _flip():
	if not animator.flip_h and velocity.x < 0:
		animator.flip_h = true
		flipped = true
		return
	if animator.flip_h and velocity.x > 0:
		animator.flip_h = false
		flipped = false
	
func _play_anims():
	if velocity.length() > 0:
		if animator.animation != "walk":
			animator.play("walk")
		return
	if animator.animation != "idle":
		animator.play("idle")
	
func pickup_item(item_drop: ItemDrop):
	var remaining_stack = inventory.add_item(item_drop.stack)
	if remaining_stack:
		#print("Inventory full, remaining stack: ", remaining_stack)
		item_drop.stack = remaining_stack
	else:
		item_drop.queue_free()

func _on_inventory_opened():
	can_move = false
	Engine.time_scale = 0.3
	
func _on_inventory_closed():
	can_move = true
	Engine.time_scale = 1.0
	
func take_damage(damage):
	current_health -= damage
	if current_health <= 0:
		SceneManager.call_deferred("death")
	health_bar.value = current_health
