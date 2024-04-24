extends Area2D

var done = false

func _on_body_entered(body : Node2D) : 
	if done : 
		return 
		
	#switch visual state
	get_node("PlateSprite").play("pressed")
	
	#TODO : affect gameplay
	
	#don't perform this again
	done = true

