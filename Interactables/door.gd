@tool
extends "res://Scripts/base_interactable.gd"

@onready var sprite: Sprite2D = $Sprite2D

#func snap_to_tile_centre() -> void:
#	global_position.x=floor(global_position.x/TILE_SIZE.x)* TILE_SIZE.x  + TILE_SIZE.x * 0.5
#	global_position.y=round(global_position.y/TILE_SIZE.y)* TILE_SIZE.y

func open()-> void:
	$CollisionShape2D.disabled = true
	sprite.frame=3
	if player:
		player.update_visibility_layer()

func interact(player_character):
	super.interact(player_character)
	if Inventory.use_key():
		open()
	else:
		print("No Key")
