extends Node

@export var keys: int=0

func add_key()->void:
	keys+=1

func use_key()->bool:
	if keys > 0:
		keys -=1
		return true
	
	return false

func has_key()->bool:
	return keys > 0
