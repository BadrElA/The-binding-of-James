extends Label

var elapsedTime : float = 0

var hours : int = 0
var minutes : int = 0
var seconds : int = 0
var centis : int = 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	elapsedTime += delta
	
	centis = (elapsedTime - int(elapsedTime)) * 100
	seconds = int(elapsedTime) % 60
	minutes = int(elapsedTime / 60) % 60
	hours = int(elapsedTime) % 3600
	
	set_text("%02d:%02d:%02d" % [minutes, seconds, centis])
	#set_text("glizzy")
