extends RigidBody2D
class_name Player

#constants (that probably shouldn't change)
const LIN_DRAG = 5
const vecToHeadAnim = {
	Vector2(0, 0) : "None",
	Vector2(0, -1) : "shoot_up",
	Vector2(0, 1) : "shoot_down",
	Vector2(-1, 0) : "shoot_left",
	Vector2(1, 0) : "shoot_right"
}

const SPEED_TRANSFER = 0.08 #how much character speed goes into bullets
const FLICKER_DT = 0.1 #duration of a flicker (in s)


#character attributes
@export 
var StartHP : int = 4   
@export
var Speed : float = 1.5  #note : only use EffectiveSpeed in code
var EffectiveSpeed : float : 
	get : return Speed * 1_600
@export 
var Friction : float = 5
@export 
var TearRate : float = 3
@export 
var Damage : float = 3.5 
@export 
var ShotSpeed : float = 6
@export 
var ShotRange : float = 10


	
	
#loading scene objects
@onready
var Projectile := preload("res://scenes/projectile.tscn")
@onready
var Head := get_node("PHead")
@onready
var Body := get_node("PBody")
@onready
var ShotCooldown := get_node("ShotCooldown")
@onready
var Hitbox := get_node("PCollider")

@onready
var rightSpawner := get_node("TearSpawners/RightSpawner")
@onready
var leftSpawner := get_node("TearSpawners/LeftSpawner")
@onready
var upSpawner := get_node("TearSpawners/UpSpawner")
@onready
var downSpawner := get_node("TearSpawners/DownSpawner")


# public members 
var Health : int = StartHP 
@onready
var IsHitboxShown = get_node("PHitboxSprite").visible

# private members
@onready
var lastPos : Vector2 = get_position()

var flickerTimer := 0.0
var currentFlicker := 0.0

var currentIFrames := 0.0
var isInvincible : 
	get : return currentIFrames > 0


#misc 
@export
var TearContainer : Node2D



func _ready():
	assert(TearContainer != null, "Player must have tear container")
	
	#set the proper tear rate and body drag
	linear_damp = LIN_DRAG
	ShotCooldown.set_wait_time(1/TearRate)
	


func cardinal(vector):
	"""
	Returns closest cardinal unit vector to input vector
	"""
	if abs(vector.y) > abs(vector.x):
		return Vector2(0, sign(vector.y))
	else : 
		return Vector2(sign(vector.x), 0)
		
		

func _process(delta):
	"""
	Handle movement and shooting
	"""
	var inputVec = Vector2()
	
	#handle movement logic
	if Input.is_action_pressed("move_up"):
		inputVec.y = -1
	elif Input.is_action_pressed("move_down"):
		inputVec.y = 1
		
	if Input.is_action_pressed("move_right"):
		inputVec.x = 1
	elif Input.is_action_pressed("move_left"):
		inputVec.x = -1
		
	if (inputVec != Vector2.ZERO):
		#apply force to our character
		inputVec = inputVec.normalized()
		var moveVec = inputVec * EffectiveSpeed
		#apply_force(moveVec, Hitbox.get_position())
		apply_central_force(moveVec)
		
		#set the walk animation
		if (inputVec.x != 0):
			Body.play("walk_horizontal")
			Body.set_flip_h(inputVec.x < 0)
		else:
			Body.play("walk_vertical")
			

	else: 
		Body.play("walk_vertical") #default state
		Body.set_flip_h(false)
		Body.set_frame(0)
		Body.pause()

	
	
	#handle shooting logic
	var shotInput = false
	var shootVec = Vector2(0, 0)
	var shootPos : Vector2
	
	
	#create base shooting vector
	if Input.is_action_pressed("shoot_up"):
		shootVec = Vector2(0, -1)
		shootPos = upSpawner.global_position
	elif Input.is_action_pressed("shoot_down"):
		shootVec = Vector2(0, 1)
		shootPos = downSpawner.global_position
	elif Input.is_action_pressed("shoot_left"):
		shootVec = Vector2(-1, 0)
		shootPos = leftSpawner.global_position
	elif Input.is_action_pressed("shoot_right"):
		shootVec = Vector2(1, 0)
		shootPos = rightSpawner.global_position

	
	shotInput = shootVec != Vector2.ZERO
	#handle head direction if didn't shoot 
	if not shotInput :
		if inputVec != Vector2.ZERO : 
			#face walk direction if not shooting
			Head.play(vecToHeadAnim[cardinal(inputVec)])
			Head.set_frame(0)
			Head.pause()
		else:  
			Head.play("shoot_down") #default state
			Head.set_frame(0)
			Head.pause()
		
	#spawn the bullet if applicable
	if shotInput and ShotCooldown.get_time_left() <= 0:
		#reset timer
		ShotCooldown.start()
		
		#set facing direction
		Head.play(vecToHeadAnim[shootVec])
		
		 #apply some of the player momentum to the bullet 
		var perturbation = Vector2()
		if (get_position() - lastPos != Vector2.ZERO) : 
			perturbation = (get_position() - lastPos) * SPEED_TRANSFER
		
		#create a projectile with proper values
		var bullet = Projectile.instantiate()
		bullet.dirVec = shootVec + perturbation 
		bullet.global_position = shootPos
		bullet.Damage = Damage
		bullet.Speed = ShotSpeed
		
		
		TearContainer.add_child(bullet)
		
	#handle flickering logic 
	if (flickerTimer != 0):
		flickerTimer -= delta
		currentFlicker -= delta
		
		if flickerTimer <= 0 :
			set_visible(true)
			flickerTimer = 0
			
		elif currentFlicker <= 0 : 
			set_visible(not is_visible())
			currentFlicker = FLICKER_DT
			
	#check for input to make hitbox visible
	if Input.is_action_just_pressed("show_hitbox"):
		IsHitboxShown = not IsHitboxShown;
		$PHitboxSprite.set_visible(IsHitboxShown)
		
			
			
	#decrease iframes
	currentIFrames = max(currentIFrames - delta, 0)
	#update last pos
	lastPos = get_position()
	

func take_damage(healthLoss : int, iframes : float, knockbackVec: Vector2):
	"""
	Makes isaac take damage, and handles all associated subroutines.
	"""
	if isInvincible :
		return 
		
	#reduce health
	Health -= healthLoss
	
	#set flicker + i frames
	currentIFrames = iframes
	
	flickerTimer = iframes
	currentFlicker = FLICKER_DT
	
	#set knockback
	apply_impulse(knockbackVec, Hitbox.get_position())
	

	
func on_center_collision(other : Node) : 
	"""
	Handle player specific logic when a collision happens
	"""
	
	if (other is Enemy):
		var enemy := other as Enemy
		var damageTaken = enemy.ContactDamage
		
		var knockbackVec = (get_global_position() - enemy.get_global_position())\
						   .normalized()
		knockbackVec *= EffectiveSpeed * 0.3
		
		take_damage(damageTaken, 1, knockbackVec)
		
	elif (other is EnemyProjectile) : 
		var projectile := other as EnemyProjectile
		var damageTaken = projectile.Damage
		
		var knockbackVec = projectile.DirectionVector.normalized()
		knockbackVec *= EffectiveSpeed * projectile.KnockbackStrength
		
		take_damage(damageTaken, 1, knockbackVec)
		


func on_feet_collision(other : Node) -> void : 
	if (other is Spikes):
		take_damage(1, 1, Vector2(0, 0))
	elif (other is EnemyProjectile):
		on_center_collision(other) #hmm questionnable code

func handle_collision(other : Node, bodyPart : int):
	if (bodyPart == 0):
		on_center_collision(other)
	elif (bodyPart == 1):
		on_feet_collision(other)
	else : 
		assert(false, "Unknown player body part")

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, hitboxID: int) -> void:
	handle_collision(body, hitboxID)
