extends Node2D

@export var tile_size:Vector2=Vector2(24,21)
@export var move_duration:float=0.18
@export var move_curve:Curve

enum FacingDirection {LEFT, RIGHT}
var facing_direction:FacingDirection=FacingDirection.RIGHT

var started_moving:bool=false

var last_move:Vector2=Vector2.ZERO

@onready var animation:AnimatedSprite2D=$AnimatedSprite2D
@onready var collition:CollisionShape2D=$CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = position.snapped(Vector2(tile_size.x, tile_size.y))

func _process(_delta: float) -> void:
	var input := get_input_dir()
	if input != Vector2.ZERO:
		last_move=input
	if not started_moving and last_move != Vector2.ZERO:
		try_move(last_move)
		last_move=Vector2.ZERO


func get_input_dir() -> Vector2:
	var x := Input.get_axis("ui_left","ui_right")
	var y := Input.get_axis("ui_up","ui_down")

	if abs(x) > abs(y):
		return Vector2(sign(x),0)
	elif y != 0.0:
		return Vector2(0,sign(y))
	return Vector2.ZERO

func try_move(dir: Vector2) -> void:
	var target_pos: Vector2 =position + dir *tile_size

	if is_tile_blocked(target_pos):
		play_idle_animation()
		return
	
	update_facing(dir)
	started_moving=true
	play_walk_animation()

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	if move_curve:
		tween.tween_method(_set_position_along_curve.bind(position,target_pos), 0.0, 1.0, move_duration)
	else:
		tween.tween_property(self,"position",target_pos,move_duration)
	
	tween.tween_callback(_on_move_complete)

func _set_position_along_curve(t: float, from: Vector2, to: Vector2) -> void:
	position=from.lerp(to,move_curve.sample(t))

func _on_move_complete() -> void:
	position=position.snapped(tile_size)
	started_moving=false
	play_idle_animation()

func is_tile_blocked(target: Vector2) -> bool:
	return false

func update_facing(dir: Vector2) -> void:
	if dir.x>0:
		facing_direction=FacingDirection.RIGHT
	elif dir.x<0:
		facing_direction=FacingDirection.LEFT

func get_facing_vector() -> Vector2:
	match facing_direction:
		FacingDirection.LEFT: return Vector2.LEFT
		FacingDirection.RIGHT: return Vector2.RIGHT

	return Vector2.RIGHT

func play_walk_animation() -> void:
	match facing_direction:
		FacingDirection.LEFT: 
			animation.flip_h=true
		FacingDirection.RIGHT:
			animation.flip_h=false

	animation.play("Walk_Animation")	

func play_idle_animation() -> void:
	pass
