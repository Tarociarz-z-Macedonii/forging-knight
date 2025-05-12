extends Camera2D

@export var default_zoom: Vector2 = Vector2(1, 1)
@export var inventory_zoom_level: float = 1.7  # Multiplier for zoom level
@export var zoom_duration: float = 0.3
@export var zoom_ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var zoom_trans: Tween.TransitionType = Tween.TRANS_QUAD

var inventory: Node

func _physics_process(_delta: float) -> void:
	follow_cursor()
	
func follow_cursor():
	var pos = get_local_mouse_position() * 0.02
	set_position(pos)

func _ready():
	zoom = default_zoom
	# Get inventory node - adjust this path to match your scene structure
	inventory = get_node("../Inventory")  # Or use $../Inventory
	
	if inventory:
		inventory.inventory_opened.connect(_on_inventory_opened)
		inventory.inventory_closed.connect(_on_inventory_closed)
	else:
		push_warning("Inventory node not found for camera zoom controller")

func _on_inventory_opened():
	var target_zoom = default_zoom * inventory_zoom_level
	zoom_smoothly_to(target_zoom)

func _on_inventory_closed():
	zoom_smoothly_to(default_zoom)

func zoom_smoothly_to(target_zoom: Vector2):
	var tween = create_tween()
	tween.set_trans(zoom_trans)
	tween.set_ease(zoom_ease)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)
