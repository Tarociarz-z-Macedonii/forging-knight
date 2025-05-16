class_name Blueprint
extends Area2D

@export var data: BlueprintData 
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player:
		body.get_node('BlueprintManager').add_blueprint(data)
		queue_free()
