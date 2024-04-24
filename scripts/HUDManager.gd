extends Control

@export 
var PlayerRef : Player




#loading children nodes
@onready 
var SpeedLabel  :  Label = get_node("Speed/SpeedT")
@onready
var FrictionLabel : Label = get_node("Friction/FrictionT")
@onready 
var DamageLabel  :  Label = get_node("Damage/DamageT")
@onready 
var RangeLabel :  Label = get_node("Range/RangeT")
@onready 
var TearsLabel  :  Label = get_node("Tears/TearsT")









# Called when the node enters the scene tree for the first time.
func _ready():
	#synchronize values to player stats
	assert(PlayerRef != null)
	



func _process(delta):
	#synchronize player stats
	SpeedLabel.set_text(str("%-3.2f" % PlayerRef.Speed))
	FrictionLabel.set_text(str("%-3.2f" % PlayerRef.Friction))
	DamageLabel.set_text(str("%-3.2f" % PlayerRef.Damage))
	RangeLabel.set_text(str("%-3.2f" % PlayerRef.ShotRange))
	TearsLabel.set_text(str("%-3.2f" % PlayerRef.TearRate))

	
	#respond to hud toggles
	if Input.is_action_just_pressed("toggle_hud"):
		set_visible(not is_visible())
