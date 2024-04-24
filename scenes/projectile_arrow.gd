extends Node2D


#public members
var Direction := Vector2.ZERO
var Speed := 0.0



func _ready() -> void : 
	Direction = Direction.normalized()

func rotate_by(theta : float) -> void : 
	var children = get_children()
	
	for childUncast in children : 
		var child = childUncast as Node2D
		var dist = child.position
		
		child.position = Vector2(dist.length() * cos(dist.angle() + theta), \
								 dist.length() * sin(dist.angle() + theta))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Direction * Speed * delta
