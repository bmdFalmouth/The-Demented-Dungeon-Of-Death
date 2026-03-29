extends Node2D

@export var tile_size:Vector2=Vector2(24,21)
@export var move_duration:float=0.18
@export var move_curve:Curve

enum FacingDirection {LEFT, RIGHT}
var facing_direction:FacingDirection=FacingDirection.RIGHT

var is_moving:bool=false

var last_move:Vector2=Vector2.ZERO

@onready var animation:AnimatedSprite2D=$AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
