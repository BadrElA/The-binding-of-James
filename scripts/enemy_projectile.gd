extends Area2D
class_name EnemyProjectile

@export
var splashEffect = load("res://scenes/tear_splash.tscn")

var DirectionVector := Vector2.ZERO
var Speed : float = 0.0
var Damage : int = 1
var KnockbackStrength : float = 0.05

func _process(delta: float) -> void:
	position += DirectionVector * Speed * delta


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is Player):
		body.handle_collision(self, body_shape_index)
		
	# TODO : die and splash
	#var splash = splashEffect.instantiate()
	#splash.modulate = Color(1, 0, 0)
	#splash.emitting = true
	#get_parent().add_child(splash)
	
	queue_free()
