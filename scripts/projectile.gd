extends RigidBody2D
class_name PlayerProjectile


var Speed : float = 0
var Damage : float = 3.5
var Knockback : float = 1

@onready
var splash = preload("res://scenes/tear_splash.tscn")


var dirVec := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	#set our constant movement vector
	apply_impulse(dirVec * Speed * 100)


func _on_body_entered(body):
	var splashRot = dirVec.angle() - Vector2(-1, 0).angle()
	var deathSplash = splash.instantiate()
	
	deathSplash.set_rotation(splashRot)
	deathSplash.set_position(get_position())
	deathSplash.set_emitting(true)
		
	get_parent().add_child(deathSplash)
	queue_free()
