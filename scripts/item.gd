extends Node
class_name Item

"""
Abstract class for all items,
Any methods here are meant to be overriden
"""
var Player : Player

func _ready() -> void:
	assert(Player != null, "Item has no reference to the player")

func process_tear(tear : PlayerProjectile) -> PlayerProjectile :
	return tear
	
	
func _on_room_enter() -> void:
	pass
	
func _on_damage_taken() -> void : 
	pass
	
func _on_enemy_killed() -> void : 
	pass


func _process(delta: float) -> void:
	pass
