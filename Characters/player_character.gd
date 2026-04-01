extends CharacterBody2D

signal visibility_updated

@export var tile_size: Vector2 = Vector2(24, 21)
@export var move_duration: float = 0.18
@export var move_curve: Curve
@export var visible_layer: TileMapLayer
@export var vision_radius: int = 4

const VISION_MASK: int = 0b00000110
const MOVE_MASK: int = 0b00001110

enum FacingDirection { LEFT, RIGHT }
var facing_direction: FacingDirection = FacingDirection.RIGHT

var started_moving: bool = false
var last_move: Vector2 = Vector2.ZERO
var current_tween: Tween = null
var debug_ray_target: Vector2 = Vector2.ZERO
var revealed_tiles: Array[Vector2i] = []

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	position.x = floor(position.x / tile_size.x) * tile_size.x + tile_size.x * 0.5
	position.y = floor(position.y / tile_size.y) * tile_size.y + tile_size.y * 0.5
	update_visibility_layer()

func is_tile_in_radius(world_pos: Vector2) -> bool:
	var player_tile:=Vector2i(
		floor(position.x / tile_size.x),
		floor(position.y / tile_size.y)
	)
	var target_tile:=Vector2i(
		floor(world_pos.x / tile_size.x),
		floor(world_pos.y / tile_size.y)
	)

	var diff :=target_tile-player_tile
	return abs(diff.x) <= vision_radius and abs(diff.y) <= vision_radius

func is_visible_from_player(world_pos: Vector2, exclude_rid:RID=RID()) -> bool:
	var space := get_world_2d().direct_space_state
	var dir := (world_pos - position).normalized()
	var shortened_target := world_pos - dir * 2.0  # stop 2px short
	var query := PhysicsRayQueryParameters2D.create(
		position,
		shortened_target,
		VISION_MASK  # your wall physics layer
		)
	query.exclude = [get_rid()]
	if exclude_rid.is_valid():
		query.exclude.append(exclude_rid)
	
	var result:=space.intersect_ray(query)
	if not result.is_empty():
		print("Ray blocked by: ", result.collider, " at ", result.position)
		
	return result.is_empty()

func update_visibility_layer():
	print("re-filling ", revealed_tiles.size(), " tiles")
	for t in revealed_tiles:
		visible_layer.set_cell(t, visible_layer.tile_set.get_source_id(0), Vector2i(0, 0))
	revealed_tiles.clear()
	
	var player_tile := Vector2i(
		floor(position.x / tile_size.x),
		floor(position.y / tile_size.y)
		)

	for x in range(-vision_radius, vision_radius + 1):
		for y in range(-vision_radius, vision_radius + 1):
			var t := player_tile + Vector2i(x, y)
			var world_pos := Vector2(
				t.x * tile_size.x + tile_size.x * 0.5,
				t.y * tile_size.y + tile_size.y * 0.5
				)
			if is_tile_blocked(world_pos):
				# It's a wall — reveal by proximity alone, no raycast
				visible_layer.erase_cell(t)
				revealed_tiles.append(t)
			elif is_visible_from_player(world_pos):
				# It's open space — only reveal if raycast is clear
				visible_layer.erase_cell(t)
				revealed_tiles.append(t)
	
	visibility_updated.emit()

func _process(_delta: float) -> void:
	if started_moving:
		return

	var input := get_input_dir()
	if input != Vector2.ZERO:
		last_move = input

	if last_move != Vector2.ZERO:
		try_move(last_move)
		last_move = Vector2.ZERO

func get_input_dir() -> Vector2:
	var x := Input.get_axis("ui_left", "ui_right")
	var y := Input.get_axis("ui_up", "ui_down")
	if abs(x) > abs(y):
		return Vector2(sign(x), 0)
	elif y != 0.0:
		return Vector2(0, sign(y))
	return Vector2.ZERO

func try_move(dir: Vector2) -> void:
	started_moving = true

	var target_pos: Vector2 = position + (dir * tile_size)

	if is_tile_blocked(target_pos):
		started_moving = false
		play_idle_animation()
		return

	update_facing(dir)
	play_walk_animation()

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_SINE)
	current_tween.set_ease(Tween.EASE_IN_OUT)

	if move_curve:
		current_tween.tween_method(_set_position_along_curve.bind(position, target_pos), 0.0, 1.0, move_duration)
	else:
		current_tween.tween_property(self, "position", target_pos, move_duration)

	current_tween.tween_callback(_on_move_complete)

func _set_position_along_curve(t: float, from: Vector2, to: Vector2) -> void:
	position = from.lerp(to, move_curve.sample(t))

func _on_move_complete() -> void:
	position.x = floor(position.x / tile_size.x) * tile_size.x + tile_size.x * 0.5
	position.y = floor(position.y / tile_size.y) * tile_size.y + tile_size.y * 0.5
	started_moving = false
	update_visibility_layer()
	play_idle_animation()

func is_tile_blocked(target: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var target_centre: Vector2 = Vector2(
		floor(target.x / tile_size.x) * tile_size.x + tile_size.x * 0.5,
		floor(target.y / tile_size.y) * tile_size.y + tile_size.y * 0.5
	)
	debug_ray_target = target_centre
	queue_redraw()
	var query := PhysicsRayQueryParameters2D.create(position, target_centre, MOVE_MASK)
	var result := space.intersect_ray(query)
	return not result.is_empty()

func _draw() -> void:
	if debug_ray_target != Vector2.ZERO:
		var target_local := debug_ray_target - position
		draw_line(Vector2.ZERO, target_local, Color.RED, 1.0)
		draw_line(Vector2(-4, 0), Vector2(4, 0), Color.YELLOW, 1.0)
		draw_line(Vector2(0, -4), Vector2(0, 4), Color.YELLOW, 1.0)

func update_facing(dir: Vector2) -> void:
	if dir.x > 0:
		facing_direction = FacingDirection.RIGHT
	elif dir.x < 0:
		facing_direction = FacingDirection.LEFT

func get_facing_vector() -> Vector2:
	match facing_direction:
		FacingDirection.LEFT:  return Vector2.LEFT
		FacingDirection.RIGHT: return Vector2.RIGHT
	return Vector2.RIGHT

func play_walk_animation() -> void:
	match facing_direction:
		FacingDirection.LEFT:
			animation.flip_h = true
		FacingDirection.RIGHT:
			animation.flip_h = false
	animation.play("Walk_Animation")

func play_idle_animation() -> void:
	pass
