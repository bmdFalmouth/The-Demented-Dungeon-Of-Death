@tool
extends "res://Interactables/base_interactable.gd"

func snap_to_tile_centre() -> void:
	global_position.x=floor(global_position.x/TILE_SIZE.x)* TILE_SIZE.x  + TILE_SIZE.x * 0.5
	global_position.y=round(global_position.y/TILE_SIZE.y)* TILE_SIZE.y

func open()-> void:
	$CollisionShape2D.disabled = true
	if player:
		player.update_visibility_layer()