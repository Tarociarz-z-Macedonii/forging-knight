class_name Blueprint
extends Area2D

@export var data: BlueprintData 
var velocity : Vector2
var velocity_tween : Tween

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	apply_drop_impulse()
	
func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		global_position += velocity * delta

func _on_body_entered(body):
	if body is Player:
		body.get_node('BlueprintManager').add_blueprint(data)
		queue_free()

func apply_drop_impulse():
	var speed = randf_range(200, 250)
	velocity = Vector2.RIGHT.rotated(deg_to_rad(randf_range(0.0, 360.0))) * speed
	velocity_tween = create_tween()
	velocity_tween.tween_property(self, "velocity", Vector2.ZERO, 0.75)
	velocity_tween.set_trans(Tween.TRANS_BOUNCE)
	velocity_tween.set_ease(Tween.EASE_OUT)
