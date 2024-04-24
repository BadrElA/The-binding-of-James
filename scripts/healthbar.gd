extends Control

@export 
var PlayerRef : Player

#consts
const HEART_GAP : float = 50 

#loading some images
var RedHeart = preload("res://assets/icons/full_heart.webp")
var HRedHeart = preload("res://assets/icons/half_heart.webp")

# private members
var curHealth : int = 0
var heartsList : Array[TextureRect] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(PlayerRef != null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#synchronize healthbar (if applicable)
	if PlayerRef.Health > curHealth :

		#add hearts
		for i in range(PlayerRef.Health - curHealth):
			var heartX = (HEART_GAP * len(heartsList)) 
			var newHeart = TextureRect.new()	
			
			newHeart.set_position(Vector2(heartX, 0))
			newHeart.set_texture(RedHeart)
			newHeart.set_size(Vector2(40, 40))
			
			add_child(newHeart)
			heartsList.append(newHeart)  
			
		curHealth = PlayerRef.Health
			
	elif PlayerRef.Health < curHealth and PlayerRef.Health >= 0: 
		#pop hearts
		for i in range(curHealth - PlayerRef.Health):
			heartsList.pop_back().queue_free()
		
		curHealth = PlayerRef.Health
