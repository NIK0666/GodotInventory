class_name BaseStackableItem
extends Item

@export var max_count: int = 1
@export var max_stored_count: int = 600


func is_stackable()->bool:
	return true
