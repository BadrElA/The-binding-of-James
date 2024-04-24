extends EnemyProjectile
class_name FunctionProjectile

#some sample functions 
#static func expRot(t : float) -> Vector2 :
	#var p1 = Vector2(-2 *sin(t), 2 *cos(t))
	#var p2 = Vector2(-t * cos(t), -t * sin(t))
	#return 10 * (p1 + p2)



# Important fields from parent
#var Speed : float
#var Damage : float 	

# Child fields
var PositionFunction := func(x) : return Vector2.ZERO
var timeElapsed := 0.0



func _process(delta: float) -> void:
	timeElapsed += delta
	position = PositionFunction.call(timeElapsed)
