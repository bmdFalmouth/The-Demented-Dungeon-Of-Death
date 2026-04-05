extends StaticBody2D

@export var visible_by_proximity_only : bool =false
var revealed:bool=false

var player: CharacterBody2D=null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	player=get_tree().get_first_node_in_group("player")
	if player:
		print("Interactable: player found, connecting signal")
		player.visibility_updated.connect(on_visibility_updated)
	else:
		print("Interactable: player NOT found")

func on_visibility_updated() -> void:
	print("Interactable: visibility check at ", global_position)
	print("  in radius: ", player.is_tile_in_radius(global_position))
	print("  raycast clear: ", player.is_visible_from_player(global_position))
	if visible_by_proximity_only:
		if player.is_tile_in_radius(global_position):
			show()
		else:
			hide()
		return
	
	if revealed:
		return
	
	if not player.is_tile_in_radius(global_position):
		return
	if player.is_tile_in_radius(global_position) and player.is_visible_from_player(global_position,get_rid_for_raycast()):
		revealed=true
		show()

func interact(player_character)->void:
	pass

func get_rid_for_raycast() -> RID:
	return get_rid()