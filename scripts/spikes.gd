extends Area2D
class_name Spikes


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is Player) : 
		body.handle_collision(self, body_shape_index)
	elif (body is Enemy):
		body._on_body_entered(self)
