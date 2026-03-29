extends Node2D

@export var tile_size: Vector2 = Vector2(24, 21)
@export var move_duration: float = 0.18
@export var move_curve: Curve

enum FacingDirection { LEFT, RIGHT }
var facing_direction: FacingDirection = FacingDirection.RIGHT

var started_moving: bool = false
var last_move: Vector2 = Vector2.ZERO
var current_tween: Tween = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	position.x = round(position.x / tile_size.x) * tile_size.x
	position.y = round(position.y / tile_size.y) * tile_size.y

func _process(_delta: float) -> void:
	if started_moving:
		return
	var input := get_input_dir()
	if input != Vector2.ZERO:
		last_move = input

	if not started_moving and last_move != Vector2.ZERO:
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
	started_moving = true  # gate closes immediately

	var target_pos: Vector2 = position + (dir * tile_size)
	print("from: ", position, " to: ", target_pos, " delta: ", target_pos - position)

	if is_tile_blocked(target_pos):
		started_moving = false  # re-open gate so next input works
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
	
	position.x = round(position.x / tile_size.x) * tile_size.x
	position.y = round(position.y / tile_size.y) * tile_size.y
	started_moving = false
	print("move complete at: ", position)
	play_idle_animation()

func is_tile_blocked(target: Vector2) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		position,
		target,
		0b00000010
	)
	# exclude expects RIDs — get it from the CollisionShape2D's parent body if you have one,
	# or leave exclude empty since the raycast starts inside the player tile anyway
	var result := space.intersect_ray(query)
	return not result.is_empty()

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