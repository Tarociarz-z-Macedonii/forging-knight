extends Projectile

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is Player:
		body.take_damage(damage)
		queue_free()
