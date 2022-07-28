class_name BaseConsumableItem
extends Item


@export var max_count: int = 1
@export var max_stored_count: int = 600

func is_consumable()->bool:
	return true
