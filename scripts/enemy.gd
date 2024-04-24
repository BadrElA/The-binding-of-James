extends RigidBody2D
class_name Enemy

"""
Abstract enemy class.

Every method is made to be overridden.
Every property is made to be overriden or left as default,
The implementer must connect the _on_body_entered signal.

Any standard method MUST call its parent equivalent 
"""


# public fields
@export 
var PlayerRef : Player
@export
var TearContainer : Node2D

var MaxHealth : float = 10 
var ContactDamage : int = 1


#private fields
var health := 0.0

var flashSpeed = 5 #proportion of flash that disappears per second
var curFlashAmt = 0

var growTarget : Node2D
var degrowSpeed : Vector2
var curScaleModifier : Vector2 = Vector2.ZERO


func _ready() -> void:
	assert(PlayerRef != null, "Enemy must have reference to player")
	assert(TearContainer != null, "Enemy must have tear container")
	
	health = MaxHealth
	

func flash_for(dt : float):
	"""
	Flashes red for input amount of time 
	"""	
	if dt == 0 : 
		return 
	
	flashSpeed = 1/dt
	curFlashAmt = 1
	
func pulsate_node(_growTarget : Node2D, growScale : Vector2, growDt : float) -> void : 
	#finish up previous pulse if applicable 
	if curScaleModifier != Vector2.ZERO : 
		growTarget.set_scale(growTarget.get_scale() - curScaleModifier)
		
	#setup vars for new pulse
	growTarget = _growTarget
	
	degrowSpeed = Vector2(growScale.x / growDt, \
						  growScale.y / growDt)
	curScaleModifier = growScale
	
	#apply the initial scaling 
	growTarget.set_scale(growTarget.get_scale() + curScaleModifier)
	
	
	
func _on_tear_contact(tear : PlayerProjectile) -> void:
	"""
	Default tear contact behavior,
	Substract hp, flash red
	"""
	health -= tear.Damage
	if health <= 0 : 
		queue_free()
		
	flash_for(0.2)
	
func _on_body_entered(body : Node) -> void : 
	#auto-handle player projectiles

	if body is PlayerProjectile : 
		_on_tear_contact(body as PlayerProjectile)
		
		

func _physics_process(delta: float) -> void:
	pass

func _process(delta: float) -> void:
	
	#handle red flashing logic
	set_modulate(Color(1, 1-curFlashAmt, 1-curFlashAmt))
	if curFlashAmt > 0: 
		curFlashAmt -= flashSpeed * delta 
		curFlashAmt = max(curFlashAmt, 0)
		
	#handle pulsating logic
	if curScaleModifier != Vector2.ZERO : 
		var newMod = curScaleModifier - (degrowSpeed * delta)
		var curSize = growTarget.get_scale()
		
		if newMod.angle() != curScaleModifier.angle():
			growTarget.set_scale(curSize - curScaleModifier)
			curScaleModifier = Vector2.ZERO
		else: 
			growTarget.set_scale(curSize - degrowSpeed * delta)
			curScaleModifier = newMod
