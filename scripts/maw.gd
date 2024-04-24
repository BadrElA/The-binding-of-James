extends Enemy

#constants for easy access
const SHOT_SPEED : float = 1 * 400
const SHOT_CONE_SIZE := PI/16

const COOLDOWN_LOW := 0.6
const COOLDOWN_HIGH := 1.2

const SHOT_ANIM_DT = 0.3
const VIEW_RANGE = 300

#private members
@onready
var shotCooldown = get_node("ShotCooldown")
@onready
var shotCannon = get_node("MawCannon")
@onready 
var animationCooldown = get_node("AnimationCooldown")
@onready
var sprite = get_node("MawSprite")
@onready
var ProjectileClass = load("res://scenes/enemy_projectile.tscn")

var rng = RandomNumberGenerator.new()
var playerInView := false

func _ready() -> void : 
	#overriding some values
	MaxHealth = 500
	super()
	
	rng.randomize()
	


func _process(delta: float) -> void:
	super(delta)
	

func _physics_process(delta: float) -> void:
	super(delta)
	
	#raycast towards player
	var pHitboxPos = PlayerRef.Hitbox.global_position
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, \
												   pHitboxPos)
	query.collision_mask = 0b111
	
	var result = space_state.intersect_ray(query)

	
	#check if player in field of view
	if result and result.collider is Player and \
	   (result.position - global_position).length() <= VIEW_RANGE  :
		playerInView = true 
	else : 
		playerInView = false

func _on_shot_cooldown_timeout() -> void:
	#defer shot if player not visible by enemy
	if not playerInView : 
		shotCooldown.start(1)
		return 
	
	#establish line of shot
	var playerDir = PlayerRef.global_position - global_position
	playerDir = playerDir.normalized()
	
	var randomAngle = rng.randf_range(-SHOT_CONE_SIZE, SHOT_CONE_SIZE)
	playerDir = playerDir.rotated(randomAngle)
	
	#orient set the spawn point of our tear
	var cannonSize = shotCannon.position.length()
	var newX = cos(playerDir.angle()) * cannonSize
	var newY = sin(playerDir.angle()) * cannonSize
	shotCannon.set_position(Vector2(newX, newY))
	
	
	#create projectile
	var projectile = ProjectileClass.instantiate()
	projectile.set_position(shotCannon.global_position)
	projectile.DirectionVector = playerDir
	projectile.Speed = SHOT_SPEED
	
	TearContainer.add_child(projectile)
	
	#grow when we shoot
	pulsate_node(sprite, Vector2(0.2, 0.2), 0.2)
	
	#reset timer
	shotCooldown.start(rng.randf_range(COOLDOWN_LOW, COOLDOWN_HIGH))
