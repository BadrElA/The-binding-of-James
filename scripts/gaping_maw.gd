extends StaticBody2D


const P1_COOLDOWN := 0.05
const P2_COOLDOWN := 1

var FProjClass = load("res://scenes/function_projectile.tscn")

#public members
@export
var PlayerRef : Player


# child members
var rng = RandomNumberGenerator.new()
var patternList : Array[Callable] = [
	pattern2
	]

var elapsedTime := 0.0
@onready
var shotCooldown = get_node("GMShotCooldown") 
var shotIndex : int = 0

@onready
var patternCooldown = get_node("GMPatternTimer")

var currentPattern : Callable
var currentShotHandler : Callable = Callable()

@onready
var ProjectileArrow = load("res://scenes/projectile_arrow.tscn")




#useful trajectory functions
static func waveTrajectory(theta : float, perturbation : float) -> Callable:
	"""
	Returns a list of the form 
	[initial_velocity, acceleration_function]
	"""
	var magnitude = func(t) : return 150 * t
	var angle = func(t) : return theta + cos(5*t) * atan(perturbation/magnitude.call(t))
	return func(t) : \
		return Vector2(magnitude.call(t) * cos(angle.call(t)), \
					   magnitude.call(t) * sin(angle.call(t)) )





func _ready() -> void:
	rng.randomize()


func _on_shot_ready() -> void:
	if not currentShotHandler.is_null(): 
		currentShotHandler.call()

	
	
func pattern1() -> void :
	#set the shoot handler + duration
	currentShotHandler = pattern1shooter
	patternCooldown.start(5)
	
		
func pattern1shooter() -> void : 
	"""
	Spinny wave pattern
	"""
	var newProj = FProjClass.instantiate()
	newProj.PositionFunction = waveTrajectory(shotIndex * PI**2 / 35, 15)
	add_child(newProj)
	
	shotIndex += 1
	shotCooldown.start(P1_COOLDOWN)
	
func pattern2() -> void : 
	currentShotHandler = pattern2shooter
	patternCooldown.start(10)
	
	
func pattern2shooter() -> void : 
	"""
	Big arrows pattern
	"""
	var newProj = ProjectileArrow.instantiate()
	newProj.Direction = PlayerRef.global_position - global_position
	newProj.Speed = 220
	newProj.rotate_by((PlayerRef.global_position - global_position).angle())
	
	add_child(newProj)
	shotCooldown.start(P2_COOLDOWN)

func _on_pattern_timeout() -> void:
	"""
	Called after the a pattern finishes,
	Chooses the next pattern and initiates it
	"""

	var newPatternIndex = rng.randi_range(0, len(patternList) - 1)
	var newPattern = patternList[newPatternIndex]
	
	
	currentPattern = newPattern
	shotCooldown.start(0.4)
	currentPattern.call()
	
