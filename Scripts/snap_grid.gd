@tool
extends Node2D

const TILE_SIZE:=Vector2(24,21)

func _notification(what: int) -> void:
	if what== NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		if is_inside_tree():
			snap_to_tile_centre()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snap_to_tile_centre()
	if Engine.is_editor_hint():
		return

func snap_to_tile_centre() -> void:
	global_position.x=floor(global_position.x/TILE_SIZE.x)* TILE_SIZE.x + TILE_SIZE.x *0.5
	global_position.y=floor(global_position.y/TILE_SIZE.y)* TILE_SIZE.y + TILE_SIZE.y *0.5