class_name ItemDrop
extends Node2D

@onready var item_sprite: Sprite2D = $ItemSprite
@onready var hitbox: Area2D = $Hitbox
@onready var amount: Label = $Amount

var stack : ItemStack:
	set(value):
		stack = value
		if is_inside_tree() and stack and not stack.is_empty():
			update_display()

var velocity : Vector2
var velocity_tween : Tween

func _ready():
	if not stack or stack.is_empty():
		queue_free()
		return
		
	hitbox.body_entered.connect(self.on_body_entered)
	update_display()
	
	apply_drop_impulse()


func apply_drop_impulse():
	var speed = randf_range(75, 100)
	velocity = Vector2.RIGHT.rotated(deg_to_rad(randf_range(0.0, 360.0))) * speed
	velocity_tween = create_tween()
	velocity_tween.tween_property(self, "velocity", Vector2.ZERO, 0.75)
	velocity_tween.set_trans(Tween.TRANS_BOUNCE)
	velocity_tween.set_ease(Tween.EASE_OUT)

func initialize(item_stack: ItemStack, drop_position: Vector2):
	if not item_stack or item_stack.is_empty():
		queue_free()
		return

	set("stack", item_stack)
	global_position = drop_position
	if is_inside_tree():
		update_display()


func update_display():
	if not stack or stack.is_empty():
		queue_free()
		return
		
	item_sprite.texture = stack.item.sprite
	amount.text = str(stack.count)
	amount.visible = stack.count > 1

func on_body_entered(body: Node2D) -> void:
	print("Entered by: ", body)
	if body is Player:
		print("Player detected! Picking up...")
		body.pickup_item(self)
		
func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		global_position += velocity * delta
