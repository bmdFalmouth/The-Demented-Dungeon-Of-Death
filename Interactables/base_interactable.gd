@tool
extends StaticBody2D

func _notification(what: int) -> void:
	if what== NOTIFICATION_TRANSFORM_CHANGED and Engine.is_editor_hint():
		if is_inside_tree():
			snap_to_tile_centre()

var revealed: bool=false
var player: CharacterBody2D=null

const TILE_SIZE:=Vector2(24,21)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snap_to_tile_centre()
	if Engine.is_editor_hint():
		return
	hide()
	player=get_tree().get_first_node_in_group("player")
	if player:
		print("Interactable: player found, connecting signal")
		player.visibility_updated.connect(on_visibility_updated)
	else:
		print("Interactable: player NOT found")

func on_visibility_updated() -> void:
	if revealed:
		return
	print("Interactable: visibility check at ", global_position)
	print("  in radius: ", player.is_tile_in_radius(global_position))
	print("  raycast clear: ", player.is_visible_from_player(global_position))
	if player.is_tile_in_radius(global_position) and player.is_visible_from_player(global_position,get_rid_for_raycast()):
		revealed=true
		show()

func snap_to_tile_centre() -> void:
	global_position.x=floor(global_position.x/TILE_SIZE.x)* TILE_SIZE.x + TILE_SIZE.x *0.5
	global_position.y=floor(global_position.y/TILE_SIZE.y)* TILE_SIZE.y + TILE_SIZE.y *0.5

func interact()->void:
	pass

func get_rid_for_raycast() -> RID:
	return get_rid()