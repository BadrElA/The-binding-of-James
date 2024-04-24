extends Node2D


#listen for full screen input
func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		var win_state = DisplayServer.window_get_mode()
		
		if  win_state in [DisplayServer.WINDOW_MODE_FULLSCREEN, \
						   DisplayServer.WINDOW_MODE_MAXIMIZED] : 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2(960, 540))
			
		elif win_state == DisplayServer.WINDOW_MODE_WINDOWED:  	
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
